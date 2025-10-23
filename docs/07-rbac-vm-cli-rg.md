# RBAC & Least Privilege Setup for vm-cli-rg

## Objective
This demonstrates how to apply **Azure Role-Based Access Control (RBAC)** using the **least privilege principle** for different departments within the organization — aligned with **AZ-305 (Design Identity, Governance, and Monitoring)**.

I automate the configuration using a custom script to:
- Create or verify Azure AD (Entra ID) groups for HR, Management, and Staff.
- Assign each department the correct role with minimum required permissions.
- Validate the assignments via CLI and Azure Portal.

---

## Departments and Roles

| Department | Role | Scope | Description |
|-------------|------|--------|--------------|
| **HR-Department** | Contributor | Resource Group `vm-cli-rg` | Can manage resources, but not assign permissions. |
| **Management-Department** | Reader | Subscription | Read-only access across the subscription. |
| **Staff-Department** | Reader | Resource Group `vm-cli-rg` | View-only access for specific workloads. |

This structure ensures access aligns with job functions.

---

The script automates:
1. Verification or creation of the resource group (`vm-cli-rg`).
2. Creation of Entra ID groups if missing.
3. Assignment of roles:
   - HR → Contributor  
   - Management → Reader  
   - Staff → Reader (optional)
4. Verification with tabular output.

Run it from **Azure Cloud Shell** 

```bash
bash scripts/06-rbac-assign-vm-cli-rg.sh --include-staff
```

✓ Resource group exists: vm-cli-rg
✓ HR-Department assigned Contributor role
✓ Management-Department assigned Reader role
✓ Staff-Department assigned Reader role

Portal Verification

## Navigate to:

Resource groups → vm-cli-rg → Access control (IAM) → Role assignments

| Principal             | Type  | Role        | Scope                    |
| --------------------- | ----- | ----------- | ------------------------ |
| HR-Department         | Group | Contributor | This resource            |
| Management-Department | Group | Reader      | Subscription (Inherited) |
| Staff-Department      | Group | Reader      | This resource            |

Example portal view:

CLI Verification

```bash

SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# List all roles for the resource group
az role assignment list \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/vm-cli-rg" \
  -o table

# Check Reader role at subscription
az role assignment list \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --query "[?roleDefinitionName=='Reader'].[principalName,scope]" -o table
```

## Outcome

- After running the automation:
- RBAC assignments are consistent across environments.
- The least privilege principle is enforced automatically.
- The configuration aligns with Azure governance and access control best practices.

