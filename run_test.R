run_test <- function() {
  # Document what's going on here; and inject variables instead of setting globally (?)
  
  message('Building Models')
  time.training <- system.time({
    build_models()
  })
  
  message('Making Predictions')
  time.prediction <- system.time({
    testing.predictions <- map(testing.sentences$predictor, function(x) { 
      make_prediction(x, highest_order_ngram, ngram.rankings)[,'outcome']
    })
  })
  
  # Simplify
  testing.outcome <- t(as.data.frame(testing.predictions))
  result <- cbind(testing.sentences, testing.outcome) %>%
    mutate(match = outcome == `1` | outcome == `2` | outcome == `3`)
  result.accuracy <- sum(result$match)/nrow(result)
  
  # Store results
  test.result <- data.frame(training_data_size,
                            minOccurrence,
                            highest_order_ngram,
                            ngram.rankings,
                            result.accuracy,
                            time.training['elapsed'],
                            time.prediction['elapsed'])
  
  return(test.result)
}