library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(ggplot2)

source("R/functions/estimate_fertility_rates_sya.R")
source("R/functions/smooth_fertility_curve.R")
source("R/functions/reprofile_combined_rates.R")

###### Step 1: Reprofile and smooth single year ASFR ######

raw_asfr_msoa_my <- read.csv(
  "~/projects/small-area-births/data/processed/asfr_msoa_from_2011_to_2021.csv"
)

asfr_msoa_my <- raw_asfr_msoa_my |>
  transform_combined_into_sye(
    start_age = 20,
    end_age = 44,
    combined_start_age = "Under 19",
    combined_end_age = "Over 45",
    asfr_min_age = 15,
    asfr_max_age = 49
  ) |>
  reprofile_combined_rates()


raw_list <- split(asfr_msoa_my, ~ msoa21_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

message("Smoothing fertility curves...")

for (i in 1:length(raw_list)) {
  smooth_list[[i]] <- smooth_fertility_curve(raw_list[[i]], c(15:49))

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_asfr_msoa_my <- smooth_list |>
  bind_rows()

saveRDS(smooth_asfr_msoa_my, "data/processed/smooth_sy_asfr_msoa_my.rds")

prop.table(table(smooth_asfr_msoa_my$fitting_status))
barplot(
  prop.table(table(smooth_asfr_msoa_my$fitting_status)),
  ylab = "Proportion",
  xlab = "Fitting status"
)


###### Step 2: Reprofile and smooth 3-year rollsum ASFR ######

raw_asfr_3y_msoa_my <- read.csv(
  "~/projects/small-area-births/data/processed/rolling_sum_asfr_msoa_from_2011_to_2021.csv"
)

asfr_3y_msoa_my <- raw_asfr_3y_msoa_my |>
  transform_combined_into_sye(
    start_age = 20,
    end_age = 44,
    combined_start_age = "Under 19",
    combined_end_age = "Over 45",
    asfr_min_age = 15,
    asfr_max_age = 49
  ) |>
  reprofile_combined_rates()

raw_list <- split(asfr_3y_msoa_my, ~ msoa21_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

message("Smoothing fertility curves...")

for (i in 1:length(raw_list)) {
  smooth_list[[i]] <- smooth_fertility_curve(raw_list[[i]], c(15:49))

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_asfr_3y_msoa_my <- smooth_list |>
  bind_rows()

barplot(
  prop.table(table(smooth_asfr_3y_msoa_my$fitting_status)),
  ylab = "Proportion",
  xlab = "Fitting status"
)
prop.table(table(smooth_asfr_3y_msoa_my$fitting_status))

saveRDS(
  smooth_asfr_3y_msoa_my,
  "data/processed/combined_smooth_reprofiled_asfr_msoa_my.rds"
)


yr <- "2012"
msoa <- "E02000171"

ggplot(
  smooth_asfr_msoa_my |>
    dplyr::filter(msoa21_code == msoa & year == yr),
  aes(x = age, y = fertility_rate)
) +
  geom_line(aes(colour = "smooth sy"), linewidth = 1) +
  geom_line(
    data = asfr_msoa_my |>
      dplyr::filter(msoa21_code == msoa & year == yr),
    aes(colour = "raw sy"),
    linewidth = 1
  ) +
  geom_line(
    data = asfr_3y_msoa_my |>
      dplyr::filter(msoa21_code == msoa & year == yr),
    aes(colour = "raw 3y"),
    linewidth = 1
  ) +
  geom_line(
    data = smooth_asfr_3y_msoa_my |>
      dplyr::filter(msoa21_code == msoa & year == yr),
    aes(colour = "smooth 3y"),
    linewidth = 1
  ) +
  scale_colour_manual(
    name = "type",
    values = c(
      "smooth sy" = "red",
      "raw sy" = "black",
      "smooth 3y" = "orange",
      "raw 3y" = "blue"
    )
  ) +
  labs(x = "age", y = "fertility rate")


### New fitting for SY
source("R/functions/smooth_fertility_curve2.R")

raw_list <- split(asfr_msoa_my, ~ msoa21_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

# Set initial year
first_year <- sort(unique(asfr_msoa_my$year))[1]

for (i in 1:length(raw_list)) {
  current_year <- unique(raw_list[[i]][["year"]])

  if (current_year == first_year) {
    params <- list(
      m = 0.424,
      a = 0.574,
      b1 = 3.536,
      c1 = 24.858,
      b2 = 4.815,
      c2 = 33.218
    )
  } else {
    params <- smooth_rates$coefs
  }

  smooth_rates <- smooth_fertility_curve(
    raw_rates = raw_list[[i]],
    params
  )

  smooth_list[[i]] <- smooth_rates$rates

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}
smooth_rates_dinamic_param <- smooth_list |>
  bind_rows()

prop.table(table(smooth_rates_dinamic_param$fitting_status))

### New fitting for 3y ###

raw_list <- split(asfr_3y_msoa_my, ~ msoas + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

# Set initial year
first_year <- sort(unique(asfr_3y_msoa_my$year))[1]

for (i in 1:length(raw_list)) {
  current_year <- unique(raw_list[[i]][["year"]])

  if (current_year == first_year) {
    params <- list(
      m = 0.424,
      a = 0.574,
      b1 = 3.536,
      c1 = 24.858,
      b2 = 4.815,
      c2 = 33.218
    )
  } else {
    params <- smooth_rates$coefs
  }

  smooth_rates <- smooth_fertility_curve(
    raw_rates = raw_list[[i]],
    params
  )

  smooth_list[[i]] <- smooth_rates$rates

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}
smooth_rates_dinamic_param_3y <- smooth_list |>
  bind_rows()

prop.table(table(smooth_rates_dinamic_param_3y$fitting_status))
