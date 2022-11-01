library(tidyverse)
library(ggplot2)
library(BiocManager)
library(edgeR)
library(readr)
library(dplyr)
library(data.table)
library(plotly)
library(factoextra)
library(viridis)
library(reshape2)
library(gplots)
library(ggpubr)
library(remotes)
library(data.table)
library(plotly)
library(factoextra)
library(reshape2)
library(gplots)
library(gatepoints)
library(rstatix)

# Set working directory

setwd("")

STAT3_embryos <- list() # Creates a list
listcsv <- dir(pattern = "*") # Creates the list of all the csv files in the directory

# Reads in the data
for (k in 1:length(listcsv)){
  
  STAT3_embryos[[k]] <- read.csv(listcsv[k])
  
}

# Adding file name as a column
all_paths <-
  list.files(path = "",
             pattern = "*.csv",
             full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(read.table,
         header = TRUE,
         sep = "\t",
         encoding = "UTF-8")

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

all_result <- rbindlist(all_lists, fill = T)

# Change column name
names(all_result)[3] <- "File.Path"

# Make one data table from a list of many
All_embryos_data <- rbindlist(STAT3_embryos, fill = TRUE)

# Combine the file names and the data into one dataframe
All_embryos_data <- cbind(all_result$V1, All_embryos_data)

# Add a column with the embryo stage
STAT3_embryo_staged <- transform(All_embryos_data, Embryo_stage= ifelse(V1 %like% "E3.5", "E3.5", 
                                                                        ifelse(V1 %like% "E4.5", "E4.5", 
                                                                               ifelse(V1 %like% "Diapause", "Diapaused", ""))))


# Split by channel 
STAT3_embryo_staged_morphology <- subset(STAT3_embryo_staged, V1 %like% "Morphological")
STAT3_embryo_staged_channel_1 <- subset(STAT3_embryo_staged, V1 %like% "C1")
STAT3_embryo_staged_channel_2 <- subset(STAT3_embryo_staged, V1 %like% "C2")
STAT3_embryo_staged_channel_3 <- subset(STAT3_embryo_staged, V1 %like% "C3")
STAT3_embryo_staged_channel_4 <- subset(STAT3_embryo_staged, V1 %like% "C4")


# Combine the morphologial data and dat from different channels across rows so each nuclei has all the data on one row
STAT3_embryo_staged_all_channels <- cbind(STAT3_embryo_staged_morphology, x = STAT3_embryo_staged_channel_1, y = STAT3_embryo_staged_channel_2, z = STAT3_embryo_staged_channel_3, t = STAT3_embryo_staged_channel_4)


# //////////////////////////////////////////////////////////////////////////////////////////////////////


# Add useful columns for categorizing the data 
STAT3_embryo_final_data <- STAT3_embryos_all_channels %>% separate(V1, c("Embryo_number", "Data_type"), sep="__")
STAT3_embryo_final_data <- STAT3_embryo_final_data %>% separate(Embryo_number, c("Null", "Embryo_number"), sep="M_")

STAT3_embryo_final_data <- subset(STAT3_embryo_final_data, select = -c(1))
STAT3_embryo_final_data$Embryo_number_and_stage <- paste(STAT3_embryo_final_data$Embryo_number, STAT3_embryo_final_data$x.Embryo_stage, sep = "_")
colnames(STAT3_embryo_final_data)
head(STAT3_embryo_final_data$Embryo_number_and_stage)

# Calculate the xyz centre position of the nuclei and add the values as separate columns
STAT3_embryo_final_data$X_centre <- (STAT3_embryo_final_data$Xmin..pix. + STAT3_embryo_final_data$Xmax..pix.)/2
STAT3_embryo_final_data$Y_centre <- (STAT3_embryo_final_data$Ymin..pix. + STAT3_embryo_final_data$Ymax..pix.)/2
STAT3_embryo_final_data$Z_centre <- (STAT3_embryo_final_data$Zmin..pix. + STAT3_embryo_final_data$Zmax..pix.)/2
colnames(STAT3_embryo_final_data)

# Remove mutant embryos leaving only WT in the analysis
STAT3_embryo_final_data <- subset(STAT3_embryo_final_data, !(x.V1 %like% "Mutant"))

# Filter for objects which have a high enough DAPI signal
ggplot(data = STAT3_embryo_staged_all_channels, aes(x=x.Mean)) + 
  geom_histogram(binwidth=1) 

ggplot(data = STAT3_embryo_staged_all_channels, aes(x=x.Mean)) + 
  geom_histogram(binwidth=1) +
  coord_cartesian(xlim = c(0, 50)) +
  scale_x_continuous(breaks = round(seq(0, 50 , by = 1),1))

# Set threshold to x.Mean (DAPI mean) greater than and less than based on your histogram values
# Highest value considered an individual nuclei
upper_limit <- 
# Lowest value considered an individual nuclei
lower_limit <- 
# Apply threshold to x.Mean (DAPI mean) greater than and less than based on your histogram values
STAT3_embryo_final_data <- subset(STAT3_embryo_final_data, x.Mean>lower_limit)
STAT3_embryo_final_data <- subset(STAT3_embryo_final_data, x.Mean<upper_limit)


# Filter for nuclei which are too small to be real
ggplot(data = STAT3_embryo_staged_all_channels, aes(x=Vol..unit.)) + 
  geom_histogram(binwidth=1) 

# Highest value considered an individual nuclei
upper_limit_vol <- 
# Lowest value considered an individual nuclei
lower_limit_vol <- 
# Apply threshold to Vol..unit. greater than and less than based on your histogram values
STAT3_embryo_final_data <- subset(STAT3_embryo_final_data, Vol..unit.<upper_limit_vol)
STAT3_embryo_final_data <- subset(STAT3_embryo_final_data, Vol..unit.>lower_limit_vol)
# A normally distributed dataset with no bimodal distributions suggests segmentation is pretty good with few erroneous nuclei


# Separate by embryo stage
STAT3_embryo_staged_all_channels_E3.5 <- subset(STAT3_embryo_final_data, Embryo_stage %like% "E3.5")
STAT3_embryo_staged_all_channels_E4.5 <- subset(STAT3_embryo_final_data, Embryo_stage %like% "E4.5")
STAT3_embryo_staged_all_channels_Diapaused <- subset(STAT3_embryo_final_data, Embryo_stage %like% "Diapaused")


# //////////////////////////////////////////////////////////////////////////////////////////////////////


# Background subtractions
setwd("/")

STAT3_embryos_background <- list() # creates a list
listcsv <- dir(pattern = "*") # creates the list of all the csv files in the directory

for (k in 1:length(listcsv)){
  
  STAT3_embryos_background[[k]] <- read.csv(listcsv[k])
  
}

Background_data <- rbindlist(STAT3_embryos_background, fill = TRUE)
transform(Background_data, Mean = as.numeric(Mean))

C1_background <- subset(Background_data, Label %like% "C1")
C2_background <- subset(Background_data, Label %like% "C2")
C3_background <- subset(Background_data, Label %like% "C3")
C4_background <- subset(Background_data, Label %like% "C4")

C1_mean_background <- mean(C1_background$Mean)
C2_mean_background <- mean(C2_background$Mean)
C3_mean_background <- mean(C3_background$Mean)
C4_mean_background <- mean(C4_background$Mean)

# Average integrated density = average size of the objects x average mean
transform(STAT3_embryo_final_data, Vol..unit.= as.numeric(Vol..unit.))
Average_object_size <- mean(STAT3_embryo_final_data$Vol..unit.)
C1_average_IntDen_background <- C1_mean_background*Average_object_size
C2_average_IntDen_background <- C2_mean_background*Average_object_size
C3_average_IntDen_background <- C3_mean_background*Average_object_size
C4_average_IntDen_background <- C4_mean_background*Average_object_size

# Add column with Mean minus background
STAT3_embryo_final_data$C1_Mean_minus_background <- STAT3_embryo_final_data$x.Mean - C1_mean_background
STAT3_embryo_final_data$C2_Mean_minus_background <- STAT3_embryo_final_data$y.Mean - C2_mean_background
STAT3_embryo_final_data$C3_Mean_minus_background <- STAT3_embryo_final_data$z.Mean - C3_mean_background
STAT3_embryo_final_data$C4_Mean_minus_background <- STAT3_embryo_final_data$t.Mean - C4_mean_background

# Add column with Integrated density minus background
STAT3_embryo_final_data$C1_IntDen_minus_background <- STAT3_embryo_final_data$x.IntDen - C1_average_IntDen_background
STAT3_embryo_final_data$C2_IntDen_minus_background <- STAT3_embryo_final_data$y.IntDen - C2_average_IntDen_background
STAT3_embryo_final_data$C3_IntDen_minus_background <- STAT3_embryo_final_data$z.IntDen - C3_average_IntDen_background
STAT3_embryo_final_data$C4_IntDen_minus_background <- STAT3_embryo_final_data$t.IntDen - C4_average_IntDen_background


# //////////////////////////////////////////////////////////////////////////////////////////////////////


# Graphing and statistics
pairwise_comparisons <- list(c("E3.5", "E4.5"), c("E3.5", "Diapaused"), c("E4.5", "Diapaused"))
STAT3_embryo_final_data$Embryo_stage<- factor (STAT3_embryo_final_data$Embryo_stage, levels = c("E3.5", "E4.5", "Diapaused"))


# Statistical tests

# Shapiro-Wilk test to determine whether the data in each group is normally distributed (repeated for each protein quantified)

STAT3_diapaused_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(t.Mean[t.Embryo_stage == "Diapaused"]))
STAT3_diapaused_Shapiro
write.csv(STAT3_diapaused_Shapiro[1:4], file = path)

Nanog_diapaused_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(z.Mean[t.Embryo_stage == "Diapaused"]))
Nanog_diapaused_Shapiro
write.csv(Nanog_diapaused_Shapiro[1:4], file = path)

TFCP2L1_diapaused_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(y.Mean[t.Embryo_stage == "Diapaused"]))
TFCP2L1_diapaused_Shapiro
write.csv(TFCP2L1_diapaused_Shapiro[1:4], file = path)

STAT3_E3.5_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(t.Mean[t.Embryo_stage == "E3.5"]))
STAT3_E3.5_Shapiro
write.csv(STAT3_E3.5_Shapiro[1:4], file = path)

Nanog_E3.5_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(z.Mean[t.Embryo_stage == "E3.5"]))
Nanog_E3.5_Shapiro
write.csv(Nanog_E3.5_Shapiro[1:4], file= path)

TFCP2L1_E3.5_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(y.Mean[t.Embryo_stage == "E3.5"]))
TFCP2L1_E3.5_Shapiro
write.csv(TFCP2L1_E3.5_Shapiro[1:4], file = path)


STAT3_E4.5_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(t.Mean[t.Embryo_stage == "E4.5"]))
STAT3_E4.5_Shapiro
write.csv(STAT3_E4.5_Shapiro[1:4], file = path)

Nanog_E4.5_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(z.Mean[t.Embryo_stage == "E4.5"]))
Nanog_E4.5_Shapiro
write.csv(Nanog_E4.5_Shapiro[1:4], file = path)

TFCP2L1_E4.5_Shapiro <- with(STAT3_embryo_final_data, shapiro.test(y.Mean[t.Embryo_stage == "E4.5"]))
TFCP2L1_E4.5_Shapiro
write.csv(TFCP2L1_E4.5_Shapiro[1:4], file = path)


# Levene test to determine whether the distribution of each group for each protein quantification is equal

STAT3_levene_test <- levene_test(t.Mean ~ t.Embryo_stage, data = STAT3_embryo_final_data)
STAT3_levene_test # Variance amongst the three groups is not equal
write.csv(STAT3_levene_test, file = path)

Nanog_levene_test <- levene_test(z.Mean ~ t.Embryo_stage, data = STAT3_embryo_final_data)
Nanog_levene_test # Variance amongst the three groups IS equal, p>0.05
write.csv(Nanog_levene_test, file = path)

TFCP2l1_levene_test <- levene_test(y.Mean ~ t.Embryo_stage, data = STAT3_embryo_final_data)
TFCP2l1_levene_test # Variance amongst the three groups is not equal
write.csv(TFCP2l1_levene_test, file = path)

# If the results from the Shapiro-Wilk test and Levene's test suggest the data is normally distributed and that the groups have equal distributions that are the same shape then parametric tests such as a student's t-test and ANOVA can be used. Otherwise non-parameteric tests must be used as below.

# Wilcoxon rank sum test (non-parametric test to compare two groups, pairwise tests performed if the number of groups is more than 2)
attach(STAT3_embryo_final_data)
STAT3_wilcox <- pairwise.wilcox.test(t.Mean, t.Embryo_stage, p.adjust.method = p.adjust.methods,
                                     paired = FALSE)
print(STAT3_wilcox)
write.csv(STAT3_wilcox$p.value, file = path)
#path is user defined

Nanog_wilcox <- pairwise.wilcox.test(z.Mean, t.Embryo_stage, p.adjust.method = p.adjust.methods,
                                    paired = FALSE)
print(Nanog_wilcox)
write.csv(Nanog_wilcox$p.value, file = path)

TFCP2L1_wilcox <- pairwise.wilcox.test(y.Mean, t.Embryo_stage, p.adjust.method = p.adjust.methods,
                                       paired = FALSE)
print(TFCP2L1_wilcox)
write.csv(TFCP2L1_wilcox$p.value, file = path)


# Kruskal-Wallis test to compare the distributions of multiple groups (non-parametric alternative to ANOVA)

STAT3_kruskal_wallis <- kruskal.test(t.Mean ~ t.Embryo_stage, data = STAT3_embryo_final_data)
STAT3_kruskal_wallis
write.csv(STAT3_kruskal_wallis[1:5], file = path)

Nanog_kruskal_wallis <- kruskal.test(z.Mean ~ t.Embryo_stage, data = STAT3_embryo_final_data)
Nanog_kruskal_wallis
write.csv(Nanog_kruskal_wallis[1:5], file = path)

TFCP2L1_kruskal_wallis <- kruskal.test(y.Mean ~ t.Embryo_stage, data = STAT3_embryo_final_data)
TFCP2L1_kruskal_wallis
write.csv(TFCP2L1_kruskal_wallis[1:5], file = path)


# Spatial reconstruction of in silico embryos

#Scatter plot of Nanog vs STAT 3 expression
ggplot(data = STAT3_embryo_final_data, mapping = aes(x = (C3_Mean_minus_background), y = (C4_Mean_minus_background))) +
  geom_point(aes(colour = Embryo_stage), size = 0.1)+
  scale_colour_viridis_d()+
  scale_fill_viridis_d()+
  labs(title = "STAT3 vs Nanog expression by Embryo stage", y = "Mean STAT3 protein level", x = "Mean Nanog protein level")  +
  theme(axis.text.x = element_text(size=12, angle=45, vjust=0.5), 
        axis.title.y = element_text(size=12, vjust = 0.5), 
        strip.text=element_text(size=10, angle=45),
        plot.title = element_text(hjust = 0.5, size = 15)) +
  theme(legend.position = "right")


# //////////////////////////////////////////////////////////////////////////////////////////////////////


# Plotting the cells back into the embryo
STAT3_embryo_final_data_E3.5 <- subset(STAT3_embryo_final_data, Embryo_stage %like% "E3.5")
STAT3_embryo_final_data_E4.5 <- subset(STAT3_embryo_final_data, Embryo_stage %like% "E4.5")
STAT3_embryo_final_data_Diapaused <- subset(STAT3_embryo_final_data, Embryo_stage %like% "Diapaused")


ggplot(STAT3_embryo_final_data_E4.5, aes(x = X_centre, y = Y_centre, colour = C4_IntDen_minus_background )) +
  geom_point(alpha = 10, size = 1)   +
  facet_wrap(~Embryo_number_and_stage, nrow = 10, ncol =6) +
  scale_colour_viridis(option = 'inferno') +
  theme_minimal() +
  coord_fixed()

# Need to subset data set and choose an embryo from each stage

# Plotly 3D graphs of the embryos coloured coded by transcription factor expression levels
STAT3_embryo_final_data_Diapaused_45 <- subset(STAT3_embryo_final_data, Embryo_number_and_stage %like% "Embryo_45_Diapaused")
STAT3_embryo_final_data_Diapaused_24 <- subset(STAT3_embryo_final_data, Embryo_number_and_stage %like% "Embryo_24_Diapaused")
STAT3_embryo_final_data_E3.5_12 <- subset(STAT3_embryo_final_data, Embryo_number_and_stage %like% "Embryo_12_E3.5")
STAT3_embryo_final_data_E3.5_2 <- subset(STAT3_embryo_final_data, Embryo_number_and_stage %like% "Embryo_2_E3.5")
STAT3_embryo_final_data_E4.5_27 <- subset(STAT3_embryo_final_data, Embryo_number_and_stage %like% "Embryo_27_E4.5")


plot_ly(data = STAT3_embryo_final_data_E3.5_2, x= ~X_centre, y= ~Y_centre, z= ~Z_centre, type="scatter3d", mode="markers", color= ~C4_IntDen_minus_background)


# Selecting points from the scatter plots and plotting back into the embryo to see where high STAT3 nuclei are located in the embryo 
ggplot(data = STAT3_embryo_final_data, mapping = aes(x = C3_IntDen_minus_background, y = C4_IntDen_minus_background)) +
  geom_point(aes(colour = Embryo_stage))+
  scale_colour_viridis_d()+
  scale_fill_viridis_d()+
  labs(title = "STAT3 expression by Embryo stage", y = "Mean STAT3 protein level", x = "Mean Nanog protein level")  +
  theme(axis.text.x = element_text(size=12, angle=45, vjust=0.5), 
        axis.title.y = element_text(size=12, vjust = 0.5), 
        strip.text=element_text(size=10, angle=45),
        plot.title = element_text(hjust = 0.5, size = 15)) +
  theme(legend.position = "right")

scatter_plot_data <- data.frame(STAT3_embryo_final_data %>% select(C3_IntDen_minus_background, C4_IntDen_minus_background))

plot(scatter_plot_data$C4_IntDen_minus_background, scatter_plot_data$C3_IntDen_minus_background)

# Select the high STAT3 points on the X axis using the polygon selection tool

plot(scatter_plot_data$C4_IntDen_minus_background, scatter_plot_data$C3_IntDen_minus_background)
High_STAT3_selectedPoints <- fhs(scatter_plot_data, mark = TRUE)
# 5 x 10^5 is a good cut off for the 'high' level of STAT3 expression
High_STAT3 <- data.frame(High_STAT3_selectedPoints)

High_STAT3_Vector <- as.vector(High_STAT3[,1])

High_STAT3_selection <- STAT3_embryo_final_data[STAT3_embryo_final_data$ID %in% High_STAT3_Vector, ]

High_STAT3_selection_Diapaused <- subset(High_STAT3_selection, Embryo_stage %like% "Diapaused")
ggplot(High_STAT3_selection_Diapaused, aes(x = X_centre, y = Y_centre, colour = C4_IntDen_minus_background )) +
  geom_point(alpha = 10, size = 1)   +
  facet_wrap(~Embryo_number_and_stage, nrow = 20, ncol = 8) +
  scale_colour_viridis(option = 'inferno') +
  theme_minimal() +
  theme(axis.text.x = element_text(size=3, angle=45, vjust=0.5), 
        axis.title.y = element_text(size=3, vjust = 0.5), 
        strip.text=element_text(size=5),
        plot.title = element_text(hjust = 0.5, size = 4)) +
  coord_fixed()
