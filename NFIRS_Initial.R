script.dir <- "/home/dchelst/Documents/Git-Projects/NFIRS"
data.dir <- "/home/dchelst/Documents/NFIRS"
source(file.path(script.dir, "nfirs_functions.R"))


nfirs.files <- list(
  basic = "basicincident", codes = "codelookup", address="incidentaddress",
  fdheader = "", fire = "fireincident", cause="causes-fixed", 
  aid = "basicaid", wildlands = "", arson = "", 
  civilian = "civiliancasualty", hazmat = "", firefighter="ffcasualty", ems="",
  hazchem="", arson.referal="arsonagencyreferal", 
  hazmat.equip="hazmatequipinvolved", arson.juv="arsonjuvsub", 
  hazmobprop = "", ffequip = "ffequipfail"
)

nfirs.data <- list()
for (name1 in names(nfirs.files)){
  file1 <- nfirs.files[[name1]]
  # file name
  file.name <- ifelse(file1=="", name1, file1) %>% 
    paste0(".txt") 
  print(paste(file.name, Sys.time()))
  name2 <- ifelse(name1 %in% names(ReadNFIRS), name1, "default")
  # load files
  nfirs.data[[name1]] <- file.name %>% file.path(data.dir, .) %>%
    ReadNFIRS[[name2]]() 
}

# store in RData format
save(nfirs.data,
     file=file.path(data.dir, "NFIRS2014.RData"))


# Quick Analysis
load(file.path(data.dir, "NFIRS2014.RData"))


inc.codes <- nfirs.data$codes %>% 
  filter(fieldid=="INC_TYPE") %>% 
  select(-fieldid)

nfirs.data$basic %>%
  count(INC_TYPE) %>%
  left_join(inc.codes, by=c("INC_TYPE"="code_value")) %>%
  View