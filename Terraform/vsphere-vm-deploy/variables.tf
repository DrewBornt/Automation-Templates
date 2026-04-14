# ─────────────────────────────────────────────
# vCenter connection
# ─────────────────────────────────────────────
variable "vcenter_server" {
  description = "Hostname or IP of the vCenter server"
  type        = string
}

variable "vcenter_username" {
  description = "vCenter login username (e.g. administrator@vsphere.local)"
  type        = string
}

variable "vcenter_password" {
  description = "vCenter login password"
  type        = string
  sensitive   = true
}

variable "allow_unverified_ssl" {
  description = "Skip TLS certificate verification for vCenter (set true for self-signed certs)"
  type        = bool
  default     = false
}

# ─────────────────────────────────────────────
# vCenter inventory targets
# ─────────────────────────────────────────────
variable "datacenter" {
  description = "Name of the vCenter datacenter"
  type        = string
}

variable "cluster" {
  description = "Name of the compute cluster or host to deploy onto"
  type        = string
}

variable "datastore" {
  description = "Name of the datastore to place VM files on"
  type        = string
}

variable "network" {
  description = "Port group / network name to attach the VM NIC to"
  type        = string
}

variable "vm_folder" {
  description = "vCenter folder path to place VMs in (e.g. 'Production/Servers'). Leave empty string for root."
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────
# Template
# ─────────────────────────────────────────────
variable "template_name" {
  description = "Name of the VM template to clone (must exist in the datacenter)"
  type        = string
}

# ─────────────────────────────────────────────
# Guest OS customization — network & identity
# ─────────────────────────────────────────────
variable "domain" {
  description = "DNS domain / search suffix (e.g. corp.example.com)"
  type        = string
}

variable "gateway" {
  description = "Default IPv4 gateway for all deployed VMs"
  type        = string
}

variable "netmask" {
  description = "Subnet prefix length as an integer (e.g. 24 for /24)"
  type        = number
  default     = 24
}

variable "dns_servers" {
  description = "List of DNS server IPs"
  type        = list(string)
}

# ─────────────────────────────────────────────
# VM definitions
# ─────────────────────────────────────────────
variable "vms" {
  description = "List of VMs to deploy. Each object defines one machine."
  type = list(object({
    name         = string        # VM display name in vCenter
    hostname     = string        # OS hostname set by customization
    ip_address   = string        # Static IPv4 address
    num_cpus     = number        # vCPU count
    memory_mb    = number        # RAM in MB (e.g. 4096 = 4 GB)
    disk_size_gb = optional(number) # Override template disk size; null = inherit from template
  }))
}
