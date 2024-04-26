
#------------------------------------#------------------------------------#------------------------------------
# Cola Longwave
#------------------------------------#------------------------------------#------------------------------------


#https://en.wikipedia.org/wiki/Stefan%E2%80%93Boltzmann_constant
sigma                 <- 5.67e-8 # 0.0049 
# Stefan Boltzmann constant [0.0049 J m-2 day-1 K-4]   σSB = 5.67·10–8 W m–2 K–4  || 5.67e-8 * 24*3600 = 0.0049
#-----------------------------------------------------------------------------------------------
# # Parameters | Cola
#-----------------------------------------------------------------------------------------------
CO <- cloudCoverage   <- 0    #Cloud Coverage 0/1 0 = clear sky
exposition            <- 1    # berry facing south, no shade
skyViewParameter      <- 0.5  # constant
albedo                <- 0.1  # constant red berries

a                     <- 0.85       #Brunt Cloud Coverage
a0                    <- 0.44       #Brunt Parameter 
b0                    <- 0.08       #Brunt Parameter


kinematicViscosity    <- 1.4722*10^-5 # v # m²/s
Prandtl               <- 0.8          # Pr #  elsewhere 0.7
airDensity            <- 1.293        # p   # kg/m³
specificHeatCapacity  <- 1005         # Cp # J/kg/°C # air at constant pressure

Karman                <- 0.41 # k  

measurementHeight     <- 2   # Zh # of temperature and wind
rowsHeight            <- 1.7 # h # m
LAI                   <- 1.5 # 

p1                    <- 0.09    #Paper Fit instead of initial 0.3


RHx <- 1.0  #100% max rel humid
UH2 <- function(RHn) {RHn + (RHx-RHn)*0.35}

# Assumption RHn = 0.4
RHn <- 0.4
UH2 <- UH2(RHn)
UH2

diurnal_RH <- function(hh)
{
  0.5*(UH2 + RHn) + 0.5*(UH2-RHn)*sin((hh+6)*pi/12)
}

#Magnus Formula
#http://cires1.colorado.edu/~voemel/vp.html
#Guide to Meteorological Instruments and Methods of Observation (CIMO Guide)    (WMO, 2008)
E <- function(T) {6.112 * exp(17.62 * T / ( 243.12 + T ))}   # hPa = mbar

ea_hPa_mbar<- function(T, RH) {RH * E(T)} #°C and RH in fraction ->> mbar

ea_hPa_mbar(T=30,RH=diurnal_RH(16))

ea_hPa_mbar_T <- function(T) {ea_hPa_mbar(T=T,RH=mean(diurnal_RH(8:18)))}


ea  <- ea_hPa_mbar_T         #mbar 


factor_longwaveRadiation <- function(T) {(1 - a0 - b0*(ea(T)^0.5))*(1-a*CO)}
range(factor_longwaveRadiation(0:40))

longwaveRadiation <- function(AT) {-sigma*(AT + 273.02)^4 *factor_longwaveRadiation(T)}   #[J m-2 h-1] -->> NUN J/(m2s)

longwaveRadiation(40)


