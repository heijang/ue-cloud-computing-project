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
# Load Balancer (ALB + SG — created before compute so TG ARN is available)
###############################################################################

module "loadbalancer" {
  source     = "./modules/loadbalancer"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnet_ids
  env_name   = var.env_name
}

###############################################################################
# Compute (ASG web tier — attaches to ALB target group)
###############################################################################

module "compute" {
  source                = "./modules/compute"
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.public_subnet_ids
  alb_sg_id             = module.loadbalancer.alb_sg_id
  target_group_arn      = module.loadbalancer.target_group_arn
  env_name              = var.env_name
  instance_type         = var.instance_type
  instance_profile_name = var.instance_profile_name
  secret_arn            = module.secrets.secret_arn
  secret_name           = module.secrets.secret_name
  db_init_sql           = file("${path.module}/scripts/init-db.sql")
  aws_region            = var.aws_region
  asg_min               = var.asg_min
  asg_max               = var.asg_max
  asg_desired           = var.asg_desired
  enable_ssh            = var.enable_ssh
  ssh_ingress_cidr      = var.ssh_ingress_cidr
}

###############################################################################
# Secrets Manager (DB credentials — before database so password is ready)
###############################################################################

module "secrets" {
  source   = "./modules/secrets"
  env_name = var.env_name
}

###############################################################################
# Database (RDS MySQL)
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
