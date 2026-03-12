# Common Use Cases

## 1. Upload CRM Segment (Email + Phone)

```bash
# Step 1: Prepare CSV file
cat > /tmp/crm_data.csv << 'EOF'
"email","phone"
"user1@mail.ru","79991112233"
"user2@yandex.ru","79994445566"
"user3@gmail.com","79997778899"
EOF

# Step 2: Upload file
bash scripts/create_segment.sh --type csv --file /tmp/crm_data.csv

# Step 3: Confirm segment (use segment ID from step 2)
bash scripts/confirm_segment.sh --id 12345 --name "CRM клиенты Q1" --content-type crm
```

## 2. Upload Mobile Device IDs

```bash
# Prepare file (one ID per line)
cat > /tmp/devices.txt << 'EOF'
aaaaaaaa-bbbb-cccc-1111-222222222200
aaaaaaaa-bbbb-cccc-1111-222222222201
AAAAAAAAA-BBBB-CCCC-1111-222222220000
EOF

# Upload
bash scripts/create_segment.sh --type file --file /tmp/devices.txt

# Confirm
bash scripts/confirm_segment.sh --id 12345 --name "Mobile Users" --content-type idfa_gaid
```

## 3. Upload Hashed CRM Data

```bash
# Upload
bash scripts/create_segment.sh --type csv --file /path/to/hashed_data.csv

# Confirm with hashing flag
bash scripts/confirm_segment.sh --id 12345 --name "Hashed CRM" --content-type crm \
  --hashed true --hashing-alg SHA256
```

## 4. Create Metrica-Based Segment

```bash
# From counter
bash scripts/create_segment.sh --type metrika --name "All Metrica Users" \
  --metrika-type counter_id --metrika-id 12345678

# From goal
bash scripts/create_segment.sh --type metrika --name "Goal Achievers" \
  --metrika-type goal_id --metrika-id 99999

# From Metrica segment
bash scripts/create_segment.sh --type metrika --name "Segment Import" \
  --metrika-type segment_id --metrika-id 55555
```

## 5. Create Lookalike Segment

```bash
# Find similar users to segment 12345, similarity level 3 (1-5)
bash scripts/create_segment.sh --type lookalike --name "Similar to Buyers" \
  --lookalike-link 12345 --lookalike-value 3

# Without maintaining device/geo distribution
bash scripts/create_segment.sh --type lookalike --name "Similar Wide" \
  --lookalike-link 12345 --lookalike-value 2 \
  --maintain-device false --maintain-geo false
```

## 6. Create Geo Circle Segment

```bash
# People living near Moscow center (500m radius)
bash scripts/create_segment.sh --type geo --name "Moscow Center Residents" \
  --geo-type home --radius 500 \
  --points '[{"latitude":55.7558,"longitude":37.6173,"description":"Kremlin"}]'

# Regular visitors of a location (visited 3+ times in 30 days)
bash scripts/create_segment.sh --type geo --name "Regular Visitors" \
  --geo-type condition --radius 200 \
  --period-length 30 --times-quantity 3 \
  --points '[{"latitude":55.75,"longitude":37.62,"description":"Shop"}]'
```

## 7. Create Geo Polygon Segment

```bash
bash scripts/create_segment.sh --type geo_polygon --name "Business District" \
  --geo-type work \
  --polygons '[{"points":[{"latitude":55.75,"longitude":37.60},{"latitude":55.76,"longitude":37.63},{"latitude":55.74,"longitude":37.64},{"latitude":55.73,"longitude":37.61}],"description":"Central district"}]'
```

## 8. Create Pixel-Based Segment

```bash
# Users who triggered pixel more than 5 times in 30 days from Google
bash scripts/create_segment.sh --type pixel --name "Active Pixel Users" \
  --pixel-id 123 --period-length 30 --times-quantity 5 --times-op gt \
  --utm-source google
```

## 9. Modify Segment Data

```bash
# Add records to existing segment
bash scripts/modify_segment.sh --id 12345 --file /tmp/new_records.csv --mod-type addition

# Remove records from segment
bash scripts/modify_segment.sh --id 12345 --file /tmp/remove_records.csv --mod-type subtraction

# Replace all data
bash scripts/modify_segment.sh --id 12345 --file /tmp/full_data.csv --mod-type replace
```

## 10. Manage Pixel Tracking

```bash
# List all pixels
bash scripts/pixels.sh --action list

# Create new pixel
bash scripts/pixels.sh --action create --name "Landing Page Pixel"

# Rename pixel
bash scripts/pixels.sh --action edit --id 123 --name "New Landing Pixel"

# Delete pixel
bash scripts/pixels.sh --action delete --id 123

# Restore deleted pixel
bash scripts/pixels.sh --action undelete --id 123
```

## 11. Share Segment Access

```bash
# List who has access to segment
bash scripts/grants.sh --segment-id 12345 --action list

# Give edit access
bash scripts/grants.sh --segment-id 12345 --action add \
  --user-login colleague --permission edit --comment "Campaign manager"

# Give view-only access
bash scripts/grants.sh --segment-id 12345 --action add \
  --user-login analyst --permission view

# Revoke access
bash scripts/grants.sh --segment-id 12345 --action delete --user-login colleague
```

## 12. Manage Account Delegates

```bash
# List delegates
bash scripts/delegates.sh --action list

# Add delegate with edit permissions
bash scripts/delegates.sh --action add --user-login partner --permission edit

# Remove delegate
bash scripts/delegates.sh --action delete --user-login partner
```

## 13. View Accounts

```bash
# List accounts where you are a representative
bash scripts/accounts.sh
```

## 14. Custom API Call via common.sh

```bash
#!/bin/bash
source /path/to/scripts/common.sh
load_config

# Custom GET request
response=$(audience_get "management/segments" "limit=5&offset=10")
echo "$response" | format_json

# Custom POST request
response=$(audience_post "management/segments/create_metrika" \
  '{"segment":{"name":"Custom","metrika_segment_type":"counter_id","metrika_segment_id":12345}}')
echo "$response" | format_json
```
