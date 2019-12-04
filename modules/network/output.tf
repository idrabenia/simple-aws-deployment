
output "target_vpc" {
  value = aws_vpc.test_main
}

output "subnet_public" {
  value = aws_subnet.subnet_public
}

output "subnet_public_az" {
  value = aws_subnet.subnet_public_az
}

output "subnet_private" {
  value = aws_subnet.subnet_private
}

output "subnet_private_isolated" {
  value = aws_subnet.subnet_private_isolated
}