library("dplyr")
library("readr")
library("lubridate")
library("gdata")

ReadAllChar <- function(file1, ncol){
  file.col.types <- ncol %>% rep("c", .) %>% paste(collapse="")
  df <- read_delim(file1, delim="^", col_types=file.col.types)
  df <- trim(df)
  df[df==""] <- NA
  return(df)
}

mdy_hms2 <- function(time1) {
  time2 <- str_pad(time1, 14, side="right", pad="0")
  time3 <- mdy_hms(time2)
  return(time3)
}

ReadBasic <- function(basic.file){
  basic <- ReadAllChar(basic.file, 41)
  time.columns <- c("ALARM", "ARRIVAL", "LU_CLEAR")
  integer.columns <- grep("_(APP|LOSS|VAL|INJ|DEATH)", names(basic), value=TRUE)
  for(column1 in time.columns){
    basic[[column1]] <- mdy_hms2(basic[[column1]])
  }
  for(column1 in integer.columns){
    basic[[column1]] <- as.integer(basic[[column1]])
  }
  return(basic)
}

ReadAddress <- function(address.file){
  address <- ReadAllChar(address.file, 17)
  address <- address %>%
    mutate(INC_DATE = mdy(INC_DATE))
  return(address)
}
