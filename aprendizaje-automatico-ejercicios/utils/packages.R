# Instala los paquetes faltantes a partir de una lista de paquetes 
# proporcionada.
install_missing_packages <- function(package_list) {
  not_installed_yet <-
    package_list[!(package_list %in% installed.packages()[, 'Package'])]
  if(length(not_installed_yet)) install.packages(not_installed_yet)  
}
