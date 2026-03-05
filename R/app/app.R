library(ggplot2)
library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(stringr)

### Run smoooth_my_asfr_msoas.R

ui <- page_sidebar(
  title = "Fertility rates by MSOA",
  sidebar = sidebar(
    selectInput(
      inputId = "year",
      label = "Select year:",
      choices = unique(smooth_asfr_msoa_my$year),
      selected = sort(unique(smooth_asfr_msoa_my$year))[1]
    ),

    selectInput(
      inputId = "gss_name",
      label = "Select Local Authority:",
      choices = unique(smooth_asfr_msoa_my$gss_name),
      selected = sort(unique(smooth_asfr_msoa_my$gss_name))[1]
    ),

    selectInput(
      inputId = "msoa21_code",
      label = "Select MSOA:",
      choices = c(),
      selected = sort(unique(smooth_asfr_msoa_my$msoa21_code))[1]
    )
  ),

  plotOutput(outputId = "distPlot")
)

server <- function(input, output, session) {
  # Update MSOA dropdown when Local Authority changes
  observeEvent(input$gss_name, {
    msoas_dropdown <- smooth_asfr_msoa_my |>
      filter(gss_name %in% input$gss_name) |>
      pull(msoa21_code) |>
      unique() |>
      sort()

    updateSelectInput(
      session,
      inputId = "msoa21_code",
      choices = msoas_dropdown,
      selected = msoas_dropdown[1]
    )
  })

  output$distPlot <- renderPlot({
    raw_sy_rates <- asfr_msoa_my |>
      filter(
        msoa21_code %in% input$msoa21_code,
        year == input$year
      )

    smooth_sy_rates <- smooth_asfr_msoa_my |>
      filter(
        msoa21_code %in% input$msoa21_code,
        year == input$year
      )

    smooth_3y_rates <- smooth_asfr_3y_msoa_my |>
      filter(
        msoa21_code %in% input$msoa21_code,
        year == input$year
      )

    raw_3y_rates <- asfr_3y_msoa_my |>
      filter(
        msoa21_code %in% input$msoa21_code,
        year == input$year
      )

    ggplot(smooth_sy_rates, aes(x = age, y = fertility_rate)) +
      geom_line(aes(colour = "smooth sy"), linewidth = 1) +
      geom_line(
        data = raw_sy_rates,
        aes(colour = "raw sy"),
        linewidth = 1
      ) +
      geom_line(
        data = raw_3y_rates,
        aes(colour = "raw 3y"),
        linewidth = 1
      ) +
      geom_line(
        data = smooth_3y_rates,
        aes(colour = "smooth 3y"),
        linewidth = 1
      ) +
      scale_colour_manual(
        name = "type",
        limits = c("smooth sy", "raw sy", "smooth 3y", "raw 3y"),
        values = c(
          "raw sy" = "black",
          "raw 3y" = "blue",
          "smooth sy" = "red",
          "smooth 3y" = "orange"
        )
      ) +
      labs(x = "age", y = "fertility rate") +
      theme(
        legend.key.size = unit(1, 'cm'),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 16)
      )
  })
}

shinyApp(ui = ui, server = server)
