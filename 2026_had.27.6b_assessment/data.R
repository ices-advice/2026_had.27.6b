## Preprocess data, write TAF data tables

## Before: last year's assessment input data, Datras downloads of survey data (in boot/data)
## After: data/data.RData (input for SAM), csv files of input data in data folder

#  Note this takes a long time to run as it fits the survey GAM

library(icesTAF)

mkdir("data")

#####Create all the input data ##############
# catch data
mkdir("data/catch data")
source("data_prepareCatchData.R")   

# indices
mkdir("data/indices")
file.copy(list.files("boot/data/indices",full.names=TRUE),"data/indices")

# weights
mkdir("data/stock weights")
source("data_stockweights.R")

# natural mortality
mkdir("data/natural mortality")
source("data_natmort.R") 

# maturity
mkdir("data/maturity")
source("data_maturity.R")

####End - create input data#################

#####Read in the input data files to create SAM Input ######################

#  ## Catch-numbers-at-age ##
cn <- stockassessment::read.ices("data/catch data/cn.dat")
ln <-stockassessment::read.ices("data/catch data/ln.dat")
dn <-stockassessment::read.ices("data/catch data/dn.dat")
bn <-stockassessment::read.ices("data/catch data/bms.dat")

#  ## Catch-weight-at-age ##
cw <- stockassessment::read.ices("data/catch data/cw.dat")
dw <- stockassessment::read.ices("data/catch data/dw.dat")
lw <- stockassessment::read.ices("data/catch data/lw.dat")
# Landing fraction in catch at age
lf <- stockassessment::read.ices("data/catch data/lf.dat")

#  ## Natural-mortality ##
natmort <- stockassessment::read.ices("data/natural mortality/nm.dat")

# maturity
maturity <- stockassessment::read.ices("data/maturity/mo.dat")

#  ## Stock-weight-at-age ##
sw <- stockassessment::read.ices("data/stock weights/sw.dat")

pm <-pf <-sw
pm[] <-0
pf[] <-0


# survey data
# survey indices
surDes.indices <-stockassessment:::read.surveys(paste0("boot/data/MSS_indices.dat"))

mod.indices <-stockassessment:::read.surveys(paste0("data/indices/q3index.dat"))

ages <-colnames(sw)
surveys <- list("Rockall pt1"=surDes.indices[[1]][,ages],
               "Modelled Q3"=mod.indices[[1]][,ages])

attr(surveys[[1]], "time") <- attr(surDes.indices[["Rockall pt1 "]],"time")
attr(surveys[[2]], "time") <- attr(mod.indices[["Modelled Q3 index "]],"time")

#  Survey CVs
mod.cvs <-stockassessment:::read.surveys(paste0("data/indices/q3cv.dat"))

# EDIT MADE IN 2026 change to cvs acccounting for effect of large 2021 cohort on 2022 and 2023 cohorts. See 2026 wgcse report methods for detailed rationale
# only change q3cv.dat as this is what is used below

# calc time series max for each age
q3cv <- read.csv("data/indices/q3cv.csv")

max <- NULL

for (i in (2:10)){
  
  max[i-1] <- max(q3cv[,i], na.rm = TRUE)
  
}

# update .dat file with max values for specified years age# UPDATE EVERY YEAR FOR THESE COHORTS?

# 2022 cohort N.B. uses age 0 so 1 in column 2
mod.cvs[[1]]['2023',2] <- max[2]
mod.cvs[[1]]['2024',3] <- max[3]
mod.cvs[[1]]['2025',4] <- max[4]

# 2023 cohort  
mod.cvs[[1]]['2024',2] <- max[2]
mod.cvs[[1]]['2025',3] <- max[3]

attr(surveys[[2]],"weight")<-1/log((mod.cvs[[1]][,ages])^2+1)

#rock.pt1 <-surveys[[1]]
#rock.mod <-surveys[[2]]

rock.pt1 <-surDes.indices[[1]]
rock.mod <-mod.indices[[1]]

#  Write the data to csv files
write.taf(
  c(
    "cw", "lw", "dw", "sw", "cn",
    "dn", "ln", "natmort", "bn","maturity",
    "lf"
  ),row.names=rownames(cw),
  dir = "data"
)

write.taf("rock.pt1",row.names=rownames(rock.pt1),dir="data")
write.taf("rock.mod",row.names=rownames(rock.mod),dir="data")

#SAM doesn't handle NAs in weights
lw[is.na(lw)] <- 0
dw[is.na(dw)] <- 0

## write model files
# Set up data
dat<-stockassessment::setup.sam.data(surveys=surveys,
                    residual.fleet=cn, 
                    prop.mature=maturity, 
                    stock.mean.weight=sw, 
                    catch.mean.weight=cw, 
                    dis.mean.weight=dw, 
                    land.mean.weight=lw,
                    prop.f=pf, 
                    prop.m=pm, 
                    natural.mortality=natmort, 
                    land.frac=lf)

save(dat, file = "data/data.RData")
