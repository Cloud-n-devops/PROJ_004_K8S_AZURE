# 1. Private Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrgradestarprod" # Must be globally unique, alphanumeric only
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false # Disabled for security; we use Azure AD/Managed Identities
}

# 2. Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "gradestar-aks-cluster"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "gradestar-k8s"
  kubernetes_version  = "1.34" # Uses a stable production-ready K8s version

  # Default System Node Pool (Internal cluster mechanics only)
  default_node_pool {
    name       = "systempool"
    node_count = 1
    vm_size    = var.aks_vm_size
    os_sku     = "AzureLinux" # Fast, secure, lightweight container host OS
    temporary_name_for_rotation = "tmpnodepool" # Enables seamless node pool rotation for zero-downtime cluster maintenance
    
    upgrade_settings {
      max_surge                    = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }

    # Restrict application workloads from crowding system nodes
    node_labels = {
      "role" = "system"
    }
  }

  # System Assigned Managed Identity for cluster control plane
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure" # Azure CNI for high-performance pod networking
    load_balancer_sku = "standard"
  }
  # Observability
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}

# 3. Workload Node Pool (Where your Laravel/Nginx containers run)
resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_vm_size
  auto_scaling_enabled   = true
  min_count             = var.aks_node_count
  max_count             = 1 #5
  os_sku                = "AzureLinux"

  node_labels = {
    "role" = "application"
  }
  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }
}

# 4. Secure IAM Link: Grant AKS permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = var.resource_group_id
  skip_service_principal_aad_check = true
}