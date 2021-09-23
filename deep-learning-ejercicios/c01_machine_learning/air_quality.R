# ------------------------------------
# PREPARACIÓN DE LOS DATOS.
# ------------------------------------

# Carga las librerías necesarias.
install.packages(c('readr', 'lubridate', 'xgboost', 'Metrics', 'DataExplorer', 'caret'))
install.packages('tidyverse', dependencies = TRUE)
library(tidyverse)
library(lubridate)
library(xgboost)
library(Metrics)
library(DataExplorer)
library(caret)

# Lee el dataset, mismo que contiene datos de calidad del aire proporcionados
# por la Red de Calidad del Aire de Londres. Específicamente, se utilizarán
# las lectueas de dióxido de nitrógeno en el área de Tower Hamlets durante 2018.
#
# El dataset requiere algo de limpieza y preparación, y es adecuado para el
# modelado basado en árboles de decisiones.
la_no2 <- readr::read_csv('datasets/LondonAir_TH_MER_NO2.csv')

# Visualiza la estructura del dataset.
utils::str(la_no2)

# Como todos los datos son del mismo lugar, con las lecturas de las mismas
# especies de contaminantes, se puede concluir que la unidad de medida será
# consistente. Por lo tanto, se pueden remover las columnas que no proporcionan
# información valiosa.
#
# Para comprobarlo, se agrupan los registros por unidad, sitio y especies.
la_no2 %>%
  dplyr::group_by(Units, Site, Species) %>%
  dplyr::summarise(count = n())

# Se eliminan las columnas no deseadas con dplyr::select, y se transforman los
# tipos de datos con dplyr::mutate.
la_no2 <- la_no2 %>%
  dplyr::select(c(-Site, -Species, -Units)) %>%
  dplyr::mutate(
    Value = as.numeric(Value),
    reading_date = lubridate::dmy_hm(ReadingDateTime),
    reading_year = lubridate::year(reading_date),
    reading_month = lubridate::month(reading_date),
    reading_day = lubridate::day(reading_date),
    reading_hour = lubridate::hour(reading_date),
    reading_minute = lubridate::minute(reading_date)
  ) %>%
  dplyr::select(c(-ReadingDateTime, -reading_date))

# Explora valores faltantes por medio de una gráfica.
DataExplorer::plot_missing(la_no2)

# Elimina las filas que contienen datos faltantes.
la_no2 <- la_no2 %>% filter(!is.na(Value))

# Grafica la distribución de valores de las categorías.
DataExplorer::plot_bar(la_no2)

# Crea tabla con la misma información anterior.
la_no2 %>%
  dplyr::group_by(`Provisional or Ratified`) %>%
  dplyr::summarise(count = n())

# Como hay muy pocos valores marcados como provisionales, se procede a
# eliminarlos.
la_no2 <- la_no2 %>%
  dplyr::filter(
    `Provisional or Ratified` == 'R'
  )

# Ahora la columna Provisional or Ratified solo contiene un único valor, por
# lo que también se elimina.
la_no2 <- la_no2 %>%
  dplyr::select(-`Provisional or Ratified`)

# Se consulta el rango de años de los datos.
range(la_no2$reading_year)

# Como todos los registros pertenecen al mismo año, la columna se elimina.
la_no2 <- la_no2 %>%
  dplyr::select(-reading_year)

# Genera un histograma para revisar outliers en las variables continuas.
DataExplorer::plot_histogram(la_no2)

# Genera una revisión de correlaciones entre los datos.
DataExplorer::plot_correlation(la_no2)

# Ahora se tiene un dataset apropiadamente preprocesado y listo para el
# modelado. La gráfica de correlaciones muestra que las variables no están
# correlacionadas de manera significante.

# ------------------------------------
# ENTRENAMIENTO DE UN MODELO.
# ------------------------------------

# Parte el dataset en conjuntos de entrenamiento y prueba.
set.seed(1)
partition <- sample(nrow(la_no2), 0.75 * nrow(la_no2), replace = FALSE)
train <- la_no2[partition,]
test <- la_no2[-partition,]
target <- train$Value
dtrain <- xgboost::xgb.DMatrix(data = as.matrix(train), label = target)
dtest <- xgboost::xgb.DMatrix(data = as.matrix(test))

# Genera lista de parámetros necesarios para ejecutar el algoritmo xgboost.
params <- list(
  objective = "reg:linear", # Tarea a realizar.
  booster = "gbtree", # Gradient tree bosting.
  eval_metric = "rmse", # Root Mean Squared Error.
  eta = 0.1, # Learning rate.
  subsample = 0.8, # Porcentaje de las filas.
  colsample_bytree = 0.75, # Porcentaje de las columnas.
  print_every_n = 10,
  verbose = TRUE
)

# Entrena el modelo.
xgb <- xgboost::xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100
)

# Aplica el modelo a los datos de prueba.
pred <- predict(xgb, dtest)

# Evalúa el modelo.
Metrics::rmse(test$Value, pred)

# ------------------------------------
# MEJORA DE LOS RESULTADOS DEL MODELO.
# ------------------------------------

# Determina el número de rounds o de árboles que producen el menor error dada
# la configuración por defecto.
xgb_cv <- xgboost::xgb.cv(
  params = params,
  data = dtrain,
  nrounds = 10000,
  nfold = 5, # Número de particiones.
  showsd = T, # Muestra desviación estándar.
  stratified = T, # Asegura que cada partición tenga la misma proporción de categorías.
  print_every_n = 100,
  early_stopping_rounds = 25, # Cuándo el modelo debería detener el crecimiento de árboles.
  maximize = F, # Determina si la métrica implica mejora al aumentar o disminuir su valor.
)

# Define search grid para obtener los mejores hiperparámetros.
xgb_grid <- expand.grid(
  nrounds = 500,
  eta = 0.01,
  max_depth = c(2, 3, 4),
  gamma = c(0, 0.5, 1),
  colsample_bytree = 0.75,
  min_child_weight = c(1, 3, 5),
  subsample = 0.8
)

# Define cómo se desea manejar la búsqueda de parámetros.
xgb_tc <- caret::trainControl(
  method = "cv", # Estrategia cross validation.
  number = 5, # Número de particiones.
  search = "grid",
  returnResamp = "final",
  savePredictions = "final",
  verboseIter = TRUE,
  allowParallel = TRUE
)

# Corre el modelo usando cada combinación de hiperparámetros posible, generando
# un reporte que muestra el número de particiones y la configuración de
# parámetros que el algoritmo debe tener para presentar los mejores resultados.
xgb_param_tune <- caret::train(
  x = dtrain,
  y = target,
  trControl = xgb_tc,
  tuneGrid = xgb_grid,
  method = "xgbTree",
  verbose = TRUE
)

# Ahora que se conocen los mejores hiperparámetros, se colocan en el modelo
# para ver si hay alguna mejora.
params <- list(
  objective = "reg:linear",
  booster = "gbtree",
  eval_metric = "rmse",
  eta = 0.01,
  subsample = 0.8,
  colsample_bytree = 0.75,
  max_depth = 4,
  min_child_weight = 1,
  gamma = 1
)
xgb <- xgboost::xgb.train(
  params = params,
  data = dtrain,
  nrounds = 3162,
  print_every_n = 10,
  verbose = TRUE,
  maximize = FALSE
)
pred <- stats::predict(xgb, dtest)
Metrics::rmse(test$Value, pred)