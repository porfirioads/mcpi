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

# Se muestran las primeras 5 filas.
FB[1:5,]

# Se seleccionan y grafican los precios de cierre.
closing_prices <- FB$FB.Close
plot.xts(closing_prices, main = "Facebook Closing Stock Prices")

# Se construye el modelo ARIMA, se realiza una predicción, y se grafican los
# datos predichos.
arima_mod <- auto.arima(closing_prices)
forecasted_prices <- forecast(arima_mod, h = 365)
autoplot(forecasted_prices)
# El modelo no encontró un patrón, y en lugar de eso ofrece límites superiores
# en inferiores para los precios predichos, lo cual no es muy útil.

# Se agregan y se grafican los valores reales del precio de las acciones para
# ver si los precios cayeron dentro de los límites predichos por el modelo
# ARIMA.
fb_future <- getSymbols('FB', from = '2019-01-01', to = '2019-12-31', source = 'google', auto.assign = FALSE)
future_values <- ts(data = fb_future$FB.Close, start = 1258, end = 1509)
autoplot(forecasted_prices) + autolayer(future_values, series = "Actual Closing Prices")
# Las fechas reales están fuera de los límites predichos por el modelo ARIMA,
# el conjunto de datos elegido es difícil de modelar, ya que la tendencia de
# los precios es a la baja y luego comienzan a subir de nuveo.

# -----------------------------------------------------------
# ENFOQUE DE DEEP LEARNING
# -----------------------------------------------------------

# Preparing and preprocessing data
# -----------------------------------------------------------

# Es necesario convertir los datos a valores delta en lugar de valores
# absolutos, con la finalidad de hacer que los datos sean estacionarios.
# También se transforman los valores de precio para controlar valores atípicos.
# Se convierten los datos de precios de acciones combinados, del precio de
# cierre al cambio diario en el valor del registro del precio de cierre.
future_prices <- fb_future$FB.Close
closing_deltas <- diff(log(rbind(closing_prices,future_prices)),lag=1)
closing_deltas <- closing_deltas[!is.na(closing_deltas)]

# Se grafican los datos.
plot(closing_deltas,type='l', main='Facebook Daily Log Returns')

# Se realiza la prueba Augmented Dickey-Fuller para verificar que los datos son
# estacionarios.
adf.test(closing_deltas)
# El p-value es lo suficientemente pequeño para afirmar que los datos son
# estacionarios.

# Configuring a data generator
# -----------------------------------------------------------

# Genera el conjunto de entrenamiento.
train_gen <- timeseries_generator(
  closing_deltas,
  closing_deltas,
  length = 3, # Pasos que se puede mirar hacia atrás para poblar los precios rezagados.
  sampling_rate = 1, # Valores rezagados por secuencia.
  stride = 1, # Pasos entre valores consecutivos.
  start_index = 1, # Donde comenzamos.
  end_index = 1258, # Donde terminamos.
  shuffle = FALSE, # FALSE porque deseamos orden cronológico.
  reverse = FALSE, # FALSE porque deseamos el orden actual.
  batch_size = 1 # Cantidad de series de tiempo que debería haber en cada batch del modelo.
)

# Genera el conjunto de pruebas.
test_gen <- timeseries_generator(
  closing_deltas,
  closing_deltas,
  length = 3,
  sampling_rate = 1,
  stride = 1,
  start_index = 1259, # Continuamos desde donde nos quedamos en el conjunto de entrenamiento.
  end_index = 1507,
  shuffle = FALSE,
  reverse = FALSE,
  batch_size = 1
)

# Training and evaluating the model
# -----------------------------------------------------------

# Se inicializa el modelo secuencial de Keras.
model <- keras_model_sequential()

# Se agrega la capa LSTM al modelo.
model %>%S
  layer_lstm(units = 4, # Capas ocultas.
             input_shape = c(3, 1)) %>%
  layer_dense(units = 1)

# Se agrega el paso de compilación.
model %>%
  compile(
    loss = 'mse', # Mean Squared Error
    optimizer = 'adam'
  )

# model %>%
#   compile(
#     optimizer = optimizer_adam(learning_rate = 0.001), # learning_rate antes era lr
#     loss = 'mse',
#     metrics = 'accuracy')

# Se muestra el modelo.
model

# Se entrena el modelo.
history <- model %>% fit_generator(
  train_gen,
  epochs = 100,
  steps_per_epoch=1,
  verbose=2 # Para mostrar los resultados de cada round.
)

# Se realizan las predicciones en los datos de entrenamiento y de prueba.
testpredict <- predict_generator(model, test_gen, steps = 200)
trainpredict <- predict_generator(model, train_gen, steps = 1200)

# Se convierten las predicciones de entrenamiento a un objeto XTS.
trainpredict <- data.frame(pred = trainpredict)
rownames(trainpredict) <- index(closing_deltas)[4:1203]
trainpredict <- as.xts(trainpredict)

# Se convierten las predicciones de prueba a un objeto XTS.
testpredict <- data.frame(pred = testpredict)
rownames(testpredict) <- index(closing_deltas)[1262:1461]
testpredict <- as.xts(testpredict)

# Se agregan los datos de los objetos XTS a los closing deltas.
closing_deltas$trainpred <- rep(NA,1507)
closing_deltas$trainpred[4:1203] <- trainpredict$pred
closing_deltas$testpred <- rep(NA,1507)
closing_deltas$testpred[1262:1461] <- testpredict$pred

# Se grafican los datos reales con los predichos.
plot(as.zoo(closing_deltas), las=1, plot.type = "single", col = c("light gray","black","black"), lty = c(3,1,1))

# Se evalúan las tasas de error.
evaluate_generator(model, test_gen, steps = 200)
evaluate_generator(model, train_gen, steps = 1200)

# Tuning hyperparameters to improve performance
# -----------------------------------------------------------

# Se ajusta parámetro "length" en train_gen y test_gen para que el modelo tenga
# una mayor cantidad de precios para realizar las predicciones.

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
  length = 10,
  sampling_rate = 1,
  stride = 1,
  start_index = 1259,
  end_index = 1507,
  shuffle = FALSE,
  reverse = FALSE,
  batch_size = 1
)

model <- keras_model_sequential()

# Se agregan capas lstm adicionales al modelo, así como una capa densa
# adicional. También se cambia el input shape par reflejar el cambio realizado
# en el generador. Se establece return_sequences como True para que la señal
# pueda fluir a traves de capas adicionales.
model %>%
  layer_lstm(units = 256, input_shape = c(10, 1), return_sequences = "True") %>%
  layer_dropout(rate = 0.3) %>%
  layer_lstm(units = 256, input_shape = c(10, 1), return_sequences = "False") %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 1, activation = "linear")

# Se reduce la tasa de aprendizaje en el optimizador para reducir los picos en
# las predicciones.
model %>%
  compile(
    optimizer = optimizer_adam(learning_rate = 0.001), # learning_rate antes era lr
    loss = 'mse',
    metrics = 'accuracy')

# Se muestra el modelo.
model

# Se entrena el modelo.
history <- model %>% fit_generator(
  train_gen,
  epochs = 100,
  steps_per_epoch = 1,
  verbose = 2
)

# Se evalúan las tasas de error.
evaluate_generator(model, train_gen, steps = 1200)
evaluate_generator(model, test_gen, steps = 200)