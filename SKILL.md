---
name: yandex-audience
description: |
  Manage Yandex Audience segments, pixels, grants, delegates via API v1.
  Use when the user needs to work with Yandex Audience API — segment management
  (create, edit, delete, reprocess), file uploads (CRM, device IDs, MAC addresses),
  Metrica/AppMetrica segments, lookalike segments, geo segments (circles/polygons),
  pixel segments, pixel management, permission grants, account delegates.
  Triggers: Yandex Audience, Яндекс Аудитории, audience API, сегменты аудитории,
  аудиторные сегменты, lookalike, похожие аудитории, пиксели аудиторий,
  загрузка CRM, гео-сегменты, audience segments.
license: MIT
---

# Yandex Audience API v1

## Essentials

### Base URL

```
https://api-audience.yandex.ru/v1
```

All requests use HTTPS only.

### Authentication

OAuth token in every request:

```
Authorization: OAuth YOUR_TOKEN
```

**Getting a token:**
1. Register app at https://oauth.yandex.ru/client/new
2. Add permissions: Яндекс.Аудитории → create/edit segments + read segments
3. Get token: `https://oauth.yandex.ru/authorize?response_type=token&client_id=YOUR_CLIENT_ID`

### Request Format

- **JSON methods** (POST/PUT): `Content-Type: application/json`
- **File uploads** (POST): `Content-Type: multipart/form-data`
- **Read methods** (GET): no body needed
- **Delete methods** (DELETE): no body needed, params in query string

Add `?pretty=1` to any request for formatted JSON output (debugging).

### Response Format

All responses in JSON, UTF-8 encoding.

**Success:** HTTP 200 with resource data
**Delete success:** `{ "success": true }`

**Error response:**
```json
{
  "errors": [{ "error_type": "invalid_parameter", "message": "...", "location": "..." }],
  "code": 400,
  "message": "Bad Request"
}
```

### Rate Limits

| Limit Type | Value |
|------------|-------|
| Per IP per second | 30 requests |
| Per user per day | 5,000 requests |
| Segment create/modify per minute | 10 |
| Segment create/modify per hour | 100 |
| Segment create/modify per day | 500 |
| Segment reprocess | 2 per segment, 20 per user per 24h |
| Geo segments | Cannot create if 1000+ geo segments and <5% used for targeting |

HTTP 429 on limit exceeded. IP resets within 1 second; user resets at midnight Moscow time.
Erroneous requests also count toward quotas.

### Error Types

| Error Type | HTTP | Description |
|------------|------|-------------|
| `unauthorized` | 401 | Invalid or missing token |
| `access_denied` | 403 | No permission |
| `not_found` | 404 | Object not found |
| `invalid_parameter` | 400 | Bad parameter value |
| `missing_parameter` | 400 | Required parameter missing |
| `quota` | 429 | Rate limit exceeded |
| `backend_error` | 503 | Server error |
| `timeout` | 504 | Request timeout |
| `conflict` | 409 | Data integrity violation |
| `invalid_uploading` | 400 | File upload error |
| `no_changes` | 400 | Duplicate file submission |
| `header_validation_error` | 400 | CRM file header validation failed |
| `too_large_polygon` | 400 | Polygon too large |
| `self_crossing_polygon` | 400 | Polygon self-intersects |
| `crossing_polygons` | 400 | Polygons intersect each other |
| `reprocess_quota` | 429 | Reprocess limit exceeded |
| `reprocess_wrong_type` | 400 | Segment type cannot be reprocessed |
| `reprocess_wrong_status` | 400 | Segment status prevents reprocessing |

### Configuration

The skill uses `config/.env` for credentials:

```bash
# Required
YANDEX_AUDIENCE_TOKEN=your_oauth_token
```

## Scripts

**IMPORTANT:** Always run scripts with `bash` prefix and from the skill directory. Scripts use bash-specific features.

### check_connection.sh
Verify API token and list segments.
```bash
bash scripts/check_connection.sh
```

### segments.sh
List, edit, delete, reprocess segments.
```bash
# List all segments
bash scripts/segments.sh --action list

# List with pagination
bash scripts/segments.sh --action list --limit 50 --offset 100

# Filter by pixel
bash scripts/segments.sh --action list --pixel 123

# Rename segment
bash scripts/segments.sh --action edit --id 12345 --name "New Name"

# Delete segment
bash scripts/segments.sh --action delete --id 12345

# Reprocess segment
bash scripts/segments.sh --action reprocess --id 12345
```

| Param | Description |
|-------|-------------|
| `--action, -a` | list, edit, delete, reprocess |
| `--id, -i` | Segment ID |
| `--name, -n` | New segment name (for edit) |
| `--limit, -l` | Max results (default: 10000) |
| `--offset, -o` | Starting offset (default: 0) |
| `--pixel` | Filter by pixel ID |

### create_segment.sh
Create segments of any type.
```bash
# From file (device IDs, MAC addresses)
bash scripts/create_segment.sh --type file --file /path/to/data.txt

# From CSV (CRM data)
bash scripts/create_segment.sh --type csv --file /path/to/crm.csv

# From Metrica counter
bash scripts/create_segment.sh --type metrika --name "Counter Users" \
  --metrika-type counter_id --metrika-id 12345678

# From Metrica goal
bash scripts/create_segment.sh --type metrika --name "Goal Completers" \
  --metrika-type goal_id --metrika-id 99999

# From AppMetrica
bash scripts/create_segment.sh --type appmetrica --name "App Users" \
  --appmetrica-type api_key --appmetrica-id 55555

# Lookalike
bash scripts/create_segment.sh --type lookalike --name "Similar Users" \
  --lookalike-link 12345 --lookalike-value 3

# Geo circle
bash scripts/create_segment.sh --type geo --name "Near Office" \
  --geo-type work --radius 500 \
  --points '[{"latitude":55.75,"longitude":37.62,"description":"Office"}]'

# Geo polygon
bash scripts/create_segment.sh --type geo_polygon --name "District" \
  --geo-type regular \
  --polygons '[{"points":[{"latitude":55.75,"longitude":37.60},{"latitude":55.76,"longitude":37.63},{"latitude":55.74,"longitude":37.64},{"latitude":55.73,"longitude":37.61}]}]'

# Pixel-based
bash scripts/create_segment.sh --type pixel --name "Pixel Users" \
  --pixel-id 123 --period-length 30 --times-quantity 5 --times-op gt
```

| Param | Description |
|-------|-------------|
| `--type, -t` | file, csv, metrika, appmetrica, lookalike, geo, geo_polygon, pixel |
| `--name, -n` | Segment name |
| `--file, -f` | Path to data file (for file/csv types) |
| `--metrika-type` | counter_id, goal_id, segment_id |
| `--metrika-id` | Metrica object ID |
| `--appmetrica-type` | api_key, segment_id |
| `--appmetrica-id` | AppMetrica object ID |
| `--lookalike-link` | Source segment ID |
| `--lookalike-value` | Similarity 1-5 |
| `--maintain-device` | Keep device distribution (default: true) |
| `--maintain-geo` | Keep geo distribution (default: true) |
| `--geo-type` | last, regular, home, work, condition |
| `--radius` | Circle radius in meters |
| `--period-length` | Period in days (1-90, for condition/pixel) |
| `--times-quantity` | Visit count threshold |
| `--times-op` | lt, eq, gt (for pixel) |
| `--points` | JSON array of {latitude, longitude, description} |
| `--polygons` | JSON array of polygon objects |
| `--pixel-id` | Pixel ID |
| `--utm-source/medium/campaign/content/term` | UTM filters |
| `--device-matching` | CROSS_DEVICE (default) or IN_DEVICE |

### confirm_segment.sh
Save a file-based segment after upload.
```bash
# Confirm regular file segment
bash scripts/confirm_segment.sh --id 12345 --name "CRM Customers" --content-type crm

# Confirm hashed data
bash scripts/confirm_segment.sh --id 12345 --name "Hashed CRM" --content-type crm \
  --hashed true --hashing-alg SHA256

# Confirm ClientId Metrica segment
bash scripts/confirm_segment.sh --id 12345 --name "ClientId Segment" \
  --mode client_id --counter-id 98765
```

| Param | Description |
|-------|-------------|
| `--id, -i` | Segment ID from upload step |
| `--name, -n` | Segment name |
| `--content-type` | idfa_gaid, mac, crm |
| `--hashed` | true/false |
| `--hashing-alg` | SHA256 (only option since Jan 2025) |
| `--device-matching` | CROSS_DEVICE or IN_DEVICE |
| `--check-size` | false to allow <100 records |
| `--mode, -m` | file (default) or client_id |
| `--counter-id` | Metrica counter ID (for client_id mode) |

### modify_segment.sh
Add, remove, or replace data in file-based segments.
```bash
# Add records
bash scripts/modify_segment.sh --id 12345 --file /path/to/new.csv --mod-type addition

# Remove records
bash scripts/modify_segment.sh --id 12345 --file /path/to/remove.csv --mod-type subtraction

# Replace all data
bash scripts/modify_segment.sh --id 12345 --file /path/to/full.csv --mod-type replace
```

### pixels.sh
Manage tracking pixels.
```bash
bash scripts/pixels.sh --action list
bash scripts/pixels.sh --action create --name "New Pixel"
bash scripts/pixels.sh --action edit --id 123 --name "Renamed"
bash scripts/pixels.sh --action delete --id 123
bash scripts/pixels.sh --action undelete --id 123
```

### grants.sh
Manage segment permissions.
```bash
bash scripts/grants.sh --segment-id 12345 --action list
bash scripts/grants.sh --segment-id 12345 --action add --user-login user --permission edit
bash scripts/grants.sh --segment-id 12345 --action delete --user-login user
```

### delegates.sh
Manage account representatives.
```bash
bash scripts/delegates.sh --action list
bash scripts/delegates.sh --action add --user-login partner --permission edit
bash scripts/delegates.sh --action delete --user-login partner
```

### accounts.sh
List accounts where current user is a representative.
```bash
bash scripts/accounts.sh
```

### Advanced: common.sh functions

For custom API calls, use `common.sh` functions inside a bash script:

```bash
#!/bin/bash
source /path/to/scripts/common.sh
load_config

# GET request
response=$(audience_get "management/segments" "limit=5")

# POST with JSON
response=$(audience_post "management/segments/create_metrika" '{"segment":{...}}')

# PUT with JSON
response=$(audience_put "management/segment/123" '{"segment":{"name":"New"}}')

# DELETE
response=$(audience_delete "management/segment/123")

# File upload (multipart/form-data)
response=$(audience_upload "management/segments/upload_file" "/path/to/file.csv")
```

## All API v1 Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/management/segments` | List segments |
| PUT | `/management/segment/{id}` | Edit segment (rename) |
| DELETE | `/management/segment/{id}` | Delete segment |
| PUT | `/management/segment/{id}/reprocess` | Reprocess segment |
| POST | `/management/segments/upload_file` | Create segment from file |
| POST | `/management/segments/upload_csv_file` | Create segment from CSV |
| POST | `/management/segment/{id}/confirm` | Confirm file segment |
| POST | `/management/segment/client_id/{id}/confirm` | Confirm ClientId segment |
| POST | `/management/segment/{id}/modify_data` | Modify file segment data |
| POST | `/management/segments/create_metrika` | Create Metrica segment |
| POST | `/management/segments/create_appmetrica` | Create AppMetrica segment |
| POST | `/management/segments/create_lookalike` | Create lookalike segment |
| POST | `/management/segments/create_geo` | Create geo circle segment |
| POST | `/management/segments/create_geo_polygon` | Create geo polygon segment |
| POST | `/management/segments/create_pixel` | Create pixel segment |
| GET | `/management/segment/{id}/grants` | List segment grants |
| PUT | `/management/segment/{id}/grant` | Add segment grant |
| DELETE | `/management/segment/{id}/grant` | Delete segment grant |
| GET | `/management/pixels` | List pixels |
| POST | `/management/pixels` | Create pixel |
| PUT | `/management/pixel/{id}` | Edit pixel |
| DELETE | `/management/pixel/{id}` | Delete pixel |
| POST | `/management/pixel/{id}/undelete` | Restore pixel |
| GET | `/management/delegates` | List delegates |
| PUT | `/management/delegate` | Add delegate |
| DELETE | `/management/delegate` | Delete delegate |
| GET | `/management/accounts` | List accounts |

## Data Requirements

### File Uploads
- **Min records:** 100 (bypass with `check_size=false`)
- **Max file size:** 1 GB
- **Encoding:** UTF-8 or Windows-1251
- **Hashing:** SHA-256 only (MD5 not supported since Jan 2025)

### Content Types
- `idfa_gaid` — mobile device IDs (Android GAID lowercase, iOS IDFA uppercase)
- `mac` — MAC addresses (hex without separators)
- `crm` — CRM data CSV (email, phone, external_id fields)

### CRM CSV Format
```csv
"email","phone","ext_id"
"user@mail.ru","79991112233","cust_001"
```
- `phone`: digits with country code, no spaces/symbols
- `email`: lowercase, Latin chars, with @

## Detailed References

Read the reference file matching the area you need:

- **Segments** (all segment operations, types, statuses, create/edit/delete) -- [references/segments.md](references/segments.md)
- **Pixels, Grants, Delegates, Accounts** -- [references/pixels-grants-delegates.md](references/pixels-grants-delegates.md)
- **Data Requirements** (file formats, hashing, CRM structure) -- [references/data-requirements.md](references/data-requirements.md)
- **Common Use Cases** (bash script examples) -- [references/use-cases.md](references/use-cases.md)

## Guidelines

- Always verify the token before batch operations: `bash scripts/check_connection.sh`
- File uploads are a 2-step process: upload → confirm (with name + content_type)
- Only SHA-256 hashing is supported (no MD5 since January 2025)
- When modifying file segments, new data must match original format (both hashed or both unhashed)
- Geo segments: max 1000 geo segments if <5% used for targeting
- Geo polygons: 1-10 polygons, min 4 points each, no self-intersections
- Lookalike segments: similarity 1 (broad) to 5 (narrow)
- Pixel segments: all UTM conditions must match simultaneously (AND logic)
- Rate limits apply to erroneous requests too
- Store tokens securely in `config/.env` (file is gitignored)
