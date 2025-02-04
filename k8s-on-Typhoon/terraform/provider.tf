

provider "aws" {
  region = "eu-west-2"
}

provider "ct" {}

terraform {
  backend "s3" {
    key     = "typhoon/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
  }
}
