# Script para instalar los paquetes necesarios para la aplicación Shiny

# Lista de paquetes requeridos
required_packages <- c(
  "shiny",
  "bslib",
  "dplyr",
  "DT",
  "leaflet"
)

# Función para verificar e instalar paquetes
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat(paste0("Instalando ", package, "...\n"))
    install.packages(package, dependencies = TRUE)
  } else {
    cat(paste0(package, " ya está instalado.\n"))
  }
}

# Instalar paquetes faltantes
cat("Verificando e instalando paquetes necesarios...\n\n")
invisible(sapply(required_packages, install_if_missing))

cat("\n¡Instalación completada!\n")
cat("Para ejecutar la aplicación, usa: shiny::runApp()\n")

