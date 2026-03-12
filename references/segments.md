# Segments API Reference

## List Segments

```
GET /v1/management/segments?limit=10000&offset=0&pixel={pixelId}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | integer | 10000 | Max segments to return |
| `offset` | integer | 0 | Starting position |
| `pixel` | integer | — | Filter by pixel ID |

**Response:**
```json
{
  "segments": [
    {
      "type": "uploading|metrika|appmetrica|lookalike|geo|pixel",
      "id": 1111,
      "name": "segment name",
      "status": "processed",
      "create_time": "2025-01-01T00:00:00Z",
      "owner": "user_login",
      "has_guests": true,
      "guest_quantity": 2,
      "can_create_dependent": true,
      "has_derivatives": false,
      "derivatives": [],
      "cookies_matched_quantity": 15000
    }
  ]
}
```

### Segment Statuses

| Status | Description |
|--------|-------------|
| `uploaded` | Data uploaded, not processed yet |
| `is_processed` | Currently processing |
| `processed` | Ready to use |
| `processing_failed` | Processing error |
| `is_updated` | Updating |
| `few_data` | Not enough data for the segment |

### Segment Types

| Type | Description | Extra Fields |
|------|-------------|-------------|
| `uploading` | From file | hashed, used_hashing_alg, content_type, device_matching_type, item_quantity, valid_unique_quantity, matched_quantity |
| `metrika` | From Yandex Metrica | metrika_segment_type, metrika_segment_id, pattern |
| `appmetrica` | From AppMetrica | app_metrica_segment_type, app_metrica_segment_id, pattern |
| `lookalike` | Similar users | lookalike_link, lookalike_value, maintain_device_distribution, maintain_geo_distribution |
| `geo` | Geo circles | radius, geo_segment_type, period_length, times_quantity, points[] |
| `geo` (polygon) | Geo polygons | geo_segment_type, period_length, times_quantity, polygons[] |
| `pixel` | By pixel events | pixel_id, period_length, times_quantity, times_quantity_operation, utm_* |

---

## Create Segment from File

```
POST /v1/management/segments/upload_file
Content-Type: multipart/form-data
```

Body: `file` field with binary file (CSV/TXT, min 100 records, max 1GB, UTF-8 or Windows-1251).

**Response:** `{ "segment": { UploadingSegment } }`

After upload, **confirm** with `/v1/management/segment/{segmentId}/confirm`.

---

## Create Segment from CSV

```
POST /v1/management/segments/upload_csv_file
Content-Type: multipart/form-data
```

Body: `file` field with CSV file. First row = headers (email, phone, ext_id, custom fields).

**Response:** `{ "segment": { UploadingSegment } }`

After upload, **confirm** with `/v1/management/segment/{segmentId}/confirm`.

---

## Confirm File Segment

```
POST /v1/management/segment/{segmentId}/confirm?check_size=true
Content-Type: application/json
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `check_size` | boolean | Allow segments with <100 records when false (default: true) |

**Body:**
```json
{
  "segment": {
    "name": "My Segment",
    "content_type": "idfa_gaid|mac|crm",
    "hashed": false,
    "hashing_alg": "SHA256",
    "device_matching_type": "CROSS_DEVICE|IN_DEVICE"
  }
}
```

| Field | Required | Values |
|-------|----------|--------|
| `name` | Yes | Segment name |
| `content_type` | Yes | `idfa_gaid` (device IDs), `mac` (MAC addresses), `crm` (CRM data) |
| `hashed` | No | Whether data is hashed |
| `hashing_alg` | No | Only `SHA256` (MD5 deprecated since Jan 2025) |
| `device_matching_type` | No | `CROSS_DEVICE` (default, expand to other devices) or `IN_DEVICE` (uploaded devices only, idfa_gaid only) |

---

## Confirm ClientId Metrica Segment

```
POST /v1/management/segment/client_id/{segmentId}/confirm
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "ClientId Segment",
    "counter_id": 12345
  }
}
```

---

## Create Metrica Segment

```
POST /v1/management/segments/create_metrika
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "From Metrica",
    "metrika_segment_type": "counter_id|goal_id|segment_id",
    "metrika_segment_id": 12345,
    "device_matching_type": "CROSS_DEVICE"
  }
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Segment name |
| `metrika_segment_type` | Yes | `counter_id` (counter), `goal_id` (goal), `segment_id` (segment) |
| `metrika_segment_id` | No | Metrica object ID |
| `device_matching_type` | No | Device matching type |

---

## Create AppMetrica Segment

```
POST /v1/management/segments/create_appmetrica
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "From AppMetrica",
    "app_metrica_segment_type": "api_key|segment_id",
    "app_metrica_segment_id": 12345
  }
}
```

---

## Create Lookalike Segment

```
POST /v1/management/segments/create_lookalike
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "Similar Users",
    "lookalike_link": 123,
    "lookalike_value": 3,
    "maintain_device_distribution": true,
    "maintain_geo_distribution": true
  }
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Segment name |
| `lookalike_link` | Yes | Source segment ID |
| `lookalike_value` | Yes | Similarity degree (1-5) |
| `maintain_device_distribution` | No | Keep device distribution (default: true) |
| `maintain_geo_distribution` | No | Keep geo distribution (default: true) |

---

## Create Geo Circle Segment

```
POST /v1/management/segments/create_geo
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "Moscow Center",
    "radius": 500,
    "geo_segment_type": "regular",
    "period_length": 30,
    "times_quantity": 2,
    "points": [
      { "latitude": 55.75, "longitude": 37.62, "description": "Center" }
    ]
  }
}
```

### geo_segment_type Values

| Value | Description |
|-------|-------------|
| `last` | Currently in zone or was 1 hour ago |
| `regular` | Regular visitors (45-day data) |
| `home` | Lives in zone |
| `work` | Works in zone |
| `condition` | Visited N times in period (requires period_length + times_quantity) |

---

## Create Geo Polygon Segment

```
POST /v1/management/segments/create_geo_polygon
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "District",
    "geo_segment_type": "regular",
    "polygons": [
      {
        "points": [
          { "latitude": 55.75, "longitude": 37.62 },
          { "latitude": 55.76, "longitude": 37.63 },
          { "latitude": 55.74, "longitude": 37.64 },
          { "latitude": 55.73, "longitude": 37.62 }
        ],
        "description": "Central area"
      }
    ]
  }
}
```

**Limits:** 1-10 polygons, min 4 points per polygon. No self-intersecting or crossing polygons.

---

## Create Pixel Segment

```
POST /v1/management/segments/create_pixel
Content-Type: application/json
```

**Body:**
```json
{
  "segment": {
    "name": "Pixel visitors",
    "pixel_id": 123,
    "period_length": 30,
    "times_quantity": 5,
    "times_quantity_operation": "gt",
    "utm_source": "google"
  }
}
```

| Field | Description |
|-------|-------------|
| `times_quantity_operation` | `lt` (less than), `eq` (equal), `gt` (greater than) |
| `utm_source/medium/campaign/content/term` | UTM filter tags |

All conditions must match simultaneously.

---

## Edit Segment

```
PUT /v1/management/segment/{segmentId}
Content-Type: application/json
```

**Body:** `{ "segment": { "name": "New Name" } }`

Only `name` can be changed.

---

## Delete Segment

```
DELETE /v1/management/segment/{segmentId}
```

**Response:** `{ "success": true }`

---

## Reprocess Segment

```
PUT /v1/management/segment/{segmentId}/reprocess
```

**Quota:** 2 per segment, 20 per user_login per 24 hours.

**Response:** `{ "success": true }`

---

## Modify File Segment Data

```
POST /v1/management/segment/{segmentId}/modify_data?modification_type=addition&check_size=true
Content-Type: multipart/form-data
```

| Parameter | Values | Description |
|-----------|--------|-------------|
| `modification_type` | `addition`, `subtraction`, `replace` | Add, remove, or replace records |
| `check_size` | boolean | Allow <100 records when false |

Body: `file` field with data matching original format (both hashed or both unhashed).
