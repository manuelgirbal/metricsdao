library(tidyverse)
library(geckor)
library(lubridate)

# getting data from Coingecko's free API (https://www.coingecko.com/)

ref <- coin_history(coin_id = "ref-finance", 
                                vs_currency = "usd", 
                                days = "max")

ref <- ref %>% 
  mutate(date = date(timestamp)) %>% 
  group_by(date, coin_id) %>% 
  summarise(price = mean(price),
            volume = mean(total_volume),
            market_cap = mean(market_cap))

jumbo <- coin_history(coin_id = "jumbo-exchange", 
                    vs_currency = "usd", 
                    days = "max")

jumbo <- jumbo %>% 
  mutate(date = date(timestamp)) %>% 
  group_by(date, coin_id) %>% 
  summarise(price = mean(price),
            volume = mean(total_volume),
            market_cap = mean(market_cap))


# table join and transformation

prices <- rbind(ref, jumbo)

prices <- prices %>% 
  mutate(coin_id = case_when(
    coin_id == 'ref-finance' ~ 'ref',
    TRUE ~ 'jumbo'
  ))


# writing csv

write_csv(prices, file = "11.2022 - NEAR - Comparing The Top Projects/Data/prices.csv")




