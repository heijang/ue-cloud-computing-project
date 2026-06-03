###############################################################################
# Network
###############################################################################

module "network" {
  source   = "./modules/network"
  vpc_cidr = var.vpc_cidr
  env_name = var.env_name
  az_count = var.az_count
}

# Modules will be added in the order they appear in docs/iac:
# - 03-database.md     → module "secrets", module "database"
# - 04-compute-alb.md  → module "loadbalancer", module "compute"
