variable "application_name" {
  type        = string
  description = "The name of your application"
  # default     = "msi-jdbc"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "eastus"
}

variable "database_type" {
  type        = string
  description = "Database type (postgresql, mysql)"
  validation {
    condition     = var.database_type == "postgresql" || var.database_type == "mysql"
    error_message = "Database must be either postgresql or mysql."
  }
}

variable "aad_administrator_name" {
  type        = string
  description = "The Azure Active Directory administrator name"
  default = "" 
}
