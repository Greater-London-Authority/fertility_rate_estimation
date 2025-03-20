library(dplyr)
library(readr)
library(stringr)

fpath <- list(full_estimates_series = "data/raw/full_modelled_estimates_series_EW(2023_geog).rds",
              mye_1991_2000_nomis = "data/raw/mye_1991_2000_nomis.csv",
              population_lad = "data/intermediate/population_lad(2023_geog).rds",
              births_my_lad = "data/intermediate/births_my_lad(2023_geog).rds")

urls <- list(full_estimates_series = "https://data.london.gov.uk/download/modelled-population-backseries/2b07a39b-ba63-403a-a3fc-5456518ca785/full_modelled_estimates_series_EW%282023_geog%29.rds")

if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if(!dir.exists("data/intermediate/")) dir.create("data/intermediate/", recursive = TRUE)

#TODO nomis data extracted manually at the moment

population_1993_2000 <- read_csv(fpath$mye_1991_2000_nomis) %>%
  select(year = DATE,
         gss_code = GEOGRAPHY_CODE,
         gss_name = GEOGRAPHY_NAME,
         sex = GENDER_NAME,
         age = C_AGE_NAME, value = OBS_VALUE) %>%
  mutate(age = as.numeric(str_extract(age, "[0-9]+"))) %>%
  mutate(sex = tolower(sex)) %>%
  filter(year >= 1993)

download.file(url = urls$full_estimates_series,
              destfile = fpath$full_estimates_series,
              mode = "wb")

population_lad <- readRDS(fpath$full_estimates_series) %>%
  filter(component == "population") %>%
  select(-component) %>%
  bind_rows(population_1993_2000)

saveRDS(population_lad, fpath$population_lad)

births_my_lad <- readRDS(fpath$full_estimates_series) %>%
  filter(component == "births") %>%
  filter(age == 0)

saveRDS(births_my_lad, fpath$births_my_lad)
