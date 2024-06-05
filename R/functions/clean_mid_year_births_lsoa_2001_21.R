library(readxl)
library(dplyr)
library(tidyr)

clean_mid_year_births_lsoa_2001_21 <- function(fpath_raw) {

  births_lsoa <- bind_rows(

    read_xlsx(fpath_raw,
              sheet = "1",
              skip = 3) %>%
      rename(year = `Mid-year`,
             gss_code = `Local Authority code`,
             gss_name = `Local Authority name`,
             LSOA11CD = `LSOA code`,
             LSOA11NM = `LSOA name`,
             aom_24_under = `Age of mother at birth (years) 24 and under`,
             aom_25_34 = `Age of mother at birth (years) 25 to 34`,
             aom_35_over = `Age of mother at birth (years) 35 and over`) %>%
      mutate(sex = "persons") %>%
      pivot_longer(cols = c("aom_24_under", "aom_25_34", "aom_35_over"),
                   names_to = "age_of_mother",
                   values_to = "value"),

    read_xlsx(fpath_raw,
              sheet = "2",
              skip = 3) %>%
      rename(year = `Mid-year`,
             gss_code = `Local Authority code`,
             gss_name = `Local Authority name`,
             LSOA11CD = `LSOA code`,
             LSOA11NM = `LSOA name`,
             aom_24_under = `Age of mother at birth (years) 24 and under`,
             aom_25_34 = `Age of mother at birth (years) 25 to 34`,
             aom_35_over = `Age of mother at birth (years) 35 and over`) %>%
      mutate(sex = "male") %>%
      pivot_longer(cols = c("aom_24_under", "aom_25_34", "aom_35_over"),
                   names_to = "age_of_mother",
                   values_to = "value"),

    read_xlsx(fpath_raw,
              sheet = "3",
              skip = 3) %>%
      rename(year = `Mid-year`,
             gss_code = `Local Authority code`,
             gss_name = `Local Authority name`,
             LSOA11CD = `LSOA code`,
             LSOA11NM = `LSOA name`,
             aom_24_under = `Age of mother at birth (years) 24 and under`,
             aom_25_34 = `Age of mother at birth (years) 25 to 34`,
             aom_35_over = `Age of mother at birth (years) 35 and over`) %>%
      mutate(sex = "female") %>%
      pivot_longer(cols = c("aom_24_under", "aom_25_34", "aom_35_over"),
                   names_to = "age_of_mother",
                   values_to = "value")
  )

  return(births_lsoa)
}
