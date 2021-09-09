variable "subnet_group" {
  description = "Name for the subnet group to process"
  type        = string
}

variable "vpc_id" {
  description = "VPC where to create the NACL"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets attached to the NACL"
  type        = list(string)
}

variable "ruleset" {
  description = "List of rules that are outbound from subnet groups"
  type = list(object({
    source = string
    target = string
    port   = number
  }))
}

variable "ruleset_refs" {
  description = "Map where a key is a reference in the ruleset and the value is the list of CIDRs for the reference"
  type        = map(list(string))
}
