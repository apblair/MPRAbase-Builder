FROM jupyter/datascience-notebook:latest

USER root

RUN R -e "install.packages('BiocManager', repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('tidyr', 'dplyr'), repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('dbplyr', 'RSQLite', 'DBI'), repos='http://cran.us.r-project.org')"
RUN R -e "BiocManager::install(c('SummarizedExperiment','BiocStyle','iSEE', 'BSgenome.Hsapiens.UCSC.hg38', 'BSgenome.Hsapiens.UCSC.hg19'), dependencies=TRUE)"
RUN R -e "install.packages(c('roxygen2','devtools'), repos='http://cran.us.r-project.org')"
RUN R -e "BiocManager::install(c('MultiAssayExperiment'), dependencies=TRUE)"
RUN R -e "install.packages('synapser', repos = c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

USER $NB_UID
RUN pip install --user pytest
RUN pip install --user synapseclient
RUN conda install -c conda-forge pandoc