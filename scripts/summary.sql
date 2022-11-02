SELECT datasets.PMID, datasets.GEO_number,datasets.labs, designed_library.number_of_elements, sample.Library_strategy,sample.Organism,sample.Cell_line_tissue,sample.DNA_RNA_reps,sample.sample_id
FROM datasets
INNER JOIN designed_library 
ON datasets.datasets_id = designed_library.datasets_id
INNER JOIN  sample
ON designed_library.library_id=sample.library_id