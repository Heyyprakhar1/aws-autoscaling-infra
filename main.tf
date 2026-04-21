module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
}

module "security_groups" {
  source = "./modules/security_groups"
    
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment   = var.environment
}