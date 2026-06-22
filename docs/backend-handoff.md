# PawPawLand — Backend Handoff Note

**Date:** 2026-06-16  
**Focus:** Backend foundation (NestJS + PostGIS)  
**Repo path:** `~/Developer/PawPawLand`

---

## Environment setup (already done)

| Tool | Status | Notes |
|------|--------|-------|
| Git | Ready | Repo initialized on `main`, **no commits yet** |
| Homebrew | Installed | v6.0.2 |
| Node / npm | Installed | Node v26.3.0, npm 11.16.0 |
| Xcode / Swift | Ready | For future `ios/` work |
| Docker Desktop | Installed | Compose plugin linked at `~/.docker/cli-plugins/docker-compose` |
| PostgreSQL/PostGIS | Running | Container `pawpawland-db`, healthy |

### Docker Compose plugin fix (if needed on another machine)

If `docker compose` fails with "unknown command", link the plugin:

```bash
mkdir -p ~/.docker/cli-plugins
ln -sf /Applications/Docker.app/Contents/Resources/cli-plugins/docker-compose ~/.docker/cli-plugins/docker-compose
```

---

## What was accomplished today

### 1. Project scaffold

```
PawPawLand/
├── backend/              # NestJS API (fully scaffolded)
├── ios/                  # Empty — not started
├── docs/                 # Documentation
├── infrastructure/
│   └── db/init.sql       # Enables PostGIS extension on first DB boot
├── compose.yaml          # PostGIS container definition
├── .gitignore
└── README.md             # Empty placeholder
```

### 2. NestJS API (`backend/`)

- Created with `@nestjs/cli` (strict TypeScript, npm)
- Packages: `@nestjs/typeorm`, `typeorm`, `pg`, `@nestjs/config`
- Dev server runs on **port 3000**

### 3. PostgreSQL + PostGIS (Docker)

- Image: `postgis/postgis:16-3.4`
- Container: `pawpawland-db`
- Port: `5432`
- Credentials (also in `backend/.env`):

  | Variable | Value |
  |----------|-------|
  | `DB_HOST` | `localhost` |
  | `DB_PORT` | `5432` |
  | `DB_USERNAME` | `pawpaw` |
  | `DB_PASSWORD` | `pawpaw` |
  | `DB_DATABASE` | `pawpawland` |

- `infrastructure/db/init.sql` runs `CREATE EXTENSION IF NOT EXISTS postgis;` on first container start

### 4. Database connection

- TypeORM configured in `backend/src/app.module.ts`
- `synchronize: true` in dev (auto-creates tables — **replace with migrations before production**)
- Config loaded from `backend/.env` (gitignored; template at `backend/.env.example`)

### 5. `parks` table

Created by TypeORM from `backend/src/parks/entities/park.entity.ts`:

| Column | Type |
|--------|------|
| `id` | `uuid` (PK) |
| `name` | `varchar(255)` |
| `description` | `text` (nullable) |
| `address` | `varchar(500)` (nullable) |
| `location` | `geometry(Point, 4326)` (PostGIS) |
| `created_at` | `timestamp` |
| `updated_at` | `timestamp` |

### 6. `GET /parks` endpoint

- **Route:** `GET http://localhost:3000/parks`
- **Module:** `backend/src/parks/`
- **Response shape:** JSON array with `id`, `name`, `description`, `address`, `latitude`, `longitude`, `createdAt`, `updatedAt`
- PostGIS `POINT(lng lat)` is converted to separate `latitude` / `longitude` fields in the API response
- **Seed data:** On first startup, if the table is empty, inserts:
  - Central Park (NYC)
  - Golden Gate Park (SF)

### 7. Verified working

```bash
curl http://localhost:3000/parks
# Returns 2 parks with lat/lng

docker compose exec db psql -U pawpaw -d pawpawland -c "SELECT name, ST_AsText(location) FROM parks;"
# Returns PostGIS POINT geometries
```

---

## How to run locally

**Terminal 1 — database:**
```bash
cd ~/Developer/PawPawLand
docker compose up -d
```

**Terminal 2 — API:**
```bash
cd ~/Developer/PawPawLand/backend
npm install          # first time only
npm run start:dev
```

**Test:**
```bash
curl http://localhost:3000/parks
```

---

## Git status

- Branch: `main`
- **No commits yet** — all files are untracked
- `.env` is gitignored; use `backend/.env.example` as reference

Suggested first commit when ready:
```bash
git add .
git commit -m "Add NestJS backend with PostGIS parks API"
```

---

## Next steps (recommended priority)

### Backend — near term

1. **`POST /parks`** — create new parks with name, address, lat/lng
2. **`GET /parks/:id`** — fetch a single park by UUID
3. **`GET /parks/nearby?lat=&lng=&radius=`** — PostGIS distance/radius query (`ST_DWithin`)
4. **Input validation** — add `class-validator` + `class-transformer` DTOs for request bodies
5. **Migrations** — replace `synchronize: true` with TypeORM migrations
6. **Error handling** — global exception filter, consistent error response format
7. **Tests** — unit tests for `ParksService`, e2e test for `GET /parks`

### Backend — medium term

8. Additional entities (e.g. dog-friendly amenities, reviews, user favorites)
9. Auth (JWT or similar) if user accounts are needed
10. Add API service to `compose.yaml` so backend runs in Docker alongside DB
11. OpenAPI/Swagger docs (`@nestjs/swagger`)

### iOS (`ios/`)

12. Create SwiftUI app in Xcode inside `ios/`
13. Call `GET /parks` from the iOS client
14. Display parks on a map (MapKit) using returned lat/lng

### Infrastructure / DevOps

15. Populate root `README.md` with project overview and run instructions
16. CI pipeline (lint, test, build)
17. Production deployment config in `infrastructure/`

---

## Key files to read first

| File | Purpose |
|------|---------|
| `compose.yaml` | PostGIS Docker service |
| `backend/src/app.module.ts` | TypeORM + config wiring |
| `backend/src/parks/entities/park.entity.ts` | Parks table schema |
| `backend/src/parks/parks.service.ts` | Business logic + seed data |
| `backend/src/parks/parks.controller.ts` | `GET /parks` route |
| `backend/.env.example` | Environment variable template |

---

## Known caveats

- `synchronize: true` is enabled for dev convenience — do not use in production
- Seed data runs in `ParksService.onModuleInit()` — only inserts when table is empty
- `brew install docker` (formula) conflicts with Docker Desktop CLI; prefer Docker Desktop's `docker` binary or run `brew uninstall docker` if issues arise
- Empty folders (`ios/`, etc.) are not tracked by git until they contain files
