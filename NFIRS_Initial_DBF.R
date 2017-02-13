library(foreign)

# the next two lines are not for generic use - start below
project.name <- "CPSM/NFIRS" 
data.dir <- ProjectDir(project.name) 
# switch to your own directory
setwd(data.dir) 
# if data is not downloaded
DownloadNFIRS <- function(){
  url1 <- "https://www.fema.gov/media-library-data"
  zip.files <- list(year.2010="20130726-2124-31471-2156/nfirs_2010_100711.zip",
                    year.2011="20130726-2126-31471-8394/nfirs_2011_120612.zip")
  download.file(file.path(url1, zip.files$year.2010), destfile="NFIRS-2010.zip")
  unzip("NFIRS-2010.zip", exdir="NFIRS-2010")
  download.file(file.path(url1, zip.files$year.2011), destfile="NFIRS-2011.zip")
  unzip("NFIRS-2011.zip", exdir="NFIRS-2011")
}
# DownloadNFIRS()
# read in fire department registry downloaded from
# https://apps.usfa.fema.gov/registry-download/main/download
registry.file <- list.files(pattern="registry", full.names=TRUE)
registry <- read_csv(registry.file) %>% FixData # 3 lines fixed manually




# assume that NFIRS2011 and 2010 data are in a subfolder
ReadNFIRSOld <- function(sub.dir1){
  dbf.files <- list.files(path=sub.dir1, pattern="dbf$", ignore.case=TRUE)
  nfirs <- list()
  for(file1 in dbf.files){
    print(paste(file1, Sys.time()))
    file2 <- gsub("[.].*", "", file1)
    df <- file.path(sub.dir1, file1) %>% read.dbf(as.is=TRUE) %>%
      FixData
    if(! file2 %in% c("fdheader", "legacyfields", "codelookup")){
      df <- mutate(df, inc.date=mdy(inc.date))
    }
    nfirs[[file2]] <- df
  }
  
  # clean up basic incident file and civilian file
  ZeroToNA <- function(x){ifelse(x==0, NA, x)}
  nfirs$basicincident <- nfirs$basicincident %>%
    mutate_at(vars(alarm, arrival, lu.clear), ZeroToNA) %>%
    mutate_at(vars(alarm, arrival, lu.clear), mdy_hm)
  nfirs$civilian <- nfirs$civilian %>%
    mutate(inj.dt.tim = ZeroToNA(inj.dt.tim),
           inj.dt.tim = mdy_hm(inj.dt.tim))
  nfirs$ffcasualty <- nfirs$ffcasualty %>% 
    mutate(inj.date = ZeroToNA(inj.date),
           inj.date = mdy_hm(inj.date))
  return(nfirs)
}

nfirs <- ReadNFIRSOld("NFIRS-2011")
save(nfirs, registry, file="NFIRS-2011/NFIRS2011.RData")
nfirs <- ReadNFIRSOld("NFIRS-2010")
save(nfirs, registry, file="NFIRS-2010/NFIRS2010.RData")




