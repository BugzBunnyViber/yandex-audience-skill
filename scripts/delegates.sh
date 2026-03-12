#!/bin/bash
# Manage account delegates (representatives): list, add, delete

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

ACTION="list"
USER_LOGIN=""
PERMISSION=""
COMMENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action|-a)       ACTION="$2"; shift 2 ;;
        --user-login|-u)   USER_LOGIN="$2"; shift 2 ;;
        --permission|-p)   PERMISSION="$2"; shift 2 ;;
        --comment|-c)      COMMENT="$2"; shift 2 ;;
        *)                 echo "Unknown option: $1"; exit 1 ;;
    esac
done

case "$ACTION" in
    list)
        response=$(audience_get "management/delegates")
        if command -v jq &>/dev/null; then
            echo "$response" | jq -r '.delegates[] | "User: \(.user_login) | Perm: \(.perm) | Comment: \(.comment // "-") | Created: \(.created_at)"'
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
        body="{\"delegate\":{\"user_login\":\"$(json_escape "$USER_LOGIN")\",\"perm\":\"$PERMISSION\""
        if [[ -n "$COMMENT" ]]; then
            body="${body},\"comment\":\"$(json_escape "$COMMENT")\""
        fi
        body="${body}}}"
        response=$(audience_put "management/delegate" "$body")
        echo "$response" | format_json
        ;;

    delete)
        if [[ -z "$USER_LOGIN" ]]; then
            echo "Error: --user-login required for delete action"
            exit 1
        fi
        response=$(audience_delete "management/delegate" "user_login=${USER_LOGIN}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        echo "Available: list, add, delete"
        exit 1
        ;;
esac
