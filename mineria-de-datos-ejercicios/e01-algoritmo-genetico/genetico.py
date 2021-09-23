import numpy as np
from numpy.random import seed
from numpy.random import rand
from numpy.random import randint
import json

# seed(1)
fitness_esperado = 70


def generar_genes(no_genes, no_cromosomas, min_value, max_value):
    genes = {
        'genes': []
    }

    for i in range(no_genes):
        gen = randint(min_value, max_value + 1, no_cromosomas).tolist()
        genes['genes'].append({'gen': gen})

    return genes


def obtener_pesos_calorias(genes):
    calorias = [500, 300, 100, 700, 300, 400, 500, 400]
    pesos = [0.5, 0.1, 0.5, 0.25, 0.15, 0.15, 0.5, 0.3]
    genes['peso_total'] = 0
    genes['calorias_total'] = 0

    for gen in genes['genes']:
        gen['peso'] = 0
        gen['calorias'] = 0

    for gen in genes['genes']:
        for i in range(len(gen['gen'])):
            cromosoma = gen['gen'][i]

            if cromosoma == 1:
                gen['peso'] += pesos[i]
                gen['calorias'] += calorias[i]
                genes['peso_total'] += pesos[i]
                genes['calorias_total'] += calorias[i]

        # Esta línea es para visualización, hay que comentarla.
        # gen['gen'] = str(gen['gen'])


def calcular_fitness(genes):
    for gen in genes['genes']:
        gen['fitness_peso'] = (gen['peso'] / genes['peso_total']) * 100
        gen['fitness_calorias'] = (
            gen['calorias'] / genes['calorias_total']) * 100
        gen['fitness_total'] = gen['fitness_peso'] + gen['fitness_calorias']


def obtener_selecciones(genes):
    fitnesses = []

    for i in range(len(genes['genes'])):
        gen = genes['genes'][i]
        fitnesses.append(
            {
                'fitness': gen['fitness_total'],
                'index': i
            }
        )

    fitnesses.sort(key=lambda d: d['fitness'])

    for i in range(len(fitnesses)):
        fitness = fitnesses[i]
        if i == 0:
            genes['genes'][fitness['index']]['selecciones'] = 0
        elif i == len(fitnesses) - 1:
            genes['genes'][fitness['index']]['selecciones'] = 2
        else:
            genes['genes'][fitness['index']]['selecciones'] = 1


def obtener_cruces(genes):
    cruces = [None for i in range(len(genes['genes']))]
    # cruces = [None] * len(genes['genes'])
    indices_cruzados = []

    for i in range(len(genes['genes'])):
        gen = genes['genes'][i]

        for j in range(gen['selecciones']):
            indice_repetido = True
            indice = -1

            while indice_repetido:
                indice = randint(0, len(genes['genes']))
                indice_repetido = indice in indices_cruzados

            indices_cruzados.append(indice)
            cruces[indice] = {'gen': gen['gen']}

    return cruces


def obtener_reproducciones(cruces):
    reproducciones = []
    no_pares = int(len(genes['genes']) / 2)

    for par in range(no_pares):
        reproducciones.append({'gen': []})
        reproducciones.append({'gen': []})
        # indice_intercambio = randint(2, len(cruces[0]['gen']) - 2)
        indice_intercambio = randint(0, len(cruces[0]['gen']))

        # Intercambio antes del índice (queda igual)
        for i in range(indice_intercambio):
            reproducciones[par * 2]['gen'].append(cruces[par * 2]['gen'][i])
            reproducciones[(par * 2) +
                           1]['gen'].append(cruces[(par * 2) + 1]['gen'][i])

        # Intercambio después del índice
        for i in range(indice_intercambio, len(cruces[0]['gen'])):
            reproducciones[par *
                           2]['gen'].append(cruces[(par * 2) + 1]['gen'][i])
            reproducciones[(par * 2) +
                           1]['gen'].append(cruces[par * 2]['gen'][i])

    return reproducciones


def obtener_mutaciones(reproducciones):
    mutaciones = json.loads(json.dumps(reproducciones))

    for mutacion in mutaciones:
        indice_mutacion = randint(0, len(mutacion['gen']))
        valor = mutacion['gen'][indice_mutacion]
        mutacion['gen'][indice_mutacion] = abs(valor - 1)

    return mutaciones


def reemplazar_genes_invalidos(genes):
    genes_validos = {'genes': []}

    for gen in genes['genes']:
        es_valido = False
        intentos = 1

        while not es_valido:
            if gen['peso'] <= 2 and gen['calorias'] >= 2000:
                genes_validos['genes'].append(gen)
                es_valido = True
            else:
                # Nueva generación totalmente aleatoria
                nuevos_genes = generar_genes(1, 8, 0, 1)
                obtener_pesos_calorias(nuevos_genes)
                gen = nuevos_genes['genes'][0]

                # Nueva generación con mutación del gen inválido
                # nuevos_genes = {'genes': obtener_mutaciones([json.loads(json.dumps(gen))])}
                # obtener_pesos_calorias(nuevos_genes)
                # gen = nuevos_genes['genes'][0]

                intentos += 1

    obtener_pesos_calorias(genes_validos)
    return genes_validos


def realizar_busqueda_genetica(genes):
    gen_encontrado = False
    i = 1
    fitness_max = 0

    while not gen_encontrado:
        obtener_pesos_calorias(genes)
        genes = reemplazar_genes_invalidos(genes)
        calcular_fitness(genes)

        for gen in genes['genes']:
            if gen['fitness_total'] > fitness_max:
                fitness_max = gen['fitness_total']
                print(f'Intento {i}, mejor fitness: {fitness_max}')

            if gen["fitness_total"] >= fitness_esperado:
                gen_encontrado = True
                print(f'\nFINALIZADO EN {i} ITERACIONES')
                print(f'Gen: {gen["gen"]}')
                print(f'Fitness total: {gen["fitness_total"]}')
                print(f'Peso: {gen["peso"]}')
                print(f'Calorías: {gen["calorias"]}')
                break

        obtener_selecciones(genes)
        cruces = obtener_cruces(genes)
        reproducciones = obtener_reproducciones(cruces)
        mutaciones = obtener_mutaciones(reproducciones)
        genes = {'genes': mutaciones}
        i += 1


genes = generar_genes(4, 8, 0, 1)

genes = {
    'genes': [
        {'gen': [1, 1, 0, 0, 1, 1, 1, 0]},
        {'gen': [0, 1, 0, 1, 1, 1, 1, 1]},
        {'gen': [1, 1, 0, 1, 1, 1, 0, 1]},
        {'gen': [0, 1, 1, 1, 1, 0, 1, 1]}
    ]
}

realizar_busqueda_genetica(genes)
