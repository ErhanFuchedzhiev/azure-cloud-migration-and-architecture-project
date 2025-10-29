# Azure Cost Optimization Design

## Objective
In this phase, I apply cost optimization strategies to Azure infrastructure to reduce operational expenses while maintaining performance and availability.  
These practices align with the **AZ-305: Design for Cost Optimization** domain and focus on measurable efficiency across compute, storage, and monitoring.

---

## 1. Resource Group & Region Selection

| Decision | Optimization Rationale |
|-----------|------------------------|
| **Region:** East US 2 | Selected for low cost per vCPU and storage while maintaining multi-zone availability. |
| **Resource Group:** vm-cli-rg | Logical isolation enables single-delete cleanup to stop billing quickly. |

> Always deploy related components in the same region to avoid cross-region data transfer costs.

---

## 2. VM Sizing and Type

| Setting | Value | Optimization Strategy |
|----------|--------|-----------------------|
| **VM Size** | Standard_B1s | Uses a burstable CPU model — ideal for dev/test workloads. Pay for baseline, burst when needed. |
| **OS Image** | Windows Server 2022 Datacenter (Gen2) | Eligible for **Azure Hybrid Benefit** (reuse existing licenses). |
| **Disk Type** | Standard SSD (LRS) | Balanced performance and cost for general-purpose workloads. |

> For non-production workloads, use **B-series** or **Spot VMs** to save up to 80%.

---

## 3. Scheduling & Auto-Shutdown

Automatically shutting down low-usage VMs prevents unnecessary billing during off-peak hours.

| Setting | Value |
|----------|--------|
| **Auto-shutdown time** | 19:00 UTC |
| **Notifications enabled** | Yes |

**CLI Example:**
```bash
az vm auto-shutdown --resource-group vm-cli-rg --name vm-cli-01 --time 1900
