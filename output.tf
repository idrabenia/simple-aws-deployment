output "bastion_ip" {
  value = module.instances.bastion.public_ip
}

output "web_ip" {
  value = module.instances.web_server.private_ip
}

output "lb_dns" {
  value = module.load_balancer.lb_url
}

output "domain_name" {
  value = var.domain_name
}
