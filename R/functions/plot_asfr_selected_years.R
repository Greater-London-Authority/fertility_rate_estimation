library(dplyr)
library(ggplot2)
library(gglaplot)

plot_asfr_selected_years <- function(in_df, sel_cd, sel_yrs = c(2001, 2006, 2011, 2016, 2021), rng_age = c(15, 49)) {

  out_plot <- in_df %>%
    filter(gss_code == sel_cd,
           year %in% sel_yrs,
           between(age, rng_age[1], rng_age[2])) %>%
    ggplot(aes(x = age, y = fert_rate, colour = as.factor(year))) +
    theme_gla(free_y_facets = TRUE, base_size = 10) +
    geom_line(linewidth = 1, alpha = 0.7) +
    scale_x_continuous(n.breaks = 7)

  return(out_plot)
}
