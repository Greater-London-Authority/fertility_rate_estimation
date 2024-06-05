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

  # starting value range for a grid search on starting values. This is much slower than the single starting value fitting. This
  # method is used where the single value start method returns an error.
  grid_start <- data.frame(m=c(0.01,10),
                           a=c(0.01,10),
                           b1=c(0.1,50),
                           c1=c(5,30),
                           b2=c(0.1,50),
                           c2=c(25,50))

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

  # If necessary, run the second pass fit
  # if(!success) {
  #
  #   try({
  #     model_outputs <- nlsLM2(fert_rate ~ curve_function(age,m,a,b1,c1,b2,c2),
  #                             data = raw_rates,
  #                             start = grid_start,
  #                             control = list(maxiter = 200, warnOnly = TRUE))
  #
  #     coefs <- coef(model_output)
  #     success <- TRUE
  #     pass_num <- "2"
  #   }, silent=TRUE)
  # }

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
