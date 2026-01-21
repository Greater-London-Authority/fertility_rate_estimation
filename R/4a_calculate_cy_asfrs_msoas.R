library(dplyr)
library(readr)
library(tidyr)
library(stringr)

source("R/functions/estimate_fertility_rates_sya.R")
source("R/functions/smooth_fertility_curve.R")

raw_asfr_msoa_my <- read.csv(
  "~/projects/small-area-births/data/processed/asfr_msoa_from_2011_to_2021.csv"
)

raw_asfr_msoa_my <- raw_asfr_msoa_my |>
  pivot_longer(cols=starts_with("age"), names_to = "age", values_to = "fertility_rate") |>
  mutate(age = as.numeric(unlist(str_extract_all(age, "\\d{2}"))))


###### Step 3: Create and save smooth age-specific fertility rates ######

raw_list <- split(raw_asfr_msoa_my, ~ msoas + year)
smooth_list <- sapply(names(raw_list), function(x) NULL)

message("Smoothing fertility curves...")

for (i in 1:length(raw_list)) {
  smooth_list[[i]] <- smooth_fertility_curve(raw_list[[i]], c(19:45))

  if (i %% 100 == 0) message(paste0("Running ", i, " of ", length(raw_list)))
}

smooth_asfr_msoa_my <- smooth_list |>
  bind_rows()

saveRDS(smooth_asfr_msoa_my, "data/processed/first_asfr_msoa_my.rds")

unique(smooth_asfr_msoa_my$fitting_status)

barplot(prop.table(table(smooth_asfr_msoa_my$fitting_status)),
        ylab = "Proportion",
        xlab = "Fitting status")

msoa <- "E02000099"
y <- "2011-2012"

smooth_fertility_rates |>
  filter(msoas == msoa & year == y) |>
  ggplot(aes(x = age, y = fertility_rate)) +
  geom_line(aes(colour = "smoothed"), linewidth = 1) +
  geom_line(
    data = raw_asfr_msoa_my |>
      filter(msoas == msoa & year == "2011-2012"),
    aes(colour = "raw"),
    linewidth = 1
  ) +
  scale_colour_manual(
    name = "type",
    values = c(
      "smoothed" = "red",
      "raw" = "black"
    )
  ) +
  labs(x = "age", y = "fertility rate")

### Look into this MSOAS, no smooth output E02000133 E02006782


