module "vpc" {
  source                  = "git::https://github.com/sai-pillalamarri/terraform-aws-vpc.git?ref=main"
  project                 = var.project
  environment             = var.environment
  is_vpc_peering_required = false
}
