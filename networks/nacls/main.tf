locals {
  # ruleset references that are not subnet groups
  extra_ruleset_refs = {
    _universe    = ["0.0.0.0/0"]
    _aws_s3      = ["3.5.164.0/22", "3.5.168.0/23", "52.95.128.0/21"]
    _onprem_ldap = ["54.192.220.70/32"]

    _vpc_app  = data.aws_vpc.app.cidr_block_associations[*].cidr_block
    _vpc_mgmt = data.aws_vpc.mgmt.cidr_block_associations[*].cidr_block
  }

  ruleset = csvdecode(file("${path.module}/subnet_group_ruleset.csv"))

  # merge subnet groups CIDRs from all VPCs plus the extra (non subnet group) references
  ruleset_refs = merge(
    local.extra_ruleset_refs,
    { for s in data.aws_subnet.app : s.tags.SubnetGroup => s.cidr_block... },  # subnet groups in app vpc
    { for s in data.aws_subnet.mgmt : s.tags.SubnetGroup => s.cidr_block... }, # subnet groups in mgmt vpc
  )

  # for looking up VPC id of a given subnet group
  subnet_group_to_vpc_map = merge(
    { for s in distinct([for s in data.aws_subnet.app : s.tags.SubnetGroup]) : s => data.aws_vpc.app.id },   // app vpc
    { for s in distinct([for s in data.aws_subnet.mgmt : s.tags.SubnetGroup]) : s => data.aws_vpc.mgmt.id }, // mgmt vpc
  )

  # for looking up subnet ids of a given subnet group
  subnet_group_to_ids_map = merge(
    { for s in data.aws_subnet.app : s.tags.SubnetGroup => s.id... },  // app vpc
    { for s in data.aws_subnet.mgmt : s.tags.SubnetGroup => s.id... }, // mgmt vpc
  )


  subnet_groups_to_process = [
    "app_private",
    "app_public",
    "app_persistence",
    "mgmt_private",
    "mgmt_public",
    "mgmt_persistence",
  ]
}

module "nacl" {
  for_each = toset(local.subnet_groups_to_process)
  source   = "./modules/nacl"

  subnet_group = each.value
  vpc_id       = lookup(local.subnet_group_to_vpc_map, each.value)
  subnet_ids   = lookup(local.subnet_group_to_ids_map, each.value)
  ruleset      = local.ruleset
  ruleset_refs = local.ruleset_refs
}
