# ------------------------------------
# INSTALACIÓN DE LOS PAQUETES
# ------------------------------------

# Revisa paquetes actualmente instalados.
rownames(installed.packages())

# ReinforcementLearning
install.packages("ReinforcementLearning")

# RBM
install.packages("devtools")
library(devtools)
install_github("TimoMatzen/RBM")

# Keras
devtools::install_github("rstudio/keras")
install.packages("keras")
library(keras)
library(tensorflow)
use_python(python = '/home/porfirio/anaconda3/envs/R/bin/python', required = TRUE)
install_keras()
install_tensorflow()

# H2O
if ("package:h2o" %in% search()) { detach("package:h2o", unload = TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }
pkgs <- c("RCurl", "jsonlite")
for (pkg in pkgs) {
  if (!(pkg %in% rownames(installed.packages()))) { install.packages(pkg)
  }
}
install.packages("h2o", type = "source",
                 repos = ("http://h2o-release.s3.amazonaws.com/h2o/latest_stable_R"))

# MXNet
"
sudo apt-get update
sudo apt-get install -y build-essential git ninja-build ccache libopenblas-dev libopencv-dev cmake
git clone --recursive https://github.com/apache/incubator-mxnet
cd incubator-mxnet
cmake . -D USE_CUDA=0
make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas
make rpkg
"
