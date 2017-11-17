library(sqldf)

make_prediction <- function(input.string, ngram, ngram.rankings) {
  # N-gram based prediction with fallback to lower dimension ngrams
  #
  # input.string
  # ngram
  # ngram.rankings
  #
  # - ngram.rankings for how many results to return
  # - ngram_x defined for ngram and lower
  #
  # Predictions
  
  if (ngram == 1) return(ngram_1[1:ngram.rankings, 'outcome'])
  
  # Should be handled in data cleaning...
  input.string <- gsub("'","", input.string)
  input.string <- gsub(" $","", input.string, perl=T)
  
  input.string.exploded <- str_split(input.string, " ")[[1]]
  ngram.predictionVector <- tail(input.string.exploded, ngram - 1)
  ngram.predictionString <- paste(ngram.predictionVector, collapse = " ")
  ngram.name <- paste("ngram_", ngram, sep = "")
  
  sql <- "select predictor, outcome from $ngram.name where predictor = '$ngram.predictionString' limit $ngram.rankings"
  predictions <- fn$sqldf(sql)
  
  # If enough matches are found, return results
  if (nrow(predictions) >= ngram.rankings) return(predictions[1:ngram.rankings, ])
  
  # Recursive call to lower ngram dimension
  predictions <- bind_rows(predictions, make_prediction(input.string, ngram - 1, ngram.rankings))
  
  # Remove lower ngram duplicates of predicted words
  predictions <- predictions[!duplicated(predictions$outcome),]

  return(predictions[1:ngram.rankings, ])
}