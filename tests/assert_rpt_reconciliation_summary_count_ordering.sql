with summary as (
    select layer, row_count
    from {{ ref('rpt_reconciliation_summary') }}
),

pivoted as (
    select
        max(case when layer = 'raw' then row_count end) as raw_count,
        max(case when layer = 'bronze' then row_count end) as bronze_count,
        max(case when layer = 'silver' then row_count end) as silver_count,
        max(case when layer = 'gold_search_eligible' then row_count end) as gold_search_eligible_count
    from summary
)

select *
from pivoted
where raw_count != bronze_count
   or bronze_count != silver_count
   or gold_search_eligible_count > silver_count
