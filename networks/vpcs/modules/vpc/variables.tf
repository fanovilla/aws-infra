variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "secondary_cidrs" {
  description = "List of secondary CIDR blocks to associate with the VPC"
  type        = list(string)
  default     = []
}

variable "az_ids" {
  description = "List of availability zone ids to distribute subnets across"
  type        = list(string)
  default     = []
}

variable "subnet_groups" {
  description = "List of subnets to create in the VPC"
  type = map(object({
    cidrs = list(string)

  }))
}
