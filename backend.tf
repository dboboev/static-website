terraform {
  backend "s3" {
    bucket  = "devops-bootcamp-terraform-states"
    key     = ""
    region  = "us-east-1"
    encrypt = true
  }
}