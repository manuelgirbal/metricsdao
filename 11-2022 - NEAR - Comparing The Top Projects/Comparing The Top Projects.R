# Let’s take a closer look at some of the biggest and best-known projects in the NEAR ecosystem.
# Choose one of the Top projects in the NEAR ecosystem (a list can be found below). 
# Analyze the project and its health.
# You can include baseline measures, e.g. token price (if applicable), transaction volume, etc., but go beyond that and apply your analysis skills. 
# Choose and define at least 2 measures of ecosystem health, and assess how the project is performing on those metrics.
# Grand prize winners will also compare the project to at least one other Top NEAR project using the 2 measures provided.

# aclarar tablas que usamos (y qué significan), y otras fuentes como Coingecko, además de que lo hicimos vía Shroom_SDK
# posible baseline el día que arranca Jumbo
# de las tablas queremos tener (como medidas de salud del ecosistema -recordar definirlas metodológicamente-):
  # precio -- ok
  # volumen de transacciones (solo estables -in swap-) -- ok (también hay volumen Coingecko)
  # usuarios diarios -- ok
  # nuevos usuarios 
  # active users (7 days, 30 days, etc)


## El volumen de comercio en 24 horas hace referencia a la cantidad de una criptomoneda 
## que se ha comprado y vendido en todos los intercambios en las últimas 24 horas 
## en el mercado al contado. 


library(tidyverse)


# reading data (last updated 2022-11-22)

swaps <- read_csv("11-2022 - NEAR - Comparing The Top Projects/Data/swaps.csv")
prices <- read_csv("11-2022 - NEAR - Comparing The Top Projects/Data/prices.csv")


# plot 


ggplot(prices, aes(x = date, y = price, color = coin_id) ) +
  geom_line() +
  theme_minimal()
