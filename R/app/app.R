library(ggplot2)
library(shiny)
library(bslib)

smooth_fertility_rates

  ui <- page_sidebar(
  title = "Raw fertility rates by MSOA",
  sidebar = sidebar(
    selectInput(
      inputId = "year",
      label = "Select year:",
      choices = unique(smooth_fertility_rates$year),
      selected = sort(unique(smooth_fertility_rates$year))[1]
    ),

    selectInput(
      inputId = "local_authority_name",
      label = "Select Local Authority:",
      choices = unique(smooth_fertility_rates$local_authority_name),
      selected = sort(unique(smooth_fertility_rates$local_authority_name))[1]
    ),

    selectInput(
      inputId = "msoas",
      label = "Select MSOA:",
      choices = c(),
      selected = sort(unique(smooth_fertility_rates$msoas))[1]
    )
  ),

  plotOutput(outputId = "distPlot")
)

  server <- function(input, output, session) {

    # Update MSOA dropdown when Local Authority changes
    observeEvent(input$local_authority_name, {

      msoas_dropdown <- smooth_fertility_rates |>
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

      smooth_rates <- smooth_fertility_rates |>
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
