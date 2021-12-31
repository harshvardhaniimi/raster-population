library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    theme = shinytheme("united"),
    
    # navigation panel
    navbarPage(title = "Raster-based Cropping",
               tabPanel(
                   "India - URCA",
                   
                   # Application title
                   titlePanel("India: Urban-Rural Raster Population"),
                   
                   # Sidebar with a slider input for number of bins
                   sidebarLayout(
                       sidebarPanel(
                           sliderInput(
                               "divider",
                               "Region divider number:",
                               min = 1,
                               max = 29,
                               value = 7
                           ),
                           submitButton("Run now", icon("refresh")),
                           hr(),
                           helpText(
                               "Click the button in main panel to download the file you want. Running the code takes around a minute."
                           )
                       ),
                       
                       # Show a plot of the generated distribution
                       mainPanel(
                           plotOutput("pl"),
                           downloadButton("download1", "Download State-level Rural Population"),
                           downloadButton("download2", "Download State-level Urban Population"),
                           downloadButton("download3", "Download District-level Rural Population"),
                           downloadButton("download4", "Download District-level Urban Population")
                       )
                   )
               ),
               
               tabPanel(
                 "Any Country - Population",
                 # Application title
                 titlePanel("Any Country: Urban-Rural Raster Population"),
                 
                 # Sidebar with a slider input for number of bins
                 sidebarLayout(
                     sidebarPanel(
                         selectInput(inputId = "country",
                                     label = "Select country or location",
                                     choices = raster::getData("ISO3")$NAME,
                                     width = "100%"),
                         sliderInput(
                             "divider",
                             "Region divider number:",
                             min = 1,
                             max = 29,
                             value = 7
                         ),
                         submitButton("Run now", icon("refresh")),
                         hr(),
                         helpText(
                             "Click the button in main panel to download the file you want. Running the code takes 2-3 minutes."
                         )
                     ),
                     
                     # Show a plot of the generated distribution
                     mainPanel(
                         plotOutput("pl_ac"),
                         downloadButton("download1_ac", "Download State-level Rural Population"),
                         downloadButton("download2_ac", "Download State-level Urban Population"),
                         downloadButton("download3_ac", "Download District-level Rural Population"),
                         downloadButton("download4_ac", "Download District-level Urban Population")
                     )
                 )
               ),
               
               tabPanel(
                   "FAQ",
                   h4("What is this app for?"),
                   p("Something useful."),
                   h4("How to use it?"),
                   p("If you want to download data for India, go to the first tab. For all other countries, go to the second tab. \nOnce you are on the relevant tab, wait for the population density plot to appear. Then click on the file you want to download. The process to create downloadable files will take around 1-2 minutes for India and 4-5 minutes for other countries (on a 30 mbps connection speed)."),
                   h4("Why such long wait time?"),
                   p("Because good things take time. For the first time, the files are downloaded on the go which takes time. Additionally, working with rasters is a slow process due to their sheer size. Your internet speed and system configuration would determine the overall speed.")
               ),
               
               tabPanel(
                   "India - Any Raster",
                   h4("Code for cropping any raster by Indian national, state and district boundaries.")
               ),
               
               tabPanel(
                   "Any Country - Any Raster",
                   h4("Code for cropping any country and its national and regional boundaries by any raster.")
               )
               )
))
