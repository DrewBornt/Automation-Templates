terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.7"
    }
  }
  required_version = ">= 1.5.0"
}

# ─────────────────────────────────────────────
# Provider — connects to vCenter
# ─────────────────────────────────────────────
provider "vsphere" {
  user                 = var.vcenter_username
  password             = var.vcenter_password
  vsphere_server       = var.vcenter_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

# ─────────────────────────────────────────────
# Data sources — look up existing vCenter objects
# ─────────────────────────────────────────────
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ─────────────────────────────────────────────
# VM deployment — one VM per entry in var.vms
# ─────────────────────────────────────────────
resource "vsphere_virtual_machine" "vm" {
  for_each = { for vm in var.vms : vm.name => vm }

  name             = each.value.name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus = each.value.num_cpus
  memory   = each.value.memory_mb

  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  firmware = data.vsphere_virtual_machine.template.firmware

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = each.value.disk_size_gb != null ? each.value.disk_size_gb : data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = each.value.hostname
        domain    = var.domain
      }

      network_interface {
        ipv4_address = each.value.ip_address
        ipv4_netmask = var.netmask
      }

      ipv4_gateway    = var.gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = [var.domain]
    }
  }

  lifecycle {
    ignore_changes = [
      # Prevent Terraform from re-cloning if the template is updated
      clone[0].template_uuid,
    ]
  }
}
