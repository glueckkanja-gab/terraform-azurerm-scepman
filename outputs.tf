output "scepman_url" {
  value       = format("https://%s", var.service_plan_os_type == "Linux" ? azurerm_linux_web_app.app[0].default_hostname : azurerm_windows_web_app.app[0].default_hostname)
  description = "SCEPman Url"
}

output "scepman_certificate_master_url" {
  value       = format("https://%s", var.service_plan_os_type == "Linux" ? azurerm_linux_web_app.app_cm[0].default_hostname : azurerm_windows_web_app.app_cm[0].default_hostname)
  description = "SCEPman Certificate Master Url"
}
