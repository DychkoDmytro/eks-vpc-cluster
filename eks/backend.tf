terraform {
  backend "s3" {
    bucket = "mlops-tfstate-goit-905444005934"
    key    = "eks/terraform.tfstate"
    region = "eu-central-1"
  }
}
