pacman::p_load(biobricks, tidyverse)

# load 'variant_summary' table from clinvar database
# select rsid, phenotype and significance columns
cv = bbload('clinvar')$variant_summary |> collect() |> 
  select(`RS (dbSNP)`, PhenotypeList, ClinicalSignificance) |>
  rename(rsid=1, pheno=2, signi=3)

# unnest the table so there is at most one pheno/signi per row.
cv <- cv |> mutate(pheno = str_split(pheno, "\\|")) |> unnest(pheno)
cv <- cv |> mutate(signi = str_split(signi, "\\|")) |> unnest(signi)

andme23 <- readr::read_tsv('./23me.txt',
  comment = '#', col_names = c('rsid','id','chr','pos'))

# remove the 'rs' prefix and make `rsid` numeric
andme23 <- andme23 |> mutate(rsid = as.numeric(gsub("rs","",rsid)))

# pathogenic enrichment
cv <- cv |> mutate(has_rsid = rsid %in% andme23$rsid)
cv <- cv |> filter(signi == 'Pathogenic')
cv |> group_by(pheno) |> 
  summarize(cnt=n(),mycnt=sum(has_rsid)) |> ungroup() |>
  mutate(enrichment = mycnt/cnt) |>
  filter(cnt>100) |> arrange(desc(enrichment))
