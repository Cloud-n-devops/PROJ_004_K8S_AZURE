terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "gradestar-admin-rg"
  #   storage_account_name = "gradestartfstate"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  #   use_oidc             = true # Matches pipeline logic
  # }
}


provider "azurerm" {
  features {
    application_insights {
      # This prevents the "Failure Anomalies" rule and 
      # its Action Group from being created automatically.
      disable_generated_rule = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      # This tells Terraform to permanently delete (purge) on destroy
      purge_soft_deleted_secrets_on_destroy = true
      purge_soft_deleted_keys_on_destroy    = true

      # If you want it to recover instead of failing if it finds a deleted vault
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "RG_aks_cluster" {
  name     = var.resource_group_name
  location = var.prod_location
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.RG_aks_cluster.name
  location            = azurerm_resource_group.RG_aks_cluster.location
  project_name        = var.project_name
  environment         = var.environment
  aks_node_count      = var.aks_node_count
  aks_vm_size         = var.aks_vm_size
  resource_group_id   = azurerm_resource_group.RG_aks_cluster.id
  log_analytics_workspace_id = module.observability.log_analytics_workspace_id
}
module "db" {
  source              = "./modules/db"
  resource_group_name = azurerm_resource_group.RG_aks_cluster.name
  location            = azurerm_resource_group.RG_aks_cluster.location
  project_name        = var.project_name
  environment         = var.environment
}

module "observability" {
  source              = "./modules/observability"
  resource_group_name = azurerm_resource_group.RG_aks_cluster.name
  location            = azurerm_resource_group.RG_aks_cluster.location
  project_name        = var.project_name
  environment         = var.environment
  subscription_id     = data.azurerm_client_config.current.subscription_id
  aks_cluster_id      = module.compute.aks_cluster_id
  resource_group_id   = azurerm_resource_group.RG_aks_cluster.id
  principal_name      = var.principal_name
  log_analytics_daily_quota_gb = var.log_analytics_daily_quota_gb
}

# module "storage" {
#   source              = "./modules/storage"
#   resource_group_name = azurerm_resource_group.RG_aks_cluster.name
#   location            = azurerm_resource_group.RG_aks_cluster.location
#   project_name        = var.project_name
#   environment         = var.environment
#   storageAccName      = var.storageAccName
# }





