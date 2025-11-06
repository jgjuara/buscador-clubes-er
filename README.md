# Buscador de Instituciones Deportivas - Entre Ríos

Aplicación web basada en Shiny para facilitar la búsqueda y visualización de instituciones deportivas en la provincia de Entre Ríos, Argentina.

## Descripción

Esta herramienta permite explorar un catálogo de instituciones deportivas mediante un sistema de búsqueda inteligente con chips/tags. Los usuarios pueden buscar por nombre, ubicación, disciplinas deportivas, estado de infraestructura y otros criterios, visualizando los resultados tanto en formato de tabla como en un mapa interactivo.

## Características Principales

### Experiencia de Usuario

- **Búsqueda con chips/tags**: Sistema visual de búsqueda que convierte términos en chips removibles (Enter o Espacio para agregar, backspace para eliminar)
- **Búsqueda inteligente**: Algoritmo de scoring que busca en todos los campos y ordena resultados por relevancia
- **Mapa interactivo**: Visualización geográfica con Leaflet, sincronizado con selección de tabla
- **Tabla dinámica**: DataTables con paginación, ordenamiento, búsqueda adicional y selección múltiple
- **Interfaz responsiva**: Bootstrap 5 con tema Flatly, optimizado para desktop y móvil
- **Navegación por pestañas**: Tabla, Mapa y Ayuda en interfaz organizada

### Capacidades de Actualización

- **Datos**: Actualizar `data/data_clean.csv` con nuevas instituciones o información modificada
- **Diseño**: Cambiar tema Bootstrap modificando parámetro `bootswatch` en `app.R`
- **Scoring**: Ajustar pesos de relevancia en función `calculate_relevance_score()` en `utils.R`
- **Columnas**: Personalizar campos mostrados en función `format_for_display()` en `utils.R`
- **Estilos**: Modificar apariencia en `www/custom.css`

## Estructura del Proyecto

```
./
├── app.R                 # Aplicación principal Shiny
├── utils.R               # Funciones de búsqueda y procesamiento
├── data/
│   └── data_clean.csv   # Dataset de instituciones
├── www/
│   ├── chips.js         # Lógica JavaScript para chips
│   └── custom.css       # Estilos personalizados
```

## Uso Rápido

### Ejecución Local

```r
# Desde R/RStudio
shiny::runApp()
```

### Búsqueda de Instituciones

1. Escribe términos en el campo de búsqueda
2. Presiona **Enter** o **Espacio** para crear chips
3. Los resultados se actualizan automáticamente por relevancia
4. Elimina chips con el botón **X** o botón "Limpiar búsqueda"
5. Selecciona filas en la tabla para visualizar en el mapa

**Ejemplos:**
- `fútbol Gualeguay` - Clubes de fútbol en Gualeguay
- `hockey BUENO` - Instalaciones de hockey en buen estado
- `pileta natación` - Instituciones con piletas

## Documentación Adicional

- **DEPLOYMENT.md**: Dependencias y especificaciones de despliegue
- **IMPLEMENTATION.md**: Referencia técnica de la implementación

## Licencia

Uso interno - Consultoría ER
