# Variables
RESOURCE_GROUP="vm-cli-rg"
LOCATION="eastus2"
NSG_NAME="vm-nsg"
VM_NAME="vm-cli-01"

echo "=============================================="
echo "Step 1: Create a Network Security Group (NSG)"
echo "=============================================="

az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name $NSG_NAME \
  --location $LOCATION

echo "NSG '$NSG_NAME' created successfully."
echo

# ----------------------------------------------------------
echo "=============================================="
echo "Step 2: Create Inbound RDP Rule"
echo "=============================================="

# Automatically detect your public IP
MY_PUBLIC_IP=$(curl -s ifconfig.me)

az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-RDP \
  --priority 1000 \
  --source-address-prefixes $MY_PUBLIC_IP \
  --destination-port-ranges 3389 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound

echo "RDP Rule created successfully for IP: $MY_PUBLIC_IP"
echo

# ----------------------------------------------------------
echo "=============================================="
echo "Step 3: Associate NSG with VM's NIC"
echo "=============================================="

# Get NIC name of the VM dynamically
NIC_NAME=$(az vm show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "networkProfile.networkInterfaces[0].id" -o tsv | awk -F '/' '{print $NF}')

echo " Detected NIC: $NIC_NAME"

# Associate the NSG with the NIC
az network nic update \
  --name $NIC_NAME \
  --resource-group $RESOURCE_GROUP \
  --network-security-group $NSG_NAME

echo " NSG '$NSG_NAME' associated with NIC '$NIC_NAME'."
echo

# ----------------------------------------------------------
echo "=============================================="
echo "Step 4: Verify Effective NSG Rules"
echo "=============================================="

az network nic list-effective-nsg \
  --name $NIC_NAME \
  --resource-group $RESOURCE_GROUP \
  -o json

echo "Verification complete: NSG successfully applied to the VM NIC."
echo
echo "All tasks completed successfully!"
