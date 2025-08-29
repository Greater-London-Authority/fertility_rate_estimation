library(dplyr)
library(gsscoder)

source("R/functions/read_and_clean_calendar_year_births.R")
source("R/functions/split_joint_lads.R")


###### Step 1: Create global variables ######

file_path <- list(
  raw_births_lad_cy1993_2021 = "data/raw/births_by_ageofmother_lad_1993_2021.xlsx",
  raw_births_lad_cy2022_2023 = "data/raw/births_by_ageofmother_lad_2022_2023.xlsx",
  births_lad_cy = "data/intermediate/births_lad_cy.rds"
)


###### Step 2: Download calendar year LAD data from ONS ######

download.file(
  url = paste0(
    "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/",
    "birthsdeathsandmarriages/livebirths/adhocs/",
    "1265livebirthsbyageofmotherandlocalauthorityenglandandwales",
    "1993to2021/birthsbyageofmotherlaua19932021finaltable.xlsx"
  ),
  destfile = file_path$raw_births_lad_cy1993_2021,
  mode = "wb"
)

download.file(
  url = paste0(
    "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/",
    "birthsdeathsandmarriages/conceptionandfertilityrates/adhocs/",
    "2609livebirthsbyageofmotherbylocalauthoritiesenglandandwales",
    "2022to2023/finalfileage.xlsx"
  ),
  destfile = file_path$raw_births_lad_cy2022_2023,
  mode = "wb"
)


###### Step 3: Read, clean and re-code births per LAD (1993-2021) ######

births_lad_cy1993_2021 <- read_and_clean_ms_births_lad(
  file_path = file_path$raw_births_lad_cy1993_2021
) %>%
  select(-gss_name)

births_lad_cy1993_2021 <- recode_gss(
  df_in = births_lad_cy1993_2021,
  recode_from_year = 2021,
  recode_to_year = 2023
) %>%
  add_gss_names(gss_year = 2023)


###### Step 4: Read, clean and split combined areas per LAD (from 2022) ######
# In this case we are splitting City of London & Isles of Scilly

births_lad_cy2022_2023 <- read_and_clean_ss_births_lad(
  file_path = file_path$raw_births_lad_cy2022_2023
)

births_lad_cy2022_2023 <- split_joint_lads(
  data_to_split = births_lad_cy2022_2023,
  past_data = births_lad_cy1993_2021,
  separated_codes = list(
    c("E09000001", "E09000012"),
    c("E06000052", "E06000053")
  ),
  joint_codes = c("E09000001 & E09000012", "E06000052 & E06000053"),
  num_years_past_data = 10
)


###### Step 5: Combine and save births at LAD level from 1993 ######

births_lad_cy <- bind_rows(births_lad_cy1993_2021, births_lad_cy2022_2023)

rm(
  births_lad_cy1993_2021,
  births_lad_cy2022_2023
)

saveRDS(births_lad_cy, file_path$births_lad_cy)
