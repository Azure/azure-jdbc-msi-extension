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

variable "hosting_type" {
  type        = string
  description = "Hosting type (appservice, spring)"
  default     = "appservice"
  validation {
    condition     = var.hosting_type == "appservice" || var.hosting_type == "spring"
    error_message = "Hosting type must be either appservice or spring."
  }
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
  default     = ""
}

variable "identity_type" {
  type        = string
  description = "value of either 'SystemAssigned' or 'UserAssigned' to set the identity of the resource"
  default     = "SystemAssigned"
  validation {
    condition     = var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned"
    error_message = "The identity_type must be either SystemAssigned or UserAssigned."
  }
}
