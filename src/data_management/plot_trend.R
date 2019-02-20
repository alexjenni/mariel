rm(list = ls())

library('ggplot2')
library(optparse)
library(haven)
library(readr)
library(dplyr)

cps_ready <- read_csv("../../out/data/cps_trend_no_high_school.csv")

ggplot(cps_ready) +
  geom_point(aes(x = year, y = log_weekly_wage, colour = miami, group = miami), size = 4) +
  geom_line(aes(x = year, y = log_weekly_wage, colour = miami, group = miami), size = 2) +
  geom_vline(aes(xintercept = 1980)) +
  scale_x_continuous(name="year", breaks=seq(1975,1995,1)) +
  theme_classic()




