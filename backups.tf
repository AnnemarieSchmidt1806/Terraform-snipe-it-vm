resource "azurerm_recovery_services_vault" "my_recovery_service_vault" {
  name = "snipeit-recovery-vault"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku = "Standard"
}

resource "azurerm_backup_policy_vm" "my_backup_policy" {
  name = "snipeitrecoveryvaultpolicy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.my_recovery_service_vault.name

  timezone = "W. Europe Standard Time"

  backup {
    frequency = "Daily"
    time = "23:00"
  }

    retention_daily {
      count = 7
    }

    retention_weekly {
      count = 12
      weekdays = ["Friday"]
    }

}

resource "azurerm_backup_protected_vm" "my_backup_protected_vm" {
    resource_group_name = var.resource_group_name
    recovery_vault_name = azurerm_recovery_services_vault.my_recovery_service_vault.name
    source_vm_id = azurerm_linux_virtual_machine.my_terraform_vm.id
    backup_policy_id = azurerm_backup_policy_vm.my_backup_policy.id
}
