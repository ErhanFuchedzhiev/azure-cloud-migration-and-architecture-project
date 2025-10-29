#!/bin/bash
#
# Purpose:
#   Step 3 of the migration: secure the managed PostgreSQL database.
#
#   - Create an isolated virtual network + subnet
#   - Create a Private Endpoint to the Azure Database for PostgreSQL Flexible Server
#   - Disable public network access on the database
#
#   After this step, the database is no longer exposed to the public internet.
#   Only resources inside the private VNet/subnet can reach it.
#
# Prereqs:
#   - Azure CLI is logged in (az login)
#   - PostgreSQL Flexible Server already exists (from step 1)
#   - Key Vault / secret already configured (from step 2)
#
# Notes:
#   - This script uses real values from the live environment we built:
#       Resource group: rg-container-demo-centralus
#       Region: centralus
#       PostgreSQL server: demo-db-erhan22318
#   - The VNet/subnet are created in this script (demo-vnet / demo-subnet)
#   - The private endpoint will receive a private IP (for example 10.10.1.x)
#   - At the end, public network access is disabled on the DB
#
#

set -euo pipefail

########################################
# Configuration
########################################

# Azure region and resource group
LOCATION="centralus"
RG="rg-container-demo-centralus"

# Existing Azure Database for PostgreSQL Flexible Server
DB_NAME="demo-db-erhan22318"

# Networking resources to create
VNET_NAME="demo-vnet"
SUBNET_NAME="demo-subnet"
VNET_ADDRESS_PREFIX="10.10.0.0/16"
SUBNET_ADDRESS_PREFIX="10.10.1.0/24"

# Private Endpoint names
PE_NAME="demo-db-pe"
PE_CONN_NAME="demo-db-conn"

########################################
# 1. Create a dedicated VNet + Subnet
########################################
echo "[INFO] Creating VNet '$VNET_NAME' and subnet '$SUBNET_NAME' in '$LOCATION'..."

az network vnet create \
  --resource-group "$RG" \
  --name "$VNET_NAME" \
  --location "$LOCATION" \
  --address-prefixes "$VNET_ADDRESS_PREFIX" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefixes "$SUBNET_ADDRESS_PREFIX" \
  --output jsonc

echo "[INFO] VNet and subnet created:"
echo "       VNet : $VNET_NAME ($VNET_ADDRESS_PREFIX)"
echo "       Subnet: $SUBNET_NAME ($SUBNET_ADDRESS_PREFIX)"
echo ""

########################################
# 2. Get the Postgres server resource ID
########################################
echo "[INFO] Fetching PostgreSQL Flexible Server resource ID for '$DB_NAME'..."

DB_RESOURCE_ID=$(az postgres flexible-server show \
  --name "$DB_NAME" \
  --resource-group "$RG" \
  --query id -o tsv)

echo "[INFO] PostgreSQL resource ID:"
echo "       $DB_RESOURCE_ID"
echo ""

########################################
# 3. Create a Private Endpoint to the DB
########################################
echo "[INFO] Creating Private Endpoint '$PE_NAME' for server '$DB_NAME'..."

az network private-endpoint create \
  --resource-group "$RG" \
  --name "$PE_NAME" \
  --location "$LOCATION" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --private-connection-resource-id "$DB_RESOURCE_ID" \
  --group-id "postgresqlServer" \
  --connection-name "$PE_CONN_NAME" \
  --output jsonc

echo "[INFO] Private Endpoint created:"
echo "       Name            : $PE_NAME"
echo "       Connection name : $PE_CONN_NAME"
echo "       VNet/Subnet     : $VNET_NAME / $SUBNET_NAME"
echo "       Status          : should be 'Approved'"
echo ""

########################################
# 4. Disable public network access
########################################
echo "[INFO] Disabling public network access on PostgreSQL server '$DB_NAME'..."

az postgres flexible-server update \
  --name "$DB_NAME" \
  --resource-group "$RG" \
  --public-network-access Disabled

echo ""

########################################
# 5. Final summary
########################################
echo "------------------------------------------------------------"
echo "[SUCCESS] PostgreSQL network access has been secured."
echo ""
echo " Resource Group        : $RG"
echo " Region                : $LOCATION"
echo " PostgreSQL Server     : $DB_NAME"
echo " Virtual Network       : $VNET_NAME"
echo " Subnet                : $SUBNET_NAME"
echo " Private Endpoint      : $PE_NAME"
echo " Public Access         : Disabled"
echo ""
echo "RESULT:"
echo " - The database is no longer reachable over the public internet."
echo " - Traffic to the database now flows through a Private Endpoint"
echo "   with a private IP in $VNET_NAME."
echo ""
echo "NEXT:"
echo " - Any container or compute that needs DB access must run in the"
echo "   same VNet (or a peered VNet)."
echo "------------------------------------------------------------"
