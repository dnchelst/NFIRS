library(RJDBC)
library(dplyr)
library(sergeant)
library(readr)
library(arrow)
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
rm(basic.incident)