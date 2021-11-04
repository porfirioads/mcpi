# Importa utilidades comunes.
source('utils/packages.R')

# Instala paquetes.
install_missing_packages(c(
  'quantmod',
  'tseries',
  'ggplot2',
  'timeSeries',
  'forecast',
  'xts',
  'keras',
  'tensorflow',
  'reticulate'
))

# Importa librerías.
library(quantmod)
library(tseries)
library(ggplot2)
library(timeSeries)
library(forecast)
library(xts)
library(keras)
library(tensorflow)
library(reticulate)

# -----------------------------------------------------------
# Keras
install_missing_packages("reticulate")
install_miniconda(force = TRUE)
reticulate::use_condaenv("r-reticulate", required = TRUE)
reticulate::py_config()
reticulate::conda_install(packages = 'keras')
reticulate::conda_install(packages = 'tensorflow')
reticulate::py_module_available('keras')
reticulate::py_module_available('tensorflow')
reticulate::conda_list()
# remove.packages(c("keras", "tensorflow"))
install_missing_packages(c('keras', 'tensorflow'))
install_keras(
  method = c("auto", "virtualenv", "conda"),
  conda = "auto",
  version = "default",
  tensorflow = "default",
  extra_packages = c("tensorflow-hub"),
)
# -----------------------------------------------------------

# Understanding common methods for stock market prediction
# -----------------------------------------------------------

# Se obtiene data frame XTS, que es similar a un data frame standard, pero con
# fechas como nombres de columnas.
FB <- getSymbols('FB', from = '2014-01-01', to = '2018-12-31', source = 'google', auto.assign = FALSE)

FB[1:5,]

closing_prices <- FB$FB.Close

plot.xts(closing_prices, main = "Facebook Closing Stock Prices")

arima_mod <- auto.arima(closing_prices)

forecasted_prices <- forecast(arima_mod, h = 365)

autoplot(forecasted_prices)

fb_future <- getSymbols('FB', from = '2019-01-01', to = '2019-12-31', source = 'google', auto.assign = FALSE)

future_values <- ts(data = fb_future$FB.Close, start = 1258, end = 1509)

autoplot(forecasted_prices) + autolayer(future_values, series = "Actual Closing Prices")

# Preparing and preprocessing data
# -----------------------------------------------------------

future_prices <- fb_future$FB.Close

closing_deltas <- diff(log(rbind(closing_prices,future_prices)),lag=1)
closing_deltas <- closing_deltas[!is.na(closing_deltas)]

plot(closing_deltas,type='l', main='Facebook Daily Log Returns')

adf.test(closing_deltas)

# Configuring a data generator
# -----------------------------------------------------------

train_gen <- timeseries_generator(
  closing_deltas,
  closing_deltas,
  length = 3,
  sampling_rate = 1,
  stride = 1,
  start_index = 1,
  end_index = 1258,
  shuffle = FALSE,
  reverse = FALSE,
  batch_size = 1
)

test_gen <- timeseries_generator(
  closing_deltas,
  closing_deltas,
  length = 3,
  sampling_rate = 1,
  stride = 1,
  start_index = 1259,
  end_index = 1507,
  shuffle = FALSE,
  reverse = FALSE,
  batch_size = 1
)

# Training and evaluating the model
# -----------------------------------------------------------

model <- keras_model_sequential()

model %>%
  layer_lstm(units = 4,
             input_shape = c(3, 1)) %>%
  layer_dense(units = 1)

# model %>%
#   compile(loss = 'mse', optimizer = 'adam')

model %>%
  compile(
    optimizer = optimizer_adam(learning_rate = 0.001), # learning_rate antes era lr
    loss = 'mse',
    metrics = 'accuracy')

model

history <- model %>% fit_generator(
  train_gen,
  epochs = 100,
  steps_per_epoch=1,
  verbose=2
)

testpredict <- predict_generator(model, test_gen, steps = 200)
trainpredict <- predict_generator(model, train_gen, steps = 1200)

trainpredict <- data.frame(pred = trainpredict)
rownames(trainpredict) <- index(closing_deltas)[4:1203]
trainpredict <- as.xts(trainpredict)

testpredict <- data.frame(pred = testpredict)
rownames(testpredict) <- index(closing_deltas)[1262:1461]
testpredict <- as.xts(testpredict)

closing_deltas$trainpred <- rep(NA,1507)
closing_deltas$trainpred[4:1203] <- trainpredict$pred

closing_deltas$testpred <- rep(NA,1507)
closing_deltas$testpred[1262:1461] <- testpredict$pred

plot(as.zoo(closing_deltas), las=1, plot.type = "single", col = c("light gray","black","black"), lty = c(3,1,1))

evaluate_generator(model, test_gen, steps = 200)
evaluate_generator(model, train_gen, steps = 1200)

# Tuning hyperparameters to improve performance
# -----------------------------------------------------------

# TODO: No pude tunear los parámetros cambiando el parámetro length del
#       generador, me arrojó una excepción al compilar el modelo.

train_gen <- timeseries_generator(
  closing_deltas,
  closing_deltas,
  length = 10,
  sampling_rate = 1,
  stride = 10,
  start_index = 1,
  end_index = 1258,
  shuffle = FALSE,
  reverse = FALSE,
  batch_size = 1
)

test_gen <- timeseries_generator(
  closing_deltas,
  closing_deltas,
  length = 3,
  sampling_rate = 1,
  stride = 1,
  start_index = 1259,
  end_index = 1507,
  shuffle = FALSE,
  reverse = FALSE,
  batch_size = 1
)

model <- keras_model_sequential()

model %>%
  layer_lstm(units = 256, input_shape = c(10, 1), return_sequences = "True") %>%
  layer_dropout(rate = 0.3) %>%
  layer_lstm(units = 256, input_shape = c(10, 1), return_sequences = "False") %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 1, activation = "linear")

model %>%
  compile(
    optimizer = optimizer_adam(learning_rate = 0.001), # learning_rate antes era lr
    loss = 'mse',
    metrics = 'accuracy')

model

history <- model %>% fit_generator(
  train_gen,
  epochs = 100,
  steps_per_epoch = 1,
  verbose = 2
)

evaluate_generator(model, train_gen, steps = 1200)
evaluate_generator(model, test_gen, steps = 200)