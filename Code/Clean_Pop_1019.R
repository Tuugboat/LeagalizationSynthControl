#############################
# Author: Robert Petit
# Desc: We need out population data in the format (STFIPS, NAME, YEAR, TOTALPOP)
# This will later be extended by Pop_0009 and joined with the drug summary
#############################

read.csv(here("Data/sc-est2019-agesex-civ.csv")) %>% 
  # See code book; state=0 is the U.S. and region data
  filter(AGE==999, SEX==0, STATE!=0) %>%
  
  select(STATE, NAME, starts_with("POPEST")) %>%
  
  # Gives a seperate entry for each year. names_prefixed is the removed text
  pivot_longer(cols=starts_with("POPEST"), names_prefix="POPEST", names_to = "YEAR", values_to = "TOTALPOP") %>%
  
  # For whatever reason, the columns all have _CIV at the end of them. 
  # It's easier to just rowwise mutate than it is to write a regex for the pivot table
  rowwise() %>%
  mutate(YEAR = as.numeric(str_remove(YEAR, "_CIV"))) %>%
  ungroup %>%
  
  write.csv(here("Data/Pop_ByState_1019.csv"))
