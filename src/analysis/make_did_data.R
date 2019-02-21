#' make_did_data.R
#'
#' contributors: @alexjenni
#'
#' Prepare data for DiD estimation
#'

# Libraries
library(optparse)
library(dplyr)
library(readr)
library(rlist)

# CLI parsing
option_list = list(
  make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a csv file name",
                metavar = "character"),
  make_option(c("-c", "--control"),
                type = "character",
                default = "card",
                help = "indicator variable for the control group: 'card' or 'not_miami'",
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
 stop("Input data must be provided", call. = FALSE)
}

if (opt$control != "card" & opt$control != "not_miami"){
 print_help(opt_parser)
 stop("Control must be 'card' or 'not_miami'", call. = FALSE)
}

# Load data
print("Loading data")
df <- read_csv(opt$data)
if (opt$control == "card"){
  df <- df %>%
    filter(miami == TRUE | control_group == TRUE)
}


# Prepare data for diff-in-diff regression
labels <- rep(c("1977-1979","1981-83","1984-86","1987-89","1990-92"), each = 3)
reg_data <- df %>%
  mutate(year_group = factor(df$year,c(1977:1979,1981:1992),labels)) %>%
  filter(educ_group=="<12 years") %>%
  filter(year!=1980) %>%
  mutate(year=factor(year)) %>%
  select(weights,year,msa_code,year_group,miami,log_weekly_wage)

# Save data
print("saving output")
write_csv(reg_data, opt$out)
