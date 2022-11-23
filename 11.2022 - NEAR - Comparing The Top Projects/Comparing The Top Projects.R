library(tidyverse)
library(plotly)

# reading data (last updated 2022-11-23)

swaps <- read_csv("11.2022 - NEAR - Comparing The Top Projects/Data/swaps.csv")
prices <- read_csv("11.2022 - NEAR - Comparing The Top Projects/Data/prices.csv")
new_users <- read_csv("11.2022 - NEAR - Comparing The Top Projects/Data/new_users.csv")


# transforming and merging data

prices <- prices %>% 
  rename(DATE = date,
         DEX = coin_id,
         PRICE = price,
         VOLUME = volume,
         MARKET_CAP = market_cap) 

new_users <- new_users %>% 
  rename(DATE = FIRST_DATE)


data <- swaps %>% 
  left_join(prices, by = c('DATE', 'DEX')) %>% 
  left_join(new_users, by = c('DATE', 'DEX')) %>% 
  filter(DATE >= '2022-05-01') %>% 
  arrange(DATE)


# writing csv for .Rmd

write_csv(data, file = "11.2022 - NEAR - Comparing The Top Projects/Data/data.csv")


# plot options

ggplot(data, aes(x = DATE, y = PRICE, color = DEX) ) +
  geom_line((size=1)) +
  theme_minimal() +
  xlab("Date") +
  ylab("") +
  scale_x_date(date_breaks = "1 month", date_labels = "%m-%Y")

plot_ly(data, type = 'scatter', mode = 'lines', color = ~DEX)%>%
  add_trace(x = ~DATE, y = ~PRICE)
