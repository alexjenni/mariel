#' estimate_did.R
#'
#' contributors: @alexjenni
#'
#' Run a DiD regression on a (subset of) data
#'

# Libraries
library(optparse)
library(rjson)
library(readr)
library(rlist)
library(dplyr)
library(lfe)

# CLI parsing
option_list = list(
   make_option(c("-d", "--data"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
   make_option(c("-s", "--subset"),
               type = "character",
               default = NULL,
               help = "A condition to select a subset of data",
               metavar = "character"),
   make_option(c("-c", "--control"),
               type = "character",
               default = NULL,
               help = "A condition to select the control group",
               metavar = "character"),
	make_option(c("-o", "--out"),
               type = "character",
               default = "out.rds",
               help = "output file name [default = %default]",
               metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
 print_help(opt_parser)
 stop("Input data must be provided", call. = FALSE)
}

# Load Subset Condition
if (!is.null(opt$subset)){
  data_filter <- fromJSON(file = opt$subset)
}

if (!is.null(opt$control)){
  control_filter <- fromJSON(file = opt$control)
}

# Load data
print("Loading data")
df <- read_csv(opt$data)

# Prepare data for diff-in-diff regression
# Optional filters
if (!is.null(opt$subset)){
  df <- df %>%
    filter(eval(parse(text = data_filter$KEEP_CONDITION)))
}
if (!is.null(opt$control)){
  df <- df %>%
    filter(eval(parse(text = control_filter$KEEP_CONDITION)) | miami == TRUE)
}
# Generate year categories
labels <- rep(c("1977-1979","1981-83","1984-86","1987-89","1990-92"), each = 3)
reg_data <- df %>%
  mutate(year_group = factor(df$year,c(1977:1979,1981:1992),labels)) %>%
  filter(year!=1980 & year >= 1977 & year <= 1992) %>%
  select(weights,year,msa_code,year_group,log_weekly_wage,miami)

# Construct Formula
dep_var <- "log_weekly_wage"
exog <- "miami*year_group | msa_code + year"
reg_formula <- as.formula(paste(dep_var, " ~ ", exog, sep=""))
print(reg_formula)

# Run Diff-in-diff
did_model <- felm(reg_formula, reg_data) # , weights = reg_data$weights
summary(did_model,robust=TRUE)

# Save output
list.save(did_model, opt$out)
