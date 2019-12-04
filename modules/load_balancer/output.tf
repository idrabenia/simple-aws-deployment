
output "lb_url" {
  value = aws_lb.web_server_lb.dns_name
}
