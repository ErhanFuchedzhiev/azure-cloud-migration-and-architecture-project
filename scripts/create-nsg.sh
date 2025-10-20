Create a Network Security Group (NSG)
# This NSG will control inbound and outbound traffic to mine virtual machine.

# Create the NSG
az network nsg create \
  --resource-group vm-cli-rg \
  --name vm-nsg \
  --location eastus2

# Add inbound RDP rule (allow RDP only from your public IP)
# Automatically detect your public IP
MY_PUBLIC_IP=$(curl -s ifconfig.me)

az network nsg rule create \
  --resource-group vm-cli-rg \
  --nsg-name vm-nsg \
  --name Allow-RDP \
  --priority 1000 \
  --source-address-prefixes $MY_PUBLIC_IP \
  --destination-port-ranges 3389 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound

# Verify NSG and rules
az network nsg rule list \
  --resource-group vm-cli-rg \
  --nsg-name vm-nsg \
  --output table
