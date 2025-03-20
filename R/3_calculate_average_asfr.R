library(dplyr)
library(ggplot2)

source("R/functions/estimate_fertility_sya_cy_births.R")
source("R/functions/smoothing_functions.R")
source("R/functions/smooth_single_fertility_curve.R")

fpath <- list(births_lad_cy = "data/intermediate/births_lad_rgn_cy.rds",
              population_lad = "data/intermediate/population_lad_rgn.rds",
              asfr_raw_ave = "data/processed/asfr_lad_raw_3yr.rds",
              asfr_smooth_ave = "data/processed/asfr_lad_smooth_3yr.rds")

ave_years <- 3


population_lad <- readRDS(fpath$population_lad) %>%
  filter(sex == "female")

births_lad_cy <- readRDS(fpath$births_lad_cy)

year_max <- min(max(population_lad$year), max(births_lad_cy$year))

births_agg <- births_lad_cy %>%
  filter(between(year, year_max - (ave_years -1), year_max)) %>%
  group_by(across(-any_of(c("year", "value")))) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  mutate(year = year_max)

population_agg <- population_lad %>%
  filter(between(year, year_max - (ave_years -1), year_max)) %>%
  group_by(across(-any_of(c("year", "value")))) %>%
  summarise(value = sum(value), .groups = "drop") %>%
  mutate(year = year_max)

raw_fertility_rates_ave <- estimate_fertility_sya_cy_births(births_df = births_agg,
                                                            population_df = population_agg)

raw_list <- split(raw_fertility_rates_ave, ~ gss_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

for(i in 1:length(raw_list)) {

  smooth_list[[i]] <- smooth_single_fertility_curve(raw_list[[i]])

  if(i%%100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

asfr_smooth_ave <- smooth_list %>%
  bind_rows() %>%
  select(-c(fitting_status)) %>%
  mutate(period = paste0(year_max - (ave_years -1), " to ", year_max))

saveRDS(asfr_smooth_ave, fpath$asfr_smooth_ave)
