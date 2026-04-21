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

module "alb" {
  source = "./modules/alb"

  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id        = module.security_groups.alb_sg_id
  project_name     = var.project_name
  environment      = var.environment
}

module "asg" {
  source = "./modules/asg"

  name_prefix = var.project_name
  image_id    = var.image_id
  instance_type = var.instance_type
  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size
  target_group_arn = module.alb.target_group_arn
  scaling_adjustment = var.scaling_adjustment
  private_subnet_ids = module.vpc.private_subnet_ids
  key_name = var.key_name
  ec2_sg_id = module.security_groups.ec2_sg_id
}