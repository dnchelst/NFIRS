script.dir <- "/home/dov/git/nfirs"
data.dir <- "/home/dov/Public/NFIRS/NFIRS2014"

basic.file <- "basicincident.txt" %>% file.path(data.dir, .)
lookup.file <- "codelookup.txt" %>% file.path(data.dir, .)
address.file <- "incidentaddress.txt" %>% file.path(data.dir, .)
fdheader.file <- "fdheader.txt" %>% file.path(data.dir, .)
source(file.path(script.dir, "nfirs_functions.R"))

# load files
basic <- ReadBasic(basic.file)
code.lookup <- read_delim(lookup.file, delim="^")
fdheader <- ReadAllChar(fdheader.file, 18)
address <- ReadAddress(address.file)

# store in RData format
save(basic, code.lookup, fdheader, address, 
     file=file.path(data.dir, "NFIRS2014.RData"))
