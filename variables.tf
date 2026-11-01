variable "project_name" {
  type        = string
  description = "The name of the project"
}
variable "environment" {
  type = string
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create"
}
variable "admin_user_email" {
  type = string
}

variable "prod_location" {
  type        = string
  description = "production Location"
  default     = "eastus"
}

variable "principal_name" {
  type        = string
  description = "User principal name (email) of the account to assign Grafana Admin role"
}

# variable "email_address" {
#   type        = any
#   description = "List of email addresses to receive alerts"
# }


variable "aks_node_count" {
  type        = number
  default     = 2
  description = "Minimum number of nodes for the user workload pool"
}

variable "aks_vm_size" {
  type        = string
  default     = "Standard_D2s_v5" # Balanced CPU/Memory for production workloads
  description = "The size of the Virtual Machines running the nodes"
}
variable "storageAccName" {
  type        = string
  description = "Globally unique name for the Azure Storage Account (lowercase, letters/numbers only)"
}
variable "log_analytics_daily_quota_gb" {
  type = number
}