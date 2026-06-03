variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for EC2 instances."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID of the ALB (for web SG ingress rule)."
  type        = string
}

variable "env_name" {
  description = "Environment name used in resource naming and tags."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "az_count" {
  description = "Number of instances to launch (one per AZ)."
  type        = number
  default     = 2
}

variable "instance_profile_name" {
  description = "IAM Instance Profile name for EC2 (e.g. LabInstanceProfile). Leave null to skip."
  type        = string
  default     = null
}
