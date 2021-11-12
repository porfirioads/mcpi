# Preparing, preprocessing, and exploring data
# -----------------------------------------------------------

library(keras)
library(tidyverse)
library(knitr)

steamdata <- read_csv("data/steam-200k.csv", col_names = FALSE)

glimpse(steamdata)

colnames(steamdata) <- c("user", "item", "interaction", "value", "blank")

steamdata <- steamdata %>%
  filter(interaction == "play") %>%
  select(-blank) %>%
  select(-interaction) %>%
  mutate(item = str_replace_all(item, '[ [:blank:][:space:] ]', ""))

users <- steamdata %>%
  select(user) %>%
  distinct() %>%
  rowid_to_column()
steamdata <- steamdata %>%
  inner_join(users) %>%
  rename(userid = rowid)

items <- steamdata %>%
  select(item) %>%
  distinct() %>%
  rowid_to_column()
steamdata <- steamdata %>%
  inner_join(items) %>%
  rename(itemid = rowid)

steamdata <- steamdata %>% rename(title = item, rating = value)

n_users <- steamdata %>%
  select(userid) %>%
  distinct() %>%
  nrow()
n_items <- steamdata %>%
  select(itemid) %>%
  distinct() %>%
  nrow()

# normalize data with min-max function
minmax <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# add scaled rating value
steamdata <- steamdata %>% mutate(rating_scaled = minmax(rating))

# split into training and test
index <- sample(1:nrow(steamdata), 0.8 * nrow(steamdata))
train <- steamdata[index,]
test <- steamdata[-index,]

# create matrices of user, items, and ratings for training and test
x_train <- train %>%
  select(c(userid, itemid)) %>%
  as.matrix()
y_train <- train %>% select(rating_scaled) %>% as.matrix()
x_test <- test %>%
  select(c(userid, itemid)) %>%
  as.matrix()
y_test <- test %>% select(rating_scaled) %>% as.matrix()

# Performing exploratory data analysis
# -----------------------------------------------------------

# user-item interaction exploratory data analysis (EDA)
item_interactions <- aggregate(
  rating ~ title, data = steamdata, FUN = 'sum')
item_interactions <- item_interactions[
  order(item_interactions$rating, decreasing = TRUE),]
item_top10 <- head(item_interactions, 10)
kable(item_top10)

# average gamplay
steamdata %>% summarise(avg_gameplay = mean(rating))

# median gameplay
steamdata %>% summarise(median_gameplay = median(rating))

# top game by individual hours played
topgame <- steamdata %>%
  arrange(desc(rating)) %>%
  top_n(1, rating)

# show top game by individual hours played
kable(topgame)


# top 10 games by hours played
mostplayed <-
  steamdata %>%
    group_by(item) %>%
    summarise(hrs = sum(rating)) %>%
    arrange(desc(hrs)) %>%
    top_n(10, hrs) %>%
    ungroup

# show top 10 games by hours played
kable(mostplayed)

# reset factor levels for items
mostplayed$item <- droplevels(mostplayed$item)

# top 10 games by collective hours played
ggplot(mostplayed, aes(x = item, y = hrs, fill = hrs)) +
  aes(x = fct_inorder(item)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(size = 8, face = "bold", angle = 90)) +
  theme(axis.ticks = element_blank()) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1000000)) +
  labs(title = "Top 10 games by collective hours played") +
  xlab("game") +
  ylab("hours")


# most popular games by total users
mostusers <-
  steamdata %>%
    group_by(item) %>%
    summarise(users = n()) %>%
    arrange(desc(users)) %>%
    top_n(10, users) %>%
    ungroup

# reset factor levels for items
mostusers$item <- droplevels(mostusers$item)

# top 10 popular games by total users
ggplot(mostusers, aes(x = item, y = users, fill = users)) +
  aes(x = fct_inorder(item)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(size = 8, face = "bold", angle = 90)) +
  theme(axis.ticks = element_blank()) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 5000)) +
  labs(title = "Top 10 popular games by total users") +
  xlab("game") +
  ylab("users")


summary(steamdata$value)


# plot item iteraction
ggplot(steamdata, aes(x = steamdata$value)) +
  geom_histogram(stat = "bin", binwidth = 50, fill = "steelblue") +
  theme(axis.ticks = element_blank()) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 60000)) +
  labs(title = "Item interaction distribution") +
  xlab("Hours played") +
  ylab("Count")


# plot item iteraction with log transformation
ggplot(steamdata, aes(x = steamdata$value)) +
  geom_histogram(stat = "bin", binwidth = 0.25, fill = "steelblue") +
  theme(axis.ticks = element_blank()) +
  scale_x_log10() +
  labs(title = "Item interaction distribution with log transformation") +
  xlab("log(Hours played)") +
  ylab("Count")

# Building and training a neural recommender system
# -----------------------------------------------------------

# create custom model with user and item embeddings
dot <- function(
  embedding_dim,
  n_users,
  n_items,
  name = "dot"
) {
  keras_model_custom(name = name, function(self) {
    self$user_embedding <- layer_embedding(
      input_dim = n_users + 1,
      output_dim = embedding_dim,
      name = "user_embedding")
    self$item_embedding <- layer_embedding(
      input_dim = n_items + 1,
      output_dim = embedding_dim,
      name = "item_embedding")
    self$dot <- layer_lambda(
      f = function(x)
        k_batch_dot(x[[1]], x[[2]], axes = 2),
      name = "dot"
    )
    function(x, mask = NULL, training = FALSE) {
      users <- x[, 1]
      items <- x[, 2]
      user_embedding <- self$user_embedding(users)
      item_embedding <- self$item_embedding(items)
      dot <- self$dot(list(user_embedding, item_embedding))
    }
  })
}

# initialize embedding parameter
embedding_dim <- 50

# define model
model <- dot(
  embedding_dim,
  n_users,
  n_items
)

# compile model
model %>% compile(
  loss = "mse",
  optimizer = "adam"
)

# train model
history <- model %>% fit(
  x_train,
  y_train,
  epochs = 10,
  batch_size = 500,
  validation_data = list(x_test, y_test),
  verbose = 1
)

summary(model)

# Evaluating results and tuning hyperparameters
# -----------------------------------------------------------

# evaluate results
plot(history)

# caculate minimum and max rating
min_rating <- steamdata %>%
  summarise(min_rating = min(rating_scaled)) %>%
  pull()
max_rating <- steamdata %>%
  summarise(max_rating = max(rating_scaled)) %>%
  pull()

# create custom model with user, item, and bias embeddings
dot_with_bias <- function(
  embedding_dim,
  n_users,
  n_items,
  min_rating,
  max_rating,
  name = "dot_with_bias"
) {
  keras_model_custom(name = name, function(self) {
    self$user_embedding <- layer_embedding(
      input_dim = n_users + 1,
      output_dim = embedding_dim,
      name = "user_embedding")
    self$item_embedding <- layer_embedding(
      input_dim = n_items + 1,
      output_dim = embedding_dim,
      name = "item_embedding")
    self$user_bias <- layer_embedding(
      input_dim = n_users + 1,
      output_dim = 1,
      name = "user_bias")
    self$item_bias <- layer_embedding(
      input_dim = n_items + 1,
      output_dim = 1,
      name = "item_bias")


    self$user_dropout <- layer_dropout(
      rate = 0.3)
    self$item_dropout <- layer_dropout(
      rate = 0.5)
    self$dot <- layer_lambda(
      f = function(x)
        k_batch_dot(x[[1]], x[[2]], axes = 2),
      name = "dot")
    self$dot_bias <- layer_lambda(
      f = function(x)
        k_sigmoid(x[[1]] + x[[2]] + x[[3]]),
      name = "dot_bias")
    self$min_rating <- min_rating
    self$max_rating <- max_rating
    self$pred <- layer_lambda(
      f = function(x)
        x * (self$max_rating - self$min_rating) + self$min_rating,
      name = "pred")
    function(x, mask = NULL, training = FALSE) {
      users <- x[, 1]
      items <- x[, 2]
      user_embedding <- self$user_embedding(users) %>% self$user_dropout()
      item_embedding <- self$item_embedding(items) %>% self$item_dropout()
      dot <- self$dot(list(user_embedding, item_embedding))
      dot_bias <- self$dot_bias(list(dot, self$user_bias(users), self$item_bias(items)))
      self$pred(dot_bias)
    }
  })
}

# define model
model <- dot_with_bias(
  embedding_dim,
  n_users,
  n_items,
  min_rating,
  max_rating)

# compile model
model %>% compile(
  loss = "mse",
  optimizer = "adam"
)

# train model
history <- model %>% fit(
  x_train,
  y_train,
  epochs = 10,
  batch_size = 50,
  validation_data = list(x_test, y_test),
  verbose = 1
)

# summary model
summary(model)

# evaluate results
plot(history)
