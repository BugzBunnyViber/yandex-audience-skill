#!/bin/bash
# Verify Yandex Audience API connection and list segments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

echo "Checking Yandex Audience API connection..."
echo ""

response=$(audience_get "management/segments" "limit=5")

# Check for errors
if echo "$response" | grep -q '"errors"'; then
    echo "Connection FAILED"
    echo ""
    echo "$response" | format_json
    exit 1
fi

# Check for segments
if echo "$response" | grep -q '"segments"'; then
    echo "Connection OK"
    echo ""

    if command -v jq &>/dev/null; then
        total=$(echo "$response" | jq '.segments | length')
        echo "Found segments (showing up to 5):"
        echo ""
        echo "$response" | jq -r '.segments[] | "  ID: \(.id) | Name: \(.name) | Type: \(.type) | Status: \(.status)"'
    else
        echo "Response:"
        echo "$response" | format_json
    fi
else
    echo "Unexpected response:"
    echo "$response" | format_json
    exit 1
fi
