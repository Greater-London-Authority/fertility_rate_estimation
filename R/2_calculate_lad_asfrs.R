library(dplyr)
library(ggplot2)

source("R/functions/estimate_fertility_sya_cy_births.R")
source("R/functions/smoothing_functions.R")
source("R/functions/smooth_single_fertility_curve.R")

fpath <- list(births_cy = "data/intermediate/births_lad_rgn_cy.rds",
              population = "data/intermediate/population_lad_rgn.rds",
              asfr_raw = "data/processed/asfr_lad_raw.rds",
              asfr_smooth = "data/processed/asfr_lad_smooth.rds")

population <- readRDS(fpath$population) %>%
  filter(component == "population",
         sex == "female")

births_cy <- readRDS(fpath$births_cy)

raw_fertility_rates <- estimate_fertility_sya_cy_births(births_df = births_cy,
                                                        population_df = population)

saveRDS(raw_fertility_rates, fpath$asfr_raw)

raw_list <- split(raw_fertility_rates, ~ gss_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

for(i in 1:length(raw_list)) {

  smooth_list[[i]] <- smooth_single_fertility_curve(raw_list[[i]])

  if(i%%100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_fertility_rates <- smooth_list %>%
  bind_rows() %>%
  select(-c(fitting_status))

saveRDS(smooth_fertility_rates, fpath$asfr_smooth)
