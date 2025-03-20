library(readxl)
library(dplyr)
library(tidyr)

clean_calendar_year_births_lad_2022_2023 <- function(fpath_raw) {

    out_df <- read_excel(fpath_raw, sheet = "Table 1", skip = 5) %>%
      rename(year = Year,
             gss_code = `Local Authority Code`,
             gss_name = `Local Authority`) %>%
      pivot_longer(cols = -any_of(c("year", "gss_code", "gss_name")),
                   names_to = "age_of_mother",
                   values_to = "value") %>%
      mutate(age_of_mother = recode(age_of_mother,
                                    "<20" = "Under 20",
                                    "40+" = "40 and over")) %>%
      filter(!grepl("Total|Not stated", age_of_mother))

  return(out_df)
}
