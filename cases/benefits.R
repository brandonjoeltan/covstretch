

# Sequencing vaccination (prevaccination scenario) ------

benefits_curve <- function(e, pop){
  ii <- 1e-04
  sapply(
    seq(0,1,length=21),
    function(p) {
      v <- vac_top_p(p, pop)
      y0_v <- y0_gen(13, Ngroups, pre_immunity = pre_immunity + (1-pre_immunity)*e*v)
      sr <- sr(list_modify(pars_le_fast, y0 = y0_v))
      c(p = p,
        bd = bd(sr, pop),
        bi = b_any(sr, pop, "cumI"))
    }) %>% t() %>% as.data.frame()
}

bf <- rbind(
  benefits_curve(.8, pop) %>% mutate(scenario = " 80% efficacy"),
  benefits_curve(.6, pop) %>% mutate(scenario = " 60% efficacy"),
  benefits_curve(.4, pop) %>% mutate(scenario = " 40% efficacy"),
  benefits_curve(1, pop) %>% mutate(scenario = "100% efficacy")) %>%
  mutate(bi = 1-(bi/max(bi))) %>%
  mutate(bd = 1-(bd/max(bd)))

benefits_gg <- bf %>% 
  # mutate(both = .5*bi + .5*bd) %>%
  setNames(c("p", "Deaths averted", "Infections averted", "scenario")) %>%
  gather(var, value, -p, -scenario) %>%
  # filter(!(scenario != "100% efficacy" & var == "Total benefit")) %>%
  ggplot(aes(x = p, y = value, group = scenario, color = scenario, lty = scenario)) + 
  geom_line() + 
  # scale_color_viridis_d() +
  facet_wrap(~var, scales = "free") + xlab("Fraction vaccinated before epidemic") + ylab("Fraction of harm averted") +
  theme(legend.position = "top", legend.title = element_blank())





# Illustration -----

# sr(list_modify(pars_le_fast, delta1 = rep(0, Ngroups), y0 = y0_gen(13, Ngroups, c(0.5, 0.5, rep(0,7)), 0))) %>% harm()
atrisk <- c(rep(1,8), 1)
0.5*sum(risk_age_i*atrisk*pop)/normalising_f_i + 0.5*sum(risk_age_d*atrisk*pop)/normalising_f_d 

contribution <- sapply(1:9, function(i) {
  atrisk <- rep(0, 9)
  atrisk[i] <- 1
  0.5*sum(risk_age_i*atrisk*pop)/normalising_f_i + 0.5*sum(risk_age_d*atrisk*pop)/normalising_f_d 
})

rbind("Group size" = pop,
      "Infection risk q" = risk_age_i,
      "Fatality risk r" = risk_age_d,
      "Total contributon" = contribution) %>% 
  as.data.frame() %>% setNames(colnames(pbc_spread)) %>% print(digits = 2)




bf %>% mutate(both = .5*bi + .5*bd) %>% filter(scenario == "100% efficacy") %>% select(p, both, scenario) %>%
  rbind(data.frame(scenario = "Assumption", 
                   both = cumsum(rev(contribution)),
                   # both = c(0, .55, .9, 1, 1), 
                   # p = c(0, .25, .5, .7, 1))) %>%
                   p = c(cumsum(rev(pop))))) %>%
  ggplot(aes(x = p, y = both, group = scenario, lty = scenario)) + 
  geom_line() + xlab("Fraction vaccinated") + ylab("Fraction averted")

