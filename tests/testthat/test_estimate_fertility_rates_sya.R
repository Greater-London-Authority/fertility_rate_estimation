source(paste0(
  "~/git/fertility_rate_estimation/",
  "R/functions/estimate_fertility_rates_sya.R"
))

dir <- "~/git/fertility_rate_estimation/tests/testthat/test_data/"

FILE_PATH_TO_POPULATION_SAMPLE <- paste0(dir, "population_hackney_2023.rds")
FILE_PATH_TO_BIRTH_SAMPLE <- paste0(dir, "births_hackney_2023.rds")
FILE_PATH_TO_ASFR_SAMPLE <- paste0(dir, "raw_asfr_hackney_2023.rds")


test_that("`estimate_fertility_rates_sya` should return
          single year of age fertility rates", {
  expected_output <- readRDS(FILE_PATH_TO_ASFR_SAMPLE)

  output <- estimate_fertility_rates_sya(
    population_data = readRDS(FILE_PATH_TO_POPULATION_SAMPLE),
    births_data = readRDS(FILE_PATH_TO_BIRTH_SAMPLE)
  )

  expect_identical(output, expected_output)
})
