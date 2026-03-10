source("R/functions/reprofile_combined_rates.R")
source("R/functions/smooth_fertility_curve2.R")
source("R/functions/estimate_fertility_rates_sya.R")

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


###### Step 2: New fitting for fertility rates single year, mid-year MSOA

raw_list <- split(asfr_msoa_my, ~ msoa21_code + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

# Set first year
first_year <- min(asfr_msoa_my$year)

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
    params = params
  )

  smooth_list[[i]] <- smooth_rates$rates

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}
smooth_asfr_msoa_my <- smooth_list |>
  bind_rows()

prop.table(table(smooth_asfr_msoa_my$fitting_status))

saveRDS(
  smooth_asfr_msoa_my,
  "data/processed/smooth_single_year_asfr_msoa_my.rds"
)

###### Step 3: New fitting for fertility rates 3 year rolling mean, mid-year MSOA

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
    params <- smooth_rates_3y$coefs
  }

  smooth_rates_3y <- smooth_fertility_curve(
    raw_rates = raw_list[[i]],
    params
  )

  smooth_list[[i]] <- smooth_rates_3y$rates

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}
smooth_asfr_3y_msoa_my <- smooth_list |>
  bind_rows()

prop.table(table(smooth_asfr_3y_msoa_my$fitting_status))

saveRDS(
  smooth_asfr_3y_msoa_my,
  "data/processed/smooth_3y_rolling_asfr_msoa_my.rds"
)
