#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
#   Create a custom Azure Policy Definition at the subscription
#   scope that DENIES any deployment missing a required tag.
#
#   The policy created is "require-tag-on-resources".
#
#   After this script succeeds,we will see the policy under:
#   Azure Portal -> Policy -> Definitions -> Type: Custom
#
# Prereqs:
#   - I logged in with 'az login'
#   - i have the correct subscription selected in 'az account show'
#   - The file policy-definition.bicep exists in the same folder as this script
#
# Notes:
#   - This script does NOT assign the policy to any scope. For that, run:
#     08-policy-assignment-create.sh
# -----------------------------------------------------------------------------

##############################################
# CUSTOMIZE ME
##############################################

# Azure region needed by 'az deployment sub create'
LOCATION="eastus"

# Tag key that all resources must have (ex: Environment, CostCenter, Owner)
REQUIRED_TAG_NAME="Environment"

##############################################
# DO NOT EDIT BELOW (unless you know why)
##############################################

# Get subscription ID for visibility
SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

echo "-----------------------------------------------------------------------------"
echo " Azure Policy Definition Deployment"
echo "-----------------------------------------------------------------------------"
echo " Subscription ID : ${SUBSCRIPTION_ID}"
echo " Location        : ${LOCATION}"
echo " Required tag    : ${REQUIRED_TAG_NAME}"
echo " Bicep template  : $(dirname "$0")/policy-definition.bicep"
echo "-----------------------------------------------------------------------------"
echo "⏳ Creating/Updating custom policy definition 'require-tag-on-resources'..."
echo

az deployment sub create \
  --location "${LOCATION}" \
  --template-file "$(dirname "$0")/policy-definition.bicep" \
  --parameters requiredTagName="${REQUIRED_TAG_NAME}"

echo
echo "✅ DONE."
echo "The custom policy definition 'require-tag-on-resources' now exists at the"
echo "subscription scope (${SUBSCRIPTION_ID})."
echo
echo "Next step: assign this policy to a resource group using:"
echo "  ./08-policy-assignment-create.sh"
echo "-----------------------------------------------------------------------------"
