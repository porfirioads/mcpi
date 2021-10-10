# Importa utilidades comunes.
source('utils/packages.R')

# ------------------------------------------------------
# IMAGE RECOGNITION WITH SHALLOW NETS
# ------------------------------------------------------

# Carga los paquetes necesarios.
install_missing_packages('randomForest')
library(tidyverse)
library(caret)
library(randomForest)

# Carga los datos.
fm <- readr::read_csv('c04_cnn/fashion-mnist_train.csv')
fm_test <- readr::read_csv('c04_cnn/fashion-mnist_test.csv')

# Planta semilla para que se repitan los números aleatorios.
set.seed(0)

# Crea el modelo
rf_model <- randomForest::randomForest(
  as.factor(label) ~ .,
  data = fm,
  ntree = 10,
  mtry = 5
)

# Realiza las predicciones en los datos de prueba.
pred <- predict(rf_model, fm_test, type = "response")

# Evalúa los resultados.
caret::confusionMatrix(as.factor(fm_test$label), pred)

# ------------------------------------------------------
# SHALLOW NEURAL NETWORK WITH JUST ONE LAYER
# ------------------------------------------------------

# Carga las librerías.
library(tidyverse)
library(caret)
library(neuralnet)
library(Metrics)

# Crea subconjunto de los datos para configurar el problema de clasificación binaria.
fm <- fm %>% dplyr::filter(label < 2)
fm_test <- fm_test %>% dplyr::filter(label < 2)

# Obtiene los argumentos de datos.
n <- names(fm)
formula <- as.formula(paste("label ~", paste(n[!n == "label"], collapse = " + ", sep = "")))

# Entrena el modelo.
net <- neuralnet::neuralnet(formula,
                            data = fm,
                            hidden = 250,
                            linear.output = FALSE,
                            act.fct = "logistic"
)

# Realiza las predicciones.
prediction_list <- neuralnet::compute(net, fm_test)
predictions <- as.vector(prediction_list$net.result)

# Revisa la AUC score
Metrics::auc(test_label, predictions)

# ------------------------------------------------------
# RECONOCIMIENTO DE IMÁGENES CON REDES NEURONALES CONVOLUCIONALES
# ------------------------------------------------------

# Carga las librerías.
library(keras)
library(caret)

# Carga los datasets.
fashion_mnist <- dataset_fashion_mnist()

# Divide el dataset en entrenamiento y prueba.
train <- fashion_mnist$train$x
train_target <- fashion_mnist$train$y
test <- fashion_mnist$test$x
test_target <- fashion_mnist$test$y

# Normaliza los valores.
train <- normalize(train)
test <- normalize(test)

# Inicializa el modelo como secuencial.
model <- keras_model_sequential()

# Aplana el arreglo de matrices para obtener todos los valores de los pixeles en una sola fila por imagen.
model %>% layer_flatten(input_shape = c(28, 28))

# Define la capa oculta (Aquí se establecen 256 unidades donde el valor procesado de cada uno
# es evaluado por la función RELU).
model %>% layer_dense(units = 256, activation = 'relu')

# Establece la capa de salida con 10 unidades porque la variable objetivo tiene diez clases.
model %>% layer_dense(units = 10, activation = 'softmax')

# Convierte los vectores objetivo a matrices para ajustarse al formato requerido.
test_target <- to_categorical(test_target)
train_target <- to_categorical(train_target)

# Define el paso de compilación, que incluye:
# Cómo se calcula la tasa de error (pérdida)
# Cómo el modelo hará las correcciones basado en los resultados de la función de pérdida (optimizador)
# Cómo se evaluarán los resultados (métricas)
model %>% compile(
  optimizer = 'adam',
  loss = 'categorical_crossentropy',
  metrics = 'categorical_accuracy'
)

# Entrena el modelo.
model %>% fit(train, train_target, epochs = 10)

# Obtiene las métricas de evaluación.
score <- model %>% evaluate(test, test_target)
score$categorical_accuracy

# Realiza las predicciones.
preds <- model %>% predict(test)
predicted_classes <- model %>% predict_classes(test)

# Evalúa el rendimiento.
test_target_vector <- fashion_mnist$test$y
caret::confusionMatrix(as.factor(predicted_classes),as.factor(test_target_vector))

