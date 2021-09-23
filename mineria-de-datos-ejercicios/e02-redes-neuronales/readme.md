# Redes neuronales

## Instrucciones

**Preparación del entorno virtual:**

```bash
# Crear entorno e instalar dependencias
conda create -n venv-keras --file package-list.txt

# Activar entorno
conda activate venv-keras
```

**Instalación de librerías:**

```bash
conda install numpy keras jupyter matplotlib
```

**Abrir Anaconda Navigator:**

```bash
~/anaconda3/bin/anaconda-navigator
```

## Comandos conda

```bash
# Crear entorno
conda create -n venv-keras python=3.7

# Listar paquetes de environment actual:
conda list

# Exportar paquetes instalados a archivo:
conda list --export > package-list.txt

# Reinstalar paquetes desde un archivo:
conda create -n venv-keras --file package-list.txt
```