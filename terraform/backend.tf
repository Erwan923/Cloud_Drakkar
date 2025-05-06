terraform {
  backend "s3" {
    bucket         = "terraform-state-cloud-drakkar"  # nom du bucket S3
    key            = "eks/terraform.tfstate"         # chemin dans le bucket
    region         = "eu-west-3"                     # ta région
    dynamodb_table = "terraform-locks"               # nom de la table DynamoDB
    encrypt        = true
  }
}
