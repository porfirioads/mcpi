# Título:   Identificación de riesgo en préstamos de bancos.
# Autor:    Porfirio Ángel Díaz Sánchez
# Creación: 04/06/2020

source('utils/packages.R')
install_missing_packages(c('C50'))
library(C50)

# STEP 1. COLLECTING DATA
# ------

credit <- read.csv('datasets/credit.csv')

# STEP 2. EXPLORING AND PREPARING THE DATA
# ------

# Revisa tipos de datos.
str(credit)
credit$default <- as.factor(credit$default)

# Visualiza características.
table(credit$checking_balance)
table(credit$savings_balance)
summary(credit$months_loan_duration)
summary(credit$amount)
table(credit$default)

# Preparación de los datos
set.seed(123)
train_sample <- sample(1000, 900)
str(train_sample)
credit_train <- credit[train_sample,]
credit_test <- credit[-train_sample,]

# Visualiza porcentajes en datasets de entrenamiento y prueba.
prop.table(table(credit_train$default))
prop.table(table(credit_test$default))

# STEP 3. TRAINING A MODEL ON THE DATA
# ------

credit_model <- C5.0(credit_train[-17], credit_train$default)
credit_model
summary(credit_model)

# STEP 4. EVALUATING MODEL PERFORMANCE
# ------

credit_pred <- predict(credit_model, credit_test)
library(gmodels)
CrossTable(
  credit_test$default,
  credit_pred,
  prop.chisq = FALSE,
  prop.c = FALSE,
  prop.r = FALSE,
  dnn = c('actual default', 'predicted default')
)

# STEP 4. IMPROVING MODEL PERFORMANCE
# ------

# Boosting accuracy

credit_boost10 <- C5.0(credit_train[-17], credit_train$default,
                       trials = 10)

credit_boost10
summary(credit_boost10)

credit_boost_pred10 <- predict(credit_boost10, credit_test)
CrossTable(
  credit_test$default,
  credit_boost_pred10,
  prop.chisq = FALSE,
  prop.c = FALSE,
  prop.r = FALSE,
  dnn = c('actual default', 'predicted default')
)

# Haciendo algunas fallas más costosas que otras

matrix_dimensions <- list(c("no", "yes"), c("no", "yes"))
names(matrix_dimensions) <- c("predicted", "actual")
matrix_dimensions

error_cost <- matrix(c(0, 1, 4, 0), nrow = 2,
                     dimnames = matrix_dimensions)
error_cost

credit_cost <- C5.0(credit_train[-17], credit_train$default,
                    costs = error_cost)
credit_cost_pred <- predict(credit_cost, credit_test)
CrossTable(
  credit_test$default,
  credit_cost_pred,
  prop.chisq = FALSE,
  prop.c = FALSE,
  prop.r = FALSE,
  dnn = c('actual default', 'predicted default')
)                            