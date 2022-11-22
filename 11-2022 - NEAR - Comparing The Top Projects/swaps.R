# Table docs at https://docs.metricsdao.xyz/data-curation/data-curation/near/table-documentation

library(tidyverse)
library(shroomDK)

# querying data 

query <- create_query_token(
  query = "select date(block_timestamp) as date,
                  case 
                    when platform like '%ref%' then 'ref'
                    when platform like '%jumbo%' then 'jumbo'
                    else 'other'
                  end as dex,
                  token_in,
                  round(sum(amount_in),2) as amount,
                  count(distinct trader) as traders
          from near.core.ez_dex_swaps
            where (platform like '%ref%'
                  or platform like '%jumbo%')
              and (token_in = 'USDT' 
                  or token_in = 'USDC'
                  or token_in = 'USN'
                  or token_in = 'DAI')
          group by 1, 2, 3",
  api_key = readLines("11-2022 - NEAR - Comparing The Top Projects/api_key.txt"),
  ttl = 15,
  cache = TRUE)

swaps <- get_query_from_token(query$token, readLines("11-2022 - NEAR - Comparing The Top Projects/api_key.txt"), 1, 10000)


# transforming data

swaps <- as_tibble(clean_query(swaps, try_simplify = TRUE))

swaps <- swaps %>% 
  mutate(DATE = as_date(DATE))


# writing csv

write_csv(swaps, file = "11-2022 - NEAR - Comparing The Top Projects/Data/swaps.csv")
