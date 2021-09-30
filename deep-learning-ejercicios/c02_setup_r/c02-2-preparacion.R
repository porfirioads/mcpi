# ------------------------------------
# INSTALACIÓN DE LOS PAQUETES
# ------------------------------------

# Importa las librerías necesarias
library(tidyverse)
library(caret)

# Realiza la carga de los datos
train <- read.csv("adult_processed_train.csv")
train <- train %>% dplyr::mutate(dataset = "train")
test <- read.csv("adult_processed_test.csv")
test <- test %>% dplyr::mutate(dataset = "test")