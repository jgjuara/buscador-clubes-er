FROM rocker/shiny:4.4.0

ENV SHINY_APP_DIR=/srv/shiny-server/app

USER root

RUN mkdir -p ${SHINY_APP_DIR}

COPY . ${SHINY_APP_DIR}

WORKDIR ${SHINY_APP_DIR}

RUN Rscript install_packages.R

RUN chown -R shiny:shiny ${SHINY_APP_DIR}

USER shiny

VOLUME ["${SHINY_APP_DIR}/data"]

EXPOSE 3838

CMD ["R", "-e", "options(shiny.port=3838, shiny.host='0.0.0.0'); shiny::runApp('.')"]

