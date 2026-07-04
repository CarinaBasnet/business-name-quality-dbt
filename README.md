# Business Name Quality & Reconciliation dbt Project

This project uses dbt to validate, standardise, and reconcile business name records loaded into Snowflake. The core goal is to make data quality issues visible early, preserve enough lineage to trace records back to source files, and publish simple gold-layer outputs for operational review and downstream search use cases.

## What the project does

The project takes raw business name extracts, applies light standardisation in staging, flags quality issues in the silver layer, and publishes summary-style gold models for reconciliation and reporting.

Key quality checks currently implemented include:
- invalid ABN length
- missing business names
- unexpected registration status values
- registered records with cancellation dates
- duplicate business names based on ABN and standardised name

## Project structure

The project follows a bronze / silver / gold pattern:

- `models/raw/` declares the raw Snowflake source used by the project
- `models/bronze/` standardises and types raw fields in `stg_business_names`
- `models/silver/` applies business rules and DQ flags in `int_business_names_cleaned`
- `models/gold/` publishes reporting and reconciliation outputs:
  - `rpt_business_name_search` exposes business-name records with a search eligibility flag
  - `rpt_quality_summary` provides one-row issue counts across the cleaned dataset
  - `rpt_reconciliation_summary` compares row counts across pipeline layers

## DAG overview

```text
source('raw', 'VW_BUSINESS_NAMES')
  -> stg_business_names
    -> int_business_names_cleaned
      -> rpt_business_name_search
      -> rpt_quality_summary
      -> rpt_reconciliation_summary
```

## Model intent

### `stg_business_names`
Standardises raw fields from the staged source extract. This is where trimming, casing, and date parsing happen, while source lineage columns are preserved for traceability.

### `int_business_names_cleaned`
Applies the project’s main reconciliation logic. It standardises business names for matching, derives issue flags, and ranks duplicates within each `bn_abn` + standardised-name grouping.

### `rpt_business_name_search`
Publishes a consumer-facing subset of attributes with an `is_search_eligible` flag so downstream users can filter to records that pass the project’s core validation rules.

### `rpt_quality_summary`
Produces a one-row snapshot of key data quality issue counts. This is the quickest model to inspect when checking overall extract health.

### `rpt_reconciliation_summary`
Compares row counts between layers so it’s easy to see whether records were dropped, deduplicated, or filtered out on the way to gold outputs.

## Tests and documentation

The project now includes:
- source and model descriptions across raw, bronze, silver, and gold layers
- built-in dbt tests for high-signal columns such as identifiers, status fields, and rule flags
- singular tests that protect the one-row quality summary and ensure issue counts stay within sensible bounds

These tests are intentionally practical. For a reconciliation project, the useful checks are the ones that catch broken assumptions in the reporting layer, not just generic null coverage everywhere.

## How to run

Install dependencies if packages are added later, then build the project:

```bash
dbt build
```

To validate just the reporting layer and its dependencies:

```bash
dbt build --select +rpt_quality_summary+
dbt build --select +rpt_reconciliation_summary+
```

To generate docs:

```bash
dbt docs generate
```

## Recommended next improvements

A few additions would make this repo stronger:
- add source freshness config once the expected landing cadence is known
- add custom generic tests for ABN format if you want stricter validation than length
- add exposures or semantic-layer objects if these gold outputs feed dashboards or apps
- add owners and tags in YAML so responsibility for DQ checks is explicit
