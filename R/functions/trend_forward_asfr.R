library(dplyr)
library(tidyr)


trend_forward_asfr <- function(past_asfr,
                               yrs_past = 5,
                               yrs_proj = 5){

  if(yrs_past < 2) stop("Error: must specify at least 2 years of past data")
  if(length(unique(past_asfr$year)) < yrs_past) stop("Error: more years of past data specified than available")

  proj_yrs <- c((max(past_asfr$year) + 1):(max(past_asfr$year) + yrs_proj))

  asfr <- past_asfr %>%
    filter(between(year, max(year) - (yrs_past - 1), max(year))) %>%
    mutate(fert_rate = case_when(
      fert_rate == 0 ~ 0.00001,
      TRUE ~ fert_rate
    )) %>%
    split(~age + gss_code)

  lookup_gss_name <- past_asfr %>%
    select(gss_code, gss_name) %>%
    distinct()

  fit_model <- function(in_data) {lm(log(fert_rate) ~ year, data = in_data)}

  models <- lapply(asfr, fit_model)

  project_rates <- function(mdel, projection_years) {
    out_df <- data.frame(log_rate = predict.lm(mdel,
                                                newdata = data.frame(year = projection_years)),
                         year = projection_years) %>%
      mutate(fert_rate = exp(log_rate)) %>%
      select(-log_rate)
    }

  projected_asfr_list <- lapply(models, project_rates, projection_years = proj_yrs)

  projected_asfr <- bind_rows(projected_asfr_list, .id = "age.gss_code") %>%
    separate_wider_delim(age.gss_code, ".", names = c("age", "gss_code")) %>%
    mutate(age = as.numeric(age),
           sex = "female") %>%
    left_join(lookup_gss_name, by = "gss_code")

  return(projected_asfr)
}
