library(dplyr)
library(readr)

source("R/functions/estimate_fertility_rates_sya.R")
source("R/functions/smoothing_functions.R")
source("R/functions/smooth_fertility_curve.R")


###### Step 1: Create global variables ######

file_path <- list(
  births_cy = "data/intermediate/births_lad_rgn_cy.rds",
  population = "data/intermediate/population_lad_rgn.rds",
  asfr_raw = "data/processed/asfr_cy_raw.rds",
  asfr_smooth = "data/processed/asfr_cy_smooth.rds",
  asfr_smooth_csv = "data/processed/asfr_cy_smooth.csv"
)

if (!dir.exists("data/processed/")) {
  dir.create("data/processed/", recursive = TRUE)
}


###### Step 2: Create and save raw age-specific fertility rates ######

raw_fertility_rates <- estimate_fertility_rates_sya(
  population_data = readRDS(file_path$population),
  births_data = readRDS(file_path$births_cy)
)

saveRDS(raw_fertility_rates, file_path$asfr_raw)

###### Step 3: Create and save smooth age-specific fertility rates ######

raw_list <- split(raw_fertility_rates, ~ gss_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

for (i in 1:length(raw_list)) {
  smooth_list[[i]] <- smooth_fertility_curve(raw_list[[i]])

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_fertility_rates <- smooth_list %>%
  bind_rows() %>%
  select(-c(fitting_status))

saveRDS(smooth_fertility_rates, file_path$asfr_smooth)

write_csv(smooth_fertility_rates, file_path$asfr_smooth_csv)
