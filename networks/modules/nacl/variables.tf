variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "rulesets" {
  description = "List of rules that are outbound from subnet groups"
  type = list(object({
    basenum = string
    source  = string
    target  = string
    port    = string
  }))
}

variable "rulesets_refs" {
  description = "Map where a key is a reference in the ruleset and the value is the list of CIDRs for the reference"
  type        = map(list(string))
}
