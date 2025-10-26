#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
#   Assign the custom policy definition 'require-tag-on-resources' to a specific
#   resource group. The assignment ("enforce-required-tag") DENIES deployments
#   that do not include the required tag key.
#
#   After this script succeeds, I will see the assignment under:
#   - Azure Portal -> Policy -> Definitions -> (your custom policy) -> Assignments
#   - Azure Portal -> Resource groups -> <RG> -> Policies
#
# Prereqs:
#   - I already ran 07-policy-definition-create.sh (policy must exist)
#   - I am logged in with 'az login'
#   - I have the right subscription set in 'az account show'
#   - The file policy-assignment.bicep exists in the same folder as this script
#
# Validation:
#   I can verify after running this script:
#     az policy assignment list \
#       --scope /subscriptions/<SUB_ID>/resourceGroups/<RESOURCE_GROUP> \
#       -o table
#
#     I should see 'enforce-required-tag'
# -----------------------------------------------------------------------------

##############################################
# CUSTOMIZE ME
##############################################

# Resource group to protect with the policy
RESOURCE_GROUP="vm-cli-rg"

# Tag key that must exist on every resource in that RG
REQUIRED_TAG_NAME="Environment"

##############################################
# DO NOT EDIT BELOW (unless you know why)
##############################################

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

echo "-----------------------------------------------------------------------------"
echo "🛡  Azure Policy Assignment Deployment"
echo "-----------------------------------------------------------------------------"
echo " Subscription ID : ${SUBSCRIPTION_ID}"
echo " Resource Group  : ${RESOURCE_GROUP}"
echo " Required tag    : ${REQUIRED_TAG_NAME}"
echo " Bicep template  : $(dirname "$0")/policy-assignment.bicep"
echo "-----------------------------------------------------------------------------"
echo "⏳ Assigning policy 'require-tag-on-resources' to resource group '${RESOURCE_GROUP}'..."
echo

az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file "$(dirname "$0")/policy-assignment.bicep" \
  --parameters requiredTagName="${REQUIRED_TAG_NAME}"

echo
echo " DONE."
echo "The policy assignment 'enforce-required-tag' is now active on RG '${RESOURCE_GROUP}'."
echo
echo "Test it by trying to deploy any resource into '${RESOURCE_GROUP}' WITHOUT the"
echo "'${REQUIRED_TAG_NAME}' tag. Azure should block it with RequestDisallowedByPolicy."
echo
echo "You can also verify via:"
echo "  az policy assignment list --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP} -o table"
echo "-----------------------------------------------------------------------------"
