#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Suggest next word"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       textInput('inputString', 
                 'label', 
                 value = "", 
                 width = NULL, 
                 placeholder = NULL),
       helpText("Start typing a sentence and get next word suggested")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tableOutput('tableResult')
    )
  )
))
