library(shiny)
library(ggplot2)
library(plotly)

library(leaflet)
library(leaflet.extras)
library(leaflet.providers)

#
# Load data
#
# Parameters:
#   verbose: TRUE to print progress
LoadDataset <- function(verbose = TRUE) {
    df <- readr::read_csv(file = "https://raw.githubusercontent.com/himalayahall/DATA607-FINALPROJECT/master/data/processed/owid/owid-covid-data.csv", col_names = TRUE)
    
    lat_long <- readr::read_csv(file = "https://raw.githubusercontent.com/himalayahall/DATA607-FINALPROJECT/master/data/processed/owid/country_lat_long.csv", col_names = TRUE)
    lat_long <- rename(lat_long, Longitude = `Longitude (average)`)
    lat_long <- rename(lat_long, Latitude = `Latitude (average)`)

    df <-
        left_join(df, lat_long, by = c('iso_code' = 'Alpha-3 code'))
    
    df <- df |>
        mutate(date = as.Date(date, format = '%m/%d/%y'))
    df$year = format(df$date, '%Y')
    df$month = format(df$date, '%m')
    df$day = format(df$date, '%d')
    
    max_tot_deaths_per_million <-
        max(df$total_deaths_per_million, na.rm = TRUE)
    df <- df |>
        filter(!is.na(total_deaths_per_million)) |>
        mutate(scaled_var = total_deaths_per_million / max_tot_deaths_per_million)
    
    return (df)
}

covid <- LoadDataset(verbose = FALSE)
glimpse(covid)

ui <- fluidPage(titlePanel("COVID Metrics"),
                
                sidebarLayout(
                    sidebarPanel(
                        width = 4,
                        helpText("COVID metrics from Our World In Data"),
                        
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
                            inline = TRUE,
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
                title = paste0("COVID - ",  str_replace_all(input$metric, "_", " ")),
                subtitle = "2020 - 2023",
                caption = "source: Our World In Data",
                y = input$metric
            ) +
            theme_minimal()
    })
}



shinyApp(ui = ui, server = server)
