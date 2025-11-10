library(dplyr)
library(zoo)

#' Reprofile raw fertility rates estimated for aggregate age bands at extremes of range
#' This is an intermediate step before fitting curves to data
#' Assume fertility rates are zero outside of specified asfr range
#' Assume linear increase/decrease of rates with age within combined bands
#'
#' @param raw_fertility_rates A data.frame, age specific fertility rates by individual ages and area
#' @param min_age_upper_band A double / integer.
#' @param max_age_lower_band A double / integer.
#' @param asfr_min_age A double / integer.
#' @param asfr_max_age A double / integer.
#' @returns A data frame, with a new fertility rate column.
reprofile_combined_rates <- function(
    raw_fertility_rates,
    asfr_min_age = 15,
    asfr_max_age = 49,
    max_age_lower_band = 19,
    min_age_upper_band = 40
) {

  # get the reshaped rates for the upper and lower age groups.
  interpolated_lower <- get_interpolated_rates_for_age_band(
    raw_fertility_rates = raw_fertility_rates,
    age_outer = asfr_min_age,
    age_inner = max_age_lower_band
  )

  interpolated_upper <- get_interpolated_rates_for_age_band(
    raw_fertility_rates = raw_fertility_rates,
    age_outer = asfr_max_age,
    age_inner = min_age_upper_band
  )

  # replace combined rates
  reprofiled_rates <- raw_fertility_rates %>%
    filter(between(age, max_age_lower_band + 1, min_age_upper_band - 1)) %>%
    bind_rows(interpolated_lower,
              interpolated_upper) %>%
    arrange(gss_code, year, age)

  return(reprofiled_rates)
}

#' Create a set of rates for  fertility rates estimated for aggregate age bands at extremes of range
#' This is an intermediate step before fitting curves to data
#' Assume fertility rates are zero outside of specified asfr range
#' Assume linear increase/decrease of rates with age within combined bands
#'
#' @param raw_fertility_rates A data.frame
#' @param age_outer A double / integer, min/max age for lower/upper band respectively
#' @param age_inner A double / integer, max/min age for lower/upper band respectively
#' @returns A data frame.
get_interpolated_rates_for_age_band <- function(
    raw_fertility_rates,
    age_outer,
    age_inner
) {

  # interpolated rates over band
  width_combined_band <- abs(age_inner - age_outer) + 1

  interpolated_rates <- raw_fertility_rates %>%
    filter(age %in% seq(age_inner, age_outer)) %>%
    arrange(age) %>%
    group_by(across(-any_of(c("value", "fertility_rate", "age")))) %>%
    mutate(fertility_rate = case_when(
      age == age_inner ~ fertility_rate * 2 - (fertility_rate * 2)/width_combined_band,
      age == age_outer ~ (fertility_rate * 2)/width_combined_band,
      TRUE ~ NA
    )) %>%
    mutate(fertility_rate = na.approx(fertility_rate, rule = 2)) %>%
    ungroup()

  return(interpolated_rates)
}
