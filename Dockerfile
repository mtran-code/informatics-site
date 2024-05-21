# From R latest
FROM r-base:latest as builder

# Install Quarto latest
RUN curl -sSL https://quarto.org/download/latest/quarto-linux-arm64.deb -o quarto.deb && \
    apt-get update && \
    apt-get install -y ./quarto.deb && \
    rm quarto.deb

# Install renv and restore R environment
RUN R -r "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@*release')"

COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library

RUN R -e 'renv::restore()'

RUN quarto render .

FROM httpd:alpine
COPY --from=builder docs/ /usr/local/apache2/htdocs/