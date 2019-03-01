#' table_did.R
#'
#' contributors: @lachlandeer, @julianlanger, @alexjenni
#'
#' Export table of did estimates
#'

# Libraries
library(optparse)
library(purrr)
library(stargazer)
library(rlist)

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
print("Loading estimates")
data <- file_list %>%
            map(list.load)

# Create Table
print("Exporting tables")
stargazer(data[[1]],
          data[[2]],
          initial.zero = TRUE,
          align = TRUE,
          style = "qje",
          title = "DiD Impact of the Marielitos on the wage of high school dropouts",
          dep.var.labels = "Log wage of high school dropouts",
          column.labels = c("Card placebo", "All cities"),
          covariate.labels = c("1981-1983","1984-1986","1987-1989","1990-1992"),
          omit.stat = c("rsq", "ser", "F", "N", "adj.rsq"),
          keep.stat = c(),
          nobs = FALSE,
          keep= c("TRUE"),
          report ="vcs",
          omit=c(1),
          df = FALSE,
          digits = 3,
          font.size = "scriptsize",
          notes = c("Robust standard errors are reported in parentheses.",
                    "All regressions include vectors of city and year fixed effects.",
                    "Sample of non-Hispanic men aged 25-59 without a high-school degree.",
                    "Card placebo group consists of four cities: Atlanta, Houston, Los Angeles and Tampa."),
          notes.append = FALSE,
          notes.align = "l",
          table.layout ="-dc-t-a-s=n",
          no.space = TRUE,
          type = "latex",
          out = opt$out
)
