select
    bn_abn,
    bn_name,
    bn_name_standardised,
    bn_status,
    bn_state_num,
    bn_state_of_reg,
    bn_reg_dt,
    bn_cancel_dt,

    case
        when flag_missing_business_name = 0
         and flag_invalid_abn = 0
         and flag_duplicate = 0
         and bn_status = 'REGISTERED'
        then 1
        else 0
    end as is_search_eligible

from {{ ref('int_business_names_cleaned') }}