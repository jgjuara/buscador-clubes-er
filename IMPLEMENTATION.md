# Referencia Técnica de Implementación

Documentación técnica de componentes y algoritmos principales.

## Arquitectura

### Componentes

- **app.R**: UI y lógica del servidor Shiny
- **utils.R**: Funciones de búsqueda y procesamiento de datos
- **www/chips.js**: Sistema de chips/tags con jQuery
- **www/custom.css**: Estilos personalizados Bootstrap 5

### Stack Tecnológico

- **Framework:** Shiny con Bootstrap 5 (via bslib)
- **Visualizaciones:** Leaflet (mapas), DT (tablas)
- **Procesamiento:** dplyr para manipulación de datos
- **Frontend:** jQuery para interactividad de chips

## Sistema de Chips

Implementación JavaScript para búsqueda con tags visuales.

### Funcionalidad Principal

```javascript
let searchTerms = [];

// Agregar chip con Enter o Espacio
$('#search_input').on('keydown', function(e) {
  if ((e.keyCode === 13 || e.keyCode === 32) && value !== '') {
    addTerm(value);
    Shiny.setInputValue('search_chips', searchTerms, {priority: 'event'});
  }
});

// Eliminar con Backspace en campo vacío
if (e.keyCode === 8 && value === '') {
  removeLastTerm();
}
```

### Características

- Prevención de duplicados
- Comunicación bidireccional Shiny-JavaScript
- Eliminación individual (click en X) o por teclado
- Animaciones CSS para agregar/eliminar

## Algoritmo de Búsqueda

### Scoring de Relevancia

Función: `calculate_relevance_score(row, terms)`

```r
score <- 0
for (term in terms) {
  term_lower <- tolower(term)
  
  for (value in row_values) {
    value_lower <- tolower(as.character(value))
    
    # Coincidencia exacta de palabra completa: +10
    if (grepl(paste0("\\b", term_lower, "\\b"), value_lower)) {
      score <- score + 10
    }
    # Coincidencia parcial: +3
    else if (grepl(term_lower, value_lower)) {
      score <- score + 3
    }
  }
}
```

**Comportamiento:**
- Case-insensitive
- Búsqueda en todas las columnas del dataset
- Score acumulativo (múltiples coincidencias suman)
- Resultados ordenados por relevancia descendente

### Pipeline de Búsqueda

```r
# 1. Calcular score para cada fila
data$relevance_score <- apply(data, 1, function(row) {
  calculate_relevance_score(row, search_terms)
})

# 2. Filtrar solo resultados relevantes
result <- data[data$relevance_score > 0, ]

# 3. Ordenar por relevancia
result <- result[order(result$relevance_score, decreasing = TRUE), ]
```

## Integración de Mapa

### Leaflet Reactivo

```r
# Mapa base - IGN Argentina
leaflet() %>%
  addTiles(
    urlTemplate = "https://wms.ign.gob.ar/geoserver/gwc/service/tms/1.0.0/mapabase_gris@EPSG%3A3857@png/{z}/{x}/{-y}.png",
    attribution = '&copy; <a href="https://www.ign.gob.ar/">Instituto Geográfico Nacional</a>',
    options = tileOptions(tms = TRUE)
  ) %>%
  setView(lng = -59.2, lat = -33.2, zoom = 9)

# Actualización con leafletProxy (sin recrear mapa)
observe({
  selected <- input$results_table_rows_selected
  map_data <- if (is.null(selected)) {
    prepare_map_data(filtered_data())
  } else {
    prepare_map_data(filtered_data()[selected, ])
  }
  
  leafletProxy("map", data = map_data) %>%
    clearMarkers() %>%
    addMarkers(
      lat = ~latitud,
      lng = ~longitud,
      popup = ~popup_html,
      label = ~nombre_institucion
    ) %>%
    fitBounds(~min(longitud), ~min(latitud), 
              ~max(longitud), ~max(latitud))
})
```

### Validación de Coordenadas

```r
prepare_map_data <- function(data) {
  # Filtrar NA y convertir a numérico
  map_data <- data[!is.na(data$latitud) & !is.na(data$longitud), ]
  map_data$latitud <- as.numeric(map_data$latitud)
  map_data$longitud <- as.numeric(map_data$longitud)
  
  # Validar rangos
  map_data <- map_data[
    abs(map_data$latitud) < 90 & 
    abs(map_data$longitud) < 180,
  ]
  
  return(map_data)
}
```

## Tabla Interactiva

### Configuración DataTables

```r
datatable(
  data,
  selection = "multiple",
  rownames = FALSE,
  options = list(
    pageLength = 25,
    scrollX = TRUE,
    dom = 'Bfrtip',
    language = list(
      url = "//cdn.datatables.net/plug-ins/1.10.24/i18n/Spanish.json"
    )
  ),
  class = "table table-striped table-hover"
)
```

**Features:**
- Selección múltiple (Ctrl+Click)
- Búsqueda nativa adicional
- Paginación y ordenamiento
- Scroll horizontal para móvil
- Interfaz en español

## Flujo de Reactividad

```
Input JavaScript
    ↓
search_chips → reactive: search_terms()
    ↓
reactive: filtered_data() (aplica scoring)
    ↓
reactive: display_data() (formatea columnas)
    ↓
output: results_table (renderDT)
    ↓
input: results_table_rows_selected
    ↓
observer: actualiza mapa (leafletProxy)
```

## Optimizaciones

### Performance

- **Carga de datos:** Una sola vez al inicio
- **leafletProxy:** Actualiza sin recrear mapa completo
- **Reactive caching:** Evita recálculos innecesarios
- **Búsqueda lazy:** Solo cuando cambian los chips

### UI/UX

- **Bootstrap 5:** Componentes modernos y responsivos
- **Google Fonts:** Tipografía Inter para legibilidad
- **Validación de inputs:** Prevención de errores de usuario
- **Feedback visual:** Animaciones y estados de carga

## Personalización

### Cambiar Scoring

Editar `utils.R`, función `calculate_relevance_score()`:

```r
# Ajustar pesos
score <- score + 15  # Coincidencia exacta (default: 10)
score <- score + 5   # Coincidencia parcial (default: 3)
```

### Modificar Columnas Mostradas

Editar `utils.R`, función `format_for_display()`:

```r
display_cols <- c(
  "nombre_institucion",
  "tipo_de_institucion",
  "municipio",
  # Agregar/quitar columnas aquí
)
```

### Cambiar Tema Visual

Editar `app.R`, parámetro `bootswatch`:

```r
theme = bs_theme(
  version = 5,
  bootswatch = "flatly",  # Opciones: minty, cosmo, litera, etc.
  primary = "#0d6efd"
)
```

Ver temas en: https://bootswatch.com/


