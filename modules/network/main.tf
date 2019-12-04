variable "environment_tag" {}

variable "cidr_subnet" {
  description = "CIDR block for the VPC"
  default     = "10.0.1.0/24"
}

variable "cidr_subnet_public_az" {
  description = "CIDR block for the VPC"
  default     = "10.0.4.0/24"
}

variable "cidr_subnet_private" {
  description = "CIDR block for the VPC"
  default     = "10.0.2.0/24"
}

variable "cidr_subnet_private_isolated" {
  description = "CIDR block for the VPC"
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Availability Zone to Create Subnet"
  default     = "us-east-1a"
}

variable "availability_zone_reserve" {
  description = "Availability Zone to Create Subnet"
  default     = "us-east-1b"
}

resource "aws_vpc" "test_main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "test-main"
    Environment = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_main.id

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.test_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.test_main.id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public_az" {
  vpc_id                  = aws_vpc.test_main.id
  cidr_block              = var.cidr_subnet_public_az
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_reserve

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_subnet" "subnet_private" {
  vpc_id            = aws_vpc.test_main.id
  cidr_block        = var.cidr_subnet_private
  availability_zone = var.availability_zone

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.test_main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_private_nat" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_subnet" "subnet_private_isolated" {
  vpc_id            = aws_vpc.test_main.id
  cidr_block        = var.cidr_subnet_private_isolated
  availability_zone = var.availability_zone

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_private_isolated" {
  subnet_id      = aws_subnet.subnet_private_isolated.id
  route_table_id = aws_route_table.rtb_public.id
}
