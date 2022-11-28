# File to download NFIRS files from FEMA
library(httr)

primary.url <- file.path("https://fema.gov/about/reports-and-data/openfema")

url.version1 <- "usfa_nfirs_year.zip"
url.version2 <- "nfirs_all_incident_pdr_year.zip"
options(timeout = max(300, getOption("timeout")))
for (year1 in 2014:2021){
  url.version <- if_else(year1 < 2020, url.version1, url.version2)
  url.version <- str_replace(url.version, "year", as.character(year1))
  total.url <- file.path(primary.url, url.version)
  if(!file.exists(url.version)){
    download.file(total.url, destfile = url.version, mode="wb")
  }
}


