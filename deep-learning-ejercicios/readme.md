# MCPI Deep Learning

Ejercicios de la materia de deep learning de la MCPI.

## SOLUCIÓN DE ERRORES

### Librerías de Linux faltantes

**Error:**

```
Configuration failed because XXXX was not found. Try installing
```

**Solución:**

```bash
sudo apt-get update
sudo apt-get install libssl-dev
sudo apt-get install libcurl4-openssl-dev 
sudo apt-get install libxml2-dev
```