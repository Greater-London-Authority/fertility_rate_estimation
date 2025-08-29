library(dplyr)
library(minpack.lm)


#' Smooths fertility rates using the Hadwiger mixture model and non-linear least squares
#'
#' @param raw_rates A nested list.
#' @param age_range_to_model A integer vector.
#' @returns A nested list.
smooth_fertility_curve <- function(
  raw_rates,
  age_range_to_model = c(15:49)
) {
  # Starting values for initial fitting pass
  m <- 0.424
  a <- 0.574
  b1 <- 3.536
  c1 <- 24.858
  b2 <- 4.815
  c2 <- 33.218

  success <- FALSE

  # Run fit
  try(
    {
      # Non-linear least squares fit using modified Levenberg-Marquardt algorithm from minpack.lm
      model_output <- nlsLM(
        fertility_rate ~ curve_function(age, m, a, b1, c1, b2, c2),
        data = raw_rates,
        start = list(m = m, a = a, b1 = b1, c1 = c1, b2 = b2, c2 = c2),
        control = list(maxiter = 400, warnOnly = TRUE)
      )

      # Generate smooth rates from the model coefficients
      coefs <- coef(model_output)
      success <- TRUE
      pass <- "succeeded"
    },
    silent = TRUE
  )

  # If no fit, use the raw rates
  if (!success) {
    out_rates <- raw_rates %>%
      mutate(fitting_status = "failed")
  } else {
    smooth_rates <- data.frame(
      age = age_range_to_model,
      fertility_rate = getPred('curve_function', coefs, age_range_to_model),
      stringsAsFactors = FALSE
    )

    out_rates <- raw_rates %>%
      select(-fertility_rate) %>%
      left_join(smooth_rates, by = "age") %>%
      mutate(fitting_status = pass) %>%
      mutate(
        fertility_rate = case_when(
          fertility_rate < 0 ~ 0,
          TRUE ~ fertility_rate
        )
      )
  }

  return(out_rates)
}

#' Curve fitting function based on Hadwiger mixture model for fitting to data
#' See Chandola et al. 1999. Recent European fertility patterns: Fitting curves to 'distorted' distributions
#'
#' @param age A double / integer.
#' @param m A double / integer.
#' @param a A double / integer.
#' @param b1 A double / integer.
#' @param c1 A double / integer.
#' @param b2 A double / integer.
#' @param c2 A double / integer.
#' @returns A double / integer.
curve_function <- function(age, m, a, b1, c1, b2, c2) {
  smooth_fertility_rates <- a *
    m *
    (b1 / c1) *
    (c1 / age)^(3 / 2) *
    exp(-b1^2 * (c1 / age + age / c1 - 2)) +
    (1 - m) *
      (b2 / c2) *
      (c2 / age)^(3 / 2) *
      exp(-b2^2 * (c2 / age + age / c2 - 2))

  return(smooth_fertility_rates)
}


#' Calls `curve_fitting` function for given parameters for each age
#'
#' @param func A function, as a string.
#' @param fit_coefs A integer vector of length 6.
#' @param age A integer vector.
getPred <- function(func, fit_coefs, age) {
  fit_coefs <- as.list(fit_coefs)
  fit_coefs$age <- age

  do.call(func, fit_coefs)
}
