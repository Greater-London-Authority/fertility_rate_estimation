install.packages("pak")
source("R/functions/get_fertility_rates_estimates_data.R")

#' Create a lockfile and install all required packages
pak::lockfile_create(
  pkg = c(
    "dplyr",
    "Greater-London-Authority/gglaplot",
    "ggplot2",
    "Greater-London-Authority/gsscoder",
    "kableExtra",
    "knitr",
    "magrittr",
    "minpack.lm",
    "ropensci/nomisr",
    "readr",
    "readxl",
    "rmarkdown",
    "stringr",
    "tidyr",
    "zoo"
  ),
  dependencies = NA,
  upgrade = TRUE,
  lockfile = "pkg.lock"
)

pak::lockfile_install(lockfile = "pkg.lock")

#' Run all scripts to:
#' 1. Download all the necessary data
#' 2. Process and clean births and population estimates from various sources
#' 3. Calculate raw age-specific fertility rates
#' 4. Smooth fertility curves
get_fertility_rates_estimates_data()
