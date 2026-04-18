# vsphere-vm-deploy

Deploys one or more VMs in vCenter by cloning a template and applying a guest OS customization (hostname, static IP, DNS, domain). Each VM can be placed on its own port group and subnet, or they can all share the same network defaults.

---

## Requirements

### Control Machine (where you run Ansible)

| Requirement | Notes |
|---|---|
| Python 3.9+ | Needed by Ansible and the VMware SDK |
| Ansible 8+ (ansible-core 2.15+) | `pip install ansible` |
| community.vmware collection | `ansible-galaxy collection install community.vmware` |
| PyVmomi | `pip install PyVmomi` — Python bindings for the vSphere API |
| vSphere Automation SDK *(optional)* | `pip install vsphere-automation-sdk` — required only for newer REST-based VMware modules; not needed for `vmware_guest` |

> All of the above can be installed in a virtual environment to keep your system Python clean:
> ```bash
> python -m venv venv && source venv/bin/activate
> pip install ansible PyVmomi
> ansible-galaxy collection install community.vmware
> ```

---

### vCenter Environment

**Permissions** — the account in `vars.yml` needs at minimum:

- Virtual machine → Inventory → Create from existing
- Virtual machine → Configuration → (all)
- Virtual machine → Provisioning → Clone virtual machine
- Virtual machine → Provisioning → Customize guest
- Resource → Assign virtual machine to resource pool
- Datastore → Allocate space
- Network → Assign network

A custom role with these permissions assigned at the datacenter level (propagated to children) is the cleanest approach.

**Template prerequisites:**

- The template must have **VMware Tools installed and running** — guest customization will not work without it.
- The template must be an actual VM template (right-click → Convert to Template), not just a powered-off VM.
- The template's OS must match the customization type. This playbook uses Linux customization. For Windows templates, the `vmware_guest` module uses a different set of customization keys — see the [module docs](https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_guest_module.html).
- The **VMware vCenter guest customization specification** does not need to be pre-created — `vmware_guest` builds the spec on the fly from the values in `vars.yml`.

**Network:**

- Each port group named in `vars.yml` must already exist in vCenter.
- Static IPs must be free — this playbook does not check for conflicts.
- DNS and gateway entries must be reachable from the target subnet or customization will complete but the VM may not be network-accessible.

---

## Usage

1. Copy `vars.yml` and fill in your values (see inline comments).
2. Run the playbook:
   ```bash
   ansible-playbook deploy_vms.yml
   ```
3. Ansible will print each VM name as it works through the list. The task waits for an IP address before moving to the next VM, so the run takes roughly 1–3 minutes per VM depending on guest customization speed.

---

## Per-VM Network Overrides

Every VM **requires** a `network` (port group name) and `ip_address`. The remaining network fields (`gateway`, `netmask`, `domain`, `dns_servers`) fall back to the `default_*` values at the top of `vars.yml` if not specified per VM. This means:

- All VMs on one network → fill in only the defaults, omit per-VM overrides.
- Mixed networks → set the most common network as the default, then override only the VMs that differ.
- Every VM fully isolated → override all four fields on each VM entry.
