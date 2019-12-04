variable "environment_tag" {}
variable "subnet_public" {}
variable "subnet_public_az" {}
variable "main_vpc" {}
variable "web_server_instance" {}

resource "aws_security_group" "sg_80" {
  name   = "sg_80"
  vpc_id = var.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "web_server_lb" {
  name               = "web-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_80.id]
  subnets            = [var.subnet_public.id, var.subnet_public_az.id]

  enable_deletion_protection = false

  access_logs {
    enabled = false
    bucket  = "web_server_lb_logs"
  }

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_lb_target_group" "web_server_lb_group" {
  name        = "web-server-lb-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = var.main_vpc.id
}

resource "aws_lb_target_group_attachment" "web_server_lb_group_attch" {
  target_group_arn = aws_lb_target_group.web_server_lb_group.arn
  target_id        = var.web_server_instance.id
  port             = 8080
}

resource "aws_lb_listener" "web_server_lb_listener" {
  load_balancer_arn = aws_lb.web_server_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_lb_group.arn
  }
}
