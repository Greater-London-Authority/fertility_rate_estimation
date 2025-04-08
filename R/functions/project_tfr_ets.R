library(dplyr)
library(lubridate)
library(tidyr)
library(fable)
library(tsibble)
library(tsibbledata)

project_tfr_ets <- function(past_tfr,
                            max_horizon = 6,
                            yr_min = 2019,
                            yr_max = 2024,
                            interval_size = 75) {

  rename_lookup <- c(interval = paste0(interval_size, "%"))

  ts_ratios <- past_tfr %>%
    filter(between(year, yr_min, yr_max)) %>%
    as_tsibble(index = year,
               key = c(gss_code, gss_name, geography, sex))


  ts_model <- ts_ratios %>%
    model(ets = ETS(value ~ error("A") +
                      trend() + season("N"))) %>%
    forecast(h = max_horizon)

  projected_tfr <- ts_model %>%
    hilo(interval_size) %>%
    rename(any_of(rename_lookup)) %>%
    mutate(low = interval$lower,
           high = interval$upper) %>%
    data.frame() %>%
    select(gss_code, gss_name,
           geography, sex,
           year,
           central = .mean,
           low,
           high) %>%
    pivot_longer(cols = -any_of(c("gss_code", "gss_name", "geography", "sex", "year")),
                 names_to = "measure", values_to = "value")

  return(projected_tfr)
}
