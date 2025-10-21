#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# RBAC bootstrap for vm-cli-rg
# - Ensures RG exists
# - Ensures three Entra ID (AAD) groups exist: HR, Management, Staff
# - Assigns:
#     HR-Department        -> Contributor on vm-cli-rg
#     Management-Department-> Reader      on SUBSCRIPTION (inherited everywhere)
#     (optional) Staff-Department -> Reader on vm-cli-rg  (enable with --include-staff)
#
# Usage:
#   bash rbac-assign-vm-cli-rg.sh [--rg vm-cli-rg] [--location eastus2] [--include-staff]
#
# Requires: Azure CLI logged in and `az account set` to the correct subscription.
# -----------------------------------------------------------------------------

set -euo pipefail

# -------- Defaults (override via flags) ---------------------------------------
RG_NAME="vm-cli-rg"
LOCATION="eastus2"
INCLUDE_STAFF=false

# Group display names (change if you prefer different names)
HR_GROUP_NAME="HR-Department"
MGMT_GROUP_NAME="Management-Department"
STAFF_GROUP_NAME="Staff-Department"

# Built-in role IDs (stable GUIDs)
ROLE_READER_ID="acdd72a7-3385-48ef-bd42-f606fba81ae7"
ROLE_CONTRIB_ID="b24988ac-6180-42a0-ab88-20f7382dd24c"

# -------- Parse flags ---------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --rg) RG_NAME="${2:-}"; shift 2 ;;
    --location) LOCATION="${2:-}"; shift 2 ;;
    --include-staff) INCLUDE_STAFF=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--rg vm-cli-rg] [--location eastus2] [--include-staff]"
      exit 0
      ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

# -------- Helpers -------------------------------------------------------------
say()  { printf "\n\033[1;36m%s\033[0m\n" "$*"; }
ok()   { printf "\033[0;32m✓ %s\033[0m\n" "$*"; }
warn() { printf "\033[0;33m! %s\033[0m\n" "$*"; }
die()  { printf "\033[0;31m✗ %s\033[0m\n" "$*"; exit 1; }

need_cli() { command -v az >/dev/null 2>&1 || die "Azure CLI (az) is required."; }

get_or_create_group() {
  local display_name="$1"
  local mail_nickname="${display_name//@/_}" # simple nickname
  local id
  if id=$(az ad group show --group "$display_name" --query id -o tsv 2>/dev/null); then
    echo "$id"; return 0
  fi
  say "Creating Entra ID group: $display_name"
  az ad group create --display-name "$display_name" --mail-nickname "$mail_nickname" >/dev/null
  id=$(az ad group show --group "$display_name" --query id -o tsv)
  echo "$id"
}

assign_role() {
  local principal_id="$1"
  local principal_type="$2"   # Group | User | ServicePrincipal
  local role_id="$3"
  local scope="$4"
  # deterministic GUID for idempotency (scope+principal+role)
  local name
  name=$(python3 - <<PY
import uuid, sys
print(str(uuid.uuid5(uuid.NAMESPACE_URL, f"{sys.argv[1]}|{sys.argv[2]}|{sys.argv[3]}")))
PY
"$scope" "$principal_id" "$role_id")

  # Check if exists
  if az role assignment list --scope "$scope" --query "[?id=='$scope/providers/Microsoft.Authorization/roleAssignments/$name']" -o tsv | grep -q "$name"; then
    ok "Role already assigned at scope: $scope"
    return 0
  fi

  az role assignment create \
    --assignee-object-id "$principal_id" \
    --assignee-principal-type "$principal_type" \
    --role "$role_id" \
    --scope "$scope" \
    --name "$name" >/dev/null

  ok "Assigned role at scope: $scope"
}

# -------- Main ----------------------------------------------------------------
need_cli

SUBSCRIPTION_ID=$(az account show --query id -o tsv) || die "Not logged in. Run 'az login'."
SCOPE_SUB="/subscriptions/$SUBSCRIPTION_ID"
SCOPE_RG="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME"

say "Using subscription: $SUBSCRIPTION_ID"
say "Target Resource Group: $RG_NAME ($LOCATION)"

# Ensure RG exists
if az group show -n "$RG_NAME" >/dev/null 2>&1; then
  ok "Resource group exists: $RG_NAME"
else
  say "Creating resource group: $RG_NAME"
  az group create -n "$RG_NAME" -l "$LOCATION" >/dev/null
  ok "Created resource group: $RG_NAME"
fi

# Ensure groups exist
HR_GROUP_ID=$(get_or_create_group "$HR_GROUP_NAME")
MGMT_GROUP_ID=$(get_or_create_group "$MGMT_GROUP_NAME")
if $INCLUDE_STAFF; then
  STAFF_GROUP_ID=$(get_or_create_group "$STAFF_GROUP_NAME")
fi

say "Group IDs:
  HR:    $HR_GROUP_ID
  MGMT:  $MGMT_GROUP_ID
  STAFF: ${STAFF_GROUP_ID:-(skipped)}"

# Assign roles
say "Assigning roles…"
assign_role "$HR_GROUP_ID"   "Group" "$ROLE_CONTRIB_ID" "$SCOPE_RG"
assign_role "$MGMT_GROUP_ID" "Group" "$ROLE_READER_ID"  "$SCOPE_SUB"
if $INCLUDE_STAFF; then
  assign_role "$STAFF_GROUP_ID" "Group" "$ROLE_READER_ID" "$SCOPE_RG"
fi

# Verification
say "Verification: assignments for vm-cli-rg"
az role assignment list --scope "$SCOPE_RG" -o table

say "Verification: Management group at subscription"
az role assignment list --scope "$SCOPE_SUB" \
  --query "[?principalId=='$MGMT_GROUP_ID'].[principalName,roleDefinitionName,scope]" -o table

if $INCLUDE_STAFF; then
  say "Verification: Staff group on vm-cli-rg"
  az role assignment list --scope "$SCOPE_RG" \
    --query "[?principalId=='$STAFF_GROUP_ID'].[principalName,roleDefinitionName,scope]" -o table
fi

ok "RBAC setup complete."
