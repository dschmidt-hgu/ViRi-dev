
getSkyEmissivity <- function(temperature, humidity) {
  temperature = temperature + 273.15
  ##Model from Prata (1996) Q. J. R. Meteorol. Soc.
  
  e0 = 611*exp(17.502*(temperature-273.15)/((temperature-273.15)+240.9))*humidity ##Pascals
  
  K = 0.465 ##cm-K/Pa
  
  xi = e0/temperature*K
  eps = 1-(1+xi)*exp(-sqrt(1.2+3*xi))
  return(eps)
}

# netR to BerryT
BT <- function(netR_wm2,AT,KH, BHS) {
  # 23% storage # Cola
  surfaceActiveRadiation <- netR_wm2 * (1-BHS)
  #KH <- KHfactor # round(((450*1.1)*(1-0.23))/15)    (m2/W)
  deltaT <- surfaceActiveRadiation/KH
  BT <- deltaT + AT
  return(BT)
}

get_lrSky=function(boltzmann=5.670374419*10^-8) {
  return(berry_emissivity*boltzmann*(formFactorSky*sky_emissivity*(rav_tempAir2m + 273.15)^4))
}

get_lrGround=function(boltzmann=5.670374419*10^-8) {
  return(berry_emissivity*boltzmann*(formFactorGround*soil_emissivity*(rav_tempSoil5cm + 273.15)^4))
}

get_lrPlant=function(boltzmann=5.670374419*10^-8) {
  return(berry_emissivity*plant_emissivity*boltzmann*((1-(formFactorSky+formFactorGround))*(rav_tempAir1_025m + 273.15)^4))
}

get_lrBerry=function(boltzmann=5.670374419*10^-8) {
  return((-berry_emissivity*boltzmann*(rav_tempAir1_025m + 273.15)^4))
}

get_radiation <- function(data) {
  return(
    data[, sumPAR_NIR_Wm2]
    + get_lrSky(data)
    + get_lrGround(data)
    + get_lrPlant(data)
    + get_lrBerry(data)
  )
}


## process one scenario
processFiles <- function(meta, data, weather, analyzeThesePlants, row_orientation, longitude, latitude, yearOfSeason, temp_change=0)
{
  meta <- fread(meta) # 
  data <- fread(data) # 
  weather <- fread(weather)
  
  meta <- meta[dayOfYear%in%data[,unique(dayOfYear)]]
  

  data <- meta[data, on = c("id", "dayOfYear")] # , nomatch = 0L, mult = "last"
  
  data <- data[plant%in%analyzeThesePlants]
  
  ## GroIMP time in H:M
  #data$time <- as.POSIXct(data$time, format="%H:%M",tz='UTC') 
  data[,"time":=hour+minute/60] 
  
  ## make GroIMP noon identical with local noon UTC time
  ## plus local_noon_minute_difference (negative in August)
  local_noon_minute_difference= 60-minute(round(solarnoon(matrix(c(longitude,latitude), nrow = 1),
                                                          as.POSIXct(as.Date(data[,unique(dayOfYear)]-1, origin=paste0(yearOfSeason,"-01-01")), tz = "UCT"),
                                                          POSIXct.out=TRUE)$time,"mins"))
  
  data[,"time":=time-local_noon_minute_difference/60]
  data[, hour:=floor(time)]
  data[, minute:=round((time-floor(time))*60,2)]
  
  
  # Radius
  data[,"diameter":=2*radius]
  data[,"circle_area":=pi*radius^2]
  
  # SW || NEW Area /2
  # Cola '60% of the whole berry surface.'
  fraction_area <- 1#0.6
  
  dt_solar <- data[isLongwave==F]
  dt_lw <- data[isLongwave==T]
  
  dt_solar[, parAbs_Wm2:= (specX*3*0.47)/(area*fraction_area)]
  dt_solar[, nirAbs_Wm2:= (specY*3*0.53)/(area*fraction_area)]
  dt_solar[, sumPAR_NIR_Wm2:= parAbs_Wm2 + nirAbs_Wm2]
  dt_solar <- dt_solar[,list(specX,specY,specZ,id, dayOfYear, inputDirectSR_Wm2, inputDiffuseSR_Wm2, plant, clusterNumber,x,y,z, time, hour, minute, area, radius, 
                             diameter, circle_area, parAbs_Wm2, nirAbs_Wm2 , sumPAR_NIR_Wm2)] # , sunAzimuth, sunBeta
  
  
  dt_lw[skyOrGround=="sky", lrSkyAbs:= (specZ*3)/(area*fraction_area)]
  dt_lw[skyOrGround=="ground", lrGroundAbs:= (specZ*3)/(area*fraction_area)]
  
  ## restrict factor to max = 0.5 (restriction necessary since GroIMP objects affect LR radiation even with full abs Phong)
  ## 25% of incoming radiation can max be absorbed by sphere fully exposed to light (no obstacles for light rays)
  dt_lw[skyOrGround=="sky", formFactorSky:= ifelse(lrSkyAbs/(inputLWSky_Wm2*0.25)>1, 0.5, (lrSkyAbs/(inputLWSky_Wm2*0.25))*0.5)]
  dt_lw[skyOrGround=="ground", formFactorGround:= ifelse(lrGroundAbs/(inputLWGround_Wm2*0.25)>1, 0.5, (lrGroundAbs/(inputLWGround_Wm2*0.25))*0.5)]
  
  ## put row info into columns to get rid of sun, sky, ground rows
  dt_lw[, lrSkyAbs:= sum(lrSkyAbs, na.rm = T), by=list(id, time)]
  dt_lw[, lrGroundAbs:= sum(lrGroundAbs,na.rm = T), by=list(id, time)]
  dt_lw[, formFactorSky:= sum(formFactorSky,na.rm = T), by=list(id, time)]
  dt_lw[, formFactorGround:= sum(formFactorGround,na.rm = T), by=list(id, time)]
  # ==sky: drop second row per id, all info in columns
  dt_lw <- dt_lw[skyOrGround=="sky", list(id, plant, clusterNumber, time, hour, minute, area, radius, diameter, circle_area, lrSkyAbs, lrGroundAbs, 
                                          formFactorSky, formFactorGround)] # , sunAzimuth, sunBeta
  
  #data <- merge(dt_solar, dt_lw)
  data <- merge(dt_solar, dt_lw, by = intersect(names(dt_solar), names(dt_lw)))
  
  ## Load weather data which has not been used in ViRi
  weather <- weather[doy%in%unique(data$dayOfYear)]  
  # weather[dateTime=="2023-08-10 14:43:00", tempAir1_025m] # OK
  weather <- weather[, c("doy", "hour", "minute", "temp2m", "temp5cm", "tempAir1_025m", "tempSoil5cm", "humid2m", "wind", "wind_direction", "u", "v")]
  weather[, dayOfYear:= doy]
  weather$doy <- NULL
  weather[, tempAir2m:= temp2m]
  weather$temp2m <- NULL
  weather[, tempAir5cm:= temp5cm]
  weather$temp5cm <- NULL
  

  ## determin ks for rolmean fn coming from GroIMP model
  ## k for time data (temp)
  k_timepoint = floor(mean((diff(data[, unique(time)])*60)))#as.numeric(floor(mean(diff(data[, unique(dateTime)]))))
  cat("k_timepoint: ")
  print(k_timepoint)
  ## k for average data (wind of 10 minutes before)
  k_10minAverage = floor(mean((diff(data[, unique(time)])*60))) - 10#as.numeric(floor(mean(diff(data[, unique(dateTime)])))) - 10
  cat("k_10minAverage: ")
  print(k_10minAverage)
  ## k for average data (wind of 15 minutes before)
  k_15minAverage = floor(mean((diff(data[, unique(time)])*60))) - 15#as.numeric(floor(mean(diff(data[, unique(dateTime)])))) - 10
  cat("k_15minAverage: ")
  print(k_15minAverage)
  


  ## DWD data
  weather[, rav_tempAir2m:=rollmean(tempAir2m, k=k_timepoint,fill=NA,align="center")]
  weather[, rav_tempAir5cm:=rollmean(tempAir5cm, k=k_timepoint,fill=NA,align="center")]
  weather[, rav_tempAir1_025m:=rollmean(tempAir1_025m, k=k_timepoint,fill=NA,align="center")]
  weather[, rav_tempSoil5cm:=rollmean(tempSoil5cm, k=k_timepoint,fill=NA,align="center")]
  weather[, rav_humid2m:=rollmean(humid2m, k=k_timepoint,fill=NA,align="center")]
  ## scalar average wind speed
  weather[, rav_wind:=rollmean(wind, k=k_10minAverage,fill=NA,align="center")]
  weather[, rav_u:=rollmean(u, k=k_10minAverage,fill=NA,align="center")]
  weather[, rav_v:=rollmean(v, k=k_10minAverage,fill=NA,align="center")]
  weather[, rav_wind_direction:=(atan2(rav_u, rav_v)*360/2/pi)+180]


  
  # TODO: doy if multiple days simulated??
  data <- merge(data, weather, by=c("dayOfYear", "hour","minute"))
   
  return(data)
}		

computeBST=function(data, temp_change, wind_m_s, row_orientation, soil_emissivity, berry_emissivity, plant_emissivity, reduce_wind_by=0) {
  
  data[, sky_emissivity := getSkyEmissivity(rav_tempAir2m, rav_humid2m)]
  data[, soil_emissivity := soil_emissivity]
  data[, plant_emissivity := plant_emissivity]
  data[, berry_emissivity := berry_emissivity]
  
  ## climate scenario temperature modifications
  data[,rav_tempAir2m:=rav_tempAir2m+temp_change]
  data[,rav_tempAir5cm:=rav_tempAir5cm+temp_change]
  data[,rav_tempAir1_025m:=rav_tempAir1_025m+temp_change]
  data[,rav_tempSoil5cm:=rav_tempSoil5cm+temp_change]
  
  data[, "netR":= radiation(
    parAbs=parAbs_Wm2,
    nirAbs=nirAbs_Wm2,
    sky_emissivity = sky_emissivity, # model from Prata  #-14.72
    soil_emissivity = soil_emissivity, #0.95,
    plant_emissivity= plant_emissivity, #0.93,#0.93,
    boltzmann=5.670374419*10^-8,
    formFactorSky=formFactorSky,
    formFactorGround=formFactorGround,
    tempAir2m_Celsius=rav_tempAir2m,  #-14.72
    tempSoil5cm_Celsius=rav_tempSoil5cm, # -14.72
    tempAir1_025m_Celsius = rav_tempAir1_025m,
    berry_emissivity=berry_emissivity)] # 0.9)]
  
  
  ## clusterid used in Dom's cluster_burn fn
  #data[,"clusterid":=clusterNumber]
  data[,"KH":=h(U=wind_m_s,D=diameter,temp=rav_tempAir1_025m)]#,temp=rav_tempAir1_025m # wind_m_s = fn argument # rav_wind = DWD data  # wind_mod = modified DWD data # rav_wind = rolling average DWD data
  data[, "BerryT":= BT(netR_wm2=netR,AT=rav_tempAir1_025m,KH=KH, BHS=0.31)] # tempAir1_025m  # Th= 52.5°, BHS = 0.725  # Th=50°, BHS = 0.775
  data[, sensibleHeat:= KH*(BerryT-rav_tempAir1_025m)]
  
}

radiation <- function(parAbs, nirAbs, sky_emissivity, soil_emissivity, plant_emissivity, boltzmann, formFactorSky, formFactorGround, tempAir2m_Celsius, tempSoil5cm_Celsius, tempAir1_025m_Celsius, berry_emissivity) {
  tempAir2m <- tempAir2m_Celsius + 273.15 
  tempSoil5cm <- tempSoil5cm_Celsius + 273.15  
  tempAir1_025m <-  tempAir1_025m_Celsius + 273.15
  return(
    ## absorbed PAR from 3d model
    parAbs +
      ## absorbed NIR from 3d model
      nirAbs +
      ## total absorbed LR from sky and ground (minus emitted power of berry related to LR sky and ground)   
      (berry_emissivity*boltzmann*(formFactorSky*sky_emissivity*tempAir2m^4 + formFactorGround*soil_emissivity*tempSoil5cm^4) + # tempSoil5cm
         ## total absorbed LR from other plant organs (minus emitted power of berry related to LR plant)          
         berry_emissivity * plant_emissivity*boltzmann*((1-(formFactorSky+formFactorGround))*(tempAir1_025m)^4)) - 
      ## emitted LR power of berry          
      (1*berry_emissivity*boltzmann*(tempAir1_025m)^4)) 
}


## process all scenarios
merge_sim_weather = function(outputFolder, weather_file, numberOfPlantsPerSimulation=25, rowOrientation,
                             longitude, latitude, yearOfSeason, temp_change=0) {
  
  sim_data <- data.table()
  
  filenames <- 
    list.files(outputFolder, 
               pattern=paste0("Berries", ".*.csv"), full.names=TRUE) #"-", day, ".*.csv"     "-[2|3][9|0].*.csv"
  for (f in 1:(length(filenames)/2)) {  # length(filenames)/2
    
    data <- processFiles(meta=filenames[f], 
                         data=filenames[f+(length(filenames)/2)], 
                         weather=weather_file,
                         analyzeThesePlants=c(6,7,8,11,12,13,16,17,18),
                         row_orientation = rowOrientation,
                         longitude=longitude,
                         latitude=latitude, 
                         yearOfSeason=yearOfSeason)
    ## modify plant number with simulation number f: all clusters of all simulations shall be unique in scenario simulations 
    data[, plant:= plant + (f-1)*numberOfPlantsPerSimulation]
    ## modify id to be able to reconstruct vineyard with berries including berry sunburn and all other information (id in GroIMP randomly chosen, not in use) 
    data[, id:=paste0(plant,"_",id)]
    ## clusterNumber and id same thing: important, must be unique in scenario simulations (different in tests, e.g. light ray tests, see other scripts similar loop)
    ## following line gives: plant_berryID_clusterNumber; including info: plant= simulation and plant with objectInfo, id=berry with objectInfo, clusterNumber= cluster with objectInfo  
    data[, clusterNumber:= paste0(plant,"_",clusterNumber)]
    data[, clusterid:=clusterNumber]
    data[, sim:=f]
    sim_data <- rbindlist(list(sim_data, data))
  }
  return(sim_data)
}

# Estimate Sunburn Function
markSunburnBerry <- function(data,minShortWaveDT,sunburnT, boltzmann=5.670374419*10^-8)
{
  data <- copy(data)
  data[,"enoughSW":=sumPAR_NIR_Wm2 > minShortWaveDT*KH]  #1°C
  data[,"sunburn":=BerryT>(sunburnT) & enoughSW == TRUE]
  
  nBerries <- length(unique(data[variante==variante[1]]$id))
  
  data[sunburn==TRUE,"sunburn_time":=min(time),by=c("id","variante")]		
  
  data[,"sunburn":=BerryT>(sunburnT) & enoughSW == TRUE & sunburn_time == time]
  
  sunburn_summary <- data[,list("sunburn_occur_frac"=sum(sunburn)/nBerries,
                                plant=plant,
                                clusterNumber=clusterNumber,
                                sim=sim, 
                                x=x, 
                                y=y, 
                                z=z,
                                "radius"=radius,
                                "sunburn"=sunburn,
                                ## unique not necessary here
                                "rav_wind"=unique(rav_wind),
                                "rav_wind_direction"=unique(rav_wind_direction),
                                "rav_tempAir2m"=unique(rav_tempAir2m),
                                "rav_tempAir1_025m"=unique(rav_tempAir1_025m),
                                "rav_tempAir5cm"=unique(rav_tempAir5cm),
                                "rav_tempSoil5cm"=unique(rav_tempSoil5cm),
                                "rav_humid2m"=unique(rav_humid2m),
                                "lrGround"=berry_emissivity*boltzmann*(formFactorGround*soil_emissivity*(rav_tempSoil5cm + 273.15)^4),#get_lrGround(),
                                "lrSky"=berry_emissivity*boltzmann*(formFactorSky*sky_emissivity*(rav_tempAir2m + 273.15)^4),#get_lrSky(),
                                "lrPlant"=berry_emissivity*plant_emissivity*boltzmann*((1-(formFactorSky+formFactorGround))*(rav_tempAir1_025m + 273.15)^4),#get_lrPlant(),
                                "lrBerry"=(-berry_emissivity*boltzmann*(rav_tempAir1_025m + 273.15)^4)#get_lrBerry()),
                                ,
                                "parAbs_Wm2"=parAbs_Wm2,
                                "nirAbs_Wm2"=nirAbs_Wm2,
                                "sumPAR_NIR_Wm2"=sumPAR_NIR_Wm2,
                                "formFactorSky"=formFactorSky,
                                "formFactorGround"=formFactorGround,
                                # if("sunAzimuth" %in% colnames(data)){
                                #   sunAzimuth=unique(sunAzimuth)  
                                # },
                                # sunAzimuth=unique(sunAzimuth),
                                # sunBeta=unique(sunBeta),
                                "inputDirectSR_Wm2"=unique(inputDirectSR_Wm2),
                                "inputDiffuseSR_Wm2"=unique(inputDiffuseSR_Wm2)
                                ),
                                by=c("id","time","variante")]
  
  sunburn_summary[,"sunburn_total_frac":=c(cumsum(sunburn_occur_frac)),by="variante"]							 
  sunburn_summary[,"minShortWaveDT":=minShortWaveDT]
  sunburn_summary[,"sunburnT":=sunburnT]
  
  return(sunburn_summary)
}

markSunburnCluster <- function(data,minShortWaveDT,sunburnT)
{
  
  data <- copy(data)
  #data[,"enoughSW":=T]  #1°C
  #data[,"enoughSW":=sumPAR_NIR_Wm2 > 9]  #1°C
  data[,"enoughSW":=sumPAR_NIR_Wm2 > minShortWaveDT*KH]  #1°C
  data[,"sunburn":=BerryT>(sunburnT) & enoughSW == TRUE]
  
  nBerries <<- length(unique(data[variante==variante[1]]$id))
  nCluster <<- length(unique(data[variante==variante[1]][time ==time[1]]$clusterid))
  
  data[sunburn==TRUE,"sunburn_time":=min(time),by=c("id","variante")]		
  data[,"sunburn":=BerryT>(sunburnT) & enoughSW == TRUE & sunburn_time == time]
  
  # mark cluster sunburn
  
  data[,"cluster_burn":=sum(sunburn)>0,by=c("clusterid","time","variante")]
  data[cluster_burn==TRUE,"cluster_burn_time":=min(time),by=c("clusterid","variante")]		
  
  data[,"cluster_burn":=sum(sunburn)>0 & cluster_burn_time==time
       ,by=c("clusterid","time","variante")]
  
  
  sunburn_summary_cluster <- data[!duplicated(paste0(cluster_burn,clusterid,variante,time))]
  ## Chris 20231121: adding time step (interval) data
  sunburn_summary <- sunburn_summary_cluster[,list("rav_wind"=unique(rav_wind),
                                                   "rav_wind_direction"=unique(rav_wind_direction),
                                                   "rav_tempAir2m"=unique(rav_tempAir2m),
                                                   "rav_tempAir1_025m"=unique(rav_tempAir1_025m),
                                                   "rav_tempAir5cm"=unique(rav_tempAir5cm),
                                                   "rav_tempSoil5cm"=unique(rav_tempSoil5cm),
                                                   "rav_humid2m"=unique(rav_humid2m),
                                                   #"max_angle"=unique(max_angle),
                                                   #"wind_direction"=unique(wind_direction),
                                                   "sunburn_occur_frac"=sum(cluster_burn)/nCluster
                                                   # ,
                                                   #"max_BerryHeight"=max(z),
                                                   # "sunAzimuth"=unique(sunAzimuth),
                                                   # "sunBeta"=unique(sunBeta)
                                                   ),
                                             by=c("time","variante")]
  
  # sunburn_summary <- sunburn_summary_cluster[,list("sunburn_occur_frac"=sum(cluster_burn)/nCluster),
  #                                            by=c("time","variante")]
  
  sunburn_summary[,"sunburn_total_frac":=c(cumsum(sunburn_occur_frac)),by="variante"]							 
  sunburn_summary[,"minShortWaveDT":=minShortWaveDT]
  sunburn_summary[,"sunburnT":=sunburnT]
  
  return(sunburn_summary)
}

getSBperCluster = function(data=data,minShortWaveDT=0,sunburnT=threshold) {
  ## sunburn
  
  ## give berry TRUE which exceeds threshold, will be modified in third next line
  data[,"sunburn":=BerryT>(sunburnT)]
  data[, totBerries:= .N, by=c("clusterNumber", "time")]
  
  ## sunburn = T only at first occurrence
  data[sunburn==TRUE,"sunburn_time":=min(time),by=c("id","clusterNumber")]	
  ## give berry TRUE only at time of occurrence
  data[,"sunburn":=BerryT>(sunburnT) & sunburn_time == time]
  ## sum of berries per cluster which were newly burned at given time
  data[, totBurnedOnlyAtTime:= sum(sunburn==T), by=c("clusterNumber", "time")] 
  
  ## in data:
  # [1] "dayOfYear"          "hour"               "minute"             "id"                 "plant"              "clusterNumber"      "time"              
  # [8] "area"               "radius"             "diameter"           "circle_area"        "specX"              "specY"              "specZ"             
  # [15] "inputDirectSR_Wm2"  "inputDiffuseSR_Wm2" "x"                  "y"                  "z"                  "parAbs_Wm2"         "nirAbs_Wm2"        
  # [22] "sumPAR_NIR_Wm2"     "sunAzimuth"         "sunBeta"            "lrSkyAbs"           "lrGroundAbs"        "formFactorSky"      "formFactorGround"  
  # [29] "tempAir1_025m"      "tempSoil5cm"        "humid2m"            "wind"               "wind_direction"     "u"                  "v"                 
  # [36] "tempAir2m"          "tempAir5cm"         "rav_tempAir2m"      "rav_tempAir5cm"     "rav_tempAir1_025m"  "rav_tempSoil5cm"    "rav_humid2m"       
  # [43] "rav_wind"           "rav_u"              "rav_v"              "rav_wind_direction" "clusterid"          "sim"   
  
  cluster <- data[, .(dayOfYear=unique(dayOfYear),
                      plant=unique(plant),
                      totBerries=unique(totBerries), 
                      totBurnedOnlyAtTime=unique(totBurnedOnlyAtTime), 
                      sim=unique(sim), 
                      x=mean(x), 
                      y=mean(y), 
                      z=mean(z), 
                      z_min=min(z),
                      z_max=max(z), 
                      parAbs_Wm2=mean(parAbs_Wm2),
                      parAbs_Wm2_min=min(parAbs_Wm2),
                      parAbs_Wm2_max=max(parAbs_Wm2),
                      nirAbs_Wm2=mean(nirAbs_Wm2),
                      nirAbs_Wm2_min=min(nirAbs_Wm2),
                      nirAbs_Wm2_max=max(nirAbs_Wm2),
                      sumPAR_NIR_Wm2=mean(sumPAR_NIR_Wm2),
                      sumPAR_NIR_Wm2_min=min(sumPAR_NIR_Wm2),
                      sumPAR_NIR_Wm2_max=max(sumPAR_NIR_Wm2),
                      lrSkyAbs=mean(lrSkyAbs),
                      lrSkyAbs_min=min(lrSkyAbs),
                      lrSkyAbs_max=max(lrSkyAbs),
                      lrGroundAbs=mean(lrGroundAbs),
                      lrGroundAbs_min=min(lrGroundAbs),
                      lrGroundAbs_max=max(lrGroundAbs),
                      formFactorSky=mean(formFactorSky),
                      formFactorSky_min=min(formFactorSky),
                      formFactorSky_max=max(formFactorSky),
                      formFactorGround=mean(formFactorGround),
                      formFactorGround_min=min(formFactorGround),
                      formFactorGround_max=max(formFactorGround),
                      rav_wind=unique(rav_wind),
                      rav_wind_direction=unique(rav_wind_direction),
                      rav_u=unique(rav_u),
                      rav_v=unique(rav_v),
                      rav_tempAir2m=unique(rav_tempAir2m),
                      rav_tempAir1_025m=unique(rav_tempAir1_025m),
                      rav_tempAir5cm=unique(rav_tempAir5cm),
                      rav_tempSoil5cm=unique(rav_tempSoil5cm),
                      rav_humid2m=unique(rav_humid2m),
                      # if("sunAzimuth" %in% colnames(data)){
                      #   sunAzimuth=unique(sunAzimuth)  
                      # },
                      # sunAzimuth=unique(sunAzimuth),
                      # sunBeta=unique(sunBeta),
                      inputDirectSR_Wm2=unique(inputDirectSR_Wm2),
                      inputDiffuseSR_Wm2=unique(inputDiffuseSR_Wm2)
                      
  ),
  by = .(clusterNumber, time, variante)]
  
  cluster[,cumSumBurned:= cumsum(totBurnedOnlyAtTime), by=c("clusterNumber")]
  cluster[, damage:=cumSumBurned/totBerries, by=c("clusterNumber")]

 return(cluster) # all_damage
}

