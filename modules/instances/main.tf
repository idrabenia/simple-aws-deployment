variable "target_vpc" {}
variable "environment_tag" {}
variable "key_name" {}
variable "subnet_public" {}
variable "subnet_private" {}

resource "aws_security_group" "sg_22" {
  name   = "sg_22"
  vpc_id = var.target_vpc.id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_security_group" "sg_8080" {
  name   = "sg_8080"
  vpc_id = var.target_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_instance" "bastion" {
  ami                    = "ami-04763b3055de4860b"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_public.id
  vpc_security_group_ids = aws_security_group.sg_22.*.id

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-04763b3055de4860b"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_private.id
  vpc_security_group_ids = [aws_security_group.sg_8080.id, aws_security_group.sg_22.id]

  tags = {
    Environment = var.environment_tag
  }
}
