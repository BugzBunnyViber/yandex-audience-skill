#!/bin/bash
# List accounts where current user is a representative

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

response=$(audience_get "management/accounts")

if command -v jq &>/dev/null; then
    echo "$response" | jq -r '.accounts[] | "User: \(.user_login) | Perm: \(.perm) | Created: \(.created_at)"'
else
    echo "$response" | format_json
fi
