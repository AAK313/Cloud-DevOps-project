terraform {
  backend "s3" {
    bucket         = "stoargebucket1"
    key            = "cloud-devops-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloudTable"
  }
}


