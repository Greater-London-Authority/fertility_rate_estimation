library(dplyr)
library(ggplot2)
library(gglaplot)


#' Plot age-specific fertility rates for selected years and one given local authority.
#'
#' @param asfr_data A data frame containing age-specific fertility rates.
#' @param lad_code A string, the local authority code.
#' @param years A numeric vector, a list with the years to plot.
#' @param age_range A integer vector.
#' @param title A string, the title.
#' @param subtitle A string, the subtitle.
#' @returns A plot from `ggplot2`
plot_asfr_selected_years <- function(
  asfr_data,
  lad_code,
  years = c(2001, 2006, 2011, 2016, 2021),
  age_range = c(15, 49),
  title = "Age-Specific Fertility Rates (ASFR)",
  subtitle = "Fertility rates by age of mother"
) {
  lad_name <- asfr_data %>%
    filter(gss_code == lad_code) %>%
    select(gss_name) %>%
    head(1)

  out_plot <- asfr_data %>%
    filter(
      gss_code == lad_code,
      year %in% years,
      between(age, age_range[1], age_range[2])
    ) %>%
    ggplot(aes(x = age, y = fertility_rate, colour = as.factor(year))) +
    theme_gla(free_y_facets = TRUE, base_size = 10) +
    geom_line(linewidth = 1, alpha = 0.7) +
    scale_x_continuous(n.breaks = 7) +
    scale_y_continuous(limits = c(0, NA)) +
    labs(
      title = title,
      subtitle = paste0(subtitle, " - ", lad_name[[1]]),
      caption = "Source: GLA modelled rates based on ONS births by age of mother"
    )

  return(out_plot)
}


#' Plot age-specific fertility rates for selected areas and one given year.
#'
#' @param asfr_data A data frame containing age-specific fertility rates.
#' @param lad_codes A string vector, the local authority codes.
#' @param year A integer.
#' @param age_range A integer vector.
#' @param title A string, the title.
#' @param subtitle A string, the subtitle.
#' @returns A plot from `ggplot2`
plot_asfr_selected_areas <- function(
  asfr_data,
  lad_codes,
  year = 2021,
  age_range = c(15, 49),
  title = "Age-Specific Fertility Rates (ASFR)",
  subtitle = "Fertility rates by age of mother"
) {
  out_plot <- asfr_data %>%
    filter(
      gss_code %in% lad_codes,
      year == year,
      between(age, age_range[1], age_range[2])
    ) %>%
    ggplot(aes(x = age, y = fertility_rate, colour = gss_name)) +
    theme_gla(free_y_facets = TRUE, base_size = 10) +
    geom_line(linewidth = 1, alpha = 0.7) +
    scale_x_continuous(n.breaks = 7) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = "Source: GLA modelled rates based on ONS births by age of mother"
    )
  return(out_plot)
}


#' Plot age-specific fertility rates for selected areas and multiple years.
#'
#' @param asfr_data A data frame containing age-specific fertility rates.
#' @param lad_codes A string vector, the local authority codes.
#' @param years A numeric vector, the years to plot.
#' @param ncols A integer, the number of plot columns.
#' @param label_group A string, creates group label by local authority or year. Only takes two values `gss_code` or `year`.
#' @param title A string, the title.
#' @param subtitle A string, the subtitle.
#' @returns A plot from `ggplot2`
plot_asfr_multiple_areas_and_years <- function(
  asfr_data,
  lad_codes,
  years,
  ncols,
  label_group,
  title = "Age-Specific Fertility Rates (ASFR)",
  subtitle = "Fertility rates by age of mother"
) {
  if (!label_group %in% c("gss_name", "year")) {
    stop(
      "The argument 'label_group' only takes 'gss_name' or 'year'. Check parameters"
    )
  }

  plot_data <- asfr_data %>%
    filter(year %in% years) %>%
    filter(gss_code %in% lad_codes)

  if (label_group == "gss_name") {
    out_plot <- ggplot(
      plot_data,
      aes(
        x = age,
        y = fertility_rate,
        colour = gss_name
      )
    ) +
      theme_gla(base_size = 10) +
      geom_line(linewidth = 1, alpha = 0.7) +
      scale_y_continuous(limits = c(0, NA)) +
      facet_wrap("year", ncol = ncols) +
      scale_x_continuous(n.breaks = 8) +
      labs(
        title = title,
        subtitle = subtitle,
        caption = "Source: GLA modelled rates based on ONS births by age of mother"
      )
  } else if (label_group == "year") {
    out_plot <- ggplot(
      plot_data,
      aes(
        x = age,
        y = fertility_rate,
        colour = as.factor(year)
      )
    ) +
      theme_gla(base_size = 10) +
      geom_line(linewidth = 1, alpha = 0.7) +
      scale_y_continuous(limits = c(0, NA)) +
      facet_wrap("gss_name", ncol = ncols) +
      scale_x_continuous(n.breaks = 8) +
      labs(
        title = title,
        subtitle = subtitle,
        caption = "Source: GLA modelled rates based on ONS births by age of mother"
      )
  }
  return(out_plot)
}


#' Plot total fertility rates for selected areas overtime.
#'
#' @param tfr_data A data frame containing total fertility rates.
#' @param lad_codes A character vector, the local authority codes.
#' @param years A numeric vector, the period to plot.
#' @param title A string, the title.
#' @param subtitle A string, the subtitle.
#' @returns A plot from `ggplot2`
plot_tfr_selected_areas <- function(
  tfr_data,
  lad_codes,
  years,
  title = "Total Fertility Rates (TFR)",
  subtitle = "Fertility rates by age of mother"
) {
  out_plot <- tfr_data %>%
    filter(gss_code %in% lad_codes) %>%
    ggplot(aes(x = year, y = tfr, colour = gss_name)) +
    theme_gla(base_size = 10) +
    geom_line(linewidth = 1, alpha = 0.7) +
    scale_x_continuous(breaks = years, guide = guide_axis(angle = 60)) +
    scale_y_continuous(limits = c(0, NA)) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = "Source: GLA modelled rates based on ONS births by age of mother"
    )
  return(out_plot)
}
