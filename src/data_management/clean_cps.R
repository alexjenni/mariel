#' rename_variables.R
#'
#' contributors: @alexjenni, @mventu
#'
#' Clean raw data set and add meaningful variable names
#'

# Libraries
library(optparse)
library(readr)
library(dplyr)

# CLI parsing
option_list = list(
  make_option(c("-d", "--data"),
              type = "character",
              default = NULL,
              help = "csv file name",
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
  stop("Could not find raw data (input file).n -see README", call. = FALSE)
}

# Load data
print("Loading data")
cps_data <- read_csv(opt$data)

# Rename variables
print("Rename and generate variables")
cps_data <- cps_data %>%
    setNames(tolower(names(cps_data))) %>%
    select(year,
           cpi99,
           age,
           statefip,
           labforce,
           msa_code=metarea,
           weights=asecwt,
           hispan,
           empstat,
           educ,
           weeks_worked=wkswork1,
           wage_inc = incwage,
           emp_type=classwkr)


# Generate variables
# Area Dummies
cps_data <- cps_data %>%
    mutate(miami= msa_code==5000) %>% # Miami
    mutate(control_group= (msa_code==520 | # Atlanta
                             msa_code==4480 | # Los Angeles
                             msa_code==3360 | # Houston
                             msa_code==8280)) # Tampa

# Education
cps_data <- cps_data %>%
    mutate(educ_group=educ)

cps_data$educ_group[cps_data$educ<61] <- 1
cps_data$educ_group[cps_data$educ>=70 & cps_data$educ<75] <- 2
cps_data$educ_group[cps_data$educ>=80 & cps_data$educ<101] <- 3
cps_data$educ_group[cps_data$educ>=110] <- 4
cps_data$educ_group <- ordered(cps_data$educ_group,
    levels = c(1,2,3,4),
    labels = c("<12 years", "12 years", "13-15 years", ">15 years"))


# Hispanic ethnicity
cps_data <- cps_data %>%
    mutate(hispanic = hispan < 900 & hispan > 0)
cps_data$hispanic[cps_data$hispan>900] <- NA


# Wage variables
cps_data <- cps_data %>%
    mutate(weekly_wage = wage_inc*cpi99/weeks_worked) %>% # adjust for inflation (1999 prices)
    mutate(weekly_wage = na_if(weekly_wage, NaN)) %>%
    mutate(weekly_wage = na_if(weekly_wage, Inf)) %>%
    mutate(log_weekly_wage = log(weekly_wage))


# year adjustement
cps_data <- cps_data %>%
    mutate(year = year -1)  # corresponds to the previous year income

# Restrictions
cps_data <- cps_data %>%
    filter(weekly_wage > 0) %>%                             # keep men with positive hourly wages
    filter(age >=25 & age < 60) %>%
    filter(hispanic==0) %>%                                 # keep non-hispanic men
    filter(emp_type!=10 & emp_type!=13 & emp_type!=14) %>%  # drop self-employed
    filter(labforce==2)  %>%                                # drop men outside of the labor force
    filter(empstat !=1)  %>%                                 # drop members of army force
    filter(weights > 0)

# Trim 1% top and 1% bottom earners
cps_data <- cps_data %>%
    filter(weekly_wage > quantile(cps_data$weekly_wage, 0.01) &
          weekly_wage < quantile(cps_data$weekly_wage, 0.99))

# Drop variables
cps_data <- cps_data %>%
    select(-educ, -hispan, -hispanic, -emp_type, -empstat, -labforce)

# Save data
print("saving output")
write_csv(cps_data, opt$out)
