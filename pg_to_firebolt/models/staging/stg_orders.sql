with source as (
    select * from {{ source('postgres_raw', 'orders') }}
),

renamed as (
    select
        order_id::bigint                          as order_id,
        customer_id::bigint                       as customer_id,
        order_date::date                          as order_date,
        lower(trim(status))                       as status,
        amount::numeric(12, 2)                    as amount_usd
    from source
)

select * from renamed
