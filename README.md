# Yandex Audience API Skill

Agent Skill for managing [Yandex Audience](https://audience.yandex.ru/) segments, pixels, grants, and delegates via API v1.

Works with [Claude Code](https://claude.ai/code), [Cursor](https://cursor.com/), [Gemini CLI](https://geminicli.com/), and any other [Agent Skills](https://agentskills.io/)-compatible tool.

## Install

```bash
npx skills add BugzBunnyViber/yandex-audience-skill
```

## Setup

1. Get an OAuth token at [oauth.yandex.ru](https://oauth.yandex.ru/client/new) with Yandex Audience permissions
2. Configure the token:

```bash
cp config/.env.example config/.env
# Edit config/.env and paste your token
```

3. Verify connection:

```bash
bash scripts/check_connection.sh
```

## What It Can Do

### Segments
- **Create** from files (CRM, device IDs, MAC), Yandex Metrica, AppMetrica, lookalike, geo circles, geo polygons, pixels
- **List** all segments with filters and pagination
- **Edit** segment names
- **Delete** segments
- **Reprocess** segments
- **Modify data** in file-based segments (add, remove, replace records)

### Pixels
- Create, list, edit, delete, restore tracking pixels

### Permissions (Grants)
- Grant edit/view access to segments for other users

### Delegates
- Add/remove account representatives

### Accounts
- List accounts where you are a representative

## Quick Examples

```bash
# List all segments
bash scripts/segments.sh --action list

# Upload CRM data
bash scripts/create_segment.sh --type csv --file /path/to/crm.csv

# Create lookalike segment
bash scripts/create_segment.sh --type lookalike --name "Similar Users" \
  --lookalike-link 12345 --lookalike-value 3

# Create geo segment (500m around a point)
bash scripts/create_segment.sh --type geo --name "Near Office" \
  --geo-type work --radius 500 \
  --points '[{"latitude":55.75,"longitude":37.62,"description":"Office"}]'

# Manage pixels
bash scripts/pixels.sh --action list
bash scripts/pixels.sh --action create --name "Landing Pixel"

# Share segment access
bash scripts/grants.sh --segment-id 12345 --action add \
  --user-login colleague --permission edit
```

## API Coverage

All 27 endpoints of Yandex Audience API v1 are covered. See [SKILL.md](SKILL.md) for full reference.

## Data Requirements

- **Min records:** 100 per file (bypass with `check_size=false`)
- **Max file size:** 1 GB
- **Encoding:** UTF-8 or Windows-1251
- **Hashing:** SHA-256 only (MD5 not supported since Jan 2025)
- **CRM format:** CSV with `email` and/or `phone` fields

## License

MIT
