{{
    config(
        materialized = 'table'
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.country_code,
        o.order_date,
        o.status,
        o.amount_usd,

        -- derived metrics
        case
            when o.status = 'completed' then o.amount_usd
            else 0
        end                                                 as completed_revenue_usd,

        date_trunc('month', o.order_date)                   as order_month
    from orders o
    left join customers c using (customer_id)
)

select * from final
