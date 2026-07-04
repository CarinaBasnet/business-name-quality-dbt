# Business Name Data Quality Pipeline

## Overview

This project implements an end-to-end data quality pipeline for the Australian Register of Business Names dataset.

The objective is to show how an external dataset can be ingested, profiled, validated, transformed, and published into trusted reporting datasets that support business name search, reconciliation, autocomplete, and downstream analytics.

The project uses dbt's recommended project structure: `staging`, `intermediate`, and `marts`. Those folders map to medallion-style Snowflake schemas:

- `staging` → `bronze`
- `intermediate` → `silver`
- `marts` → `gold`

The gold outputs are also consumed by external Streamlit applications for business-facing access and summary reporting.

## Business Context

The Australian Business Register contains millions of registered business names. Before this data can be consumed reliably by applications or reporting tools, it needs to be validated, standardised, and reconciled.

This project demonstrates a practical analytics engineering workflow that:

- ingests data from an external source
- preserves source lineage and metadata
- applies business rules and data quality validation
- produces trusted reporting datasets
- monitors data quality through automated testing and summary reporting

Potential downstream use cases include:

- business name autocomplete
- business name matching
- customer onboarding validation
- reporting and analytics
- data reconciliation

## Solution Architecture

```text
Australian Business Register API
                │
                ▼
        Google Colab (Python)
                │
                ▼
            Local CSV File
                │
                ▼
       SnowSQL (PUT Command)
                │
                ▼
 Snowflake Internal Stage
(@BUSINESS_NAME_DQ.RAW.BUSINESS_NAME_STAGE)
                │
                ▼
      RAW View (VW_BUSINESS_NAMES)
                │
                ▼
          dbt Source
                │
      ┌─────────┴───────────────┐
      ▼                         ▼
 staging / bronze          tests + docs
      │
      ▼
intermediate / silver
      │
      ▼
    marts / gold
 ├── rpt_business_name_search
 ├── rpt_quality_summary
 └── rpt_reconciliation_summary
      │
      ▼
 Streamlit Apps
```

## Technology Stack

| Component | Technology |
| --- | --- |
| Data source | Australian Business Register API |
| Extraction | Google Colab (Python) |
| Warehouse | Snowflake |
| File ingestion | SnowSQL |
| Transformation | dbt |
| Version control | GitHub |
| Reporting | Streamlit applications |

## Project Structure

```text
.
├── models/
│   ├── raw/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── tests/
├── macros/
├── analyses/
├── snapshots/
├── dbt_project.yml
└── README.md
```

This repository contains the dbt transformation project. Streamlit applications consume the gold-layer outputs externally and are not stored in this repo.

The dbt folder structure maps directly to the warehouse schemas configured in `dbt_project.yml`:

| dbt folder | Warehouse schema |
| --- | --- |
| `staging` | `bronze` |
| `intermediate` | `silver` |
| `marts` | `gold` |

## Schema Naming Behavior

This project uses a custom `generate_schema_name` macro.

- For `target.name == 'PROD'`, models build directly into the configured schema names from `dbt_project.yml`: `bronze`, `silver`, and `gold`.
- For all other targets, models build into `<target.schema>_<configured_schema>` to keep development and CI objects isolated.

Examples:

- dev/default target with `target.schema = dbt_cbasnet` → `dbt_cbasnet_bronze`
- prod target with `target.name = 'PROD'` → `bronze`

## Implementation Journey

### 1. Data Extraction

The extraction step was run in Google Colab instead of a local Python environment due to machine restrictions on the development laptop.

That approach worked well for this case study because:

- the dataset only required a one-time extraction
- Snowflake Trial Edition does not support direct external API integrations for this workflow
- the generated CSV could be staged and loaded with a simple, repeatable process

### 2. Snowflake Data Ingestion

The extracted CSV was uploaded into a managed Snowflake stage using SnowSQL.

```sql
PUT file://business_names_extract.csv
@BUSINESS_NAME_DQ.RAW.BUSINESS_NAME_STAGE
AUTO_COMPRESS = TRUE;
```

Rather than loading directly into a physical raw table, the project reads the staged file through the raw view `VW_BUSINESS_NAMES`.

Benefits of that approach:

- preserved source metadata
- repeatable ingestion
- complete lineage and auditing
- stable dbt source definition for downstream models

### 3. dbt Transformations

#### Bronze / `stg_`

- standardises raw fields
- trims whitespace
- parses dates
- preserves lineage metadata
- adds ingestion timestamps

#### Silver / `int_`

- standardises business names for matching
- applies business rules
- deduplicates records
- generates quality flags

#### Gold / `rpt_`

- `rpt_business_name_search`
- `rpt_quality_summary`
- `rpt_reconciliation_summary`

The gold layer exposes business-ready outputs for reporting and downstream consumption, including search eligibility and reconciliation summaries.

## Data Quality Testing

The project combines dbt generic tests with custom SQL tests.

### Generic Tests

- not null
- unique
- accepted values

### Custom SQL Tests

- duplicate flag validation
- registered-with-cancellation-date rule validation
- search eligibility validation
- quality summary single-row assertion
- quality summary count validation
- reconciliation count ordering validation

## Documentation and Lineage

The project is designed to run through a production dbt job that:

- builds models
- runs data tests
- generates dbt documentation artifacts
- exposes end-to-end lineage across sources, models, and tests

## Streamlit Consumption

Streamlit applications consume the gold-layer models produced by this project.

Current business-facing use cases include:

- Business Name Search
- Quality Summary
- Reconciliation Summary

## Running the Project

### Prerequisites

Before running the project, ensure you have:

- Access to a Snowflake account with the required permissions to create and manage databases, schemas, stages, views, and tables
- A configured dbt Cloud project environment connected to your Snowflake account
- Access to the project's GitHub repository
- SnowSQL installed (required for uploading the source CSV to the Snowflake stage)
- Python or Google Colab (required only if re-running the data extraction process)

### Upload CSV

```sql
PUT file://<local_csv_path>
@BUSINESS_NAME_DQ.RAW.BUSINESS_NAME_STAGE;
```

### Execute dbt

```bash
dbt build
```

## Assumptions

- one-time extraction is sufficient for this case study
- Snowflake Trial Edition limitations prevent direct API ingestion in this workflow
- future files will continue to be uploaded into the managed Snowflake stage
- business name matching uses deterministic standardisation rather than fuzzy matching

## Future Enhancements

- incremental dbt models
- automated API ingestion
- source freshness monitoring
- ABN checksum validation
- fuzzy business name matching
- automated data quality alerting
- CI/CD with GitHub Actions
- dbt exposures and semantic layer extensions

## AI Usage

AI-assisted development tools were used to support solution design, SQL refinement, dbt model organisation, documentation, testing ideas, and implementation guidance.

All generated content was reviewed, modified, tested, and validated before implementation.

The final solution reflects the implemented project structure and behavior in this repository.
