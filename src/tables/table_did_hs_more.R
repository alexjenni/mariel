#' table_did.R
#'
#' contributors: @lachlandeer, @julianlanger, @alexjenni
#'
#' Export table of did estimates
#'

# Libraries
library(optparse)
library(rlist)
library(magrittr)
library(purrr)
library(stargazer)

# CLI parsing
option_list = list(
   make_option(c("-fp", "--filepath"),
               type = "character",
               default = NULL,
               help = "A directory path where models are saved",
               metavar = "character"),
   make_option(c("-m", "--models"),
               type = "character",
               default = NULL,
               help = "A regex of the models to load",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.tex",
                help = "output file name [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$filepath)){
 print_help(opt_parser)
 stop("Input filepath must be provided", call. = FALSE)
}
if (is.null(opt$models)){
 print_help(opt_parser)
 stop("A regex of model names must be provided", call. = FALSE)
}

# Load Files
dir_path  <- opt$filepath
f_names   <- opt$models
models    <- paste0(dir_path, f_names)
file_list <- Sys.glob(models)


# Load into a list
data <- file_list %>%
            map(list.load)


# Load into a list
data <- file_list %>%
  map(list.load)

# Create Table
stargazer(data[[1]],
          data[[2]],
          initial.zero = TRUE,
          align = FALSE,
          style = "qje",
          title = "DiD Impact of the Marielitos on the wage of high school graduates",
          dep.var.labels = "Log wage of high school graduates",
          column.labels = c("Card placebo", "All cities"),
          covariate.labels = c("1981-1983","1984-1986","1987-1989","1990-1992"),
          omit.stat = c("rsq", "ser", "F", "N", "adj.rsq"),
          keep.stat = c(),
          nobs = FALSE,
          report ="vcs",
          keep= c("TRUE"),
          omit=c(1),
          df = FALSE,
          digits = 3,
          font.size = "scriptsize",
          notes = c("Robust standard errors are reported in parentheses.",
                    "All regressions include vectors of city and year fixed effects.",
                    "Card placebo group consists of men in four cities: Atlanta, Houston, Los Angeles and Tampa."),
          notes.append = FALSE,
          notes.align = "l",
          table.layout ="-dc-t-a-s=n",
          no.space = FALSE,
          type = "latex",
          out = opt$out
)