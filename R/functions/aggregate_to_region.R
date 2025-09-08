library(dplyr)

#' Add a geography column for each type of geography
#'
#' @param lad_data A data.frame, population data per local authority district.
#' @param lookup_path A character.
#' @param geography_label A character.
#' @param lad_geography_label A character, e.g., 'RNG' for region or 'CTRY' for country.
#' @returns A data frame with new aggregated row according to the geography provided.
aggregate_to_region <- function(
  lad_data,
  lookup_path,
  geography_label,
  lad_geography_label
) {
  merged_lad_and_region <- lad_data %>%
    left_join(readRDS(lookup_path), by = join_by(gss_code, gss_name)) %>%
    group_by(across(-any_of(c("value", "gss_code", "gss_name")))) %>%
    summarise(value = sum(value), .groups = "drop") %>%
    rename(gss_code = RGNCD, gss_name = RGNNM) %>%
    mutate(geography = geography_label) %>%
    select(gss_code, gss_name, geography, everything())

  return(merged_lad_and_region)
}


#' Filter local authority data - England and Wales
#' Call `aggregate_to_region` for each type of geography
#'
#' @param lad_data A data.frame, population data per local authority district.
#' @param lookup_paths A list.
#' @param geography_labels A list.
#' @param lad_geography_labels A list.
#' @returns A data frame with new aggregated row according to the geography provided.
aggregate_lad_to_all_geogs <- function(
  lad_data,
  lookup_paths,
  geography_labels,
  lad_geography_labels
) {
  lad_data_with_geography <- lad_data %>%
    filter(grepl("E0|W0", gss_code)) %>%
    mutate(geography = lad_geography_labels)

  temporary_list <- sapply(names(lookup_paths), function(x) NULL)

  for (lookup_name in names(temporary_list)) {
    temporary_list[[lookup_name]] <- aggregate_to_region(
      lad_data_with_geography,
      lookup = lookup_paths[[lookup_name]],
      geography_label = geography_labels[[lookup_name]]
    ) %>%
      na.omit()
  }

  regions_data <- bind_rows(temporary_list)

  merged_lad_and_regions <- bind_rows(lad_data_with_geography, regions_data) %>%
    arrange(gss_code)

  return(merged_lad_and_regions)
}
