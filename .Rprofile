source("renv/activate.R")

suppressPackageStartupMessages(
  pacman::p_load(
    dplyr,
    conflicted
  )
)

pacman::p_load_gh('ChrisDonovan307/projecter')

conflicted::conflicts_prefer(
  dplyr::filter(),
  dplyr::select(),
  .quiet = TRUE
)

options(
  scipen = 999,
  pillar.print_max = 950,
  pilar.print_min = 950
)

source('startup.R')

cat("\n.Rprofile loaded")
