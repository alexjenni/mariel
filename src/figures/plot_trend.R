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
   make_option(c("-d", "--data_not_miami"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
   make_option(c("-e", "--data_miami"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
   make_option(c("-p", "--data_placebo"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.pdf",
                help = "output file name [default = %default]",
                metavar = "character"),
	make_option(c("-l", "--out_placebo"),
	            type = "character",
	            default = "out.pdf",
	            help = "output file name [default = %default]",
	            metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);
print(opt)

if (is.null(opt$data_not_miami)){
  print_help(opt_parser)
  stop("Input data must be provided", call. = FALSE)
}
if (is.null(opt$data_miami)){
  print_help(opt_parser)
  stop("Input data must be provided", call. = FALSE)
}
if (is.null(opt$data_placebo)){
  print_help(opt_parser)
  stop("Input data must be provided", call. = FALSE)
}
# Load data
print("Loading data")
miami <- read_csv(opt$data_miami)
not_miami <- read_csv(opt$data_not_miami)
placebo <- read_csv(opt$data_placebo)


#Generate graph miami vs not miami
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

ggsave(opt$out, cps_trend_no_high_school, width = 30, height = 20, units = "cm")

#Generate graph miami vs placebo
cps_ready_placebo <- union(miami, placebo)

cps_ready_placebo$miami <- ordered(cps_ready_placebo$miami,
                           labels = c("Atlanta, LA, Houston, Tampa", "Miami"))

cps_trend_no_high_school_placebo <- ggplot(cps_ready_placebo) +
  geom_point(aes(x = year, y = log_weekly_wage, colour = miami), size = 4) +
  geom_line(aes(x = year, y = log_weekly_wage, colour = miami, group = miami), size = 2) +
  geom_vline(aes(xintercept = 1980)) +
  scale_x_continuous(name="year", breaks=seq(1975,1995,1)) +
  scale_color_manual(values=c("red","blue")) +
  theme_classic()

ggsave(opt$out_placebo, cps_trend_no_high_school_placebo, width = 30, height = 20, units = "cm")
