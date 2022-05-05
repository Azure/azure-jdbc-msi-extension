# Azure Spring Cloud is not yet supported in azurecaf_name
locals {
  spring_cloud_service_name = "asc-${var.application_name}-${var.environment}"
  spring_cloud_app_name     = "app-${var.application_name}"
}

# This creates the Azure Spring Cloud that the service use
resource "azurerm_spring_cloud_service" "application" {
  name                = local.spring_cloud_service_name
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = "B0"

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

# This creates the application definition, including system assigned identity
resource "azurerm_spring_cloud_app" "application" {
  name                = local.spring_cloud_app_name
  resource_group_name = var.resource_group
  service_name        = azurerm_spring_cloud_service.application.name
  is_public           = true
  identity {
    type = "SystemAssigned"
  }
}

# important: mysql and postgresql aad authentication expect the application_id, not the object id. that is the reason to look for the application_id in aad
data "azuread_service_principal" "aad_appid" {
  object_id = azurerm_spring_cloud_app.application.identity[0].principal_id
}

# This creates the application deployment. Terraform provider doesn't support dotnet yet
resource "azurerm_spring_cloud_java_deployment" "application_deployment" {
  name                = "default"
  spring_cloud_app_id = azurerm_spring_cloud_app.application.id
  instance_count      = 1
  runtime_version     = "Java_11"

  quota {
    cpu    = "1"
    memory = "1Gi"
  }

  environment_variables = {
    "DATABASE_CONNECTION_URL" = var.database_url
    "SPRING_DATASOURCE_URL"   = var.database_url
  }
}
