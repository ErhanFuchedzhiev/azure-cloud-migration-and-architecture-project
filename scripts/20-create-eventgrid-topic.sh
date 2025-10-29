#!/bin/bash
# Purpose:
# Provision an Event Grid Topic for VM -> Azure integration events
# This is part of the "Application Integration & Eventing" architecture.
# It lets migrated VMs publish "FileReady" or "JobCompleted" signals into Azure.

set -euo pipefail

# -----------------------------
# Config 
# -----------------------------
RG_NAME="rg-az305-migration"
LOCATION="eastus"
TOPIC_NAME="vm-events-demo"

echo "[+] Creating resource group: ${RG_NAME} (${LOCATION})"
az group create \
  --name "${RG_NAME}" \
  --location "${LOCATION}" \
  --output none

echo "[+] Creating Event Grid custom topic: ${TOPIC_NAME}"
az eventgrid topic create \
  --name "${TOPIC_NAME}" \
  --resource-group "${RG_NAME}" \
  --location "${LOCATION}" \
  --output none

echo "[+] Fetching topic endpoint and key"
TOPIC_ENDPOINT=$(az eventgrid topic show \
  --name "${TOPIC_NAME}" \
  --resource-group "${RG_NAME}" \
  --query "endpoint" \
  --output tsv)

TOPIC_KEY=$(az eventgrid topic key list \
  --name "${TOPIC_NAME}" \
  --resource-group "${RG_NAME}" \
  --query "key1" \
  --output tsv)

echo ""
echo "=== Event Grid Topic Provisioned =========================="
echo " Resource Group : ${RG_NAME}"
echo " Topic Name     : ${TOPIC_NAME}"
echo " Location       : ${LOCATION}"
echo " Endpoint       : ${TOPIC_ENDPOINT}"
echo " Key (key1)     : ${TOPIC_KEY}"
echo "==========================================================="
echo ""
echo "Store the endpoint and key securely. They will be needed to publish events."
echo "Example publisher script: 19-publish-fileReady-event.sh"
