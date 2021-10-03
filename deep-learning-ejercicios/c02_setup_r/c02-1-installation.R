# ------------------------------------
# INSTALACIÓN DE LOS PAQUETES
# ------------------------------------

# Revisa paquetes actualmente instalados.
rownames(installed.packages())

# ReinforcementLearning
install.packages("ReinforcementLearning")
library(ReinforcementLearning)

# RBM
# sudo apt install libssl-dev
# sudo apt install libcurl4-openssl-dev
# sudo apt install libxml2-dev
install.packages("devtools")
library(devtools)
install_github("TimoMatzen/RBM")

# Keras
devtools::install_github("rstudio/keras")
install.packages("keras")
library(keras)
library(tensorflow)
use_python(python = '/home/porfirio/anaconda3/envs/venv/bin/python', required = TRUE)
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

# Desde respuesta de https://askubuntu.com/questions/1326116/mxnet-r-package-compilation

"
sudo apt-get install git

cd ~/Downloads
git clone --recursive https://github.com/apache/incubator-mxnet mxnet -b v1.8.x

sudo apt-get update
sudo apt-get install -y build-essential git ninja-build ccache libopenblas-dev libopencv-dev cmake
sudo apt-get install -y nvidia-cuda-dev nvidia-cuda-gdb nvidia-cuda-toolkit nvidia-cuda-toolkit-gcc # Nvidia CUDA
sudo apt-get install -y libmkl-full-dev # MKL

cd mxnet
cmake . -D USE_CUDA=0
make -j$(nproc)
sudo make install
"

# Desde documentación de mxnet

"
INTENTO 1
sudo apt-get update
sudo apt-get install -y build-essential git
sudo apt-get install -y libopenblas-dev liblapack-dev libopencv-dev
sudo apt-get install -y libcairo2-dev libxml2-dev
sudo apt-get install -y ninja-build ccache cmake
git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet
cd mxnet
TODO: Reparar las instrucciones compilación
cmake . -D USE_CUDA=0
cmake . -DUSE_CUDA=0 -DUSE_CUDNN=0 -DUSE_BLAS=openblas -DDUSE_MKL_IF_AVAILABLE=0 -DUSE_MKLDNN=0
cmake . -D USE_CUDA=0 -D CMAKE_C_COMPILER=gcc -D CMAKE_CXX_COMPILER=g++
cmake . -D USE_CUDA=0 -D USE_CUDNN=0 -D USE_BLAS=openblas -D DUSE_MKL_IF_AVAILABLE=0 -D USE_MKLDNN=0 -D CMAKE_C_COMPILER=gcc -D CMAKE_CXX_COMPILER=g++
make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas
make rpkg
"
