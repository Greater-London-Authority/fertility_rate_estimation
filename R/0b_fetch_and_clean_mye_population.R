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
  c_age = c(101:185, 210),
  select = c(
    "date",
    "geography_name",
    "geography_code",
    "gender_name",
    "c_age_name",
    "obs_value"
  ),
  geography = "1778384897...1778384901,1778384941,1778384950,1778385143...1778385146,1778385159,1778384902...1778384905,1778384942,1778384943,1778384956,1778384957,1778385033...1778385044,1778385124...1778385138,1778384906...1778384910,1778384958,1778385139...1778385142,1778385154...1778385158,1778384911...1778384914,1778384954,1778384955,1778384965...1778384972,1778385045...1778385058,1778385066...1778385072,1778384915...1778384917,1778384944,1778385078...1778385085,1778385100...1778385104,1778385112...1778385117,1778385147...1778385153,1778384925...1778384928,1778384948,1778384949,1778384960...1778384964,1778384986...1778384997,1778385015...1778385020,1778385059...1778385065,1778385086...1778385088,1778385118...1778385123,1778385160...1778385192,1778384929...1778384940,1778384953,1778384981...1778384985,1778385004...1778385014,1778385021...1778385032,1778385073...1778385077,1778385089...1778385099,1778385105...1778385111,1778384918...1778384924,1778384945...1778384947,1778384951,1778384952,1778384973...1778384980,1778384998...1778385003,1778384959,1778385193...1778385257"
)

clean_population_estimates <- clean_population_estimates(
  raw_population_estimates
)

saveRDS(clean_population_estimates, file_path$population_mye_1991_2000_nomis)


###### Step 3: Download and clean modelled backseries from the Datastore (from 2001)
#' Link to the new backseries of population estimates (June 2024 release):
#' https://data.london.gov.uk/download/fb203828-bde5-4a50-96d9-8adfb4960631/13f2e9f9-f378-47b4-95b1-bde79a5c14f0/full_series_lad.rds
#' New projections are currently in progress. The link below correspond to the
#' most updated release

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

saveRDS(population_lad, file_path$population_lad)
