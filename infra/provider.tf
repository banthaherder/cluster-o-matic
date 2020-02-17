provider "aws" {
  region  = var.region
  version = "~> 2.29"
}

terraform {
  backend "s3" {
    bucket = "banthaherder.terraform"
    key    = "terraform/sandcastles/testops.tfstate"
    region = "us-west-2"
  }
}