script.dir <- "/home/dov/git/nfirs"
data.dir <- "/home/dov/Public/NFIRS/NFIRS2014"

basic.file <- "basicincident.txt" %>% file.path(data.dir, .)
lookup.file <- "codelookup.txt" %>% file.path(data.dir, .)
address.file <- "incidentaddress.txt" %>% file.path(data.dir, .)
fdheader.file <- "fdheader.txt" %>% file.path(data.dir, .)
fire.file <- "fireincident.txt" %>% file.path(data.dir, .)
cause.file <- "causes-fixed.txt" %>% file.path(data.dir, .)
source(file.path(script.dir, "nfirs_functions.R"))

# load files
basic <- ReadBasic(basic.file)
code.lookup <- read_delim(lookup.file, delim="^")
fdheader <- ReadAll(fdheader.file, 18)
address <- ReadAll(address.file, 17)
fire <- ReadFire(fire.file)
cause <- ReadAll(cause.file, 10)

# store in RData format
save(basic, code.lookup, fdheader, address, fire, cause,
     file=file.path(data.dir, "NFIRS2014.RData"))

load(file.path(data.dir, "NFIRS2014.RData"))
