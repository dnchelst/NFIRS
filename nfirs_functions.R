library("readr")
library("lubridate")
library("gdata")

ReadBasic <- function(basic.file){
  basic.col.types <-  rep("c", 41)
  basic.col.types <- paste(basic.col.types, collapse="")
  
  basic <- read_delim(basic.file, delim="^", col_types=basic.col.types)
  mdy_hms2 <- function(time1) {
    time2 <- str_pad(time1, 14, side="right", pad="0")
    time3 <- mdy_hms(time2)
    return(time3)
  }
  
  basic <- trim(basic)
  basic[basic==""] <- NA
  time.columns <- c("ALARM", "ARRIVAL", "LU_CLEAR")
  integer.columns <- grep("_(APP|LOSS|VAL|INJ|DEATH)", names(basic), value=TRUE)
  for(column1 in time.columns){
    basic[[column1]] <- mdy_hms2(basic[[column1]])
  }
  for(column1 in integer.columns){
    basic[[column1]] <- as.integer(basic[[column1]])
  }
}

