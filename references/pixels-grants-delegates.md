# Pixels, Grants, Delegates, Accounts API Reference

## Pixels

### List Pixels

```
GET /v1/management/pixels
```

**Response:**
```json
{
  "pixels": [
    {
      "id": 123,
      "name": "My Pixel",
      "create_time": "2025-01-01T00:00:00Z",
      "url": "https://mc.yandex.ru/pixel/...",
      "user_quantity_7": 1500,
      "user_quantity_30": 5000,
      "user_quantity_90": 12000,
      "segments": []
    }
  ]
}
```

### Create Pixel

```
POST /v1/management/pixels
Content-Type: application/json
```

**Body:** `{ "pixel": { "name": "New Pixel" } }`

### Edit Pixel

```
PUT /v1/management/pixel/{pixelId}
Content-Type: application/json
```

**Body:** `{ "pixel": { "name": "Updated Name" } }`

### Delete Pixel

```
DELETE /v1/management/pixel/{pixelId}
```

**Response:** `{ "success": true }`

### Restore (Undelete) Pixel

```
POST /v1/management/pixel/{pixelId}/undelete
```

**Response:** `{ "success": true }`

---

## Grants (Segment Permissions)

### List Grants

```
GET /v1/management/segment/{segmentId}/grants
```

**Response:**
```json
{
  "grants": [
    {
      "user_login": "some_user",
      "permission": "edit|view",
      "comment": "Optional comment (0-255 chars)",
      "created_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

### Add Grant

```
PUT /v1/management/segment/{segmentId}/grant
Content-Type: application/json
```

**Body:**
```json
{
  "grant": {
    "user_login": "some_user",
    "permission": "edit",
    "comment": "Full access for manager"
  }
}
```

| Field | Required | Values |
|-------|----------|--------|
| `user_login` | Yes | Yandex login (min 1 char) |
| `permission` | Yes | `edit` or `view` |
| `comment` | No | Up to 255 chars |

### Delete Grant

```
DELETE /v1/management/segment/{segmentId}/grant?user_login=some_user
```

**Response:** `{ "success": true }`

---

## Delegates (Account Representatives)

### List Delegates

```
GET /v1/management/delegates
```

**Response:**
```json
{
  "delegates": [
    {
      "user_login": "delegate_user",
      "perm": "edit|view",
      "comment": "optional",
      "created_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

### Add Delegate

```
PUT /v1/management/delegate
Content-Type: application/json
```

**Body:**
```json
{
  "delegate": {
    "user_login": "new_delegate",
    "perm": "edit",
    "comment": "Manager access"
  }
}
```

| Field | Required | Values |
|-------|----------|--------|
| `user_login` | Yes | Yandex login (min 1 char) |
| `perm` | Yes | `edit` or `view` |
| `comment` | No | Up to 255 chars |

### Delete Delegate

```
DELETE /v1/management/delegate?user_login=delegate_user
```

**Response:** `{ "success": true }`

---

## Accounts

### List Accounts

```
GET /v1/management/accounts
```

Returns accounts where the current user is a representative.

**Response:**
```json
{
  "accounts": [
    {
      "user_login": "account_owner",
      "perm": "edit|view",
      "created_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```
