# Análisis de Covid-19

## Instalación de dependencias

**Latex y librerías:**

```bash
sudo apt-get install texlive
sudo apt-get install lmodern
sudo apt-get install texlive-latex-extra
```

## Solución de errores

### Problemas con RWeka

**Mensaje:**

```
conftest.c:1:10: fatal error: jni.h: No such file or directory
 #include <jni.h>
```

**Solución:**

```bash
sudo apt-get install libicu-dev libbz2-dev libpcre3-dev
sudo apt-get install liblzma-dev zlib1g-dev
sudo apt install libomp-dev
sudo R CMD javareconf JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
sudo apt install r-base-dev
```

### Error con paquetes después de una actualización de R

**Mensaje:**
```
Error: package ‘package_name’ was installed before R 4.0.0: please re-install it
```

**Solución:**

```bash
sudo R
sudo R
remove.packages("package_name", lib="/usr/lib/R/library")
install.packages("package_name", lib="/usr/lib/R/library")
```


### Error con librerías de Linux

**Mensaje:**
```
ERROR: dependency ‘xml2’ is not available for package ‘tm’
```

**Solución:**

```bash

```

**Mensaje:**
```
No package 'libcurl' found
```

**Solución:**

```bash
sudo apt-get install libcurl4-openssl-dev
```
