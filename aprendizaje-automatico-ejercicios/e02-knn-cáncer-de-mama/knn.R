# Título:   Diagnóstico de cáncer de mama.
# Autor:    Porfirio Ángel Díaz Sánchez
# Creación: 21/05/2020

source('utils/packages.R')
install_missing_packages(c('class'))
library(class)
library(gmodels)

# Abre el dataset.
wbcd <- read.csv('datasets/wisc_bc_data.csv', stringsAsFactors = FALSE)

# Elimina la característica 'id', que no se utilizará.
wbcd <- wbcd[-1]

# Muestra resumen de los registros.
str(wbcd)

# Realiza conteo de los valores para esta característica, que es la que
# se pretende predecir.
table(wbcd$diagnosis)

# Se codifica la variable diagnosis como un factor, además de asignarle
# etiquetas más descriptivas a sus valores.
wbcd$diagnosis <- factor(wbcd$diagnosis, levels = c('B', 'M'), 
                         labels = c('Benign', 'Malignant'))

# Obtiene porcentajes de los valores de diagnosis.
round(prop.table(table(wbcd$diagnosis)) * 100, digits = 1)

# Calcula medidas de tendencia central de características de interés.
summary(wbcd[c('radius_mean', 'area_mean', 'smoothness_mean')])

# Función que normaliza un conjunto de datos numéricos para que tenga
# valores de 0 a 1.
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

# Prueba la función de normalización anteriormente creada.
normalize(c(1, 2, 3, 4, 5))
normalize(c(10, 20, 30, 40, 50))

# Aplica la normalización a cada columna por medio de la función lapply,
# y por último lo convierte en dataframe.
wbcd_n <- as.data.frame(lapply(wbcd[2:31], normalize))

# Muestra resumen de los datos para confirmar que fueron normalizados.
summary(wbcd_n)

# Separa el dataset en datos de entrenamiento y datos de prueba.
total_rows = nrow(wbcd_n)
percent_70 = round(0.7 * total_rows)
wbcd_train <- wbcd_n[1:percent_70,]
wbcd_test <- wbcd_n[(percent_70 + 1):total_rows,]

# Cuando se construyeron los datasets de entrenamiento y de prueba, 
# se excluyó el campo diagnisis. Para el entrenamiento con el algoritmo
# kNN, necesitamos almacenar esas etiquetas en vectores, separándolas entre
# entrenamiento y prueba.
wbcd_train_labels <- wbcd[1:percent_70, 1]
wbcd_test_labels <- wbcd[(percent_70 + 1):total_rows, 1]

# Se elige el valor de K, como el primer número impar >= a la cantidad de
# registros del dataset de entrenamiento
k <- round(sqrt(percent_70))
k <- if (k %% 2) k else k + 1

# Repasa los datos con los que se generará el análisis con el algoritmo
# kNN.
k
percent_70
total_rows
ncol(wbcd_train)
ncol(wbcd_test)
nrow(wbcd_train)
nrow(wbcd_test)

# Aplica el algoritmo kNN.
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = k)

# Compara resultados de la predicción en el dataset de prueba.
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# VARIACIÓN 1: Estandarizar datos con z-score.
wbcd_z <- as.data.frame(scale(wbcd[-1]))

# Comprueba valores estandarizados (el promedio siempre debería ser 0).
summary(wbcd_z$area_mean)

# Divide el dataset en entrenamiento y prueba.
wbcd_train <- wbcd_z[1:percent_70,]
wbcd_test <- wbcd_z[(percent_70 + 1):total_rows,]
wbcd_train_labels <- wbcd[1:percent_70, 1]
wbcd_test_labels <- wbcd[(percent_70 + 1):total_rows, 1]

# Aplica el algoritmo kNN.
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = k)

# Compara resultados de la predicción en el dataset de prueba.
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# VARIACIÓN 2: Probando con diferentes valores de K.

# K = 1
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = 1)
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# K = 5
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = 5)
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# K = 11
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = 11)
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# K = 15
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = 15)
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# K = 21
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = 21)
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)

# K = 27
wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, 
                      cl = wbcd_train_labels, k = 27)
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq = FALSE)