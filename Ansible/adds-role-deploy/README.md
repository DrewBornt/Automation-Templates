# adds-role-deploy

Installs the AD Domain Services role and promotes a Windows Server to a Domain Controller, creating a new forest. The server reboots automatically at the end if required.

---

## Requirements

### Control Machine (where you run Ansible)

| Requirement | Notes |
|---|---|
| Python 3.9+ | |
| Ansible 8+ | `pip install ansible` |
| ansible.windows collection | Bundled with `ansible`; or `ansible-galaxy collection install ansible.windows` |
| microsoft.ad collection | `ansible-galaxy collection install microsoft.ad` |
| pywinrm | `pip install pywinrm` — Ansible's WinRM transport layer |

---

### Target Windows Server

**WinRM must be enabled** before Ansible can connect. Run this once on the server (in an elevated PowerShell prompt):

```powershell
winrm quickconfig -force
winrm set winrm/config/service/auth '@{NTLM="true"}'
```

For a lab or trusted network, you can also allow unencrypted traffic to avoid cert setup:

```powershell
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

> For production, use HTTPS WinRM with a real certificate instead and set `ansible_winrm_transport: kerberos` or `credssp`.

**Other expectations:**

- Windows Server 2016 or newer
- The account in `inventory.yml` must be a local Administrator (or Domain Admin if the server is already joined to a domain)
- Static IP is strongly recommended before promoting to a DC — DHCP and DNS can behave unpredictably post-promotion
- This playbook creates a **new forest**. To add a DC to an existing domain, change the `state` in `microsoft.ad.domain` to `member_server` and supply the existing domain credentials

---

## Usage

1. Fill in `inventory.yml` with the server address and credentials.
2. Fill in `vars.yml` with the domain name, NetBIOS name, and safe mode password.
3. Run:
   ```bash
   ansible-playbook -i inventory.yml install_adds.yml
   ```
