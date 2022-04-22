variable "resource_group" {
  type        = string
  description = "The resource group"
}

variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
}

variable "database_url" {
  type        = string
  description = "The URL to the database"
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
