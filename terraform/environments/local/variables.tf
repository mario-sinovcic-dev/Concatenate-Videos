# No sensitive variables needed for local development
# Using hardcoded values for LocalStack

variable "db_username" {
  description = "Database username for local development"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password for local development"
  type        = string
  default     = "postgres"
} 