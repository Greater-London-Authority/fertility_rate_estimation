library(dplyr)
source("R/functions/aggregate_to_region.R")


###### Step 1: Create global variables ######

file_paths <- list(
  births_lad_cy = "data/intermediate/births_lad_cy.rds",
  population_lad = "data/intermediate/population_lad(2023_geog).rds",
  births_lad_rgn_cy = "data/intermediate/births_lad_rgn_cy.rds",
  population_lad_rgn = "data/intermediate/population_lad_rgn.rds"
)

lookup_paths <- list(
  lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
  lookup_lad_itl = "lookups/lookup_lad_itl.rds",
  lookup_lad_inner_outer = "lookups/lookup_lad_inner_outer.rds",
  lookup_lad_ctry = "lookups/lookup_lad_ctry.rds"
)

geography_labels <- list(
  lookup_lad_rgn = "RGN", # Region
  lookup_lad_itl = "ITL2", # International Territorial Level 2
  lookup_lad_inner_outer = "Inner/Outer London",
  lookup_lad_ctry = "CTRY" # Country (England and Wales)
)


###### Step 2: Add regions to population and birth data and save ######

births_lad_rgn_cy <- aggregate_lad_to_all_geogs(
  lad_data = readRDS(file_paths$births_lad_cy),
  lookup_paths = lookup_paths,
  geography_labels = geography_labels,
  lad_geography_label = "LAD23"
)
population_lad_rgn <- aggregate_lad_to_all_geogs(
  lad_data = readRDS(
    file_paths$population_lad
  ),
  lookup_paths = lookup_paths,
  geography_labels = geography_labels,
  lad_geography_label = "LAD23"
)

saveRDS(births_lad_rgn_cy, file_paths$births_lad_rgn_cy)
saveRDS(population_lad_rgn, file_paths$population_lad_rgn)
