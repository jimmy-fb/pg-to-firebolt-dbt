# pg_to_firebolt

A dbt pipeline that reads from a **PostgreSQL** source and writes to **Firebolt** as the destination.

---

## How it works

```
PostgreSQL (source)
  └── orders, customers
        │
        ▼  staging models — views created on PostgreSQL
  stg_orders, stg_customers
        │
        ▼  mart models — tables created in Firebolt
  fct_orders, agg_customer_revenue
```

---

## Step 1 — Configure your source (PostgreSQL)

This project expects a running PostgreSQL instance. You can use the bundled Docker setup or point to your own.

### Option A — Use Docker (local)

```bash
docker compose up -d postgres
```

This starts `postgres:16-alpine` on `localhost:5432` with:

| Setting | Value |
|---------|-------|
| Host | `localhost` |
| Port | `5432` |
| User | `postgres` |
| Password | `postgres` |
| Database | `postgres` |
| Schema | `public` |

### Option B — Use your own PostgreSQL

Set the following variables in your `.env` file:

```env
PG_HOST=your-postgres-host
PG_PORT=5432
PG_USER=your-user
PG_PASSWORD=your-password
PG_DBNAME=your-database
PG_SCHEMA=public
```

Then load the test tables into it:

```bash
make seed
```

This runs `dbt seed` and inserts the `orders` (10 rows) and `customers` (7 rows) CSV files into the schema you configured.

---

## Step 2 — Configure your destination (Firebolt)

### Create a service account

1. Log in to [app.firebolt.io](https://app.firebolt.io)
2. Go to **Configure → Service Accounts** and create a new service account
3. Copy the **Client ID** and **Client Secret**

### Set Firebolt variables in `.env`

```env
FIREBOLT_CLIENT_ID=<your-service-account-id>
FIREBOLT_CLIENT_SECRET=<your-service-account-secret>
FIREBOLT_ACCOUNT=<your-account-name>
FIREBOLT_DATABASE=<your-database-name>
FIREBOLT_ENGINE=<your-engine-name>
FIREBOLT_SCHEMA=public
```

> `FIREBOLT_ENGINE` can be left blank to use the default engine attached to the database.

### Test the Firebolt connection

```bash
source .venv/bin/activate
cd pg_to_firebolt
dbt debug --target firebolt
```

A successful run prints `All checks passed`.

---

## Step 3 — Run the pipeline

```bash
make full-job
```

This executes in order:

| Step | Command | Target |
|------|---------|--------|
| Install packages | `dbt deps` | — |
| Load test data | `dbt seed` | PostgreSQL |
| Build staging views | `dbt run --select staging` | PostgreSQL |
| Build mart tables | `dbt run --select marts` | Firebolt |
| Run all tests | `dbt test` | Firebolt |

Or run each step individually:

```bash
make deps    # install dbt_utils
make seed    # load CSVs → PostgreSQL
make run     # staging on PG + marts on Firebolt
make test    # schema + singular tests
```

---

## Project layout

```
pg_to_firebolt/
├── seeds/
│   ├── orders.csv          # 10 sample orders
│   └── customers.csv       # 7 sample customers
├── models/
│   ├── staging/
│   │   ├── _sources.yml    # PostgreSQL source declaration
│   │   ├── stg_orders.sql
│   │   └── stg_customers.sql
│   └── marts/
│       ├── fct_orders.sql           # denormalised fact table → Firebolt
│       └── agg_customer_revenue.sql # per-customer aggregation → Firebolt
└── tests/
    └── assert_no_negative_amounts.sql
```

---

## Prerequisites

- Python 3.12
- Docker (for local PostgreSQL)
- A Firebolt account

Install Python dependencies once:

```bash
make install
```
