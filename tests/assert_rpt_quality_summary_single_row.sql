select *
from {{ ref('rpt_quality_summary') }}
qualify count(*) over () != 1
