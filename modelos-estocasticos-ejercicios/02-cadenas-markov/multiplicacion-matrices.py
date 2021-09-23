import numpy as np

T = np.array(
    [
        [1/4, 1/2, 1/4],
        [1/2, 1/4, 1/4],
        [1/4, 1/4, 1/2]
    ]
)

for i in range(10):
    T = np.matmul(T, T)

print(T)