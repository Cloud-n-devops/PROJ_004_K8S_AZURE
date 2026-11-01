# Root variables
variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "resource_group_id" {
  type = string
}
variable "location" {
  type = string
}
variable "subscription_id" {
  type = string
}
variable "aks_cluster_id" {
  type = string
}
variable "principal_name" {
  type = string
}
variable "log_analytics_daily_quota_gb" {
  type    = number
}