library(MPRAbase)

summary_df <- read.table("../inst/summary.csv", header=T, sep=',') # Load summary file
geo_selection_df <- filter(summary_df, GEO_number=="GSE83894") # User select GEO identifier
se <- ExportSummarizedExperiment(geo_selection_df) # Create the Summarized Experimen

