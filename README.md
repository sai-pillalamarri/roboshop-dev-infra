# RoboShop Dev Infrastructure

Terraform infrastructure for the RoboShop microservices application in the `dev` environment on AWS.

This repository represents the infrastructure stage of my RoboShop automation work. The environment is split into independent Terraform root modules for networking, security, compute, databases, load balancing, DNS, certificates, and application components.

Each root has its own Terraform state. Later layers discover infrastructure created by earlier layers through AWS Systems Manager Parameter Store rather than reading another layer's Terraform state directly.

## Architecture

```text
                              Internet
                                 |
                           Route 53 / ACM
                                 |
                         Frontend ALB
                                 |
                             Frontend
                                 |
                          Backend ALB
                                 |
              +------------------+------------------+
              |                  |                  |
          Catalogue             User               Cart
              |                  |                  |
              +----------- Application Tier --------+
                                 |
                 +---------------+---------------+
                 |               |               |
              MongoDB           Redis          RabbitMQ
                                                 |
                                               MySQL
```

The VPC provides separate public, private, and database subnet tiers.

The public-facing load balancer handles frontend traffic. Backend services are reached through an internal Application Load Balancer rather than being exposed directly.

## Terraform Layering

The repository is split into numbered directories.

Each directory is an independent Terraform root with its own provider configuration, variables, resources, and remote state.

```text
00-vpc
   |
10-sg
   |
20-sg-rules
   |
30-bastion
   |
40-databases
   |
50-backend-alb
   |
60-catalogue
   |
70-acm
   |
80-frontend-alb
   |
90-components
```

The numbering makes the dependency order explicit. Infrastructure is applied from the lowest number to the highest and destroyed in reverse order.

This keeps the state and blast radius of each infrastructure area separate instead of managing the entire environment through one large Terraform state file.

## How the Layers Communicate

The Terraform roots do not read each other's state directly.

Earlier layers publish resource identifiers to AWS Systems Manager Parameter Store. Later layers read those parameters using Terraform data sources.

For example:

```text
00-vpc
   |
   +-- creates VPC
   |
   +-- writes /roboshop/dev/vpc_id
                          |
                          +--> 10-sg
                          +--> 60-catalogue
                          +--> later infrastructure
```

Security groups follow the same pattern:

```text
10-sg
   |
   +-- creates component security groups
   |
   +-- writes /roboshop/dev/<component>_sg_id
                          |
                          +--> 20-sg-rules
                          +--> 30-bastion
                          +--> 40-databases
                          +--> application layers
```

The parameter naming convention is:

```text
/<project>/<environment>/<key>
```

For example:

```text
/roboshop/dev/vpc_id
```

`project` defaults to `roboshop` and `environment` defaults to `dev`.

## Remote State

Every Terraform root stores its state independently in Amazon S3.

Native S3 state locking is enabled so two Terraform operations cannot safely modify the same state at the same time.

| Terraform root | State key |
| --- | --- |
| `00-vpc` | `roboshop-vpc.tfstate` |
| `10-sg` | `roboshop-sg.tfstate` |
| `20-sg-rules` | `roboshop-sg-rules.tfstate` |
| `30-bastion` | `roboshop-bastion.tfstate` |
| `40-databases` | `roboshop-databases.tfstate` |
| `50-backend-alb` | `roboshop-backend-alb.tfstate` |
| `60-catalogue` | `roboshop-catalogue.tfstate` |
| `70-acm` | `roboshop-acm.tfstate` |
| `80-frontend-alb` | `roboshop-frontend-alb.tfstate` |
| `90-components` | `roboshop-components.tfstate` |

Keeping separate state files means a change to one layer does not require Terraform to manage every resource in the environment.

## Deployment Order

Apply the Terraform roots from top to bottom.

| Order | Directory | Responsibility |
| ---: | --- | --- |
| 1 | [`00-vpc`](./00-vpc) | VPC, subnets, routing, NAT, and network foundation. Publishes network IDs to SSM. |
| 2 | [`10-sg`](./10-sg) | Creates security groups for the RoboShop components and publishes their IDs. |
| 3 | [`20-sg-rules`](./20-sg-rules) | Defines allowed traffic between the security groups. |
| 4 | [`30-bastion`](./30-bastion) | Bastion host used to reach instances in private network tiers. |
| 5 | [`40-database`](./40-database) | MongoDB, Redis, RabbitMQ, MySQL, supporting DNS records, and database configuration. |
| 6 | [`50-backend-alb`](./50-backend-alb) | Internal Application Load Balancer used by backend services. |
| 7 | [`60-catalogue`](./60-catalogue) | Reference implementation of the AMI, launch template, target group, and Auto Scaling pattern. |
| 8 | [`70-acm`](./70-acm) | ACM certificate and Route 53 DNS validation. |
| 9 | [`80-frontend-alb`](./80-frontend-alb) | Internet-facing HTTPS Application Load Balancer for the frontend. |
| 10 | [`90-components`](./90-components) | Deploys the RoboShop application components through a reusable Terraform module. |

Destroy the infrastructure in reverse order so dependent resources are removed before the infrastructure they depend on.

## Application Deployment Pattern

`60-catalogue` contains the explicit version of the application deployment pattern.

It shows the individual resources involved before the same pattern is generalised into a reusable module.

```text
Configured EC2 instance
         |
         v
        AMI
         |
         v
   Launch Template
         |
         v
 Auto Scaling Group
         |
         v
    Target Group
         |
         v
 Application Load Balancer
```

The catalogue service is useful as a reference because the infrastructure can be followed resource by resource.

`90-components` then applies the same pattern across the application components using the shared [`terraform-roboshop-component`](https://github.com/sai-pillalamarri/terraform-roboshop-component) module.

This shows the progression from implementing one deployment explicitly to extracting the repeated infrastructure into a reusable pattern.

## Reusable Terraform Modules

Common infrastructure is maintained separately instead of being duplicated inside this repository.

- [`terraform-aws-vpc`](https://github.com/sai-pillalamarri/terraform-aws-vpc) — VPC and subnet infrastructure
- [`terraform-aws-sg`](https://github.com/sai-pillalamarri/terraform-aws-sg) — reusable security-group configuration
- [`terraform-roboshop-component`](https://github.com/sai-pillalamarri/terraform-roboshop-component) — reusable application component deployment

The infrastructure roots in this repository compose those modules with environment-specific configuration.

## AWS Services

The environment uses AWS services including:

- Amazon VPC
- Amazon EC2
- Amazon EC2 Auto Scaling
- Application Load Balancer
- Amazon Route 53
- AWS Certificate Manager
- AWS Systems Manager Parameter Store
- AWS Identity and Access Management
- Amazon S3 for Terraform remote state

## Environment-Specific Configuration

Some values in this repository are specific to the environment in which it was originally built.

Review them before deploying the infrastructure into another AWS account.

### Terraform state bucket

The Terraform roots currently reference:

```text
remote-state-90s-dev
```

as the S3 backend bucket.

S3 bucket names are globally unique, so another deployment needs its own remote-state bucket.

A typical backend configuration looks like:

```hcl
backend "s3" {
  bucket       = "your-terraform-state-bucket"
  key          = "roboshop-vpc.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
```

Keep a unique state key for each Terraform root.

### Domain and Route 53 hosted zone

The current environment uses:

```text
daws90s.shop
```

for DNS and ACM certificate validation.

When using another domain, update the relevant:

```text
domain_name
zone_id
```

values and any remaining environment-specific domain references.

For example:

```text
roboshop-dev.daws90s.shop
```

would become:

```text
roboshop-dev.example.com
```

## Running a Terraform Layer

Each directory is operated independently.

For example:

```bash
cd 00-vpc

terraform init
terraform plan
terraform apply
```

`terraform init` configures the backend and downloads providers.

`terraform plan` shows the changes Terraform intends to make.

`terraform apply` creates or updates the resources represented by that root.

Continue through the remaining directories in dependency order.

To remove the environment, destroy the layers in reverse order.

## Prerequisites

Before running the infrastructure, you need:

- Terraform 1.10 or later
- AWS credentials with permissions for the resources being created
- An S3 bucket for Terraform remote state
- A registered domain and Route 53 hosted zone if deploying the DNS and ACM layers

The reusable Terraform modules used by this project are available in my GitHub repositories:

- [`terraform-aws-vpc`](https://github.com/sai-pillalamarri/terraform-aws-vpc)
- [`terraform-aws-sg`](https://github.com/sai-pillalamarri/terraform-aws-sg)
- [`terraform-roboshop-component`](https://github.com/sai-pillalamarri/terraform-roboshop-component)

## Repository Conventions

Most Terraform roots follow the same file structure:

```text
provider.tf
variables.tf
data.tf
locals.tf
main.tf
parameters.tf
outputs.tf
```

Their responsibilities are:

| File | Purpose |
| --- | --- |
| `provider.tf` | Terraform provider and remote-state backend configuration |
| `variables.tf` | Environment and module inputs |
| `data.tf` | Reads existing AWS resources and SSM parameters |
| `locals.tf` | Shared names, tags, and derived values |
| `main.tf` | Resources managed by the Terraform root |
| `parameters.tf` | Publishes resource identifiers to SSM for later layers |
| `outputs.tf` | Values exposed after Terraform operations |

Keeping a similar structure across the roots makes it easier to move between infrastructure layers and understand where a particular value or resource is managed.

## RoboShop Automation Journey

This repository is one part of my RoboShop DevOps work.

The same application was used to practise different stages of infrastructure and deployment automation:

1. [`shell-roboshop`](https://github.com/sai-pillalamarri/shell-roboshop) — provisioning and configuration with shell scripts
2. [`roboshop-ansible-v3`](https://github.com/sai-pillalamarri/roboshop-ansible-v3) — configuration management with reusable Ansible roles
3. [`roboshop-docker`](https://github.com/sai-pillalamarri/roboshop-docker) — containerised services and Docker Compose
4. **roboshop-dev-infra** — AWS infrastructure managed with Terraform

This progression helped move the same application from host-level automation toward reusable Infrastructure as Code and cloud deployment patterns.
