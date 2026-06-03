variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "env_name" {
  description = "Environment name used in resource naming and tags."
  type        = string
}

variable "instance_ids" {
  description = "EC2 instance IDs to register with the target group."
  type        = list(string)
}
