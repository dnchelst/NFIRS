library("dplyr")
library("readr")
library("lubridate")
library("gdata")
library("stringr")

mdy2 <- function(time1) {
  time2 <- str_pad(time1, 8, side="left", pad="0")
  time3 <- mdy(time2)
  return(time3)
}
mdy_hms2 <- function(time1) {
  time2 <- str_pad(time1, 14, side="right", pad="0")
  time3 <- mdy_hms(time2)
  return(time3)
}

ReadAll <- function(file1, ncol, integer.columns=c(), time.columns=c()){
  file.col.types <- ncol %>% rep("c", .) %>% paste(collapse="")
  df <- read_delim(file1, delim="^", col_types=file.col.types)
  df <- trim(df)
  df[df==""] <- NA
  if(length(integer.columns) > 0){
    for(column1 in time.columns){
      df[[column1]] <- mdy_hms2(df[[column1]])
    }
  }
  if(length(time.columns) > 0){
    for(column1 in integer.columns){
      df[[column1]] <- as.integer(df[[column1]])
    }
  }
  if("INC_DATE" %in% names(df)){
    df <- mutate(df, INC_DATE=mdy2(INC_DATE))
  }
  if("VERSION" %in% names(df)){
    df <- select(df, -VERSION)
  }
  return(df)
}

ReadBasic <- function(basic.file){
  time.columns1 <- c("ALARM", "ARRIVAL", "LU_CLEAR")
  integer.columns1 <- grep("_(APP|LOSS|VAL|INJ|DEATH)", names(basic), value=TRUE)
  basic <- ReadAll(basic.file, 41, 
                   time.columns=time.columns1, integer.columns=integer.columns1)
  return(basic)
}

ReadFire <- function(fire.file){
  integer.columns1 <- c("NUM_UNIT", "BLDG_INVOL", "ACRES_BURN", "AGE", 
                       "BLDG_LGTH", "BLDG_WIDTH", "TOT_SQ_FT")
  fire <- ReadAll(fire.file, 80, integer.columns=integer.columns1)
  return(fire)
}

ReadCause <- function(cause.file){
  cause.header <- read.delim(cause.file, sep="^", header=FALSE, nrows=1)
  cause.header <- cause.header[1, ]
}
