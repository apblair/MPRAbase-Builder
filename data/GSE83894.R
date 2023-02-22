library(MPRAbase)

summary_df <- read.table("../inst/summary.csv", header=T, sep=',') # Load summary file
geo_selection_df <- filter(summary_df, GEO_number=="GSE83894") # User select GEO identifier
se <- create_summarized_experiment_object(geo_selection_df) # Create the Summarized Experiment

