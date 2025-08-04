library(dplyr)
library(readr)
library(lubridate)
library(tidyr)

source("R/functions/scale_asfr_to_births.R")

fpath <- list(population = "data/intermediate/population_lad_rgn.rds",
              nowcast_births = "data/intermediate/nowcast_births.rds",
              forecast_asfr = "data/processed/forecast_asfr.rds",
              asfr_w_nowcast = "data/processed/asfr_w_nowcast.rds",
              lookup_gss_names = "lookups/lookup_lad_rgn_ctry.rds")

lookup_gss_names <- readRDS(fpath$lookup_gss_names) %>%
  select(gss_code, gss_name) %>%
  distinct()

age_min <- 15
age_max <- 49

forecast_asfr <- readRDS(fpath$forecast_asfr) %>%
  arrange(gss_code, age, year)

nowcast_births <- readRDS(fpath$nowcast_births) %>%
  filter(grepl("E0", gss_code)) %>%
  select(-c(geography, gss_name)) %>%
  rename(births = value)

yr_min_nowcast_births <- min(nowcast_births$year)
yr_max_nowcast_births <- max(nowcast_births$year)


population_at_risk <- readRDS(fpath$population) %>%
  mutate(age = age + 1,
         year = year + 1) %>%
  filter(between(age, age_min, age_max)) %>%
  filter(sex == "female") %>%
  select(gss_code, year, age, population = value) %>%
  filter(between(year, yr_min_nowcast_births, yr_max_nowcast_births))

asfr_to_scale <- forecast_asfr %>%
  filter(between(year, yr_min_nowcast_births, yr_max_nowcast_births)) %>%
  filter(grepl("E0", gss_code)) %>%
  mutate(variant = case_when(
    grepl("high", measure) ~ "high",
    grepl("low", measure) ~ "low",
    grepl("median|mean|central|principal", measure) ~ "principal",
    TRUE ~ "other"
  )) %>%
  mutate(sex = "female") %>%
  left_join(lookup_gss_names)

scaled_asfr <- scale_asfr_to_births(base_asfr = asfr_to_scale,
                                annual_births = nowcast_births,
                                population_at_risk = population_at_risk) %>%
  select(-c(variant, gss_name, sex))

not_scaled_asfr <- forecast_asfr %>%
  filter(between(year, yr_min_nowcast_births, yr_max_nowcast_births)) %>%
  filter(!grepl("E0", gss_code))

asfr_w_nowcast <- forecast_asfr %>%
  filter(!between(year, yr_min_nowcast_births, yr_max_nowcast_births)) %>%
  bind_rows(scaled_asfr, not_scaled_asfr) %>%
  arrange(gss_code, age, year)


saveRDS(asfr_w_nowcast, fpath$asfr_w_nowcast)

