#!/bin/bash
#
# Goal:
#   - Deploy container instance with DB secret from Azure Key Vault
#   - Verify app is reachable and writing to Azure PostgreSQL
#
# Prereqs:
#   - Azure CLI logged in (az login)
#   - Resource group already exists
#   - Azure Container Registry (ACR) already created and populated with image
#   - PostgreSQL Flexible Server already created
#   - Key Vault already created and has secret "DBConnectionString"
#
# Notes:
#   This script follows two main phases:
#     (1) Inject DB connection string from Key Vault into container as env var
#     (2) Validate container is running, reachable, and talking to Postgres
#
#   The container group we deploy in this step is called "demo-container".
#   The container image is "azure-demo-app:v1".
#
#   The script uses eastus for the successful deployment scenario.
#
# Disclaimer:
#   Values like ACR credentials, passwords, and public IPs are environment-specific.
#   Replace placeholders where noted.
#

### ---------------------------------------------------------------------------
### 0. Variables
### ---------------------------------------------------------------------------

# Resource group containing the WORKING container instance
RG="rg-container-demo"

# Azure region where the container will run
LOCATION="eastus"

# Azure Container Registry info (the registry that stores the Flask app image)
ACR_LOGIN_SERVER="myacr7406.azurecr.io"
ACR_USERNAME="<ACR-username>"        # TODO: replace with actual ACR username
ACR_PASSWORD="<ACR-password>"        # TODO: replace with actual ACR password

# Name/tag of the application image in ACR
IMAGE_TAG="azure-demo-app:v1"

# Name of the container group we will run in Azure Container Instances
CONTAINER_NAME="demo-container"

# Azure Key Vault that stores the DB connection string
KEYVAULT_NAME="demo-kv"

# Name of the secret in Key Vault that contains the PostgreSQL connection string
SECRET_NAME="DBConnectionString"


### ---------------------------------------------------------------------------
### 1. Retrieve DB connection string from Key Vault
###    This string includes hostname, username, password, database, sslmode.
###    We DO NOT hardcode it in the script.
### ---------------------------------------------------------------------------

echo "[INFO] Fetching DB connection string from Key Vault: $KEYVAULT_NAME/$SECRET_NAME"

DB_CONN=$(az keyvault secret show \
  --vault-name "$KEYVAULT_NAME" \
  --name "$SECRET_NAME" \
  --query value -o tsv)

echo "[OK] Retrieved connection string from Key Vault."
# NOTE: Do not echo the value in cleartext in real logs.
# echo "$DB_CONN"


### ---------------------------------------------------------------------------
### 2. Deploy container instance to Azure Container Instances
###    - Uses image from ACR
###    - Injects DB_CONN as environment variable so Flask can connect on startup
###    - Exposes port 80 publicly
### ---------------------------------------------------------------------------

echo "[INFO] Creating container instance '$CONTAINER_NAME' in resource group '$RG'..."

az container create \
  --resource-group "$RG" \
  --name "$CONTAINER_NAME" \
  --image "$ACR_LOGIN_SERVER/$IMAGE_TAG" \
  --registry-login-server "$ACR_LOGIN_SERVER" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --environment-variables DB_CONN="$DB_CONN" \
  --ports 80 \
  --os-type Linux \
  --location "$LOCATION"

echo "[OK] Container create command submitted."


### ---------------------------------------------------------------------------
### 3. Inspect container instance status
###    We list container instances and confirm:
###      - Status is 'Succeeded' (or 'Running')
###      - We have a public IP and exposed port
### ---------------------------------------------------------------------------

echo "[INFO] Listing container instances..."
az container list --output table


### ---------------------------------------------------------------------------
### 4. Fetch container runtime logs
###    We expect Flask to be running and listening on 0.0.0.0:80
###    We also expect GET / HTTP/1.1 200 once the endpoint is hit.
### ---------------------------------------------------------------------------

echo "[INFO] Getting container logs for '$CONTAINER_NAME'..."
az container logs \
  --resource-group "$RG" \
  --name "$CONTAINER_NAME"

# Typical successful log sample:
#   Serving Flask app 'app'
#   Running on http://0.0.0.0:80
#   "GET / HTTP/1.1" 200 -
#
# If you see repeated restarts / crashloop, check Key Vault permissions,
# image tag, and environment variables.


### ---------------------------------------------------------------------------
### 5. Get the public IP address of the container
###    We'll curl it to confirm the app is reachable externally.
### ---------------------------------------------------------------------------

APP_IP=$(az container show \
  --resource-group "$RG" \
  --name "$CONTAINER_NAME" \
  --query ipAddress.ip -o tsv)

echo "[INFO] Public IP of container '$CONTAINER_NAME' is: $APP_IP"


### ---------------------------------------------------------------------------
### 6. Validate app response over public IP
###    The Flask app's '/' route:
###      - Creates table 'visits' if it doesn't exist
###      - Inserts "Hello from Azure!" into Postgres
###      - Returns a success message
### ---------------------------------------------------------------------------

echo "[INFO] Calling application endpoint..."
curl "http://$APP_IP/"

# Expected response body:
#   Data inserted successfully into PostgreSQL!
#
# This proves:
#   - Container can reach Azure PostgreSQL Flexible Server
#   - Connection string from Key Vault was injected correctly
#   - App is functional over public IP via Azure Container Instances


### ---------------------------------------------------------------------------
### 7. (Manual / optional) Verify data landed in the database
###    Connect to Postgres (psql / Azure Data Studio) and run:
###
###    SELECT * FROM visits;
###
### Expected:
###    id | message
###   ----+-------------------------
###     1 | Hello from Azure!
###
### This confirms durable storage in cloud Postgres.
### ---------------------------------------------------------------------------

echo "[NEXT] Verify table 'visits' in Postgres contains 'Hello from Azure!'"


### ---------------------------------------------------------------------------
### 8. Portal verification (for screenshots/documentation)
### ---------------------------------------------------------------------------

# 8.1 Azure Portal > Container Instances > demo-container > Overview
#     - Status: Succeeded
#     - Image: myacr7406.azurecr.io/azure-demo-app:v1
#     - IP address: $APP_IP:80
#
# 8.2 Azure Portal > Container Instances > demo-container > Containers > Logs
#     - Shows Flask startup and HTTP 200 responses.
#
# 8.3 Azure Portal > Container Instances > demo-container > Containers > Properties
#     - Shows Environment variables, including DB_CONN (injected secret).
#
# 8.4 Azure Portal > Key Vaults > demo-kv > Secrets > DBConnectionString
#     - Confirms the connection string is stored securely.
#
# 8.5 Azure Portal > PostgreSQL flexible servers > <your-postgres-name> > Overview
#     - Confirms managed DB is running in Azure and accepting connections.


