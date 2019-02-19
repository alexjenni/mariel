#' rename_variables.R
#'
#' contributors: @lachlandeer, @julianlanger, @alexjenni
#'
#' Adds meaningful variable names to the original CPS data set
#'

# Libraries
library(optparse)
library(haven)
library(readr)
library(dplyr)

 # CLI parsing
# option_list = list(
#     make_option(c("-d", "--data"),
#                 type = "character",
#                 default = NULL,
#                 help = "csv dataset file name",
#                 metavar = "character"),
# 	make_option(c("-o", "--out"),
#                 type = "character",
#                 default = "out.csv",
#                 help = "output file name [default = %default]",
#                 metavar = "character")
# );
# 
# opt_parser = OptionParser(option_list = option_list);
# opt = parse_args(opt_parser);
# 
# if (is.null(opt$data)){
#   print_help(opt_parser)
#   stop("At least one argument must be supplied (input file).n", call. = FALSE)
# }

# Load data
print("Loading data")
# cps_data <- read_csv(opt$data)
cps_data <- read_csv("src/data/cps_77-93_men.csv")

# Rename variables
print("Rename variables")
cps_data <- cps_data %>%
              rename(non_oil = n,
                     oecd = o,
                     intermediate = i,
                     gdp_60 = rgdpw60,
                     gdp_85 = rgdpw85,
                     gdp_growth_60_85 = gdpgrowth,
                     pop_growth_60_85 = popgrowth,
                     inv_gdp = i_y,
                     school = school)

# Save data
print("saving output")
write_csv(mrw_data, opt$out)
