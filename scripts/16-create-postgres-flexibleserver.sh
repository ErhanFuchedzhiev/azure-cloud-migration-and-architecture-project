#!/bin/bash
#
# Purpose:
#   Provision Azure Database for PostgreSQL Flexible Server to be used
#   by the containerized Flask application.
#
# What this script does:
#   1. Registers the DB provider (Microsoft.DBforPostgreSQL) if needed
#   2. Creates a resource group in the target region
#   3. Deploys a Burstable (dev/test) PostgreSQL Flexible Server
#   4. Prints a psycopg2 connection string for the app
#
# Notes:
#   - Server names must be globally unique.
#   - This script uses public access '0.0.0.0-0.0.0.0' for bootstrap only.
#     In Step 3 we will lock down networking / disable public access.
#

set -euo pipefail

### CONFIGURATION ####################################################

LOCATION="centralus"
RG="rg-container-demo-centralus"

# admin creds for PostgreSQL (used later by the app)
ADMIN_USER="dbadmin"
ADMIN_PASS="YourStrongPassword123!"

# the server name MUST be unique in Azure. You can override DB_NAME before running.
DB_NAME_DEFAULT="demo-db-erhan$RANDOM"
DB_NAME="${DB_NAME:-$DB_NAME_DEFAULT}"

# sku / sizing for demo purposes
SKU_NAME="Standard_B1ms"   # Burstable, 1 vCore, ~2GB RAM
STORAGE_SIZE_GB=32
PG_VERSION="16"

######################################################################

echo "[INFO] Registering resource provider 'Microsoft.DBforPostgreSQL' (idempotent)..."
az provider register --namespace Microsoft.DBforPostgreSQL >/dev/null 2>&1 || true
az provider show --namespace Microsoft.DBforPostgreSQL --query "registrationState" -o tsv

echo "[INFO] Creating resource group '$RG' in '$LOCATION'..."
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --output table

echo "[INFO] Creating Azure Database for PostgreSQL Flexible Server '$DB_NAME'..."
az postgres flexible-server create \
  --name "$DB_NAME" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --admin-user "$ADMIN_USER" \
  --admin-password "$ADMIN_PASS" \
  --public-access 0.0.0.0-0.0.0.0 \
  --tier Burstable \
  --sku-name "$SKU_NAME" \
  --version "$PG_VERSION" \
  --storage-size "$STORAGE_SIZE_GB" \
  --output jsonc

FQDN=$(az postgres flexible-server show \
  --name "$DB_NAME" \
  --resource-group "$RG" \
  --query fullyQualifiedDomainName -o tsv)

echo ""
echo "------------------------------------------------------------"
echo "[SUCCESS] PostgreSQL Flexible Server created"
echo " Resource Group : $RG"
echo " Server Name    : $DB_NAME"
echo "
