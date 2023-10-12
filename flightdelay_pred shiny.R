suppressMessages(library(shiny))
suppressMessages(library(glmnet))
suppressMessages(library(effects))
suppressMessages(library(plotly))
suppressMessages(library(ggeffects))
suppressMessages(library(shinyWidgets))
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))
suppressMessages(library(shinyTime))
suppressMessages(library(lubridate))
suppressMessages(library(tidyr))
suppressMessages(library(forcats))
suppressMessages(library(RColorBrewer))



oldw <- getOption("warn")
options(warn = -1)

#Model
trainBatch <- read.csv("/Users/clairecasey/Downloads/697VGroup1/train.batch.csv")
mod=readRDS("/Users/clairecasey/Downloads/697VGroup1/final_flight.mod.rds")



flight.data.types <- c('factor',   # Month
                       'factor',    # Day of Week 
                       'factor',    # Carrier 
                       'factor',    # origin airport
                       'factor',    # origin state
                       'factor',    # destination airport
                       'factor',    # destination state
                       'numeric',    # Departure Time
                       'numeric', #  on time or not 
                       'numeric',    # elapsed time (duration)
                       'numeric'    # distance
)

missing.values <- c("NA","")

flight.data <- read.csv("/Users/clairecasey/Downloads/697VGroup1/WashDCflights2021 (1).csv",
                        colClasses=flight.data.types,na.strings=missing.values)

# FLIGHT DATA:

# Change level names of carrier, day, month to full name for shiny app

flight.data$month <- forcats::fct_recode(flight.data$month, April = "4", May = "5", June = "6", July = "7", August = "8")                                     

flight.data$day <- fct_recode(flight.data$day, Monday = "1", Tuesday = "2", Wednesday = "3", Thursday = "4", Friday = "5", Saturday = "6", Sunday = "7") 

flight.data$carrier <- fct_recode(flight.data$carrier, `Endeavor Air` = "9E", `American Airlines` = "AA", `Alaska Airlines` = "AS", `JetBlue Airways` = "B6", `Delta Airlines` = "DL", `Frontier Airlines` = "F9", `Envoy Air` = "MQ", `PSA Airlines` = "OH", `SkyWest Airlines` = "OO", `United Airlines` = "UA", `Southwest Airlines` = "WN", `Mesa Airlines` = "YV", `Republic Airlines` = "YX")

#Map

flight_map_df <- flight.data

flight_map_df <- flight_map_df %>% group_by(dest) %>% mutate(count = n())

airports <- read.csv("/Users/clairecasey/Downloads/697VGroup1/airports.csv")

flight_dest_airports <- airports %>% subset(IATA %in% flight_map_df$dest)

# counts for delayed/not delayed flights

delay_flight_paths <- flight_map_df %>% group_by(dest) %>% mutate(delay_ct = sum(delay)) 

delay_flight_paths <- delay_flight_paths %>% mutate(delay_pct = (delay_ct)/count)

#DF containing unique flight paths, their counts, and % delay

delay_flight_paths2 <- delay_flight_paths %>% group_by(origin, count, delay_pct) %>% distinct(dest)

#change delay flights df column names to match airport DF

colnames(delay_flight_paths2) <- c("origin", "count", "delay_pct", "IATA")


#left join to get lat/lon coordinates of each destination airport (end lon/lat)

delay_flight_paths_map <- left_join(delay_flight_paths2, flight_dest_airports, by = "IATA")

colnames(delay_flight_paths_map) <- c("origin", "count", "delay_pct", "IATA", "dest_AIRPORT", "dest_CITY", "dest_STATE", "dest_COUNTRY", "end_lat", "end_lon")

#mutate column with DCA airport lon/lat (38.85208,-77.03772) (start lon/lat)

DCA_lat <- 38.85208

DCA_lon <- -77.03772

delay_flight_paths_map <- delay_flight_paths_map %>% mutate(start_lat = DCA_lat, start_lon = DCA_lon)

#airport DF created by using distinct lat/lon of each airport in my DCA flights dataset

flight_airports <- airports %>% subset(IATA %in% flight_map_df$dest|IATA %in% flight_map_df$origin)
  
  #color map by delay percentage:
  
  delay_factored <- function(delay_pct){
    
    delay_degree <- c()
    
    for(i in 1:length(delay_pct)) {
      
      if(delay_pct[i] <= 0.05) {
        
        delay_degree[i] <- "<= 5% Delay Rate" 
      } 
      else if(delay_pct[i] > 0.05 & delay_pct[i] <= 0.1){
        
        delay_degree[i] <- "<= 10% Delay Rate"
      }
      else if(delay_pct[i] > 0.1 & delay_pct[i] <= 0.15){
        
        delay_degree[i] <- "<= 15% Delay Rate"
      }
      else if(delay_pct[i] > 0.15 & delay_pct[i] <= 0.2){
        
        delay_degree[i] <- "<= 20% Delay Rate"
      }
      else if(delay_pct[i] > 0.2 & delay_pct[i] <= 0.25){
        
        delay_degree[i] <- "<= 25% Delay Rate"
      }
      else if(delay_pct[i] > 0.25 & delay_pct[i] <= 0.3){
        
        delay_degree[i] <- "<= 30% Delay Rate"
      }
      else if(delay_pct[i] > 0.3 & delay_pct[i] <= 0.35){
        
        delay_degree[i] <- "<= 35% Delay Rate"
      }
      else if(delay_pct[i] > 0.35 & delay_pct[i] <= 0.4){
        
        delay_degree[i] <- "<= 40% Delay Rate"
      }
      else if(delay_pct[i] > 0.4 & delay_pct[i] <= 0.45){
        
        delay_degree[i] <- "<= 45% Delay Rate"
      }
      else if(delay_pct[i] > 0.45 & delay_pct[i] <= 0.50){
        
        delay_degree[i] <- "<= 50% Delay Rate"
      } else{
        
        delay_degree[i] <- "> 50% Delay Rate"
      }
    }
    return(delay_degree)
  }

how_much_delay <- delay_factored(delay_flight_paths_map$delay_pct)

delay_flight_paths_map <- cbind(delay_flight_paths_map, how_much_delay)

colnames(delay_flight_paths_map)[13] <- "how_much_delay"

#Add count variable to flight_airports dataset for size reference 

#new_row = c(origin = "DCA", count = as.integer(10), delay_pct = NA, IATA = "DCA")
#flight_airports_map = rbind(delay_flight_paths2, new_row)

delay_flight_paths2 <- delay_flight_paths2 %>% ungroup() %>% 
  add_row(origin = "DCA", count = 10, delay_pct = NA, IATA = "DCA")

#join 2 dfs to obtain count variable

flight_airports_map <- left_join(flight_airports, delay_flight_paths2, by = "IATA")


#################################### UI ########################################

ui <- fluidPage(
  
  titlePanel("Predicting Flight Delay from DCA Airport"),
  
  
  sidebarLayout(
    
    sidebarPanel(
      selectizeInput(inputId = "day",
                     label = "On what day of the week is your flight?",
                     choices = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"),
                     selected = "Friday"),
      
      selectizeInput(inputId = "month",
                     label = "In what month is your flight?",
                     choices = c("April", "May", "June", "July", "August"),
                     selected = "April"),
      
  
      selectizeInput(inputId = "carrier",
                     label ="Which airline carrier are you flying?",
                     choices = c("Endeavor Air", "American Airlines", "Alaska Airlines", "JetBlue Airways", "Delta Airlines", "Frontier Airlines", "Envoy Air", "PSA Airlines", "SkyWest Airlines", "United Airlines", "Southwest Airlines", "Mesa Airlines", "Republic Airlines"),
                     selected = "American Airlines"),
      
      timeInput(inputId = "timeof",
                     label ="What time does your flight depart (Military time)?",
                     seconds = FALSE),
      
      numericInput(inputId = "duration",
                     label = "What is the duration of your flight in minutes?",
                     value = 60, min = 0, max = 1440),
      
    
      checkboxGroupInput(inputId = "interactions_plot",
                         label = "Choose a Variable(s) to Visualize their (Joint) Effect:",
                         choices = c("day", "month", "carrier", "depart", "duration"),
                         selected="day"
      )
      
    ),
    
    mainPanel(
      h2(textOutput("cancel_pred")),
      tags$style(type="text/css",
                   ".shiny-output-error { visibility: hidden; }",
                   ".shiny-output-error:before { visibility: hidden; }"),
      tabPanel("Your Prediction", plotOutput(outputId = "interactioneffectplot"), 
               actionButton("pred", "Predict!"), 
               actionButton("intplot", "Visualize (Joint) Effects")), 
               actionButton("Update", "Update Delay Distribution for Selected D.O.W."), 
               actionButton("revert", "Revert to Original"), 
               plotlyOutput(outputId = "map")
    )
  )
 )



#################################### SERVER ########################################

server <- function(input, output, session) {
  
  
  interactionseffectsplot <- eventReactive(input$intplot, 
                                           {depart <- hour(input$timeof)*60 + minute(input$timeof)    # convert hh:mm time back to minutes
                                             
                                             ggpredict(mod, terms = input$interactions_plot, condition = c(day = (input$day),
                                                                                                             month = (input$month),
                                                                                                             carrier = (input$carrier),
                                                                                                             duration = as.numeric(input$adults),
                                                                                                             depart = as.numeric(depart))) 
                                                       })
 
  
                                                                                                           
                                                                                                           
                                                                                                           
                                                                                                           
  predict_cancel <- eventReactive(input$pred, 
                                  {depart <- hour(input$timeof)*60 + minute(input$timeof) # convert hh:mm time back to minutes
                                    
                                    pred_df = data.frame(
                                    day = as.factor(input$day),
                                    month = as.factor(input$month),
                                    carrier = as.factor(input$carrier),
                                    depart = as.numeric(depart),
                                    duration = as.numeric(input$duration),
                                    stringsAsFactors = TRUE)
                                  
                                  
                                  
                                  
                                  predc <- predict(mod, newdata = pred_df, type="response")
                                  
                                  round(predc*100, 2)
                                  
                                  
                                  })

  
  
  output$interactioneffectplot <- renderPlot({i <- interactionseffectsplot()
  
  
  plot(i, ci=T, ci.style="ribbon") 
  
  })
  
  

 observeEvent(input$Update, { 
   
   # Map projection:
   geo <- list(
     projection = list(
       type = 'orthographic', 
       rotation = list(lon = -100, lat = 40, roll = 0)
     ),
     center = list(lon=-100, lat=40),
     lonaxis = list(range = c(-130, -50)),
     lataxis = list(range = c(20,60)),
     showland = TRUE,
     landcolor = toRGB("#e5ecf6")
   )
   
   output$map <- renderPlotly({
     
     
     
     # get unique flight counts for my DCA flights dataset given the selected day
     
     flight_map_df <- flight.data %>% subset(day %in% input$day)
     
     flight_dest_airports <- airports %>% subset(IATA %in% flight_map_df$dest)
     
     flight_map_df <- flight_map_df %>% group_by(dest) %>% mutate(count = n())
     
     # counts for delayed/not delayed flights
     
     delay_flight_paths <- flight_map_df %>% group_by(dest) %>% mutate(delay_ct = sum(delay)) 
     
     delay_flight_paths <- delay_flight_paths %>% mutate(delay_pct = (delay_ct)/count)
     
     #DF containing unique flight paths, their counts, and % delay
     
     delay_flight_paths2 <- delay_flight_paths %>% group_by(origin, count, delay_pct) %>% distinct(dest)
     
     #change delay flights df column names to match airport DF
     
     colnames(delay_flight_paths2) <- c("origin", "count", "delay_pct", "IATA")
     
     
     #left join to get lat/lon coordinates of each destination airport (end lon/lat)
     
     delay_flight_paths_map <- left_join(delay_flight_paths2, flight_dest_airports, by = "IATA")
     
     colnames(delay_flight_paths_map) <- c("origin", "count", "delay_pct", "IATA", "dest_AIRPORT", "dest_CITY", "dest_STATE", "dest_COUNTRY", "end_lat", "end_lon")
     
     #mutate column with DCA airport lon/lat (38.85208,-77.03772) (start lon/lat)
     
     DCA_lat <- 38.85208
     
     DCA_lon <- -77.03772
     
     delay_flight_paths_map <- delay_flight_paths_map %>% mutate(start_lat = DCA_lat, start_lon = DCA_lon)
     
     #airport DF created by using distinct lat/lon of each airport in my DCA flights dataset
     
     flight_airports <- airports %>% subset(IATA %in% flight_map_df$dest|IATA %in% flight_map_df$origin)
     
     #color map by delay percentage:
     
     delay_factored <- function(delay_pct){
       
       delay_degree <- c()
       
       for(i in 1:length(delay_pct)) {
         
         if(delay_pct[i] <= 0.05) {
           
           delay_degree[i] <- "<= 5% Delay Rate" 
         } 
         else if(delay_pct[i] > 0.05 & delay_pct[i] <= 0.1){
           
           delay_degree[i] <- "<= 10% Delay Rate"
         }
         else if(delay_pct[i] > 0.1 & delay_pct[i] <= 0.15){
           
           delay_degree[i] <- "<= 15% Delay Rate"
         }
         else if(delay_pct[i] > 0.15 & delay_pct[i] <= 0.2){
           
           delay_degree[i] <- "<= 20% Delay Rate"
         }
         else if(delay_pct[i] > 0.2 & delay_pct[i] <= 0.25){
           
           delay_degree[i] <- "<= 25% Delay Rate"
         }
         else if(delay_pct[i] > 0.25 & delay_pct[i] <= 0.3){
           
           delay_degree[i] <- "<= 30% Delay Rate"
         }
         else if(delay_pct[i] > 0.3 & delay_pct[i] <= 0.35){
           
           delay_degree[i] <- "<= 35% Delay Rate"
         }
         else if(delay_pct[i] > 0.35 & delay_pct[i] <= 0.4){
           
           delay_degree[i] <- "<= 40% Delay Rate"
         }
         else if(delay_pct[i] > 0.4 & delay_pct[i] <= 0.45){
           
           delay_degree[i] <- "<= 45% Delay Rate"
         }
         else if(delay_pct[i] > 0.45 & delay_pct[i] <= 0.50){
           
           delay_degree[i] <- "<= 50% Delay Rate"
         } else{
           
           delay_degree[i] <- "> 50% Delay Rate"
         }
       }
       return(delay_degree)
     }
     
     how_much_delay <- delay_factored(delay_flight_paths_map$delay_pct)
     
     delay_flight_paths_map2 <- cbind(delay_flight_paths_map, how_much_delay)
     
     colnames(delay_flight_paths_map2)[13] <- "how_much_delay"
     
     #Add count variable to flight_airports dataset for size reference 
     
     delay_flight_paths2 <- delay_flight_paths2 %>% ungroup() %>% 
       add_row(origin = "DCA", count = 10, delay_pct = NA, IATA = "DCA")
     
     #join 2 dfs to obtain count variable
     
     flight_airports_map <- left_join(flight_airports, delay_flight_paths2, by = "IATA") 
     
     my_day <- input$day
     
     plot_geo(color = I("blue")) %>%
     add_segments(
       data = delay_flight_paths_map2,
       x = ~start_lon,
       xend = ~end_lon,
       y = ~start_lat,
       yend = ~end_lat,
       alpha = 0.3,
       size = I(1),
       color = ~how_much_delay,
       colors =  brewer.pal(11, "Spectral"),
       hoverinfo = "none"
     ) %>%
     add_markers(
       data = flight_airports_map,
       x = ~LONGITUDE,
       y = ~LATITUDE,
       text = ~paste0("Delay Percentage on ", my_day, " from DCA to ", AIRPORT, ": ", 100*round(delay_pct,2), "%"),
       size = ~count,
       hoverinfo = "text",
       alpha = 0.5,
       showlegend = F
     ) %>%
     layout(geo = geo, showlegend = TRUE)
   })
  
   })
 
  
observeEvent(input$revert, {
  
  
  # Map projection:
  output$map <- renderPlotly({
    
    
    flight_map_df <- flight.data 
    
    flight_map_df <- flight_map_df %>% group_by(dest) %>% mutate(count = n())
    
    # counts for delayed/not delayed flights
    
    delay_flight_paths <- flight_map_df %>% group_by(dest) %>% mutate(delay_ct = sum(delay)) 
    
    delay_flight_paths <- delay_flight_paths %>% mutate(delay_pct = (delay_ct)/count)
    
    #DF containing unique flight paths, their counts, and % delay
    
    delay_flight_paths2 <- delay_flight_paths %>% group_by(origin, count, delay_pct) %>% distinct(dest)
    
    #change delay flights df column names to match airport DF
    
    colnames(delay_flight_paths2) <- c("origin", "count", "delay_pct", "IATA")
    
    
    #left join to get lat/lon coordinates of each destination airport (end lon/lat)
    
    delay_flight_paths_map <- left_join(delay_flight_paths2, flight_dest_airports, by = "IATA")
    
    colnames(delay_flight_paths_map) <- c("origin", "count", "delay_pct", "IATA", "dest_AIRPORT", "dest_CITY", "dest_STATE", "dest_COUNTRY", "end_lat", "end_lon")
    
    #mutate column with DCA airport lon/lat (38.85208,-77.03772) (start lon/lat)
    
    DCA_lat <- 38.85208
    
    DCA_lon <- -77.03772
    
    delay_flight_paths_map <- delay_flight_paths_map %>% mutate(start_lat = DCA_lat, start_lon = DCA_lon)
    
    #airport DF created by using distinct lat/lon of each airport in my DCA flights dataset
    
    flight_airports <- airports %>% subset(IATA %in% flight_map_df$dest|IATA %in% flight_map_df$origin)
    
    
    #color map by delay percentage:
    
    delay_factored <- function(delay_pct){
      
      delay_degree <- c()
      
      for(i in 1:length(delay_pct)) {
        
        if(delay_pct[i] <= 0.05) {
          
          delay_degree[i] <- "<= 5% Delay Rate" 
        } 
        else if(delay_pct[i] > 0.05 & delay_pct[i] <= 0.1){
          
          delay_degree[i] <- "<= 10% Delay Rate"
        }
        else if(delay_pct[i] > 0.1 & delay_pct[i] <= 0.15){
          
          delay_degree[i] <- "<= 15% Delay Rate"
        }
        else if(delay_pct[i] > 0.15 & delay_pct[i] <= 0.2){
          
          delay_degree[i] <- "<= 20% Delay Rate"
        }
        else if(delay_pct[i] > 0.2 & delay_pct[i] <= 0.25){
          
          delay_degree[i] <- "<= 25% Delay Rate"
        }
        else if(delay_pct[i] > 0.25 & delay_pct[i] <= 0.3){
          
          delay_degree[i] <- "<= 30% Delay Rate"
        }
        else if(delay_pct[i] > 0.3 & delay_pct[i] <= 0.35){
          
          delay_degree[i] <- "<= 35% Delay Rate"
        }
        else if(delay_pct[i] > 0.35 & delay_pct[i] <= 0.4){
          
          delay_degree[i] <- "<= 40% Delay Rate"
        }
        else if(delay_pct[i] > 0.4 & delay_pct[i] <= 0.45){
          
          delay_degree[i] <- "<= 45% Delay Rate"
        }
        else if(delay_pct[i] > 0.45 & delay_pct[i] <= 0.50){
          
          delay_degree[i] <- "<= 50% Delay Rate"
        } else{
          
          delay_degree[i] <- "> 50% Delay Rate"
        }
      }
      return(delay_degree)
    }
    
    how_much_delay <- delay_factored(delay_flight_paths_map$delay_pct)
    
    delay_flight_paths_map1 <- cbind(delay_flight_paths_map, how_much_delay)
    
    colnames(delay_flight_paths_map1)[13] <- "how_much_delay"
    
    #Add count variable to flight_airports dataset for size reference 
    
    delay_flight_paths2 <- delay_flight_paths2 %>% ungroup() %>% 
      add_row(origin = "DCA", count = 10, delay_pct = NA, IATA = "DCA")
    
    #join 2 dfs to obtain count variable
    
    flight_airports_map <- left_join(flight_airports, delay_flight_paths2, by = "IATA")
    
    geo <- list(
    projection = list(
      type = 'orthographic', 
      rotation = list(lon = -100, lat = 40, roll = 0)
    ),
    center = list(lon=-100, lat=40),
    lonaxis = list(range = c(-130, -50)),
    lataxis = list(range = c(20,60)),
    showland = TRUE,
    landcolor = toRGB("#e5ecf6")
  )
  
    plot_geo(color = I("blue")) %>%
    add_segments(
      data = delay_flight_paths_map1,
      x = ~start_lon,
      xend = ~end_lon,
      y = ~start_lat,
      yend = ~end_lat,
      alpha = 0.3,
      size = I(1),
      color = ~how_much_delay,
      colors =  brewer.pal(11, "Spectral"),
      hoverinfo = "none"
    ) %>%
    add_markers(
      data = flight_airports_map,
      x = ~LONGITUDE,
      y = ~LATITUDE,
      text = ~paste0("Delay Percentage from DCA to ", AIRPORT, ": ", 100*round(delay_pct,2), "%"),
      size = ~count,
      hoverinfo = "text",
      alpha = 0.5,
      showlegend = F
    ) %>%
    layout(geo = geo, showlegend = TRUE)
  })
  
  
})

  
 
   output$map <- renderPlotly({
     
     delay_flight_paths_map <- as.data.frame(delay_flight_paths_map)
     
     # Map projection:
     geo <- list(
       projection = list(
         type = 'orthographic', 
         rotation = list(lon = -100, lat = 40, roll = 0)
       ),
       center = list(lon=-100, lat=40),
       lonaxis = list(range = c(-130, -50)),
       lataxis = list(range = c(20,60)),
       showland = TRUE,
       landcolor = toRGB("#e5ecf6")
     )
     
       plot_geo(color = I("blue")) %>%
       add_segments(
         data = delay_flight_paths_map,
         x = ~start_lon,
         xend = ~end_lon,
         y = ~start_lat,
         yend = ~end_lat,
         alpha = 0.3,
         size = I(1),
         color = ~how_much_delay,
         colors =  brewer.pal(11, "Spectral"),
         hoverinfo = "none"
       ) %>%
       add_markers(
         data = flight_airports_map,
         x = ~LONGITUDE,
         y = ~LATITUDE,
         text = ~paste0("Delay Percentage from DCA to ", AIRPORT, ": ", 100*round(delay_pct,2), "%"),
         size = ~count,
         hoverinfo = "text",
         alpha = 0.5,
         showlegend = F
       ) %>%
       layout(geo = geo, showlegend = TRUE)

     
  })
  
  
  
  output$cancel_pred <- renderText({paste0("The probability of flight delay from DCA: ", predict_cancel(), "%")})
  
}
options(warn = oldw)

shinyApp(ui = ui, server = server)



