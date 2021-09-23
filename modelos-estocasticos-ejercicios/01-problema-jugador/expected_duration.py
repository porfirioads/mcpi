import matplotlib.pyplot as plt
import random

# Prepara datos que servirán para hacer los cálculos y mostrar las gráficas.
ks = [i for i in range(21)]
ps = [0.44, 0.5, 0.56]
axes = []
random.seed(1)

# Recorre cada una de las probabilidades para agregar su gráfica.
for p in ps:
    axes.append([])
    # Recorre las ks para hacer la sustitución de valores.
    for k in ks:
        q = 1 - p
        d_k = None

        if p == q:
            d_k = round((k * (20 - k)), 2)
        else:
            d_k = round(
                ((1 / (1 - 2 * p)) * (k - ((20 * (1 - (q / p) ** k))/(1 - (q / p) ** 20)))), 2)
        axes[-1].append(d_k)

# Recorre los valores calculados para generar cada gráfica linear.
for i in range(len(axes)):
    axe = axes[i]
    color = (random.random(), random.random(), random.random())
    line, = plt.plot(ks, axe, color=color, marker='o')
    line.set_label(f'$p={ps[i]}$')
    plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')

# Establece títulos generales y muestra la gráfica.
plt.title('Duración esperada', fontsize=14)
plt.ylabel('$D_k$', fontsize=14)
plt.xlabel('$k$', fontsize=14)
plt.tight_layout()
plt.grid(True)
plt.show()
