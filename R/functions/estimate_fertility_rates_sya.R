library(dplyr)


#' Calculate age-specific fertility rates from births & population data
#' 1. Filter data by common start and end year
#' 2. Get population at risk
#' 3. Adjust ages according to births and population data
#'
#' @param population_data A data.frame, mid-year estimates aggregated by region.
#' @param births_data A data.frame, calendar-year births aggregated by region.
#' @param start_age A double / integer.
#' @param end_age A double / integer.
#' @param combined_start_age A character.
#' @param combined_end_age A character.
#' @param asfr_min_age A double / integer.
#' @param asfr_max_age A double / integer.
#' @param max_rate A double / float.
#' @returns A data frame, with a new fertility rate column.
estimate_fertility_rates_sya <- function(
    population_data,
    births_data,
    start_age = 20,
    end_age = 39,
    combined_start_age = "Under 20",
    combined_end_age = "40 and over",
    asfr_min_age = 15,
    asfr_max_age = 49,
    max_rate = 0.25
) {
    filtered_data <- filter_data_by_year(population_data, births_data)

    population <- data.frame(filtered_data[[1]])
    births <- data.frame(filtered_data[[2]]) %>%
        rename(births = value)

    population_at_risk <- population %>%
        get_population_at_risk(asfr_min_age, asfr_max_age, "female") %>%
        combine_single_year_of_age(
            start_age,
            end_age,
            combined_start_age,
            combined_end_age
        )

    fertility_rates_sya <- population_at_risk %>%
        get_asfr(births) %>%
        transform_combined_into_sye(
            start_age,
            end_age,
            combined_start_age,
            combined_end_age,
            asfr_min_age,
            asfr_max_age
        )

    return(fertility_rates_sya)
}


#' Filter two datasets by common minimum and maximum years to ensure
#' that they have the same start and end year
#'
#' @param first_df A data.frame.
#' @param second_df A data.frame.
#' @returns A data frame.
filter_data_by_year <- function(first_df, second_df) {
    year_min <- max(min(first_df$year), min(second_df$year))
    year_max <- min(max(first_df$year), max(second_df$year))

    filtered_first_data <- first_df %>%
        filter(between(year, year_min, year_max))
    filtered_second_data <- second_df %>%
        filter(between(year, year_min, year_max))

    return(list(filtered_first_data, filtered_second_data))
}


#' Get population at risk by filtering the data according to age & sex
#'
#' @param population_data A data.frame.
#' @param asfr_min_age A double / integer.
#' @param asfr_max_age A double / integer.
#' @param sex A character or NULL.
#' @returns A data frame.
get_population_at_risk <- function(
    population_data,
    asfr_min_age,
    asfr_max_age,
    sex = NULL
) {
    population_at_risk <- population_data %>%
        filter(between(age, asfr_min_age, asfr_max_age))

    if (!is.null(sex)) {
        return(population_at_risk[population_at_risk$sex == sex, ])
    } else {
        return(population_at_risk)
    }
}


#' Combine single year of age population data into combined years.
#' E.g., "Under 20" or "Over 40" to match births data.
#'
#' @param population_data A data.frame.
#' @param start_age A double / integer.
#' @param end_age A double / integer.
#' @param combined_start_age A character.
#' @param combined_end_age A character.
#' @returns A data frame.
combine_single_year_of_age <- function(
    population_data,
    start_age,
    end_age,
    combined_start_age,
    combined_end_age
) {
    population_data_mya <- population_data %>%
        mutate(
            value = case_when(
                value >= 1 ~ value,
                TRUE ~ 1
            )
        ) %>%
        mutate(age_of_mother = as.character(age)) %>%
        mutate(
            age_of_mother = case_when(
                age < start_age ~ combined_start_age,
                age > end_age ~ combined_end_age,
                TRUE ~ age_of_mother
            )
        ) %>%
        group_by(gss_code, sex, year, age_of_mother) %>%
        summarise(population = sum(value), group_size = n(), .groups = "drop")

    return(population_data_mya)
}


#' Calculate age-specific fertility rates.
#'
#' @param population_data A data.frame.
#' @param births_data A data.frame.
#' @param max_rate A double / float.
#' @returns A data frame, with a new fertility rate column.
get_asfr <- function(population_data, births_data, max_rate = 0.25) {
    asfr <- population_data %>%
        left_join(births_data, by = join_by(gss_code, year, age_of_mother)) %>%
        mutate(fertility_rate = (births / population) / group_size) %>%
        mutate(
            fertility_rate = case_when(
                fertility_rate < 0 ~ 0,
                fertility_rate > max_rate ~ max_rate,
                TRUE ~ fertility_rate
            )
        )

    return(asfr)
}


#' Transform previously combined years back into single year estimates
#'
#' @param rates_data A data.frame.
#' @param start_age A double / integer.
#' @param end_age A double / integer.
#' @param combined_start_age A character.
#' @param combined_end_age A character.
#' @param asfr_min_age A double / integer.
#' @param asfr_max_age A double / integer.
#' @returns A data frame.
transform_combined_into_sye <- function(
    rates_data,
    start_age,
    end_age,
    combined_start_age,
    combined_end_age,
    asfr_min_age,
    asfr_max_age
) {
    rates_sya <- data.frame(age = c(asfr_min_age:asfr_max_age)) %>%
        mutate(age_of_mother = as.character(age)) %>%
        mutate(
            age_of_mother = case_when(
                age < start_age ~ combined_start_age,
                age > end_age ~ combined_end_age,
                TRUE ~ age_of_mother
            )
        ) %>%
        left_join(
            rates_data,
            by = "age_of_mother",
            relationship = "many-to-many"
        ) %>%
        select(-c(age_of_mother, population, group_size, births)) %>%
        arrange(gss_code, year, age)

    return(rates_sya)
}
