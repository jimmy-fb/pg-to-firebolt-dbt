-- Singular test: no order should have a negative amount.
select order_id, amount_usd
from {{ ref('fct_orders') }}
where amount_usd < 0
