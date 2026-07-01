terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.48.0"
    }
  }
  backend "s3" {

    bucket       = "aslearnings-remote-state-dev"
    key          = "roboshop-sg.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

  }
}

provider "aws" {
  region = "us-east-1"
}
