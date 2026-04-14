# ─────────────────────────────────────────────
# Outputs — printed after apply, useful for records
# ─────────────────────────────────────────────
output "vm_names" {
  description = "Display names of all deployed VMs"
  value       = [for vm in vsphere_virtual_machine.vm : vm.name]
}

output "vm_ip_addresses" {
  description = "Assigned IP addresses keyed by VM name"
  value       = { for name, vm in vsphere_virtual_machine.vm : name => vm.default_ip_address }
}

output "vm_uuids" {
  description = "vCenter UUIDs keyed by VM name"
  value       = { for name, vm in vsphere_virtual_machine.vm : name => vm.uuid }
}
