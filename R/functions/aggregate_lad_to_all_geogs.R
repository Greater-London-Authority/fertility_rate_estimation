library(dplyr)

source("R/functions/aggregate_to_region.R")

aggregate_lad_to_all_geogs <- function(lad_df,
                                       lookup_paths = list(lookup_lad_rgn = "lookups/lookup_lad_rgn.rds",
                                                          lookup_lad_itl = "lookups/lookup_lad_itl.rds",
                                                           lookup_lad_ctry = "lookups/lookup_lad_ctry.rds"),
                                       geog_labels = list(lookup_lad_rgn = "RGN21",
                                                            lookup_lad_itl = "ITL221",
                                                            lookup_lad_ctry = "CTRY21"),
                                       lad_geog_label = "LAD21") {

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
