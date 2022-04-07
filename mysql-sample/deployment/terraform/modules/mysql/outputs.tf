output "database_host" {
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

output "jdbc_database_url" {
  value= local.jdbc_database_url
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
