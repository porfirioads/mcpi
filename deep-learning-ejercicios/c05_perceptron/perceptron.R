# Preparing and preprocessing data
# -----------------------------------------------------------

library(mxnet)
library(tidyverse)
library(caret)

train <- read.csv("adult_processed_train.csv")
train <- train %>% mutate(dataset = "train")
test <- read.csv("adult_processed_test.csv")
test <- test %>% mutate(dataset = "test")

all <- rbind(train, test)
all <- all[complete.cases(all),]

unique(all$sex)
all <- all %>% mutate_if(~is.factor(.), ~trimws(.))

train <- all %>% filter(dataset == "train")
train_target <- as.numeric(factor(train$target))
train <- train %>% select(-target, -dataset)

train_chars <- train %>%
  select_if(is.character)

train_ints <- train %>%
  select_if(is.integer)

ohe <- caret::dummyVars(" ~ .", data = train_chars)
train_ohe <- data.frame(predict(ohe, newdata = train_chars))

train <- cbind(train_ints, train_ohe)

train <- train %>% mutate_all(funs(scales::rescale(.) %>% as.vector))

test <- all %>% filter(dataset == "test")
test_target <- as.numeric(factor(test$target))
test <- test %>% select(-target, -dataset)

test_chars <- test %>%
  select_if(is.character)

test_ints <- test %>%
  select_if(is.integer)

ohe <- caret::dummyVars(" ~ .", data = test_chars)
test_ohe <- data.frame(predict(ohe, newdata = test_chars))

test <- cbind(test_ints, test_ohe)
test <- test %>% mutate_all(funs(scales::rescale(.) %>% as.vector))

setdiff(names(train), names(test))
train <- train %>% select(-native.countryHoland.Netherlands)

train_target <- train_target - 1
test_target <- test_target - 1

# Deciding on the hidden layers and neurons
# -----------------------------------------------------------

length(train) * .66

possible_node_values <- c(50, 60, 70, 80, 90)

mx.set.seed(0)

model <- mx.mlp(data.matrix(train),
                train_target,
                hidden_node = 70,
                out_node = 2,
                out_activation = "softmax",
                num.round = 10,
                array.batch.size = 32,
                learning.rate = 0.1,
                momentum = 0.8,
                eval.metric = mx.metric.accuracy)

preds = predict(model, data.matrix(test))
pred.label = max.col(t(preds)) - 1

acc = sum(pred.label == test_target) / length(test_target)

vals <- tibble(
  nodes = 70,
  accuracy = acc
)

vals

mlp_loop <- function(x) {
  model <- mx.mlp(data.matrix(train),
                  train_target,
                  hidden_node = x,
                  out_node = 2,
                  out_activation = "softmax",
                  num.round = 10,
                  array.batch.size = 32,
                  learning.rate = 0.1,
                  momentum = 0.8,
                  eval.metric = mx.metric.accuracy)
  preds = predict(model, data.matrix(test))
  pred.label = max.col(t(preds)) - 1
  acc = sum(pred.label == test_target) / length(test_target)
  vals <- tibble(
    nodes = x,
    accuracy = acc
  )
}

results <- mlp_loop(70)
results
all.equal(results$accuracy, acc)

results <- map_df(possible_node_values, mlp_loop)
results

data <- mx.symbol.Variable("data")
fc1 <- mx.symbol.FullyConnected(data, num_hidden = 90)
fc2 <- mx.symbol.FullyConnected(fc1, num_hidden = 50)
smx <- mx.symbol.SoftmaxOutput(fc2)

model <- mx.model.FeedForward.create(smx,
                                     data.matrix(train),
                                     train_target, num.round = 10,
                                     array.batch.size = 32,
                                     learning.rate = 0.1,
                                     momentum = 0.8,
                                     eval.metric = mx.metric.accuracy)

preds = predict(model, data.matrix(test))
pred.label = max.col(t(preds)) - 1
acc = sum(pred.label == test_target) / length(test_target)
acc

# Training and evaluating the model
# -----------------------------------------------------------

model <- mx.mlp(data.matrix(train),
                train_target,
                hidden_node = 90,
                out_node = 2,
                out_activation = "softmax",
                num.round = 200,
                array.batch.size = 32,
                learning.rate = 0.005,
                momentum = 0.8,
                eval.metric = mx.metric.accuracy)
preds = predict(model, data.matrix(test))
pred.label = max.col(t(preds)) - 1
acc = sum(pred.label == test_target) / length(test_target)
acc