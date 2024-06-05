library(dplyr)

estimate_fertility_sya_cy_births <- function(births_df, population_df,
                                             births_min_sya = 20,
                                             births_max_sya = 39,
                                             births_min_cat_name = "Under 20",
                                             births_max_cat_name = "40 and over",
                                             asfr_min_age = 15,
                                             asfr_max_age = 49,
                                             max_rate = 0.25) {

  year_min <- max(min(population_df$year), min(births_df$year))
  year_max <- min(max(population_df$year), max(births_df$year))

  births_df <- births_df %>%
    filter(between(year, year_min, year_max)) %>%
    rename(births = value)

  denominators <- population_df %>%
    filter(sex == "female") %>%
    filter(between(year, year_min, year_max)) %>%
    filter(between(age, asfr_min_age, asfr_max_age)) %>%
    mutate(age_of_mother = as.character(age)) %>%
    mutate(age_of_mother = case_when(
      age < births_min_sya ~ births_min_cat_name,
      age > births_max_sya ~ births_max_cat_name,
      TRUE ~ age_of_mother
    )) %>%
    group_by(gss_code, sex, year, age_of_mother) %>%
    summarise(population = sum(value), group_size = n(), .groups = "drop")

  rates <- denominators %>%
    left_join(births_df, by = NULL) %>%
    mutate(fert_rate = (births/population)/group_size) %>%
    mutate(fert_rate = case_when(
      fert_rate < 0 ~ 0,
      fert_rate > max_rate ~ max_rate,
      TRUE ~ fert_rate
    ))

  rates_sya <- data.frame(age = c(asfr_min_age:asfr_max_age)) %>%
    mutate(age_of_mother = as.character(age)) %>%
    mutate(age_of_mother = case_when(
      age < births_min_sya ~ births_min_cat_name,
      age > births_max_sya ~ births_max_cat_name,
      TRUE ~ age_of_mother
    )) %>%
    left_join(rates, by = "age_of_mother", relationship = "many-to-many") %>%
    select(-c(age_of_mother, population, group_size, births)) %>%
    arrange(gss_code, year, age)

  return(rates_sya)
}
