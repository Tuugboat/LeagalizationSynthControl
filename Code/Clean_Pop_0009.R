#############################
# Author: Robert Petit
# Desc: We need out population data in the format (STFIPS, NAME, YEAR, TOTALPOP)
# This will later be extended by Pop_1019 and joined with the drug summary
#############################

read.csv(here("Data/st-est00int-agesex.csv")) %>%
  # See code book; age=999 is total, sex=0 is total, state=0 is the U.S.
   
  filter(AGE==999, SEX==0, STATE!=0) %>%
  
  select(STATE, NAME, starts_with("POPESTIMATE")) %>%
  
  # Gives a seperate entry for each year. names_prefixed is the removed text
  pivot_longer(cols=starts_with("POPESTIMATE"), names_prefix="POPESTIMATE", names_to = "YEAR", values_to = "TOTALPOP") %>%
  
  # For whatever reason, the census includes 2010 in this set, leaving us with TWO 2010s.
  filter(YEAR != 2010) %>%
  
  write.csv(here("Data/Pop_ByState_0009.csv"))
