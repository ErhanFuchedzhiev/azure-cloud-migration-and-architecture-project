#!/bin/bash

# Purpose:
# - Build the local Docker image for the Flask app
# - Tag it for ACR
# - Log in to ACR
# - Push the image to ACR
#
# Prereqs:
# - Docker is running locally
# - I ran 01-provision-core-resources.sh and noted:
#     ACR_LOGIN_SERVER
#     ACR_USERNAME
#     ACR password (from az acr credential show)
# - app.py and Dockerfile are in the current working directory

set -e

# ===== VARIABLES I MUST SET =====
RG="rg-container-demo"
ACR_NAME="myacr7406"  # <-- replace with the ACR you actually created
IMAGE_NAME="azure-demo-app"
IMAGE_TAG="v1"

# Look up dynamic values from Azure
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

echo "Target registry:     $ACR_LOGIN_SERVER"
echo "Image (local):       $IMAGE_NAME:$IMAGE_TAG"
echo "Image (remote tag):  $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"
echo

# 1. Build the Docker image locally
echo "Building local image..."
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
echo "Local image built."
echo

# 2. Tag the image for your private registry
echo "Tagging image for ACR..."
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"
echo "Image tagged as $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"
echo

# 3. Log in to ACR so we can push
echo "Logging in to ACR via docker..."
echo "$ACR_PASSWORD" | docker login "$ACR_LOGIN_SERVER" -u "$ACR_USERNAME" --password-stdin
echo "Docker is authenticated to ACR."
echo

# 4. Push the tagged image
echo "Pushing image to ACR..."
docker push "$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG"
echo "Image pushed to ACR."
echo

# 5. Show repositories in ACR
echo "Verifying image exists in ACR..."
az acr repository show-tags \
  --name "$ACR_NAME" \
  --repository "$IMAGE_NAME" \
  --output table

echo
echo "Done My image is now in Azure Container Registry."
