output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.network.public_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = module.network.private_db_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the ALB (public entry point)."
  value       = module.loadbalancer.alb_dns_name
}

output "db_endpoint" {
  description = "Endpoint address of the RDS MySQL instance."
  value       = module.database.db_endpoint
}

output "ssh_key_name" {
  description = "Name of the generated EC2 key pair (null when SSH is disabled)."
  value       = module.compute.ssh_key_name
}

output "ssh_private_key_path" {
  description = "Local path to the generated private key .pem (null when SSH is disabled)."
  value       = module.compute.ssh_private_key_path
}
