variable "aws_region" {
  description = "AWS Region for all resources (lab requires single Region)."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name. Use 'personal' for personal account, 'academy' for AWS Academy Lab."
  type        = string
  default     = null
}

variable "env_name" {
  description = "Environment name used in tags and resource names."
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to span. Spec requires >= 2."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "Spec requires private subnets in at least two AZs."
  }
}
