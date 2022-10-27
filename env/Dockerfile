FROM jupyter/datascience-notebook:latest

USER root
RUN R -e "install.packages(c('BiocManager'), repos='http://cran.us.r-project.org')"
RUN R -e "BiocManager::install('SummarizedExperiment')"
