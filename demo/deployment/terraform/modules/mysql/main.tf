terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.16"
    }
  }
}

resource "azurecaf_name" "mysql_server" {
  name          = var.application_name
  resource_type = "azurerm_mysql_server"
  suffixes      = [var.environment]
}

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "azurerm_mysql_server" "database" {
  name                = azurecaf_name.mysql_server.result
  resource_group_name = var.resource_group
  location            = var.location

  administrator_login = var.administrator_login
  administrator_login_password = random_password.password.result
  ssl_enforcement_enabled      = true
  storage_mb                   = 5120

  sku_name                     = "B_Gen5_1"
  version                      = "8.0"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

resource "azurerm_mysql_database" "database" {
  name                = var.database_name
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.database.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurecaf_name" "mysql_firewall_rule" {
  name          = var.application_name
  resource_type = "azurerm_mysql_firewall_rule"
  suffixes      = [var.environment]
}

# This rule is to enable the 'Allow access to Azure services' checkbox
resource "azurerm_mysql_firewall_rule" "database" {
  name                = azurecaf_name.mysql_firewall_rule.result
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.database.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# To enable managed identities in MySQL it is necessary to create an Active Directory administrator

# assign current azure ad user as server admin
data "azurerm_client_config" "current" {}

resource "azurerm_mysql_active_directory_administrator" "current_aad_user_admin" {
  server_name         = azurerm_mysql_server.database.name
  resource_group_name = var.resource_group
  login               = "sqladmin"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

# this rule is to enable the access from current machine to allow SQL script executions
# this sample provides sql script to create aad users in MySQL. If you don't plan to create those users you can skip these steps
data "http" "myip" {
  url = "http://whatismyip.akamai.com"
}

locals {
  myip = chomp(data.http.myip.body)
}

resource "azurecaf_name" "mysql_firewall_rule_agent" {
  name          = "${var.application_name}-deployagent"
  resource_type = "azurerm_mysql_firewall_rule"
  suffixes      = [var.environment]
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall_clientip" {
  name                = azurecaf_name.mysql_firewall_rule_agent.result
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.database.name
  start_ip_address    = local.myip
  end_ip_address      = local.myip
}

# prepare locals to be returned as module output
locals {
  database_url      = "${azurerm_mysql_server.database.name}.mysql.database.azure.com:3306/${azurerm_mysql_database.database.name}"
  
}
