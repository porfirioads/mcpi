import requests
from bs4 import BeautifulSoup
import time

apariciones = {}


def navegar(url, nivel):
    if nivel > 3:
        return

    if url in apariciones:
        print(f'Ya se había accedido a {url}')
        return
    else:
        apariciones[url] = {}

    try:
        page = requests.get(url)
    except:
        print(f'Ocurrió un error en la request a {url}')
        return

    soup = BeautifulSoup(page.content, 'html.parser')
    body = soup.find_all(class_='mw-parser-output')

    if len(body) == 0:
        print(f'No hay body en {url}')
        return

    children = soup.select('.mw-parser-output > *')
    links_count = 0

    for child in children:
        if child.name == 'h2':
            break
        elif child.name == 'p':
            links = child.find_all('a')
            links_count += len(links)
            for link in links:
                href = link.get('href')
                if href is not None and href.startswith('/wiki') and '#' not in href:
                    href_url = f'https://es.wikipedia.org{href}'
                    apariciones[url][href_url] = -1
                    navegar(href_url, nivel + 1)

    for destino in apariciones[url]:
        apariciones[url][destino] = 1 / links_count


navegar('https://es.wikipedia.org/wiki/Lenguaje_de_programación', 0)

# Llena las probabilidades de transición
for origen in apariciones:
    suma = 0
    ceros_count = 0

    for destino in apariciones:
        if destino not in apariciones[origen]:
            apariciones[origen][destino] = 0
            ceros_count += 1
        suma += apariciones[origen][destino]

    por_llenar = 1 - suma
    suma = 0

    for destino in apariciones:
        if apariciones[origen][destino] == 0:
            apariciones[origen][destino] = por_llenar / ceros_count
        suma += apariciones[origen][destino]

# Muestra las probabilidades de transición
for origen in apariciones:
    print(f'--- {origen}')
    for destino in apariciones:
        print(
            f'{round(apariciones[origen][destino], 3)}: {origen} - {destino}')
