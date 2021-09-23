# ------------------------------------------------------------------------------
# Title     : Tarea 1
# Objective : Ejemplificar los ejercicios de la tarea 1 de la materia de
#             Fundamentos de estadística
# Created by: Porfirio Ángel Díaz Sánchez
# Created on: 19/03/2020
# ------------------------------------------------------------------------------

printModa <- function(moda, articulo, concepto, index) {
  if (length(moda) > 1) {
    modasStr <- paste(moda, collapse = ', ')
    sprintf('%s. Las modas de %s %s son: %s',
            index, articulo, concepto, modasStr)
  } else {
    sprintf('%s. La moda de %s %s es: %s',
            index, articulo, concepto, moda)
  }
}

# Ejercicio 1
eficiencias <- c(28.2, 28.3, 28.4, 28.5, 29.0)
media <- mean(eficiencias)
sprintf('1. El promedio de las eficiencias es: %s', media)

# Ejercicio 2
semanas <- c(2, 110, 5, 7, 6, 7, 3)
mediana <- median(semanas)
sprintf('2. La mediana de las semanas es: %s', mediana)

# Ejercicio 3
dias <- c(1, 2, 3, 5, 8, 100)
mediana <- median(dias)
sprintf('3. La mediana de los días es: %s', mediana)

# Ejercicio 4
library('modeest')
vestidos <- c(8, 10, 6, 4, 10, 12, 14, 10)
moda <- mfv(vestidos)
printModa(moda, 'los', 'vestidos', 4)

# Ejercicio 5
edades <- c(2, 5, 3, 5, 2, 4)
moda <- mfv(edades)
printModa(moda, 'las', 'edades', 5)

# Ejercicio 6
trajes <- c(3, 3, 4, 5, 5, 5)
media <- mean(trajes)
moda <- mfv(trajes)
mediana <- median(trajes)
table(trajes, dnn = '6.a. Trajes vendidos diariamente')
sprintf('6.b. La media de los trajes es: %s', media)
printModa(moda, 'los', 'trajes', '6.c')
sprintf('6.d. La mediana de los trajes es: %s', mediana)

# Ejercicio 7
library('Hmisc')
lanzamientos <- matrix(c(1, 2, 3, 4, 5, 6, 6, 4, 5, 8, 3, 4),
                       ncol = 2,
                       dimnames = list(NULL, c('valor', 'frecuencia')))
media <- wtd.mean(lanzamientos[, 1], weights = lanzamientos[, 2])
mediana <- wtd.quantile(lanzamientos[, 1], weights = lanzamientos[, 2])[3]
lanzamientos <- read.csv('t01_e07.csv', header = TRUE)
expanded <- lanzamientos[rep(1:nrow(lanzamientos), lanzamientos[['frecuencia']]),]
moda <- mfv(expanded$valor)
sprintf('7.a. La media de los lanzamientos es: %s', media)
sprintf('7.b. La mediana de los lanzamientos es: %s', mediana)
printModa(moda, 'los', 'lanzamientos', '7.c')

# Ejercicio 8
pop.sd <- function(x) {
  sd <- sqrt(sum((x - mean(x, na.rm = TRUE))^2, na.rm = TRUE) / sum(!is.na(x)))
  return(sd)
}
cotizaciones <- c(720, 880, 630, 590, 1140, 908, 677, 720, 1260, 800)
media <- mean(cotizaciones)
mediana <- median(cotizaciones)
sdMuestra <- sd(cotizaciones)
sdPoblacion <- pop.sd(cotizaciones)
sprintf('8.a. La media de las cotizaciones es: %s', media)
sprintf('8.b. La mediana de las cotizaciones es: %s', mediana)
sprintf('8.b. La desviación estándar muestral de las cotizaciones es: %s', sdMuestra)
sprintf('8.b. La desviación estándar poblacional de las cotizaciones es: %s', sdPoblacion)

# Ejercicio 9
conjunto1 <- c(1, 2, 3, 4, 5)
conjunto2 <- c(6, 7, 8, 9, 10)
conjunto3 <- c(11, 12, 13, 14, 15)
conjunto4 <- c(2, 4, 6, 8, 10)
conjunto5 <- c(10, 20, 30, 40, 50)
sdMuestraC1 <- sd(conjunto1)
sdPoblacionC1 <- pop.sd(conjunto1)
varMuestraC1 <- sdMuestraC1^2
varPoblacionC1 <- sdPoblacionC1^2
sdMuestraC2 <- sd(conjunto2)
sdPoblacionC2 <- pop.sd(conjunto2)
varMuestraC2 <- sdMuestraC2^2
varPoblacionC2 <- sdPoblacionC2^2
sdMuestraC3 <- sd(conjunto3)
sdPoblacionC3 <- pop.sd(conjunto3)
varMuestraC3 <- sdMuestraC3^2
varPoblacionC3 <- sdPoblacionC3^2
sdMuestraC4 <- sd(conjunto4)
sdPoblacionC4 <- pop.sd(conjunto4)
varMuestraC4 <- sdMuestraC4^2
varPoblacionC4 <- sdPoblacionC4^2
sdMuestraC5 <- sd(conjunto5)
sdPoblacionC5 <- pop.sd(conjunto5)
varMuestraC5 <- sdMuestraC5^2
varPoblacionC5 <- sdPoblacionC5^2
sprintf('9.a. La desviación estándar poblacional de los datos es: %s', sdPoblacionC1)
sprintf('9.a. La desviación estándar muestral de los datos es: %s', sdMuestraC1)
sprintf('9.a. La varianza poblacional de los datos es: %s', varPoblacionC1)
sprintf('9.a. La varianza muestral de los datos es: %s', varMuestraC1)
sprintf('9.b. La desviación estándar poblacional de los datos es: %s', sdPoblacionC2)
sprintf('9.b. La desviación estándar muestral de los datos es: %s', sdMuestraC2)
sprintf('9.b. La varianza poblacional de los datos es: %s', varPoblacionC2)
sprintf('9.b. La varianza muestral de los datos es: %s', varMuestraC2)
sprintf('9.c. La desviación estándar poblacional de los datos es: %s', sdPoblacionC3)
sprintf('9.c. La desviación estándar muestral de los datos es: %s', sdMuestraC3)
sprintf('9.c. La varianza poblacional de los datos es: %s', varPoblacionC3)
sprintf('9.c. La varianza muestral de los datos es: %s', varMuestraC3)
sprintf('9.d. La desviación estándar poblacional de los datos es: %s', sdPoblacionC4)
sprintf('9.d. La desviación estándar muestral de los datos es: %s', sdMuestraC4)
sprintf('9.d. La varianza poblacional de los datos es: %s', varPoblacionC4)
sprintf('9.d. La varianza muestral de los datos es: %s', varMuestraC4)
sprintf('9.e. La desviación estándar poblacional de los datos es: %s', sdPoblacionC5)
sprintf('9.e. La desviación estándar muestral de los datos es: %s', sdMuestraC5)
sprintf('9.e. La varianza poblacional de los datos es: %s', varPoblacionC5)
sprintf('9.e. La varianza muestral de los datos es: %s', varMuestraC5)

# Ejercicio 10
phs <- c(3.71, 4.23, 4.16, 2.98, 3.23, 4.67, 3.99, 5.04, 4.55, 3.24, 2.80,
         3.44, 3.27, 2.66, 2.95, 4.70, 5.12, 3.77, 3.12, 2.38, 4.57, 3.88,
         2.97, 3.70, 2.53, 2.67, 4.12, 4.80, 3.55, 3.86, 2.51, 3.33, 3.85,
         2.35, 3.12, 4.39, 5.09, 3.38, 2.73, 3.07)
sdMuestra <- sd(phs)
sdPoblacion <- pop.sd(phs)
rango <- diff(range(phs))
rangoIntercuartil <- IQR(phs)
sprintf('10.a. La desviación estándar poblacional de los datos es: %s', sdMuestra)
sprintf('10.a. La desviación estándar muestral de los datos es: %s', sdPoblacion)
sprintf('10.b. El rango de los datos es: %s', rango)
sprintf('10.c. El rango intercuartil de los datos es: %s', rangoIntercuartil)

# Ejercicio 11
edades <- c(36, 25, 37, 24, 39, 20, 36, 45, 31, 31, 39, 24, 29, 23, 41, 40, 33, 24, 34, 40)
boxplot(edades, main = 'Diagrama de caja y bigotes de edades', ylab = 'Años')