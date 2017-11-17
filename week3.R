library(tidyverse)
library(tidytext)
library(magrittr)
library(tm)
library(RWeka)
library(stringr)

source("./build_ngram_models.R")
source("./predictions.R")
source("./run_test.R")

if (!exists("joined_data_cleaned")) {
  joined_data_cleaned <- readRDS("./files/joined_data_cleaned.rds") %>% 
    select(-source, -cld2, -cld3)
}

set.seed(1337)
training <- sample_frac(joined_data_cleaned, 0.9)
testing <- sample_n(joined_data_cleaned, 10)

# Preparing test sentences -------------------------------
testing.sentences <- testing %>% 
  unnest_tokens(word, text, token = 'ngrams', n = 8) %>%
  count(word, sort = TRUE) %>%
  separate(word, into = c('predictor', 'outcome'), sep = "\\s(?=\\S*$)") %>% 
  sample_n(100)

# Training parameters ------------------------------------
training.param.data.steps <- 1:3
training.param.data.step.size <- 0.05
training.param.ngrams <- 1:2

minOccurrence <- 0
ngram.rankings <- 3 # !! Only three supported in testing currently

# Running Tests ------------------------------------------
model.results <- data.frame(matrix(ncol = 7, nrow = 0), stringsAsFactors=FALSE)
for (ngramSize in training.param.ngrams) {
  highest_order_ngram <- ngramSize
  
  for (data.step in training.param.data.steps) {
    training_data_size <- data.step * training.param.data.step.size
    
    data <- sample_frac(training, training_data_size)
    test.result <- run_test()
    
    model.results <- rbind(test.result, model.results)
  }
}

# saveRDS(model.results, file="files/training_results_1.rds")