library(dplyr)
library(nomisr)
library(stringr)

source("R/functions/clean_midyear_population_estimates.R")


###### Step 1: Create global variables ######

file_path <- list(
  estimates_coc_from_2001 = "data/raw/full_modelled_estimates_series_lad23_from_2001.rds",
  population_mye_1991_2000_nomis = "data/intermediate/population_mye_1991_2000.rds",
  population_lad = "data/intermediate/population_lad23.rds"
)


###### Step 2: Download and clean population estimates from Nomis (1991-2000)

raw_population_estimates <- nomis_get_data(
  id = "NM_2002_1",
  gender = c(1, 2),
  measures = 20100,
  time = c(1991:2000),
  c_age = c(101:191, 210),
  select = c(
    "date",
    "geography_name",
    "geography_code",
    "gender_name",
    "c_age_name",
    "obs_value"
  )
)

clean_population_estimates <- clean_population_estimates(
  raw_population_estimates
)

saveRDS(clean_population_estimates, file_path$population_mye_1991_2000_nomis)


###### Step 3: Download and clean modelled backseries from the Datastore (from 2001)

download.file(
  url = paste0(
    "https://data.london.gov.uk/download/modelled-population-backseries/",
    "2b07a39b-ba63-403a-a3fc-5456518ca785/",
    "full_modelled_estimates_series_EW%282023_geog%29.rds"
  ),
  destfile = file_path$estimates_coc_from_2001,
  mode = "wb"
)


###### Step 4: Combine Nomis population estimates with adjusted backseries and save

population_lad <- bind_rows(
  readRDS(file_path$population_mye_1991_2000_nomis),
  readRDS(file_path$estimates_coc_from_2001) %>%
    filter(component == "population") %>%
    select(-component) %>%
    filter(year >= 2001)
)

saveRDS(population_lad, fpath$population_lad)
