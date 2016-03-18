---
output: pdf_document
---
# NFIRS
A collection of scripts to analyze NFIRS data

# R code (using Google style guide)
Packages include:  
* dplyr  
* readr  
* lubridate  
* gdata  
* stringr  

Functions:  
* mdy2, mdy_hms2 - timestamp parsing after padding with zeros  
* ReadNFIRS  
  + ReadAll  
  + ReadBasic  
  + ReadAddress  
  + ReadInjury  
  + ReadHazmat  


