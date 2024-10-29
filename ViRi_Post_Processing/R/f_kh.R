#------------------- ------------------- -------------------
# KH | Bailey
#------------------- ------------------- -------------------
#------------------
# h                   #W m-2 K-1
#------------------
#ka = 0.024#0.027715#0.024 #W/m/K  thermal conductivity # pressure, tempAir1m025 20220719 12:00: 1004.8 hPa, 312.145 K
#D = 0.012 #m berry diameter
# ka_t=function(temp) (0.02449*(temp/273.16)^(3/2) * (273.16+268.8)/(temp+268.8)) # old, Oxygen Braun et al.
## parameters from: VISCOUS FLUID FLOW, SECOND EDITION, Frank M. White, University of Rhode Island: Table 1.3
ka_t=function(temp) (0.0241*(temp/273)^(3/2) * (273+194)/(temp+194))
# ka_t(273.16)    #T in Kelvin
# ka_t(300)
delta <- function(U,D) {(0.0028*(D/U)^0.5 + 0.00025/U) * 15}   #effective boundary layer thickness

  
h <-  function(U,D,temp) {ka_t(temp+273.15)/delta(U,D) + 2*ka_t(temp+273.15)/D}
#h <-  function(U,D) {ka/delta(U,D) + 2*ka/D}

# h(0)
# h(1)
#plot(h(h(seq(0.1,10,by=0.1))))
#------------------

# max Delta T = 15 #°C
# # maxDT    <- 12
# KHfactor <- round(((max(d_lr2$netR)*1.1)*(1-0.23))/maxDT)  #   (m2/W)

# zwischen 6 und 7

#---------------------------------------------------------
