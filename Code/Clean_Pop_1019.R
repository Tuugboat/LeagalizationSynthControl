#############################
# Author: Robert Petit
# Desc: We need out population data in the format (STFIPS, NAME, YEAR, TOTALPOP)
# This will later be extended by Pop_0009 and joined with the drug summary
#############################

read.csv(here("Data/nst-est2019-alldata.csv")) %>% 
  # See code book; state=0 is the U.S. and region data
  filter(STATE!=0) %>%
  
  select(STATE, NAME, starts_with("POPESTIMATE")) %>%
  
  # Gives a seperate entry for each year. names_prefixed is the removed text
  pivot_longer(cols=starts_with("POPESTIMATE"), names_prefix="POPESTIMATE", names_to = "YEAR", values_to = "TOTALPOP") %>%
  
  write.csv(here("Data/Pop_ByState_1019.csv"))
