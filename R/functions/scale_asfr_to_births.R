library(dplyr)

scale_asfr_to_births <- function(base_asfr, annual_births, population_at_risk){

  yr_min <- max(min(base_asfr$year), min(population_at_risk$year), min(annual_births$year))
  yr_max <- min(max(base_asfr$year), max(population_at_risk$year), max(annual_births$year))


  base_births <- population_at_risk %>%
    left_join(base_asfr, by = NULL) %>%
    select(-c(sex)) %>%
    mutate(base_births = population * fert_rate) %>%
    #group_by(gss_code, gss_name, year) %>%
    group_by(across(-any_of(c("age", "population", "fert_rate", "base_births")))) %>%
    summarise(base_births = sum(base_births), .groups = "drop")

  scaling_factors <- annual_births %>%
    left_join(base_births, by = NULL) %>%
    filter(between(year, yr_min, yr_max)) %>%
    mutate(scaling_factor = births/base_births)

  scaled_asfr <- scaling_factors %>%
    left_join(base_asfr, by = NULL) %>%
    mutate(fert_rate = scaling_factor * fert_rate) %>%
    select(-c(scaling_factor, births, base_births))

  return(scaled_asfr)
}
