# pg_to_firebolt

A dbt project that moves data from a **PostgreSQL** source to **Firebolt** as the destination.

## Stack

| Layer | Tool |
|-------|------|
| Source | PostgreSQL (Docker) |
| Transformation | dbt 1.11 + dbt-postgres + dbt-firebolt |
| Destination | Firebolt |

## Quick start

### 1. Start PostgreSQL

```bash
docker compose up -d postgres
```

### 2. Configure credentials

```bash
cp .env.example .env
# fill in your Firebolt credentials in .env
```

### 3. Run the full dbt job

```bash
make full-job
```

This runs in order: `dbt deps` → `dbt seed` → `dbt run` (staging on PG, marts on Firebolt) → `dbt test`.

## Data flow

```
PostgreSQL (Docker)
  └── orders, customers  (loaded via dbt seed)
        │
        ▼  staging models (views on PG)
  stg_orders, stg_customers
        │
        ▼  mart models (tables in Firebolt)
  fct_orders, agg_customer_revenue
```

## Project layout

```
pg_to_firebolt/
├── seeds/            # CSV test data
├── models/
│   ├── staging/      # thin type-cast wrappers on PG sources
│   └── marts/        # enriched tables materialised in Firebolt
└── tests/            # singular tests
```

## Environment variables

See `.env.example` for all required variables.
