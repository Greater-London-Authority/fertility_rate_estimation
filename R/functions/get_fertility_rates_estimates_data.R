#' Run all scripts to download data, clean it and calculate smooth age-specific fertility rates
#' 1. Suppress warning for dplyr and gsscoder
#' 2. Create data directories
#' 3. Run all necessary scripts
get_fertility_rates_estimates_data <- function() {
  library(dplyr, warn.conflicts = FALSE)
  suppressWarnings(library(gsscoder))

  ###### Step 1: Create directories ######

  if (!dir.exists("data/raw/")) {
    dir.create("data/raw/", recursive = TRUE)
  }
  if (!dir.exists("data/intermediate/")) {
    dir.create("data/intermediate/", recursive = TRUE)
  }

  if (!dir.exists("data/processed/")) {
    dir.create("data/processed/", recursive = TRUE)
  }

  ###### Step 2: Run estimates ######

  # Download and clean calendar year births
  message("Step 1 of 4: Downloading and cleaning calendar year births...")
  source("R/1_fetch_and_clean_cy_births.R")

  # Download and clean mid-year population from Nomis API
  message(
    "Step 2 of 4: Downloading and cleaning mid-year population data from Nomis API..."
  )
  message("Please wait as it takes a few moments...")
  source("R/2_fetch_and_clean_mye_population.R")

  # Aggregate by region / country / international territory
  message("Step 3 of 4: Aggregating data by region...")
  message("")
  source("R/3_aggregate_lad_data.R")

  # Create estimates, age-specific fertility rates and curve fitting
  message("Step 4 of 4: Calculating age-specific fertility rates...")
  message("")
  source("R/4_calculate_cy_asfrs.R")
  message("Done!")
}
