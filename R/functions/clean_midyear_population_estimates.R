library(stringr)

#' Cleans *mid-year* population estimates from Nomis API
#'
#' @param raw_population_estimates A data.frame.
#' @returns A data frame.
clean_population_estimates <- function(raw_population_estimates) {
  population_estimates <- raw_population_estimates %>%
    rename(
      year = DATE,
      gss_code = GEOGRAPHY_CODE,
      gss_name = GEOGRAPHY_NAME,
      sex = GENDER_NAME,
      age = C_AGE_NAME,
      value = OBS_VALUE
    ) %>%
    mutate(age = as.numeric(str_extract(age, "[0-9]+"))) %>%
    mutate(sex = tolower(sex))

  return(population_estimates)
}
