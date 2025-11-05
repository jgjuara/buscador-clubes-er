# Script de prueba para funciones auxiliares

# Cargar funciones
source("utils.R")

# Cargar datos
cat("Cargando datos...\n")
data_path <- file.path("..", "data_clean.csv")
if (!file.exists(data_path)) {
  data_path <- "data_clean.csv"
}

if (!file.exists(data_path)) {
  stop("No se encuentra el archivo data_clean.csv")
}

instituciones <- read.csv(data_path, stringsAsFactors = FALSE, encoding = "UTF-8")
cat(paste0("Datos cargados: ", nrow(instituciones), " instituciones\n\n"))

# Test 1: Búsqueda simple
cat("=== Test 1: Búsqueda simple ===\n")
test_terms <- c("fútbol", "Gualeguay")
results <- search_and_rank(instituciones, test_terms)
cat(paste0("Términos: ", paste(test_terms, collapse = ", "), "\n"))
cat(paste0("Resultados: ", nrow(results), " instituciones\n"))
if (nrow(results) > 0) {
  cat("Primeros 3 resultados:\n")
  print(head(results$nombre_institucion, 3))
}
cat("\n")

# Test 2: Búsqueda por estado
cat("=== Test 2: Búsqueda por estado ===\n")
test_terms <- c("BUENO")
results <- search_and_rank(instituciones, test_terms)
cat(paste0("Términos: ", paste(test_terms, collapse = ", "), "\n"))
cat(paste0("Resultados: ", nrow(results), " instituciones\n\n"))

# Test 3: Búsqueda múltiple
cat("=== Test 3: Búsqueda múltiple ===\n")
test_terms <- c("hockey", "pileta", "natación")
results <- search_and_rank(instituciones, test_terms)
cat(paste0("Términos: ", paste(test_terms, collapse = ", "), "\n"))
cat(paste0("Resultados: ", nrow(results), " instituciones\n\n"))

# Test 4: Format for display
cat("=== Test 4: Format for display ===\n")
display_data <- format_for_display(instituciones[1:5, ])
cat(paste0("Columnas mostradas: ", ncol(display_data), "\n"))
cat("Nombres de columnas:\n")
print(colnames(display_data))
cat("\n")

# Test 5: Prepare map data
cat("=== Test 5: Preparar datos del mapa ===\n")
map_data <- prepare_map_data(instituciones)
cat(paste0("Instituciones con coordenadas válidas: ", nrow(map_data), " / ", nrow(instituciones), "\n"))
if (nrow(map_data) > 0) {
  cat("Rango de latitudes: [", min(map_data$latitud), ", ", max(map_data$latitud), "]\n")
  cat("Rango de longitudes: [", min(map_data$longitud), ", ", max(map_data$longitud), "]\n")
}
cat("\n")

# Test 6: Calculate relevance score
cat("=== Test 6: Calcular score de relevancia ===\n")
test_row <- instituciones[1, ]
test_terms <- c("club", "deportivo")
score <- calculate_relevance_score(test_row, test_terms)
cat(paste0("Institución: ", test_row$nombre_institucion, "\n"))
cat(paste0("Términos: ", paste(test_terms, collapse = ", "), "\n"))
cat(paste0("Score: ", score, "\n\n"))

cat("=== Todas las pruebas completadas ===\n")
cat("\nPara ejecutar la aplicación Shiny, usa:\n")
cat("  shiny::runApp()\n")

