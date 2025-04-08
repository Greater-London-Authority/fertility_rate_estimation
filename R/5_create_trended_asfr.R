library(dplyr)
library(readr)
library(lubridate)
library(tidyr)
library(fabletools)
library(distributional)

source("R/functions/trend_forward_asfr.R")
source("R/functions/scale_asfr_to_births.R")
source("R/functions/project_tfr_ets.R")

fpath <- list(population = "data/intermediate/population_lad_rgn.rds",
              births = "data/intermediate/actual_and_predicted_births.rds",
              past_asfr = "data/processed/asfr_my.rds",
              projected_asfr = "data/processed/asfr_projected_my.rds",
              lookup_lad_rgn_ctry = "lookups/lookup_lad_rgn_ctry.rds",
              forecast_age_standardised_births = "data/intermediate/forecast_standardised_births.rds",
              forecast_asfr = "data/processed/forecast_asfr.rds")


yr_start_backseries <- 2008
past_asfr <- readRDS(fpath$past_asfr)
yr_first_proj <- max(past_asfr$year) + 1
age_min <- 15
age_max <- 49

max_asfr <- 0.18

population_at_risk_ew <- readRDS(fpath$population) %>%
  mutate(age = age + 1,
         year = year + 1) %>%
  filter(year == yr_first_proj) %>%
  filter(between(age, age_min, age_max)) %>%
  filter(sex == "female") %>%
  select(gss_code, year, age, population = value)


lookup_lad_rgn_ctry <- readRDS(fpath$lookup_lad_rgn_ctry)

age_standardised_births <- population_at_risk_ew %>%
  filter(year == max(year)) %>%
  select(-year) %>%
  right_join(past_asfr, by = c("gss_code", "age")) %>%
  filter(year >= yr_start_backseries) %>%
  mutate(value = fert_rate * population) %>%
  filter(geography == "LAD23") %>%
  select(gss_code, age, year, value) %>%
  mutate(age = as.character(age)) %>%
  left_join(lookup_lad_rgn_ctry, by = "gss_code") %>%
  select(RGNCD, gss_code, age, year, value) %>%
  mutate(value = case_when(
    value == 0 ~ 0.01,
    TRUE ~ value
  )) %>%
  arrange(RGNCD, gss_code, age, year) %>%
  as_tsibble(index = year,
             key = c(RGNCD, gss_code, age)) %>%
  relocate(value)


standard_pop <- population_at_risk_ew %>%
  filter(year == max(year)) %>%
  select(-year) %>%
  mutate(age = as.character(age))


age_standardised_births_full <- age_standardised_births %>%
  aggregate_key(age * (RGNCD/gss_code), value = sum(value))

base_fit <- age_standardised_births_full %>%
  model(base = ETS(log(value) ~ error() + trend() + season("N")))

structural_fit <- base_fit %>%
  reconcile(mint = min_trace(base, method = "mint_shrink"))

forecast_age_standardised_births <- structural_fit %>%
  forecast(h = 10, simulate = TRUE, bootstrap = TRUE, times = 2000,
           point_forecast = list(.median = median))

saveRDS(forecast_age_standardised_births, fpath$forecast_age_standardised_births)

#######

forecast_age_standardised_births <- readRDS(fpath$forecast_age_standardised_births)

#interval_size <- 50
intervals <- c(67, 50, 33, 25)
#rename_lookup <- c(interval = paste0(interval_size, "%"))

out_fc <- forecast_age_standardised_births %>%
  hilo(intervals) %>%
  mutate(low50 = `50%`$lower,
         high50 = `50%`$upper,
         low67 = `67%`$lower,
         high67 = `67%`$upper,
         low33 = `33%`$lower,
         high33 = `33%`$upper
         ) %>%
  data.frame() %>%
  select(RGNCD,
         gss_code,
         age,
         year,
         model = .model,
         median = .median,
         low50,
         high50,
         high67,
         low67,
         low80,
         high80
         ) %>%
  pivot_longer(cols = -any_of(c("RGNCD", "model", "gss_code", "age", "age_name", "year")),
               names_to = "measure", values_to = "value")


out_lad <- out_fc %>%
  filter(!is_aggregated(RGNCD)) %>%
  filter(!is_aggregated(gss_code)) %>%
  filter(!is_aggregated(age)) %>%
  mutate(RGNCD = as.character(RGNCD),
         gss_code = as.character(gss_code),
         age = as.character(age)) %>%
  mutate(value = case_when(
    value < 0 ~ 0.01,
    TRUE ~ value
  )) %>%
  left_join(standard_pop, by = c("age", "gss_code")) %>%
  mutate(fert_rate = value/population) %>%
  mutate(value = case_when(
    fert_rate <= max_asfr ~ value,
    TRUE ~ value * max_asfr/fert_rate
  )) %>%
  select(-c(fert_rate))

out_rgn <- out_lad %>%
  group_by(RGNCD, age, year, model, measure) %>%
  summarise(value = sum(value),
            population = sum(population),
            .groups = "drop") %>%
  rename(gss_code = RGNCD)

out_eng <- out_lad %>%
  filter(grepl("E0", gss_code)) %>%
  group_by(age, year, model, measure) %>%
  summarise(value = sum(value),
            population = sum(population),
            .groups = "drop") %>%
  mutate(gss_code = "E92000001")

out_asfr <- bind_rows(out_lad, out_rgn, out_eng) %>%
  select(-RGNCD) %>%
  mutate(fert_rate = value/population) %>%
  select(-c(value, population)) %>%
  mutate(age = as.numeric(age)) %>%
  bind_rows(past_asfr %>% mutate(measure = "past", model = "actual")) %>%
  select(-c(gss_name, sex, geography))

saveRDS(out_asfr, fpath$forecast_asfr)

out_tfr <- out_asfr %>%
  group_by(across(-any_of(c("fert_rate", "age")))) %>%
  summarise(tfr = sum(fert_rate), .groups = "drop")

out_asfr %>%
  filter(gss_code %in% c("E09000002")) %>%
  filter(model %in% c("actual", "bu", "mint")) %>%
  filter(age %in% c(24, 28, 32)) %>%
  ggplot(aes(x = year, y = fert_rate, colour = measure, linetype = model)) +
  geom_line() +
  facet_wrap("age", scales = "free_y")

out_asfr %>%
  filter(gss_code %in% c("E12000007", "E09000002", "E09000033",
                         "E09000030", "E09000007", "E09000015")) %>%
  filter(model %in% c("actual", "mint")) %>%
  filter(year %in% c(2023, 2035)) %>%
  ggplot(aes(x = age, y = fert_rate, colour = measure)) +
  geom_line() +
  theme_minimal() +
  facet_wrap("gss_code")

out_asfr %>%
  filter(gss_code %in% c("E09000002")) %>%
  filter(model %in% c("actual", "mint")) %>%
  filter(year %in% c(2020:2032)) %>%
  ggplot(aes(x = age, y = fert_rate, colour = measure)) +
  geom_line() +
  theme_minimal() +
  facet_wrap("year")

out_asfr %>%
  filter(gss_code %in% c("E09000002")) %>%
  filter(measure %in% c("high", "past")) %>%
  filter(model %in% c("actual", "mint")) %>%
  filter(year %in% c(2017, 2020, 2023, 2025, 2028)) %>%
  ggplot(aes(x = age, y = fert_rate, colour = as.factor(year))) +
  geom_line() +
  theme_minimal()



out_tfr %>%
  filter(gss_code %in% c("E12000007", "E09000009", "E07000008",
                         "E07000109", "E07000178", "E06000053")) %>%
  filter(model %in% c("actual", "mint")) %>%
  ggplot(aes(x = year, y = tfr, colour = measure, linetype = model)) +
  geom_line() +
  scale_y_continuous(limits = c(0, NA)) +
  facet_wrap("gss_code")

out_tfr %>%
  filter(grepl("E09", gss_code)) %>%
  filter(model %in% c("actual", "mint")) %>%
  ggplot(aes(x = year, y = tfr, colour = measure, linetype = model)) +
  geom_line() +
  scale_y_continuous(limits = c(0,NA)) +
  theme_minimal() +
  facet_wrap("gss_code")

# trended_asfr_first_yr <- trend_forward_asfr(past_asfr, yrs_past = 5, yrs_proj = 1)
#
# trended_asfr_first_yr_wales <- trended_asfr_first_yr %>%
#     filter(grepl("TLL|W", gss_code))
#
# trended_asfr_first_yr_england <- trended_asfr_first_yr %>%
#   filter(!grepl("TLL|W", gss_code)) %>%
#   scale_asfr_to_births(annual_births = births_first_proj_year,
#                        population_at_risk = population_at_risk_england)
#
# past_asfr_central <- bind_rows(past_asfr,
#                                filter(trended_asfr_first_yr_england, variant == "central"),
#                                trended_asfr_first_yr_wales) %>%
#   arrange(gss_code, year, age)
#
# past_asfr_high <- bind_rows(past_asfr,
#                                filter(trended_asfr_first_yr_england, variant == "high"),
#                                trended_asfr_first_yr_wales) %>%
#   arrange(gss_code, year, age)
#
# past_asfr_low <- bind_rows(past_asfr,
#                                filter(trended_asfr_first_yr_england, variant == "low"),
#                                trended_asfr_first_yr_wales) %>%
#   arrange(gss_code, year, age)
#
# asfr_central <- bind_rows(
#   past_asfr_central,
#   trend_forward_asfr(past_asfr_central, yrs_past = 10, yrs_proj = 5)
# ) %>%
#   mutate(variant = "central")
#
# asfr_high <- bind_rows(
#   past_asfr_high,
#   trend_forward_asfr(past_asfr_high, yrs_past = 10, yrs_proj = 5)
# ) %>%
#   mutate(variant = "high")
#
# asfr_low <- bind_rows(
#   past_asfr_low,
#   trend_forward_asfr(past_asfr_low, yrs_past = 10, yrs_proj = 5)
# ) %>%
#   mutate(variant = "low")
#
# asfrs <- bind_rows(asfr_central,
#                    asfr_low,
#                    asfr_high)
#
# tfrs <- asfrs %>%
#   group_by(across(-any_of(c("fert_rate", "age")))) %>%
#   summarise(tfr = sum(fert_rate), .groups = "drop")
#
# sel_cd <- "E12000007"
#
# sel_cd <- "E09000007"
# sel_cd <- "E92000001"
#
#
# asfrs %>%
#   filter(gss_code == sel_cd) %>%
#   filter(year %in% c(2021, 2024, 2029)) %>%
#   mutate(year = as.factor(year)) %>%
#   ggplot(aes(x = age, y = fert_rate, colour = variant)) +
#   geom_line() +
#   facet_wrap("year")
#
# asfrs %>%
#   filter(gss_code == sel_cd) %>%
#   filter(variant == "central") %>%
#   filter(age %in% c(23, 34, 37)) %>%
#   mutate(age = as.factor(age)) %>%
#   ggplot(aes(x = year, y = fert_rate, colour = age)) +
#   geom_line()
#
# tfrs %>%
#   filter(gss_code == sel_cd) %>%
#   ggplot(aes(x = year, y = tfr, colour = variant)) +
#   geom_line()
#
# proj_tfr %>%
#   filter(gss_code == sel_cd) %>%
#   ggplot(aes(x = year, y = value, colour = measure)) +
#   geom_line() +
#   scale_y_continuous(limits = c(0,NA))
#
#
# tst %>%
#   filter(gss_code == sel_cd) %>%
#   ggplot(aes(x = year, y = value, colour = variant, linetype = measure)) +
#   geom_line() +
#   scale_y_continuous(limits = c(0,NA))
