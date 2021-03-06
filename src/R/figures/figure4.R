# Distance calculations/plotting ****Fire Frequency-----------Regions-------------------------------

fishdis_reg <- fread('data/PointShp/CONUS_short_dis_VLDH_Wildlands_FishID.csv', header = T, sep = ',', stringsAsFactors = TRUE) %>%
  mutate(AREA_km2 = as.numeric(AREA_km2),
         Class = classify_new_categories(WUICLASS10)) %>%
  group_by(FishID_10k, Region, IGNITION) %>%
  summarise(Ave_NEAR_DIST = median(NEAR_DIST),
            fseason_lngth = IQR(DISCOVERY_DOY),
            Avg_DOY = mean(DISCOVERY_DOY),
            f_cnt = n()) %>%
  ungroup()

firefreq_p <- fishdis_reg %>%
  #transform(Region = factor(Region, levels=c("West", "Central", "South East", "North East"))) %>%
  ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = f_cnt, color = IGNITION)) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"),
              fullrange = TRUE, size = 0.75) +
  scale_color_manual(values=c("red", "black")) +
  xlab("Distance from WUI (km)") + ylab("Ignition frequency") +
  theme_pub()  +
  facet_wrap(~Region,
             nrow = 2, labeller = label_wrap_gen(10))

pred_diffs <- ggplot_build(firefreq_p)$data[[1]] %>%
  tbl_df %>%
  dplyr::select(colour, y, x, PANEL) %>%
  spread(colour, y) %>%
  mutate(line_diff = abs(black - red))

min_diffs <- pred_diffs %>%
  group_by(PANEL) %>%
  summarize(line_diff = min(line_diff))

xpoints_cnt <- left_join(min_diffs, pred_diffs) %>%
  mutate(Region = sort(unique(fishdis_reg$Region)),
         xpt_cnt = x) %>%
  dplyr::select(Region, xpt_cnt) %>%
  left_join(., fishdis_reg, by = c("Region")) %>%
  group_by(Region) %>%
  summarise(n = n(),
            xpt_cnt = round(first(xpt_cnt),0),
            xpt_lab = as.factor(xpt_cnt)) %>%
  ungroup()

regmean <- fishdis_reg %>%
  group_by(Region, IGNITION) %>%
  summarise(fcnt_mean = mean(f_cnt)) %>%
  spread(IGNITION, fcnt_mean)

# check to see where the min. diffs fall in plot
firefreq_cent <- fishdis_reg %>%
  filter(Region ==  "Central") %>%
  ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = f_cnt, color = IGNITION)) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"),
               size = 0.75) +
  scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
  xlab("") + ylab("") +
  ggtitle("Central") +
  scale_x_continuous(limits = c(0, 125)) +
  theme_pub()  +
  geom_vline(aes(xintercept = xpt_cnt), data = subset(xpoints_cnt, Region == "Central"),
             linetype = "dashed", color  = "gray") +
  geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "Central"),
             linetype = "dashed", color = "red") +
  geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "Central"),
             linetype = "dashed", color = "#1F77B4") +
  # geom_text(data=subset(xpoints_cnt, Region == "Central"),
  #           aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_cnt, y = 10, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "Central"),
  #           aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "Central"),
  #           aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
  theme(axis.title = element_text(face = "bold"),
        strip.text = element_text(size = 8, face = "bold"),
        legend.position = "none")

firefreq_west <- fishdis_reg %>%
  filter(Region ==  "West") %>%
  ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = f_cnt, color = IGNITION)) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"),
               size = 0.75) +
  scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
  xlab("") + ylab("Ignition frequency") +
  ggtitle("West") +
  scale_x_continuous(limits = c(0, 125)) +
  theme_pub()  +
  geom_vline(aes(xintercept = xpt_cnt), data = subset(xpoints_cnt, Region == "West"),
             linetype = "dashed", color  = "gray") +
  geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "West"),
             linetype = "dashed", color = "red") +
  geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "West"),
             linetype = "dashed", color = "#1F77B4") +
  # geom_text(data=subset(xpoints_cnt, Region == "West"),
  #           aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_cnt, y = 10, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "West"),
  #           aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = - 0.5 + Human, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "West"),
  #           aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
  theme(axis.title = element_text(face = "bold"),
        strip.text = element_text(size = 8, face = "bold"),
        legend.position = "none")

firefreq_se <- fishdis_reg %>%
  filter(Region ==  "South East") %>%
  ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = f_cnt, color = IGNITION)) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"),
               size = 0.75) +
  scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
  xlab("Distance from WUI (km)") + ylab("Ignition frequency") +
  ggtitle("South East") +
  scale_x_continuous(limits = c(0, 125)) +
  theme_pub()  +
  geom_vline(aes(xintercept = xpt_cnt), data = subset(xpoints_cnt, Region == "South East"),
             linetype = "dashed", color  = "gray") +
  geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "South East"),
             linetype = "dashed", color = "red") +
  geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "South East"),
             linetype = "dashed", color = "#1F77B4") +
  # geom_text(data=subset(xpoints_cnt, Region == "South East"),
  #           aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_cnt, y = 20, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "South East"),
  #           aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "South East"),
  #           aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = - 0.5 + Lightning, colour="red"), size = 4) +
  theme(axis.title = element_text(face = "bold"),
        strip.text = element_text(size = 8, face = "bold"),
        legend.position = "none")

firefreq_ne <- fishdis_reg %>%
  filter(Region ==  "North East") %>%
  ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = f_cnt, color = IGNITION)) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"),
               size = 0.75, se = FALSE) +
  geom_smooth(method = "glm", method.args = list(family = "poisson"),
              fullrange = T, size = 0.5, linetype = "dashed") +
  scale_color_manual(values = c("#D62728","#1F77B4", "black")) +
  xlab("Distance from WUI (km)") + ylab("") +
  ggtitle("North East") +
  scale_x_continuous(limits = c(0, 125)) +
  theme_pub()  +
  geom_vline(aes(xintercept = xpt_cnt), data = subset(xpoints_cnt, Region == "North East"),
             linetype = "dashed", color  = "gray") +
  geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "North East"),
             linetype = "dashed", color = "red") +
  geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "North East"),
             linetype = "dashed", color = "#1F77B4") +
  # geom_text(data=subset(xpoints_cnt, Region == "North East"),
  #           aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_cnt, y = 10, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "North East"),
  #           aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
  # geom_text(data = subset(regmean, Region == "North East"),
  #           aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
  theme(axis.title = element_text(face = "bold"),
        strip.text = element_text(size = 8, face = "bold"),
        legend.position = "none")

grid.arrange(firefreq_west, firefreq_cent, firefreq_se, firefreq_ne, ncol =2)
g <- arrangeGrob(firefreq_west, firefreq_cent, firefreq_se, firefreq_ne, ncol =2)
ggsave("Distance_FireFreq_Reg.png", g, width = 6, height = 8, dpi=1200)
ggsave("Distance_FireFreq_Reg.EPS", g, width = 6, height = 7, dpi=1200, scale = 2, units = "cm") #saves g

ffreq_xpt <- xpoints_cnt %>%
  transform(Region = factor(Region, levels=c("West", "Central", "South East", "North East"))) %>%
  #ggplot(aes(x = reorder(Region, -xpt_cnt), y = xpt_cnt)) +
  ggplot(aes(x = Region, y = xpt_cnt)) +
  geom_bar(stat="identity", color = "black") +
  xlab("") + ylab("Distance from the WUI (km)") +
  theme_pub()+
  ggtitle("(A) Fire frequency") +
  geom_hline(aes(yintercept = 2.4), linetype = "dashed")


  # Distance calculations/plotting ****IQR Fire season length---Regions---------------------------------------

  fseason_p <- fishdis_reg %>%
    ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = fseason_lngth, color = IGNITION)) +
    geom_smooth(method = "glm", method.args = list(family = "poisson"),
                se = FALSE, fullrange = TRUE, size = 0.75) +
    scale_color_manual(values=c("red", "black")) +
    xlab("Distance from WUI (km)") + ylab("Fire season length") +
    theme_pub()  +
    facet_wrap(~Region,
               nrow = 2, labeller = label_wrap_gen(10))

  pred_diffs <- ggplot_build(fseason_p)$data[[1]] %>%
    tbl_df %>%
    dplyr::select(colour, y, x, PANEL) %>%
    spread(colour, y) %>%
    mutate(line_diff = abs(black - red))

  min_diffs <- pred_diffs %>%
    group_by(PANEL) %>%
    summarize(line_diff = min(line_diff))

  xpoints_fseason <- left_join(min_diffs, pred_diffs) %>%
    mutate(Region = sort(unique(fishdis_reg$Region)),
           xpt_season = x) %>%
    dplyr::select(Region, xpt_season)  %>%
    left_join(., fishdis_reg, by = c("Region")) %>%
    group_by(Region) %>%
    summarise(n = n(),
              xpt_season = round(first(xpt_season),0),
              xpt_lab = as.factor(xpt_season)) %>%
    ungroup()


  regmean <- fishdis_reg %>%
    group_by(Region, IGNITION) %>%
    summarise(fseason_mean = mean(fseason_lngth)) %>%
    spread(IGNITION, fseason_mean)


  # check to see where the min. diffs fall in plot
  fseason_cent <- fishdis_reg %>%
    filter(Region ==  "Central") %>%
    ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = fseason_lngth, color = IGNITION)) +
    geom_smooth(method = "glm", method.args = list(family = "poisson"),
                 size = 0.75) +
    scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
    xlab("") + ylab("") +
    ggtitle("Central") +
    scale_x_continuous(limits = c(0, 125)) +
    theme_pub()  +
    geom_vline(aes(xintercept = xpt_cnt), data = subset(xpoints_cnt, Region == "Central"),
               linetype = "dashed", color  = "gray") +
    geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "Central"),
               linetype = "dashed", color = "red") +
    geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "Central"),
               linetype = "dashed", color = "#1F77B4") +
    geom_text(data=subset(xpoints_fseason, Region == "Central"),
              aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_season, y = 10, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "Central"),
              aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "Central"),
              aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
    theme(axis.title = element_text(face = "bold"),
          strip.text = element_text(size = 8, face = "bold"),
          legend.position = "none")

  fseason_west <- fishdis_reg %>%
    filter(Region ==  "West") %>%
    ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = fseason_lngth, color = IGNITION)) +
    geom_smooth(method = "glm", method.args = list(family = "poisson"),
                 size = 0.75) +
    scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
    xlab("") + ylab("IQR Range") +
    ggtitle("West") +
    scale_x_continuous(limits = c(0, 125)) +
    theme_pub()  +
    geom_vline(aes(xintercept = xpt_season), data = subset(xpoints_fseason, Region == "West"),
               linetype = "dashed", color  = "gray") +
    geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "West"),
               linetype = "dashed", color = "red") +
    geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "West"),
               linetype = "dashed", color = "#1F77B4") +
    geom_text(data=subset(xpoints_fseason, Region == "West"),
              aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_season, y = 10, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "West"),
              aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "West"),
              aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
    theme(axis.title = element_text(face = "bold"),
          strip.text = element_text(size = 8, face = "bold"),
          legend.position = "none")

  fseason_se <- fishdis_reg %>%
    filter(Region ==  "South East") %>%
    ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = fseason_lngth, color = IGNITION)) +
    geom_smooth(method = "glm", method.args = list(family = "poisson"),
                 size = 0.75) +
    # geom_smooth(method = "glm", method.args = list(family = "poisson"),
    #             fullrange = T, size = 0.5, linetype = "dashed") +
    scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
    xlab("Distance from WUI (km)") + ylab("IQR Range") +
    ggtitle("South East") +
    scale_x_continuous(limits = c(0, 125)) +
    theme_pub()  +
    geom_vline(aes(xintercept = xpt_season), data = subset(xpoints_fseason, Region == "South East"),
               linetype = "dashed", color  = "gray") +
    geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "South East"),
               linetype = "dashed", color = "red") +
    geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "South East"),
               linetype = "dashed", color = "#1F77B4") +
    geom_text(data=subset(xpoints_fseason, Region == "South East"),
              aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_season, y = 10, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "South East"),
              aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "South East"),
              aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
    theme(axis.title = element_text(face = "bold"),
          strip.text = element_text(size = 8, face = "bold"),
          legend.position = "none")

  fseason_ne <- fishdis_reg %>%
    filter(Region ==  "North East") %>%
    ggplot(aes(x = (Ave_NEAR_DIST)*0.001, y = fseason_lngth, color = IGNITION)) +
    geom_smooth(method = "glm", method.args = list(family = "poisson"),
                 size = 0.75) +
    scale_color_manual(values=c("#D62728","#1F77B4", "black")) +
    xlab("Distance from WUI (km)") + ylab("") +
    ggtitle("North East") +
    scale_x_continuous(limits = c(0, 125)) +
    theme_pub()  +
    geom_vline(aes(xintercept = xpt_season), data = subset(xpoints_fseason, Region == "North East"),
               linetype = "dashed", color  = "gray") +
    geom_hline(aes(yintercept = Human), data = subset(regmean, Region == "North East"),
               linetype = "dashed", color = "red") +
    geom_hline(aes(yintercept = Lightning), data = subset(regmean, Region == "North East"),
               linetype = "dashed", color = "#1F77B4") +
    geom_text(data=subset(xpoints_fseason, Region == "North East"),
              aes(label=paste(xpt_lab, "km", sep = " "), x = 20 + xpt_season, y = 10, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "North East"),
              aes(label=paste(round(Human,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Human, colour="red"), size = 4) +
    geom_text(data = subset(regmean, Region == "North East"),
              aes(label=paste(round(Lightning,2), "fires/km2", sep = " "), x = 90, y = 0.5 + Lightning, colour="red"), size = 4) +
    theme(axis.title = element_text(face = "bold"),
          strip.text = element_text(size = 8, face = "bold"),
          legend.position = "none")

  grid.arrange(fseason_west, fseason_cent, fseason_se, fseason_ne,
               ncol =2, widths = c(0.5, 0.5))
  g <- arrangeGrob(fseason_west, fseason_cent, fseason_se, fseason_ne,
                   ncol =2, widths = c(0.5, 0.5))
  ggsave("Distance_FireSeason_Reg.png", g, width = 6, height = 8, dpi=1200)
  ggsave("Distance_FireSeason_Reg.EPS", g, width = 6, height = 7, dpi=1200, scale = 2, units = "cm") #saves g
