
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
source("R/0a_fetch_and_clean_cy_births.R")
# Download and clean mid-year population from Nomis API
source("R/0b_fetch_and_clean_mye_population.R")
# Aggregate by region / country / international territory
source("R/0c_aggregate_lad_data.R")
# Create estimates, age-specific fertility rates and curve fitting
source("R/1_calculate_cy_asfrs.R")
