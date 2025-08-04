library(dplyr)

split_city_of_london_isles_of_scilly <- function(data_to_split, past_split_data, num_years_past_data = 15) {

  col_joint_code <- "E09000001 & E09000012"
  ios_joint_code <- "E06000052 & E06000053"

  col_sep_codes <- c("E09000001", "E09000012")
  ios_sep_codes <- c("E06000052", "E06000053")

  lookup_names <- past_split_data %>%
    select(gss_code, gss_name) %>%
    filter(gss_code %in% c(col_sep_codes, ios_sep_codes)) %>%
    distinct()

  get_splits <- function(sep_codes, combined_code, num_years_past_data) {

    splits_age <- past_split_data %>%
      filter(year > max(year) - num_years_past_data + 1) %>%
      filter(gss_code %in% sep_codes) %>%
      group_by(gss_code, age_of_mother) %>%
      summarise(value = sum(value), .groups = "drop") %>%
      group_by(age_of_mother) %>%
      mutate(total = sum(value)) %>%
      ungroup() %>%
      mutate(proportion = value/total) %>%
      select(gss_code, age_of_mother, proportion) %>%
      mutate(joint_code = combined_code)

    return(splits_age)
  }

 splits <- bind_rows(get_splits(col_sep_codes, col_joint_code, num_years_past_data),
                     get_splits(ios_sep_codes, ios_joint_code, num_years_past_data))


  split_data <- data_to_split %>%
    filter(gss_code %in% c(col_joint_code, ios_joint_code)) %>%
    rename(joint_code = gss_code) %>%
    full_join(splits, by = c("joint_code", "age_of_mother"), relationship = "many-to-many") %>%
    mutate(value = round(value * proportion, 0)) %>%
    select(-c(proportion, joint_code, gss_name)) %>%
    left_join(lookup_names, by = "gss_code")


  out_df <- data_to_split %>%
    filter(!gss_code %in% c(col_joint_code, ios_joint_code)) %>%
    bind_rows(split_data) %>%
    arrange(year, gss_code, age_of_mother)

  return(out_df)
}
