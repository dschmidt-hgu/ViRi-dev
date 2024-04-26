source("./R/packages.R")
source("./R/f_longwave.R")
source("./R/f_kh.R")
source("./R/processFiles_BS_fns2.R")

path_Viri_output="../ViRi_Output"
weather_minute="../ViRi_Input/T_minute_Geisenheim_Constant10MinuteWind_2023.csv"



latitude=49.98877101529701
longitude=7.932706870141822
yearOfSeason=2023
ViRiSetup="NS_LR1"

wind=0.4
threshold=50
changeTemp=c(0)
row_orientation= 162

## merge sim and weather data
raw_data=merge_sim_weather(outputFolder=path_Viri_output,
                           weather_file=weather_minute,
                           rowOrientation=row_orientation,
                           longitude=longitude,
                           latitude=latitude, 
                           yearOfSeason=yearOfSeason
)
# fwrite(raw_data, paste0("processed_files/SimAndWeatherData_merged_T_change_",changeTemp))
# raw_data=fread(paste0("processed_files/SimAndWeatherData_merged_T_change_",changeTemp))

data=copy(raw_data)

## compute berry surface temperature (BST)
data=computeBST(data, 
                temp_change=changeTemp,
                wind_m_s=wind,
                row_orientation=row_orientation,
                soil_emissivity = 0.95,
                plant_emissivity = 0.93,
                berry_emissivity = 0.9
)
## kick out Nas
data=data[complete.cases(data)]
data[, variante:=ViRiSetup]

# sunburn berry level per time step: fraction of berries burnt to total berries 
berry_burn=markSunburnBerry(data=data,minShortWaveDT=0,sunburnT=threshold)

# sunburn cluster level per time step: fraction of affected clusters to total clusters
cluster_burn=markSunburnCluster(data=data,minShortWaveDT=0,sunburnT=threshold)

# sunburn individual cluster level per time step: damage of every cluster per time step
# SBperCluster=getSBperCluster(data=data,minShortWaveDT=0,sunburnT=threshold)

burnColorBerry <- "#FF5C5C"
burnColorCluster <- "#FFA07A"


pBB <- ggplot(berry_burn
              , aes(x=time,y=sunburn_occur_frac*100))+
  geom_col(aes(y=sunburn_total_frac*100),fill="white",color="gray",position="dodge")+
  geom_col(fill=burnColorBerry,color="black",position="dodge")+
  scale_y_continuous(name="Berry sunburn (%)")+
  theme( plot.caption = element_markdown(lineheight = 1.2,hjust = 0))+
  facet_grid(variante~paste0(sunburnT,"°C"))

#ggsave(pBB,file="berryBurnStats.pdf",width=outWidth, height=outHeight, unit="cm")

# Clusters with Sunburn 
ggplot(cluster_burn
              , aes(x=time,y=sunburn_occur_frac*100))+
  geom_col(aes(y=sunburn_total_frac*100),fill="white",color="gray",position="dodge")+
  geom_col(fill=burnColorCluster,color="black",position="dodge")+
  scale_fill_viridis_c(option="plasma",end=0.8)+
  scale_y_continuous(name="Cluster sunburn (%)")

