data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "mlops-tfstate-goit-905444005934"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}
