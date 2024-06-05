library(minpack.lm)

# Hadwiger mixture model for fitting to data (Chandola et al. 1999)
curve_function <- function(age,m,a,b1,c1,b2,c2){

  fert_rate <- a*m*(b1/c1)*(c1/age)^(3/2)*exp(-b1^2*(c1/age + age/c1 -2)) +
    (1-m)*(b2/c2)*(c2/age)^(3/2)*exp(-b2^2*(c2/age + age/c2 -2))

  return(fert_rate)

}

# get predicted output from fitted coeficients
getPred <- function(func, fit_coefs, age) {

  fit_coefs <- as.list(fit_coefs)
  fit_coefs$age <- age

  #func should be function name in single quotes
  do.call(func, fit_coefs)

}


nlsLM2 <- function(formula, data = parent.frame(), start, jac = NULL,
                   algorithm = "LM", control = nls.control(), lower = NULL,
                   upper = NULL, trace = FALSE, model = FALSE, ...){

  L <- list(formula = formula,
            data = data,
            start = start,
            jac = jac,
            algorithm = algorithm,
            control = control,
            lower = lower,
            upper = upper,
            trace = trace,
            model = model)

  L <- append(L, list(...))

  L$start <- as.data.frame(as.list(start))

  if (NROW(L$start) == 1)

    return(try(do.call(nlsLM, L),silent=T))

  if (NROW(L$start) == 2) {

    try({
      finIter <- control$maxiter

      u <- matrix(runif(finIter * NCOL(start)), NCOL(start))

      L$start <- t(u * unlist(start[1, ]) + (1 - u) * unlist(start[2, ]))

      L$start <- as.data.frame(L$start)

      names(L$start) <- names(start)

    }, silent=T)

  }

  name <- names(L$start)

  result <- apply(L$start, 1, function(start) {
    L$start <- as.list(start)
    names(L$start)<-name
    xx <- try(do.call(nlsLM, L), silent=TRUE)
    yy <- if (inherits(xx, "try-error"))
      NA
    else xx
    if (trace)
      print(yy)
    yy
  })

  ss <- lapply(result, function(x) if (identical(x, NA))
    NA
    else deviance(x))
  result <- result[[which.min(ss)]]
  result$data <- substitute(data)

  result
}


