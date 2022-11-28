script.dir <- "/home/dchelst/Documents/Git-Projects/NFIRS"
data.dir <- "/home/dchelst/Documents/NFIRS"
source(file.path(script.dir, "nfirs_functions.R"))

library(archive)
library(lubridate)
setwd(data.dir)

calls.by.type <- tibble()
calls.by.agency <- tibble()

basic.cols <- cols_only(STATE="c", FDID="c", INC_NO="c", EXP_NO="i", 
                        INC_TYPE="c", INC_DATE="c")
agency.cols <- cols_only(STATE="c", FDID="c", FD_NAME="c")
for (year1 in 2014:2021){
  print(str_c("Starting ", year1, ", ", format(Sys.time(), "%H:%M:%S")))
  file.pattern1 <- str_c("nfirs", ".*", year1, "[.]zip")
  file.pattern2 <- str_c("NFIRS_", year1, ".*zip")
  basic.file <- str_c("basicincident-", year1, ".txt")
  if(!file.exists(basic.file)){
    archive.file1 <- list.files(pattern=file.pattern1)
    archive.file2 <- archive(archive.file1) %$% path %>%  
      grep(pattern=file.pattern2, ., value=TRUE)
  # check if file2 was already extracted
    if(!file.exists(archive.file2)){
      archive_extract(archive.file1, files=archive.file2)
    }
  # check if basicincident was already extracted
    archive_extract(archive.file2, files=c("basicincident.txt", "fdheader.txt"))
    file.rename("basicincident.txt", basic.file)
    # repair a line in 2018
    if(year1==2018){
      system("sed -i \'s/029118\"\"/0029118\"/g\' basicincident-2018.txt")
    }
    print(str_c("Finished Extracting ", year1, ", ", format(Sys.time(), 
                                                            "%H:%M:%S")))
  } else{
    print(str_c("Skipping Extracting ", year1))
  }
  
  basic <- read_delim(basic.file, delim="^", col_types = basic.cols, 
                      trim_ws=TRUE, show_col_types = FALSE) %>% 
    distinct %>% 
    filter(EXP_NO==0) %>% 
    filter(STATE != "GU") # test call
  
  agency <- read_delim("fdheader.txt", delim="^", col_types=agency.cols, 
                       trim_ws = TRUE, show_col_types = FALSE) %>% 
    replace_na(list(STATE="Other")) %>% 
    distinct

  calls.by.type1 <- basic %>% 
    filter(EXP_NO==0) %>% 
    count(INC_TYPE) %>% 
    mutate(year = year1)
                  
  calls.by.agency1 <- basic %>% 
    filter(EXP_NO == 0) %>% 
    count(STATE, FDID, INC_DATE) %>%
    mutate(INC_DATE = mdy(INC_DATE), 
           month = month(INC_DATE)) %>% 
    group_by(STATE, FDID) %>% 
    summarise(n = sum(n), 
              days = n_distinct(INC_DATE), 
              months = n_distinct(month)) %>% 
    ungroup %>% 
    mutate(year = year1) %>%
    replace_na(list(STATE = "Other")) %>% 
    left_join(agency)
                  
  calls.by.type <- bind_rows(calls.by.type, calls.by.type1)
  calls.by.agency <- bind_rows(calls.by.agency, calls.by.agency1)

}

save(calls.by.agency, calls.by.type, file="NFIRS-SummaryByYear.RData")

calls.by.agency %>% 
  group_by(year) %>% 
  summarise(count = sum(n), 
            agencies = n(), 
            monthly.agencies = sum(months==12), 
            daily.agencies = sum(days >= 365)) %>% 
  ungroup %>% 
  view

agency.reporting <- calls.by.agency %>% 
  group_by(STATE, FDID, FD_NAME) %>% 
  summarise(year.count = n(), 
            full.month.count = sum(months==12),
            full.year.count = sum(days >=365),
            min.year = min(year),
            max.year = max(year),
            mean.calls = mean(n)) %>% 
  ungroup %>% 
  filter(year.count == full.year.count, year.count < 8) %>% 
  view