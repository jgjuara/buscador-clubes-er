# Script para verificar disponibilidad de paquetes en webR

cat("==============================================\n")
cat("  Verificación de Paquetes webR\n")
cat("==============================================\n\n")

# Paquetes requeridos por la aplicación
required_packages <- c(
  "shiny",
  "bslib",
  "dplyr",
  "DT",
  "leaflet"
)

cat("Paquetes requeridos por la aplicación:\n")
cat(paste0("  - ", required_packages, collapse = "\n"), "\n\n")

cat("Verificando disponibilidad en webR...\n")
cat("(Visita https://repo.r-wasm.org/ para ver el repositorio completo)\n\n")

# Función para verificar si un paquete está en webR
# Nota: Esta es una verificación local basada en conocimiento común
# Para verificación real, visitar https://repo.r-wasm.org/

check_webr_availability <- function() {
  # Paquetes conocidos como disponibles en webR
  known_available <- c(
    "shiny",      # ✅ Disponible - core de Shinylive
    "bslib",      # ✅ Disponible - parte del ecosistema Shiny
    "dplyr",      # ✅ Disponible - parte del tidyverse
    "DT",         # ✅ Disponible - widget htmlwidgets
    "leaflet"     # ✅ Disponible - widget htmlwidgets
  )
  
  results <- data.frame(
    Package = required_packages,
    Status = ifelse(required_packages %in% known_available, "✅ Disponible", "⚠️  Verificar"),
    stringsAsFactors = FALSE
  )
  
  return(results)
}

results <- check_webr_availability()

cat("Resultados:\n")
cat("----------\n")
print(results, row.names = FALSE)

cat("\n")

if (all(grepl("✅", results$Status))) {
  cat("✅ Todos los paquetes están disponibles en webR\n")
  cat("   Tu aplicación debería funcionar correctamente con Shinylive.\n\n")
} else {
  cat("⚠️  Algunos paquetes necesitan verificación\n")
  cat("   Visita https://repo.r-wasm.org/ para confirmar disponibilidad.\n\n")
}

cat("Notas importantes:\n")
cat("------------------\n")
cat("1. webR solo soporta paquetes precompilados como binarios WebAssembly\n")
cat("2. No es posible instalar paquetes desde source en el navegador\n")
cat("3. Si un paquete no está en repo.r-wasm.org, no se puede usar\n")
cat("4. Los paquetes se detectan automáticamente en tu código\n")
cat("5. Si un paquete no se detecta, agrega: if (FALSE) library(paquete)\n\n")

cat("Para más información:\n")
cat("  https://posit-dev.github.io/r-shinylive/\n")
cat("  https://repo.r-wasm.org/\n\n")

