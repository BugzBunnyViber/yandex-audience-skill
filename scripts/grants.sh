#!/bin/bash
# Manage segment permissions (grants): list, add, delete

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

ACTION="list"
SEGMENT_ID=""
USER_LOGIN=""
PERMISSION=""
COMMENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action|-a)       ACTION="$2"; shift 2 ;;
        --segment-id|-s)   SEGMENT_ID="$2"; shift 2 ;;
        --user-login|-u)   USER_LOGIN="$2"; shift 2 ;;
        --permission|-p)   PERMISSION="$2"; shift 2 ;;
        --comment|-c)      COMMENT="$2"; shift 2 ;;
        *)                 echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$SEGMENT_ID" ]]; then
    echo "Error: --segment-id required"
    exit 1
fi

case "$ACTION" in
    list)
        response=$(audience_get "management/segment/${SEGMENT_ID}/grants")
        if command -v jq &>/dev/null; then
            echo "$response" | jq -r '.grants[] | "User: \(.user_login) | Permission: \(.permission) | Comment: \(.comment // "-") | Created: \(.created_at)"'
        else
            echo "$response" | format_json
        fi
        ;;

    add)
        if [[ -z "$USER_LOGIN" || -z "$PERMISSION" ]]; then
            echo "Error: --user-login and --permission required for add action"
            echo "  --permission: edit or view"
            exit 1
        fi
        body="{\"grant\":{\"user_login\":\"$(json_escape "$USER_LOGIN")\",\"permission\":\"$PERMISSION\""
        if [[ -n "$COMMENT" ]]; then
            body="${body},\"comment\":\"$(json_escape "$COMMENT")\""
        fi
        body="${body}}}"
        response=$(audience_put "management/segment/${SEGMENT_ID}/grant" "$body")
        echo "$response" | format_json
        ;;

    delete)
        if [[ -z "$USER_LOGIN" ]]; then
            echo "Error: --user-login required for delete action"
            exit 1
        fi
        response=$(audience_delete "management/segment/${SEGMENT_ID}/grant" "user_login=${USER_LOGIN}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        echo "Available: list, add, delete"
        exit 1
        ;;
esac
