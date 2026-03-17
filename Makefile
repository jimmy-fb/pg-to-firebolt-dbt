# ── dbt job: PostgreSQL → Firebolt ───────────────────────────────────────────
SHELL        := /bin/bash
VENV         := .venv
DBT          := source $(VENV)/bin/activate && cd pg_to_firebolt && dbt
ENV_FILE     := ../.env

# Load .env if present
ifneq (,$(wildcard $(ENV_FILE)))
  include $(ENV_FILE)
  export
endif

.PHONY: install deps seed run test docs full-job

## Install Python deps
install:
	python3.12 -m venv $(VENV)
	source $(VENV)/bin/activate && pip install dbt-firebolt dbt-postgres --quiet

## Install dbt packages (dbt_utils etc.)
deps:
	$(DBT) deps

## Load seed data into PostgreSQL (test data)
seed:
	$(DBT) seed --target postgres

## Run staging models against PostgreSQL, then build marts in Firebolt
run:
	$(DBT) run --select staging --target postgres
	$(DBT) run --select marts  --target firebolt

## Run all schema + singular tests
test:
	$(DBT) test --target firebolt

## Generate & serve docs
docs:
	$(DBT) docs generate --target firebolt
	$(DBT) docs serve

## Full end-to-end job (seed → run → test)
full-job: deps seed run test
	@echo "✅  pg_to_firebolt job complete"
