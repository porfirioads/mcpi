import numpy as np
import matplotlib.pyplot as plt
import scipy.linalg as la

def markov_eigen(T):
    # Obtención de los eigenvalores, eigenvectores y diagonal
    eigens = la.eig(T)
    eigenvalores = eigens[0]
    eigenvectores = eigens[1]
    C = eigenvectores
    C_inversa = la.inv(C)
    D = np.zeros((len(eigenvalores), len(eigenvalores)))
    for i in range(len(eigenvalores)):
        D[i][i] = eigenvalores[i]

    # Cálculo de T^n
    n = 100000
    D_n = D.copy()
    for i in range(len(eigenvalores)):
        D_n[i][i] = D_n[i][i] ** n
    T_n = np.matmul(C, np.matmul(D_n, C_inversa))

    # Impresión de los resultados
    print(f'T\n{T}\n')
    print(f'EIGENVALORES\n{eigenvalores}\n')
    print(f'C\n{C}\n')
    print(f'C INVERSA\n{C_inversa}\n')
    print(f'D\n{D}\n')
    print(f'D^n\n{D_n}\n')
    print(f'T^n\n{T_n}\n')

# Definición de la matriz
T_1 = np.array(
    [
        [1/4, 1/2, 1/4],
        [1/2, 1/4, 1/4],
        [1/4, 1/4, 1/2]
    ]
)

T_2 = np.array(
    [
        [1/2, 1/4, 1/4],
        [0,   1,   0  ],
        [1/4, 1/4, 1/2]
    ]
)

# markov_eigen(T_1)
markov_eigen(T_2)