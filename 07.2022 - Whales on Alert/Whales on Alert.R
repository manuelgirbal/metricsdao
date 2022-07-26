library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

options(scipen=999)

data_1 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/7a4307c2-3d46-468b-85af-8a4b5cdf7feb/data/latest")
data_2 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/4f2ac609-f14c-4119-8130-2dc6c4ede5e0/data/latest")

data2_1 <- rawToChar(data_1$content)
data2_2 <- rawToChar(data_2$content)

data3_1 <- as_tibble(fromJSON(data2_1, flatten = TRUE))
whalesactivity <- as_tibble(fromJSON(data2_2, flatten = TRUE))

data3_1[is.na(data3_1)] <- 0
whalesactivity$DATE <- as_date(whalesactivity$DATE)


# Identify active wallets with a high balance of ETH (whales). 
# Visualize the ETH transaction history of these whales in May and June 2022. 

# Defining whales:
x <- quantile(data3_1$MAY22BALANCE, .99) # 99 percentile of all ETH hodlers that don't have a labeled account and that had more than 100000 USD in ETH on 2022-05-01

data3_1$whales <- if_else(data3_1$MAY22BALANCE >= x, "whale", "not whale")

table(data3_1$whales)

whalesbalance <- data3_1 %>% 
  filter(whales == 'whale') %>% 
  mutate(balance = JULY22BALANCE-MAY22BALANCE,
         percentual_balance = round((JULY22BALANCE-MAY22BALANCE)/MAY22BALANCE*100,2),
         outcome = case_when(
           percentual_balance == 0 ~ "kept",
           percentual_balance > 0 ~ "increased",
           percentual_balance == -100 ~ "sold all",
           TRUE ~ "sold some"
         ))


# Analyzing transactions:
# How many whales kept same balance? # How many hodl more now?

whalesbalance #renderDT

table(whalesbalance$outcome)

plot_ly(data = whalesbalance %>% filter(percentual_balance != 0),
        x = ~percentual_balance, 
        type = "histogram") %>% 
  layout(bargap=0.1,
         xaxis = list(title = 'Whales percentual balance change (may22-july22)'),
         autosize = F
  )


# Those who transferred ETH (direct transfers only), what did they do?

whalesactivity #renderDT

# 0) How much ETH was moved out ("activity", as it doesn't count inflows) of these accounts?
sum(whalesactivity$AMOUNT)

# 1) Days with more transactions / amount of ETH transferred:
plot_ly(whalesactivity %>% group_by(DATE) %>% summarise(n = n()),
        x = ~DATE, y = ~n, type = 'scatter', mode = 'lines') %>%
  layout(title = "",
         yaxis = list(title = "Daily transactions" ,
                      zeroline = FALSE))

plot_ly(whalesactivity %>% group_by(DATE) %>% summarise(ETH = sum(AMOUNT)),
        x = ~DATE, y = ~ETH, type = 'scatter', mode = 'lines') %>%
  layout(title = "",
         yaxis = list(title = "Daily ETH activity" ,
                      zeroline = FALSE))




# VER SI SALE UN DOUBLE AXIS PLOT con ambas variables en uno solo...
plot_ly(whalesactivity %>% group_by(DATE) %>% summarise(ETH = sum(AMOUNT), n = n()),
        x = ~DATE, 


# 2) Addresses with more transactions (amount of transactions done and by how many accounts)
whalesactivity %>% 
  group_by()

# 3) most common labels to which ETH was transferred

#analizar usar un treemap para las labels más usadas
