#!/bin/bash

# Purpose:
# - Deploy the container image from ACR into Azure Container Instances (ACI)
# - Expose it publicly over port 80 with a DNS name
# - Output the public FQDN so you can test in a browser
#
# Prereqs:
# - I already pushed the image to ACR 
# - The image exists at <ACR_LOGIN_SERVER>/azure-demo-app:v1
# - az login works and you're on the correct subscription
#
# After running this script:
# - Browse to http://<FQDN> and you should see the Flask response

set -e

# ===== VARIABLES I CAN EDIT =====
RG="rg-container-demo"
LOCATION="eastus"
ACR_NAME="myacr7406"
ACI_NAME="demo-container"
IMAGE_NAME="azure-demo-app"
IMAGE_TAG="v1"
DNS_LABEL="demo-container-$RANDOM"   # must be globally unique within that region

# ===== LOOKUPS =====
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

IMAGE_FQN="$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"

echo "Region:             $LOCATION"
echo "Image:              $IMAGE_FQN"
echo "DNS label:         $DNS_LABEL"
echo "Resource group:     $RG"
echo "Container name:     $ACI_NAME"
echo

# 1. Create the container instance
echo "Creating Azure Container Instance..."
az container create \
  --resource-group "$RG" \
  --name "$ACI_NAME" \
  --image "$IMAGE_FQN" \
  --cpu 1 \
  --memory 1 \
  --registry-login-server "$ACR_LOGIN_SERVER" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --dns-name-label "$DNS_LABEL" \
  --ports 80 \
  --location "$LOCATION" \
  --restart-policy OnFailure \
  --output none

echo "Container instance created."
echo

# 2. Get the public FQDN
FQDN=$(az container show \
  --resource-group "$RG" \
  --name "$ACI_NAME" \
  --query ipAddress.fqdn \
  -o tsv)

STATE=$(az container show \
  --resource-group "$RG" \
  --name "$ACI_NAME" \
  --query instanceView.state \
  -o tsv)

echo "Public URL:    http://$FQDN"
echo "State:         $STATE"
echo
echo "Open that URL in your browser. You should see your Flask app response."
echo
echo "Done"
