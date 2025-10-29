#!/bin/bash
#
# Purpose:
# - Build a Flask container that writes to Azure Database for PostgreSQL
# - Push that image to Azure Container Registry (ACR)
# - Retrieve DB connection string securely from Azure Key Vault
# - Deploy the container to Azure Container Instances (ACI)
# - Expose it publicly and verify it inserts data into the DB
#
# This demonstrates:
#   * App modernization (containerized Flask app)
#   * Secure secret handling (Key Vault, not hardcoded env vars)
#   * Managed data plane (Azure Database for PostgreSQL Flexible Server)
#   * Serverless compute plane (ACI pulling from private ACR)

# -------------------------------------------------------
# Prereqs (already completed in earlier steps):
#
# 1. ACR exists and admin enabled:
#    myacr7406.azurecr.io   (resource group: rg-container-demo-centralus)
#
# 2. PostgreSQL Flexible Server deployed:
#    demo-db-erhan22318     (resource group: rg-container-demo-centralus)
#    with admin user "dbadmin"
#
# 3. Key Vault created and DB connection string stored as secret:
#    Vault name: kv-container-demo-erhan
#    Secret name: DBConnectionString
#
# 4. VNet/private endpoint configured for Postgres (see 17-secure-postgres-network.sh)
#
# 5. Local files in flask-db-app/ :
#    - app.py
#    - requirements.txt
#    - Dockerfile
#
#    Example app.py:
#
#    from flask import Flask
#    import os, psycopg2, psycopg2.extras
#
#    app = Flask(__name__)
#
#    # connection string will be injected at runtime from env var DB_CONN
#    DB_CONN = os.getenv("DB_CONN")
#
#    @app.route("/")
#    def home():
#        conn = psycopg2.connect(DB_CONN)
#        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
#
#        # ensure table exists
#        cur.execute("""
#            CREATE TABLE IF NOT EXISTS visits (
#                id serial PRIMARY KEY,
#                message text,
#                created_at timestamp default now()
#            );
#        """)
#
#        # insert row
#        cur.execute("""
#            INSERT INTO visits (message)
#            VALUES ('Hello from Azure!')
#            RETURNING id, message, created_at;
#        """)
#
#        row = cur.fetchone()
#        conn.commit()
#
#        cur.close()
#        conn.close()
#
#        return f"Insert OK — id={row['id']}, message='{row['message']}', created_at={row['created_at']}"
#
#
#    if __name__ == "__main__":
#        app.run(host="0.0.0.0", port=80)
#
#
#    Example requirements.txt:
#       flask
#       psycopg2-binary
#
#
#    Example Dockerfile:
#
#    FROM python:3.11-slim
#
#    ENV PYTHONDONTWRITEBYTECODE=1
#    ENV PYTHONUNBUFFERED=1
#
#    WORKDIR /app
#
#    # install system deps for psycopg2 (PostgreSQL client libs, build tools)
#    RUN apt-get update && apt-get install -y --no-install-recommends \
#        gcc \
#        libpq-dev \
#        && rm -rf /var/lib/apt/lists/*
#
#    COPY requirements.txt .
#    RUN pip install --no-cache-dir -r requirements.txt
#
#    COPY app.py .
#
#    ENV FLASK_APP=app.py
#    ENV FLASK_RUN_HOST=0.0.0.0
#    ENV FLASK_RUN_PORT=80
#
#    EXPOSE 80
#
#    CMD ["flask", "run"]
#
# -------------------------------------------------------
# STEP 1: Log in to Azure and ACR from local machine
# -------------------------------------------------------

# NOTE: Run these from local PowerShell / bash BEFORE executing the rest:
# az login --use-device-code
# az account set --subscription "Azure subscription 1"

# ACR info (already created in previous steps)
ACR_NAME="myacr7406"
ACR_LOGIN_SERVER="myacr7406.azurecr.io"

# Tag we will publish
IMAGE_TAG="$ACR_LOGIN_SERVER/azure-demo-app:v2"

echo "[INFO] Logging in to ACR..."
az acr login --name $ACR_NAME

# -------------------------------------------------------
# STEP 2: Build the Docker image locally
# -------------------------------------------------------
# Must be run from inside the flask-db-app/ folder where Dockerfile lives.

echo "[INFO] Building Docker image locally..."
docker build -t $IMAGE_TAG .

# Screenshot:
#  - Capture successful docker build output (layers pulled, pip install, 'exporting to image', 'naming to ... v2')

# -------------------------------------------------------
# STEP 3: Push the image to ACR
# -------------------------------------------------------

echo "[INFO] Pushing image to ACR..."
docker push $IMAGE_TAG

# Screenshot:
#  - Capture docker push output (layer uploaded, digest sha256:..., size ...)

# Optional sanity check: list repos in ACR
echo "[INFO] Listing repos in ACR..."
az acr repository list --name $ACR_NAME -o table
# Should include "azure-demo-app"

# -------------------------------------------------------
# STEP 4: Pull DB connection string securely from Key Vault
# -------------------------------------------------------

RG="rg-container-demo-centralus"
LOCATION="centralus"

KV_NAME="kv-container-demo-erhan"
SECRET_NAME="DBConnectionString"

echo "[INFO] Retrieving DB connection string from Key Vault..."
DB_CONN_VALUE=$(az keyvault secret show \
  --vault-name $KV_NAME \
  --name $SECRET_NAME \
  --query value -o tsv)

echo "[INFO] DB_CONN_VALUE (redacted for screenshot):"
echo "$DB_CONN_VALUE" | sed 's/YourStrongPassword123!/********/'

# Screenshot:
#  - Capture proof that we can read the secret (do NOT expose full password in public repo)

# -------------------------------------------------------
# STEP 5: Deploy container to Azure Container Instances (ACI)
# -------------------------------------------------------
# ACI will:
#   * pull the image from our private ACR
#   * receive DB_CONN as an environment variable
#   * expose port 80 publicly
#
# We explicitly set cpu/memory and os-type Linux.

CONTAINER_NAME="demo-container-db"

echo "[INFO] Getting ACR credentials for ACI pull..."
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

echo "[INFO] Creating container instance in Azure..."
az container create \
  --resource-group $RG \
  --name $CONTAINER_NAME \
  --image $IMAGE_TAG \
  --location $LOCATION \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --environment-variables DB_CONN="$DB_CONN_VALUE" \
  --ports 80 \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5

#  - Capture successful az container create output (JSON or summary)
#  - This proves the container was accepted by Azure

# -------------------------------------------------------
# STEP 6: Get the public IP and test the live app
# -------------------------------------------------------

echo "[INFO] Fetching public IP for container..."
PUBLIC_IP=$(az container show \
  --resource-group $RG \
  --name $CONTAINER_NAME \
  --query ipAddress.ip -o tsv)

echo "[INFO] Container Public IP: $PUBLIC_IP"

#  - Capture PowerShell/terminal output of the IP

echo "[INFO] Test in browser:"
echo "Open: http://$PUBLIC_IP/"

# Expected result in browser:
#   Insert OK — id=1, message='Hello from Azure!', created_at=2025-10-29 13:42:18.123456
#
# That response confirms:
#   * The Flask container is running in Azure
#   * It pulled the image from ACR
#   * It connected to Azure Database for PostgreSQL Flexible Server
#   * It created the 'visits' table if missing
#   * It inserted a new row ('Hello from Azure!')
#   * It read the DB connection string from Key Vault, NOT from hardcoded secrets

# -------------------------------------------------------
# STEP 7: Operational verification
# -------------------------------------------------------

echo "[INFO] Checking container runtime state..."
az container show \
  --resource-group $RG \
  --name $CONTAINER_NAME \
  --query "instanceView.state" -o tsv
# Should return "Running"

echo "[INFO] Fetching container logs..."
az container logs \
  --resource-group $RG \
  --name $CONTAINER_NAME

#  - Capture container logs: should show Flask starting and handling a request
#  - This is proof for audit / case study write-up

# -------------------------------------------------------
# Wrap-up
# -------------------------------------------------------
# At this point I have:
#   1. A containerized Python/Flask web app
#   2. Pushed to a private Azure Container Registry
#   3. Deployed in Azure via ACI
#   4. Secure DB connection string coming from Azure Key Vault
#   5. Inserting data into a managed PostgreSQL Flexible Server
#
# This demonstrates cloud-native modernization:
#   - no VM management
#   - no hardcoded secrets
#   - managed database + private networking
#   - ephemeral compute, repeatable deployment

echo "[DONE] App is deployed to Azure Container Instances with secure DB access."
