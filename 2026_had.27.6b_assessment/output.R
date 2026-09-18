## Extract results of interest, write TAF output tables

## Before:
## After:


library(tidyverse)
library(stockassessment)
library(viridis)
library(data.table)
library(icesTAF)

source("utilities_intercatch WGCSE.R")
source("utilities_plot_functions.R")

mkdir("output")
mkdir("output/tables")
source("output_tables.R")

mkdir("output/figures")
source("output_figures.R")

mkdir("output/figures/forecast")
source("output_forecast_summary.R")

mkdir("output/figures/adg_extra")
source("output_compare_last_advice.R")

