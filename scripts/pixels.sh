#!/bin/bash
# Manage Yandex Audience pixels: list, create, edit, delete, undelete

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

ACTION="list"
PIXEL_ID=""
NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action|-a)   ACTION="$2"; shift 2 ;;
        --id|-i)       PIXEL_ID="$2"; shift 2 ;;
        --name|-n)     NAME="$2"; shift 2 ;;
        *)             echo "Unknown option: $1"; exit 1 ;;
    esac
done

case "$ACTION" in
    list)
        response=$(audience_get "management/pixels")
        if command -v jq &>/dev/null; then
            echo "$response" | jq -r '.pixels[] | "ID: \(.id) | \(.name) | URL: \(.url // "N/A") | 7d: \(.user_quantity_7 // 0) | 30d: \(.user_quantity_30 // 0) | 90d: \(.user_quantity_90 // 0)"'
        else
            echo "$response" | format_json
        fi
        ;;

    create)
        if [[ -z "$NAME" ]]; then
            echo "Error: --name required for create action"
            exit 1
        fi
        body="{\"pixel\":{\"name\":\"$(json_escape "$NAME")\"}}"
        response=$(audience_post "management/pixels" "$body")
        echo "$response" | format_json
        ;;

    edit)
        if [[ -z "$PIXEL_ID" || -z "$NAME" ]]; then
            echo "Error: --id and --name required for edit action"
            exit 1
        fi
        body="{\"pixel\":{\"name\":\"$(json_escape "$NAME")\"}}"
        response=$(audience_put "management/pixel/${PIXEL_ID}" "$body")
        echo "$response" | format_json
        ;;

    delete)
        if [[ -z "$PIXEL_ID" ]]; then
            echo "Error: --id required for delete action"
            exit 1
        fi
        response=$(audience_delete "management/pixel/${PIXEL_ID}")
        echo "$response" | format_json
        ;;

    undelete)
        if [[ -z "$PIXEL_ID" ]]; then
            echo "Error: --id required for undelete action"
            exit 1
        fi
        response=$(audience_post "management/pixel/${PIXEL_ID}/undelete" "{}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        echo "Available: list, create, edit, delete, undelete"
        exit 1
        ;;
esac
