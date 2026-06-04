variable "vpc_id" {
  description = "VPC ID where the RDS instance is deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security group ID of the web tier (allowed to connect on 3306)."
  type        = string
}

variable "env_name" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the default database."
  type        = string
}

variable "secret_id" {
  description = "Secrets Manager secret ID to update with the RDS endpoint."
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}
