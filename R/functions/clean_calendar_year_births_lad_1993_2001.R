library(readxl)
library(dplyr)
library(tidyr)

clean_calendar_year_births_lad_1993_2001 <- function(fpath_raw) {

  wsheets <- excel_sheets(fpath_raw)
  wsheets <- wsheets[grepl("[0-9]{4}", wsheets)]

  get_single_sheet_data <- function(wsheet, fp, skip = 4) {

    out_df <- read_excel(fp, sheet = wsheet, skip = 4) %>%
      rename(gss_code = Code,
             gss_name = 'Local Authority') %>%
      pivot_longer(cols = -any_of(c("gss_code", "gss_name")),
                   names_to = "age_of_mother",
                   values_to = "value"
                   ) %>%
      mutate(year = as.numeric(wsheet))

    return(out_df)
  }

  all_data <- lapply(wsheets, get_single_sheet_data, fp = fpath_raw) %>%
    bind_rows() %>%
    filter(!grepl("Total|Not stated", age_of_mother)) %>%
    na.omit() %>%
    data.frame()

  return(all_data)
}
