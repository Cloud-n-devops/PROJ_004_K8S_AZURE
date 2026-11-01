# Fetch your current logged-in Azure CLI user details dynamically
data "azurerm_client_config" "current" {}

# Create the Central Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_logs" {
  name                = "law-gradestar-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  # FIX: cap daily ingestion so a runaway log volume can't silently bill past
  # what you're expecting. Tune this to your actual traffic — start low.
  daily_quota_gb = var.log_analytics_daily_quota_gb
}

# Assign Service Principle access to K8 extension
resource "azurerm_role_assignment" "tf_extension_access" {
  scope                = var.resource_group_id
  role_definition_name = "Kubernetes Extension Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# # Create Azure Managed Grafana
# resource "azurerm_dashboard_grafana" "grafana" {
#   name                = "grafana-gradestar-prod"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   api_key_enabled         = true
#   grafana_major_version = 12

#   identity {
#     type = "SystemAssigned"
#   }
# }

# # Grant Grafana permissions to read metrics from your subscription/Log Analytics
# resource "azurerm_role_assignment" "grafana_monitoring_reader" {
#   scope                = "/subscriptions/${var.subscription_id}"
#   role_definition_name = "Monitoring Reader"
#   principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
# }

# # Assign the Grafana Admin role to YOUR account
# resource "azurerm_role_assignment" "grafana_admin" {
#   scope                = azurerm_dashboard_grafana.grafana.id
#   role_definition_name = "Grafana Admin"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# # Look up your account by your exact login email
# data "azuread_user" "me" {
#   user_principal_name = var.principal_name
# }

# # Assign the Data Plane access role directly to your user
# resource "azurerm_role_assignment" "browser_user_admin" {
#   scope                = azurerm_dashboard_grafana.grafana.id
#   role_definition_name = "Grafana Admin"
#   principal_id         = data.azuread_user.me.object_id
# }


# # 1. Create the Azure Monitor Workspace (The Hosted Prometheus DB)
# resource "azurerm_monitor_workspace" "prometheus" {
#   name                = "amw-gradestar-prod"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   tags = {
#     Environment = "Production"
#   }
# }

# # 2. Link Prometheus to your existing AKS Cluster
# resource "azurerm_kubernetes_cluster_extension" "prometheus_extension" {
#   name          = "azuremonitor-metrics"
#   cluster_id    = var.aks_cluster_id
#   extension_type = "Microsoft.AzureMonitor.Containers.Metrics"
#   depends_on = [azurerm_role_assignment.tf_extension_access]
  
#   # This configures the cluster to stream metrics to the workspace
#   configuration_settings = {
#     "azuremonitor.metrics.monitoringWorkspaceResourceId" = azurerm_monitor_workspace.prometheus.id
#   }
# }

# # 3. Grant Grafana permission to read data from the Prometheus Workspace
# resource "azurerm_role_assignment" "grafana_prometheus_reader" {
#   scope                = azurerm_monitor_workspace.prometheus.id
#   role_definition_name = "Monitoring Data Reader"
#   principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
# }

# # 4. Connect Prometheus as a Data Source inside Grafana
# resource "azurerm_dashboard_grafana_data_source" "prometheus_source" {
#   name                  = "Azure Managed Prometheus"
#   # grafana_id            = var.grafana_resource_id
#   grafana_id            = azurerm_dashboard_grafana.grafana.id
#   type                  = "prometheus"
#   url                   = azurerm_monitor_workspace.prometheus.query_endpoint
  
#   # Configures authentication using Grafana's Managed Identity
#   json_data_secure {
#     http_header_name1  = "Authorization"
#     http_header_value1 = "Bearer"
#   }
# }