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

output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora MySQL cluster."
  value       = module.database.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint of the Aurora MySQL cluster."
  value       = module.database.reader_endpoint
}
