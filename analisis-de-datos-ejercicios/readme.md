# Ejercicios de Análisis de Datos

Implementación de los ejemplos y ejercicios vistos en la materia de Análisis de Datos de la Maestría en Ciencias del Procesamiento de la Información.

## Instalación de Anaconda

**Instalar Anaconda:**

```bash
# Update Local Package Manager
sudo apt-get update

# Download the Latest Version of Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh

# Run Anaconda Installation Script
sudo bash Anaconda3-2020.02-Linux-x86_64.sh

# Activate installation
source ~/.bashrc

# Test installation
conda info
```

**Actualizar Anaconda:**

```bash
# Update conda utility
conda update conda

# Update Anaconda package
conda update anaconda
```

## Instalación de proyecto

```bash
# Crear virtualenv
conda create --name venv python=3

# Activar virtualenv
conda activate venv

# Instalar dependencias
conda install numpy
conda install pandas
conda install statsmodels
conda install matplotlib
conda install seaborn
conda install jupyter
conda install -c conda-forge pandas-profiling
conda install -c conda-forge pywavelets
conda install -c conda-forge lightgbm
```

## Manejo del proyecto

**Comandos para manejar Anaconda:**

```bash
# Create virtualenv
conda create --name venv python=3

# Activate environment
conda activate venv

# Deactivate environment
conda deactivate

# Start notebook
jupyter notebook

# Open Anaconda Navigator
~/anaconda3/bin/anaconda-navigator
```

## Solución de errores

### NotWritableError

**Mensaje:**

```bash
NotWritableError: The current user does not have write permissions to a required path.
  path: /home/porfirio/.conda/pkgs/urls.txt
  uid: 1000
  gid: 1000
```

**Solución:**

```bash
sudo chown -R $USER:$USER ~/anaconda3
```

### Unable to create environments file

**Mensaje:**

```bash
Verifying transaction: - WARNING conda.core.path_actions:verify(963): Unable to create environments file. Path not writable.
  environment location: /home/porfirio/.conda/environments.txt
```

**Solución:**

```bash
sudo chown -R $USER:$USER ~/.conda
sudo chmod -R 775 ~/.conda
```

### DISTRO_NAME referenced before assignment

**Mensaje:**

```bash
File "/home/porfirio/anaconda3/lib/python3.7/site-packages/anaconda_navigator/api/external_apps/vscode.py", line 168, in _find_linux_install_dir
    if DISTRO_NAME in ['ubuntu', 'debian']:
UnboundLocalError: local variable 'DISTRO_NAME' referenced before assignment
```

**Solución:**

```bash
# Abrir configuración de vscode para conda.
vim anaconda3/lib/python3.7/site-packages/anaconda_navigator/api/external_apps/vscode.py

# En el método mostrado abajo, asignar variable DISTRO_NAME
def _find_linux_install_dir(self):
        INST_DIR = None
        exe = os.path.join('/snap', 'bin', 'code')
        if os.path.lexists(exe):
            INST_DIR = '/snap'

        DISTRO_NAME = None # Esta línea es la que se tiene que agregar.

        for distro in self.distro_map.keys():
            _distro_regex = ".*{}/([^ ]*)".format(distro)
            m = re.match(_distro_regex, self._conda_api.user_agent)
            if m:
                DISTRO_NAME = distro
                DISTRO_VER = m.group(1)
                break
```
