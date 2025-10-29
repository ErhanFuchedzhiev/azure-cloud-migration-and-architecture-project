## Pre-Creation Checklist

Before deploying Azure Virtual Machines for the medical research company, I plan each configuration carefully to ensure scalability, data compliance, and operational efficiency.  
This checklist reflects modern Azure architecture practices and helps validate every design decision before deployment.

- **Workload profile:** Define OS type (Windows/Linux), runtime version, dependencies, and workload category (compute-, memory-, or storage-intensive).  
- **VM sizing:** Choose series and SKU (e.g., D-series for general purpose, E-series for memory-optimised). Validate sizing through Azure Migrate performance data.  
- **Region and availability:** Select a region that meets data-residency rules and latency targets. Use **Availability Zones** or **Availability Sets** to maintain uptime SLAs.  
- **Networking:** Plan virtual network topology, subnet structure, IP ranges, and secure connectivity with **Network Security Groups (NSGs)**, **Azure Firewall**, and **Private Endpoints**.  
- **Storage:** Select disk types (Premium SSD v2 or Ultra Disk) and configure replication (ZRS/GRS). Encrypt disks with **customer-managed keys (CMK)** when required.  
- **Security & identity:** Apply **RBAC**, enforce least-privilege access, enable **Defender for Cloud**, and ensure patching through **Azure Update Manager**.  
- **Management & monitoring:** Configure **Azure Monitor**, **Log Analytics**, and **Activity Logs** for observability. Apply consistent **tagging** and policy enforcement with **Azure Policy**.  
- **Cost & governance:** Enable cost budgets and alerts, apply **Azure Hybrid Benefit**, use **reserved instances** where possible, and schedule auto-shutdown for non-production workloads.  
- **Migration strategy:** Use **Azure Migrate** to assess and replicate on-premises workloads. Validate functionality in test environments before the production cut-over.  

---

With the pre-creation checklist complete, I proceed to deploy and validate Azure infrastructure using automated methods such as **Azure CLI**, **Bicep templates**, and **PowerShell scripts**, ensuring consistent, secure, and repeatable provisioning across environments.
