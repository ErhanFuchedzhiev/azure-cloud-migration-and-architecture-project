# Exercise: Create a Virtual Machine (Azure Portal)

## Objective
This exercise is part of the **Plan and Create Infrastructure** phase.  
It demonstrates manual deployment of a baseline virtual machine before automating infrastructure creation with Azure CLI and Bicep in subsequent exercises.


---

## Prerequisites
- Active [Azure Free Trial](https://azure.microsoft.com/free/)
- Access to the Azure Portal
- Basic understanding of Virtual Machines, networking, and cloud resource groups

---

## Step-by-Step Implementation

### Step 1 — Navigate to Create a Virtual Machine
From the Azure Portal home screen:
> **Home → Create a resource → Compute → Virtual Machine**

This opens the *Create a virtual machine* wizard.

![Create a VM - Basics Tab](../images/1.Create%20VM.png)


---

### Step 2 — Configure Basic Settings
Fill out the fields as follows:

| Setting | Value |
|----------|--------|
| **Subscription** | Azure subscription 1 |
| **Resource group** | `vm-uk-research-01_group` |
| **Virtual machine name** | `vm-uk-research-01` |
| **Region** | East US 2 |
| **Availability options** | No infrastructure redundancy required |
| **Security type** | Standard |
| **Image** | Windows Server 2022 Datacenter: Azure Edition (Gen2) |
| **Size** | Standard B1s (1 vCPU, 1 GiB memory – free-tier eligible) |
| **Username** | `azureuser` |
| **Password** | (your secure password) |
| **Inbound ports** | Allow selected ports → RDP (3389) |

> ⚠️ **Note:** Opening RDP (3389) to all IP addresses is suitable for testing only.  
> In production, restrict access using known IPs or a VPN.

![Configure Basic Settings](../images/2.Create%20VM.png)
![Inbound Ports Configuration](../images/3.Next%20Step.png)

---

###  Step 3 — Configure Disks
In the **Disks** tab:

- **OS disk type:** Standard SSD (LRS)  
- **Delete with VM:** ✅ Enabled  
- **Encryption:** Platform-managed key (default)  

> The VM uses a 127 GiB OS disk. Ultra Disk and host encryption are optional and not required for this exercise.

![Configure Disks](../images/4.Disks.png)

---

### Step 4 — Configure Networking
Under **Networking**, configure:

| Setting | Value |
|----------|--------|
| **Virtual network** | (new) `vm-uk-research-01-vnet` |
| **Subnet** | (new) `default (10.0.0.0/24)` |
| **Public IP** | (new) `vm-uk-research-01-ip` |
| **NIC network security group** | Basic |
| **Public inbound ports** | Allow selected ports → RDP (3389) |
| **Delete public IP and NIC when VM is deleted** | ✅ Enabled |

> Keep “Load balancing” set to **None** unless you are creating multiple VMs behind a load balancer.

![Configure Networking](../images/5.Networking.png)

---

### Step 5 — Configure Management
In the **Management** tab:

| Setting | Value |
|----------|--------|
| **Microsoft Defender for Cloud** | Enabled (Basic – Free) |
| **System-assigned managed identity** | ✅ Enabled |
| **Auto-shutdown** | ✅ Enabled |
| **Shutdown time** | 7:00 PM (UTC) |
| **Notification before shutdown** | ✅ Enabled |
| **Notification email** | *your email address* |
| **Backup** | Disabled |

> Enabling auto-shutdown helps avoid unnecessary charges when the VM is not in use.

![Configure Management](../images/6.Management.png)

---

### Step 6 — Configure Monitoring
In the **Monitoring** tab:

| Setting | Value |
|----------|--------|
| **Boot diagnostics** | Enable with managed storage account (Recommended) |
| **OS guest diagnostics** | Disabled |
| **Application health monitoring** | Disabled |

> Boot diagnostics capture screenshots and logs to assist with troubleshooting.

![Configure Monitoring](../images/7.Monitoring.png)

---

### Step 7 — Review + Create
Azure will validate all settings.  
Ensure you see the message:  
> ✅ **Validation passed**

Then click **Create** to deploy the virtual machine.

![Review and Create - Validation Passed](../images/8.Create.png)
![Validation Summary](../images/9.Create.png)

---

### Step 8 — Deployment Completed
Once the deployment is complete, Azure automatically creates:
- Virtual Machine  
- Network Interface  
- Network Security Group  
- Public IP Address  
- Virtual Network  
- Resource Group  

All resources are visible under the same resource group.

![Deployment Completed](../images/10.Created.png)

---

## ✅ Verification
Navigate to:
> **Home → Recent Resources**

You should see all resources created for the VM:
- `vm-uk-research-01` (Virtual Machine)
- `vm-uk-research-01vnet` (Virtual Network)
- `vm-uk-research-01-ip` (Public IP)
- `vm-uk-research-01-nsg` (Network Security Group)
- `vm-uk-research-01_group` (Resource Group)

---

## Cleanup (Optional)
After testing, delete the entire resource group to avoid consuming free-tier credits.

> **Azure Portal → Resource groups → vm-uk-research-01_group → Delete**

---

## Summary

| Category | Configuration |
|-----------|----------------|
| **Region** | East US 2 |
| **Operating System** | Windows Server 2022 Datacenter (Gen2) |
| **VM Size** | Standard B1s (1 vCPU, 1 GiB RAM) |
| **Disk Type** | Standard SSD (LRS) |
| **Networking** | VNet, Subnet, Public IP, RDP Enabled |
| **Management** | Defender (Free), Auto-shutdown Enabled |
| **Monitoring** | Boot Diagnostics Enabled |
| **Cost** | ≈ $0.014 USD/hr (covered by free-tier credits) |

---

## Outcome
A fully functional **Windows Server 2022 Virtual Machine** has been deployed in Azure, following best practices for cost efficiency and resource cleanup.  
This environment can now be used for:
- Testing workloads  
- Practicing RDP access  
- Evaluating Azure management and monitoring features  

---

