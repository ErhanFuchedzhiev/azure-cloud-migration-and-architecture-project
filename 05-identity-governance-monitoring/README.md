# 05. Identity, Governance & Monitoring

## Overview
This section consolidates the governance and monitoring configuration created throughout the migration case study.  
It aligns with **Microsoft AZ-305 (Design Identity, Governance, and Monitoring Solutions)** — demonstrating how to enforce governance, ensure visibility, and maintain operational control.

---

## Identity, Governance & Monitoring Overview

| Area | Description | Artifacts / Examples |
|------|--------------|----------------------|
| **RBAC (Identity)** | Implemented least-privilege access through built-in roles and resource-level scoping. | [`07-rbac-vm-cli-rg.md`](../docs/07-rbac-vm-cli-rg.md) |
| **Azure Policy (Governance)** | Enforced tagging standards and denied creation of non-compliant resources (e.g., missing “Environment” tag). | [`08-policy-enforcement-tag-requirement.md`](../docs/08-policy-enforcement-tag-requirement.md) |
| **Monitoring & Alerts** | Centralized monitoring via Log Analytics Workspace and CPU alert rules for VMs. | [`09-monitoring-and-alerts.md`](../docs/09-monitoring-and-alerts.md) |


---

## Key Components

1. **RBAC least privilege model**
   - Scoped custom roles or built-in roles (e.g., Reader, Virtual Machine Contributor)
   - Role assignments follow least-privilege design principles

2. **Azure Policy baseline**
   - Required tags for all resources
   - Deny public IP assignment to VMs
   - Validates compliance automatically in Azure Policy → **Compliance view**

3. **Centralized Monitoring**
   - Dedicated monitoring RG (`rg-azure-migration`)
   - Log Analytics Workspace (`log-analytics-*`)
   - Alert rule: *Percentage CPU > 80%* on `vm-cli-01`

---

## Visual Verification

### Azure Policy Enforcement
![Azure Policy Enforcement](../images/49.verify-policy-enforcement.png)

### Log Analytics Workspace
![Log Analytics Workspace](../images/47.verify-log-analytics-workspace-azure-portal.png)

### VM Diagnostic Settings (Blocked)
![VM Diagnostic Settings Blocked](../images/48.verify-vm-diagnostic-settings.png)

### Alert Rule Verification
![VM Alert Rule](../images/50.verify-vm-alert-rule.png)

---

## Alignment with AZ-305 Objectives

| AZ-305 Objective | How It’s Demonstrated |
|------------------|------------------------|
| **Design Governance** | Azure Policy applied to resource groups, enforcing compliance |
| **Design Identity Solutions** | RBAC model with scoped permissions |
| **Design Monitoring Solutions** | Log Analytics, metrics, and alert rules |

---

## Summary
This completes the **Identity, Governance, and Monitoring** phase of the Azure VM Migration case study.  
These elements ensure your environment is:
- Secure by design  
- Governed by policy  
- Observable and measurable  


