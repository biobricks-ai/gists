pacman::p_load(biobricks, tidyverse)

# LOAD PUBCHEM
pc <- bbload("pubchem")
ba <- pc$bioassay_concise |> collect() |> tibble()

nrow(ba)

# A GLIMPSE
ba |> 
  select(aid,pubchem_cid,property,value) |> 
  head()

# WHAT IS THE MOST TESTED COMPOUND?
topcid <- ba |> 
  group_by(pubchem_cid) |>
  summarise(aids = n_distinct(aid)) |> 
  arrange(desc(aids)) |>
  head(1) 

topcid

sprintf(
  "https://pubchem.ncbi.nlm.nih.gov/compound/%s", 
  topcid$pubchem_cid)

# WHAT ARE THE LARGEST ASSAYS BY # OUTCOMES?
cntdf <- ba |> 
  filter(property=="pubchem_activity_outcome") |>
  count(aid,value)

cntdf <- cntdf |> 
  group_by(aid) |> 
  mutate(tot = sum(n)) |> 
  ungroup()

pdf <- cntdf |> arrange(-tot) |> head(100)
httpgd::hgd()
ggplot(pdf, 
  aes(x=reorder(aid,tot), y=n, fill=value)) + 
  geom_bar(stat="identity", position="stack") + 
  coord_flip() + 
  theme_minimal() + 
  labs(x="Assay ID", y="Number of Outcomes")

