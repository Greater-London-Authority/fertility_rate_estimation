library(dplyr)

#' Split joint local authorities
#'
#' @param data_to_split A data frame.
#' @param past_data A data frame.
#' @param separated_codes A list of character vectors.
#' @param joint_codes A character vector.
#' @param num_years_past_data A double / integer.
#' @returns A data frame.
split_joint_lads <- function(
  data_to_split,
  past_data,
  separated_codes,
  joint_codes,
  num_years_past_data
) {
  for (i in joint_codes) {
    tryCatch({
      if (!(i %in% data_to_split$gss_code)) {
        stop(i, ": joint codes not present in the data")
      }
    })
  }

  lookup_names <- past_data %>%
    select(gss_code, gss_name) %>%
    filter(gss_code %in% unlist(separated_codes)) %>%
    distinct()

  temporary_list <- sapply(joint_codes, function(x) NULL)

  for (i in 1:length(joint_codes)) {
    temporary_list[[i]] <- get_proportion_and_joint_codes(
      past_data,
      separated_codes[[i]],
      joint_codes[i],
      num_years_past_data
    )
  }

  proportions_by_age_of_mother <- bind_rows(temporary_list)

  separated_las <- calculate_current_births_for_joint_lads(
    data_to_split,
    proportions_by_age_of_mother,
    joint_codes,
    lookup_names
  )

  return(separated_las)
}


#' Calculate current births using proportions based on past data
#' 1. Use proportion data to calculate births in the current data
#' 2. Merge data from previous step with current data
#'
#' @param data_to_split A data frame.
#' @param proportions_by_age_of_mother A data frame with proportional births based on past data (see `get_proportion_and_joint_codes`).
#' @param joint_codes A character vector.
#' @param num_years_past_data A double / integer.
#' @returns A data frame with only single LADs
calculate_current_births_for_joint_lads <- function(
  data_to_split,
  proportions_by_age_of_mother,
  joint_codes,
  lookup_names
) {
  calculate_current_births_for_joint_lads <- data_to_split %>%
    filter(gss_code %in% joint_codes) %>%
    rename(joint_code = gss_code) %>%
    full_join(
      proportions_by_age_of_mother,
      by = c("joint_code", "age_of_mother"),
      relationship = "many-to-many"
    ) %>%
    mutate(value = round(value * proportion, 0)) %>%
    select(-c(proportion, joint_code, gss_name)) %>%
    left_join(lookup_names, by = "gss_code")

  merge_split_la_data <- data_to_split %>%
    filter(!gss_code %in% c(joint_codes)) %>%
    bind_rows(calculate_current_births_for_joint_lads) %>%
    arrange(year, gss_code, age_of_mother)

  return(merge_split_la_data)
}


#' Calculate proportional births for joint local authorities using past data
#'
#' @param past_data A data frame.
#' @param separated_codes A list of character vectors.
#' @param joint_codes A character vector.
#' @param num_years_past_data A double / integer.
#' @returns A data frame containing only the joint LADs with a new proportion column.
get_proportion_and_joint_codes <- function(
  past_data,
  separated_codes,
  joint_codes,
  num_years_past_data
) {
  proportion_and_joint_code <- past_data %>%
    filter(year > max(year) - num_years_past_data + 1) %>%
    filter(gss_code %in% separated_codes) %>%
    group_by(gss_code, age_of_mother) %>%
    summarise(value = sum(value), .groups = "drop") %>%
    group_by(age_of_mother) %>%
    mutate(total = sum(value)) %>%
    ungroup() %>%
    mutate(proportion = value / total, joint_code = joint_codes) %>%
    select(gss_code, age_of_mother, proportion, joint_code)

  return(proportion_and_joint_code)
}
