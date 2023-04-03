pacman::p_load(biobricks, tidyverse, ggplot2, tictoc, arrow)

# LOAD PUBCHEM
pc <- biobricks::bbload("pubchem")
pc <- pc$compound_sdf

# HOW MANY ROWS?
nrow(pc) / 1e9

# A GLIMPSE
pctop <- pc |> head(1000) |> collect() |> tibble()
unique(pctop$property)

# GET MOLECULAR WEIGHTS!
tic()
mw <- pc |> filter(property == "PUBCHEM_MOLECULAR_WEIGHT")
mw <- mw |> mutate(value = as.integer(round(as.numeric(value))))
mw <- mw |> group_by(value) |> summarize(cnt=n())
mw <- mw |> collect()
toc()

# HOW MANY MOLECULAR WEIGHTS?
total = sum(mw$cnt)

# TOP 99% MOLECULAR WEIGHTS
mw <- mw |> arrange(value) |> mutate(percentile = cumsum(cnt) / total)
mw99 <- mw |> filter(percentile > 0.98) |> pull(value) |> first()

# PLOT
df <- mw |> filter(value < mw99)
g <- ggplot(df, aes(x=value, y=cnt)) + geom_col() 
ggsave("pubchem_mol_weights.png")
