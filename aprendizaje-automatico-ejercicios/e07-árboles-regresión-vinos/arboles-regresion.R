# Título:   Estimación de la calidad de vinos por medio de árboles de regresión
#           y modelos de árboles.
# Autor:    Porfirio Ángel Díaz Sánchez
# Creación: 05/06/2020

source('utils/packages.R')
install_missing_packages(c('rpart', 'rpart.plot', 'RWeka'))
library(rpart)
library(rpart.plot)
library(RWeka)

# STEP 1. COLLECTING DATA
# ------

wine <- read.csv('datasets/winequality-white.csv')

# STEP 2. EXPLORING AND PREPARING THE DATA
# ------

# La ventaja de los modelos de árbol es que pueden manejar muchos tipos de datos
# sin la necesidad de procesamiento. Esto significa que no se necesitan
# normalizar o estandarizar las características.

# Visualiza datos generales del dataset.
str(wine)
summary(wine)
hist(wine$quality)

# Divide entre datos de entrenamiento y datos de prueba.
wine_train <- wine[1:3750,]
wine_test <- wine[3751:4898,]

# STEP 3. TRAINING A MODEL ON THE DATA
# ------

# Crea modelo de árbol de regresión, especificando a 'quality' como salida, y
# el resto de variables como predictores.
m.rpart <- rpart(quality ~ ., data = wine_train)
m.rpart
summary(m.rpart)

# Grafica árbol de regresión.
rpart.plot(m.rpart, digits = 3)
rpart.plot(m.rpart, digits = 4, fallen.leaves = TRUE, type = 3, extra = 101)

# STEP 4. EVALUATING MODEL PERFORMANCE
# ------

# Usa modelo para predecir calidad de vino en los datos de prueba.
p.rpart <- predict(m.rpart, wine_test)
summary(p.rpart)
summary(wine_test$quality)

# Mide performance con la correlación. 
cor(p.rpart, wine_test$quality)

# Mide performance con el error absoluto promedio.
MAE <- function(actual, predicted) {
  mean(abs(actual - predicted))
}

MAE(p.rpart, wine_test$quality)

# Con el MAE, se obtiene que la diferencia entre la predicción y el valor real 
# es 0.5732104. En una escala de 0 a 10, indica que el modelo lo está haciendo 
# muy bien.

# Promedio de calidad en datos de entrenamiento.
mean(wine_train$quality)

# Calcula error si predijéramos 5.886933 para cada muestra de vino.
MAE(5.886933, wine_test$quality)

# STEP 5. IMPROVING MODEL PERFORMANCE
# ------

# Para mejorar el modelo, se construirá un model tree, que mejora a los árboles
# de regresión reemplazando los leaf nodes con modelos de regresión.
summary(wine_train$quality)
m.m5p <- M5P(quality ~ ., data = wine_train)
m.m5p
summary(m.m5p)
p.m5p <- predict(m.m5p, wine_test)
summary(p.m5p)

# Evalúa performance deel modelo

cor(p.m5p, wine_test$quality)
MAE(wine_test$quality, p.m5p)
