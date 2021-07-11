locals {
  subnet_group = var.subnet_group
  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids
  ruleset      = var.ruleset
  ruleset_refs = var.ruleset_refs

  # outbound rules for subnet groups in source column in ruleset
  source_outbound_rules = flatten([
    for rule_index, rule in var.ruleset : [
      for cidr_index, cidr in lookup(local.ruleset_refs, rule.target) : {
        id           = "${rule.source}-${rule.target}-${rule.port}-${cidr}"
        rulenum      = 1000 + (rule_index * 10) + (cidr_index * 1)
        subnet_group = local.subnet_group
        cidr         = cidr
        from_port    = rule.port
        to_port      = rule.port
      }
    ] if rule.source == local.subnet_group
  ])

  # inbound rules for subnet groups in source column in ruleset
  source_inbound_rules = flatten([
    for rule_index, rule in var.ruleset : [
      for cidr_index, cidr in lookup(local.ruleset_refs, rule.target) : {
        id           = "${rule.source}-${rule.target}-${rule.port}-${cidr}"
        rulenum      = 2000 + (rule_index * 10) + (cidr_index * 1)
        subnet_group = local.subnet_group
        cidr         = cidr
        from_port    = 1024
        to_port      = 65535
      }
    ] if rule.source == local.subnet_group
  ])

  # inbound rules for subnet groups in target column in ruleset
  target_inbound_rules = flatten([
    for rule_index, rule in var.ruleset : [
      for cidr_index, cidr in lookup(local.ruleset_refs, rule.source) : {
        id           = "${rule.source}-${rule.target}-${rule.port}-${cidr}"
        rulenum      = 3000 + (rule_index * 10) + (cidr_index * 1)
        subnet_group = local.subnet_group
        cidr         = cidr
        from_port    = rule.port
        to_port      = rule.port
      }
    ] if rule.target == local.subnet_group
  ])

  # outbound rules for subnet groups in target column in ruleset
  target_outbound_rules = flatten([
    for rule_index, rule in var.ruleset : [
      for cidr_index, cidr in lookup(local.ruleset_refs, rule.source) : {
        id           = "${rule.source}-${rule.target}-${rule.port}-${cidr}"
        rulenum      = 4000 + (rule_index * 10) + (cidr_index * 1)
        subnet_group = local.subnet_group
        cidr         = cidr
        from_port    = 1024
        to_port      = 65535
      }
    ] if rule.target == local.subnet_group
  ])

  outbound_rules = { for rule in concat(local.source_outbound_rules, local.target_outbound_rules) : rule.id => rule }
  inbound_rules  = { for rule in concat(local.source_inbound_rules, local.target_inbound_rules) : rule.id => rule }
}

resource "aws_network_acl" "this" {
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  tags = {
    Name = local.subnet_group
  }
}

resource "aws_network_acl_rule" "outbound" {
  for_each = local.outbound_rules

  network_acl_id = aws_network_acl.this.id
  rule_number    = each.value.rulenum
  egress         = true
  protocol       = each.value.from_port == 0 ? "all" : "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "inbound" {
  for_each = local.inbound_rules

  network_acl_id = aws_network_acl.this.id
  rule_number    = each.value.rulenum
  egress         = false
  protocol       = each.value.from_port == 0 ? "all" : "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}
