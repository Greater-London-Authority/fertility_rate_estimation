library(dplyr)
library(readr)
library(stringr)

#TODO nomis data extracted manually at the moment - could be extracted directly from API

fpath <- list(mye_1991_2000_nomis_raw = "data/raw/mye_1991_2000_nomis.csv",
              mye_1991_2000_nomis = "data/intermediate/mye_1991_2000_nomis.rds")

if(!dir.exists("data/raw/")) dir.create("data/raw/", recursive = TRUE)
if(!dir.exists("data/intermediate/")) dir.create("data/intermediate/", recursive = TRUE)

process_1990s_population_nomis <- function(fpath_raw, fpath_out,
                                           yr_start = 1991, yr_end = 2000) {

  if(!file.exists(fpath_raw)) stop(paste0("Error: raw csv file not found at ", fpath_raw))
  if(file.exists(fpath_out)) stop(paste0("Error: file already exists at ", fpath_out, " - delete file before running if you wish to replace it"))

  out_df <- read_csv(fpath_raw) %>%
    select(year = DATE,
           gss_code = GEOGRAPHY_CODE,
           gss_name = GEOGRAPHY_NAME,
           sex = GENDER_NAME,
           age = C_AGE_NAME, value = OBS_VALUE) %>%
    mutate(age = as.numeric(str_extract(age, "[0-9]+"))) %>%
    mutate(sex = tolower(sex)) %>%
    filter(between(year, yr_start, yr_end))

  saveRDS(out_df, fpath_out)
}

process_1990s_population_nomis(fpath$mye_1991_2000_nomis_raw,
                               fpath$mye_1991_2000_nomis,
                               yr_start = 1991, yr_end = 2000)
