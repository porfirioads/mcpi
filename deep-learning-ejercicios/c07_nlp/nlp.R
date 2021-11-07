# Formatting data using tokenization
# -----------------------------------------------------------

library(tidyverse)
library(tidytext)
library(spacyr)
library(textmineR)

twenty_newsgroups <- read_csv("http://ssc.wisc.edu/~ahanna/20_newsgroups.csv")

twenty_newsgroups[1,]

word_tokens <- twenty_newsgroups %>%
  unnest_tokens(word, text)

word_tokens %>%
  group_by(word) %>%
  summarize(word_count = n()) %>%
  top_n(20) %>%
  ggplot(aes(x = reorder(word, word_count), word_count)) +
  xlab("word") +
  geom_col() +
  coord_flip()

# Cleaning text to remove noise
# -----------------------------------------------------------

word_tokens <- word_tokens %>%
  filter(!word %in% stop_words$word)

word_tokens %>%
  group_by(word) %>%
  summarize(word_count = n()) %>%
  top_n(20) %>%
  ggplot(aes(x = reorder(word, word_count), word_count)) +
  xlab("word") +
  geom_col() +
  coord_flip()

word_tokens <- word_tokens %>%
  filter(str_detect(word, "^[a-z]+[a-z]$"))

# Applying word embeddings to increase usable data
# -----------------------------------------------------------

spacy_install()

spacy_initialize(model = "en_core_web_sm")

spacy_parse(twenty_newsgroups$text[1], entity = TRUE, lemma = TRUE)

# Clustering data into topic groups
# -----------------------------------------------------------

tcm <- CreateTcm(doc_vec = twenty_newsgroups$text, skipgram_window = 10, verbose = FALSE, cpus = 2)

embeddings <- FitLdaModel(dtm = tcm,
                          k = 20,
                          iterations = 500,
                          burnin = 200,
                          calc_coherence = TRUE)

embeddings$top_terms <- GetTopTerms(phi = embeddings$phi,
                                    M = 5)

embeddings$summary <- data.frame(topic = rownames(embeddings$phi),
                                 coherence = round(embeddings$coherence, 3),
                                 prevalence = round(colSums(embeddings$theta), 2),
                                 top_terms = apply(embeddings$top_terms, 2, function(x) {
                                   paste(x, collapse = ", ")
                                 }),
                                 stringsAsFactors = FALSE)

embeddings$summary[order(embeddings$summary$coherence, decreasing = TRUE),][1:5,]

# Summarizing documents using model results
# -----------------------------------------------------------

twenty_newsgroups$text[400]

sentences <- tibble(text = twenty_newsgroups$text[400]) %>%
  unnest_tokens(sentence, text, token = "sentences") %>%
  mutate(id = row_number()) %>%
  select(id, sentence)

words <- sentences %>%
  unnest_tokens(word, sentence)

article_summary <- textrank_sentences(data = sentences, terminology = words)

article_summary[["sentences"]] %>%
  arrange(desc(textrank)) %>%
  top_n(1) %>%
  pull(sentence)

# Creating an RBM
# -----------------------------------------------------------

library(tm)
library(deepnet)

corpus <- Corpus(VectorSource(twenty_newsgroups$text))

corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeWords, c("the", "and", stopwords("english")))
corpus <- tm_map(corpus, stripWhitespace)

news_dtm <- DocumentTermMatrix(corpus, control = list(weighting = weightTfIdf))
news_dtm <- removeSparseTerms(news_dtm, 0.95)

split_ratio <- floor(0.75 * nrow(twenty_newsgroups))

set.seed(614)
train_index <- sample(seq_len(nrow(twenty_newsgroups)), size = split_ratio)

train_x <- news_dtm[train_index,]
train_y <- twenty_newsgroups$target[train_index]
test_x <- news_dtm[-train_index,]
test_y <- twenty_newsgroups$target[-train_index]

rbm <- rbm.train(x = as.matrix(train_x), hidden = 20, numepochs = 100)

test_latent_features <- rbm.up(rbm, as.matrix(test_x))

# Defining the Gibbs sampling rate
# -----------------------------------------------------------

gibbs <- function(n, rho)
{
  mat <- matrix(ncol = 2, nrow = n)
  x <- 0
  y <- 0
  mat[1,] <- c(x, y)
  for (i in 2:n) {
    x <- rnorm(1, rho * y, sqrt(1 - rho^2))
    y <- rnorm(1, rho * x, sqrt(1 - rho^2))
    mat[i,] <- c(x, y)
  }
  mat
}

gibbs(10, 0.75)

gibbs(10, 0.03)

# Speeding up sampling with contrastive divergence
# -----------------------------------------------------------

spam_vs_ham <- read.csv("spam.csv")

y <- if_else(spam_vs_ham$v1 == "spam", 1, 0)
x <- spam_vs_ham$v2 %>%
  str_replace_all("[^a-zA-Z0-9/:-_]|\r|\n|\t", " ") %>%
  str_replace_all("\b[a-zA-Z0-9/:-]{1,2}\b", " ") %>%
  str_trim("both") %>%
  str_squish()

corpus <- Corpus(VectorSource(x))
dtm <- DocumentTermMatrix(corpus)

split_ratio <- floor(0.75 * nrow(dtm))

set.seed(614)
train_index <- sample(seq_len(nrow(dtm)), size = split_ratio)

train_x <- dtm[train_index,]
train_y <- y[train_index]
test_x <- dtm[-train_index,]
test_y <- y[-train_index]

rbm3 <- rbm.train(x = as.matrix(train_x), hidden = 100, cd = 3, numepochs = 5)
rbm5 <- rbm.train(x = as.matrix(train_x), hidden = 100, cd = 5, numepochs = 5)
rbm1 <- rbm.train(x = as.matrix(train_x), hidden = 100, cd = 1, numepochs = 5)

# Computing free energy for model evaluation
# -----------------------------------------------------------

rbm5$e[1:10]
rbm3$e[1:10]
rbm1$e[1:10]

# Stacking RBMs to create a deep belief network
# -----------------------------------------------------------

train_latent_features <- rbm.up(rbm1, as.matrix(train_x))
test_latent_features <- rbm.up(rbm1, as.matrix(test_x))

dbn <- dbn.dnn.train(x = as.matrix(train_x), y = train_y, hidden = c(100, 50, 10), cd = 1, numepochs = 5)

predictions <- nn.predict(dbn, as.matrix(test_x))

pred_class <- if_else(predictions > 0.3, 1, 0)
table(test_y, pred_class)
