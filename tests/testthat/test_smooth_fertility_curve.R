source(paste0(
  "~/git/fertility_rate_estimation/",
  "R/functions/smooth_fertility_curve.R"
))

dir <- "~/git/fertility_rate_estimation/tests/testthat/test_data/"

FILE_PATH_TO_ASFR_SAMPLE <- paste0(dir, "raw_asfr_hackney_2023.rds")
FILE_PATH_TO_SMOOTH_ASFR <- paste0(dir, "smooth_asfr_hackney_2023.rds")


test_that("`smooth_fertility_curve` should return smooth
          single year of age fertility rates", {
  expected_output <- readRDS(FILE_PATH_TO_SMOOTH_ASFR)

  output <- smooth_fertility_curve(readRDS(FILE_PATH_TO_ASFR_SAMPLE))

  expect_identical(output, expected_output)
})
