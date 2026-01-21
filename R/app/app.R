library(ggplot2)
library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(stringr)


raw_asfr_msoa_my <- read.csv(
  "~/projects/small-area-births/data/processed/asfr_msoa_from_2011_to_2021.csv"
)

raw_asfr_msoa_my <- raw_asfr_msoa_my |>
  pivot_longer(
    cols = starts_with("age"),
    names_to = "age",
    values_to = "fertility_rate"
  ) |>
  mutate(age = as.numeric(unlist(str_extract_all(age, "\\d{2}"))))

smooth_asfr_msoa_my <- readRDS("data/processed/first_asfr_msoa_my.rds")


ui <- page_sidebar(
  title = "Raw fertility rates by MSOA",
  sidebar = sidebar(
    selectInput(
      inputId = "year",
      label = "Select year:",
      choices = unique(smooth_asfr_msoa_my$year),
      selected = sort(unique(smooth_asfr_msoa_my$year))[1]
    ),

    selectInput(
      inputId = "local_authority_name",
      label = "Select Local Authority:",
      choices = unique(smooth_asfr_msoa_my$local_authority_name),
      selected = sort(unique(smooth_asfr_msoa_my$local_authority_name))[1]
    ),

    selectInput(
      inputId = "msoas",
      label = "Select MSOA:",
      choices = c(),
      selected = sort(unique(smooth_asfr_msoa_my$msoas))[1]
    )
  ),

  plotOutput(outputId = "distPlot")
)

server <- function(input, output, session) {
  # Update MSOA dropdown when Local Authority changes
  observeEvent(input$local_authority_name, {
    msoas_dropdown <- smooth_asfr_msoa_my |>
      filter(local_authority_name %in% input$local_authority_name) |>
      pull(msoas) |>
      unique() |>
      sort()

    updateSelectInput(
      session,
      inputId = "msoas",
      choices = msoas_dropdown,
      selected = msoas_dropdown[1]
    )
  })

  output$distPlot <- renderPlot({
    smooth_rates <- smooth_asfr_msoa_my |>
      filter(
        msoas %in% input$msoas,
        year == input$year
      )

    raw_rates <- raw_asfr_msoa_my |>
      filter(
        msoas %in% input$msoas,
        year == input$year
      )

    ggplot(smooth_rates, aes(x = age, y = fertility_rate)) +
      geom_line(aes(colour = "smoothed"), linewidth = 1) +
      geom_line(
        data = raw_rates,
        aes(colour = "raw"),
        linewidth = 1
      ) +
      scale_colour_manual(
        name = "type",
        values = c(
          "smoothed" = "red",
          "raw" = "black"
        )
      ) +
      labs(x = "age", y = "fertility rate")
  })
}

shinyApp(ui = ui, server = server)
