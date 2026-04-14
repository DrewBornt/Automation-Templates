# ══════════════════════════════════════════════════════════
#  terraform.tfvars — fill this in before running
#  WARNING: this file contains credentials — do NOT commit
#           it to source control. It is listed in .gitignore.
# ══════════════════════════════════════════════════════════

# ─── vCenter connection ───────────────────────────────────
vcenter_server       = "Your-vCenter-Hostname-Or-IP-Here"
vcenter_username     = "Your-vCenter-Username-Here"   # e.g. administrator@vsphere.local
vcenter_password     = "Your-vCenter-Password-Here"
allow_unverified_ssl = true                           # set false if you have a trusted cert

# ─── vCenter inventory ────────────────────────────────────
datacenter  = "Your-Datacenter-Name-Here"
cluster     = "Your-Cluster-Or-Host-Name-Here"
datastore   = "Your-Datastore-Name-Here"
network     = "Your-Port-Group-Name-Here"
vm_folder   = "Your-VM-Folder-Path-Here"    # e.g. "Production/Servers" or "" for root

# ─── Template ─────────────────────────────────────────────
template_name = "Your-Template-Name-Here"   # must exist in the datacenter

# ─── Guest OS customization ───────────────────────────────
domain      = "Your-Domain-Here"            # e.g. corp.example.com
gateway     = "Your-Default-Gateway-Here"   # e.g. 192.168.1.1
netmask     = 24                            # subnet prefix length
dns_servers = ["Your-Primary-DNS-Here", "Your-Secondary-DNS-Here"]

# ─── VMs to deploy ────────────────────────────────────────
# Add or remove objects to control how many VMs are created.
# disk_size_gb is optional — omit it to inherit the template disk size.
vms = [
  {
    name         = "Your-VM-Display-Name-Here"
    hostname     = "Your-Hostname-Here"
    ip_address   = "Your-Static-IP-Here"
    num_cpus     = 2
    memory_mb    = 4096
    disk_size_gb = null   # null = use template size; set a number (e.g. 60) to override
  },
  {
    name         = "Your-Second-VM-Display-Name-Here"
    hostname     = "Your-Second-Hostname-Here"
    ip_address   = "Your-Second-Static-IP-Here"
    num_cpus     = 4
    memory_mb    = 8192
    disk_size_gb = null
  },
]
