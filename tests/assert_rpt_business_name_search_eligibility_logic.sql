with cleaned as (
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
        end as expected_is_search_eligible
    from {{ ref('int_business_names_cleaned') }}
),

search as (
    select *
    from {{ ref('rpt_business_name_search') }}
)

select
    search.*,
    cleaned.expected_is_search_eligible
from search
inner join cleaned
    using (
        bn_abn,
        bn_name,
        bn_name_standardised,
        bn_status,
        bn_state_num,
        bn_state_of_reg,
        bn_reg_dt,
        bn_cancel_dt
    )
where search.is_search_eligible != cleaned.expected_is_search_eligible
