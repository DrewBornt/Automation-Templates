# vsphere-vm-deploy

Deploys one or more VMs in vCenter by cloning a template and applying a guest OS customization (hostname, static IP, DNS, domain).

## Files

| File | Purpose |
|---|---|
| `main.tf` | Provider config, data source lookups, VM resource block |
| `variables.tf` | All input variable declarations with descriptions |
| `outputs.tf` | Prints VM names, IPs, and UUIDs after apply |
| `terraform.tfvars` | **Your values go here** — credentials, VM specs, network config |
| `.gitignore` | Prevents state files and tfvars from being committed |

## Prerequisites

- Terraform >= 1.5 installed
- A vCenter user account with permissions to clone VMs and apply customizations
- VMware Tools installed in the template (required for guest customization)
- The template must have the `linux_options` customization block match its OS type — swap for `windows_options` if deploying Windows (see note below)

## Quick Start

1. Fill in `terraform.tfvars` with your vCenter details and VM list.
2. Initialize the workspace (downloads the vSphere provider):
   ```bash
   terraform init
   ```
3. Preview what will be created:
   ```bash
   terraform plan
   ```
4. Deploy:
   ```bash
   terraform apply
   ```

## Windows Templates

If your template is Windows, replace the `linux_options` block inside `clone > customize` in `main.tf` with:

```hcl
windows_options {
  computer_name  = each.value.hostname
  workgroup      = "Your-Workgroup-Here"   # or use join_domain / domain_admin_user / domain_admin_password
  admin_password = var.windows_admin_password
  time_zone      = 85   # Eastern; see vSphere docs for other zone codes
}
```

Add a corresponding `windows_admin_password` sensitive variable to `variables.tf` and `terraform.tfvars`.

## Adding More VMs

Add another object to the `vms` list in `terraform.tfvars`:

```hcl
{
  name         = "Your-VM-Name-Here"
  hostname     = "Your-Hostname-Here"
  ip_address   = "Your-IP-Here"
  num_cpus     = 2
  memory_mb    = 4096
  disk_size_gb = null
}
```

Run `terraform apply` — only the new VM will be created; existing VMs are not touched.

## Removing a VM

Remove its object from the `vms` list and run `terraform apply`. Terraform will destroy that VM. Always run `terraform plan` first to confirm only the intended VM is marked for destruction.
