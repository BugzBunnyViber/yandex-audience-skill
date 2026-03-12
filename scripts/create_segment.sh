#!/bin/bash
# Create Yandex Audience segments of various types

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
load_config

TYPE=""
NAME=""
FILE_PATH=""
CHECK_SIZE="true"

# File segment params
CONTENT_TYPE=""
HASHED="false"
HASHING_ALG=""
DEVICE_MATCHING="CROSS_DEVICE"

# Metrika params
METRIKA_TYPE=""
METRIKA_ID=""

# AppMetrica params
APPMETRICA_TYPE=""
APPMETRICA_ID=""

# Lookalike params
LOOKALIKE_LINK=""
LOOKALIKE_VALUE=""
MAINTAIN_DEVICE="true"
MAINTAIN_GEO="true"

# Geo circle params
RADIUS=""
GEO_TYPE=""
PERIOD_LENGTH=""
TIMES_QUANTITY=""
POINTS_JSON=""

# Geo polygon params
POLYGONS_JSON=""

# Pixel params
PIXEL_ID=""
UTM_SOURCE=""
UTM_MEDIUM=""
UTM_CAMPAIGN=""
UTM_CONTENT=""
UTM_TERM=""
TIMES_OP=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --type|-t)              TYPE="$2"; shift 2 ;;
        --name|-n)              NAME="$2"; shift 2 ;;
        --file|-f)              FILE_PATH="$2"; shift 2 ;;
        --check-size)           CHECK_SIZE="$2"; shift 2 ;;
        --content-type)         CONTENT_TYPE="$2"; shift 2 ;;
        --hashed)               HASHED="$2"; shift 2 ;;
        --hashing-alg)          HASHING_ALG="$2"; shift 2 ;;
        --device-matching)      DEVICE_MATCHING="$2"; shift 2 ;;
        --metrika-type)         METRIKA_TYPE="$2"; shift 2 ;;
        --metrika-id)           METRIKA_ID="$2"; shift 2 ;;
        --appmetrica-type)      APPMETRICA_TYPE="$2"; shift 2 ;;
        --appmetrica-id)        APPMETRICA_ID="$2"; shift 2 ;;
        --lookalike-link)       LOOKALIKE_LINK="$2"; shift 2 ;;
        --lookalike-value)      LOOKALIKE_VALUE="$2"; shift 2 ;;
        --maintain-device)      MAINTAIN_DEVICE="$2"; shift 2 ;;
        --maintain-geo)         MAINTAIN_GEO="$2"; shift 2 ;;
        --radius)               RADIUS="$2"; shift 2 ;;
        --geo-type)             GEO_TYPE="$2"; shift 2 ;;
        --period-length)        PERIOD_LENGTH="$2"; shift 2 ;;
        --times-quantity)       TIMES_QUANTITY="$2"; shift 2 ;;
        --times-op)             TIMES_OP="$2"; shift 2 ;;
        --points)               POINTS_JSON="$2"; shift 2 ;;
        --polygons)             POLYGONS_JSON="$2"; shift 2 ;;
        --pixel-id)             PIXEL_ID="$2"; shift 2 ;;
        --utm-source)           UTM_SOURCE="$2"; shift 2 ;;
        --utm-medium)           UTM_MEDIUM="$2"; shift 2 ;;
        --utm-campaign)         UTM_CAMPAIGN="$2"; shift 2 ;;
        --utm-content)          UTM_CONTENT="$2"; shift 2 ;;
        --utm-term)             UTM_TERM="$2"; shift 2 ;;
        *)                      echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$TYPE" ]]; then
    echo "Error: --type required"
    echo "Available types: file, csv, metrika, appmetrica, lookalike, geo, geo_polygon, pixel"
    exit 1
fi

case "$TYPE" in
    file)
        if [[ -z "$FILE_PATH" ]]; then
            echo "Error: --file required for file type"
            exit 1
        fi
        echo "Uploading file: $FILE_PATH"
        response=$(audience_upload "management/segments/upload_file" "$FILE_PATH")
        echo "$response" | format_json

        # Extract segment ID for confirm step
        seg_id=$(json_value "$response" "id")
        if [[ -n "$seg_id" && "$seg_id" != "null" ]]; then
            echo ""
            echo "File uploaded. Segment ID: $seg_id"
            echo "Now confirm with: bash scripts/confirm_segment.sh --id $seg_id --name \"YOUR_NAME\" --content-type $CONTENT_TYPE"
        fi
        ;;

    csv)
        if [[ -z "$FILE_PATH" ]]; then
            echo "Error: --file required for csv type"
            exit 1
        fi
        echo "Uploading CSV file: $FILE_PATH"
        response=$(audience_upload "management/segments/upload_csv_file" "$FILE_PATH")
        echo "$response" | format_json

        seg_id=$(json_value "$response" "id")
        if [[ -n "$seg_id" && "$seg_id" != "null" ]]; then
            echo ""
            echo "CSV uploaded. Segment ID: $seg_id"
            echo "Now confirm with: bash scripts/confirm_segment.sh --id $seg_id --name \"YOUR_NAME\" --content-type crm"
        fi
        ;;

    metrika)
        if [[ -z "$NAME" || -z "$METRIKA_TYPE" ]]; then
            echo "Error: --name and --metrika-type required for metrika type"
            echo "  --metrika-type: counter_id, goal_id, segment_id"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"metrika_segment_type\":\"$METRIKA_TYPE\""
        if [[ -n "$METRIKA_ID" ]]; then
            body="${body},\"metrika_segment_id\":$METRIKA_ID"
        fi
        if [[ -n "$DEVICE_MATCHING" ]]; then
            body="${body},\"device_matching_type\":\"$DEVICE_MATCHING\""
        fi
        body="${body}}}"
        response=$(audience_post "management/segments/create_metrika" "$body")
        echo "$response" | format_json
        ;;

    appmetrica)
        if [[ -z "$NAME" || -z "$APPMETRICA_TYPE" ]]; then
            echo "Error: --name and --appmetrica-type required for appmetrica type"
            echo "  --appmetrica-type: api_key, segment_id"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"app_metrica_segment_type\":\"$APPMETRICA_TYPE\""
        if [[ -n "$APPMETRICA_ID" ]]; then
            body="${body},\"app_metrica_segment_id\":$APPMETRICA_ID"
        fi
        if [[ -n "$DEVICE_MATCHING" ]]; then
            body="${body},\"device_matching_type\":\"$DEVICE_MATCHING\""
        fi
        body="${body}}}"
        response=$(audience_post "management/segments/create_appmetrica" "$body")
        echo "$response" | format_json
        ;;

    lookalike)
        if [[ -z "$NAME" || -z "$LOOKALIKE_LINK" || -z "$LOOKALIKE_VALUE" ]]; then
            echo "Error: --name, --lookalike-link, --lookalike-value required for lookalike type"
            echo "  --lookalike-value: 1-5 (degree of similarity)"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"lookalike_link\":$LOOKALIKE_LINK,\"lookalike_value\":$LOOKALIKE_VALUE,\"maintain_device_distribution\":$MAINTAIN_DEVICE,\"maintain_geo_distribution\":$MAINTAIN_GEO}}"
        response=$(audience_post "management/segments/create_lookalike" "$body")
        echo "$response" | format_json
        ;;

    geo)
        if [[ -z "$NAME" || -z "$POINTS_JSON" ]]; then
            echo "Error: --name and --points required for geo type"
            echo "  --points: JSON array of {latitude, longitude, description}"
            echo '  Example: --points '"'"'[{"latitude":55.75,"longitude":37.62,"description":"Moscow"}]'"'"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"points\":$POINTS_JSON"
        if [[ -n "$RADIUS" ]]; then
            body="${body},\"radius\":$RADIUS"
        fi
        if [[ -n "$GEO_TYPE" ]]; then
            body="${body},\"geo_segment_type\":\"$GEO_TYPE\""
        fi
        if [[ -n "$PERIOD_LENGTH" ]]; then
            body="${body},\"period_length\":$PERIOD_LENGTH"
        fi
        if [[ -n "$TIMES_QUANTITY" ]]; then
            body="${body},\"times_quantity\":$TIMES_QUANTITY"
        fi
        body="${body}}}"
        response=$(audience_post "management/segments/create_geo" "$body")
        echo "$response" | format_json
        ;;

    geo_polygon)
        if [[ -z "$NAME" || -z "$POLYGONS_JSON" ]]; then
            echo "Error: --name and --polygons required for geo_polygon type"
            echo '  --polygons: JSON array of polygon objects with points'
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"polygons\":$POLYGONS_JSON"
        if [[ -n "$GEO_TYPE" ]]; then
            body="${body},\"geo_segment_type\":\"$GEO_TYPE\""
        fi
        if [[ -n "$PERIOD_LENGTH" ]]; then
            body="${body},\"period_length\":$PERIOD_LENGTH"
        fi
        if [[ -n "$TIMES_QUANTITY" ]]; then
            body="${body},\"times_quantity\":$TIMES_QUANTITY"
        fi
        body="${body}}}"
        response=$(audience_post "management/segments/create_geo_polygon" "$body")
        echo "$response" | format_json
        ;;

    pixel)
        if [[ -z "$NAME" || -z "$PIXEL_ID" ]]; then
            echo "Error: --name and --pixel-id required for pixel type"
            exit 1
        fi
        body="{\"segment\":{\"name\":\"$(json_escape "$NAME")\",\"pixel_id\":$PIXEL_ID"
        if [[ -n "$PERIOD_LENGTH" ]]; then
            body="${body},\"period_length\":$PERIOD_LENGTH"
        fi
        if [[ -n "$TIMES_QUANTITY" ]]; then
            body="${body},\"times_quantity\":$TIMES_QUANTITY"
        fi
        if [[ -n "$TIMES_OP" ]]; then
            body="${body},\"times_quantity_operation\":\"$TIMES_OP\""
        fi
        for utm_var in utm_source:$UTM_SOURCE utm_medium:$UTM_MEDIUM utm_campaign:$UTM_CAMPAIGN utm_content:$UTM_CONTENT utm_term:$UTM_TERM; do
            key="${utm_var%%:*}"
            val="${utm_var#*:}"
            if [[ -n "$val" ]]; then
                body="${body},\"$key\":\"$(json_escape "$val")\""
            fi
        done
        body="${body}}}"
        response=$(audience_post "management/segments/create_pixel" "$body")
        echo "$response" | format_json
        ;;

    *)
        echo "Unknown type: $TYPE"
        echo "Available: file, csv, metrika, appmetrica, lookalike, geo, geo_polygon, pixel"
        exit 1
        ;;
esac
