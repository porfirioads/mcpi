# Importa utilidades comunes.
source('utils/packages.R')

# ------------------------------------------------------
# FUNCIÓN SIGMOIDE
# ------------------------------------------------------

sigmoid <- function(x) {
  1 / (1 + exp(-x))
}

vals <- tibble(x = seq(-10, 10, 1), sigmoid_x = sigmoid(seq(-10, 10, 1)))

p <- ggplot(vals, aes(x, sigmoid_x))

p <- p + geom_point()
p + stat_function(fun = sigmoid, n = 1000)

# ------------------------------------------------------
# FUNCIÓN TANGENTE HIPERBÓLICA
# ------------------------------------------------------

vals <- tibble(x = seq(-10, 10, 1), tanh_x = tanh(seq(-10, 10, 1)))

p <- ggplot(vals, aes(x, tanh_x))

p <- p + geom_point()
p + stat_function(fun = tanh, n = 1000)

# ------------------------------------------------------
# RECTIFIED LINEAR UNITS (RELU) ACTIVATION FUNCTION
# ------------------------------------------------------

relu <- function(x) { dplyr::if_else(x > 0, x, 0) }

vals <- tibble(x = seq(-10, 10, 1), relu_x = relu(seq(-10, 10, 1)))

p <- ggplot(vals, aes(x, relu_x))
p <- p + geom_point()
p + geom_line()

# ------------------------------------------------------
# LEAKY RELU ACTIVATION FUNCTION
# ------------------------------------------------------

leaky_relu <- function(x, a) { dplyr::if_else(x > 0, x, x * a) }

vals <- tibble(x = seq(-10, 10, 1), leaky_relu_x = leaky_relu(seq(-10, 10, 1), 0.01))

p <- ggplot(vals, aes(x, leaky_relu_x))
p <- p + geom_point()
p + geom_line()

# ------------------------------------------------------
# SWISH ACTIVATION FUNCTION
# ------------------------------------------------------

swish <- function(x) { x * sigmoid(x) }

vals <- tibble(x = seq(-10, 10, 1), swish_x = swish(seq(-10, 10, 1)))

p <- ggplot(vals, aes(x, swish_x))
p <- p + geom_point()
p + geom_line()

# ------------------------------------------------------
# PREDICIENDO PROBABILIDAD CON SOFTMAX
# ------------------------------------------------------

softmax <- function(x) { exp(x) / sum(exp(x)) }

results <- softmax(c(2, 3, 6, 9))
results

sum(results)

# ------------------------------------------------------
# RED NEURONAL CON R BASE
# ------------------------------------------------------

# Función de la red neuronal.
artificial_neuron <- function(input) {
  as.vector(ifelse(input %*% weights > 0, 1, 0))
}

# Dibuja líneas con los pesos aprendidos.
linear_fits <- function(w, to_add = TRUE, line_type = 1) {
  curve(-w[1] / w[2] * x - w[3] / w[2], xlim = c(-1, 2), ylim = c(-1, 2), col = "black", lty = line_type, lwd = 2, xlab = "Input Value A", ylab = "Input Value B", add = to_add)
}

# Establece valores iniciales.
input <- matrix(c(1, 0,
                  0, 0,
                  1, 1,
                  0, 1), ncol = 2, byrow = TRUE)
input <- cbind(input, 1)
output <- c(0, 1, 0, 1)
weights <- c(0.12, 0.18, 0.24)
learning_rate <- 0.2

# Agrega la primera línea.
linear_fits(weights, to_add = FALSE)
points(input[, 1:2], pch = (output + 21))

# Actualiza los pesos basado en el primer conjuntos de pesos a traves de la neurona artificial.
weights <- weights + learning_rate *
  (output[1] - artificial_neuron(input[1,])) *
  input[1,]
linear_fits(weights)

# Dibuja una línea con los pesos actualizados y repite este paso con pesos continuamente actualizados otras tres veces,
weights <- weights + learning_rate *
  (output[2] - artificial_neuron(input[2,])) *
  input[2,]
linear_fits(weights)


weights <- weights + learning_rate *
  (output[3] - artificial_neuron(input[3,])) *
  input[3,]
linear_fits(weights)


weights <- weights + learning_rate *
  (output[4] - artificial_neuron(input[4,])) *
  input[4,]
# Esta línea bisecciona las dos clases y es la solución al problema.
linear_fits(weights, line_type = 2)

# ------------------------------------------------------
# CREACIÓN DE MODELO CON DATOS DE CÁNCER DE WISCONSIN
# ------------------------------------------------------

install_missing_packages('Metrics')
install_missing_packages('neuralnet')

library(tidyverse)
library(caret)
library(Metrics)
library(neuralnet)

# Lee el dataset
wbdc <- readr::read_csv("c03_ann/wdbc.data", col_names = FALSE)

# Convierte la variable objetivo a 1 y 0 y la re etiqueta.
wbdc <- wbdc %>%
  dplyr::mutate(target = dplyr::if_else(X2 == "M", 1, 0)) %>%
  dplyr::select(-X2)

# Escala y estandariza todas las variables independientes.
wbdc <- wbdc %>% dplyr::mutate_at(vars(-X1, -target), funs((. - min(.)) / (max(.) - min(.))))

# Crea datasets de entrenamiento y prueba dividiéndolos en una razón de 80/20.
train <- wbdc %>% dplyr::sample_frac(.8)
test <- dplyr::anti_join(wbdc, train, by = 'X1')

# Elimina la columna ID.
test <- test %>% dplyr::select(-X1)
train <- train %>% dplyr::select(-X1)

# Estrae las variables objetivo en un vector separado y las remueve de los datos de prueba.
actual <- test$target
test <- test %>% dplyr::select(-target)

# Prepara el argumento para la función de neuralnet.
n <- names(train)
formula <- as.formula(paste("target ~", paste(n[!n == "target"], collapse = " + ", sep = "")))

# Entrena la red neuronal con los datos.
net <- neuralnet::neuralnet(formula,
                            data = train,
                            hidden = c(15, 15),
                            linear.output = FALSE,
                            act.fct = "logistic"
)

# Realiza las predicciones usando el modelo.
prediction_list <- neuralnet::compute(net, test)

# Convierte las predicciones en valores binarios para su evaluación.
predictions <- as.vector(prediction_list$net.result)
binary_predictions <- dplyr::if_else(predictions > 0.5, 1, 0)

# Calcula el porcentaje de predicciones correctas.
sum(binary_predictions == actual) / length(actual)

# Evalúa los resultados usando una matriz de confusión.
results_table <- table(binary_predictions, actual)
caret::confusionMatrix(results_table)

# Evalúa los resultados usanco el score AUC.
Metrics::auc(actual, predictions)

# Agrega un paso de retropropagación.
bp_net <- neuralnet::neuralnet(formula,
                               data = train,
                               hidden = c(15, 15),
                               linear.output = FALSE,
                               act.fct = "logistic",
                               algorithm = "backprop",
                               learningrate = 0.00001,
                               threshold = 0.3,
                               stepmax = 1e6
)

# Revisa nuevamente la accuracy.
prediction_list <- neuralnet::compute(bp_net, test)
predictions <- as.vector(prediction_list$net.result)
binary_predictions <- dplyr::if_else(predictions > 0.5, 1, 0)
results_table <- table(binary_predictions, actual)
Metrics::auc(actual, predictions)
caret::confusionMatrix(results_table)
