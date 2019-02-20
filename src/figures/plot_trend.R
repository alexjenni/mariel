#' plot_trend.R
#'
#' contributors: @alexjenni, @miriam
#'
#' Plot trend in mean log wage
#'

library(optparse)
library(readr)
library(dplyr)
library(rlist)
library(ggplot2)

# CLI parsing
option_list = list(
   make_option(c("-d", "--data"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.pdf",
                help = "output file name [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);
print(opt)

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("Input data must be provided", call. = FALSE)
}

# Load data
print("Loading data")
miami <- read_csv(opt$data)
not_miami <- read_csv(opt$data)

cps_ready <- union(miami, not_miami)

cps_ready$miami <- ordered(cps_ready$miami,
                           labels = c("All other US cities", "Miami"))

cps_trend_no_high_school <- ggplot(cps_ready) +
  geom_point(aes(x = year, y = log_weekly_wage, colour = miami), size = 4) +
  geom_line(aes(x = year, y = log_weekly_wage, colour = miami, group = miami), size = 2) +
  geom_vline(aes(xintercept = 1980)) +
  scale_x_continuous(name="year", breaks=seq(1975,1995,1)) +
  scale_color_manual(values=c("red","blue")) +
  theme_classic()

ggsave(opt$out, cps_trend_no_high_school)
