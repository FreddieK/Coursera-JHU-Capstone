library(sqldf)

# N-gram based prediction with fallback to lower dimension ngrams
#
# input.string
# ngram
#
# - ngram.rankings for how many results to return
# - ngram_x defined for ngram and lower
#
# Predictions
make_prediction <- function(input.string, ngram) {
    input.string.exploded <- str_split(input.string, " ")[[1]]
    ngram.predictionVector <- tail(input.string.exploded, ngram - 1)
    ngram.predictionString <- paste(ngram.predictionVector, collapse = " ")
    ngram.name <- paste("ngram_", ngram, sep = "")
    
    if (ngram == 1) return(ngram_1[1:ngram.rankings, 'outcome'])
    
    sql <- "select predictor, outcome from $ngram.name where predictor = '$ngram.predictionString' limit $ngram.rankings"
    predictions <- fn$sqldf(sql)
    
    # If enough matches are found, return results
    if (nrow(predictions) >= ngram.rankings) return(predictions[1:ngram.rankings,])
    
    # Recursive call to lower ngram dimension
    return(bind_rows(predictions, make_prediction(input.string, ngram - 1))[1:ngram.rankings,])
    
}