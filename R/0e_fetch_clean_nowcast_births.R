library(readr)
library(tidyr)
library(dplyr)
library(lubridate)

fpath <- list(
  raw_nowcast_births = "data/raw/actual_and_predicted_births.csv",
  nowcast_births = "data/intermediate/nowcast_births.rds"
)

urls <- list(
  nowcast_births = "https://data.london.gov.uk/download/modelled-estimates-of-recent-births/9698d0b1-663c-4594-8687-67469ce07e6d/actual_and_predicted_births.csv"
  )

if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if(!dir.exists("data/intermediate/")) dir.create("data/intermediate/", recursive = TRUE)

download.file(url = urls$nowcast_births,
              destfile = fpath$raw_nowcast_births,
              mode = "wb")

nowcast_births <- read_csv(fpath$raw_nowcast_births) %>%
  filter(type == "predicted") %>%
  filter(month(date) == 7) %>%
  rename(principal = annual_births,
         high = interval_upper,
         low = interval_lower) %>%
  pivot_longer(cols = c("principal", "high", "low"), names_to = "variant", values_to = "value") %>%
  mutate(year = year(date)) %>%
  select(-c(sex, date, type))

saveRDS(nowcast_births, fpath$nowcast_births)

