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

whalesbalance <- data3_1 %>% 
  filter(whales == 'whale') %>% 
  mutate(balance = JULY22BALANCE-MAY22BALANCE,
         percentual_balance = round((JULY22BALANCE-MAY22BALANCE)/MAY22BALANCE*100,2),
         outcome = case_when(
           percentual_balance == 0 ~ "kept",
           percentual_balance > 0 ~ "increased",
           percentual_balance == -100 ~ "sold all",
           TRUE ~ "sold some"
         )) %>%
  select(!whales)







# Analyzing transactions:
# How many whales kept same balance? # How many hodl more now?

whalesbalance #renderDT

fig0 <- plot_ly(whalesbalance %>%
                  group_by(outcome) %>% 
                  summarise(n = n()),
                labels = ~outcome, values = ~n, type = 'pie')

fig0 <- fig0 %>% layout(title = 'Actions taken by whales between May22 and July22',
                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
fig0


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

fig <- plot_ly(whalesactivity %>% group_by(DATE) %>% summarise(ETH = sum(AMOUNT), n = n()))

fig <- fig %>% add_trace(x = ~DATE, y = ~ETH, name = "ETH", mode = "lines+markers", type = "scatter")

ay <- list(
  tickfont = list(color = "black"),
  overlaying = "y",
  side = "right",
  title = "<b>Daily transactions</b>")

fig <- fig %>% add_trace(x = ~DATE, y = ~n, name = "transactions", yaxis = "y2", mode = "lines+markers", type = "scatter")

fig <- fig %>% layout(
  title = "Daily ETH transferred from whales and amount of transactions", yaxis2 = ay,
  xaxis = list(title="Date"),
  yaxis = list(title="<b>Daily ETH activity</b>")
)%>%
  layout(plot_bgcolor='#e5ecf6',
         xaxis = list(
           zerolinecolor = '#ffff',
           zerolinewidth = 2,
           gridcolor = 'ffff'),
         yaxis = list(
           zerolinecolor = '#ffff',
           zerolinewidth = 2,
           gridcolor = 'ffff')
  )

fig
        
        
# 2) Top 10 addresses with more transactions (amount of transactions done and by how many accounts)
fig2 <- plot_ly(whalesactivity %>%
                  mutate(address = ORIGIN_FROM_ADDRESS) %>% 
                  group_by(address) %>% 
                  summarise(n = n()) %>%
                  arrange(desc(n)) %>% 
                  top_n(10),
                labels = ~address, values = ~n, type = 'pie')
fig2 <- fig2 %>% layout(title = 'Top 10 whales by transactions',
                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
fig2



fig3 <- plot_ly(whalesactivity %>%
                  mutate(address = ORIGIN_FROM_ADDRESS) %>% 
                  group_by(address) %>% 
                  summarise(ETH = sum(AMOUNT)) %>%
                  arrange(desc(ETH)) %>% 
                  top_n(10),
                labels = ~address, values = ~ETH, type = 'pie')
fig3 <- fig3 %>% layout(title = 'Top 10 whales by amount of ETH transferred',
                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
fig3



# 3) most common labels to which ETH was transferred

# Address Name
plot_ly(
  data = whalesactivity %>%
    group_by(ADDRESS_NAME) %>% 
    summarise(ETH = sum(AMOUNT)) %>%
    arrange(desc(ETH)) %>% 
    top_n(10),
  type = "treemap",
  labels= ~ADDRESS_NAME,
  parents= "",
  values= ~ETH
)

plot_ly(
  data = whalesactivity %>%
    group_by(ADDRESS_NAME) %>% 
    summarise(n = n()) %>%
    arrange(desc(n)) %>% 
    top_n(10),
  type = "treemap",
  labels= ~ADDRESS_NAME,
  parents= "",
  values= ~n
)



# Label type
plot_ly(
  data = whalesactivity %>%
    group_by(LABEL_TYPE) %>% 
    summarise(ETH = sum(AMOUNT)) %>%
    arrange(desc(ETH)) %>% 
    top_n(10),
  type = "treemap",
  labels= ~LABEL_TYPE,
  parents= "",
  values= ~ETH
)


plot_ly(
  data = whalesactivity %>%
    group_by(LABEL_TYPE) %>% 
    summarise(n = n()) %>%
    arrange(desc(n)) %>% 
    top_n(10),
  type = "treemap",
  labels= ~LABEL_TYPE,
  parents= "",
  values= ~n
)


# Label Subtype

plot_ly(
  data = whalesactivity %>%
    group_by(LABEL_SUBTYPE) %>% 
    summarise(ETH = sum(AMOUNT)) %>%
    arrange(desc(ETH)) %>% 
    top_n(10),
  type = "treemap",
  labels= ~LABEL_SUBTYPE,
  parents= "",
  values= ~ETH
)

plot_ly(
  data = whalesactivity %>%
    group_by(LABEL_SUBTYPE) %>% 
    summarise(n = n()) %>%
    arrange(desc(n)) %>% 
    top_n(10),
  type = "treemap",
  labels= ~LABEL_SUBTYPE,
  parents= "",
  values= ~n
)

