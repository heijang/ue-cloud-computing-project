variable "env_name" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager secret name. MUST match the name hard-coded in the provided app (app/config/config.js → \"Mydbsecret\")."
  type        = string
  default     = "Mydbsecret"
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "nodeapp"
}

variable "db_name" {
  description = "Name of the default database to create."
  type        = string
  default     = "STUDENTS"
}
