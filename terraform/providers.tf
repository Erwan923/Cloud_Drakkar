terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Le provider AWS : Terraform sait comment parler à AWS grâce à ce bloc.
  # La région où seront créées toutes les ressources.
  region = var.aws_region
}
