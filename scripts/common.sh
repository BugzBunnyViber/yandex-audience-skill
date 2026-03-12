#!/bin/bash
# Common functions for Yandex Audience API v1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/.env"
CACHE_DIR="$SCRIPT_DIR/../cache"

AUDIENCE_API="https://api-audience.yandex.ru/v1"

# Load config
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    fi

    if [[ -z "$YANDEX_AUDIENCE_TOKEN" ]]; then
        echo "Error: YANDEX_AUDIENCE_TOKEN not found."
        echo "Set in config/.env or environment. See config/README.md for instructions."
        exit 1
    fi
}

# Make Audience API GET request
# Usage: audience_get "management/segments" "limit=10&offset=0"
audience_get() {
    local path="$1"
    local params="$2"

    local url="${AUDIENCE_API}/${path}"
    if [[ -n "$params" ]]; then
        url="${url}?${params}"
    fi

    curl -s -X GET "$url" \
        -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
        -H "Content-Type: application/json"
}

# Make Audience API POST request with JSON body
# Usage: audience_post "management/segments/create_metrika" '{"segment":{...}}'
audience_post() {
    local path="$1"
    local body="$2"

    curl -s -X POST "${AUDIENCE_API}/${path}" \
        -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$body"
}

# Make Audience API PUT request with JSON body
# Usage: audience_put "management/segment/123" '{"segment":{...}}'
audience_put() {
    local path="$1"
    local body="$2"

    curl -s -X PUT "${AUDIENCE_API}/${path}" \
        -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$body"
}

# Make Audience API DELETE request
# Usage: audience_delete "management/segment/123" "user_login=test"
audience_delete() {
    local path="$1"
    local params="$2"

    local url="${AUDIENCE_API}/${path}"
    if [[ -n "$params" ]]; then
        url="${url}?${params}"
    fi

    curl -s -X DELETE "$url" \
        -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
        -H "Content-Type: application/json"
}

# Make Audience API multipart/form-data POST request (file upload)
# Usage: audience_upload "management/segments/upload_file" "/path/to/file.csv"
audience_upload() {
    local path="$1"
    local file_path="$2"

    if [[ ! -f "$file_path" ]]; then
        echo "Error: File not found: $file_path"
        return 1
    fi

    curl -s -X POST "${AUDIENCE_API}/${path}" \
        -H "Authorization: OAuth $YANDEX_AUDIENCE_TOKEN" \
        -F "file=@${file_path}"
}

# Format JSON output (pretty print if jq available)
format_json() {
    if command -v jq &>/dev/null; then
        jq '.'
    else
        cat
    fi
}

# Extract JSON value using jq or grep/sed
json_value() {
    local json="$1"
    local key="$2"
    if command -v jq &>/dev/null; then
        echo "$json" | jq -r ".$key // empty"
    else
        echo "$json" | grep -o "\"$key\":[^,}]*" | head -1 | sed 's/.*://' | tr -d '"[:space:]'
    fi
}

# Format number with thousands separator
format_number() {
    local num="$1"
    printf "%'d" "$num" 2>/dev/null || echo "$num"
}

# JSON escape
json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}
