#!/usr/bin/env bash
set -euo pipefail

# Create the custom policy definition at subscription scope.

LOCATION="eastus"
REQUIRED_TAG_NAME="Environment"

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

echo "Deploying policy definition to subscription ${SUBSCRIPTION_ID}..."
az deployment sub create \
  --location "${LOCATION}" \
  --template-file "$(dirname "$0")/policy-definition.bicep" \
  --parameters requiredTagName="${REQUIRED_TAG_NAME}"
echo "Done."
