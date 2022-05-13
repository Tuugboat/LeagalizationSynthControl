read.csv(here("Data/st-est00int-agesex.csv")) %>% 
  # For whatever reason, the census includes 2010 in this set, leaving us with TWO 2010s. 
  filter(SEX==0, STATE != 0) %>%
  mutate(AGEGRP = ifelse(AGE<18, 1, 0),
         AGEGRP=ifelse((AGE>=18 & AGE < 25), 2, AGEGRP),
         AGEGRP=ifelse((AGE>=25 & AGE < 65), 3, AGEGRP),
         AGEGRP=ifelse((AGE>=65 & AGE < 999), 4, AGEGRP),
         AGEGRP=ifelse(AGE>=999, 999, AGEGRP)) %>%
  select(STATE, AGEGRP, starts_with("POPESTIMATE")) %>%
  group_by(STATE, AGEGRP) %>%
  summarise(across(starts_with("POPESTIMATE"), sum)) %>%
  
  # We need to reshape our data frame so that we have (STATE, YEAR, GRP1, GRP2, GRP 3, GRP 4, GRP 999)
  pivot_longer(cols=starts_with("POPESTIMATE"), names_prefix="POPESTIMATE", names_to = "YEAR", values_to = "TOTALPOP") %>%
  
  
  pivot_wider(id_cols=c(STATE, YEAR), names_from = AGEGRP, names_prefix = "POPGRP", values_from = TOTALPOP) %>%
  
  # Calc the percentages
  mutate(P017 = POPGRP1/POPGRP999,
         P1824 = POPGRP2/POPGRP999,
         P2565 = POPGRP3/POPGRP999,
         P65 = POPGRP4/POPGRP999) %>%
  select(STATE, YEAR, P017, P1824, P2565, P65) %>%
  # For whatever reason, the census includes 2010 in this set, leaving us with TWO 2010s.
  filter(YEAR != 2010) %>%
  write.csv(here("Data/PopPercent_0009.csv"))
  