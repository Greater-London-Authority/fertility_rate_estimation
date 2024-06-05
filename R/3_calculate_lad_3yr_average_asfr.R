library(dplyr)
library(ggplot2)

source("R/functions/estimate_fertility_sya_cy_births.R")
source("R/functions/smoothing_functions.R")
source("R/functions/smooth_single_fertility_curve.R")

fpath <- list(births_lad_cy = "data/intermediate/births_lad_cy.rds",
              population_lad = "data/intermediate/full_modelled_estimates_series_EW(2021_geog).rds",
              asfr_raw_3yr = "data/processed/asfr_lad_raw_3yr.rds",
              asfr_smooth_3yr = "data/processed/asfr_lad_smooth_3yr.rds")

population_lad <- readRDS(fpath$population_lad) %>%
  filter(component == "population",
         sex == "female")

births_lad_cy <- readRDS(fpath$births_lad_cy)

year_max <- min(max(population_lad$year), max(births_lad_cy$year))

births_3yr <- births_lad_cy %>%
  filter(between(year, year_max - 2, year_max)) %>%
  group_by(across(-any_of(c("year", "value")))) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  mutate(year = year_max)

population_3yr <- population_lad %>%
  filter(between(year, year_max - 2, year_max)) %>%
  group_by(across(-any_of(c("year", "value")))) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  mutate(year = year_max)

raw_fertility_rates_3yr <- estimate_fertility_sya_cy_births(births_df = births_3yr,
                                                            population_df = population_3yr)

raw_3yr_list <- split(raw_fertility_rates_3yr, ~ gss_code + year)
smooth_3yr_list <- sapply(names(raw_3yr_list), function(x) NULL)

for(i in 1:length(raw_3yr_list)) {

  smooth_3yr_list[[i]] <- smooth_single_fertility_curve(raw_3yr_list[[i]])

  if(i%%100 == 0) message(paste0("Running ", i, " of ", length(raw_3yr_list)))
}

asfr_smooth_3yr <- smooth_3yr_list %>%
  bind_rows() %>%
  select(-c(fitting_status))

saveRDS(asfr_smooth_3yr, fpath$asfr_smooth_3yr)
