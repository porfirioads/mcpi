# ------------------------------------------------------------------------------
# Title     : Tarea 3
# Objective : Ejemplificar los ejercicios de la tarea 3 de la materia de
#             Fundamentos de estadística
# Created by: Porfirio Ángel Díaz Sánchez
# Created on: 19/03/2020
# ------------------------------------------------------------------------------

# Ejercicio 1
a <- 0.2
ac <- 1 - a
b_d_a <- 0.1
b_d_ac <- 0.05
bc_d_a <- 1 - b_d_a
bc_d_ac <- 1 - bc_d_a
b <- a * b_d_a + ac * b_d_ac
a_d_b <- (b_d_a * a) / (b_d_a * a + b_d_ac * ac)
sprintf('Ejercicio 1')
sprintf('a -> propenso a accidentes')
sprintf('b -> tiene accidente en el 1er año')
sprintf('1.a. p(b) = %s', b)
sprintf('1.b. p(a|b) = %s', a_d_b)

# Ejercicio 2
a <- 0.5
ac <- 1 - a
b_d_a <- .99
bc_d_a <- 1 - b_d_a
b_d_ac <- 0.02
bc_d_ac <- 1 - bc_d_a
a_d_b <- (b_d_a * a) / (b_d_a * a + b_d_ac * ac)
a_d_b <- round(a_d_b, digits = 2) * 100
sprintf('Ejercicio 2')
sprintf('a -> tiene la enfermedad')
sprintf('b -> el resultado de la prueba es positivo')
sprintf('p(a|b) = %s', b)
sprintf('1.b. p(a|b) = %s%%', a_d_b)

# Ejercicio 3
mas5pares_g1 <- .26
mas5pares_g2 <- .20
mas5pares_g3 <- .13
mas5pares_g4 <- .18
mas5pares_g5 <- .14
mas20edad_g1 <- .09
mas20edad_g2 <- .20
mas20edad_g3 <- .31
mas20edad_g4 <- .23
mas20edad_g5 <- .17
a <- mas20edad_g1 * mas5pares_g1 +
  mas20edad_g2 * mas5pares_g2 +
  mas20edad_g3 * mas5pares_g3 +
  mas20edad_g4 * mas5pares_g4 +
  mas20edad_g5 * mas5pares_g5
b <- (mas20edad_g5 * mas5pares_g5) /
  (mas20edad_g1 * mas5pares_g1 +
    mas20edad_g2 * mas5pares_g2 +
    mas20edad_g3 * mas5pares_g3 +
    mas20edad_g4 * mas5pares_g4 +
    mas20edad_g5 * mas5pares_g5)
sprintf('3.a. %s', a)
sprintf('3.b. %s', b)

# Ejercicio 4
a <- 0.6
ac <- 1 - a
b_d_a <- 0.35
b_d_ac <- 0.2
bc_d_a <- 1 - b_d_a
bc_d_ac <- 1 - bc_d_a
b <- a * b_d_a + ac * b_d_ac
ac_d_b <- (b_d_ac * ac) / (b_d_ac * ac + b_d_a * a)
ac_d_b <- round(ac_d_b, digits = 2)
sprintf('Ejercicio 1')
sprintf('a -> es niño')
sprintf('b -> es menor a 24 meses')
sprintf('1.a. p(b) = %s', b)
sprintf('1.b. p(ac|b) = %s', ac_d_b)
