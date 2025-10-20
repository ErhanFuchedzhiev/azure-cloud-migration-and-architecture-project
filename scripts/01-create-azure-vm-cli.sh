#!/usr/bin/env bash
set -euo pipefail

# ========= Variables you can tweak =========
RG="vm-cli-rg"
LOC="eastus2"
VMNAME="vm-cli-01"
VNET="vm-cli-vnet"
SUBNET="default"
NSG="vm-cli-nsg"
PIP="vm-cli-ip"
NIC="vm-cli-nic"
ADDR_PREFIX="10.10.0.0/16"
SUBNET_PREFIX="10.10.1.0/24"
SIZE="Standard_B1s"
ADMIN="azureuser"
# Windows Server 2022 Datacenter (Azure Edition, Gen2)
IMAGE="MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest"
# ===========================================

echo "Getting your public IP to scope the RDP rule..."
MYIP="$(curl -s ifconfig.me || echo 0.0.0.0)"
if [[ "$MYIP" == "0.0.0.0" || -z "$MYIP" ]]; then
  echo "Could not determine your IP. The RDP rule will allow from anywhere (not recommended)."
  SRC_PREFIX="*"
else
  SRC_PREFIX="${MYIP}/32"
  echo "Will allow RDP from: ${SRC_PREFIX}"
fi

# Prompt for a strong admin password (Windows complexity rules apply)
read -s -p "Enter a strong password for '${ADMIN}': " ADMINPW; echo

echo "Creating resource group..."
az group create -n "$RG" -l "$LOC" -o table

echo "Creating virtual network & subnet..."
az network vnet create \
  -g "$RG" -n "$VNET" \
  --address-prefix "$ADDR_PREFIX" \
  --subnet-name "$SUBNET" --subnet-prefix "$SUBNET_PREFIX" -o table

echo "Creating NSG and RDP rule..."
az network nsg create -g "$RG" -n "$NSG" -o table
az network nsg rule create \
  -g "$RG" --nsg-name "$NSG" -n allow-rdp \
  --priority 1000 --protocol Tcp --access Allow \
  --source-address-prefixes "$SRC_PREFIX" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 3389 \
  --description "Allow RDP from my IP" -o table

echo "Creating public IP (Standard SKU)..."
az network public-ip create -g "$RG" -n "$PIP" --sku Standard -o table

echo "Creating NIC and attaching NSG + Public IP..."
az network nic create \
  -g "$RG" -n "$NIC" \
  --vnet-name "$VNET" --subnet "$SUBNET" \
  --network-security-group "$NSG" \
  --public-ip-address "$PIP" -o table

echo "Creating Windows VM..."
az vm create \
  -g "$RG" -n "$VMNAME" \
  --image "$IMAGE" \
  --size "$SIZE" \
  --admin-username "$ADMIN" \
  --admin-password "$ADMINPW" \
  --nics "$NIC" \
  --os-disk-name "${VMNAME}-osdisk" \
  --public-ip-sku Standard \
  --license-type Windows_Server \
  -o table

echo "Optional: enable boot diagnostics (uses managed storage by default in most regions)"
# Uncomment the line below if you want explicit boot diagnostics with a storage account you own:
# az vm boot-diagnostics enable -g "$RG" -n "$VMNAME" --storage "<YourStorageAccountName>"

echo "Fetching connection info..."
PUBLIC_IP="$(az vm show -d -g "$RG" -n "$VMNAME" --query publicIps -o tsv)"
echo ""
echo "================== Connection details =================="
echo "VM name:     $VMNAME"
echo "Username:    $ADMIN"
echo "Public IP:   $PUBLIC_IP"
echo "RDP:         ${PUBLIC_IP}:3389 (allowed from ${SRC_PREFIX})"
echo "========================================================"
echo ""
echo "Cleanup when done:"
echo "  az group delete -n $RG --yes --no-wait"
