variable "environment_tag" {}
variable "subnet_public" {}
variable "subnet_public_az" {}
variable "main_vpc" {}
variable "web_server_instance" {}
variable "domain_name" {}
variable "route53_id" {}

resource "aws_security_group" "sg_443" {
  name   = "sg_80"
  vpc_id = var.main_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_acm_certificate" "web_server_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.web_server_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.web_server_cert.domain_validation_options.0.resource_record_type
  zone_id = var.route53_id
  records = [aws_acm_certificate.web_server_cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.web_server_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_lb" "web_server_lb" {
  name               = "web-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_443.id]
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
  certificate_arn   = aws_acm_certificate.web_server_cert.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_lb_group.arn
  }
}

resource "aws_lb_listener_certificate" "web_server_lb_listener_cert" {
  listener_arn    = aws_lb_listener.web_server_lb_listener.arn
  certificate_arn = aws_acm_certificate.web_server_cert.arn
}

resource "aws_route53_record" "web_record" {
  zone_id = var.route53_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.web_server_lb.dns_name
    zone_id                = aws_lb.web_server_lb.zone_id
    evaluate_target_health = "true"
  }
}
