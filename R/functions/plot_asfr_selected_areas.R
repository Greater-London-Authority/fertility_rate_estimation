library(dplyr)
library(ggplot2)
library(gglaplot)

plot_asfr_selected_areas <- function(in_df, sel_cds, sel_yr = 2021, rng_age = c(15, 49)) {

  out_plot <- in_df %>%
    filter(gss_code %in% sel_cds,
           year == sel_yr,
           between(age, rng_age[1], rng_age[2])) %>%
    ggplot(aes(x = age, y = fert_rate, colour = gss_name)) +
    theme_gla(free_y_facets = TRUE, base_size = 10) +
    geom_line(linewidth = 1, alpha = 0.7) +
    scale_x_continuous(n.breaks = 7)

  return(out_plot)
}
