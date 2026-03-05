provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "Application" = "plausible"
    }
  }
}

# Configure your own backend:
# backend "s3" {
#   encrypt        = true
#   bucket         = "your-terraform-state-bucket"
#   region         = "eu-west-1"
#   dynamodb_table = "your-terraform-lock-table"
#   key            = "plausible.tfstate"
# }

data "aws_caller_identity" "current" {}
