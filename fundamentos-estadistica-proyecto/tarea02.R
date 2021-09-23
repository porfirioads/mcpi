# ------------------------------------------------------------------------------
# Title     : Tarea 2
# Objective : Ejemplificar los ejercicios de la tarea 2 de la materia de
#             Fundamentos de estadística
# Created by: Porfirio Ángel Díaz Sánchez
# Created on: 19/03/2020
# ------------------------------------------------------------------------------

data <- read.csv('t02.csv', header = TRUE)

# Inciso a
plot(x = data$tiempo_capacitacion, y = data$tiempo_proyecto, main = 'Precio vs Mileage',
     xlab = 'Odómetro (mi)', ylab = 'Precio ($)')

# Inciso b
linearMod <- lm(tiempo_proyecto ~ tiempo_capacitacion, data=data)
abline(linearMod)

# Inciso c
linearMod
intercept <- summary(linearMod)$coefficients[1, 1]
slope <- summary(linearMod)$coefficients[2, 1]
tiempoEstimado <- slope * 28 + intercept
sprintf('El tiempo estimado es de %s horas', tiempoEstimado)