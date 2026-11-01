# # The Azure Storage Account (The storage engine container)
# resource "azurerm_storage_account" "storage" {
#   name                     = var.storageAccName # Must be globally unique, lowercase, letters/numbers only
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS" # Locally Redundant Storage (keeps 3 sync copies in the data center)

#   # Security Hardening
#   min_tls_version                 = "TLS1_2"
#   allow_nested_items_to_be_public = true # Allows us to make specific upload subfolders public if needed

#   tags = {
#     Environment = "Production"
#     Project     = "Gradestar"
#   }
# }

# # The specific private Blob Container where Laravel will stream files
# resource "azurerm_storage_container" "uploads" {
#   name                  = "user-uploads"
#   storage_account_id    = azurerm_storage_account.storage.id
#   container_access_type = "blob" # 'blob' allows anonymous read access to specific files via URL, keeping structural directory private
# }