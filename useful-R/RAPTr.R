library(devtools); 
devtools::install_github('cargomoose/raptR')
library(raptR)
raptR()

devtools::install_github('cargomoose/raptR')
raptR::raptR()

devtools::install_github('rstudio/DT')
library(DT)

if (!require("devtools"))
  install.packages("devtools")
devtools::install_github("rstudio/shiny")

devtools::install_github("rstudio/httpuv")

update.packages(ask = FALSE)


options(repos = 'http://vnijs.github.io/radiant_miniCRAN/')
install.packages("radiant")
library(radiant)
radiant("marketing")
# need to upgrade shiny to >= 0.12.1
