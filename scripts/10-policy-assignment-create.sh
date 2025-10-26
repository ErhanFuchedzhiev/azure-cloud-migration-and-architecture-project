#!/usr/bin/env bash
set -euo pipefail

# Assign the policy to a specific resource group and enforce the tag.

RESOURCE_GROUP="vm-cli-rg"
REQUIRED_TAG_NAME="Environment"

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

echo "Assigning policy to resource group ${RESOURCE_GROUP} in ${SUBSCRIPTION_ID}..."
az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file "$(dirname "$0")/policy-assignment.bicep" \
  --parameters requiredTagName="${REQUIRED_TAG_NAME}"
echo "Done."
