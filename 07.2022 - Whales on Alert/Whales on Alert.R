library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

options(scipen=999)

data_1 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/7a4307c2-3d46-468b-85af-8a4b5cdf7feb/data/latest")
data_2 <- GET("")

data2_1 <- rawToChar(data_1$content)
data2_2 <- rawToChar(data_2$content)

data3_1 <- as_tibble(fromJSON(data2_1, flatten = TRUE))
data3_2 <- as_tibble(fromJSON(data2_2, flatten = TRUE))

# data3_2$DATE <- as_date(data3_2$DATE)


# Defining whales:
x <- quantile(data3_1$BALANCE, .99)

data3_1$whales <- if_else(data3_1$BALANCE >= x, "whale", "not whale")

table(data3_1$whales)


