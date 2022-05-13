Heroin_Out <-
  read.csv(here("Data/Usage_ByStateYear.csv")) %>%
  filter(YEAR>=2007) %>%
  
  # Initial object
  synthetic_control(outcome = lRatHer, # The first, simple outcome
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
                     Lag2007 = lRatHer) %>%
  generate_predictor(time_window = 2010,
                     Lag2010 = lRatHer) %>%
  generate_predictor(time_window = 2012,
                     Lag2012 = lRatHer) %>%
  
  # Generating the fitted weights for the synth
  generate_weights(optimization_window = 2007:2012,
                   margin_ipop = .02,sigf_ipop = 7,bound_ipop = 6 # optimizer options from the vignette
  ) %>%
  
  generate_control()

Heroin_Out %>%
  plot_trends() +
  labs(title="Synthetic and Observed Rate of Heroin Admissions",
       y="Log Heroin Admission Rate",
       x="Year")
ggsave(here("Figures/Figure_Trend_Heroin.png"))

Heroin_Out %>%
  plot_differences() +
  labs(title="Difference between Synthetic and Observed",
       y="Difference in Log Heroin Admission Rate",
       x="Year")
ggsave(here("Figures/Figure_Difference_Heroin.png"))

Heroin_Out %>%
  plot_mspe_ratio() +
  labs(title="Ratio of Pre/Post Treatment Mean Squared Prediction Error (Heroin)",
       x="State FIPS, ordered")
ggsave(here("Figures/Figure_MSPERat_Heroin.png"))

Heroin_Out %>% 
  plot_placebos(prune=F)+
  labs(title="Difference of Each State in the Donor Pool",
       y="Difference in Log Heroine Rate",
       x="Year")
ggsave(here("Figures/Figure_Placebos_Heroin.png"))

Heroin_Out %>% grab_balance_table() %>%
  rowwise() %>%
  mutate(variable = str_replace(variable, "mP1824", "Mean Pop. Percent [18, 24]"),
         variable = str_replace(variable, "mP2565", "Mean Pop. Percent [25, 65]"),
         variable = str_replace(variable, "Lag2007", "Log Heroin Rate: 2007"),
         variable = str_replace(variable, "Lag2010", "Log Heroin Rate: 2010"),
         variable = str_replace(variable, "Lag2012", "Log Heroin Rate: 2012")) %>%
  kbl(caption="Balance of Variables in Treatment and Control",
      booktabs=T,
      format="latex",
      label="BalTab",
      col.names=c("Variable", "Colorado", "Synthetic Colorado", "Donor Sample")) %>%
  kable_styling(latex_options=c("striped", "hold_position", "condensed")) %>%
  
  write_lines(here("Tables/Table_BalanceTable.tex"))
