library(shiny)
library(ggplot2)
library(plotly)

library(leaflet)
library(leaflet.extras)
library(leaflet.providers)

source("OurWorldInData_Common.R", echo = FALSE)
covid <- LoadDataset(verbose = FALSE)
glimpse(covid)

ui <- fluidPage(
  titlePanel("COVID"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("COVID Deaths."),

    checkboxGroupInput(
                        "locations",
                        label = h3("Locations group"),
                        choices = unique(covid$location),
                        selected = c('United States', 'Great Britain', 'France', 'Japan', 'Germany', 'India')
                    ),

      # selectInput("var", 
      #             label = "Choose a variable to display",
      #             choices = c("Percent White", 
      #                         "Percent Black",
      #                         "Percent Hispanic", 
      #                         "Percent Asian"),
      #             selected = "Percent White"),
      
      sliderInput("range", 
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100))
    ),
    
    mainPanel(
      plotOutput("locationPlot")
    )
  )
)
# Define server logic required to draw a histogram ----
server <- function(input, output) {
    
    output$locationPlot <- renderPlot({
            covid |> filter(location %in% input$locations) |>
            arrange(date) |>
            ggplot(aes(
                x = date,
                y = total_deaths_per_million,
                color = location
            )) +
            geom_line(size = 0.5) +
            scale_x_date(
                date_breaks = "1 year",
                date_minor_breaks = '1 month', 
                date_labels = "%Y"
            ) +
            scale_y_continuous(limits = c(0, 5000),
                               labels = scales::label_comma()) +
            labs(
                title = "COVID Deaths Per Million",
                subtitle = "2020 - 2023",
                caption = "source: Our World In Data",
                y = "Deaths"
            ) +
            theme_minimal()
    })
}



shinyApp(ui = ui, server = server)
