model_supply <- function(d1, supply_delay, model, rm = FALSE) {
  pars <- grab_2v_parms(model)
  pars <- apap_2v(pars, d1)
  # pars <- list_modify(pars, delta1 = rep(1/d1, Ngroups))
  y <- sr(list_modify(pars, 
                      e1 = .95,
                      tmore1 = rep(supply_delay, Ngroups)), "2v_v2")
  if(rm) return(y)
  main_metrics(y, pop)
}

# c("2%" = 1460, "4%" = 730, "8%" = 360, "15%" = 180, "28%" = 90, "40%" = 60, "49%" = 45)

df_supply <- expand_grid(d1 = d1_general,
                                     supply_delay = seq(0, 360, 15),
                                     model = scenario_par_nms_2v) %>%
  mutate(data = pmap(list(d1, supply_delay, model), function(x,y,z) data.frame(value = model_supply(x,y,z), 
                                                                     var = metric_nms))) %>%
  unnest(data) %>%
  spread(var, value) %>%
  group_by(model, supply_delay)  %>%
  mutate(model = factor(model, levels = scenario_par_nms_2v,
                        labels = scenario_nms_2v)) 


# Burdens
select(df_supply, d1, supply_delay, i) %>%
  spread(supply_delay, i) %>%
  filter(d1 %in% c(d1_general, Inf)) %>%
  mutate(d1 = 100/d1)
# Reductions
select(df_supply, d1, supply_delay, i) %>%
  group_by(model, supply_delay) %>%
  mutate(i = 1 - i/max(i)) %>%
  ungroup() %>%
  spread(supply_delay, i) %>%
  filter(d1 %in% c(d1_general, Inf)) %>%
  mutate(d1 = 100/d1)

fig_extra_supply <- select(df_supply, d1, supply_delay, i) %>% 
  group_by(model, supply_delay) %>%
  mutate(i = 1 - i/max(i)) %>%
  ungroup() %>%
  filter(d1 %in% c(d1_general)) %>%
  mutate(d1 = factor(d1, levels = c(d1_general), labels = c(as.percent(1/d1_general)))) %>%
  ggplot(aes(x = supply_delay, y = i, color = d1, group = d1)) + 
  facet_wrap(~model) + 
  geom_line() +
  xlab("Time until extra capacity available (2x increase in vaccination rate)") +
  ylab("Fraction of infections averted") +
  scale_x_continuous(breaks = seq(0, 360, 120)) + 
  scale_color_discrete(name = "Vaccinated per day") +
  theme(legend.position = "top")

