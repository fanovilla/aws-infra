output "aws_subnets" {
  value = module.main_nacl.aws_subnets
}

output "subnet_group_map" {
  value = module.main_nacl.subnet_group_map
}

output "rulesets" {
  value = local.rulesets
}