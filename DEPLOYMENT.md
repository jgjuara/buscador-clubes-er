# Especificaciones de Despliegue

Guía de dependencias y procedimientos para desplegar la aplicación en diferentes entornos.

## Dependencias

### Librerías R

Paquetes requeridos con versiones mínimas:

```r
install.packages(c(
  "shiny",      # >= 1.7.0
  "bslib",      # >= 0.5.0
  "dplyr",      # >= 1.0.0
  "DT",         # >= 0.28
  "leaflet"     # >= 2.1.0
))
```

**Notas:**
- Todas las librerías están disponibles en CRAN
- Compatible con webR para despliegue Shinylive
- Verificar compatibilidad webR en: https://repo.r-wasm.org/

### Datos

**Archivo requerido:** `data/data_clean.csv`

- **Formato:** CSV con encoding UTF-8, separador coma
- **Ubicación:** Directorio `data/` en la raíz del proyecto
- **Tamaño:** ~300 KB (304 KB en versión actual)
- **Columnas críticas:**
  - `nombre_institucion`: Nombre de la institución
  - `latitud`, `longitud`: Coordenadas geográficas (numeric)
  - `tipo_de_institucion`: Clasificación del lugar
  - `municipio`, `departamento`: Ubicación administrativa
  - `disciplinas`: Deportes disponibles
  - Otras columnas se incluyen en búsqueda y tabla

### Assets Estáticos

**Directorio:** `app/www/`

- `chips.js` (2 KB): Lógica JavaScript para sistema de chips/tags
- `custom.css` (3 KB): Estilos CSS personalizados

**Recursos externos** (CDN):
- Bootstrap 5 (via bslib)
- Font Google "Inter" (via bslib)
- jQuery (incluido con Shiny)
- Leaflet tiles del IGN Argentina (Instituto Geográfico Nacional)

## Despliegue con Docker Compose

### Requisitos

- Docker 24 o superior
- Docker Compose V2 (incluido en Docker Desktop o en distribuciones recientes de Docker CLI)

### Preparación del entorno

```bash
# Clonar repositorio
git clone https://github.com/[usuario]/buscador-clubes-er.git
cd buscador-clubes-er

# Crear directorio de datos persistentes
mkdir -p data

# Copiar dataset al volumen local
cp /ruta/al/original/data_clean.csv data/data_clean.csv
```

### Construcción y ejecución

```bash
# Construir imagen y levantar contenedor (primera vez)
docker compose up --build

# Levantar en segundo plano usando la imagen existente
docker compose up -d

# Detener y limpiar contenedor y red (mantiene el volumen)
docker compose down
```

La aplicación estará disponible en `http://localhost:3838`. El conjunto de datos persiste en el volumen `./data`, montado dentro del contenedor en `/srv/shiny-server/app/data`.

### Variables de entorno

- `DATA_PATH`: definida en `docker-compose.yml` como `/srv/shiny-server/app/data/data_clean.csv`. Cambia el valor solo si renombras el archivo dentro del volumen.

### Mantenimiento del volumen de datos

```bash
# Actualizar dataset
docker compose stop
cp /ruta/nueva/data_clean.csv data/data_clean.csv
docker compose start

# Respaldar datos
tar -czf backup-data.tar.gz data/

# Recrear volumen desde cero
docker compose down
rm -rf data
mkdir data
# volver a copiar data_clean.csv antes de levantar nuevamente
```

### Logs y diagnóstico

```bash
# Ver logs en tiempo real
docker compose logs -f

# Abrir shell dentro del contenedor
docker compose exec shiny-app bash

# Confirmar que el dataset está disponible
docker compose exec shiny-app ls -l /srv/shiny-server/app/data
```

## Despliegue en Ubuntu 22 Server con Shiny Server

### Requisitos del Sistema

- Ubuntu 22.04 LTS
- R >= 4.0.0
- Shiny Server (Open Source o Pro)
- 4 GB RAM mínimo
- 20 GB espacio en disco

### Instalación de R y Shiny Server

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar R
sudo apt install -y r-base r-base-dev

# Dependencias del sistema para paquetes R
sudo apt install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev

# Descargar e instalar Shiny Server
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.21.1012-amd64.deb
sudo apt install -y gdebi-core
sudo gdebi shiny-server-1.5.21.1012-amd64.deb
```

### Instalación de Paquetes R

```bash
# Ejecutar como usuario shiny
sudo su - -c "R -e \"install.packages(c('shiny', 'bslib', 'dplyr', 'DT', 'leaflet'), repos='https://cloud.r-project.org/')\""
```

### Configuración de la Aplicación

```bash
# Crear directorio de la app
sudo mkdir -p /srv/shiny-server/buscador-clubes

# Copiar archivos
sudo cp -r app/* /srv/shiny-server/buscador-clubes/
sudo mkdir -p /srv/shiny-server/buscador-clubes/data
sudo cp data/data_clean.csv /srv/shiny-server/buscador-clubes/data/

# Ajustar permisos
sudo chown -R shiny:shiny /srv/shiny-server/buscador-clubes
sudo chown shiny:shiny /srv/shiny-server/buscador-clubes/data/data_clean.csv
sudo chmod -R 755 /srv/shiny-server/buscador-clubes
```

### Configuración de Shiny Server

Editar `/etc/shiny-server/shiny-server.conf`:

```conf
# Ejecutar como usuario shiny
run_as shiny;

# Servidor en puerto 3838
server {
  listen 3838;
  
  # Ubicación de la app
  location /buscador-clubes {
    site_dir /srv/shiny-server/buscador-clubes;
    log_dir /var/log/shiny-server;
    
    # Directorio de trabajo
    directory_index on;
    
    # Timeouts (ajustar según necesidad)
    app_init_timeout 60;
    app_idle_timeout 300;
  }
}
```

### Iniciar Servicio

```bash
# Reiniciar Shiny Server
sudo systemctl restart shiny-server

# Verificar estado
sudo systemctl status shiny-server

# Habilitar inicio automático
sudo systemctl enable shiny-server

# Ver logs
sudo tail -f /var/log/shiny-server/*.log
```

### Acceso a la Aplicación

La aplicación estará disponible en:
```
http://[IP-SERVIDOR]:3838/buscador-clubes/
```

### Configuración de Firewall (Opcional)

```bash
# Permitir puerto 3838
sudo ufw allow 3838/tcp
sudo ufw reload
```

### Nginx como Proxy Reverso (Opcional)

Para servir en puerto 80/443 con dominio:

```bash
# Instalar Nginx
sudo apt install -y nginx

# Configurar site
sudo nano /etc/nginx/sites-available/buscador-clubes
```

```nginx
server {
    listen 80;
    server_name buscador.ejemplo.com;
    
    location / {
        proxy_pass http://localhost:3838/buscador-clubes/;
        proxy_redirect http://localhost:3838/ $scheme://$host/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 20d;
        proxy_buffering off;
    }
}
```

```bash
# Activar site
sudo ln -s /etc/nginx/sites-available/buscador-clubes /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Despliegue como Shinylive en GitHub Pages

### Requisitos

- Cuenta de GitHub
- R con paquete `shinylive` instalado
- Git configurado localmente

### Instalación de Shinylive

```r
install.packages("shinylive")
```

### Verificación de Compatibilidad

Todos los paquetes de esta app están disponibles en webR:

```r
# Opcional: verificar
packages <- c("shiny", "bslib", "dplyr", "DT", "leaflet")
sapply(packages, function(pkg) {
  url <- paste0("https://repo.r-wasm.org/bin/emscripten/contrib/4.3/", pkg, "_")
  exists <- !inherits(try(readLines(url, n=1, warn=FALSE), silent=TRUE), "try-error")
  cat(pkg, ":", ifelse(exists, "✅", "❌"), "\n")
})
```

### Exportación Local

```r
# Desde directorio raíz del proyecto
setwd("app")

# Exportar a shinylive
shinylive::export(".", "shinylive_export")

# Probar localmente
httpuv::runStaticServer("shinylive_export")
```

Esto genera el directorio `shinylive_export/` con:
- `index.html`: Aplicación empaquetada
- `app.json`: Código R y assets
- `shinylive/`: Runtime de webR (~20 MB)

### Configuración del Repositorio GitHub

1. **Crear repositorio** en GitHub (público o privado)

2. **Habilitar GitHub Pages:**
   - Settings → Pages
   - Source: "GitHub Actions"
   - Guardar

3. **Crear GitHub Action:**

Crear `.github/workflows/deploy-shinylive.yaml`:

```yaml
name: Deploy Shinylive

on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.3.0'
      
      - name: Setup R dependencies
        uses: r-lib/actions/setup-r-dependencies@v2
        with:
          packages: |
            any::shinylive
            any::shiny
            any::bslib
            any::dplyr
            any::DT
            any::leaflet
      
      - name: Export Shinylive
        run: |
          Rscript -e "shinylive::export('app', 'shinylive_export')"
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: 'shinylive_export'
      
      - name: Deploy to GitHub Pages
        uses: actions/deploy-pages@v2
```

### Despliegue

```bash
# Agregar workflow al repositorio
git add .github/workflows/deploy-shinylive.yaml
git commit -m "Add Shinylive deployment workflow"
git push origin main

# El workflow se ejecuta automáticamente
# Monitorear en: https://github.com/[usuario]/[repo]/actions
```

### Acceso a la Aplicación

La aplicación estará disponible en:
```
https://[usuario].github.io/[repo]/
```

**Tiempo de carga inicial:** 10-30 segundos (descarga de webR). Las visitas subsecuentes son instantáneas gracias al caché del navegador.

### Actualización de Datos

Para actualizar `data/data_clean.csv`:

```bash
# Reemplazar archivo en repositorio
git add data/data_clean.csv
git commit -m "Update data"
git push origin main

# El workflow redeploya automáticamente
```

### Limitaciones de Shinylive

- **Tamaño de datos:** Ideal para archivos <10 MB
- **Paquetes:** Solo los disponibles en repo.r-wasm.org
- **Sistema de archivos:** No hay acceso a archivos locales del servidor
- **Bases de datos:** No puede conectarse a bases de datos locales
- **Performance:** Depende del navegador del usuario
- **Privacidad:** Los datos permanecen en el navegador del usuario


### Ventajas de Shinylive

- **Sin servidor:** Hosting gratuito, sin costos de infraestructura
- **Escalabilidad:** Ilimitados usuarios concurrentes
- **Distribución:** Funciona offline después de la primera carga

## Troubleshooting

### Shiny Server: App no inicia

```bash
# Verificar logs
sudo tail -f /var/log/shiny-server/*.log

# Verificar permisos
ls -la /srv/shiny-server/buscador-clubes

# Verificar que data_clean.csv es accesible
sudo -u shiny cat /srv/shiny-server/buscador-clubes/data/data_clean.csv | head
```

### Shiny Server: Error de paquetes

```bash
# Reinstalar como usuario shiny
sudo su - -c "R -e \"install.packages('PAQUETE', repos='https://cloud.r-project.org/')\""
```

### Shinylive: No carga en navegador

- Verificar consola del navegador (F12 → Console)
- Confirmar que GitHub Pages está habilitado
- Esperar ~30 segundos para carga inicial de webR
- Limpiar caché del navegador (Ctrl+Shift+R)

### Shinylive: Errores en GitHub Actions

- Verificar que el workflow YAML está bien indentado
- Confirmar que las dependencias están listadas correctamente
- Revisar logs en pestaña Actions del repositorio

