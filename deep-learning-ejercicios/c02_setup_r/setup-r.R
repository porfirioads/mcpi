# ------------------------------------------------------
# INSTALACIÓN DE LOS PAQUETES
# ------------------------------------------------------

# Instalar las siguientes versiones de R y Rtools:
# R: https://cran.r-project.org/bin/windows/base/old/4.0.0/
# Rtools: https://cran.r-project.org/bin/windows/Rtools/rtools40v2-x86_64.exe

# Ejecutar las siguientes instrucciones en la terminal de Windows:
# cd C:\Users\porfi\AppData\Local\r-miniconda
# condabin\activate.bat r-reticulate
# pip install --upgrade pip

# Importa utilidades comunes.
source('utils/packages.R')

# ReinforcementLearning
install_missing_packages("ReinforcementLearning")

# RBM
install_missing_packages("usethis")
# install_missing_packages("rcmdcheck")
install_missing_packages("devtools")
library(usethis)
library(devtools)
devtools::install_github("TimoMatzen/RBM", force = TRUE)
library(RBM)

# Keras
install_missing_packages("Rcpp")
install_missing_packages("reticulate")
library(reticulate)
install_miniconda(force = TRUE)
reticulate::use_condaenv("r-reticulate", required = TRUE)
reticulate::py_config()
reticulate::conda_install(packages = 'keras')
reticulate::conda_install(packages = 'tensorflow')
reticulate::py_module_available('keras')
reticulate::py_module_available('tensorflow')
reticulate::conda_list()
# devtools::install_github("rstudio/keras", force = TRUE)
remove.packages(c("keras", "tensorflow"))
install_missing_packages("keras")
install_missing_packages("tensorflow")
library(keras)
library(tensorflow)

# H2O
if ("package:h2o" %in% search()) { detach("package:h2o", unload = TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }
pkgs <- c("RCurl", "jsonlite")
for (pkg in pkgs) {
  if (!(pkg %in% rownames(installed.packages()))) {
    install.packages(pkg)
  }
}
install.packages("h2o", repos=(c("http://s3.amazonaws.com/h2o-release/h2o/master/1497/R", getOption("repos"))))
library(h2o)
localH2O = h2o.init()
demo(h2o.glm)

# MXNet
cran <- getOption("repos")
cran["dmlc"] <- "https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/R/CRAN/"
options(repos = cran)
install.packages("mxnet")

# ------------------------------------------------------
# PREPARACIÓN DE UN DATASET DE EJEMPLO
# ------------------------------------------------------

# Importa las librerías necesarias.
install_missing_packages("tidyverse")
install_missing_packages("caret")
library(tidyverse)
library(caret)

# Importa dataset de entrenamiento y de prueba, y agrega una columna con
# etiquetas a cada uno.
train <- read.csv("c02_setup_r/adult_processed_train.csv")
train <- train %>% dplyr::mutate(dataset = "train")
test <- read.csv("c02_setup_r/adult_processed_test.csv")
test <- test %>% dplyr::mutate(dataset = "test")

# Fusiona los datasets.
all <- rbind(train, test)

# Mantienene únicamente las filas sin datos faltantes.
all <- all[complete.cases(all),]

# Elimina los espacios en blanco entre factores.
all <- all %>% mutate_if(~is.factor(.), ~trimws(.))

# FIXME: Establece variable objetivo porque la columna 'target' no existe.
target <- 'income'
# target <- 'hours.per.week'

# Extrae los datos de entrenamiento
train <- all %>% filter(dataset == "train")

# Crea el vector target.
train_target <- as.numeric(factor(train[target]))
# train_target <- factor(train[target])

# Visualiza las variables a usar.
train
train_target

# Elimina la columna 'target' y la columna 'dataset' (label).
train <- train %>% select(-target, -dataset)

# Mueve todas las cadenas a un subset.
train_chars <- train %>% select_if(is.character)

# Mueve todos los enteros a un subset.
train_ints <- train %>% select_if(is.integer)

# Codifica las cadenas con one-hot.
ohe <- caret::dummyVars(" ~ .", data = train_chars)
train_ohe <- data.frame(predict(ohe, newdata = train_chars))

# Une los enteros y las variables codificadas one-hot.
train <- cbind(train_ints, train_ohe)

# Hace los mismos cambios en los datos de prueba.
test <- all %>% filter(dataset == "test")
test_target <- as.numeric(factor(test$target))
test <- test %>% select(-target, -dataset)
test_chars <- test %>% select_if(is.character)
test_ints <- test %>% select_if(is.integer)
ohe <- caret::dummyVars(" ~ .", data = test_chars)
test_ohe <- data.frame(predict(ohe, newdata = test_chars))
test <- cbind(test_ints, test_ohe)

# Cambia las variables target de 1 a 2 y 0 a 1.
train_target <- train_target - 1
test_target <- test_target - 1

# Elimina un pais que existe en el dataset de entrenamiento pero no en el de
# prueba.
train <- train %>% select(-native.countryHoland.Netherlands)

# ------------------------------------------------------
# EXPLORANDO KERAS
# ------------------------------------------------------

# Carga las librerías.
library(tensorflow)
library(keras)

# convert the prepared sample data (from prepare_sample_data.R) to matrices
train <- as.matrix(train)
test <- as.matrix(test)

# start a sequential model
model <- keras_model_sequential()

# set the number of units in the hidden layer and the activation function
model %>% layer_dense(units = 35, activation = 'relu')

# set the evaluation metrics and correction mechanism
model %>% keras::compile(
  loss = 'binary_crossentropy',
  optimizer = 'adam',
  metrics = 'accuracy'
)

# ValueError: Input arrays should have the same number of samples as target
# arrays. Found 32561 input samples and 0 target samples.
# fit a model
history <- model %>% fit(
  train,
  train_target,
  epoch = 10,
  batch = 16,
  validation_split = 0.15
)

# evaluate the model
model %>% keras::evaluate(test, test_target)

# ------------------------------------------------------
# EXPLORANDO MXNET
# ------------------------------------------------------

## load the library
library(mxnet)

# set seed for reprodibility
mx.set.seed(0)

# fit a model
model <- mx.mlp(
  data.matrix(train),
  train_target,
  hidden_node = 10,
  out_node = 2,
  out_activation = "softmax",
  num.round = 10,
  array.batch.size = 20,
  learning.rate = 0.05,
  momentum = 0.8,
  eval.metric = mx.metric.accuracy
)

# make predictions
preds <- predict(model, data.matrix(test))

# compare predictions with ground truth
pred.label <- max.col(t(preds)) - 1
table(pred.label, test_target)

# ------------------------------------------------------
# EXPLORANDO H2O
# ------------------------------------------------------

# load H2O package
library(h2o)

# start H2O
h2o::h2o.init()

# load data
train <- read.csv("c02_setup_r/adult_processed_train.csv")
test <- read.csv("c02_setup_r/adult_processed_test.csv")

# load data on H2o
train <- as.h2o(train)
test <- as.h2o(test)

# pre-process by imputing missing values
h2o.impute(train, column = 0, method = c("mean", "median", "mode"))
h2o.impute(test, column = 0, method = c("mean", "median", "mode"))

# set dependent and independent variables
target <- "target"
predictors <- colnames(train)[1:14]

# train the model
model <- h2o.deeplearning(
  model_id = "h2o_dl_example",
  training_frame = train,
  seed = 321,
  y = target,
  x = predictors,
  epochs = 10,
  nfolds = 5
)

# evaluate model performance
h2o.performance(model, xval = TRUE)

# shutdown h2o
h2o::h2o.shutdown()

# ------------------------------------------------------
# EXPLORANDO REINFORCEMENTLEARNING
# ------------------------------------------------------

# load library
library(ReinforcementLearning)

# create a sample environment
data <- sampleGridSequence(N = 1000)

# set how the agent will learn
control <- list(alpha = 0.1, gamma = 0.1, epsilon = 0.1)

# fit the model
model <- ReinforcementLearning(
  data,
  s = "State",
  a = "Action",
  r = "Reward",
  s_new = "NextState",
  control = control
)

# print the results
print(model)

# ------------------------------------------------------
# EXPLORANDO  RBM
# ------------------------------------------------------

# load library
library(RBM)

# load FMNIST data
data(Fashion)

# create the train data set and train target vector
train <- Fashion$trainX
train_label <- Fashion$trainY

# fit the model
rbmModel <- RBM(
  x = t(train),
  y = train_label,
  n.iter = 500,
  n.hidden = 200,
  size.minibatch = 10
)

# create the test data and test target vector
test <- Fashion$testX
test_label <- Fashion$testY

# predict using the model
PredictRBM(test = t(test), labels = test_label, model = rbmModel)