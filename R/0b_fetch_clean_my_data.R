library(dplyr)

source("R/functions/clean_mid_year_births_lsoa_2001_21.R")
source("R/functions/clean_mid_year_births_lsoa_2022.R")

fpath <- list(raw_births_lad_msoa_my1992_2021 = "data/raw/livebirthsfinal.xlsx",
              raw_births_lsoa_my2022 = "data/raw/birthsbylsoamidyear22.xlsx",
              raw_births_lsoa_my2001_2021 = "data/raw/birthsbylsoamidyear01to21.xlsx",
              births_lad_my = "data/intermediate/births_lad_my.rds",
              births_msoa11_my = "data/intermediate/births_msoa11_my.rds",
              births_lad_msoa_my1992_2021 = "data/raw/livebirthsfinal.xlsx",
              births_lsoa11_my = "data/intermediate/births_lsoa11_my.rds",
              births_lsoa21_my = "data/intermediate/births_lsoa21_my.rds"
)

urls <- list(births_lad_cy_1993_2021 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/adhocs/1265livebirthsbyageofmotherandlocalauthorityenglandandwales1993to2021/birthsbyageofmotherlaua19932021finaltable.xlsx",
             births_lad_cy_2022_2023 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/conceptionandfertilityrates/adhocs/2609livebirthsbyageofmotherbylocalauthoritiesenglandandwales2022to2023/finalfileage.xlsx")


if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if(!dir.exists("data/intermediate/")) dir.create("data/intermediate/", recursive = TRUE)

# lsoa data
births_lsoa_2022 <- clean_mid_year_births_lsoa_2022(fpath$raw_births_lsoa_my2022)

births_lsoa11_my <- clean_mid_year_births_lsoa_2001_21(fpath$raw_births_lsoa_my2001_2021) %>%
  bind_rows(births_lsoa_2022$lsoa11)

births_lsoa21_my <- births_lsoa_2022$lsoa21

saveRDS(births_lsoa11_my, fpath$births_lsoa11_my)
saveRDS(births_lsoa21_my, fpath$births_lsoa21_my)


