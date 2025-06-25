terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.8"
    }
  }
  required_version = ">= 1.3"
}

resource "null_resource" "deprecation_warning" {
  provisioner "local-exec" {
    command = "echo 'WARNING: This Terraform module is deprecated and may be removed in future releases. Please use the successor module: https://registry.terraform.io/modules/scepman/scepman/'"
  }
}

output "deprecation_warning" {
  value = "WARNING: This Terraform module is deprecated and may be removed in future releases. Please use the successor module: https://registry.terraform.io/modules/scepman/scepman/"
}

data "azurerm_client_config" "current" {}

# Log Analytics Workspace

# Get exisiting Log Analytics Workspace if law_resource_group_name is defined
data "azurerm_log_analytics_workspace" "existing-law" {
  count               = var.law_resource_group_name != null ? 1 : 0
  name                = var.law_name
  resource_group_name = var.law_resource_group_name
}

resource "azurerm_log_analytics_workspace" "law" {
  count = length(data.azurerm_log_analytics_workspace.existing-law) > 0 ? 0 : 1

  name                = var.law_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = var.tags
}

locals {
  law_id           = length(data.azurerm_log_analytics_workspace.existing-law) > 0 ? data.azurerm_log_analytics_workspace.existing-law[0].id : azurerm_log_analytics_workspace.law[0].id
  law_workspace_id = length(data.azurerm_log_analytics_workspace.existing-law) > 0 ? data.azurerm_log_analytics_workspace.existing-law[0].workspace_id : azurerm_log_analytics_workspace.law[0].workspace_id
  law_shared_key   = length(data.azurerm_log_analytics_workspace.existing-law) > 0 ? data.azurerm_log_analytics_workspace.existing-law[0].primary_shared_key : azurerm_log_analytics_workspace.law[0].primary_shared_key
}

# Application Insights
# Creating Application Insights will not allow terraform to destroy the ressource group, as app insights create hidden rules that can (currently) not be managed by terraform

resource "azurerm_application_insights" "scepman-primary" {
  count               = var.enable_application_insights == true ? 1 : 0
  name                = format("%s_app-insights", var.app_service_name_primary)
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.law_id
  application_type    = "web"

  tags = var.tags
}
resource "azurerm_application_insights" "scepman-cm" {
  count               = var.enable_application_insights == true ? 1 : 0
  name                = format("%s_app-insights", var.app_service_name_certificate_master)
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.law_id
  application_type    = "web"

  tags = var.tags
}
