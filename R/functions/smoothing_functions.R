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
