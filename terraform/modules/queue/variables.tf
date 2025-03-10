variable "environment" {
  description = "Environment name (e.g., local, dev)"
  type        = string
  
  validation {
    condition     = contains(["local", "dev", "staging", "prod"], var.environment)
    error_message = "Valid values for var: test_variable are (\"local\", \"dev\", \"staging\", \"prod\")."
  } 
}