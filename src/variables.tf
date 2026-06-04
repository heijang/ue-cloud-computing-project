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
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the web tier."
  type        = string
  default     = "t3.micro"
}

variable "instance_profile_name" {
  description = "Existing IAM instance profile to attach. Set to \"LabInstanceProfile\" for AWS Academy. Leave null on a personal account to have Terraform create a role + profile (SSM + secret read)."
  type        = string
  default     = null
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

variable "asg_min" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_max" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 4
}

variable "asg_desired" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "Instance class for the RDS MySQL instance."
  type        = string
  default     = "db.t3.micro"
}

variable "enable_ssh" {
  description = "Generate an SSH key pair, write the .pem locally, and open port 22 on the web tier for inspection."
  type        = bool
  default     = false
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH into the web tier when enable_ssh is true. Restrict to your IP/32 in real use."
  type        = string
  default     = "0.0.0.0/0"
}
