provider "helm" {
  kubernetes {
    config_context = var.cluster_context
  }
}

terraform {
  backend "s3" {
    bucket = "banthaherder.terraform"
    key    = "terraform/sandcastles/cluster-app-services.tfstate"
    region = "us-west-2"
  }
}