#############################
# Author: Robert Petit
# Desc: Some working/reference scripts that are useful for this project
# No code here will directly generate any information, figures, or tables in the project
# If it is being extended, perusing here before starting work is a good idea
#############################


# Good example of summarizing. This is passed to kable for the most key important summary table
USE <- read.csv(here("Data/Usage_ByStateYear.csv")) %>% 
  summarize(across(.cols=starts_with("Rat"),list (mean=mean, sd=sd))) %>%
  select(starts_with("Rat")) %>%
  pivot_longer(cols = everything(),
               names_to = c(".value", "statistic"), names_sep="_")

read.csv(here("Data/Usage_ByStateYear.csv")) %>% colnames
