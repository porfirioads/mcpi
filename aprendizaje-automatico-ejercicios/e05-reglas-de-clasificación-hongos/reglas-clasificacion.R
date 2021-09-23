# Título:   Detección de hongos venenosos.
# Autor:    Porfirio Ángel Díaz Sánchez
# Creación: 04/06/2020

source('utils/packages.R')
install_missing_packages(c('RWeka'))
library('RWeka')

# STEP 1. COLLECTING DATA
# ------

mushrooms <- read.csv('datasets/mushrooms.csv', stringsAsFactors = TRUE)

# STEP 2. EXPLORING AND PREPARING THE DATA
# ------

str(mushrooms)
str(mushrooms$veil.type)

# Elimina columna veil.type ya que al ser un factor de un solo nivel, no
# representa información relevante.
mushrooms$veil.type <- NULL

# Visualiza cantidad de tipos de hongos.
table(mushrooms$type)

# STEP 3. TRAINING A MODEL ON THE DATA
# ------

# Aplica algoritmo OneR para determinar el type, consideranto todas las 
# posibles características.
mushroom_1R <- OneR(type ~ ., data = mushrooms)
mushroom_1R

# STEP 4. EVALUATING MODEL PERFORMANCE
# ------

# Muestra resumen de la clasificación para ver eficiencia.
summary(mushroom_1R)

# STEP 5. IMPROVING MODEL PERFORMANCE
# ------

# Aplica algoritmo RIPPER.
mushroom_JRip <- JRip(type ~ ., data = mushrooms)
mushroom_JRip
summary(mushroom_JRip)
