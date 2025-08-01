library(dplyr)
library(gsscoder)

source("R/functions/clean_calendar_year_births_lad_1993_2001.R")
source("R/functions/clean_calendar_year_births_lad_2022_2023.R")
source("R/functions/split_city_of_london_isles_of_scilly.R")

fpath <- list(
  raw_births_lad_cy1993_2021 =
    "data/raw/birthsbyageofmotherlaua19932021finaltable.xlsx",
  raw_births_lad_cy2022_2023 =
    "data/raw/finalfileage.xlsx",
  births_lad_cy =
    "data/intermediate/births_lad_cy.rds"
)

urls <- list(
  births_lad_cy_1993_2021 =
    "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/" %>%
    paste0("birthsdeathsandmarriages/livebirths/adhocs/",
           "1265livebirthsbyageofmotherandlocalauthorityenglandandwales",
           "1993to2021/birthsbyageofmotherlaua19932021finaltable.xlsx"),

  births_lad_cy_2022_2023 =
    "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/" %>%
    paste0("birthsdeathsandmarriages/conceptionandfertilityrates/adhocs/",
           "2609livebirthsbyageofmotherbylocalauthoritiesenglandandwales",
           "2022to2023/finalfileage.xlsx")
)


if (!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if (!dir.exists("data/intermediate/"))
  dir.create("data/intermediate/", recursive = TRUE)

# calendar lad data

download.file(url = urls$births_lad_cy_1993_2021,
              destfile = fpath$raw_births_lad_cy1993_2021,
              mode = "wb")

download.file(url = urls$births_lad_cy_2022_2023,
              destfile = fpath$raw_births_lad_cy2022_2023,
              mode = "wb")

# Read, clean and recode births per (LAD - 1993-2021)
births_lad_cy1993_2021 <- clean_cy_births_lad_1993_2001(
  fpath$raw_births_lad_cy1993_2021
) %>%
  select(-gss_name)

births_lad_cy1993_2021 <- recode_gss(births_lad_cy1993_2021,
                                     recode_from_year = 2021,
                                     recode_to_year = 2023) %>%
  add_gss_names(gss_year = 2023)


# Read, clean and split combined areas (LAD - from 2022)
births_lad_cy2022_2023 <- clean_cy_births_lad_2022_2023(
  fpath$raw_births_lad_cy2022_2023
)

births_lad_cy2022_2023 <- split_city_of_london_isles_of_scilly(
  data_to_split = births_lad_cy2022_2023,
  past_split_data = births_lad_cy1993_2021,
  num_years_past_data = 10
)

# Combine both datasets (LAD - from 1993)
births_lad_cy <- bind_rows(births_lad_cy1993_2021, births_lad_cy2022_2023)

rm(births_lad_cy1993_2021,
   births_lad_cy2022_2023)

saveRDS(births_lad_cy, fpath$births_lad_cy)
