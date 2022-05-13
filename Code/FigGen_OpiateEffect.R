Opiate_Out <-
  read.csv(here("Data/Usage_ByStateYear.csv")) %>%
  filter(YEAR>=2007) %>%
  
  # Initial object
  synthetic_control(outcome = lRatOpi, # The first, simple outcome
                    unit=STFIPS, # Unit level
                    time=YEAR, # Time variable
                    i_unit = 8, # CO FIPS=8
                    i_time=2012, # treat time
                    generate_placebos = T
  ) %>%
  
  # It seems that including /all/ of the percentages is overcontrolling to a degree. Only two are included
  # The variables on which we are matching. In this case, it is the percentages of age groups in the total population
  generate_predictor(time_window = 2000:2011,
                     mP1824 = mean(P1824),
                     mP2565 = mean(P2565)
  ) %>%
  
  generate_predictor(time_window = 2007,
                     Lag2007 = lRatOpi) %>%
  generate_predictor(time_window = 2010,
                     Lag2010 = lRatOpi) %>%
  generate_predictor(time_window = 2012,
                     Lag2012 = lRatOpi) %>%
  
  # Generating the fitted weights for the synth
  generate_weights(optimization_window = 2007:2012,
                   margin_ipop = .02,sigf_ipop = 7,bound_ipop = 6 # optimizer options from the vignette
  ) %>%
  
  generate_control()

Opiate_Out %>%
  plot_trends() +
  labs(title="Synthetic and Observed Rate of Opiate Admissions",
       y="Log Opiate Admission Rate",
       x="Year")
ggsave(here("Figures/Figure_Trend_Opiate.png"))

Opiate_Out %>%
  plot_differences() +
  labs(title="Difference between Synthetic and Observed",
       y="Difference in Log Opiate Admission Rate",
       x="Year")
ggsave(here("Figures/Figure_Difference_Opiate.png"))

Opiate_Out %>%
  plot_mspe_ratio() +
  labs(title="Ratio of Pre/Post Treatment Mean Squared Prediction Error (Opiate)",
       x="State FIPS, ordered")
ggsave(here("Figures/Figure_MSPERat_Opiate.png"))