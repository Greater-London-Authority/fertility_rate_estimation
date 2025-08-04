library(dplyr)
source("R/functions/smoothing_functions.R")

smooth_single_fertility_curve <- function(raw_rates, age_range_to_model=c(15:49)){

  # starting values for initial fitting pass. Chosen by looking at Mixture_Hadwigers_using2011population_UPDATED_Revised_Base_Rates.csv
  m<-0.424
  a<-0.574
  b1<-3.536
  c1<-24.858
  b2<-4.815
  c2<-33.218

  success <- FALSE

  # Run the first pass fit
  try({
    # non-linear least squares fit using modified Levenberg-Marquardt algorithm
    model_output <- nlsLM2(fert_rate ~ curve_function(age,m,a,b1,c1,b2,c2),
                           data=raw_rates,
                           start=list(m=m,a=a,b1=b1,c1=c1,b2=b2,c2=c2),
                           control=list(maxiter=400,warnOnly=TRUE))

    coefs <- coef(model_output)
    success <- TRUE
    pass <- "succeeded"
  }, silent=TRUE)

  # if no fit, use the raw rates
  if(!success) {
    out_rates <- raw_rates %>%
      mutate(fitting_status = "failed")
  } else {

  # generate smooth rates from the model coefficients
    coefs <- coef(model_output)

    smoothed_rates <- data.frame(age = age_range_to_model,
                              fert_rate = getPred('curve_function', coefs, age_range_to_model),
                              stringsAsFactors = FALSE)

    out_rates <- raw_rates %>%
      select(-fert_rate) %>%
      left_join(smoothed_rates, by = "age") %>%
      mutate(fitting_status = pass) %>%
      mutate(fert_rate = case_when(
        fert_rate < 0 ~ 0,
        TRUE ~ fert_rate
      ))
  }


  return(out_rates)
}
