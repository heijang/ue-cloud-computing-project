###############################################################################
# Network
###############################################################################

module "network" {
  source   = "./modules/network"
  vpc_cidr = var.vpc_cidr
  env_name = var.env_name
  az_count = var.az_count
}

###############################################################################
# Load Balancer (ALB + SG — created before compute so SG ID is available)
###############################################################################

module "loadbalancer" {
  source       = "./modules/loadbalancer"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnet_ids
  env_name     = var.env_name
  instance_ids = module.compute.instance_ids
}

###############################################################################
# Compute (EC2 web tier)
###############################################################################

module "compute" {
  source        = "./modules/compute"
  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.public_subnet_ids
  alb_sg_id     = module.loadbalancer.alb_sg_id
  env_name      = var.env_name
  instance_type          = var.instance_type
  az_count               = var.az_count
  instance_profile_name  = var.instance_profile_name
}

# Modules to be added in later phases:
# - 03-database.md → module "secrets", module "database"
