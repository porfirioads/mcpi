# -----------------------
# Manejo de datos desde archivo csv
# -----------------------

# Cargar el archivo csv
usedcars <- read.csv('datasets/usedcars.csv', stringsAsFactors = FALSE)

# Ver los datos cargados
str(usedcars)

# -----------------------
# Exploración de las variables numéricas
# -----------------------

summary(usedcars$year)
summary(usedcars[c('price', 'mileage')])

# Cálculo de media
mean(c(243, 5000, 3200, 6000, 564))

# -----------------------
# Medidas de dispersión
# -----------------------

# Mínimo
min(usedcars$price)

# Máximo
max(usedcars$price)

# Máximo y mínimo
range(usedcars$price)

# Diferencia entre el máximo y mínimo
diff(range(usedcars$price))

# Obtiene los percentiles
quantile(usedcars$price)

# Obtiene los quintiles
quantile(usedcars$price, seq(from = 0, to = 1, by = 0.20))

# Calcula el rango intercuartil de los precios es decir, la diferencia de los
# cuartiles 1 y 3
IQR(usedcars$price)

# Creación de boxplots

boxplot(usedcars$price, main = "Boxplot de precios de carros usados",
        ylab = "Precio ($)")

boxplot(usedcars$year, main = "Boxplot de años de carros usados",
        ylab = "Año")

boxplot(usedcars$mileage, main = "Boxplot de mileage de carros usados",
        ylab = "Millas")

# Creación de histogramas

hist(usedcars$mileage, main = "Histograma de mileage", breaks = 22)

# -----------------------
# Medidas de propagación
# -----------------------

# Varianza
var(usedcars$price)

# Desviación estándar
sd(usedcars$price)

# -----------------------
# Exploración de las variables categóricas
# -----------------------

# Número de coincidencias en cada categoría
table(usedcars$year)
table(usedcars$model)
table(usedcars$color)
table(usedcars$transmission)

# Obtener ponderaciones en porcentajes
model_table <- table(usedcars$model)
prop.table(model_table)
color_table <- table(usedcars$color)
color_porcentaje <- prop.table(color_table) * 100
round(color_porcentaje, digits = 1)

plot(x = usedcars$mileage, y = usedcars$price, main = 'Precio vs Mileage',
     xlab = 'Odómetro (mi)', ylab = 'Precio ($)')

# -----------------------
# Exploración de relaciones
# -----------------------

install.packages('gmodels')
library('gmodels')

usedcars$color

usedcars$conservative <- usedcars$color %in%
  c('Black ', 'Gray ', 'Silver ', 'White ')

table(usedcars$conservative)

conservative_table <- table(usedcars$conservative)
conservative_pct <- prop.table(conservative_table) * 100
round(conservative_pct, digits = 1)

CrossTable(x = usedcars$model, y = usedcars$conservative)
CrossTable(x = usedcars$model, y = usedcars$conservative, chisq = TRUE)

