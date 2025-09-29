source(paste0(
  "~/git/fertility_rate_estimation/",
  "R/functions/read_and_clean_calendar_year_births.R"
))

dir <- "~/git/fertility_rate_estimation/tests/testthat/test_data/"

FILE_PATH_TO_MULTIPLE_SHEETS <- paste0(
  dir,
  "births_by_ageofmother_lad_1993_2021.xlsx"
)
FILE_PATH_TO_SINGLE_SHEETS <- paste0(
  dir,
  "births_by_ageofmother_lad_2022_2023.xlsx"
)


test_that("`read_and_clean_births_lad` should return the correct cols
          for a file with a single excel sheet", {
  expected_output <- c(
    "year",
    "gss_code",
    "gss_name",
    "age_of_mother",
    "value"
  )
  output <- colnames(
    read_and_clean_ss_births_lad(FILE_PATH_TO_SINGLE_SHEETS)
  )

  expect_identical(output, expected_output)
})


test_that("`read_and_clean_births_lad` should return the correct cols
          for a file with multiple excel sheets", {
  expected_output <- c(
    "gss_code",
    "gss_name",
    "age_of_mother",
    "value",
    "year"
  )
  output <- suppressMessages(colnames(
    read_and_clean_ms_births_lad(FILE_PATH_TO_MULTIPLE_SHEETS)
  ))

  expect_identical(output, expected_output)
})


test_that("`read_and_clean_births_lad` should return data on each year
          for a file with multiple excel sheets", {
  wsheets <- excel_sheets(FILE_PATH_TO_MULTIPLE_SHEETS)
  expected_output <- length(wsheets[grepl("[0-9]{4}", wsheets)])

  cleaned_births <- suppressMessages(
    read_and_clean_ms_births_lad(FILE_PATH_TO_MULTIPLE_SHEETS)
  )

  output <- length(unique(cleaned_births$year))

  expect_equal(output, expected_output)
})
