# -----------------------
# Declaración de vectores
# -----------------------

# Vector de cadenas
subject_name <- c("John Doe", "Jane Doe", "Steve Graves")
# Vector de flotantes
temperature <- c(98.1, 98.6, 101.4)
# Vector de booleanos
flu_status <- c(FALSE, TRUE, FALSE)

# Segundo elemento
temperature[2]
# Segundo y tercero
temperature[2:1]
# Todos los elementos, excepto el 2do
temperature[-2]
# Especifica un vector indicando si el valor debe o no ser devuelto
temperature[c(FALSE, FALSE, TRUE)]

# -----------------------
# Declaración de factores
#
# Un factor indica las categorías que tenemos, es decir Hombre y Mujer
# -----------------------

gender <- factor(c('Hombre', 'Mujer', 'Hombre'))
gender
# Indica cuandos valores tenemos de cada categoría
table(gender)

# Declaración de factores indicando los niveles
blood <- factor(c('O', 'AB', 'A'), levels = c('A', 'B', 'AB', 'O'))
blood
table(blood)
blood[1:2]

# Declaración de factores indicando el orden de los niveles
sintomas <- factor(c('Severo', 'Leve', 'Moderado'),
                   levels = c('Leve', 'Moderado', 'Severo'), ordered = TRUE)
sintomas
# Filtra los síntomas de acuerdo al nivel de intensidad especificado
sintomas < 'Moderado'
sintomas > 'Moderado'
sintomas >= 'Moderado'

# -----------------------
# Declaración de listas
# -----------------------

sujeto1 <- list(subject_name[1], temperature[1], flu_status[1], gender[1],
                blood[1], sintomas[1])
sujeto1
sujeto1[2]

# Declaración de lista especificando etiquetas para los valores
sujeto2 <- list(nombre = subject_name[1], temperatura = temperature[1],
                flu = flu_status[1], genero = gender[1],
                sangre = blood[1], sintomas = sintomas[1])
sujeto2
sujeto2[2]
sujeto2[[2]]
sujeto2$nombre

# -----------------------
# Dataframe
#
# Es la estructura más importante de R, podemos combinar todos los tipos de
# datos
# -----------------------

df_data <- data.frame(subject_name, temperature, flu_status, gender, blood,
                      sintomas, stringsAsFactors = FALSE)
df_data
# Obtener la columna completa del dataframe
df_data$subject_name
# Obtener columnas específicas
df_data[c('temperature', 'flu_status')]
# Filas 1 y 3, columnas 2 y 4
df_data[c(1, 3), c(2, 4)]
# De los pacientes 1 y 3, obtiene temperature y flu_status
df_data[c(1, 3), c('temperature', 'flu_status')]
# Todas las filas y todas las columnas
df_data[,]
# Todas las columnas de la fila 1
df_data[1,]
# Todas los valores de la columna 1
df_data[, 1]
# El segundo elemento de la fila de gender
df_data$gender[2]
# Elimina la fila 2, así como las columnas 1 y 3
df_data[-2, c(-1, -3)]

# -----------------------
# Declaración de matrices
# -----------------------

# Matriz con 4 elementos, los divide en dos filas
m <- matrix(c(1, 2, 3, 4), nrow = 2)
m

# Matriz con 4 elementos, los divide en dos columnas
m <- matrix(c(1, 2, 3, 4), ncol = 2)
m

# Matriz con 6 elementos, de 2x3
m1 <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2)
m1

# Matriz con 6 elementos, de 3x2
m2 <- matrix(c(1, 2, 3, 4, 5, 6), ncol = 2)
m2

# Multiplicación de matrices
m1 %*% m2
m2 %*% m1

# Transpuesta de una matriz
t(m1)

# Dimensiones de la matriz, en R especifica primero las columnas
dim(m1)

# Sacar determinante de una matriz (solo matrices cuadradas)
det(m1 %*% m2)

# Obtener primera fila de la matriz
m1[1,]

# Obtener primera columna de la matriz
m1[,1]

# Obtener elemento en fila y columna determinados
m1[1, 1]

# Obtiene la diagonal de la matriz
diag(m1)

# Obtiene la suma de la matriz
sum(m1)

# Obtiene las sumas de las columnas
colSums(m1)

# Obtiene las sumas de las filas
rowSums(m1)

# -----------------------
# Guardar, cargar y remover estructuras de datos con R
# -----------------------

save(blood, gender, temperature, 
     file = 'e01-introducción-a-R/working-with-data.RData')
load('e01-introducción-a-R/"working-with-data.RData"')
ls()