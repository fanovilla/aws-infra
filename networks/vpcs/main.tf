locals {
  # carving out /22 CIDR blocks below; customise as per need
  app_vpc_cidr         = "10.0.0.0/16"
  app_vpc_subnet_cidrs = cidrsubnets(local.app_vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6)

  mgmt_vpc_cidr         = "10.8.0.0/16"
  mgmt_vpc_subnet_cidrs = cidrsubnets(local.mgmt_vpc_cidr, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6)

  az_ids = ["apse2-az1", "apse2-az2", "apse2-az3"] # should be in provider region
}

# create app vpc and subnets
module "app_vpc" {
  source = "./modules/vpc"

  vpc_name        = "app"
  cidr            = local.app_vpc_cidr
  secondary_cidrs = ["10.1.0.0/16", "10.2.0.0/16"]
  az_ids          = local.az_ids

  subnet_groups = {
    public = {
      cidrs = slice(local.app_vpc_subnet_cidrs, 0, 3) # first 3 blocks
    }
    private = {
      cidrs = slice(local.app_vpc_subnet_cidrs, 3, 6) # next 3 blocks
    }
    persistence = {
      cidrs = slice(local.app_vpc_subnet_cidrs, 6, 9) # next 3 blocks
    }
  }
}

# create mgmt vpc and subnets
module "mgmt_vpc" {
  source = "./modules/vpc"

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
