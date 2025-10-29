# 03 – Create an Azure VM Backup (Portal & CLI)

## Objective
This exercise demonstrates two methods to **create and configure a backup for a Windows Server 2022 Virtual Machine** — first using the **Azure Portal**, and then via **Azure CLI automation**.  
It complements the earlier *Create Azure VM using CLI* case study in this repository.

This exercise continues the **Plan and Create Infrastructure** phase of the migration case study.  
It follows the previous exercise, where I deployed a Windows Server 2022 VM using Azure CLI, by adding data protection through Azure Backup.

> [!NOTE]  
> Always create your backup vault in the **same region** as your protected resources to ensure compliance and minimize data transfer costs.  
> Consider using **Geo-Redundant Storage (GRS)** for production workloads.

---

## Prerequisites
- Active [Azure subscription](https://portal.azure.com)  
- Existing VM (e.g., `vm-cli-01` in resource group `vm-cli-rg`)  
- Access to [Azure Cloud Shell](https://shell.azure.com) or Azure CLI installed locally  
- Resource group and region must match your VM deployment  

---

## Method 1 – Create Backup via Azure Portal
1. In the Azure Portal, search for **Backup Vaults**.  
2. Click **Create** and complete the fields:  
   - **Subscription:** Azure subscription 1  
   - **Resource Group:** `vm-cli-rg`  
   - **Backup Vault name:** `vm-backup-vault`  
   - **Region:** East US 2  
   - **Backup storage redundancy:** Locally-redundant  
3. Enable system identity and leave other settings default.  
4. Click **Review + Create → Create**.

### Portal Verification
![Create Backup Vault in Azure Portal](../images/12.Create-Backup.png)  
*Figure 1 – Creating the backup vault in the Azure Portal.*

---

## Method 2 – Create Backup via Azure CLI
The following script automates the entire Azure Backup configuration, from creating the Recovery Services vault to enabling protection and triggering an on-demand backup job.

Save it as **`backup-azure-vm-cli.sh`** in your `/scripts` folder and run it in **Azure Cloud Shell**.

```bash
# (script here with VMNAME="vm-cli-01")
