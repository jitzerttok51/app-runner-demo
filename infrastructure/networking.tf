resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "Project Network"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    "Name" = "Private Subnet"
  }
}

data "aws_region" "current" {}

resource "aws_subnet" "private-az2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${data.aws_region.current.name}b"
  tags = {
    "Name" = "Private Subnet AZ 2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    "Name" = "Public Subnet route table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "Private Subnet route table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_main_route_table_association" "main_route_table" {
  route_table_id = aws_route_table.private.id
  vpc_id         = aws_vpc.main.id
}

resource "aws_security_group" "ssh_group" {
  vpc_id = aws_vpc.main.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "ALL"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  tags = {
    Name = "Test VMs Security Group"
  }
}

resource "aws_security_group" "endpoint_group" {
  vpc_id = aws_vpc.main.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    self        = true
    protocol    = "ALL"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    self        = true
    protocol    = "ALL"
  }

  tags = {
    Name = "Endpoints Security Group"
  }
}