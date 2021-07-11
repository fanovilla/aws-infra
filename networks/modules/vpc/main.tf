# create the VPC
resource "aws_vpc" "this" {
  cidr_block = var.cidr

  tags = {
    Name = var.vpc_name
  }
}

# associate secondary CIDRs, if any
resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each   = toset(var.secondary_cidrs)
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
}

locals {
  # https://www.terraform.io/docs/language/functions/flatten.html
  subnets = flatten([
    for subnet_group_key, subnet_group in var.subnet_groups : [
      for index, cidr in subnet_group.cidrs : {
        subnet_group_key = subnet_group_key
        index            = index
        cidr             = cidr
      }
    ]
  ])
}

# create the subnets, setting the SubnetGroup tag
resource "aws_subnet" "this" {
  for_each = {
    for subnet in local.subnets : "${var.vpc_name}_${subnet.subnet_group_key}_${subnet.index}" => subnet
  }
  vpc_id               = aws_vpc.this.id
  cidr_block           = each.value.cidr
  availability_zone_id = var.az_ids[each.value.index]

  tags = {
    Name        = each.key
    SubnetGroup = "${var.vpc_name}_${each.value.subnet_group_key}"
  }
}