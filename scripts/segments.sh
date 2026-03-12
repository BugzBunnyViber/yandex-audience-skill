#!/bin/bash
# Manage Yandex Audience segments: list, get, delete, edit, reprocess

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

ACTION="list"
SEGMENT_ID=""
NAME=""
LIMIT="10000"
OFFSET="0"
PIXEL_ID=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action|-a)   ACTION="$2"; shift 2 ;;
        --id|-i)       SEGMENT_ID="$2"; shift 2 ;;
        --name|-n)     NAME="$2"; shift 2 ;;
        --limit|-l)    LIMIT="$2"; shift 2 ;;
        --offset|-o)   OFFSET="$2"; shift 2 ;;
        --pixel)       PIXEL_ID="$2"; shift 2 ;;
        *)             echo "Unknown option: $1"; exit 1 ;;
    esac
done

case "$ACTION" in
    list)
        params="limit=${LIMIT}&offset=${OFFSET}"
        if [[ -n "$PIXEL_ID" ]]; then
            params="${params}&pixel=${PIXEL_ID}"
        fi
        response=$(audience_get "management/segments" "$params")
        if command -v jq &>/dev/null; then
            total=$(echo "$response" | jq '.segments | length')
            echo "Segments found: $total"
            echo ""
            echo "$response" | jq -r '.segments[] | "ID: \(.id) | \(.name) | Type: \(.type) | Status: \(.status) | Matched: \(.cookies_matched_quantity // "N/A")"'
        else
            echo "$response" | format_json
        fi
        ;;

    edit)
        if [[ -z "$SEGMENT_ID" ]]; then
            echo "Error: --id required for edit action"
            exit 1
        fi
        if [[ -z "$NAME" ]]; then
            echo "Error: --name required for edit action"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\"}}"
        response=$(audience_put "management/segment/${SEGMENT_ID}" "$body")
        echo "$response" | format_json
        ;;

    delete)
        if [[ -z "$SEGMENT_ID" ]]; then
            echo "Error: --id required for delete action"
            exit 1
        fi
        response=$(audience_delete "management/segment/${SEGMENT_ID}")
        echo "$response" | format_json
        ;;

    reprocess)
        if [[ -z "$SEGMENT_ID" ]]; then
            echo "Error: --id required for reprocess action"
            exit 1
        fi
        response=$(audience_put "management/segment/${SEGMENT_ID}/reprocess" "{}")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown action: $ACTION"
        echo "Available: list, edit, delete, reprocess"
        exit 1
        ;;
esac
