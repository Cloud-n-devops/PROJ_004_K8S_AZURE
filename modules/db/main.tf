# Create a secure, random administrator password if you aren't hardcoding one
resource "random_password" "mysql_admin_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# The Production MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "db-gradestar-prod"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = "gradestar_admin"
  administrator_password = random_password.mysql_admin_password.result
  
  # The Standard Track Engine Version (Highly compatible with Laravel 10/11)
  version                = "8.0.21"

  # Sizing Track: Bursting tier B1ms (1 vCPU, 2GB RAM) - Highly cost-efficient for launching
  sku_name               = "B_Standard_B1ms"
  
  # Storage sizing in Gigabytes
  storage {
    size_gb = 20
    iops    = 360 # Base performance IOPS allocation
    # Automatically handles minor upgrades safely behind the scenes
    auto_grow_enabled      = true
  }
 
  backup_retention_days  = 7

  tags = {
    Environment = "Production"
    Project     = "Gradestar"
  }
}
resource "azurerm_mysql_flexible_server_configuration" "disable_gipk" {
  name                = "sql_generate_invisible_primary_key"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "OFF"
}

# Create the specific logical database schema for Laravel
resource "azurerm_mysql_flexible_database" "laravel_db" {
  name                = "gradestar_production"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# SRE Firewall Rule: Allows your AKS Cluster nodes to safely talk to this database
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureInternalAccess"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  
  # Special Azure rule: 0.0.0.0 mapping unlocks communication internally within Azure's fabric backbone
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}