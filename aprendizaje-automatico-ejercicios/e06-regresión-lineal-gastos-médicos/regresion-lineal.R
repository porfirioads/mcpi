# Título:   Predicción de gastos médicos.
# Autor:    Porfirio Ángel Díaz Sánchez
# Creación: 04/06/2020

# NOTA: El CLI preguntará: Do you want to install from sources the package which
#       needs compilation? (Yes/no/cancel), en este caso, para el correcto
#       funcionamiento de la librería mnormt, contestar 'no'.

source('utils/packages.R')
install_missing_packages(c('corrplot', 'psych', 'mnormt'))
library(corrplot)
library(psych)

# STEP 1. COLLECTING DATA
# ------

insurance <- read.csv('datasets/insurance.csv', stringsAsFactors = TRUE)

# STEP 2. EXPLORING AND PREPARING THE DATA
# ------

str(insurance)

# Aunque la regresión lineal no requiere estrictamente una variable dependiente
# normalmente distribuída, el modelo funcionará mejor si sí lo es. A 
# continuación se analiza la variable.
summary(insurance$expenses)
hist(insurance$expenses) # right-skewed

# Otro problema es que se necesitan variables numéricas, y se tienen algunos
# factores.
table(insurance$region)

# Crea matriz de correlación para variables numéricas.
correlacion = cor(insurance[c('age', 'bmi', 'children', 'expenses')])
corrplot(correlacion, method="color")

# Crea matriz de dispersión (scatterplot)
pairs(insurance[c('age', 'bmi', 'children', 'expenses')])

# Crea matriz de dispersión avanzada, que además muestra distribución de las 
# características así como sus correlaciones.
pairs.panels(insurance[c('age', 'bmi', 'children', 'expenses')])

# STEP 3. TRAINING A MODEL ON THE DATA
# ------

# Genera el modelo de regresión lineal.
ins_model <- lm(expenses ~ age + children + bmi + sex + smoker + region, 
                data = insurance)
ins_model

# STEP 4. EVALUATING MODEL PERFORMANCE
# ------

summary(ins_model)

# STEP 5. IMPROVING MODEL PERFORMANCE
# ------

# Agrega relaciones no lineares.
insurance$age2 <- insurance$age^2

# Convierte variable numérica a indicador binario.
insurance$bmi30 <- ifelse(insurance$bmi >= 30, 1, 0)

# Crea modelo de regresión mejorado.
ins_model2 <- lm(expenses ~ age + age2 + children + bmi + sex + bmi30*smoker 
                 + region, data = insurance)
summary(ins_model2)
