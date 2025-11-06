# Script para ejecutar la aplicación Shiny
# Asegúrate de estar en el directorio 'app/' antes de ejecutar

cat("==============================================\n")
cat("  Buscador de Instituciones Deportivas\n")
cat("==============================================\n\n")

# Verificar paquetes
required_packages <- c("shiny", "bslib", "dplyr", "DT", "leaflet")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("⚠️  Faltan los siguientes paquetes:\n")
  cat(paste0("   - ", missing_packages, collapse = "\n"), "\n\n")
  cat("Para instalarlos, ejecuta:\n")
  cat("   source('install_packages.R')\n\n")
  stop("Paquetes faltantes")
}

# Verificar archivo de datos
data_path_candidates <- c(
  Sys.getenv("DATA_PATH", unset = NA_character_),
  file.path("..", "data", "data_clean.csv"),
  file.path("data", "data_clean.csv"),
  "data_clean.csv"
)

data_path_candidates <- data_path_candidates[!is.na(data_path_candidates)]
data_path <- NULL
for (path in data_path_candidates) {
  if (file.exists(path)) {
    data_path <- path
    break
  }
}

if (is.null(data_path)) {
  stop("❌ No se encuentra el archivo 'data_clean.csv'. Esperado en 'data/data_clean.csv'.")
}

# Verificar archivos necesarios
required_files <- c("app.R", "utils.R", "www/chips.js", "www/custom.css")
missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0) {
  cat("❌ Faltan archivos necesarios:\n")
  cat(paste0("   - ", missing_files, collapse = "\n"), "\n")
  stop("Archivos faltantes")
}

cat("✓ Todos los paquetes están instalados\n")
cat("✓ Archivo de datos encontrado\n")
cat("✓ Todos los archivos necesarios presentes\n\n")

cat("Iniciando aplicación Shiny...\n")
cat("La aplicación se abrirá en tu navegador.\n")
cat("Para detenerla, presiona Ctrl+C o cierra la ventana de R.\n\n")

# Ejecutar aplicación
shiny::runApp(launch.browser = TRUE)

