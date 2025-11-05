# Script para exportar la aplicación a Shinylive
# Shinylive permite ejecutar Shiny apps completamente en el navegador sin servidor

cat("==============================================\n")
cat("  Exportar a Shinylive\n")
cat("==============================================\n\n")

# Verificar que shinylive esté instalado
if (!requireNamespace("shinylive", quietly = TRUE)) {
  cat("El paquete 'shinylive' no está instalado.\n")
  cat("Instalando desde CRAN...\n\n")
  install.packages("shinylive")
}


library(shinylive)

# Mostrar información de versiones
cat("Información de shinylive:\n")
cat("-------------------------\n")
shinylive::assets_info()
cat("\n")

# Verificar que los archivos necesarios existan
required_files <- c("app.R", "utils.R", "www/chips.js", "www/custom.css")
missing <- required_files[!file.exists(required_files)]

if (length(missing) > 0) {
  stop("Faltan archivos necesarios:\n", paste0("  - ", missing, collapse = "\n"))
}

# Directorio de salida
output_dir <- "shinylive_export"

cat("Exportando aplicación a Shinylive...\n")
cat("Directorio de salida:", output_dir, "\n\n")

# Eliminar exportación anterior si existe
if (dir.exists(output_dir)) {
  cat("Eliminando exportación anterior...\n")
  unlink(output_dir, recursive = TRUE)
}

# Exportar la aplicación
shinylive::export(
  appdir = ".",
  destdir = output_dir
)

cat("\n✅ Exportación completada!\n\n")
cat("Para probar localmente:\n")
cat("  httpuv::runStaticServer('", output_dir, "')\n\n", sep = "")

cat("Para desplegar:\n")
cat("  1. Sube el directorio '", output_dir, "/' a cualquier hosting estático\n", sep = "")
cat("  2. Opciones: GitHub Pages, Netlify, Vercel, etc.\n\n")

cat("Para GitHub Pages automático, usa:\n")
cat("  usethis::use_github_action(\n")
cat("    url='https://github.com/posit-dev/r-shinylive/blob/actions-v1/examples/deploy-app.yaml'\n")
cat("  )\n\n")

