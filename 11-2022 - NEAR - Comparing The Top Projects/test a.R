# Table docs at https://docs.metricsdao.xyz/data-curation/data-curation/near/table-documentation

library(tidyverse)
library(shroomDK)

query <- create_query_token(
  query = "SELECT * FROM near.core.dim_staking_pools",
  api_key = readLines("11-2022 - NEAR City Layout/api_key.txt"),
  ttl = 15,
  cache = TRUE)

near_sp <- get_query_from_token(query$token, readLines("11-2022 - NEAR City Layout/api_key.txt"), 1, 10000)

near_sp <- as_tibble(clean_query(near_sp, try_simplify = TRUE))