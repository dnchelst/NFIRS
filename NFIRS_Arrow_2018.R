library(RJDBC)
library(tidyverse)
library(magrittr)
library(lubridate)
library(readxl)
library(arrow)
library(sergeant)
db <- src_drill("localhost", 8047L) # drill needs to be open in a shell
print(db)
emp <- tbl(db, "cp.`employee.json`")
count(emp, gender, marital_status)


setwd("/home/dov/Documents/NFIRS/2018") 
incident.address <- read_parquet("incidentaddress.parquet")


fire.incident <- read_delim("fireincident.txt", delim="^", guess_max = 10000)
write_csv(fire.incident, "fireincident.csv")
nfirs <- tbl(db, "dfs.`/home/dov/Documents/NFIRS/2018/fireincident.csv`")

drill_query(db, "select columns[0] as STATE, count(*) from dfs.`/home/dov/Documents/NFIRS/2018/fireincident.csv` group by STATE ORDER BY STATE;")
count(nfirs, STATE)

fire.incident <- read_delim("fireincident.txt", delim="^", guess_max = 10000)
write_parquet(fire.incident, sink="fireincident.parquet")
rm(fire.incident)

incident.address <- read_delim("incidentaddress.txt", delim="^", 
                               guess_max = 10000)
write_parquet(incident.address, sink="incidentaddress.parquet")
rm(incident.address)

# sed -i 's/8""/8"/g' basicincident.txt
basic.incident.cols <- cols(ALARMS='c', CENSUS='c', OTH_INJ='i', INC_NO='c',
                            DEPT_STA='c', DISTRICT='c', FDID='c')
basic.incident <- read_delim("basicincident.txt", delim="^", 
                             col_types=basic.incident.cols, guess_max=10000) 
write_parquet(basic.incident, sink="basicincident.parquet")

basic.incident <- read_parquet("basicincident.parquet")
rm(basic.incident)

fd.agency <- read_delim("fdheader.txt", delim="^")
calls.by.agency <- basic.incident %>% 
  group_by(STATE, FDID) %>%
  summarise(calls = n(), 
            fires = sum(grepl("^1", INC_TYPE)),
            days = n_distinct(INC_DATE),
            months = n_distinct(substring(INC_DATE, 1, 2))) %>% 
  ungroup %>% 
  left_join(select(fd.agency, STATE, FDID, FD_NAME))

calls.by.agency %>% arrange(desc(calls)) %>% 
  filter(months==12) %>% 
  mutate(lambda = calls / 365, flag = exp(lambda) > 365, 
         approx1 = 365 * exp(-lambda),
         cumulative = cumsum(approx1)) %>% 
  filter(cumulative < .15) %>%  
  filter(days  < 365) %>% 
  View 

calls.by.agency %>% 
  count(month.flag = (months == 12),
        day.flag = (days == 365))

fire.incident %>% 
  filter(STATE=="MN") %>%
  count(STATE, FDID, sort=T) %>% 
  mutate(percent = 100 * n/ sum(n),
         cumulative = cumsum(percent)) %>% 
  left_join(select(fd.agency, STATE, FDID, FD_NAME)) %>% 
  View

# check death and injury
basic.incident %>% 
  filter(STATE=="MN") %>% 
  filter(grepl("^1", INC_TYPE)) %>% 
  select(STATE, FDID, INC_NO, INC_DATE, INC_TYPE, matches("DEATH|INJ")) %>% 
  mutate_at(vars(matches("DEATH|INJ")), replace_na, 0) %>% 
  filter(pmax(FF_DEATH, FF_INJ, OTH_DEATH, OTH_INJ) > 0) %>% 
  #View
  select(matches("DEATH|INJ")) %>% colSums

populations <- read_excel("/home/dov/Downloads/co-est2019-annres-27.xlsx", 
                          skip=3)

fire.incident %>% 
  filter(STATE=="MN") %>%
  mutate_at(vars(INC_DATE), mdy) %>% 
  select(STATE:INC_NO) %>% 
  count(month = floor_date(INC_DATE, unit="month")) %>% 
  mutate(days = days_in_month(month),
         per.day = n / days) %>% 
  View

  
