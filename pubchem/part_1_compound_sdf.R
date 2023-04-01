pacman::p_load(tidyverse, biobricks, ggplot2)

pc <- bbload("pubchem")
pc <- pc$compound_sdf 

# HOW MANY ROWS?
nrow(pc) / 1e9

# A GLIMPSE?
pc |> head(100) |> collect() |> tibble()

# WHAT ARE THE PROPERTIES?
props <- pc |> select(property) |> distinct()
props <- props |> pull(property,as_vector=FALSE)

# GET SOME MOLECULAR WEIGHTS?
mw <- pc |> 
  filter(property == "PUBCHEM_MOLECULAR_WEIGHT") |> 
  select(id,value) |> collect() |> tibble()
