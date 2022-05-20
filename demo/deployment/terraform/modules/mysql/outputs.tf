output "database_fqdn" {
  value       = azurerm_mysql_server.database.fqdn
  description = "MySQL Server host FQDN"
}

output "database_host_name" {
  value = azurerm_mysql_server.database.name
}

output "database_url" {
  value       = local.database_url
  description = "The MySQL server URL."
}

output "database_username" {
  value       = var.administrator_login
  description = "The MySQL server user name."
}

output "database_password" {
  value       = random_password.password.result
  sensitive   = true
  description = "The MySQL server password."
}

output "admin_username" {
  value       = "${azurerm_mysql_active_directory_administrator.current_aad_user_admin.login}@${azurerm_mysql_server.database.name}"
  description = "admin user name ready to be used to connect to the database, including @hostname"
}

output "database_name" {
  value       = azurerm_mysql_database.database.name
  description = "MySQL database name"
}

output "jdbc_database_url" {
  value = "jdbc:mysql://${azurerm_mysql_server.database.fqdn}:3306/${azurerm_mysql_database.database.name}?sslMode=REQUIRED&useSSL=true&defaultAuthenticationPlugin=com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin&authenticationPlugins=com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin"
}

output "spring_datasource_url" {
  value = "jdbc:mysql://${azurerm_mysql_server.database.fqdn}:3306/${azurerm_mysql_database.database.name}"
}
