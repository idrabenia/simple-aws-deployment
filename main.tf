
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.40"
}

variable "key_name" {}
variable "environment_tag" {}
variable "domain_name" {}
variable "route53_id" {}

module "network" {
  source          = "./modules/network"
  environment_tag = var.environment_tag
}

module "instances" {
  source          = "./modules/instances"
  environment_tag = var.environment_tag
  key_name        = var.key_name
  target_vpc      = module.network.target_vpc
  subnet_public   = module.network.subnet_public
  subnet_private  = module.network.subnet_private
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  environment_tag     = var.environment_tag
  subnet_public       = module.network.subnet_public
  subnet_public_az    = module.network.subnet_public_az
  main_vpc            = module.network.target_vpc
  web_server_instance = module.instances.web_server
  domain_name         = var.domain_name
  route53_id          = var.route53_id
}
