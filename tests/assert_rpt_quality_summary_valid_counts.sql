select *
from {{ ref('rpt_quality_summary') }}
where total_rows < 0
   or invalid_abn_count < 0
   or missing_business_name_count < 0
   or invalid_status_count < 0
   or registered_with_cancel_date_count < 0
   or duplicate_count < 0
   or invalid_abn_count > total_rows
   or missing_business_name_count > total_rows
   or invalid_status_count > total_rows
   or registered_with_cancel_date_count > total_rows
   or duplicate_count > total_rows
