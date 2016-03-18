# NFIRS
A collection of scripts to analyze aggregated National Fire Incident Reporting system 
[(NFIRS)](https://www.nfirs.fema.gov/) data supplied by [FEMA](https://www.fema.gov). 

# R code (using Google style guide)
Packages required:  
* dplyr  
* readr  
* lubridate  
* gdata  
* stringr  

Functions written:  
* mdy2, mdy_hms2 - timestamp parsing after padding with zeros  
* ReadNFIRS  
  + ReadAll  
  + ReadBasic  
  + ReadAddress  
  + ReadInjury  
  + ReadHazmat  

2014 Data available by mail on CD by request from FEMA. Compressed copies are available on AWS in the following formats
[(7zip)](https://s3.amazonaws.com/cpsm.nfirs/NFIRS-2014/NFIRS2014.7z)
[(RData)](https://s3.amazonaws.com/cpsm.nfirs/NFIRS-2014/NFIRS2014.RData).
