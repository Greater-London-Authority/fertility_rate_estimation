library(dplyr)
library(readr)

source("R/functions/estimate_fertility_rates_sya.R")
source("R/functions/smooth_fertility_curve.R")
source("R/functions/reprofile_combined_rates.R")


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

reprofiled_fertility_rates <- reprofile_combined_rates(raw_fertility_rates)

raw_list <- split(
  reprofiled_fertility_rates,
  ~ gss_code + year
)[order(names(split(
  reprofiled_fertility_rates,
  ~ gss_code + year
)))]
smooth_list <- sapply(names(raw_list), function(x) NULL)

message("Smoothing fertility curves...")

# Set first year
first_year <- min(reprofiled_fertility_rates$year)

for (i in 1:length(raw_list)) {
  current_year <- unique(raw_list[[i]][["year"]])

  if (current_year == first_year) {
    params <- list(
      m = 0.424,
      a = 0.574,
      b1 = 3.536,
      c1 = 24.858,
      b2 = 4.815,
      c2 = 33.218
    )
  } else {
    params <- smooth_rates$coefs
  }

  smooth_rates <- smooth_fertility_curve(
    raw_rates = raw_list[[i]],
    params = params
  )

  smooth_list[[i]] <- smooth_rates$rates

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_fertility_rates <- smooth_list %>%
  bind_rows()

prop.table(table(smooth_fertility_rates$fitting_status))

saveRDS(smooth_fertility_rates, file_path$asfr_smooth)

# Create total fertility rates
total_fertility_rates <- smooth_fertility_rates %>%
  group_by(gss_code, gss_name, year, geography) %>%
  summarise(tfr = sum(fertility_rate), .groups = "drop")

saveRDS(total_fertility_rates, file_path$tfr)

rm(list = ls())
