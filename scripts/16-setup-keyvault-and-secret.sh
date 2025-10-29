#!/bin/bash
#
# Purpose:
#   1. Create an Azure Key Vault for application secrets
#   2. Grant ourselves rights to manage secrets (RBAC)
#   3. Store the PostgreSQL connection string as 'DBConnectionString'
#
# Why:
#   We do NOT hardcode database credentials in source code,
#   container images, or 'az container create' commands.
#   Instead, the app reads the connection string from Key Vault at runtime.
#
#

set -euo pipefail

### CONFIGURATION ####################################################

LOCATION="centralus"
RG="rg-container-demo-centralus"

# must be globally unique in Azure; you can override KV_NAME before running
KV_NAME_DEFAULT="kv-container-demo-erhan"
KV_NAME="${KV_NAME:-$KV_NAME_DEFAULT}"

# secret name inside the vault
SECRET_NAME="DBConnectionString"

# database connection info
DB_SERVER_FQDN="demo-db-erhan22318.postgres.database.azure.com"
DB_ADMIN_USER="dbadmin"
DB_ADMIN_PASS="YourStrongPassword123!"
DB_NAME_VALUE="postgres"   # change to 'demoapp' if you created a dedicated DB

DB_CONN="postgresql://${DB_ADMIN_USER}:${DB_ADMIN_PASS}@${DB_SERVER_FQDN}/${DB_NAME_VALUE}?sslmode=require"

######################################################################

echo "[INFO] Registering resource provider 'Microsoft.KeyVault' (idempotent)..."
az provider register --namespace Microsoft.KeyVault >/dev/null 2>&1 || true
az provider show --namespace Microsoft.KeyVault --query "registrationState" -o tsv

echo "[INFO] Creating Key Vault '$KV_NAME' in '$LOCATION'..."
az keyvault create \
  --name "$KV_NAME" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --output jsonc

echo "[INFO] Getting vault resource ID..."
VAULT_ID=$(az keyvault show \
  --name "$KV_NAME" \
  --resource-group "$RG" \
  --query id -o tsv)

echo "[INFO] Getting signed-in user object ID..."
# Try to read the signed-in user's object id. If this fails in some tenants,
# set MY_ID manually to your oid.
if MY_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null); then
  echo "[INFO] Using signed-in user object id: $MY_ID"
else
  echo "[WARN] Could not auto-resolve signed-in user via 'az ad'."
  echo "[WARN] Set MY_ID manually to your AAD object id before continuing."
  echo "Example: MY_ID=\"00000000-0000-0000-0000-000000000000\""
  exit 1
fi

echo "[INFO] Granting 'Key Vault Secrets Officer' role to current user on this vault scope..."
az role assignment create \
  --assignee "$MY_ID" \
  --role "Key Vault Secrets Officer" \
  --scope "$VAULT_ID" \
  --output jsonc

echo "[INFO] Storing DB connection string in Key Vault secret '$SECRET_NAME'..."
az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "$SECRET_NAME" \
  --value "$DB_CONN" \
  --output jsonc

echo "[INFO] Verifying secret retrieval..."
RESULT=$(az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "$SECRET_NAME" \
  --query value -o tsv)

echo ""
echo "------------------------------------------------------------"
echo "[SUCCESS] Key Vault secret created and verified."
echo ""
echo " Key Vault Name     : $KV_NAME"
echo " Resource Group     : $RG"
echo " Region             : $LOCATION"
echo " Secret Name        : $SECRET_NAME"
echo ""
echo " Retrieved secret value (DB connection string):"
echo " $RESULT"
echo ""
echo "NEXT STEPS:"
echo " - In container deployment, inject this value as DB_CONN."
echo "   Example in ACI:"
echo "     --environment-variables DB_CONN=\"\$(az keyvault secret show ... --query value -o tsv)\""
echo ""
echo " - In Step 3 we will lock down PostgreSQL networking (disable public access, add Private Endpoint)."
echo "------------------------------------------------------------"
