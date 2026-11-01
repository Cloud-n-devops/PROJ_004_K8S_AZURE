output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.aks_logs.id
  description = "ID of the central Log Analytics Workspace"
}
