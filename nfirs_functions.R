library(tidyverse)
library(gdata)

mdy2 <- function(time1) {
  time2 <- time1 %>% 
    str_pad(8, side="left", pad="0") %>% 
    mdy
  return(time2)
}
mdy_hms2 <- function(time1) {
  time2 <- time1 %>% 
    str_pad(14, side="right", pad="0") %>% 
    mdy_hms
  return(time2)
}

ReadAll <- function(file1, integer.columns=c(), time.columns=c()){
  df.small <- read_delim(file1, delim="^", n_max=1)
  ncol <- ncol(df.small)
  file.col.types <- ncol %>% rep("c", .) %>% paste(collapse="")
  df <- read_delim(file1, delim="^", col_types=file.col.types) %>% 
    trim %>% 
    na_if("")
  #df <- trim(df)
  #df[df==""] <- NA
  column.names <- names(df)
  if(length(time.columns) > 0){
    time.columns <- intersect(time.columns, column.names)
    for(column1 in time.columns){
      df[[column1]] <- mdy_hms2(df[[column1]])
    }
  }
  if(length(integer.columns) > 0){
    integer.columns <- intersect(integer.columns, column.names)
    for(column1 in integer.columns){
      df[[column1]] <- parse_integer(df[[column1]])
    }
  }
  if("INC_DATE" %in% column.names){
    df <- df %>% 
      mutate_at(vars(INC_DATE), mdy2)
  }
  if("VERSION" %in% names(df)){
    df <- select(df, -VERSION)
  }
  return(df)
}

ReadBasic <- function(basic.file){
  time.columns1 <- c("ALARM", "ARRIVAL", "LU_CLEAR")
  basic <- read_delim(basic.file, delim="^", n_max=1)
  integer.columns1 <- grep("_(APP|LOSS|VAL|INJ|DEATH)", names(basic), 
                           value=TRUE)
  basic <- ReadAll(basic.file, time.columns=time.columns1, 
                   integer.columns=integer.columns1)
  return(basic)
}

ReadFire <- function(fire.file){
  integer.columns1 <- c("NUM_UNIT", "BLDG_INVOL", "ACRES_BURN", "AGE", 
                       "BLDG_LGTH", "BLDG_WIDTH", "TOT_SQ_FT")
  fire <- ReadAll(fire.file, integer.columns=integer.columns1)
  return(fire)
}

ReadInjury <- function(injury.file){
  time.columns1 <- c("INJ_DT_TIM", "INJ_DATE")
  integer.columns1 <- c("SEQ_NUMBER", "AGE", "GENDER", "FF_SEQ_NO")
  injury <- ReadAll(injury.file, integer.columns=integer.columns1, 
                    time.columns = time.columns1)
  return(injury)
}

ReadHazmat <- function(hazmat.file){
  integer.columns1 <- c("HAZ_DEATH", "HAZ_INJ", "AFFEC_MEAS", "AFFEC_UNIT", 
                        "REL_FROM", "REL_STORY")
  hazmat <- ReadAll(hazmat.file, integer.columns=integer.columns1)
  return(hazmat)
}

ReadNFIRS <- list(basic=ReadBasic, fire=ReadFire, hazmat=ReadHazmat,
                  civilian=ReadInjury, firefighter=ReadInjury,
                  default=ReadAll)