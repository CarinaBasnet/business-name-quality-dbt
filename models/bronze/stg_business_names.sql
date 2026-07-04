select
    source_file_name,
    source_row_number,
    file_content_key,
    file_last_modified,
    scan_timestamp,

    _id,
    trim(register_name) as register_name,
    trim(bn_name) as bn_name,
    upper(trim(bn_status)) as bn_status,
    try_to_date(bn_reg_dt, 'DD/MM/YYYY') as bn_reg_dt,
    try_to_date(bn_cancel_dt, 'DD/MM/YYYY') as bn_cancel_dt,
    trim(bn_state_num) as bn_state_num,
    upper(trim(bn_state_of_reg)) as bn_state_of_reg,
    trim(bn_abn) as bn_abn,
    try_to_timestamp_ntz(extract_loaded_at) as extract_loaded_at,
    source_resource_id,

    current_timestamp() as dbt_loaded_at

from {{ source('raw', 'VW_BUSINESS_NAMES') }}