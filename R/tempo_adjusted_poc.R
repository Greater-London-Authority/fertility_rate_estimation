library(dplyr)
library(tibble)
library(ggplot2)

source("R/functions/plots.R")

asfr_lad_smooth <- readRDS("data/processed/smooth_asfr_lad_agg_cy.rds")

asfr_by_year <- split(asfr_lad_smooth, asfr_lad_smooth$year)


adjusted_tfr <- list()
for (yr in names(asfr_by_year)) {
  current_yr <- as.numeric(yr)
  previous_yr <- as.character(current_yr - 1)
  next_yr <- as.character(current_yr + 1)

  lads <- unique(asfr_by_year[[yr]][["gss_code"]])

  print(glue::glue("Running year {yr}"))

  if (is.null(asfr_by_year[[previous_yr]])) {
    next
  }

  if (is.null(asfr_by_year[[next_yr]])) {
    break
  }

  for (la in lads) {

    t_minus <- asfr_by_year[[previous_yr]] |>
      filter(gss_code == la) |>
      mutate(mac = sum(age * fertility_rate) / sum(fertility_rate) + 0.5) |>
      select(mac) |>
      slice(1)

    t_plus <- asfr_by_year[[next_yr]] |>
      filter(gss_code == la) |>
      mutate(mac = sum(age * fertility_rate) / sum(fertility_rate) + 0.5) |>
      select(mac) |>
      slice(1)

    denominator <- (1 - ((t_plus$mac - t_minus$mac) / 2))

    nominator <- asfr_by_year[[as.character(current_yr)]] |>
      filter(year == yr & gss_code == la) |>
      mutate(tfr = sum(fertility_rate)) |>
      mutate(mac = sum(age * fertility_rate) / tfr + 0.5) |>
      select(tfr, gss_name, mac) |>
      slice(1)

    adj_tfr = nominator[["tfr"]] / denominator

    new_list <- data.frame(
      year = as.numeric(yr),
      gss_code = la,
      gss_name = nominator[["gss_name"]],
      tfr = nominator[["tfr"]],
      adj_tfr = adj_tfr,
      mac = nominator[["mac"]])

  adjusted_tfr <- rbind(adjusted_tfr, new_list)

  }
}

write.csv(adjusted_tfr, "data/processed/adjusted_tfr_my.csv")

lad_codes <- c("E09000007", "E09000020", "E09000026", "E12000007", "E92000001")
start_year <- min(adjusted_tfr$year)
end_year <- max(adjusted_tfr$year)
years <- c(start_year:end_year)

plot_tfr_selected_areas(adjusted_tfr, lad_codes, c(start_year:end_year))

la <- "London"
adjusted_tfr |>
  filter(gss_name %in% la) |>
  ggplot(aes(x = year)) +
  theme_gla(base_size = 10) +
  geom_line(aes(y = tfr, linetype = "tfr"), linewidth = 1, alpha = 0.7) +
  geom_line(
    aes(y = adj_tfr, linetype = "adj_tfr"),
    linewidth = 1,
    alpha = 0.7
  ) +
  scale_x_continuous(breaks = years, guide = guide_axis(angle = 60)) +
  scale_y_continuous(limits = c(0, NA)) +
  scale_linetype_manual(
    values = c("tfr" = "solid", "adj_tfr" = "dotted"),
    labels = c("tfr" = "Observed TFR", "adj_tfr" = "Adjusted TFR"),
    name = NULL
  ) +
  labs(
    title = "Total Fertility Rates",
    subtitle = la,
    caption = "Source: GLA modelled rates based on ONS births by age of mother"
  )


adjusted_tfr |>
  filter(gss_code %in% lad_codes) |>
  ggplot(aes(x = year, y = mac, colour = gss_name)) +
  theme_gla(base_size = 10) +
  geom_line(linewidth = 1, alpha = 0.7) +
  scale_x_continuous(breaks = years, guide = guide_axis(angle = 60)) +
  scale_y_continuous(limits = c(25, NA)) +
  labs(
    title = "Mean childbearing age from 1994 to 2022",
    subtitle = "",
    caption = "Source: GLA modelled rates based on ONS births by age of mother")
