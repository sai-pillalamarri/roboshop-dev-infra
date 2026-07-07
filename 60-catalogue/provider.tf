terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.48.0"
    }
  }
  backend "s3" {
    bucket       = "aslearnings-remote-state-dev"
    key          = "roboshop-catalogue.tfstate"
    use_lockfile = true
    encrypt      = true
    region       = "us-east-1"

  }
}

provider "aws" {
  region = "us-east-1"

}
