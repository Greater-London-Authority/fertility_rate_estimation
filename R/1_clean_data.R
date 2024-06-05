library(dplyr)

source("R/functions/clean_mid_year_births_lsoa_2001_21.R")
source("R/functions/clean_mid_year_births_lsoa_2022.R")
source("R/functions/clean_calendar_year_births_lad_1993_2001.R")

fpath <- list(raw_births_lad_cy1993_2021 = "data/raw/birthsbyageofmotherlaua19932021finaltable.xlsx",
              raw_births_lad_msoa_my1992_2021 = "data/raw/livebirthsfinal.xlsx",
              raw_births_lsoa_my2022 = "data/raw/birthsbylsoamidyear22.xlsx",
              raw_births_lsoa_my2001_2021 = "data/raw/birthsbylsoamidyear01to21.xlsx",
              births_lad_cy = "data/intermediate/births_lad_cy.rds",
              births_lad_my = "data/intermediate/births_lad_my.rds",
              births_msoa11_my = "data/intermediate/births_msoa11_my.rds",
              births_lad_msoa_my1992_2021 = "data/raw/livebirthsfinal.xlsx",
              births_lsoa11_my = "data/intermediate/births_lsoa11_my.rds",
              births_lsoa21_my = "data/intermediate/births_lsoa21_my.rds"
              )

# lsoa data
births_lsoa_2022 <- clean_mid_year_births_lsoa_2022(fpath$raw_births_lsoa_my2022)

births_lsoa11_my <- clean_mid_year_births_lsoa_2001_21(fpath$raw_births_lsoa_my2001_2021) %>%
  bind_rows(births_lsoa_2022$lsoa11)

births_lsoa21_my <- births_lsoa_2022$lsoa21

saveRDS(births_lsoa11_my, fpath$births_lsoa11_my)
saveRDS(births_lsoa21_my, fpath$births_lsoa21_my)

# calendar lad data
births_lad_cy <- clean_calendar_year_births_lad_1993_2001(fpath$raw_births_lad_cy)

saveRDS(births_lad_cy, fpath$births_lad_cy)
