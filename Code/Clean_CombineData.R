#############################
# Author: Robert Petit
# Desc: We have 4 files in the format:
# (STFIPS, ADMYR, AdmAlc, AdmCoc, AdmMar, AdmHer, AdmOpi, AdmPCP, AdmHal, AdmBen, AdmNMJ)
# And one file in the format (STATE, NAME, TOTALPOP)
# This rbinds the 4 files, then joins them with the totalpop and state names
#############################

POPS <- Sys.glob(here("Data/Pop_*")) %>%
  lapply(read_csv) %>%
  bind_rows %>%
  mutate(STFIPS = STATE) %>%
  select(STFIPS, NAME, YEAR, TOTALPOP)

Sys.glob(here("Data/SummarizedTEDS_*.csv")) %>%
  lapply(read_csv) %>%
  bind_rows %>%
  mutate(YEAR = ADMYR) %>%
  select(-ADMYR) %>%
  
  #We drop the states we don't worry about
  filter(STFIPS>=1, STFIPS<=56) %>%
  
  #Manual exemptions due to no data reporting
  filter(STFIPS != 1, STFIPS != 2, STFIPS != 11, STFIPS != 28, STFIPS != 41, STFIPS != 45, STFIPS != 53, STFIPS != 54) %>%
  
  left_join(POPS, by=c("STFIPS", "YEAR")) %>%
  
  # Finally, calculate our rates
  rowwise() %>%
  mutate(
    RatAlc = (AdmAlc/TOTALPOP)*100000,
    RatCoc = (AdmCoc/TOTALPOP)*100000,
    RatMar = (AdmMar/TOTALPOP)*100000,
    RatHer = (AdmHer/TOTALPOP)*100000,
    RatOpi = (AdmOpi/TOTALPOP)*100000,
    RatBen = (AdmBen/TOTALPOP)*100000,
    RatNMJ = (AdmNMJ/TOTALPOP)*100000
  ) %>%
  
  # We are taking the log+1 since there are relatively few 0's (and states that report 0's always report few, for any number)
  # This should mean that the percent change interpretation is preserved (Wooldridge. 2009 p.192)
  mutate(
    lRatAlc = log(RatAlc),
    lRatCoc = log(RatCoc),
    lRatMar = log(RatMar),
    lRatHer = log(RatHer),
    lRatOpi = log(RatOpi),
    lRatBen = log(RatBen),
    lRatNMJ = log(RatNMJ)
  ) %>%
  ungroup %>%
  select(STFIPS, NAME, YEAR, starts_with("Adm"), starts_with("Rat"), starts_with("lRat")) %>%

  write_csv(here("Data/Usage_ByStateYear.csv"))
