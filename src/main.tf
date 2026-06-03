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

###############################################################################
# Secrets Manager (DB credentials — before database so password is ready)
###############################################################################

module "secrets" {
  source   = "./modules/secrets"
  env_name = var.env_name
}

###############################################################################
# Database (Aurora MySQL)
###############################################################################

module "database" {
  source             = "./modules/database"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_db_subnet_ids
  web_sg_id          = module.compute.web_sg_id
  env_name           = var.env_name
  db_username        = module.secrets.db_username
  db_password        = module.secrets.db_password
  db_name            = module.secrets.db_name
  secret_id          = module.secrets.secret_id
  db_instance_class  = var.db_instance_class
}
