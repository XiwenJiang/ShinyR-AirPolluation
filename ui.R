
library(shiny)
library(shinyWidgets)
library(dplyr)
library(ggthemes)

pollution <- readRDS("us_pm25.Rds")
pollution <- pollution %>% rename(Date = `Date Local`, State = `State Name`, County = `County Name`)
state <- pollution %>% distinct(State)
ui <- navbarPage("Air quality in America",
                 theme = shinythemes::shinytheme("superhero"),
                 tabPanel("Description",
                          includeMarkdown("./descreaption.md"),
                          hr()),
                 tabPanel(
                   "Descriptive statistics",
                   sidebarPanel(
                     selectInput(
                       inputId = "state",
                       label = "Select a state",
                       choices = state
                     ),
                     selectInput(
                       inputId = "county",
                       label = "Select a county",
                       choices = NULL
                     ),
                     renderText(textOutput("Select a data range")),
                     airDatepickerInput("date_start",
                                        label = "From",
                                        value = "2011-01-03",
                                        maxDate = "2020-06-26",
                                        minDate = "2011-01-03",
                                        view = "months", #editing what the popup calendar shows when it opens
                                        minView = "months", #making it not possible to go down to a "days" view and pick the wrong date
                                        dateFormat = "yyyy-mm"
                     ),
                     airDatepickerInput("date_end",
                                        label = "To",
                                        value = "2020-01-03",
                                        maxDate = "2020-06-26",
                                        minDate = "2011-01-03",
                                        view = "months", #editing what the popup calendar shows when it opens
                                        minView = "months", #making it not possible to go down to a "days" view and pick the wrong date
                                        dateFormat = "yyyy-mm"
                     )
                   ),
   
    mainPanel(
      h3("Trends in air pollution levels"),
      plotOutput(outputId = "plot"),
      h3("Monthly AQI Summary Statistics"),
      
      tags$style(HTML(".dataTables_wrapper .dataTables_length {
            color: #d4552a !important;
        }")),
      
      tags$style(HTML(".dataTables_wrapper .dataTables_filter, 
      .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_processing,
      .dataTables_wrapper .dataTables_paginate .paginate_button, .dataTables_wrapper 
      .dataTables_paginate .paginate_button.disabled {
            color: #ffffff !important;
        }")),
      
      DT::dataTableOutput(outputId = "table")
    )
  ),
  tabPanel(
    "Map",
    sidebarPanel(
      selectInput(
        inputId = "year",
        label = "Select a year",
        choices = seq(2011, 2020)
      )
    ),
    mainPanel(plotOutput("map", height = 600, width = 750)))
  
)
