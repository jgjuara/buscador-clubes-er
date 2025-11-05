# utils.R - Funciones auxiliares para búsqueda con scoring

#' Función para calcular score de relevancia de un registro
#' @param row Fila del dataframe
#' @param terms Vector de términos de búsqueda (chips)
#' @return Score numérico de relevancia
calculate_relevance_score <- function(row, terms) {
  if (length(terms) == 0) return(0)
  
  # Convertir row a vector de caracteres
  row_values <- as.character(unlist(row))
  row_values <- tolower(row_values)
  row_values <- row_values[!is.na(row_values) & row_values != "na"]
  
  score <- 0
  
  for (term in terms) {
    term_lower <- tolower(trimws(term))
    if (term_lower == "") next
    
    # Buscar coincidencias en todos los campos
    for (value in row_values) {
      # Coincidencia exacta (palabra completa): +10 puntos
      if (grepl(paste0("\\b", term_lower, "\\b"), value)) {
        score <- score + 10
      }
      # Coincidencia parcial: +3 puntos
      else if (grepl(term_lower, value)) {
        score <- score + 3
      }
    }
  }
  
  return(score)
}

#' Función para filtrar y ordenar datos según términos de búsqueda
#' @param data Dataframe con los datos
#' @param search_terms Vector de términos de búsqueda (chips)
#' @return Dataframe filtrado y ordenado por relevancia
search_and_rank <- function(data, search_terms) {
  if (length(search_terms) == 0 || all(trimws(search_terms) == "")) {
    return(data)
  }
  
  # Calcular score para cada fila
  data$relevance_score <- apply(data, 1, function(row) {
    calculate_relevance_score(row, search_terms)
  })
  
  # Filtrar filas con score > 0 y ordenar por relevancia
  result <- data[data$relevance_score > 0, ]
  result <- result[order(result$relevance_score, decreasing = TRUE), ]
  
  # Remover columna de score del resultado final
  result$relevance_score <- NULL
  
  return(result)
}

#' Función para formatear columnas para display
#' @param data Dataframe
#' @return Dataframe con columnas formateadas
format_for_display <- function(data) {
  # Seleccionar columnas más relevantes para mostrar
  display_cols <- c(
    "nombre_institucion",
    "tipo_de_institucion",
    "municipio_comuna_dom_real",
    "departamento",
    "disciplinas",
    "tipo_de_espacios_deportivos",
    "e_mail",
    "calle_dom_real",
    "nro_dom_real",
    "latitud",
    "longitud"
  )
  
  # Filtrar solo las columnas que existen
  display_cols <- display_cols[display_cols %in% colnames(data)]
  
  result <- data[, display_cols, drop = FALSE]
  
  # Renombrar columnas para mejor legibilidad
  colnames(result) <- c(
    "Nombre",
    "Tipo",
    "Municipio",
    "Departamento",
    "Disciplinas",
    "Espacios Deportivos",
    "Email",
    "Calle",
    "Número",
    "Latitud",
    "Longitud"
  )[1:ncol(result)]
  
  return(result)
}

#' Función para preparar datos del mapa
#' @param data Dataframe con latitud y longitud
#' @return Dataframe filtrado con coordenadas válidas
prepare_map_data <- function(data) {
  # Filtrar registros con coordenadas válidas
  map_data <- data[!is.na(data$latitud) & !is.na(data$longitud), ]
  map_data <- map_data[map_data$latitud != "" & map_data$longitud != "", ]
  
  # Convertir a numérico si es necesario
  map_data$latitud <- as.numeric(map_data$latitud)
  map_data$longitud <- as.numeric(map_data$longitud)
  
  # Filtrar valores fuera de rango razonable
  map_data <- map_data[
    !is.na(map_data$latitud) & 
    !is.na(map_data$longitud) &
    abs(map_data$latitud) < 90 & 
    abs(map_data$longitud) < 180,
  ]
  
  return(map_data)
}

