#' rename_variables.R
#'
#' contributors: @lachlandeer, @julianlanger, @alexjenni, @mventu
#'
#' Select desired subsample from CPS dataset
#'

# Libraries
library(optparse)
library(haven)
library(readr)
library(dplyr)

# CLI parsing
option_list = list(
  make_option(c("-d", "--data"),
              type = "character",
              default = NULL,
              help = "csv file name",
              metavar = "character"),
  make_option(c("-s", "--subset"),
              type = "character",
              default = NULL,
              help = "A condition to select a subset of data",
              metavar = "character"),
  make_option(c("-o", "--out"),
              type = "character",
              default = "out.csv",
              help = "output file name [default = %default]",
              metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call. = FALSE)
}
if (is.null(opt$subset)){
  print_help(opt_parser)
  stop("A subsetting condition must be supplied", call. = FALSE)
}

# Load data
print("Loading data")
cps_data <- read_csv(opt$data)

# Rename variables
print("Collapse log wage")
cps_data_subsample <- cps_data %>%
    group_by(year, miami) %>% 
    filter(opt$subset) %>% 
    summarise(log_weekly_wage=mean(log_weekly_wage))

# Save data
print("saving output")
write_csv(cps_data_subsample, opt$out)
