terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.34.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}

locals {
  # carving out /22 CIDR blocks below; customise as per need
  main_vpc_cidr         = "10.0.0.0/16"
  main_vpc_subnet_cidrs = cidrsubnets(local.main_vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6)

  mgmt_vpc_cidr         = "10.8.0.0/16"
  mgmt_vpc_subnet_cidrs = cidrsubnets(local.mgmt_vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6)

  az_ids = ["apse2-az1", "apse2-az2", "apse2-az3"] # should be in provider region
}


module "app_vpc" {
  source = "../modules/vpc"

  vpc_name        = "app"
  cidr            = local.main_vpc_cidr
  secondary_cidrs = ["10.1.0.0/16", "10.2.0.0/16"]
  az_ids          = local.az_ids

  subnet_groups = {
    public = {
      cidrs = slice(local.main_vpc_subnet_cidrs, 0, 3) # first 3 blocks
    }
    private = {
      cidrs = slice(local.main_vpc_subnet_cidrs, 3, 6) # next 3 blocks
    }
    persistence = {
      cidrs = slice(local.main_vpc_subnet_cidrs, 6, 9) # next 3 blocks
    }
  }

}

module "mgmt_vpc" {
  source = "../modules/vpc"

  vpc_name = "mgmt"
  cidr     = local.mgmt_vpc_cidr
  az_ids   = local.az_ids

  subnet_groups = {
    public = {
      cidrs = slice(local.mgmt_vpc_subnet_cidrs, 0, 3) # first 3 blocks
    }
    private = {
      cidrs = slice(local.mgmt_vpc_subnet_cidrs, 3, 6) # next 3 blocks
    }
    persistence = {
      cidrs = slice(local.mgmt_vpc_subnet_cidrs, 6, 9) # next 3 blocks
    }
  }

}
