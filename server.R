library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(maps)
library(stringr)
library(DT)
library(zoo)

pollution <- readRDS('us_pm25.Rds')
pollution <- pollution %>% rename(Date = `Date Local`, State = `State Name` , County = `County Name`)
state <- pollution %>% distinct(State)
us_states <- map_data("state")
us_states <- us_states %>% 
  mutate(region = str_to_title(region)) 

pollution_state_year <- pollution %>%
  group_by(State,year) %>%
  summarise(mean_y= mean(AQI,na.rm = TRUE))
pollution_state <- us_states %>% left_join(pollution_state_year,by = c("region" = "State"))

#state_df <- get_urbn_map(map = "states",sf = TRUE)
#spatial_state <- state_df %>% left_join(pollution, by = c("state_name" = "State"))
#state_df %>% 
  #ggplot(aes()) +
  #geom_sf(fill = "grey", color = "#ffffff")

shinyserver <- function(session, input, output) {
  
  observe({
    updateSelectInput(session, "county", "Select a county", 
                      choices = unique(pollution[pollution$State==input$state,]$County))
  })
  #input$year
  
  output$map <- renderPlot({
    ggplot(data = us_states, mapping = aes(x = long, y = lat, group = group)) + 
      geom_polygon(color = "black", fill = "gray") + 
      geom_polygon(aes(x = long, y = lat, fill = mean_y, group = group), colour = "white", size = 0.1,
                   data = pollution_state %>% 
                     filter(year == input$year)) +
      geom_polygon(color = "black",fill = NA) +
      coord_map() +
      scale_fill_gradient2(low = "red",
                           mid = scales::muted("purple"),
                           high = "#34bab5") +
      theme_map()+
      labs(title = paste(input$year, "US Average AQI"), fill = "AQI")
  })
  
  ### monthly plot and tables
  output$table <- renderDataTable({
    # Select city to examine based on dropdown from input
    monthly <- pollution %>%
      filter(State == input$state & County == input$county
             & Date >= input$date_start & Date <= input$date_end
             ) %>%
      group_by(year, month) %>%
      summarise(mean = mean(AQI,na.rm = TRUE), max = max(AQI), min = min(AQI),
                median = median(AQI, na.rm = TRUE))
    
    # Pretty up the output
    monthly$mean <- round(monthly$mean, digits = 2)
    monthly$month <- month(monthly$month, label = TRUE)
    
    # change column colors
    monthly_colored <- monthly
    colnames(monthly_colored) <- paste0('<span style="color:',"white",'">',colnames(monthly),'</span>')
    DT::datatable(monthly_colored,escape=F)
    
  })

  
  
  output$plot <- renderPlot({
    daily <- pollution %>%
      filter(State == input$state & County == input$county 
               & Date >= input$date_start & Date <= input$date_end) %>%
      group_by(year, month) %>%
      summarise(count = n(), mean = mean(AQI,na.rm = TRUE))
    
    daily$yrmonth <- with(daily, as.yearmon(paste(year, month, "01", sep = "-")))
    
    plot_title <- paste("Monthly Average AQIs for", input$state, input$county)
    
    
    qplot(x=yrmonth, y=mean, data = daily, geom = c("point", "smooth"),
          xlab = "Month", ylab = "Monthly AQI", main = plot_title,
          alpha = 0.5) +
      theme_bw() +
      theme(legend.position = "none")
  })
  
  
}