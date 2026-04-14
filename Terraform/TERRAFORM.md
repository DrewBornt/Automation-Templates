# Terraform

## About

Terraform is an infrastructure-as-code tool. You write `.tf` files that describe the desired state of your infrastructure (VMs, networks, storage, etc.), and Terraform makes it happen by talking to provider APIs (vCenter, AWS, Azure, etc.).

Terraform tracks what it has created in a `.tfstate` file, so it knows what exists, what changed, and what needs to be created or destroyed on the next run.

## How to Install

### Windows

Download from: https://developer.hashicorp.com/terraform/install

Extract `terraform.exe` to a folder (e.g. `C:\terraform`) and add it to your system PATH.

Alternatively, if you have Chocolatey: `choco install terraform`

### Ubuntu/Debian

Add HashiCorp's GPG key:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Add the repository:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Install:

```bash
sudo apt update && sudo apt install terraform
```

### Verify

```bash
terraform -version
```

## How to Use

### 1. Initialize (once per folder)

```bash
terraform init
```

Downloads provider plugins and sets up the workspace. Each folder is an independent workspace with its own state. Run this once when you first create a project folder, or after adding new providers.

### 2. Plan (dry run)

```bash
terraform plan
```

Compares your `.tf` files against the current state and shows what will be created, changed, or destroyed. **Nothing is actually modified.** Always review this output before applying — it will warn you if servers are going to be deleted or recreated.

### 3. Execute

```bash
terraform apply
```

Executes the changes shown in the plan. You'll be asked to type `yes` to confirm.

> **This is destructive.** If you removed a VM from your `.tf` files, `apply` will delete it. If you changed specs that require recreation, it will destroy and rebuild the VM. Always run `plan` first and read the output carefully.

### 4. Destroy (tear down everything)

```bash
terraform destroy
```

Removes all resources managed by this workspace. Useful for decommissioning a client's environment.

## Key Concepts

- **`.tf` files** — Your infrastructure definitions. This is what you edit.
- **`.tfstate` file** — Terraform's record of what it created. Don't edit this manually.
- **`.tfvars` file** — Variable values (credentials, VM names, specs). This is what changes per client.
- **Providers** — Plugins that connect Terraform to platforms (vSphere, AWS, etc.).
- **Modules** — Reusable infrastructure templates you can call with different variables.
- **`for_each`** — Loop to create multiple resources (e.g. several VMs) from a single block.

## Recommended Editor

VS Code with the **HashiCorp Terraform** extension gives you syntax highlighting, autocompletion, and formatting for `.tf` files.