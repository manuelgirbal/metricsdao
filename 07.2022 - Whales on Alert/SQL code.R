#The code used to query from Flipside Crypto's database Velocity was:

## Part 1: what is a Whale?

# with maybalance as (
#     select user_address,
#     balance as may22balance
#     from flipside_prod_db.ethereum.erc20_balances
#     where balance_date = '2022-05-01'
#     and symbol = 'ETH'
#     and amount_usd > 100000
#     and label_type is null --we just count addresses that are not labeled, excluding dex, cex, dapp, etc...
#   )
# ,
# 
# julybalance as (
#   select user_address as user_address2,
#   balance as july22balance
#   from flipside_prod_db.ethereum.erc20_balances
#   where balance_date = '2022-07-15'
#   and symbol = 'ETH'
#   and amount_usd > 100000
#   and label_type is null --we just count addresses that are not labeled, excluding dex, cex, dapp, etc...
# )
# 
# select user_address,
# may22balance,
# july22balance
# from maybalance
# left join julybalance
# on maybalance.user_address = julybalance.user_address2



## Part 2: transaction history

# with whales as (
#   select user_address
#   from flipside_prod_db.ethereum.erc20_balances
#   where balance_date = '2022-07-15'
#   and symbol = 'ETH'
#   and balance >= 10353.91 -- 99 percentile
#   and label_type is null
# )
# ,
# 
# transactions as (
#   select date(block_timestamp) as date,
#   origin_from_address,
#   eth_to_address,
#   amount
#   from ethereum.core.ez_eth_transfers
#   where origin_from_address in (select * from whales)
#   and date > '2022-05-01'
# )
# ,
# 
# finaljoin as (
#   select date,
#   origin_from_address,
#   eth_to_address,
#   amount,
#   address_name,
#   label_type, 
#   label_subtype,
#   label
#   from transactions
#   left join ethereum.core.dim_labels
#   on transactions.eth_to_address = ethereum.core.dim_labels.address
# )
# 
# select *
#   from finaljoin 

https://flipsidecrypto.xyz/ 

