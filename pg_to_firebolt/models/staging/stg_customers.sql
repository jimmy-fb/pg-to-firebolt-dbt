with source as (
    select * from {{ source('postgres_raw', 'customers') }}
),

renamed as (
    select
        customer_id::bigint                       as customer_id,
        first_name,
        last_name,
        lower(trim(email))                        as email,
        upper(trim(country))                      as country_code,
        created_at::timestamp                     as created_at
    from source
)

select * from renamed
