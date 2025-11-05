# Aplicación Shiny para búsqueda de instituciones deportivas
# Sistema de búsqueda con chips/tags y visualización en mapa

library(shiny)
library(bslib)
library(dplyr)
library(DT)
library(leaflet)

# Cargar funciones auxiliares
source("utils.R")

# Cargar datos
data_path <- file.path(".", "data_clean.csv")
# if (!file.exists(data_path)) {
#   data_path <- "data_clean.csv"
# }

instituciones <- read.csv(data_path, stringsAsFactors = FALSE, encoding = "UTF-8")

# ============================================================================
# UI
# ============================================================================

ui <- page_sidebar(
  title = "Buscador de Instituciones Deportivas",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#0d6efd",
    # base_font = font_collection(font_base = "system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif")
  ),
  
  # Incluir archivos CSS y JS personalizados
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$script(src = "chips.js")
  ),
  
  # Sidebar con búsqueda
  sidebar = sidebar(
    width = 350,
    
    h4("Búsqueda Inteligente", class = "mb-3"),
    
    # Campo de búsqueda
    textInput(
      "search_input",
      label = NULL,
      placeholder = "Escribe términos y presiona Enter o Espacio...",
      width = "100%"
    ),
    
    # Contenedor para chips
    tags$div(
      id = "chips-container",
      class = "chips-container"
    ),
    
    # Ayuda contextual
    tags$div(
      class = "search-help",
      "💡 Escribe términos como 'fútbol', 'Gualeguay', 'hockey'. 
      Se buscarán en todos los campos."
    ),
    
    # Botones de acción
    tags$div(
      class = "action-buttons",
      actionButton(
        "clear_search",
        "Limpiar búsqueda",
        icon = icon("eraser"),
        class = "btn-outline-secondary btn-sm w-100"
      )
    ),
    
    hr(),
    
    # Info de resultados
    uiOutput("search_info")
  ),
  
  # Panel principal
  navset_card_tab(
    title = "Resultados",
    
    # Pestaña de tabla
    nav_panel(
      "Tabla de Resultados",
      icon = icon("table"),
      card_body(
        DTOutput("results_table")
      )
    ),
    
    # Pestaña de mapa
    nav_panel(
      "Mapa Interactivo",
      icon = icon("map"),
      card_body(
        helpText(
          "Selecciona instituciones en la tabla para visualizarlas en el mapa. ",
          "Usa Ctrl+Click para seleccionar múltiples filas."
        ),
        leafletOutput("map", height = 600)
      )
    ),
    
    # Pestaña de información
    nav_panel(
      "Ayuda",
      icon = icon("circle-info"),
      card_body(
        h5("Cómo usar esta aplicación"),
        tags$ul(
          tags$li("Escribe términos de búsqueda en el campo y presiona Enter o Espacio"),
          tags$li("Cada término se convierte en un chip azul que puedes eliminar con la X"),
          tags$li("La búsqueda busca coincidencias en todas las columnas de datos"),
          tags$li("Los resultados se ordenan por relevancia (más coincidencias = mayor score)"),
          tags$li("Selecciona filas en la tabla para verlas en el mapa interactivo"),
          tags$li("Usa Ctrl+Click para seleccionar múltiples instituciones")
        ),
        hr(),
        h5("Campos disponibles en los datos"),
        tags$ul(
          tags$li(tags$b("Básicos:"), " Nombre, tipo de institución, municipio, departamento"),
          tags$li(tags$b("Contacto:"), " Email, teléfonos, redes sociales, página web"),
          tags$li(tags$b("Deportivos:"), " Disciplinas, tipo de espacios, deporte adaptado"),
          tags$li(tags$b("Ubicación:"), " Dirección, coordenadas (lat/long)"),
          tags$li(tags$b("Accesibilidad:"), " Infraestructura adaptada para accesibilidad")
        ),
        hr(),
        tags$div(
          class = "alert alert-info",
          icon("lightbulb"),
          tags$b(" Tip: "),
          "Prueba búsquedas como 'fútbol Gualeguay', 'hockey BUENO', 
          'básquet pileta', etc. para encontrar instituciones específicas."
        )
      )
    )
  )
)

# ============================================================================
# SERVER
# ============================================================================

server <- function(input, output, session) {
  
  # Reactive: Términos de búsqueda desde JavaScript
  search_terms <- reactive({
    req(input$search_chips)
    input$search_chips
  })
  
  # Reactive: Datos filtrados según búsqueda
  filtered_data <- reactive({
    terms <- search_terms()
    
    if (is.null(terms) || length(terms) == 0) {
      return(instituciones)
    }
    
    result <- search_and_rank(instituciones, terms)
    return(result)
  })
  
  # Reactive: Datos formateados para display
  display_data <- reactive({
    data <- filtered_data()
    format_for_display(data)
  })
  
  # Output: Información de búsqueda
  output$search_info <- renderUI({
    n_total <- nrow(instituciones)
    n_filtered <- nrow(filtered_data())
    terms <- search_terms()
    
    if (is.null(terms) || length(terms) == 0) {
      tags$div(
        class = "alert alert-secondary",
        icon("database"),
        tags$b(paste0(" Total: ", n_total, " instituciones"))
      )
    } else {
      tags$div(
        class = "alert alert-primary",
        icon("filter"),
        tags$b(paste0(" Resultados: ", n_filtered, " / ", n_total)),
        tags$br(),
        tags$small(paste0("Términos: ", paste(terms, collapse = ", ")))
      )
    }
  })
  
  # Output: Tabla de resultados
  output$results_table <- renderDT({
    data <- display_data()
    
    datatable(
      data,
      selection = "multiple",
      options = list(
        pageLength = 25,
        scrollX = TRUE,
        language = list(
          search = "Buscar en resultados:",
          lengthMenu = "Mostrar _MENU_ registros",
          info = "Mostrando _START_ a _END_ de _TOTAL_ instituciones",
          infoEmpty = "No hay instituciones para mostrar",
          infoFiltered = "(filtrado de _MAX_ total)",
          paginate = list(
            first = "Primero",
            last = "Último",
            `next` = "Siguiente",
            previous = "Anterior"
          ),
          zeroRecords = "No se encontraron instituciones"
        )
      ),
      class = "table table-striped table-hover",
      rownames = FALSE
    )
  })
  
  # Output: Mapa interactivo
  output$map <- renderLeaflet({
    # Mapa base - IGN Argentina
    leaflet() %>%
      addTiles(
        urlTemplate = "https://wms.ign.gob.ar/geoserver/gwc/service/tms/1.0.0/mapabase_gris@EPSG%3A3857@png/{z}/{x}/{-y}.png",
        attribution = '&copy; <a href="https://www.ign.gob.ar/">Instituto Geográfico Nacional</a>',
        options = tileOptions(tms = TRUE)
      ) %>%
      setView(lng = -59.2, lat = -33.2, zoom = 9)
  })
  
  # Observer: Actualizar mapa con selección
  observe({
    selected_rows <- input$results_table_rows_selected
    data <- filtered_data()
    
    if (is.null(selected_rows) || length(selected_rows) == 0) {
      # No hay selección: mostrar todas las instituciones del resultado
      map_data <- prepare_map_data(data)
    } else {
      # Hay selección: mostrar solo las seleccionadas
      map_data <- prepare_map_data(data[selected_rows, ])
    }
    
    if (nrow(map_data) == 0) {
      # Sin datos para mapear
      leafletProxy("map") %>%
        clearMarkers() %>%
        setView(lng = -59.2, lat = -33.2, zoom = 9)
      return()
    }
    
    # Crear popups informativos
    popups <- paste0(
      "<b>", map_data$nombre_institucion, "</b><br/>",
      "<i>", map_data$tipo_de_institucion, "</i><br/>",
      "<hr style='margin: 5px 0;'/>",
      "<b>Disciplinas:</b> ", ifelse(is.na(map_data$disciplinas), "N/A", map_data$disciplinas), "<br/>",
      "<b>Municipio:</b> ", map_data$municipio_comuna_dom_real, "<br/>",
      "<b>Dirección:</b> ", 
      ifelse(is.na(map_data$calle_dom_real), "", paste0(map_data$calle_dom_real, " ")),
      ifelse(is.na(map_data$nro_dom_real), "", map_data$nro_dom_real)
    )
    
    # Actualizar mapa
    leafletProxy("map", data = map_data) %>%
      clearMarkers() %>%
      addMarkers(
        lng = ~longitud,
        lat = ~latitud,
        popup = popups,
        label = ~nombre_institucion,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", "padding" = "3px 8px"),
          textsize = "13px",
          direction = "auto"
        )
      ) %>%
      fitBounds(
        lng1 = min(map_data$longitud), 
        lat1 = min(map_data$latitud),
        lng2 = max(map_data$longitud), 
        lat2 = max(map_data$latitud)
      )
  })
}

# ============================================================================
# RUN APP
# ============================================================================

shinyApp(ui = ui, server = server)

