#!/bin/bash

# Goal:
# - Create a dedicated monitoring resource group
# - Deploy a Log Analytics Workspace (LAW)
# - Attempt to enable VM diagnostic settings to LAW (expected to FAIL because of policy)
# - Show policy assignment for evidence
# - Create a CPU alert rule on the VM
#
# Prereqs:
# - az login already done
# - Existing:
#   * Resource group vm-cli-rg
#   * VM vm-cli-01 in vm-cli-rg
#   * Tag enforcement policy on vm-cli-rg

set -euo pipefail

# Variables
RG="rg-azure-migration"
LOC="westeurope"

VMRG="vm-cli-rg"
VMNAME="vm-cli-01"

LAW="log-analytics-$(openssl rand -hex 2)"

SUB_ID=$(az account show --query id -o tsv)

echo "==> Create resource group for monitoring (${RG})"
az group create \
  -n $RG \
  -l $LOC

echo "==> Create Log Analytics Workspace (${LAW})"
az monitor log-analytics workspace create \
  -g $RG \
  -n $LAW \
  -l $LOC

echo "==> Register Microsoft.Insights provider (if needed)"
az provider register --namespace Microsoft.Insights >/dev/null

echo "==> Attempt to connect VM diagnostic settings to LAW (expected to fail due to policy)"
set +e
az monitor diagnostic-settings create \
  --resource "/subscriptions/${SUB_ID}/resourceGroups/${VMRG}/providers/Microsoft.Compute/virtualMachines/${VMNAME}" \
  --name sendToLAW \
  --workspace $(az monitor log-analytics workspace show -g $RG -n $LAW --query id -o tsv) \
  --metrics '[{"category": "AllMetrics", "enabled": true}]' \
  --logs    '[{"category": "Administrative", "enabled": true}]'
set -e

echo "==> Show policy assignment at vm RG scope (${VMRG})"
az policy assignment list \
  --scope /subscriptions/${SUB_ID}/resourceGroups/${VMRG} \
  -o table

echo "==> Create High CPU alert rule"
az monitor metrics alert create \
  -g $RG \
  -n "HighCPUAlert" \
  --scopes "/subscriptions/${SUB_ID}/resourceGroups/${VMRG}/providers/Microsoft.Compute/virtualMachines/${VMNAME}" \
  --condition "avg Percentage CPU > 80" \
  --description "Alert when CPU > 80%" \
  --severity 2

echo "==> Done."
echo "Log Analytics workspace created in $RG"
echo "Policy enforcement validated on $VMRG"
echo "HighCPUAlert alert rule created for $VMNAME"
