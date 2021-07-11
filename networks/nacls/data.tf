# data structures for app vpc
data "aws_vpc" "app" {
  tags = {
    Name = "app"
  }
}

data "aws_subnet_ids" "app" {
  vpc_id = data.aws_vpc.app.id
}

data "aws_subnet" "app" {
  for_each = data.aws_subnet_ids.app.ids
  id       = each.value
}

# data structures for mgmt vpc
data "aws_vpc" "mgmt" {
  tags = {
    Name = "mgmt"
  }
}

data "aws_subnet_ids" "mgmt" {
  vpc_id = data.aws_vpc.mgmt.id
}

data "aws_subnet" "mgmt" {
  for_each = data.aws_subnet_ids.mgmt.ids
  id       = each.value
}

