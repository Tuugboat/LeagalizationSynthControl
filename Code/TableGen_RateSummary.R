#############################
# Author: Robert Petit
# Desc: It's late so we are breaking styling rules. There are four summaries, which we build and combine at the end
# Following this, we dump it into a kable table and output it. 
#############################

NationWide_Pre <- read.csv(here("Data/Usage_ByStateYear.csv")) %>% 
  
  # Pot legalization was late 2012 in CO
  filter(YEAR<=2012, STFIPS!=8) %>%
  
  # Summary 
  summarize(across(.cols=starts_with("Rat"),list (mean=mean, sd=sd))) %>%
  select(starts_with("Rat")) %>%
  
  # 1 row for means, 1 row for sd, column for each drug
  pivot_longer(cols = everything(),
               names_to = c(".value", "statistic"), names_sep="_") %>%
  mutate(SetID = "Nationwide: Pre")

NationWide_Post <- read.csv(here("Data/Usage_ByStateYear.csv")) %>%
  filter(YEAR>2012, STFIPS!=8) %>%
  summarize(across(.cols=starts_with("Rat"),list (mean=mean, sd=sd))) %>%
  select(starts_with("Rat")) %>%
  pivot_longer(cols = everything(),
               names_to = c(".value", "statistic"), names_sep="_") %>%
  mutate(SetID = "Nationwide: Post")

CO_Pre <- read.csv(here("Data/Usage_ByStateYear.csv")) %>% 
  filter(YEAR<=2012, STFIPS==8) %>%
  summarize(across(.cols=starts_with("Rat"),list (mean=mean, sd=sd))) %>%
  select(starts_with("Rat")) %>%
  pivot_longer(cols = everything(),
               names_to = c(".value", "statistic"), names_sep="_") %>%
  mutate(SetID = "CO: Pre")

CO_Post <- read.csv(here("Data/Usage_ByStateYear.csv")) %>%
  filter(YEAR>2012, STFIPS==8) %>%
  summarize(across(.cols=starts_with("Rat"),list (mean=mean, sd=sd))) %>%
  select(starts_with("Rat")) %>%
  pivot_longer(cols = everything(),
               names_to = c(".value", "statistic"), names_sep="_") %>%
  mutate(SetID = "CO: Post")

Full <- rbind(NationWide_Pre, NationWide_Post, CO_Pre, CO_Post) %>%
  select(SetID, statistic, starts_with("Rat")) %>%
  mutate(statistic = recode(statistic, "mean"="Mean", "sd"="Std. Dev.")) %>%
  mutate(across(where(is.numeric), round, digits=2))

Full %>%
  select(-SetID) %>%
  kbl(caption="Summary of Admission Rates, CO Seperated",
      booktabs=T,
      format="latex",
      label="RatSum",
      col.names=c("", "Alcohol", "Cocaine", "Marijuana", "Heroin", "Opiates", "BZD", "All Non-Marijuana")) %>%
  kable_styling(latex_options=c("striped", "hold_position", "condensed")) %>%
  
  footnote(general = c("Units are admissions per year, per 100,000 people", "BZD is Benzodiazepine")) %>%
  
  pack_rows(index = table(fct_inorder(Full$SetID))) %>%
  
  write_lines(here("Tables/Table_RatSum.tex"))

