#' Calculates tempo adjusted TFR.
#'
#' @description
#' `calculate_tempo_adj_tfr` adjusted TFR and MAC calculations.
#'
#' @details
#' This function takes a file path with previously calculated age-specific
#' fertility rates and calculates adjusted total fertility rates and mean
#' age of childbearing for all local authorities in England and Wales.
#' Source: https://www.oeaw.ac.at/fileadmin/subsites/Institute/VID/PDF/Publications/Datasheet/DS2008/Tempo_effect_Documentation_VID_23-07-2008.pdf
#'
#' @param asfr_smooth_file_path A character.
#' @return A data frame.
calculate_tempo_adj_tfr <- function(asfr_smooth_file_path) {
  asfr_lad_smooth <- readRDS(asfr_smooth_file_path)
  asfr_by_year <- split(asfr_lad_smooth, asfr_lad_smooth$year)

  adjusted_tfr <- list()
  for (yr in names(asfr_by_year)) {
    current_yr <- as.numeric(yr)
    previous_yr <- as.character(current_yr - 1)
    next_yr <- as.character(current_yr + 1)

    lads <- unique(asfr_by_year[[yr]][["gss_code"]])

    print(glue::glue("Running year {yr}"))

    if (is.null(asfr_by_year[[previous_yr]])) {
      next
    }

    if (is.null(asfr_by_year[[next_yr]])) {
      break
    }

    for (la in lads) {
      t_minus <- asfr_by_year[[previous_yr]] |>
        dplyr::filter(gss_code == la) |>
        dplyr::mutate(
          mac = sum(age * fertility_rate) / sum(fertility_rate) + 0.5
        ) |>
        dplyr::select(mac) |>
        dplyr::slice(1)

      t_plus <- asfr_by_year[[next_yr]] |>
        dplyr::filter(gss_code == la) |>
        dplyr::mutate(
          mac = sum(age * fertility_rate) / sum(fertility_rate) + 0.5
        ) |>
        dplyr::select(mac) |>
        dplyr::slice(1)

      denominator <- (1 - ((t_plus$mac - t_minus$mac) / 2))

      nominator <- asfr_by_year[[as.character(current_yr)]] |>
        dplyr::filter(year == yr & gss_code == la) |>
        dplyr::mutate(tfr = sum(fertility_rate)) |>
        dplyr::mutate(mac = sum(age * fertility_rate) / tfr + 0.5) |>
        dplyr::select(tfr, gss_name, mac) |>
        dplyr::slice(1)

      adj_tfr <- nominator[["tfr"]] / denominator

      current_list <- data.frame(
        year = as.numeric(yr),
        gss_code = la,
        gss_name = nominator[["gss_name"]],
        tfr = nominator[["tfr"]],
        adj_tfr = adj_tfr,
        mac = nominator[["mac"]]
      )

      adjusted_tfr <- rbind(adjusted_tfr, current_list)
    }
  }
  return(adjusted_tfr)
}
