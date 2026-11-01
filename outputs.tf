output "debug_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "debug_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "mysql_host_endpoint" {
  value       = module.db.mysql_host_endpoint
  description = "Inject this string directly into your central ConfigMap under DB_HOST"
}

output "mysql_generated_password" {
  value       = module.db.mysql_generated_password
  sensitive   = true # Tells Terraform to hide it from standard terminal logs
}

# output "storage_account_name" {
#   value       = module.storage.storage_account_name
#   description = "Inject this into your Laravel .env under AZURE_STORAGE_NAME"
# }

