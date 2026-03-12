#!/bin/bash
# Confirm (save) a file-based segment after upload

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

SEGMENT_ID=""
NAME=""
CONTENT_TYPE=""
HASHED="false"
HASHING_ALG=""
DEVICE_MATCHING=""
CHECK_SIZE="true"
# For ClientId Metrica segments
COUNTER_ID=""
MODE="file"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --id|-i)            SEGMENT_ID="$2"; shift 2 ;;
        --name|-n)          NAME="$2"; shift 2 ;;
        --content-type)     CONTENT_TYPE="$2"; shift 2 ;;
        --hashed)           HASHED="$2"; shift 2 ;;
        --hashing-alg)      HASHING_ALG="$2"; shift 2 ;;
        --device-matching)  DEVICE_MATCHING="$2"; shift 2 ;;
        --check-size)       CHECK_SIZE="$2"; shift 2 ;;
        --counter-id)       COUNTER_ID="$2"; shift 2 ;;
        --mode|-m)          MODE="$2"; shift 2 ;;
        *)                  echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$SEGMENT_ID" || -z "$NAME" ]]; then
    echo "Error: --id and --name required"
    exit 1
fi

case "$MODE" in
    file)
        if [[ -z "$CONTENT_TYPE" ]]; then
            echo "Error: --content-type required (idfa_gaid, mac, crm)"
            exit 1
        fi

        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"content_type\":\"$CONTENT_TYPE\""
        if [[ "$HASHED" == "true" ]]; then
            body="${body},\"hashed\":true"
            if [[ -n "$HASHING_ALG" ]]; then
                body="${body},\"hashing_alg\":\"$HASHING_ALG\""
            else
                body="${body},\"hashing_alg\":\"SHA256\""
            fi
        fi
        if [[ -n "$DEVICE_MATCHING" ]]; then
            body="${body},\"device_matching_type\":\"$DEVICE_MATCHING\""
        fi
        body="${body}}}"

        params=""
        if [[ "$CHECK_SIZE" == "false" ]]; then
            params="check_size=false"
        fi

        if [[ -n "$params" ]]; then
            response=$(curl -s -X POST "${AUDIENCE_API}/management/segment/${SEGMENT_ID}/confirm?${params}" \
                -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$body")
        else
            response=$(audience_post "management/segment/${SEGMENT_ID}/confirm" "$body")
        fi
        echo "$response" | format_json
        ;;

    client_id)
        if [[ -z "$COUNTER_ID" ]]; then
            echo "Error: --counter-id required for client_id mode"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"counter_id\":$COUNTER_ID}}"
        response=$(audience_post "management/segment/client_id/${SEGMENT_ID}/confirm" "$body")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown mode: $MODE"
        echo "Available: file, client_id"
        exit 1
        ;;
esac
