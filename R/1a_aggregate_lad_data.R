library(dplyr)
source("R/functions/aggregate_to_region.R")

fpaths <- list(births_lad_cy = "data/intermediate/births_lad_cy.rds",
               births_lad_my = "data/intermediate/births_lad_my.rds",
               population_lad = "data/intermediate/population_lad(2023_geog).rds",
               births_lad_rgn_cy = "data/intermediate/births_lad_rgn_cy.rds",
               births_lad_rgn_my = "data/intermediate/births_lad_rgn_my.rds",
               population_lad_rgn = "data/intermediate/population_lad_rgn.rds"
)

aggregate_lad_to_all_geogs <- function(lad_df,
                                       lookup_paths = list(lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
                                                           lookup_lad_itl = "lookups/lookup_lad_itl.rds",
                                                           lookup_lad_inner_outer = "lookups/lookup_lad_inner_outer.rds",
                                                           lookup_lad_ctry = "lookups/lookup_lad_ctry.rds"),
                                       geog_labels = list(lookup_lad_rgn = "RGN",
                                                          lookup_lad_itl = "ITL2",
                                                          lookup_lad_inner_outer = "Inner/Outer London",
                                                          lookup_lad_ctry = "CTRY"),
                                       lad_geog_label = "LAD23") {

  lad_df <- lad_df %>%
    filter(grepl("E0|W0", gss_code)) %>%
    mutate(geography = lad_geog_label)

  agg_list <- sapply(names(lookup_paths), function(x) NULL)

  for(lookup_name in names(agg_list)) {

    agg_list[[lookup_name]] <- aggregate_to_region(lad_df,
                                                   lookup = readRDS(lookup_paths[[lookup_name]]),
                                                   geography_label = geog_labels[[lookup_name]]) %>%
      na.omit()

  }

  agg_df <- bind_rows(agg_list)

  all_df <- bind_rows(lad_df,
                      agg_df) %>%
    arrange(gss_code)

  return(all_df)
}

births_lad_rgn_cy <- aggregate_lad_to_all_geogs(lad_df = readRDS(fpaths$births_lad_cy))
population_lad_rgn <- aggregate_lad_to_all_geogs(lad_df = readRDS(fpaths$population_lad))
births_lad_rgn_my <- aggregate_lad_to_all_geogs(lad_df = readRDS(fpaths$births_lad_my))

saveRDS(births_lad_rgn_cy, fpaths$births_lad_rgn_cy)
saveRDS(population_lad_rgn, fpaths$population_lad_rgn)
saveRDS(births_lad_rgn_my, fpaths$births_lad_rgn_my)
