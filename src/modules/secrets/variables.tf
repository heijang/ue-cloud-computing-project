variable "env_name" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "db_username" {
  description = "Master username for the Aurora cluster."
  type        = string
  default     = "admin"
}

variable "db_name" {
  description = "Name of the default database to create."
  type        = string
  default     = "studentrecords"
}
