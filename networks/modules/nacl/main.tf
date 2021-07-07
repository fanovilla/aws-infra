data "aws_vpc" "this" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "this" {
  vpc_id = data.aws_vpc.this.id
}

data "aws_subnet" "this" {
  for_each = data.aws_subnet_ids.this.ids
  id       = each.value
}

locals {
  aws_subnets = data.aws_subnet.this

  subnet_group_to_ids_map = {
    for s in data.aws_subnet.this : s.tags.SubnetGroup => s.id...
  }

  subnet_group_to_cidrs_map = {
    for s in data.aws_subnet.this : s.tags.SubnetGroup => s.cidr_block...
  }

  ruleset_refs_lookup = merge(local.subnet_group_to_cidrs_map, var.rulesets_refs)

  source_egress_rules = flatten([
    for subnet_group in keys(local.subnet_group_to_ids_map) : [
      for rule in var.rulesets : [
        for index, cidr in lookup(local.ruleset_refs_lookup, rule.target) : {
          id           = "${rule.source}-${rule.basenum}-${cidr}"
          rulenum      = rule.basenum + (index * 10)
          subnet_group = subnet_group
          cidr         = cidr
          port         = rule.port
        }
      ] if rule.source == subnet_group
    ]
  ])

  source_ingress_rules = flatten([
    for subnet_group in keys(local.subnet_group_to_ids_map) : [
      for rule in var.rulesets : [
        for index, cidr in lookup(local.ruleset_refs_lookup, rule.target) : {
          id           = "${rule.source}-${rule.basenum}-${cidr}"
          rulenum      = rule.basenum + (index * 10)
          subnet_group = subnet_group
          cidr         = cidr
          port         = rule.port
        }
      ] if rule.source == subnet_group
    ]
  ])

}

resource "aws_network_acl" "this" {
  for_each   = local.subnet_group_to_ids_map
  vpc_id     = data.aws_vpc.this.id
  subnet_ids = toset(each.value)

  tags = {
    Name = each.key
  }
}

resource "aws_network_acl_rule" "source_egress" {
  for_each = {
    for rule in local.source_egress_rules : rule.id => rule
  }

  network_acl_id = aws_network_acl.this[each.value.subnet_group].id
  rule_number    = each.value.rulenum
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = each.value.port
  to_port        = each.value.port
}

resource "aws_network_acl_rule" "source_ingress" {
  for_each = {
    for rule in local.source_ingress_rules : rule.id => rule
  }

  network_acl_id = aws_network_acl.this[each.value.subnet_group].id
  rule_number    = each.value.rulenum
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = 1024
  to_port        = 65535
}