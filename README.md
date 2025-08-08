
# Azure Terraform Admin Setup (SaaS-Ready Foundation)

This repository bootstraps a secure and scalable Azure environment for Terraform provisioning and future DevOps automation.

---

## ✅ Prerequisites

- Azure CLI installed (`brew install azure-cli`)
- Terraform installed
- Logged in to Azure:
  ```bash
  az login --all
  ```

---

## 📦 Step 1 – Select and Set Active Subscription

```bash
az account list --output table
az account set --subscription "Azure subscription 1"
az account show --output table
```

> ⚠️ If `"Microsoft Azure Sponsorship"` causes errors, use the primary `"Azure subscription 1"`.

---

## 🧾 Step 2 – Register Microsoft.Storage Provider (if needed)

```bash
az provider register --namespace Microsoft.Storage
az provider show --namespace Microsoft.Storage --query "registrationState"
```

Wait until status is `"Registered"`.

---

## 🛠 Step 3 – Create Resource Group & Storage Account for Remote Backend

```bash
az group create --name tfstate-rg --location australiaeast

az storage account create   --name tfstate88hours1978   --resource-group tfstate-rg   --sku Standard_LRS   --encryption-services blob   --location australiaeast

az storage container create   --name tfstate   --account-name tfstate88hours1978
```

> Note: Storage account name must be lowercase, no hyphens, and globally unique.

---

## 🔐 Step 4 – Create Terraform Service Principal

```bash
az ad sp create-for-rbac   --name "terraform-sp"   --role="Contributor"   --scopes="/subscriptions/<subscription_id>"   --sdk-auth
```

Copy the returned JSON and extract these fields:

```bash
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

---

## 🐟 Step 5 – Persist Environment Variables (fish shell)

Temporary for session:

```fish
set -x ARM_CLIENT_ID "<appId>"
set -x ARM_CLIENT_SECRET "<password>"
set -x ARM_SUBSCRIPTION_ID "<subscriptionId>"
set -x ARM_TENANT_ID "<tenant>"
```

Persistent (add to `~/.config/fish/config.fish`):

```fish
set -gx ARM_CLIENT_ID "<appId>"
set -gx ARM_CLIENT_SECRET "<password>"
set -gx ARM_SUBSCRIPTION_ID "<subscriptionId>"
set -gx ARM_TENANT_ID "<tenant>"
```

---

## ⚙️ Step 6 – Configure Remote Backend in Terraform

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate88hours1978"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

Then initialize:

```bash
terraform init
```

---

## 🧱 Step 7 – Create Management Groups

### Provider block

```hcl
provider "azurerm" {
  features {}
}
```

### Root management group

```hcl
resource "azurerm_management_group" "root_mg" {
  display_name = "Root Management Group"
  name         = "root-mg"
}
```

### Optional: Create child group (e.g. prod)

```hcl
resource "azurerm_management_group" "prod" {
  display_name = "Production"
  name         = "prod-mg"
  parent_management_group_id = azurerm_management_group.root_mg.id
}
```

Apply it:

```bash
terraform apply -auto-approve
```

---

## 🔍 Helpful CLI Debug/Inspect Commands

```bash
az account list --output table
az account show

az provider list --output table
az provider show --namespace Microsoft.Storage
az provider register --namespace Microsoft.Storage

az group list
az role assignment list --assignee <email>

az ad signed-in-user show
```

---

## ✅ Outcome

- Secure and compliant Terraform backend on Azure
- Service Principal auth for automation
- Management group hierarchy for future governance
- CLI-friendly setup via `fish` shell config
