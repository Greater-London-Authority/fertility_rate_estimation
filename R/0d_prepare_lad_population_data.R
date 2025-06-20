library(dplyr)
library(readr)
library(stringr)

fpath <- list(estimates_coc_2001_on = "data/raw/full_modelled_estimates_series_EW(2023_geog).rds",
              mye_1991_2000_nomis = "data/intermediate/mye_1991_2000_nomis.rds",
              population_lad = "data/intermediate/population_lad(2023_geog).rds",
              alt_population_2001_on = "data/raw/population.rds"
              )

urls <- list(estimates_coc_2001_on = "https://data.london.gov.uk/download/modelled-population-backseries/2b07a39b-ba63-403a-a3fc-5456518ca785/full_modelled_estimates_series_EW%282023_geog%29.rds",
             mye_1991_2000_nomis = "https://data.london.gov.uk/download/modelled-population-backseries/7b01ed84-8eeb-4837-8939-12f9a449c32a/mye_1991_2000_nomis.rds")

if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if(!dir.exists("data/intermediate/")) dir.create("data/intermediate/", recursive = TRUE)

if(!file.exists(fpath$mye_1991_2000_nomis)) {

  download.file(url = urls$mye_1991_2000_nomis,
                destfile = fpath$mye_1991_2000_nomis,
                mode = "wb")
}

if(!file.exists(fpath$estimates_coc_2001_on)) {

  download.file(url = urls$estimates_coc_2001_on,
                destfile = fpath$estimates_coc_2001_on,
                mode = "wb")
}


# population_lad <- bind_rows(readRDS(fpath$mye_1991_2000_nomis) %>%
#                               filter(between(year, 1991, 2000)),
#
#                             readRDS(fpath$estimates_coc_2001_on) %>%
#                               filter(component == "population") %>%
#                               select(-component) %>%
#                               filter(year >= 2001)
#                             )

population_lad <- bind_rows(readRDS(fpath$mye_1991_2000_nomis) %>%
                              filter(between(year, 1991, 2000)),

                            readRDS(fpath$alt_population_2001_on) %>%
                              rename(value = popn) %>%
                              filter(year >= 2001)
) %>%
  select(-gss_name)


saveRDS(population_lad, fpath$population_lad)
