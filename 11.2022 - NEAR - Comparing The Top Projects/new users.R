# Table docs at https://docs.metricsdao.xyz/data-curation/data-curation/near/table-documentation

library(tidyverse)
library(shroomDK)

# querying data 

query <- create_query_token(
  query = "with base as 
              (
              select trader,
                     case 
                      when platform like '%ref%' then 'ref'
                      when platform like '%jumbo%' then 'jumbo'
                     else 'other'
                     end as dex,
                     min(date(block_timestamp)) as first_date
              from near.core.ez_dex_swaps
                where platform like '%ref%'
                   or platform like '%jumbo%'
              group by 1, 2
              )
              
              select first_date,
                     dex,
              	     count(trader) as new_users
              from base 
              group by 1, 2",
  api_key = readLines("11.2022 - NEAR - Comparing The Top Projects/api_key.txt"),
  ttl = 15,
  cache = TRUE)

new_users <- get_query_from_token(query$token, readLines("11.2022 - NEAR - Comparing The Top Projects/api_key.txt"), 1, 10000)


# transforming data

new_users <- as_tibble(clean_query(new_users, try_simplify = TRUE))




# writing csv

write_csv(new_users, file = "11.2022 - NEAR - Comparing The Top Projects/Data/new_users.csv")
