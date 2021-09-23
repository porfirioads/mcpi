# VECTORES
# -----------------------------------

# Declaración de vectores
x <- c(1, 2, 3, 4, 5)
nombres <- c('Porfirio', 'Ángel')

# Acceso a elementos de un vector (los índices empiezan en 1)
x[1:3]
nombres[1:2]

# Declara vector con los números del 1 al 6
numeros <- 1:6
print(numeros)

# Forza a que el vector sea una matriz de 2x3
dim(numeros) <- c(2, 3)
print(numeros)

# Crea matriz a partir de un vector
matrix(c(2:10), nrow = 3, ncol = 3)

# VECTORES CON NOMBRES
# -----------------------------------

# Define vectores de valores y etiquetas
edades <- c(10, 15, 18)
nombres <- c('Paco', 'Pepe', 'Lupe')

# Asigna a edades las etiquetas contenidas en nombres
names(edades) <- nombres
edades
edades['Paco']


# LISTAS
# Son una colección ordenada y heterogénea de objetos
# -----------------------------------

# Declaración de listas
prenda <- list(cosa = 'sombrero', tamanio = 5.6)
prenda

# Acceso al componente
prenda[1]

# Acceso a los elementos del componente
prenda[[1]]

# Creación de lista compleja
lista_compleja <- list(thing = 'memoria',
                       size = 2,
                       matriz = matrix(c(3:10), nrow = 4, ncol = 2)
)
lista_compleja

# DATA FRAMES
# Son listas que contienen vectores de la misma longitud pero pueden ser de
# diferentes tipos
# -----------------------------------

# Declaración de vectores para el dataframe
teams <- c('PHI', 'NYM', 'FLA', 'ATL', 'WSN')
w <- c(92, 89, 94, 72, 59)
l <- c(70, 73, 77, 90, 102)

# Declaración del dataframe
nleast <- data.frame(teams, w, l)
nleast

# Acceso a los campos del dataframe
nleast$teams
nleast$teams == 'FLA'
nleast[,2]
nleast$l[nleast$teams == 'FLA']
