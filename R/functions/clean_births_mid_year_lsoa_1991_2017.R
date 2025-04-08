library(readxl)
library(dplyr)

clean_births_mid_year_lsoa_1991_2017 <- function(fp_raw, fp_save) {

  births_lsoa <- read_xlsx(fp_raw) %>%
    rename(LSOA11CD = lsoa11) %>%
    select(-laua) %>%
    mutate(sex = recode(sex, "1" = "male", "2" = "female")) %>%
    pivot_longer(cols = -any_of(c("LSOA11CD", "sex")), names_to = "year", values_to = "value") %>%
    mutate(year = as.integer(substr(year, 1, 4)) + 1) %>%
    mutate(year_ending_date = as.Date(paste0(year, "-07-01")))

  saveRDS(births_lsoa, fp_save)
}
