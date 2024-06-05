library(dplyr)

source("R/functions/aggregate_lad_to_all_geogs.R")

fpaths <- list(births_lad_cy = "data/intermediate/births_lad_cy.rds",
              population_lad = "data/intermediate/full_modelled_estimates_series_EW(2021_geog).rds",
              births_lad_rgn_cy = "data/intermediate/births_lad_rgn_cy.rds",
              population_lad_rgn = "data/intermediate/population_lad_rgn.rds"
)

births_lad_rgn_cy <- aggregate_lad_to_all_geogs(lad_df = readRDS(fpaths$births_lad_cy))
population_lad_rgn <- aggregate_lad_to_all_geogs(lad_df = readRDS(fpaths$population_lad))

saveRDS(births_lad_rgn_cy, fpaths$births_lad_rgn_cy)
saveRDS(population_lad_rgn, fpaths$population_lad_rgn)
