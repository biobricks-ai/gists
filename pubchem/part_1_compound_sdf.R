pacman::p_load(tidyverse, biobricks, ggplot2)

# LOAD PUBCHEM COMPOUND SDF TABLE
pc <- bbload("pubchem")$compound_sdf

# HOW MANY ROWS?
nrow(pc) / 1e9

# A GLIMPSE?
pc |> head(100) |> collect() |> tibble()

# WHAT ARE THE PROPERTIES?
props <- pc |> select(property) |> distinct()
props <- props |> pull(property,as_vector=FALSE)

# GET SOME MOLECULAR WEIGHTS?
mw <- pc |> filter(property == "PUBCHEM_MOLECULAR_WEIGHT") |> collect()

# too big for memory
process_pcfile <- function(pcfile){
  df <- arrow::read_parquet(pcfile, as_data_frame=FALSE) |> 
    filter(property == "PUBCHEM_MOLECULAR_WEIGHT") |> 
    collect()

  df |> mutate(value = as.integer(value)) |> count(value,sort=TRUE)
}

pacman::p_load(future)
future::plan(future::multisession(workers=6))
mwcounts <- pc$files |> furrr::future_map(process_pcfile)
