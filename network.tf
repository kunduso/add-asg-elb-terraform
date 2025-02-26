#https://registry.terraform.io/modules/kunduso/vpc/aws/1.0.3
module "vpc" {
  source                  = "kunduso/vpc/aws"
  version                 = "1.0.3"
  region                  = var.region
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_flow_log         = true
  enable_internet_gateway = true
  enable_nat_gateway      = true
  vpc_name                = var.name
  vpc_cidr                = var.vpc_cidr
  subnet_cidr_public      = var.subnet_cidr_public
  subnet_cidr_private     = var.subnet_cidr_private
}