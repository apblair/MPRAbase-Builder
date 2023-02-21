library(dbplyr)
library(DBI)
library(RSQLite)
library(dplyr)
library(SummarizedExperiment)
library(tidyr)

ExportSummarizedExperiment <- function(summary){
    ###  Check user input
    
    # read filtered summary file from user input
    #summary=read.csv("filter_summary.csv",header=T)
   

    
    #connecting to SQL database in R
    con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "../data/mprabase_v4_6.db")

    SP_n=nrow(summary) ## number of samples

## loop over all samples in the summary file
    for(i in 1:SP_n) {

    PMID=summary$PMID[i]
    SPID=summary$sample_name[i]
    #### read info for metaData (PMID,GEO_number,SRP_number,labs,Organism,Cell_line_tissue,sample_name,description,DNA_RNA_reps,element_position,rep_type,number_of_elements,Reference)
    sqlStatement_coldata <- paste(" SELECT datasets.PMID, datasets.GEO_number, datasets.SRP_number, datasets.labs, sample.Library_strategy, sample.Organism, sample.Cell_line_tissue,sample.sample_name, sample.description,sample.DNA_RNA_reps, sample.element_position,sample.rep_type, designed_library.number_of_elements, datasets.Reference FROM datasets INNER JOIN designed_library ON datasets.datasets_id = designed_library.datasets_id INNER JOIN  sample ON designed_library.library_id=sample.library_id WHERE  datasets.PMID =","'",PMID,"'","AND  sample.sample_name=","'",SPID,"'",sep="")
   
    metaData =  dbGetQuery(con,sqlStatement_coldata)
    colData={}
    ## generate colData for each rep  
    for (j in 1:metaData$DNA_RNA_reps){
    colData=rbind(colData,data.frame(REP=j,condition=metaData$description,rep_type=metaData$rep_type,Organism=metaData$Organism,Cell_line_tissue=metaData$Cell_line_tissue))
     }
    ### read data for assay (ActivityScore)
    sqlStatement_assay <- paste("  SELECT library_sequence.library_element_name, library_sequence.element_coordinate, library_sequence.sequence, library_sequence.genome_build, element_rep_score.REP1, element_rep_score.REP2, element_rep_score.REP3 FROM datasets  INNER JOIN designed_library ON datasets.datasets_id = designed_library.datasets_id INNER JOIN sample ON designed_library.library_id = sample.library_id INNER JOIN  element_rep_score ON sample.sample_id=element_rep_score.sample_id  INNER JOIN library_sequence ON library_sequence.library_element_id = element_rep_score.library_element_id WHERE  datasets.PMID =","'",PMID,"'","AND  sample.sample_name=","'",SPID,"'",sep="")   
    assay_table<- dbGetQuery(con, sqlStatement_assay)



    ###need to add if it is genomic coordinates
    ## making Grange
    coord_all_table <- separate(data = assay_table, col = element_coordinate, into= c("seqnames","start","end"))
    gr = GRanges(seqnames = as.character(unlist(coord_all_table$seqnames)), 
    ranges = IRanges(as.numeric(unlist(coord_all_table$start)),
    end=as.numeric(unlist(coord_all_table$end)),
    names = unlist(coord_all_table$library_element_name)))
    mcols(gr) = subset(coord_all_table,select=c(genome_build,sequence))
 
    
    
    #### making SummarizedExperiment
    SE1=SummarizedExperiment(assays=list(ActivityScore=(cbind(coord_all_table$REP1,coord_all_table$REP2,coord_all_table$REP3))),
                             rowRanges=gr,
                             colData=colData)
    metadata(SE1)=metaData
  ## for muliple sample, return user a SummarizedExperiment list
   if(i <=1) { SE=SE1 
   SE=list(SE) } 
   else {SE = append(SE, SE1)}
}

}
