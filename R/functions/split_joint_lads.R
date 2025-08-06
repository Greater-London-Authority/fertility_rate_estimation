library(dplyr)

#' Splits joint local authorities
#'
#' @param data_to_split A data.frame.
#' @param past_data A data.frame.
#' @param separated_codes A list of character vectors.
#' @param joint_codes A character vector.
#' @param num_years_past_data A integer / double.
#' @returns A data frame.
split_joint_lads <- function(data_to_split,
                             past_data,
                             separated_codes,
                             joint_codes,
                             num_years_past_data) {

  for (i in joint_codes) {
    tryCatch({
      if (!(i %in% births_lad_cy2022_2023$gss_code)) {
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
    temporary_list[[i]] <- get_proportion_and_joint_codes(past_data,
                                                          separated_codes[[i]],
                                                          joint_codes[i],
                                                          num_years_past_data)
  }

  proportions_by_age_of_mother <- bind_rows(temporary_list)

  separated_las <- split_combined_la(data_to_split,
                                    proportions_by_age_of_mother,
                                    joint_codes,
                                    lookup_names)

  return(separated_las)
}


split_combined_la <- function(data_to_split,
                              proportions_by_age_of_mother,
                              joint_codes,
                              lookup_names) {

  split_combined_la <- data_to_split %>%
    filter(gss_code %in% joint_codes) %>%
    rename(joint_code = gss_code) %>%
    full_join(proportions_by_age_of_mother,
              by = c("joint_code", "age_of_mother"),
              relationship = "many-to-many") %>%
    mutate(value = round(value * proportion, 0)) %>%
    select(-c(proportion, joint_code, gss_name)) %>%
    left_join(lookup_names, by = "gss_code")

  merge_split_la_data <- data_to_split %>%
    filter(!gss_code %in% c(joint_codes)) %>%
    bind_rows(split_combined_la) %>%
    arrange(year, gss_code, age_of_mother)

  return(merge_split_la_data)

}


get_proportion_and_joint_codes <- function(past_data,
                                           separated_codes,
                                           joint_codes,
                                           num_years_past_data) {

  proportion_and_joint_code <- past_data %>%
    filter(year > max(year) - num_years_past_data + 1) %>%
    filter(gss_code %in% separeted_codes) %>%
    group_by(gss_code, age_of_mother) %>%
    summarise(value = sum(value), .groups = "drop") %>%
    group_by(age_of_mother) %>%
    mutate(total = sum(value)) %>%
    ungroup() %>%
    mutate(proportion = value / total,
           joint_code = joint_codes) %>%
    select(gss_code, age_of_mother, proportion, joint_code)

  return(proportion_and_joint_code)
}
