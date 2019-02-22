#' compute_wage_trend.R
#'
#' contributors:  @alexjenni
#'
#' Compute the average log wage by year for a subset of the data
#'

# Libraries
library(optparse)
library(rjson)
library(readr)
library(dplyr)

# CLI parsing
option_list = list(
  make_option(c("-d", "--data"),
              type = "character",
              default = NULL,
              help = "csv file name",
              metavar = "character"),
  make_option(c("-s1", "--subset1"),
              type = "character",
              default = NULL,
              help = "A first condition to select a subset of data",
              metavar = "character"),
  make_option(c("-s2", "--subset2"),
              type = "character",
              default = NULL,
              help = "A second condition to select a subset of data",
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
if (is.null(opt$subset1) | is.null(opt$subset2)){
  print_help(opt_parser)
  stop("Two subsetting conditions must be supplied", call. = FALSE)
}

# Load data
print("Loading data")
cps_data <- read_csv(opt$data)

# Load Subset Condition
data_filter1 <- fromJSON(file = opt$subset1)
data_filter2 <- fromJSON(file = opt$subset2)

# Filter and collapse data set
print("Collapse log wage")
cps_data_subsample <- cps_data %>%
    group_by(year, miami) %>%
    filter(eval(parse(text = data_filter1$KEEP_CONDITION))) %>%
    filter(eval(parse(text = data_filter2$KEEP_CONDITION))) %>%
    mutate(tot_log_weekly_wage = weights * log_weekly_wage) %>%     # use survey weights
    summarise(log_weekly_wage=mean(log_weekly_wage),
              log_weekly_wage_wgt=mean(tot_log_weekly_wage)/mean(weights),
              n = n())

# Save data
print("saving output")
write_csv(cps_data_subsample, opt$out)
