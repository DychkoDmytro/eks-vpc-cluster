terraform {
  backend "s3" {
    bucket = "mlops-tfstate-goit-905444005934"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}
