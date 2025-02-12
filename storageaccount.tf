# Storage Account

resource "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  public_network_access_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = ["None"]
  }

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

# Role Assignment - Storage Table Data Contributor

locals {
  app_services = lower(var.service_plan_os_type) == "linux" ? [azurerm_linux_web_app.app[0], azurerm_linux_web_app.app_cm[0]] : [azurerm_windows_web_app.app[0], azurerm_windows_web_app.app_cm[0]]
  object_ids = { for key, item in local.app_services : key => item.identity[0].principal_id }
}

resource "azurerm_role_assignment" "table_contributor" {
  for_each = local.object_ids

  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = each.value
}
