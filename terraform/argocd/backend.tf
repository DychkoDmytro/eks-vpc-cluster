terraform {
  backend "s3" {
    bucket = "mlops-tfstate-goit-905444005934"
    key    = "argocd/terraform.tfstate"
    region = "eu-central-1"
  }
}
