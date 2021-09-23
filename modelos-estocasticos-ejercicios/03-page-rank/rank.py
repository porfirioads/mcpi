import requests
from bs4 import BeautifulSoup

# Constantes de configuración
PROFUNDIDAD_NAVEGACION = 3

# Variables
apariciones = {}


def get_wikipedia_body_items(page_response):
    """Obtiene los elementos del cuerpo de un artículo en Wikipedia.

    page_response: Response de la petición http para obtener el artículo.
    """
    soup = BeautifulSoup(page_response.content, 'html.parser')
    body = soup.find_all(class_='mw-parser-output')

    if len(body) == 0:
        return []

    return soup.select('.mw-parser-output > *')


def get_request(url):
    """Realiza una petición get a una url."""

    if url in apariciones:
        return None

    try:
        return requests.get(url)
    except:
        return None


def navegar_wikipedia(url, nivel):
    """Método que navega recursivamente en los enlaces del artículo de
    Wikipedia proporcionado.

    url: Link desde el que se empieza a navegar.
    nivel: Profundidad de la llamada recursiva actual.
    """

    # Verificación de la condición de recursividad.

    if nivel > PROFUNDIDAD_NAVEGACION:
        return

    # Obtención de la página web.

    page = get_request(url)

    if page is None:
        return

    apariciones[url] = {}

    # Obtención de los elementos del artículo.

    children = get_wikipedia_body_items(page)

    # Obtención de los links y probabilidades de transición.

    links_count = 0

    for child in children:
        # Solo buscaremos en los párrafos de la parte inicial del artículo, por
        # lo que si se encuentra un encabezado h2, se detiene la búsqueda.
        if child.name == 'h2':
            break
        elif child.name == 'p':
            links = child.find_all('a')
            links_count += len(links)
            for link in links:
                href = link.get('href')
                # Valida que el link redirija a un artículo de Wikipedia y que
                # no sea un acceso a una posición específica del actual.
                if href is not None and href.startswith('/wiki') and '#' not in href:
                    href_url = f'https://es.wikipedia.org{href}'
                    apariciones[url][href_url] = -1
                    navegar_wikipedia(href_url, nivel + 1)

    # Asigna la probabilidad de transición de acuerdo a los links encontrados.
    for destino in apariciones[url]:
        apariciones[url][destino] = 1 / links_count


def rellenar_probabilidades():
    """Rellena las probabilidades de transición entre las ligas que no tienen 
    vínculo, con la finalidad de que la matriz sea estocástica."""

    # Recorre los orígenes para determinar probabilidad faltante y rellenarla
    # con los links faltantes.
    for origen in apariciones:
        suma = 0
        ceros_count = 0

        # Recorre los destinos y establece probabilidad 0 en los que no tienen
        # vínculo con el origen actual.
        for destino in apariciones:
            if destino not in apariciones[origen]:
                apariciones[origen][destino] = 0
                ceros_count += 1
            suma += apariciones[origen][destino]

        por_llenar = 1 - suma
        suma = 0

        # Recorre los destinos para repartir la probabilidad restante para que
        # la matriz sea estocástica.
        for destino in apariciones:
            if apariciones[origen][destino] == 0:
                apariciones[origen][destino] = por_llenar / ceros_count
            suma += apariciones[origen][destino]
        
        print(f'Suma: {round(suma, 1)}')


def mostrar_probabilidades():
    """Muestra las probabilidades de transición entre links."""

    for origen in apariciones:
        print(f'--- {origen}')
        for destino in apariciones:
            print(
                f'{round(apariciones[origen][destino], 3)}: {origen} - {destino}')


# Ejecución de programa
navegar_wikipedia('https://es.wikipedia.org/wiki/Lenguaje_de_programación', 0)
rellenar_probabilidades()
mostrar_probabilidades()
