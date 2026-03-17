{{
    config(
        materialized = 'table'
    )
}}

with fct as (
    select * from {{ ref('fct_orders') }}
),

aggregated as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        country_code,
        count(*)                                            as total_orders,
        sum(amount_usd)                                     as total_spend_usd,
        sum(completed_revenue_usd)                          as completed_revenue_usd,
        min(order_date)                                     as first_order_date,
        max(order_date)                                     as last_order_date
    from fct
    group by 1, 2, 3, 4, 5
)

select * from aggregated
