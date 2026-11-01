output "mysql_host_endpoint" {
  value       = azurerm_mysql_flexible_server.mysql.fqdn
  description = "Inject this string directly into your central ConfigMap under DB_HOST"
}

output "mysql_generated_password" {
  value       = random_password.mysql_admin_password.result
  sensitive   = true # Tells Terraform to hide it from standard terminal logs
}