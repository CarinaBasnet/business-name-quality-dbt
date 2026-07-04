select
    count(*) as total_rows,
    sum(flag_invalid_abn) as invalid_abn_count,
    sum(flag_missing_business_name) as missing_business_name_count,
    sum(flag_invalid_status) as invalid_status_count,
    sum(flag_registered_with_cancel_date) as registered_with_cancel_date_count,
    sum(flag_duplicate) as duplicate_count
from {{ ref('int_business_names_cleaned') }}