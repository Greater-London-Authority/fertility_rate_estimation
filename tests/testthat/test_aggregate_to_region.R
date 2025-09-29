source(paste0(
  "~/git/fertility_rate_estimation/",
  "R/functions/aggregate_to_region.R"
))

dir <- "~/git/fertility_rate_estimation/tests/testthat/test_data/"

test_that("`aggregate_to_region` should aggregate
  the given geography and add that to the existing dataframe", {

  births_lad_sample <- readRDS(paste0(dir, "births_lad_sample.rds"))
  expected_output <- readRDS(paste0(
    dir,
    "births_lad_sample_expected_output.rds"
  ))

  output <- aggregate_to_region(
    births_lad_sample,
    "~/git/fertility_rate_estimation/lookups/lookup_lad_rgn.rds",
    "RGN"
  )
  expect_identical(output, expected_output)
})
