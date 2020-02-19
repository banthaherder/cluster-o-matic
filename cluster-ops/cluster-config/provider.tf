provider "kubernetes" {
  config_context_cluster = var.cluster_context
}

terraform {
  backend "s3" {
    bucket = "banthaherder.terraform"
    key    = "terraform/sandcastles/cluster-config.tfstate"
    region = "us-west-2"
  }
}