terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.1"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.16"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  // If an environment is set up (dev, test, prod...), it is used in the application name
  environment = var.environment == "" ? "dev" : var.environment
}

resource "azurecaf_name" "resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = [local.environment]
}

resource "azurerm_resource_group" "main" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform"        = "true"
    "environment"      = local.environment
    "application-name" = var.application_name
    "nubesgen-version" = "0.11.1"
  }
}

module "application_spring" {
  count            = var.hosting_type == "spring" ? 1 : 0
  source           = "./modules/spring-cloud"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
  database_url     = local.jdbc_database_url_with_user
}

module "application_appservice" {
  count            = var.hosting_type == "appservice" ? 1 : 0
  source           = "./modules/app-service"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
  identity_type    = var.identity_type
  database_url     = local.jdbc_database_url_with_user
}
module "database_mysql" {
  count                  = var.database_type == "mysql" ? 1 : 0
  source                 = "./modules/mysql"
  resource_group         = azurerm_resource_group.main.name
  application_name       = var.application_name
  environment            = local.environment
  location               = var.location
  aad_administrator_name = var.aad_administrator_name
}

module "database_postgresql" {
  count                  = var.database_type == "postgresql" ? 1 : 0
  source                 = "./modules/postgresql"
  resource_group         = azurerm_resource_group.main.name
  application_name       = var.application_name
  environment            = local.environment
  location               = var.location
  aad_administrator_name = var.aad_administrator_name
}

locals {
  # database_url                = var.database_type == "mysql" ? module.database_mysql[0].database_url : module.database_postgresql[0].database_url
  database_fqdn  = var.database_type == "mysql" ? module.database_mysql[0].database_fqdn : module.database_postgresql[0].database_fqdn
  admin_username = var.database_type == "mysql" ? module.database_mysql[0].admin_username : module.database_postgresql[0].admin_username
  # database_host               = var.database_type == "mysql" ? module.database_mysql[0].database_host : module.database_postgresql[0].database_host
  database_name               = var.database_type == "mysql" ? module.database_mysql[0].database_name : module.database_postgresql[0].database_name
  database_host_name          = var.database_type == "mysql" ? module.database_mysql[0].database_host_name : module.database_postgresql[0].database_host_name
  application_username        = var.database_type == "mysql" ? "${var.application_name}@${var.aad_domain}" : var.application_name
  application_login           = "${local.application_username}@${local.database_host_name}"
  jdbc_database_url           = var.database_type == "mysql" ? module.database_mysql[0].jdbc_database_url : module.database_postgresql[0].jdbc_database_url
  jdbc_database_url_with_user = "${local.jdbc_database_url}&user=${local.application_login}"

  application_name          = var.hosting_type == "appservice" ? module.application_appservice[0].application_name : module.application_spring[0].application_name
  application_identity      = var.hosting_type == "appservice" ? module.application_appservice[0].application_identity : module.application_spring[0].application_identity
  application_url           = var.hosting_type == "appservice" ? module.application_appservice[0].application_url : module.application_spring[0].application_url
  spring_cloud_service_name = var.hosting_type == "appservice" ? "" : module.application_spring[0].spring_cloud_service_name
}
