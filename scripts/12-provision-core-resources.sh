#!/bin/bash

# Purpose:
# - Create a resource group
# - Create an Azure Container Registry (ACR)
# - Output the registry login server
#
# Prereqs:
# - I must be logged in: az login
# - I must have permission to create resources in the target subscription

set -e

# ===== VARIABLES YOU CAN EDIT =====
RG="rg-container-demo"
LOCATION="eastus"
ACR_NAME="myacr$RANDOM"   # must be globally unique and all lowercase

echo "🔧 Using resource group:        $RG"
echo "🌎 Azure region:               $LOCATION"
echo "📦 Container registry name:    $ACR_NAME"
echo

# 1. Create resource group (safe if it already exists)
echo "➤ Creating resource group..."
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --output none
echo "✅ Resource group ready."
echo

# 2. Create Azure Container Registry (Basic = cheapest tier)
echo "➤ Creating Azure Container Registry ($ACR_NAME)..."
az acr create \
  --resource-group "$RG" \
  --name "$ACR_NAME" \
  --sku Basic \
  --output none
echo "✅ ACR created."
echo

# 3. Enable admin access on the registry (so docker can push with username/password)
echo "➤ Enabling admin user on the registry..."
az acr update \
  --name "$ACR_NAME" \
  --admin-enabled true \
  --output none
echo "✅ Admin user enabled."
echo

# 4. Show connection info
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)

echo "Registry login server:  $ACR_LOGIN_SERVER"
echo "Registry username:      $ACR_USERNAME"
echo
echo "Save these values. You'll need them in script 02-build-and-push-image.sh"
echo
echo "Done "
