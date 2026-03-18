# pg_to_firebolt

A dbt pipeline that reads from a **PostgreSQL** source and writes to **Firebolt** as the destination.

```
PostgreSQL (source)  ──►  dbt transformations  ──►  Firebolt (destination)
```

---

## Prerequisites

- Python 3.12
- Docker (only if using the local PostgreSQL option)
- A Firebolt account — [sign up at app.firebolt.io](https://app.firebolt.io)

Install Python dependencies once:

```bash
make install
```

---

## dbt connection configuration (`profiles.yml`)

dbt uses a file called `profiles.yml` to know where to connect.  
This project defines **two named outputs** inside one profile — one for the source, one for the destination.

The file lives at `~/.dbt/profiles.yml`. It is already created when you run `make install`, but you need to fill in your own credentials.

```yaml
pg_to_firebolt:
  target: firebolt          # default target when you run dbt commands

  outputs:

    # ── Source: PostgreSQL ────────────────────────────────────────────────────
    postgres:
      type: postgres
      host: localhost        # change to your PG host
      port: 5432
      user: postgres
      password: postgres
      dbname: postgres
      schema: public
      threads: 4

    # ── Destination: Firebolt ─────────────────────────────────────────────────
    firebolt:
      type: firebolt
      client_id: <your-service-account-id>
      client_secret: <your-service-account-secret>
      account_name: <your-account-name>
      database: <your-database-name>
      engine_name: <your-engine-name>   # leave blank for default engine
      schema: public
      threads: 4
```

> The actual file uses environment variables (`{{ env_var(...) }}`) so you never commit secrets.  
> Copy `.env.example` → `.env` and fill in your values — they are loaded automatically.

---

## Configure the source (PostgreSQL)

### Option A — Local Docker (recommended for testing)

```bash
docker compose up -d postgres
```

Starts `postgres:16-alpine` on `localhost:5432`. No changes needed in `profiles.yml` — the defaults match.

### Option B — Your own PostgreSQL

Edit the `postgres` output in `~/.dbt/profiles.yml`, or set these variables in `.env`:

```env
PG_HOST=your-pg-host
PG_PORT=5432
PG_USER=your-user
PG_PASSWORD=your-password
PG_DBNAME=your-database
PG_SCHEMA=public
```

Verify the connection:

```bash
cd pg_to_firebolt
dbt debug --target postgres
```

---

## Configure the destination (Firebolt)

### 1. Create a service account

1. Log in to [app.firebolt.io](https://app.firebolt.io)
2. Go to **Configure → Service Accounts → Create**
3. Copy the **Client ID** and **Client Secret**

### 2. Fill in the Firebolt credentials

Edit the `firebolt` output in `~/.dbt/profiles.yml`, or set these variables in `.env`:

```env
FIREBOLT_CLIENT_ID=<your-service-account-id>
FIREBOLT_CLIENT_SECRET=<your-service-account-secret>
FIREBOLT_ACCOUNT=<your-account-name>
FIREBOLT_DATABASE=<your-database-name>
FIREBOLT_ENGINE=<your-engine-name>
FIREBOLT_SCHEMA=public
```

### 3. Verify the connection

```bash
cd pg_to_firebolt
dbt debug --target firebolt
```

A successful run prints `All checks passed`.

---

## Start the pipeline

Once both connections are verified, run the full job:

```bash
make full-job
```

This executes the following steps in order:

| # | Step | dbt command | Runs on |
|---|------|-------------|---------|
| 1 | Install packages | `dbt deps` | — |
| 2 | Load test data | `dbt seed` | PostgreSQL |
| 3 | Build staging views | `dbt run --select staging` | PostgreSQL |
| 4 | Build mart tables | `dbt run --select marts` | Firebolt |
| 5 | Run all tests | `dbt test` | Firebolt |

Or run steps individually:

```bash
make deps    # step 1 — install dbt_utils
make seed    # step 2 — load CSV data into PostgreSQL
make run     # steps 3 + 4 — staging on PG, marts on Firebolt
make test    # step 5 — all schema and singular tests
```

---

## Project layout

```
pg_to_firebolt/
├── seeds/
│   ├── orders.csv              # 10 sample orders
│   └── customers.csv           # 7 sample customers
├── models/
│   ├── staging/                # views built on PostgreSQL
│   │   ├── _sources.yml        # declares the PG tables as dbt sources
│   │   ├── stg_orders.sql
│   │   └── stg_customers.sql
│   └── marts/                  # tables built in Firebolt
│       ├── fct_orders.sql
│       └── agg_customer_revenue.sql
└── tests/
    └── assert_no_negative_amounts.sql
```
