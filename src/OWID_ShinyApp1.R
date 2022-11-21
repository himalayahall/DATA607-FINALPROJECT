library(shiny)
library(ggplot2)
library(plotly)

library(leaflet)
library(leaflet.extras)
library(leaflet.providers)

source("OurWorldInData_Common.R", echo = FALSE)
covid <- LoadDataset(verbose = FALSE)
glimpse(covid)

ui <- fluidPage(titlePanel("COVID"),
                
                sidebarLayout(
                    sidebarPanel(
                        helpText("COVID Deaths."),
                        
                        radioButtons(
                            "metric",
                            label = h3("Mertic"),
                            choices = c(
                                'total_deaths_per_million',
                                'excess_mortality_cumulative_per_million',
                                'hosp_patients_per_million',
                                'total_cases_per_million',
                                'positive_rate',
                                'total_vaccinations_per_hundred',
                                'population_density',
                                'gdp_per_capita'
                            ),
                            selected = c('total_deaths_per_million')
                        ),
                        
                        checkboxGroupInput(
                            "locations",
                            label = h3("Locations group"),
                            choices = unique(covid$location),
                            selected = c(
                                'United States',
                                'Great Britain',
                                'France',
                                'Japan',
                                'Germany',
                                'India'
                            )
                        )
                    ),
                    
                    mainPanel(plotlyOutput("locationPlot"))
                ))

# Define server logic required to draw a histogram ----
server <- function(input, output) {
    output$locationPlot <- renderPlotly({
        covid |>
            filter(location %in% input$locations) |>
            arrange(date) |>
            ggplot(aes(
                x = date,
                y = .data[[input$metric]],
                color = location
            )) +
            geom_line(size = 0.5) +
            scale_x_date(
                date_breaks = "1 year",
                date_minor_breaks = '1 month',
                date_labels = "%Y"
            ) +
            labs(
                title = "COVID",
                subtitle = "2020 - 2023",
                caption = "source: Our World In Data",
                y = "Metric"
            ) +
            theme_minimal()
    })
}



shinyApp(ui = ui, server = server)
