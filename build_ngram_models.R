# Build N-gram models

# Where is data coming from? Should be included in function call...

get_ngram <- function (number_of_words) {
    ngrams <- data %>% unnest_tokens(word, text, token = 'ngrams', n = number_of_words)
    
    ngram_freq <- ngrams %>%
        count(word, sort = TRUE) %>%
        separate(word, into = c('predictor', 'outcome'), sep = "\\s(?=\\S*$)") %>%
        filter(n > minOccurrence)
    
    return(ngram_freq)
}

# Make models available in global namespace
build_models <- function() {
    
    # construct filename, if exists; load. If not, create ngrams...
    
    for (ngram in 1:highest_order_ngram) {
        ngram.name <- paste("ngram_", ngram, sep = "")
        print(ngram.name)
        
        if(ngram == 1) {
            ngram_1 <<- data %>%
                unnest_tokens(word, text, token = 'words') %>%
                count(word, sort = TRUE)
            colnames(ngram_1) <<- c('outcome', 'n')
        }
        else {
            assign(ngram.name, get_ngram(ngram), envir = .GlobalEnv)
        }
    }
}