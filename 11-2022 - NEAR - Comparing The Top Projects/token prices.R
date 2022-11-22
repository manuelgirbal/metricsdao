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

near <- coin_history(coin_id = "near", 
                      vs_currency = "usd", 
                      days = "max")

near <- near %>% 
  mutate(date = date(timestamp)) %>% 
  group_by(date, coin_id) %>% 
  summarise(price = mean(price),
            volume = mean(total_volume),
            market_cap = mean(market_cap))


# table join

prices <- rbind(near, ref, jumbo)


# writing csv

write_csv(prices, file = "11-2022 - NEAR - Comparing The Top Projects/Data/prices.csv")




