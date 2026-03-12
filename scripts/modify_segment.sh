#!/bin/bash
# Modify data in a file-based segment (add, remove, or replace records)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

SEGMENT_ID=""
FILE_PATH=""
MODIFICATION_TYPE=""
CHECK_SIZE="true"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --id|-i)          SEGMENT_ID="$2"; shift 2 ;;
        --file|-f)        FILE_PATH="$2"; shift 2 ;;
        --mod-type|-m)    MODIFICATION_TYPE="$2"; shift 2 ;;
        --check-size)     CHECK_SIZE="$2"; shift 2 ;;
        *)                echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$SEGMENT_ID" || -z "$FILE_PATH" || -z "$MODIFICATION_TYPE" ]]; then
    echo "Error: --id, --file, and --mod-type required"
    echo "  --mod-type: addition, subtraction, replace"
    exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File not found: $FILE_PATH"
    exit 1
fi

params="modification_type=${MODIFICATION_TYPE}"
if [[ "$CHECK_SIZE" == "false" ]]; then
    params="${params}&check_size=false"
fi

response=$(curl -s -X POST "${AUDIENCE_API}/management/segment/${SEGMENT_ID}/modify_data?${params}" \
    -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
    -F "file=@${FILE_PATH}")

echo "$response" | format_json
