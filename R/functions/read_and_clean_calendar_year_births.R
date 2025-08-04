library(readxl)
library(dplyr)
library(tidyr)


#' Reads and cleans *calendar year* births from ONS
#'
#' @param file_path A string.
#' @param skip A number.
#' @param sheet A string.
#' @param pivot_cols A string vector.
#' @returns A cleaned data frame.
read_and_clean_ss_births_lad <- function(file_path,
                                         skip = 5,
                                         sheet = "Table 1",
                                         pivot_cols =
                                           c("year", "gss_code", "gss_name")) {

  cols_to_rename <- c(year = "Year",
                      gss_code = "Local Authority Code",
                      gss_code = "Code",
                      gss_name = "Local Authority")

  cleaned_births <- read_excel(file_path, sheet = sheet, skip = skip) %>%
    rename(any_of(cols_to_rename)) %>%
    pivot_longer(cols = -any_of(pivot_cols),
                 names_to = "age_of_mother",
                 values_to = "value") %>%
    mutate(age_of_mother = recode(age_of_mother,
                                  "<20" = "Under 20",
                                  "40+" = "40 and over")) %>%
    filter(!grepl("Total|Not stated", age_of_mother))

  return(cleaned_births)
}


#' Reads and cleans *calendar year* births from ONS,
#' where each year is split across multiple sheets
#' Recursively calls `read_and_clean_ss_births_lad` on each excel sheet
#'
#' @param file_path A string.
#' @returns A cleaned data frame.
read_and_clean_ms_births_lad <- function(file_path) {

  wsheets <- excel_sheets(file_path)
  wsheets <- wsheets[grepl("[0-9]{4}", wsheets)]

  merged_cleaned_births <- lapply(wsheets, function(sheet) {
    data <- read_and_clean_ss_births_lad(file_path = file_path,
                                         skip = 4,
                                         sheet = sheet,
                                         pivot_cols = c("gss_code", "gss_name"))
    data$year <- as.numeric(sheet)
    data
  }) %>%
    bind_rows() %>%
    na.omit() %>%
    data.frame()

  return(merged_cleaned_births)
}
