#############################
# Author: Robert Petit
# Desc: Some working/reference scripts that are useful for this project
# No code here will directly generate any information, figures, or tables in the project
# If it is being extended, perusing here before starting work is a good idea
#############################


# Good example of summarizing. This is passed to kable for the most key important summary table
USE <- read.csv(here("Data/Usage_ByStateYear.csv")) %>% view
  summarize(across(.cols=starts_with("Rat"),list (mean=mean, sd=sd))) %>%
  select(starts_with("Rat")) %>%
  pivot_longer(cols = everything(),
               names_to = c(".value", "statistic"), names_sep="_")

read.csv(here("Data/Usage_ByStateYear.csv")) %>% colnames


# Tidy Synth methods
Usage_Out <-
  read.csv(here("Data/Usage_ByStateYear.csv")) %>%
  
  # Initial object
  synthetic_control(outcome = lRatAlc, # The first, simple outcome
                    unit=STFIPS, # Unit level
                    time=YEAR, # Time variable
                    i_unit = 8, # CO FIPS=8
                    i_time=2012, # treat time
                    generate_placebos = T
                    ) %>%
    
  
    # The variables on which we are matching. In this case, it is the percentages of age groups in the total population
    # generate_predictor(time_window = 2000:2011,
    #                    mP017 = mean(P017),
    #                    mP1824 = mean(P1824),
    #                    mP2565 = mean(P2565),
    #                    mP65 = mean(P65)) %>%
    # Lagged outcomes
    generate_predictor(time_window = 2000,
                       Lag2000 = lRatAlc) %>%
    generate_predictor(time_window = 2004,
                       Lag2004 = lRatAlc) %>%
    generate_predictor(time_window = 2006,
                       Lag2006 = lRatAlc) %>%
    generate_predictor(time_window = 2008,
                       Lag2008 = lRatAlc) %>%
    generate_predictor(time_window = 2010,
                      Lag2010 = lRatAlc) %>%
    generate_predictor(time_window = 2011,
                       Lag2012 = lRatAlc) %>%
    
    # Generating the fitted weights for the synth
    generate_weights(optimization_window = 2000:2011,
                     margin_ipop = .02,sigf_ipop = 7,bound_ipop = 6 # optimizer options from the vignette
                     ) %>%
    
    generate_control()

Usage_Out %>% plot_trends
Usage_Out %>% plot_differences
Usage_Out %>% plot_placebos
Usage_Out %>% plot_mspe_ratio
    
