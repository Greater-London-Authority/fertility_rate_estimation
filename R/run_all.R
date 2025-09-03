source("R/functions/get_fertility_rates_estimates_data.R")

#' Download and install all packages
renv::restore()

#' Run all scripts to:
#' 1. Download all the necessary data
#' 2. Process and clean births and population estimates from various sources
#' 3. Calculate raw age-specific fertility rates
#' 4. Smooth fertility curves
get_fertility_rates_estimates_data()
