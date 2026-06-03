output "cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "db_sg_id" {
  description = "Security group ID of the Aurora cluster."
  value       = aws_security_group.db.id
}
