# Setup dependencies ------------------------------------------
library(shiny)

source("../predictions.R")

highest_order_ngram = 5
ngram.rankings = 5

# Replace with for loop based on configured highest_order_ngram
if (!exists("ngram_1")) {
  ngram_1 <- readRDS("../files/ngram_1_3_005_3_5.rds")
}

if (!exists("ngram_2")) {
  ngram_2 <- readRDS("../files/ngram_2_3_005_3_5.rds")
}

if (!exists("ngram_3")) {
  ngram_3 <- readRDS("../files/ngram_3_3_005_3_5.rds")
}

if (!exists("ngram_4")) {
  ngram_4 <- readRDS("../files/ngram_4_3_005_3_5.rds")
}

if (!exists("ngram_5")) {
  ngram_5 <- readRDS("../files/ngram_5_3_005_3_5.rds")
}

# Reactive Code ----------------------------------------------------
shinyServer(function(input, output) {
  
  # - How does it handle weird characters?,
  # - i/I => all lowercased is a problem
  # - Word cloud of most likely words (?) => need an estimated likelihood for that...
  
  output$tableResult <- renderTable({
    result <- make_prediction(input$inputString, highest_order_ngram, ngram.rankings)
    
    result
  })
  
})
