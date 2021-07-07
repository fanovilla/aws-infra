//output "subnet_cidr_blocks" {
//  value = [for s in data.aws_subnet.example : s.cidr_block]
//}

output "aws_subnets" {
  value = local.aws_subnets
}

output "subnet_group_map" {
  value = local.source_egress_rules
}