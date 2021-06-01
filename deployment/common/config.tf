provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

data "aws_region" "current" {
  name = "ap-southeast-1"
}

data "aws_caller_identity" "current" {
  # no arguments
}

output "aws_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}
