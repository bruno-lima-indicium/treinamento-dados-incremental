{{ config(
    materialized='incremental'
    , incremental_strategy='insert_overwrite'
    , partition_by={
        'field': 'order_ingestion_datetime'
        , 'data_type': 'datetime'
    }
)}}

with
    transform as (
        select
            cast(order_id as int) as order_id
            , cast(order_datetime as datetime) as order_datetime
            , cast(order_value as numeric) as order_value
            , order_status
            , order_payment_method
            , order_ingestion_datetime
        from {{ source('raw', 'orders-2022-09-26') }}
        {% if is_incremental() %}
            where extract(date from order_ingestion_datetime) in ({{ var('today_and_last_week') | join(',') }})
        {% endif %}
    )
select *
from transform