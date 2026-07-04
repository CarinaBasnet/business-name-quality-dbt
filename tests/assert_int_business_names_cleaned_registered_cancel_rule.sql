select *
from {{ ref('int_business_names_cleaned') }}
where (
        bn_status = 'REGISTERED'
    and bn_cancel_dt is not null
    and flag_registered_with_cancel_date != 1
)
   or (
        not (bn_status = 'REGISTERED' and bn_cancel_dt is not null)
    and flag_registered_with_cancel_date != 0
)
