library(tidyverse)
library(tidytext)
library(magrittr)

library(tm)
library(RWeka)
library(stringr)

source("./build_ngram_models.R")
source("./predictions.R")

if (!exists("joined_data_cleaned")) {
    joined_data_cleaned <- readRDS("./files/joined_data_cleaned.rds") %>% select(-source, -cld2, -cld3)
}

set.seed(1337)
training <- sample_frac(joined_data_cleaned, 0.9)
testing <- sample_n(joined_data_cleaned, 10)

# Preparing test sentences
testing.sentences <- testing %>% 
    unnest_tokens(word, text, token = 'ngrams', n = 8) %>%
    count(word, sort = TRUE) %>%
    separate(word, into = c('predictor', 'outcome'), sep = "\\s(?=\\S*$)") %>% 
    sample_n(100)

run_test <- function() {
    time.training <- system.time({
        build_models()
    })
    
    time.prediction <- system.time({
        # Running tests
        testing.predictions <- map(testing.sentences$predictor, function(x) { 
            x <- gsub("'","", x) # ! Should be handled in data cleaning
            make_prediction(x, highest_order_ngram)[,'outcome']
        })
    })
        
    testing.outcome <- t(as.data.frame(testing.predictions))
    result <- cbind(testing.sentences, testing.outcome) %>%
        mutate(match = outcome == `1` | outcome == `2` | outcome == `3`)
    result.accuracy <- sum(result$match)/nrow(result)
    
    # Store results...
    test.result <- data.frame(training_data_size,
                              minOccurrence,
                              highest_order_ngram,
                              ngram.rankings,
                              result.accuracy,
                              time.training['elapsed'],
                              time.prediction['elapsed'])

    return(test.result)
}

# Dataframe to store results in
model.results <- data.frame(matrix(ncol = 7, nrow = 0), stringsAsFactors=FALSE)

# Training parameters
training.param.data.steps <- 1:6
training.param.data.step.size <- 0.05
training.param.ngrams <- c(1:3)

#training_data_size <- 0.05
#highest_order_ngram <- 2

minOccurrence <- 0
ngram.rankings <- 3

for (ngramSize in training.param.ngrams) {
    highest_order_ngram <- ngramSize
    
    for (data.step in training.param.data.steps) {
        training_data_size <- data.step * training.param.data.step.size
        
        data <- sample_frac(training, training_data_size)
        test.result <- run_test()
        print(test.result)
        
        model.results <- rbind(test.result, model.results)
    }
}

model.results