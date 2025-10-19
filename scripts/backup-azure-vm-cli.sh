#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Azure VM Backup Automation Script
# ==========================================

# Variables
RG="vm-cli-rg"
LOC="eastus2"
VAULT="vm-backup-vault"
VM="vm-cli-01"
POLICY="DefaultPolicy"

echo "Starting Azure VM Backup Configuration..."
echo "=========================================="

# 1. Create Backup Vault
echo "Creating backup vault: $VAULT"
az dataprotection vault create \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  --location "$LOC" \
  --storage-setting datastore-type=VaultStore redundancy=LocallyRedundant \
  -o table

# 2. List available policies
echo "Fetching available backup policies..."
az dataprotection backup-policy list \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  -o table

# 3. Enable backup for the VM
echo "Enabling backup for VM: $VM"
az dataprotection backup-instance create \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  --name "vm-backup-instance" \
  --datasource-type AzureDisk \
  --policy-name "$POLICY" \
  --source-resource-id $(az vm show -g "$RG" -n "$VM" --query id -o tsv) \
  -o table

# 4. Trigger an on-demand backup
echo "Triggering initial backup..."
az dataprotection backup-instance adhoc-backup \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  --backup-instance-name "vm-backup-instance" \
  --rule-name "Default" \
  -o table

# 5. Verify backup status
echo "Verifying backup instance..."
az dataprotection backup-instance list \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  -o table

echo "=========================================="
echo "Azure VM backup configuration completed successfully!"
