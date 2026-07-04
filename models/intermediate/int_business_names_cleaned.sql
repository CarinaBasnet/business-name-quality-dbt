with base as (

    select *
    from {{ ref('stg_business_names') }}

),

standardised as (

    select
        *,

        upper(
            regexp_replace(
                regexp_replace(trim(bn_name), '[^A-Za-z0-9 ]', ''),
                '\\s+',
                ' '
            )
        ) as bn_name_standardised,

        case 
            when bn_abn is null or length(bn_abn) != 11 then 1 
            else 0 
        end as flag_invalid_abn,

        case 
            when bn_name is null or trim(bn_name) = '' then 1 
            else 0 
        end as flag_missing_business_name,

        case 
            when bn_status not in ('REGISTERED', 'DEREGISTERED') then 1 
            else 0 
        end as flag_invalid_status,

        case 
            when bn_status = 'REGISTERED' and bn_cancel_dt is not null then 1 
            else 0 
        end as flag_registered_with_cancel_date

    from base

),

deduped as (

    select
        *,
        row_number() over (
            partition by bn_abn, bn_name_standardised
            order by file_last_modified desc, source_row_number desc
        ) as duplicate_rank
    from standardised

)

select
    *,
    case 
        when duplicate_rank > 1 then 1 
        else 0 
    end as flag_duplicate

from deduped
