# Data Requirements for File-Based Segments

## General Rules

- **Minimum records:** 100 per file
- **Maximum file size:** 1 GB
- **Encoding:** UTF-8 or Windows-1251
- **Hashing:** Only SHA-256 supported (MD5 deprecated since January 1, 2025)
- Each record must be hashed individually

---

## 1. Mobile Device IDs (content_type: idfa_gaid)

**File format:** CSV or TXT

### ID Formats

| Platform | Format | Example |
|----------|--------|---------|
| Android (GAID) | Lowercase, hyphen-separated | `aaaaaaaa-bbbb-cccc-1111-222222222200` |
| iOS (IDFA) | Uppercase, hyphen-separated | `AAAAAAAAA-BBBB-CCCC-1111-222222220000` |

### Record Separators
Comma, newline, or tab.

### Hashing
SHA-256 hash of each individual ID string.

---

## 2. MAC Addresses (content_type: mac)

**File format:** CSV or TXT

### Format
Hex string without separators (`.`, `,`, `:`, `-` are FORBIDDEN in the file).

| Type | Example |
|------|---------|
| Unhashed | `AE123456D0A1` (case-insensitive) |
| SHA-256 hashed | `f74c5e094cea3ecc6289924b11903e8d9920ec4faf38f7ff82b949c5b1214b6c` |

### Hashing MAC Addresses
1. Convert hex string to byte string (2 hex chars = 1 byte)
2. Take SHA-256 hash of the byte string

**Verification pair:** MAC `AE123456D0A1` → SHA-256 `f74c5e094cea3ecc6289924b11903e8d9920ec4faf38f7ff82b949c5b1214b6c`

---

## 3. CRM Data (content_type: crm)

**File format:** CSV only

### Structure
- First row: field names separated by commas
- Each subsequent row: one customer record
- Fields separated by commas

### Required Fields (at least one)

| Field | Format | Example |
|-------|--------|---------|
| `phone` | Digits with country code, no spaces/symbols | `79995551111` |
| `email` | Lowercase, Latin chars with @ | `mail@yandex.ru` |

### Optional Fields

| Field | Description |
|-------|-------------|
| `external_id` | Customer alphanumeric ID (no spaces) |
| Other fields | Gender, birth date, etc. |

### Example CSV
```csv
"email","phone","ext_id","key1","key2"
"abc@inbox.ru","79991112233","1","value1","value2"
"xyz@mail.ru","79994445566","2","value1","value2"
```

### CRM Hashing
When uploading hashed CRM data:
- Phone and email values must be SHA-256 hashed individually
- Enable "Hashed data" flag during upload
- Use `hashing_alg: "SHA256"` in confirm request

---

## device_matching_type

| Value | Description |
|-------|-------------|
| `CROSS_DEVICE` | Default. Expands audience to other devices of the same user |
| `IN_DEVICE` | Only uploaded devices. Available only for `idfa_gaid` content type |
