variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for ASG instances."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID of the ALB (for web SG ingress rule)."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to attach the ASG to."
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

variable "instance_profile_name" {
  description = "Existing IAM instance profile to attach (e.g. LabInstanceProfile in AWS Academy). Leave null to have Terraform create a role + profile (personal accounts)."
  type        = string
  default     = null
}

variable "secret_arn" {
  description = "ARN of the DB credentials secret. Used to scope the generated instance role's read policy (personal-account path)."
  type        = string
}

variable "db_secret_version_id" {
  description = "ID of the DB secret version containing the real RDS endpoint. Gates instance launch so the app reads a populated secret (avoids host=\"\" race)."
  type        = string
  default     = ""
}

variable "db_init_sql" {
  description = "Contents of the DB init SQL script, written to /home/ubuntu/init-db.sql on each instance. Empty string skips it."
  type        = string
  default     = ""
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret containing DB credentials."
  type        = string
}

variable "aws_region" {
  description = "AWS Region (used by userdata to fetch secrets)."
  type        = string
}

variable "asg_min" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 2
}

variable "asg_max" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 4
}

variable "asg_desired" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 2
}

variable "enable_ssh" {
  description = "When true, generate an SSH key pair, upload it, and open port 22 on the web SG for inspection/debugging."
  type        = bool
  default     = false
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach the web tier on port 22 when enable_ssh is true. Restrict to your IP/32 in real use."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_key_output_path" {
  description = "Local path where the generated private key (.pem) is written when enable_ssh is true. Defaults to <env>-web-key.pem in the root module."
  type        = string
  default     = null
}
