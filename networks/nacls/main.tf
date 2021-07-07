terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.34.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

locals {
  rulesets_refs = {
    x_universe    = ["0.0.0.0/0"]
    x_aws_s3      = ["3.5.164.0/22", "3.5.168.0/23", "52.95.128.0/21"]
    x_onprem_ldap = ["54.192.220.70/32"]
  }

  rulesets = csvdecode(file("${path.module}/rulesets.csv"))
}

module "main_nacl" {
  source = "../modules/nacl"

  vpc_name      = "app"
  rulesets      = local.rulesets
  rulesets_refs = local.rulesets_refs

}
