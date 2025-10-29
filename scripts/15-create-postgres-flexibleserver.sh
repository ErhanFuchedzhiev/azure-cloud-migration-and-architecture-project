#!/bin/bash
# Purpose:
#   Provision an Azure Database for PostgreSQL Flexible Server to be used
#   by the containerized Flask application.
#
# What this script does:
#   1. Registers the Microsoft.DBforPostgreSQL resource provider (once per subscription)
#   2. Creates a resource group in the desired region
#   3. Creates a Postgres Flexible Server (Burstable tier for dev/test)
#   4. Prints the connection info we will later store in Azure Key Vault
#
# Prereqs:
#   - az CLI is installed and you're logged in: az login
#   - I have access to create resources in the target subscription
#
# Notes:
#   - Server names must be globally unique in the region.
#   - This script uses Central US because some regions are restricted.
#   - Public access is temporarily open for bootstrap/testing.
#     In later steps I will lock this down with Private Endpoint + firewall rules.
#


set -euo pipefail

########## CONFIGURABLE VARIABLES ##########

# Azure region that supports Flexible Server in this subscription
LOCATION="centralus"

# Resource group for database resources
RG="rg-container-demo-centralus"

# Admin credentials for the Postgres server
ADMIN_USER="dbadmin"
ADMIN_PASS="YourStrongPassword123!"

# Postgres server name MUST be unique. We allow overriding from env or generate one.
DB_NAME_DEFAULT="demo-db-erhan$(echo $RANDOM)"
DB_NAME="${DB_NAME:-$DB_NAME_DEFAULT}"

# SKU / sizing (dev/test friendly)
SKU_NAME="Standard_B1ms"   # Burstable, 1 vCore, ~2GB RAM
STORAGE_SIZE_GB=32
PG_VERSION="16"

########## REGISTRATION ##########

echo "[INFO] Registering Microsoft.DBforPostgreSQL resource provider (idempotent)..."
az provider register --namespace Microsoft.DBforPostgreSQL >/dev/null 2>&1 || true
az provider show --namespace Microsoft.DBforPostgreSQL --query "registrationState" -o tsv

########## RESOURCE GROUP ##########

echo "[INFO] Creating resource group '$RG' in '$LOCATION' (safe if it already exists)..."
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --output table

########## POSTGRES FLEXIBLE SERVER ##########

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

########## OUTPUT / NEXT STEPS ##########

FQDN=$(az postgres flexible-server show \
  --name "$DB_NAME" \
  --resource-group "$RG" \
  --query fullyQualifiedDomainName -o tsv)

echo ""
echo "--------------------------------------------"
echo "[SUCCESS] PostgreSQL Flexible Server created"
echo " Resource Group : $RG"
echo " Server Name    : $DB_NAME"
echo " FQDN           : $FQDN"
echo " Admin User     : $ADMIN_USER"
echo " Postgres Ver   : $PG_VERSION"
echo " SKU            : $SKU_NAME"
echo " Storage (GB)   : $STORAGE_SIZE_GB"
echo " Region         : $LOCATION"
echo ""
echo " Connection string (psycopg2 style):"
echo " postgresql://$ADMIN_USER:$ADMIN_PASS@$FQDN/postgres?sslmode=require"
echo ""
echo "NEXT:"
echo " 1) Run 16-create-demoapp-database.sh to create a dedicated 'demoapp' DB."
echo " 2) Store the connection string in Azure Key Vault (Step 2 in the case study)."
echo " 3) Update the Flask container to use that secret at runtime."
echo "--------------------------------------------"
