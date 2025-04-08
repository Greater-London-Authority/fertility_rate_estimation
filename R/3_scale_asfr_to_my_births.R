library(dplyr)
library(readr)
library(lubridate)
library(tidyr)

source("R/functions/scale_asfr_to_births.R")

fpath <- list(population = "data/intermediate/population_lad_rgn.rds",
              births_my = "data/intermediate/births_lad_rgn_my.rds",
              asfr_cy = "data/processed/asfr_cy_smooth.rds",
              asfr_my = "data/processed/asfr_my.rds")

age_min <- 15
age_max <- 49

asfr_cy <- readRDS(fpath$asfr_cy)

yr_min_asfr <- min(asfr_cy$year)
yr_max_asfr <- max(asfr_cy$year)


births_my <- readRDS(fpath$births_my) %>%
  select(gss_code, year, births = value)

population_at_risk <- readRDS(fpath$population) %>%
  mutate(age = age + 1,
         year = year + 1) %>%
  filter(between(age, age_min, age_max)) %>%
  filter(sex == "female") %>%
  select(gss_code, year, age, population = value)

asfr_my <- scale_asfr_to_births(base_asfr = asfr_cy,
                                annual_births = births_my,
                                population_at_risk = population_at_risk)

saveRDS(asfr_my, fpath$asfr_my)
