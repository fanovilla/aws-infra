data "aws_ami" "win2019" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "ad" {
  ami           = data.aws_ami.win2019.id
  instance_type = "t3.medium"

  tags = {
    Name = "ActiveDirectoryServer"
  }
}