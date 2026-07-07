terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.48.0"
    }
  }
  backend "s3" {
    bucket       = "aslearnings-remote-state-dev"
    key          = "roboshop-frontend-alb.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = "us-east-1"

}
