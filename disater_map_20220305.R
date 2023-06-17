# File:    map_disaster_v1
# Data:    floodcount.csv
# Date:    2022-03-05

# CHECK AND SET WORK DIRECTORY 
getwd()
setwd("/Users/qly/Desktop/Research Assistant/disaster_map")

# LOAD PACKAGES
library("ggplot2") 
library("sp") 
library("raster") 
library("broom") 
library("rvest")  
library("stringr") 
library("scales")
library(rgdal)
library(maptools)
library(geodata)
if (!require(gpclib)) install.packages("gpclib", type="source")
gpclibPermit()

# CHECK LOAD PACKAGES
(.packages())

# READ IN THE COUNT DATA
floodcount <- read_csv("floodcount.csv")

# get town level data from GADM dataset
jpn2 = getData("GADM", country = "JPN", level = 2) # town

class(jpn2)
View(jpn2)
jpn2@data[["NAME_2"]]

# convert the data to df format
jpn2_df = tidy(jpn2, region = "NAME_2")


# clean dataset names ----

#  select Aisho to extract the o (small) with bar accent 
accent_o = unique(jpn2_df$id)[19]
accent_o
# subset fifth letter (from 5th to 5th)
accent_o = str_sub(accent_o, 5, 5) 
accent_o
jpn2_df$id = str_replace_all(jpn2_df$id, accent_o, "o")
jpn2_df$group = str_replace_all(jpn2_df$group, accent_o, "o")

#  select Chuou to extract the u (small) with bar accent 
accent_u = unique(jpn2_df$id)[127]
# subset third letter (from 3rd to 3rd)
accent_u = str_sub(accent_u, 3, 3) 
jpn2_df$id = str_replace_all(jpn2_df$id, accent_u, "u")
jpn2_df$group = str_replace_all(jpn2_df$group, accent_u, "u")

#  select Oitsu to extract the O (capital) with bar accent 
accent_O = unique(jpn2_df$id)[1112]
# subset first letter (from 1st to 1st)
accent_O = str_sub(accent_O, 1, 1) 
jpn2_df$id = str_replace_all(jpn2_df$id, accent_O, "O")
jpn2_df$group = str_replace_all(jpn2_df$group, accent_O, "O")

accent_i = unique(jpn2_df$id)[1213]
accent_i = str_sub(accent_i, 3, 3)
jpn2_df$id = str_replace_all(jpn2_df$id, accent_i, "i")
jpn2_df$group = str_replace_all(jpn2_df$group, accent_i, "i")

write.dta(jpn2_df,"jpn2_df_full.dta")


## merge data
Total<-merge(jpn2_df,floodcount,by="id",all=T)

## plot
ggplot() +
  geom_polygon(data = Total,
               aes(x = long, y = lat, group = groupid, fill = period_1619_max)) +
  scale_fill_gradient2(low = "white", mid="red2",high = "black",  midpoint = 2,limits=c(0,4),name = "level") +
  xlab("") + ylab("") +ggtitle("2011-2015\n 1=low, 2=medium, 3=high")+
  coord_equal() +
  theme_void() +
  theme(legend.position = "right", legend.box = "vertical",
        legend.direction = "vertical",
        legend.key.size = unit(0.5, "cm"))+
  geom_polygon(data=jpn2_df,aes(x=long,y=lat,group=group),fill="white",alpha = 0.1,colour="grey10",size=0.0000000001)



# CLEAN UP 

# Clear packages
invisible(lapply(paste0("package:", names(sessionInfo()$otherPkgs)),
                 detach,
                 character.only = TRUE, unload = TRUE))

# Clear plots
dev.off()  

# Clear console
cat("\014")

