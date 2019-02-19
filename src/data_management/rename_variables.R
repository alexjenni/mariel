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
print("Rename and generate variables")
cps_data <- cps_data %>%
    setNames(tolower(names(cps_data))) %>% 
    select(year,
           cpi99,
           age,
           statefip,
           msa_code=metarea,
           weights=asecwt,
           hispan,
           empstat,
           labforce,
           educ,
           weeks_worked=wkswork1,
           wage_inc = incwage)


# Generate variables
cps_data <- cps_data %>%
  mutate(miami= msa_code==5000) %>% 
  mutate(hispanic = hispan < 900 & hispan > 0) %>% 
  mutate(year = year -1) %>%  # corresponds to the previous year income
  mutate(educ_group=educ)

cps_data$educ_group[cps_data$educ<61] <- 1
cps_data$educ_group[cps_data$educ>=70 & cps_data$educ<75] <- 2
cps_data$educ_group[cps_data$educ>=80 & cps_data$educ<101] <- 3
cps_data$educ_group[cps_data$educ>=110] <- 4
cps_data$educ_group <- ordered(cps_data$educ_group,
  levels = c(1,2,3,4),
  labels = c("<12 years", "12 years", "13-15 years", ">15 years"))
cps_data <- cps_data %>%
  select(-educ)

# Account for missings
cps_data$hispanic[cps_data$hispan>900] <- NA


# Save data
print("saving output")
write_csv(cps_data, "out/data/cps_borjas_renamed.csv")
