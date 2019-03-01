#' plot_trend.R
#'
#' contributors: @alexjenni, @miriam
#'
#' Plot trend in mean log wage
#'

library(optparse)
library(readr)
library(dplyr)
library(ggplot2)

# CLI parsing
option_list = list(
   make_option(c("-e", "--data_miami"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
   make_option(c("-p", "--data_control"),
               type = "character",
               default = NULL,
               help = "a csv file name",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "figure_out.pdf",
                help = "output file name [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data_miami)){
  print_help(opt_parser)
  stop("Input data for Miami must be provided", call. = FALSE)
}
if (is.null(opt$data_control)){
  print_help(opt_parser)
  stop("Input data for control group must be provided", call. = FALSE)
}

# Load data
print("Loading data")
miami <- read_csv(opt$data_miami)
control <- read_csv(opt$data_control)

# Create label for control group
if (grepl("not_miami",opt$data_control)){
  lab_control <- "All other US cities"
} else if(grepl("card",opt$data_control)) {
  lab_control <- "Atlanta, LA, Houston and Tampa"
} else {
  lab_control <- "Control group"
}
cps_ready <- union(miami, control)
y_pos <- min(cps_ready$log_weekly_wage, na.rm=T) + 0.02

# Plot graph miami vs. control group
print("Plot trend")
cps_ready$miami <- ordered(cps_ready$miami,
                           labels = c(lab_control, "Miami"))
cps_trend <- ggplot(cps_ready) +
  geom_point(aes(x = year, y = log_weekly_wage, colour = miami), size = 4) +
  geom_line(aes(x = year, y = log_weekly_wage, colour = miami, group = miami), size = 2) +
  geom_vline(aes(xintercept = 1980)) +
  scale_x_continuous(name="year", breaks=seq(1975,1995,1)) +
  scale_color_manual(values=c("coral1","navyblue")) +
  theme_classic() +
  labs(y = "Mean Log Weekly Wage ($)",
       x = "Year",
       color = "MSA\n") +
  annotate(geom="text",x=1979,y=y_pos,label="Mariel Boatlift")

print("Save trend")
ggsave(opt$out, cps_trend, width = 30, height = 20, units = "cm")
