#############################
# Author: Robert Petit
# Desc: File cleans the TEDS set into the format
# (STFIPS, ADMYR, AdmAlc, AdmCoc, AdmMar, AdmHer, AdmOpi, AdmPCP, AdmHal, AdmBen, AdmNMJ)
# The admit data are the specific admissions for Alcohol, Cocaine, marijuana, heroin,
# PCP, hallucinogens, benzodiazepines, and all non-marijuana admissions.
#############################

# !!!!!!!!! If you are just pulling this from github, you will need to download the following 4 large data sets
# and extract them directly into /Data
# https://www.datafiles.samhsa.gov/sites/default/files/field-uploads-protected/studies/TEDS-A-2015-2019/TEDS-A-2015-2019-datasets/TEDS-A-2015-2019-DS0001/TEDS-A-2015-2019-DS0001-bundles-with-study-info/TEDS-A-2015-2019-DS0001-bndl-data-csv.zip
# https://www.datafiles.samhsa.gov/sites/default/files/field-uploads-protected/studies/TEDS-A-2010-2014/TEDS-A-2010-2014-datasets/TEDS-A-2010-2014-DS0001/TEDS-A-2010-2014-DS0001-bundles-with-study-info/TEDS-A-2010-2014-DS0001-bndl-data-csv_v1.zip
# https://www.datafiles.samhsa.gov/sites/default/files/field-uploads-protected/studies/TEDS-A-2005-2009/TEDS-A-2005-2009-datasets/TEDS-A-2005-2009-DS0001/TEDS-A-2005-2009-DS0001-bundles-with-study-info/TEDS-A-2005-2009-DS0001-bndl-data-csv_v1.zip
# https://www.datafiles.samhsa.gov/sites/default/files/field-uploads-protected/studies/TEDS-A-2000-2004/TEDS-A-2000-2004-datasets/TEDS-A-2000-2004-DS0001/TEDS-A-2000-2004-DS0001-bundles-with-study-info/TEDS-A-2000-2004-DS0001-bndl-data-csv_v1.zip
# Each of these is ~1.5GB, so they are included in the .gitignore

# We have to read the years in four clumps since they are massive. This outputs in 4 .csv files
foreach(File=Sys.glob(here("Data/tedsa_puf*"))) %do% {
  read.csv(File)%>% group_by(STFIPS, ADMYR) %>%
    summarize(AdmAlc = count(SUB1==2),
              AdmCoc = count(SUB1==3),
              AdmMar = count(SUB1==4),
              AdmHer = count(SUB1==5),
              AdmOpi = count(SUB1==7),
              AdmBen = count(SUB1==13),
              AdmNMJ = count(SUB1!=4)) %>%
    write.csv(str_replace(File, "tedsa_puf_", "SummarizedTEDS_"))
  gc()
}
