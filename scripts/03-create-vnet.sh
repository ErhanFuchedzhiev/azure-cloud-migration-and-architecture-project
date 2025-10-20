az network vnet create \
  --name vm-network \
  --resource-group vm-cli-rg \
  --location eastus2 \
  --address-prefix 10.0.0.0/16 \
  --subnet-name default \
  --subnet-prefix 10.0.0.0/24
