terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.16"
    }
  }
}

resource "azurecaf_name" "app_service_plan" {
  name          = var.application_name
  resource_type = "azurerm_app_service_plan"
  suffixes      = [var.environment]
}

# This creates the plan that the service use
resource "azurerm_service_plan" "application" {
  name                = azurecaf_name.app_service_plan.result
  resource_group_name = var.resource_group
  location            = var.location

  sku_name = "B1"
  os_type  = "Linux"

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurecaf_name" "app_service_identity" {
  name          = var.application_name
  resource_type = "azurerm_user_assigned_identity"
  suffixes      = [var.environment]
}

resource "azurerm_user_assigned_identity" "app_user_assigned_identity" {
  count               = var.identity_type == "UserAssigned" ? 1 : 0
  resource_group_name = var.resource_group
  location            = var.location
  name                = azurecaf_name.app_service_identity.result
}


locals {
  database_connection_url = var.identity_type == "UserAssigned" ? "${var.database_url}&clientid=${azurerm_user_assigned_identity.app_user_assigned_identity.0.client_id}" : var.database_url
}

resource "azurecaf_name" "app_service" {
  name          = var.application_name
  resource_type = "azurerm_app_service"
  suffixes      = [var.environment]
}

# This creates the service definition
resource "azurerm_linux_web_app" "application" {
  name                = azurecaf_name.app_service.result
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.application.id
  https_only          = true

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }

  identity {
    type         = var.identity_type
    identity_ids = azurerm_user_assigned_identity.app_user_assigned_identity.*.id
  }

  site_config {
    application_stack {
      java_server         = "JAVA"
      java_server_version = "11"
      java_version        = "java11"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"

    # These are app specific environment variables
    "DATABASE_CONNECTION_URL" = local.database_connection_url
  }
}

# important: mysql aad authentication expect the application_id, not the object id. that is the reason to look for the application_id in aad
data "azuread_service_principal" "aad_appid" {
  count = var.identity_type == "SystemAssigned" ? 1 : 0
  object_id = azurerm_linux_web_app.application.identity[0].principal_id
}
