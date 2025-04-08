
library(dplyr)
library(gsscoder)

source("R/functions/clean_births_mid_year_lsoa_1991_2017.R")

fpath <- list(estimates_coc_2001_on = "data/raw/full_modelled_estimates_series_EW(2023_geog).rds",
              zip_births_lsoa_my1992_2017 = "data/raw/lsoabirthsdeaths19912017final.zip",
              raw_births_lsoa_my1992_2017 = "data/raw/Table_1_Births.xlsx",
              births_lsoa_my1992_2017 = "data/intermediate/births_lsoa_my1992_2017.rds",
              births_lad_my_2002_on = "data/intermediate/births_lad_my_2002_on.rds",
              lookup_lsoa11_lad = "lookups/lookup_lsoa_lad.rds",
              births_lad_my = "data/intermediate/births_lad_my.rds"
)

urls <- list(births_lsoa_my1992_2017 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/009628birthsanddeathsbylowersuperoutputarealsoaenglandandwales1991to1992to2016to2017/lsoabirthsdeaths19912017final.zip",
             estimates_coc_2001_on = "https://data.london.gov.uk/download/modelled-population-backseries/2b07a39b-ba63-403a-a3fc-5456518ca785/full_modelled_estimates_series_EW%282023_geog%29.rds"
             )



lookup_lsoa11_lad <- readRDS(fpath$lookup_lsoa11_lad)

if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if(!dir.exists("data/intermediate/")) dir.create("data/intermediate/", recursive = TRUE)

if(!file.exists(fpath$estimates_coc_2001_on)) {

  download.file(url = urls$estimates_coc_2001_on,
                destfile = fpath$estimates_coc_2001_on,
                mode = "wb")
}

births_lad_my_2002_on <- readRDS(fpath$estimates_coc_2001_on) %>%
  filter(component == "births") %>%
  filter(age == 0) %>%
  group_by(gss_code, gss_name, year) %>%
  summarise(value = sum(value), .groups = "drop")


saveRDS(births_lad_my_2002_on, fpath$births_lad_my_2002_on)

# LSOA MY data for 1992 to 2017

download.file(url = urls$births_lsoa_my1992_2017,
              destfile = fpath$zip_births_lsoa_my1992_2017,
              mode = "wb")


zip::unzip(zipfile = fpath$zip_births_lsoa_my1992_2017,
           files = "Table_1_Births.xlsx",
           exdir = "data/raw/")

clean_births_mid_year_lsoa_1991_2017(fp_raw = fpath$raw_births_lsoa_my1992_2017,
                                     fp_save = fpath$births_lsoa_my1992_2017)


births_mid_year_lsoa_1991_2017 <- readRDS(fpath$births_lsoa_my1992_2017)

births_mid_year_lad_1991_2017 <- births_mid_year_lsoa_1991_2017 %>%
  left_join(lookup_lsoa11_lad, by = "LSOA11CD") %>%
  group_by(gss_code, year) %>%
  summarise(value = sum(value), .groups = "drop")

births_mid_year_lad_1991_2017 <- recode_gss(births_mid_year_lad_1991_2017,
                                            recode_from = get_gss_year(births_mid_year_lad_1991_2017),
                                            recode_to_year = 2023) %>%
  add_gss_names(gss_year = 2023)


births_lad_my <- bind_rows(
  filter(births_mid_year_lad_1991_2017, year <= 2000),
  births_lad_my_2002_on
)

saveRDS(births_lad_my, fpath$births_lad_my)

