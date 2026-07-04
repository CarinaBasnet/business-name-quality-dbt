select
    'raw' as layer,
    count(*) as row_count
from {{ source('raw', 'VW_BUSINESS_NAMES') }}

union all
select
    'bronze' as layer,
    count(*) as row_count
from {{ ref('stg_business_names') }}

union all

select
    'silver' as layer,
    count(*) as row_count
from {{ ref('int_business_names_cleaned') }}

union all

select
    'gold_search_eligible' as layer,
    count(*) as row_count
from {{ ref('rpt_business_name_search') }}
where is_search_eligible = 1