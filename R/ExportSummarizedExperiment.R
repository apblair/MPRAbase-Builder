library(dbplyr)
library(DBI)
library(RSQLite)
library(dplyr)
library(SummarizedExperiment)
library(tidyr)

ExportSummarizedExperiment <- function(GEOID, summary){
    ###  Check user input
    ### user input a GEOID
    # GEOID="GSE83894"  ### taking this GSE83894 as an example
    
    #connecting to SQL database in R
    con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "../data/mprabase_v4_6.db")
    
    ## read from db to dataframe
    
    ### read data from selected GEO_number
    sqlStatement_seltable <- paste("SELECT * FROM datasets 
    INNER JOIN designed_library ON datasets.datasets_id = designed_library.datasets_id 
    INNER JOIN  sample ON designed_library.library_id=sample.library_id 
    INNER JOIN  library_sequence ON sample.library_id=library_sequence.library_id 
    INNER JOIN element_score ON library_sequence.library_element_id=element_score.library_element_id 
    WHERE datasets.GEO_number=","'",GEOID,"'",sep="")
    sel_table<- dbGetQuery(con, sqlStatement_seltable)
    
    #### generate coldata for grange from selected GEO_number
    sqlStatement_coldata  <- paste("SELECT datasets.PMID, datasets.GEO_number,datasets.labs FROM datasets
    WHERE datasets.GEO_number=","'",GEOID,"'",sep="")
    colData=  dbGetQuery(con,sqlStatement_coldata )
    
    ####remove duplicated record
    testing_colnames_1 <- sel_table[!duplicated(as.list(sel_table))]
    testing_colnames_2 <-  testing_colnames_1[!duplicated(testing_colnames_1$element_sample_id),]
    testing_colnames_2 <- subset(testing_colnames_2, select= -c(library_element_name.1, sample_id.1))
    coord_all_table <- separate(data = testing_colnames_2, col = element_coordinate, into= c("seqnames","start","end"))
    
    ##### export Grange
    gr = GRanges(seqnames = as.character(unlist(coord_all_table$seqnames)), 
    ranges = IRanges(as.numeric(unlist(coord_all_table$start)),
    end=as.numeric(unlist(coord_all_table$end)),
    names = unlist(coord_all_table$element_sample_id)))
    
    #### making ColData by dropping genomic-region columns

    #coord_all_table$start=as.numeric(coord_all_table$start)
    #coord_all_table$end=as.numeric(coord_all_table$end)
    
    mcols(gr) = subset(coord_all_table,select=-c(seqnames,start,end,sample_id,element_sample_id))
    
    #### making SummarizedExperiment
    SE1=SummarizedExperiment(assays=list(ratio=(as.matrix(coord_all_table$score))),
                             rowRanges=gr,
                             colData=colData)
    metadata(SE1)=summary
    return(SE1)
}