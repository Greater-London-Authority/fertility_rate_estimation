library(dplyr)
library(readr)

source("R/functions/estimate_fertility_rates_sya.R")
source("R/functions/smooth_fertility_curve.R")


###### Step 1: Create global variables ######

file_path <- list(
  births_cy = "data/intermediate/births_lad_agg_cy.rds",
  population = "data/intermediate/population_lad_agg_my.rds",
  asfr_raw = "data/processed/raw_asfr_lad_agg_cy.rds",
  asfr_smooth = "data/processed/smooth_asfr_lad_agg_cy.rds",
  tfr = "data/processed/tfr_lad_agg_cy.rds"
)


###### Step 2: Create and save raw age-specific fertility rates ######

raw_fertility_rates <- estimate_fertility_rates_sya(
  population_data = readRDS(file_path$population),
  births_data = readRDS(file_path$births_cy)
)

saveRDS(raw_fertility_rates, file_path$asfr_raw)

###### Step 3: Create and save smooth age-specific fertility rates ######

raw_list <- split(raw_fertility_rates, ~ gss_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

message("Smoothing fertility curves...")

for (i in 1:length(raw_list)) {
  smooth_list[[i]] <- smooth_fertility_curve(raw_list[[i]])

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_fertility_rates <- smooth_list %>%
  bind_rows() %>%
  select(-c(fitting_status))

saveRDS(smooth_fertility_rates, file_path$asfr_smooth)

# Create total fertility rates
total_fertility_rates <- bind_rows(

  asfr_lad_smooth %>%
    group_by(gss_code, gss_name, year, geography) %>%
    summarise(tfr = sum(fertility_rate), .groups = "drop") %>%
    mutate(source = "smoothed"),

  asfr_lad_raw %>%
    group_by(gss_code, gss_name, year, geography) %>%
    summarise(tfr = sum(fertility_rate), .groups = "drop") %>%
    mutate(source = "raw")
)

saveRDS(total_fertility_rates, file_path$tfr)

rm(list = ls())
