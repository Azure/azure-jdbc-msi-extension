output "database_url" {
  value       = "${azurerm_postgresql_server.database.fqdn}:5432/${azurerm_postgresql_database.database.name}"
  description = "The PostgreSQL server URL."
}

output "database_username" {
  value       = var.administrator_login
  description = "The PostgreSQL server user name."
}

# TODO: is it needed??
output "database_host_name" {
  value = azurerm_postgresql_server.database.name
}

output "admin_username" {
  value       = "${azurerm_postgresql_active_directory_administrator.current_aad_user_admin.login}@${azurerm_postgresql_server.database.name}"
  description = "admin user name ready to be used to connect to the database, including @hostname"
}

# TODO: is it needed??
output "database_fqdn" {
  value       = azurerm_postgresql_server.database.fqdn
  description = "PostgreSQL hostname"
}

output "database_name" {
  value       = azurerm_postgresql_database.database.name
  description = "PostgreSQL database name"
}

output "jdbc_database_url" {
  value = "jdbc:postgresql://${azurerm_postgresql_server.database.fqdn}:5432/${azurerm_postgresql_database.database.name}?sslmode=require&authenticationPluginClassName=com.azure.jdbc.msi.extension.postgresql.AzurePostgresqlMSIAuthenticationPlugin"
}
