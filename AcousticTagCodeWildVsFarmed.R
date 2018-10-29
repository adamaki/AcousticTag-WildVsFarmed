#Delousing efficiency project data coding
#Adam Brooker
#12th July 2016

#Need to install MySQL and Java software on PC and RMySQL, XLConnectJars, XLconnect and rJava packages in R Studio before executing this code

# library(RMySQL)
library(rJava)
library(XLConnectJars)
library(XLConnect) 
library(openxlsx)
options(java.parameters = "-Xmx32000m")
library(dplyr)
library(tidyr)
library(data.table)
library(tidyverse)

#ENTER YOUR VARIABLES HERE
workingdir = "H:/Acoustic tag - Wild vs. Farmed/Data processing/Cropped data/Coded Day CSV" # change to location of data
dayfileloc = "run_2LLF15S100156_day_coded.csv" # change to file to be analysed
masterfileloc = "H:/Acoustic tag - Wild vs. Farmed/AcousticTagFile_2015.xlsx" # change to location of AcousticTagFile.xlsx
day = '156' # day of the year
bottom.threshold = 15 # threshold for fish at bottom of cage coding (depth in metres)
water.height = 35
#rot.ang = 335.12 # grid rotation angle in radians
#UTMeast = 2978881.84 # grid origin x-axis
#UTMnorth = 5546147.24 #  grid origin y-axis

# Enter periods of hide tags
#hidetag7NW1 = 11805
#hidetag7NW2 = 10965
#hidetag7SE1 = 11553
#hidetag7SE2 = 11217
hidetag8SW = 13527
hidetag8NE = 15235

# DON'T CHANGE ANYTHING AFTER THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!

#------------------------------------------------------------------------------------------------------------------------------
# LOAD LOOKUP TABLES


# LOAD MASTERCODE
mastercode <- readWorksheetFromFile(masterfileloc, sheet = 11, startRow = 6, endCol = 101, colTypes = 'character') # read in mastercode from Acoustic Tag File
#mastercode <- read.xlsx(masterfileloc, sheetName = 'MasterCode', startRow = 6, endRow = 167, colIndex = seq(5, 95), colClasses = 'character')
rownames(mastercode) <- as.numeric(mastercode$DAY) # rename mastercode rows by day
mastercode$DATE <- substr(mastercode$DATE, 1, 10)

mastercode$SUN_N_S <- convert.to.date(col = mastercode$SUN_N_S)
mastercode$SUN_N_E <- convert.to.date(col = mastercode$SUN_N_E)
mastercode$SUN_W_S <- convert.to.date(col = mastercode$SUN_W_S)
mastercode$SUN_W_E <- convert.to.date(col = mastercode$SUN_W_E)
mastercode$SUN_D_S <- convert.to.date(col = mastercode$SUN_D_S)
mastercode$SUN_D_E <- convert.to.date(col = mastercode$SUN_D_E)
mastercode$SUN_K_S <- convert.to.date(col = mastercode$SUN_K_S)
mastercode$SUN_K_E <- convert.to.date(col = mastercode$SUN_K_E)
mastercode$SUN_N_S2 <- convert.to.date(col = mastercode$SUN_N_S2)
mastercode$SUN_N_E2 <- convert.to.date(col = mastercode$SUN_N_E2)

mastercode$TID_L_S <- convert.to.date(col = mastercode$TID_L_S)
mastercode$TID_L_E <- convert.to.date(col = mastercode$TID_L_E)
mastercode$TID_LH_S <- convert.to.date(col = mastercode$TID_LH_S)
mastercode$TID_LH_E <- convert.to.date(col = mastercode$TID_LH_E)
mastercode$TID_H_S <- convert.to.date(col = mastercode$TID_H_S)
mastercode$TID_H_E <- convert.to.date(col = mastercode$TID_H_E)
mastercode$TID_HL_S <- convert.to.date(col = mastercode$TID_HL_S)
mastercode$TID_HL_E <- convert.to.date(col = mastercode$TID_HL_E)
mastercode$TID_L_S2 <- convert.to.date(col = mastercode$TID_L_S2)
mastercode$TID_L_E2 <- convert.to.date(col = mastercode$TID_L_E2)
mastercode$TID_LH_S2 <- convert.to.date(col = mastercode$TID_LH_S2)
mastercode$TID_LH_E2 <- convert.to.date(col = mastercode$TID_LH_E2)
mastercode$TID_H_S2 <- convert.to.date(col = mastercode$TID_H_S2)
mastercode$TID_H_E2 <- convert.to.date(col = mastercode$TID_H_E2)
mastercode$TID_HL_S2 <- convert.to.date(col = mastercode$TID_HL_S2)
mastercode$TID_HL_E2 <- convert.to.date(col = mastercode$TID_HL_E2)

mastercode$SMEAL_P7_N_S <- convert.to.date(col = mastercode$SMEAL_P7_N_S)
mastercode$SMEAL_P7_N_E <- convert.to.date(col = mastercode$SMEAL_P7_N_E)
mastercode$SMEAL_P7_Y_S <- convert.to.date(col = mastercode$SMEAL_P7_Y_S)
mastercode$SMEAL_P7_Y_E <- convert.to.date(col = mastercode$SMEAL_P7_Y_E)
mastercode$SMEAL_P7_N_S2 <- convert.to.date(col = mastercode$SMEAL_P7_N_S2)
mastercode$SMEAL_P7_N_E2 <- convert.to.date(col = mastercode$SMEAL_P7_N_E2)
mastercode$SMEAL_P7_Y_S2 <- convert.to.date(col = mastercode$SMEAL_P7_Y_S2)
mastercode$SMEAL_P7_Y_E2 <- convert.to.date(col = mastercode$SMEAL_P7_Y_E2)
mastercode$SMEAL_P7_N_S3 <- convert.to.date(col = mastercode$SMEAL_P7_N_S3)
mastercode$SMEAL_P7_N_E3 <- convert.to.date(col = mastercode$SMEAL_P7_N_E3)
mastercode$SMEAL_P8_N_S <- convert.to.date(col = mastercode$SMEAL_P8_N_S)
mastercode$SMEAL_P8_N_E <- convert.to.date(col = mastercode$SMEAL_P8_N_E)
mastercode$SMEAL_P8_Y_S <- convert.to.date(col = mastercode$SMEAL_P8_Y_S)
mastercode$SMEAL_P8_Y_E <- convert.to.date(col = mastercode$SMEAL_P8_Y_E)
mastercode$SMEAL_P8_N_S2 <- convert.to.date(col = mastercode$SMEAL_P8_N_S2)
mastercode$SMEAL_P8_N_E2 <- convert.to.date(col = mastercode$SMEAL_P8_N_E2)
mastercode$SMEAL_P8_Y_S2 <- convert.to.date(col = mastercode$SMEAL_P8_Y_S2)
mastercode$SMEAL_P8_Y_E2 <- convert.to.date(col = mastercode$SMEAL_P8_Y_E2)
mastercode$SMEAL_P8_N_S3 <- convert.to.date(col = mastercode$SMEAL_P8_N_S3)
mastercode$SMEAL_P8_N_E3 <- convert.to.date(col = mastercode$SMEAL_P8_N_E3)

mastercode$AG7F1_N_S <- convert.to.date(col = mastercode$AG7F1_N_S)
mastercode$AG7F1_N_E <- convert.to.date(col = mastercode$AG7F1_N_E)
mastercode$AG7F1_Y_S <- convert.to.date(col = mastercode$AG7F1_Y_S)
mastercode$AG7F1_Y_E <- convert.to.date(col = mastercode$AG7F1_Y_E)
mastercode$AG7F1_M_S <- convert.to.date(col = mastercode$AG7F1_M_S)
mastercode$AG7F1_M_E <- convert.to.date(col = mastercode$AG7F1_M_E)
mastercode$AG7F2_N_S <- convert.to.date(col = mastercode$AG7F2_N_S)
mastercode$AG7F2_N_E <- convert.to.date(col = mastercode$AG7F2_N_E)
mastercode$AG7F2_Y_S <- convert.to.date(col = mastercode$AG7F2_Y_S)
mastercode$AG7F2_Y_E <- convert.to.date(col = mastercode$AG7F2_Y_E)
mastercode$AG7F2_M_S <- convert.to.date(col = mastercode$AG7F2_M_S)
mastercode$AG7F2_M_E <- convert.to.date(col = mastercode$AG7F2_M_E)
mastercode$AG8F1_N_S <- convert.to.date(col = mastercode$AG8F1_N_S)
mastercode$AG8F1_N_E <- convert.to.date(col = mastercode$AG8F1_N_E)
mastercode$AG8F1_Y_S <- convert.to.date(col = mastercode$AG8F1_Y_S)
mastercode$AG8F1_Y_E <- convert.to.date(col = mastercode$AG8F1_Y_E)
mastercode$AG8F1_M_S <- convert.to.date(col = mastercode$AG8F1_M_S)
mastercode$AG8F1_M_E <- convert.to.date(col = mastercode$AG8F1_M_E)
mastercode$AG8F2_N_S <- convert.to.date(col = mastercode$AG8F2_N_S)
mastercode$AG8F2_N_E <- convert.to.date(col = mastercode$AG8F2_N_E)
mastercode$AG8F2_Y_S <- convert.to.date(col = mastercode$AG8F2_Y_S)
mastercode$AG8F2_Y_E <- convert.to.date(col = mastercode$AG8F2_Y_E)
mastercode$AG8F2_M_S <- convert.to.date(col = mastercode$AG8F2_M_S)
mastercode$AG8F2_M_E <- convert.to.date(col = mastercode$AG8F2_M_E)

mastercode$LUMPEL_S <- convert.to.date(col = mastercode$LUMPEL_S)
mastercode$LUMPEL_E <- convert.to.date(col = mastercode$LUMPEL_E)

#LOAD FISH ID DATA
fishid_tbl <- read.xlsx(masterfileloc, sheet = 5, rows = seq(72, 110), cols = c(2, 4, 7, 11)) # read in code from Fish ID lookup table
fishid_tbl$L_m <- round(as.numeric(fishid_tbl$L_m), digits = 3)

#LOAD LOCATIONS CODING DATA
#locations.lookup <- read.xlsx(masterfileloc, sheet = 12, startRow = 1, cols = seq(1, 7)) # read in codes from Locations Coding spreadsheet
locations.lookup <- readWorksheetFromFile(masterfileloc, sheet = 12, startRow = 1, endCol = 7) # read in codes from Locations Coding spreadsheet
rownames(locations.lookup) <- locations.lookup$Code

#LOAD ENVIRONMENTAL PROBE READINGS
probe.DOT1 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(1, 2, 3))
probe.DOT1$DO.time.1m <- as.POSIXct(strptime(probe.DOT1$DO.time.1m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT1$DO.time.1m <- probe.DOT1$DO.time.1m - as.difftime(1, unit = 'hours')
# probe.DOT1 <- probe.DOT1 %>% mutate_each(funs(round(.,2)), DO.1m, Temp.1m) #deprecated function
probe.DOT1 <- probe.DOT1 %>% mutate_at(.vars = vars(DO.1m, Temp.1m), .funs = funs(round(.,2)))

probe.sal1 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(4, 5))
probe.sal1$Sal.time.1m <- as.POSIXct(strptime(probe.sal1$Sal.time.1m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal1$Sal.time.1m <- probe.sal1$Sal.time.1m - as.difftime(1, unit = 'hours')
probe.sal1 <- probe.sal1 %>% mutate(Sal.1m = round(Sal.1m, 2))

probe.DOT2 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(6, 7, 8))
probe.DOT2$DO.time.2m <- as.POSIXct(strptime(probe.DOT2$DO.time.2m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT2$DO.time.2m <- probe.DOT2$DO.time.2m - as.difftime(1, unit = 'hours')
probe.DOT2 <- probe.DOT2 %>% mutate_at(.vars = vars(DO.2m, Temp.2m), .funs = funs(round(.,2)))

probe.sal2 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(9, 10))
probe.sal2$Sal.time.2m <- as.POSIXct(strptime(probe.sal2$Sal.time.2m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal2$Sal.time.2m <- probe.sal2$Sal.time.2m - as.difftime(1, unit = 'hours')
probe.sal2 <- probe.sal2 %>% mutate(Sal.2m = round(Sal.2m, 2))

probe.DOT4 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(11, 12, 13))
probe.DOT4$DO.time.4m <- as.POSIXct(strptime(probe.DOT4$DO.time.4m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT4$DO.time.4m <- probe.DOT4$DO.time.4m - as.difftime(1, unit = 'hours')
probe.DOT4 <- probe.DOT4 %>% mutate_at(.vars = vars(DO.4m, Temp.4m), .funs = funs(round(.,2)))

probe.sal4 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(14, 15))
probe.sal4$Sal.time.4m <- as.POSIXct(strptime(probe.sal4$Sal.time.4m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal4$Sal.time.4m <- probe.sal4$Sal.time.4m - as.difftime(1, unit = 'hours')
probe.sal4 <- probe.sal4 %>% mutate(Sal.4m = round(Sal.4m, 2))

probe.DOT8 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(16, 17, 18))
probe.DOT8$DO.time.8m <- as.POSIXct(strptime(probe.DOT8$DO.time.8m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT8$DO.time.8m <- probe.DOT8$DO.time.8m - as.difftime(1, unit = 'hours')
probe.DOT8 <- probe.DOT8 %>% mutate_at(.vars = vars(DO.8m, Temp.8m), .funs = funs(round(.,2)))

probe.sal8 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(19, 20))
probe.sal8$Sal.time.8m <- as.POSIXct(strptime(probe.sal8$Sal.time.8m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal8$Sal.time.8m <- probe.sal8$Sal.time.8m - as.difftime(1, unit = 'hours')
probe.sal8 <- probe.sal8 %>% mutate(Sal.8m = round(Sal.8m, 2))


# ----------------------------------------------------------------------------------------------------------------------------------------


#CODING

setwd(workingdir) 


# LOAD HOURFILE (for when coding hourfiles instead of dayfilelocs)
#dayfile <- read.csv(dayfileloc, header = TRUE, sep = ",", colClasses = c('NULL', 'NULL', 'NULL', 'character', 'character', 'NULL', 
#                                                                           'character', 'character', 'character', 'character', 'NULL', 'NULL', 
#                                                                           'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 
#                                                                           'NULL')) #read data into table

# LOAD dayfileloc
dayfile <- read.csv(dayfileloc, header = TRUE, sep = ",", colClasses = c('NULL', 'NULL', 'NULL', 'character', 'character', 'NULL', 
                                                                          'character', 'character', 'character', 'character', 'NULL', 'NULL', 
                                                                          'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 
                                                                          'NULL')) #read data into table

dayfile <- dayfile[!(dayfile$Period == 'Period'),] # remove old headers

#CONVERT FIELDS INTO CORRECT FORMATS
dayfile$Period <- sapply(dayfile$Period, as.numeric)
dayfile$SubCode <- sapply(dayfile$SubCode, as.numeric)
dayfile[, 'EchoTime'] <- as.POSIXct(strptime(dayfile[,'EchoTime'], "%d/%m/%Y %H:%M:%S", tz = "UTC")) # convert character format to date and time format
dayfile$PosX <- as.numeric(dayfile$PosX)
dayfile$PosY <- as.numeric(dayfile$PosY)
dayfile$PosZ <- as.numeric(dayfile$PosZ)

# TRANSLATE  COORDINATES INTO POSITIVE DEPTH AND ZERO ORIGIN

#dayfile$PosX2 <- round((cos(rot.ang*pi/180)*dayfile$PosX-sin(rot.ang*pi/180)*dayfile$PosY)-UTMeast, digits = 2)
#dayfile$PosY2 <- round((sin(rot.ang*pi/180)*dayfile$PosX+cos(rot.ang*pi/180)*dayfile$PosY)-UTMnorth, digits = 2)
#dayfile$PosX <- dayfile$PosX2
#dayfile$PosY <- dayfile$PosY2
#dayfile$PosX2 <- NULL
#dayfile$PosY2 <- NULL
#dayfile$PosZ <- water.height-dayfile$PosZ

#REMOVE HIDE TAGS
#dayfile <- dayfile[!(dayfile$Period == hidetag1 | dayfile$Period == hidetag2 | dayfile$Period == hidetag3 | 
#               dayfile$Period == hidetag4 | dayfile$Period == hidetag5 | dayfile$Period == hidetag6 | dayfile$Period == hidetag7 | dayfile$Period == hidetag8),]

# REMOVE FISH IDS STILL TRANSMITTING FROM PREVIOUS STUDY
selected <- data.frame()
for (i in 1:nrow(fishid_tbl)){
selected <- rbind(selected, subset(dayfile, Period == fishid_tbl[i,'Period']))  
}
dayfile <- selected 
rm(selected)

#REMOVE PINGS ABOVE WATER SURFACE
dayfile <- dayfile[!(dayfile$PosZ < 0),]

#SORT BY TIME AND TAG
#dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
#dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
dayfile <- arrange(dayfile, Period, EchoTime) # sort by time and tag




#ADD PEN NUMBER
pen.lookup <- fishid_tbl$Pen # create pen lookup table
names(pen.lookup) <- fishid_tbl$Period
dayfile$PEN <- as.numeric(pen.lookup[as.character(dayfile$Period)]) # add pen number to day file
dayfile <- dayfile[,c('Period', 'SubCode', 'PEN', 'EchoTime', 'PosX', 'PosY', 'PosZ')] # reorder fields


#CALCULATE TIMES AND SPEEDS
periods <- unique(dayfile$Period)
SEC <- numeric(0)

for(i in 1:length(periods)){
  SEC <- c(SEC, as.integer(c(NA, diff(subset(dayfile$EchoTime, dayfile$Period == periods[i]), lag = 1, differences = 1)))) # calculate time delay between pings
}
dayfile$SEC <- SEC
rm(SEC)
dayfile$M <- round(c(0, sqrt(diff(dayfile$PosX)^2+diff(dayfile$PosY)^2+diff(dayfile$PosZ)^2)), digits = 3) # calculate distance between pings
dayfile$MSEC <- round(dayfile$M/dayfile$SEC, digits = 3) # calculate swimming speed in m/sec
dayfile$MSEC <- as.numeric(sub("Inf", "0", dayfile$MSEC)) # replace "Inf" entries
dayfile <- subset(dayfile, dayfile$SEC >5 | is.na(dayfile$SEC) == TRUE) # remove entries where time delay too low or too high
#dayfile <- dayfile[!(dayfile$SEC <5 | dayfile$SEC >60),] # remove entries where time delay too low or too high
#dayfile <- dayfile[!(dayfile$SEC <5),] # remove entries where time delay too low or too high

#CALCULATE BODY LENGTHS/SEC
fishid.bl.lookup <- fishid_tbl$L_m # create fish ID lookup table
names(fishid.bl.lookup) <- fishid_tbl$Period
dayfile$BL <- as.numeric(fishid.bl.lookup[as.character(dayfile$Period)]) # add fish lengths to day file
dayfile$BLSEC <- round(dayfile$MSEC/dayfile$BL, 3) # calculate BL per sec
dayfile <- subset(dayfile, dayfile$BLSEC < 10 | is.na(dayfile$BLSEC) == TRUE) # remove entries where swimming speed is greater than 20 BL/sec (likely multipath)

#CALCULATE HEADING AND TURN RATE
heading.func()
dayfileloc$HEAD <- c(NA, heading)
rm(heading)


#DYNAMIC HIDE CODING
dayfile <- arrange(dayfile, Period, EchoTime)

hide8SW <- subset(dayfile, Period == hidetag8SW)
names(hide8SW)[names(hide8SW) == "EchoTime"] <- "HideTime"
hide8NE <- subset(dayfile, Period == hidetag8NE)
names(hide8NE)[names(hide8NE) == "EchoTime"] <- "HideTime"


dayfile <- subset(dayfile, !(Period == hidetag8SW | Period == hidetag8NE))

hide1 <- hide8SW
hide2 <- hide8NE


detach("package:dplyr")

hide.filter(hide1, 10, 2.5)
hide1 <- fish.id
hide.filter(hide2, 10, 2.5)
hide2 <- fish.id


library(dplyr)

for(i in 1:2){
  
  all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, get(paste0('hide', as.character(i)))[,'HideTime']))))
  
  all <- all %>%
    left_join(dayfile, by = c("ts" = "EchoTime")) %>%
    left_join(get(paste0('hide', as.character(i))), by = c("ts" = "HideTime")) %>%
    arrange(ts) %>%
    fill(PosX.y, PosY.y, PosZ.y, .direction = 'up') %>%
    fill(PosX.y, PosY.y, PosZ.y, .direction = 'down') %>%
    filter(!is.na(PosX.x)) %>%
    arrange(Period.x, ts) 
  
  dayfile[,paste0("HID", as.character(i), ".x")] <- all$PosX.y
  dayfile[,paste0("HID", as.character(i), ".y")] <- all$PosY.y
  dayfile[,paste0("HID", as.character(i), ".z")] <- all$PosZ.y
}

rm(all)
rm(fish.id)

names(dayfile)[names(dayfile) == c('HID1.x', 'HID1.y', 'HID1.z', 'HID2.x', 'HID2.y', 'HID2.z')] <- c('P8SW.x', 'P8SW.y', 'P8SW.z', 'P8NE.x', 'P8NE.y', 'P8NE.z')
hides <- rbind(hide8SW, hide8NE)
names(hides)[names(hides) == 'HideTime'] <- 'EchoTime'
hides$SEC <- NULL
hides$M <- NULL
hides$MSEC <- NULL
hides$BL <- NULL
hides$BLSEC <- NULL


#ENTER CODES FROM MASTERCODE
dayfile$BIOF7 <- as.factor(mastercode[day,'BIOF7'])         
dayfile$BIOF8 <- as.factor(mastercode[day,'BIOF8'])  
dayfile$ARTL <- as.factor(mastercode[day,'ARTL'])  
dayfile$INFD <- as.factor(mastercode[day,'INFD'])  
dayfile$CHEM <- as.factor(mastercode[day,'CHEM'])  
dayfile$WVIS <- as.factor(mastercode[day,'WVIS'])                          
dayfile$MOON <- as.factor(mastercode[day,'MOON']) 

#Enter species code
fishid.origin.lookup <- fishid_tbl$Species # create fish origin lookup table
names(fishid.origin.lookup) <- fishid_tbl$Period
dayfile$SPEC <- as.factor(fishid.origin.lookup[as.character(dayfile$Period)]) # add fish origins to day file

#LICE DATA
dayfile$TOT_P7 <- as.numeric(mastercode[day,'LICE_P7_TOT']) 
dayfile$PA_A_P7 <- as.numeric(mastercode[day,'LICE_P7_FGPAA']) 
dayfile$FG_P7 <- as.numeric(mastercode[day,'LICE_P7_FG']) 
dayfile$A_P7 <- as.numeric(mastercode[day,'LICE_P7_A']) 
dayfile$PA_P7 <- as.numeric(mastercode[day,'LICE_P7_PA']) 
dayfile$CHAL_P7 <- as.numeric(mastercode[day,'LICE_P7_CHAL']) 
dayfile$CAL_P7 <- as.numeric(mastercode[day,'LICE_P7_CAL']) 
dayfile$TOT_P8 <- as.numeric(mastercode[day,'LICE_P8_TOT']) 
dayfile$PA_A_P8 <- as.numeric(mastercode[day,'LICE_P8_FGPAA']) 
dayfile$FG_P8 <- as.numeric(mastercode[day,'LICE_P8_FG']) 
dayfile$A_P8 <- as.numeric(mastercode[day,'LICE_P8_A']) 
dayfile$PA_P8 <- as.numeric(mastercode[day,'LICE_P8_PA']) 
dayfile$CHAL_P8 <- as.numeric(mastercode[day,'LICE_P8_CHAL']) 
dayfile$CAL_P8 <- as.numeric(mastercode[day,'LICE_P8_CAL']) 

#LOCATIONS CODING
dayfile$BOT <- as.factor(ifelse(dayfile$PosZ >= bottom.threshold, 'B', 'Z')) # at cage bottom
dayfile$OUT <- as.factor(locationcode(n7code = '7ON', w7code = '7OW', s7code = '7OS', e7code = '7OE', n8code = '8ON', w8code = '8OW', s8code = '8OS', e8code = '8OE')) # fish outside cage
dayfile$EDG <- as.factor(locationcode(n7code = '7EN', w7code = '7EW', s7code = '7ES', e7code = '7EE', n8code = '8EN', w8code = '8EW', s8code = '8ES', e8code = '8EE')) # fish at edge of cage
dayfile$BIGC <- as.factor(locationcode(n7code = '7CNW', w7code = '7CSW', s7code = '7CSE', e7code = '7CNE', n8code = '8CNW', w8code = '8CSW', s8code = '8CSE', e8code = '8CNE')) # fish in big corners
dayfile$SMC <- as.factor(locationcode(n7code = '7XNW', w7code = '7XSW', s7code = '7XSE', e7code = '7XNE', n8code = '8XNW', w8code = '8XSW', s8code = '8XSE', e8code = '8XNE')) # fish in small corners
#dayfile$HID <- as.factor(hidecode(p7h1code = '7WHSE', p7h2code = '7WHNW', p8h1code = '8WHSW', p8h2code = '8WHNE')) # fish in hides
dayfile$HID <- as.factor(dynamic.hidecode(p7nwhide = '7WHNW', p7sehide = '7WHSE', p8swhide = '8WHSW', p8nehide = '8WHNE', radius = 1, depth = 2, height = 1)) # fish in hides
dayfile$CEN <- as.factor(centrecode(highcode7 = '7MH', midcode7 = '7MM', lowcode7 = '7ML', highcode8 = '8MH', midcode8 = '8MM', lowcode8 = '8ML')) # fish in centre of cage
dayfile$FDB <- as.factor(atfeedcode(p7fb1code = '7FBSE', p7fb2code = '7FBNW', p8fb1code = '8FBSW', p8fb2code = '8FBNE')) # fish at feed blocks


#SUN AND TIDES CODING
dayfile$SUN <- suncode() # sun phase code
dayfile$TID <- tidecode() # tide phase code
dayfile$PHASE <- as.factor(mastercode[day,'HEIGHT']) # tidal height (spring/neap)


#MEAL TIMES CODING
dayfile$SMEAL7 <- smealcode(pen = 'P7') # salmon feeding times cage 7 code
dayfile$SMEAL8 <- smealcode(pen = 'P8') # salmon feeding times cage 8 code


if(is.na(mastercode[day, 'AG7F1_N_S'])) {dayfile$AG7F1 <- 'NA'} else {dayfile$AG7F1 <- jellycode(feed.block = '7F1')}   # cleanerfish jelly feeding time cage 7 F1 code
if(is.na(mastercode[day, 'AG7F2_N_S'])) {dayfile$AG7F2 <- 'NA'} else {dayfile$AG7F2 <- jellycode(feed.block = '7F2')}   # cleanerfish jelly feeding time cage 7 F2 code
if(is.na(mastercode[day, 'AG8F1_N_S'])) {dayfile$AG8F1 <- 'NA'} else {dayfile$AG8F1 <- jellycode(feed.block = '8F1')}   # cleanerfish jelly feeding time cage 8 F1 code
if(is.na(mastercode[day, 'AG8F2_N_S'])) {dayfile$AG8F2 <- 'NA'} else {dayfile$AG8F2 <- jellycode(feed.block = '8F2')}   # cleanerfish jelly feeding time cage 8 F2 code


if(is.na(mastercode[day, 'LUMPEL_S'])) {dayfile$LUMPEL <- 'NA'} else {dayfile$LUMPEL <- lumpelcode()} # Lumpfish feeding time code


#ENVIRONMENTAL DATA

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.DOT1$DO.time.1m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT1, by=c("ts" = "DO.time.1m")) %>%
  arrange(ts) %>%
  fill(DO.1m) %>%
  fill(Temp.1m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$O1 <- all$DO.1m
dayfile$T1 <- all$Temp.1m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.sal1$Sal.time.1m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal1, by=c("ts" = "Sal.time.1m")) %>%
  arrange(ts) %>%
  fill(Sal.1m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$S1 <- all$Sal.1m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.DOT2$DO.time.2m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT2, by=c("ts" = "DO.time.2m")) %>%
  arrange(ts) %>%
  fill(DO.2m) %>%
  fill(Temp.2m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$O2 <- all$DO.2m
dayfile$T2 <- all$Temp.2m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.sal2$Sal.time.2m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal2, by=c("ts" = "Sal.time.2m")) %>%
  arrange(ts) %>%
  fill(Sal.2m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$S2 <- all$Sal.2m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.DOT4$DO.time.4m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT4, by=c("ts" = "DO.time.4m")) %>%
  arrange(ts) %>%
  fill(DO.4m) %>%
  fill(Temp.4m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$O4 <- all$DO.4m
dayfile$T4 <- all$Temp.4m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.sal4$Sal.time.4m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal4, by=c("ts" = "Sal.time.4m")) %>%
  arrange(ts) %>%
  fill(Sal.4m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$S4 <- all$Sal.4m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.DOT8$DO.time.8m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT8, by=c("ts" = "DO.time.8m")) %>%
  arrange(ts) %>%
  fill(DO.8m) %>%
  fill(Temp.8m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$O8 <- all$DO.8m
dayfile$T8 <- all$Temp.8m

all <- data.frame(ts = unique(unlist(c(dayfile$EchoTime, probe.sal8$Sal.time.8m))))

all <- all %>%
  left_join(dayfile, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal8, by=c("ts" = "Sal.time.8m")) %>%
  arrange(ts) %>%
  fill(Sal.8m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile$S8 <- all$Sal.8m

rm(all)

#dayfile <- dayfile[c(seq(1, 12), seq(25, 74), seq(13, 24))]

dayfile$P7NW.x <- NULL
dayfile$P7NW.y <- NULL
dayfile$P7NW.z <- NULL
dayfile$P7SE.x <- NULL
dayfile$P7SE.y <- NULL
dayfile$P7SE.z <- NULL
dayfile$P8SW.x <- NULL
dayfile$P8SW.y <- NULL
dayfile$P8SW.z <- NULL
dayfile$P8NE.x <- NULL
dayfile$P8NE.y <- NULL
dayfile$P8NE.z <- NULL

#FINISH CODE
write.csv(dayfile, file = sub(".csv", "_coded.csv", dayfileloc, ignore.case = FALSE, fixed = T)) #write output to file
write.csv(hides, file = sub(".csv", "_hides.csv", dayfileloc, ignore.case = FALSE, fixed = T)) #write output to file


#remove(dayfile_tbl)
#remove(mastercode)
#remove(fishid_tbl)
#remove(locations.lookup)


#----------------------------------------------------------------------------------------------------------------------------------------

# Code to add tide height (spring/neap) retrospectively


dayfile.classes = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',# 'factor', 
                    'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'double'
)


files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)

for(i in 1:length(files)){
  
  day <- substr(files[[i]], 15, 17)
  dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes)
  
  dayfile$HEIGHT <- as.factor(mastercode[day,'HEIGHT']) # tidal height (spring/neap)
  
  dayfile <- dayfile[,c(seq(1, 43), 63, seq(44, 62))]
  
  write.csv(dayfile, file = files[[i]]) #write output to file
}

#-------------------------------------------------------------------------------------------------------------------------------------


# Code to add fish heading retrospectively

dayfile.classes = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                    'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'double'
)



system.time({

files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  
for(i in 1:length(files)){
  
  day <- substr(files[[i]], 15, 17)
  dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes)  
  
heading.func()
dayfile$HEAD <- c(NA, heading)
rm(heading)

dayfile <- dayfile[,c(seq(1, 12), 64, seq(13, 63))]

write.csv(dayfile, file = files[[i]]) #write output to file

}


})


# code to calculate turn angles and turn rate retrospectively ------------------------------------------------------------------------------------------

dayfile.classes = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                    'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'double'
                    )

system.time({
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  
  for(i in 1:length(files)){
    
    day <- substr(files[[i]], 15, 17)
    dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes) 
    dayfile <- 
    
    turn.angles()
    dayfile$TURN <- c(NA, NA, theta)
    dayfile$TURNRATE <- dayfile$TURN/dayfile$SEC
    rm(theta)
    
    dayfile <- dayfile[,c(seq(1, 13), 65, 66, seq(14, 64))]
    
    write.csv(dayfile, file = files[[i]]) #write output to file
    
  }
  
  
})

# Code to add fish at feed blocks retrospectively ---------------------------------------------------------------------------------------

dayfile.classes = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'double', 'double', 'double', 'double', 'double', 'double', 'double',
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                    'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                    'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                    'double', 'double', 'double', 'double', 'double', 'double', 'double'
)


system.time({
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  
  for(i in 1:length(files)){
    
    day <- substr(files[[i]], 15, 17)
    dayfile_tbl <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes)  
    
    dayfile_tbl$FDB <- as.factor(atfeedcode(p7fb1code = '7FBSE', p7fb2code = '7FBNW', p8fb1code = '8FBSW', p8fb2code = '8FBNE')) # fish at feed blocks

    
    #dayfile_tbl <- dayfile_tbl[,c(seq(1, 44), 67, seq(45, 66))]
    
    write.csv(dayfile_tbl, file = files[[i]]) #write output to file
    
  }
  
  
})




# Retrospectively add new column of water temperature at the fish's depth

fdtemp <- function(x, t1, t2, t4, t8){ 
  
  if(is.na(t1) == T){
    
    tatd <- NA
    
  } else {
    
    # create temperature profile using probe data
    tprofile <- data.frame(depth = seq(0, 35, 0.01)) %>% # dataframe of depths in 0.01m increments
      left_join(data.frame(depth = c(0, 1, 2, 4, 8, 35), temp = c(t1, t1, t2, t4, t8, t8)), by = 'depth') %>% # join probe data
      mutate(temp = approx(depth, temp, depth)$y) # fill in gaps by imputing linear interpolation
    
    rownames(tprofile) <- tprofile$depth
    #tprofile$depth <- NULL
    
    tatd <- as.numeric(tprofile[as.character(x),2]) # select temperature at fish's depth
    
  }
  
  return(tatd)
}



files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)

system.time({
  
  for(i in 12:length(files)){
    
    #day <- substr(files[[i]], 15, 17)
    #dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes)  
    
    dayfile <- fread(files[[i]], drop = c(1))
    dayfile$EchoTime <- as.POSIXct(dayfile$EchoTime)
    
    dayfile$FISHTEMP <- round(mapply(fdtemp, x = dayfile$PosZ, t1 = dayfile$T1, t2 = dayfile$T2, t4 = dayfile$T4, t8 = dayfile$T8, SIMPLIFY = T), 2)
    
    write.csv(dayfile, files[[i]]) #write output to file
    
  }
  
  
})


#----------------------------------------------------------------------------------------------------------------------------------------

# FUNCTIONS

convert.to.date <- function(column = col) {
  as.POSIXct(strptime(paste(mastercode$DATE, substr(column, 12, 19), sep = " "), "%Y-%m-%d %H:%M:%S", tz = "UTC"))
}

# function to code for sun phase
suncode <- function(daycode = day) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_N_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_N_E']), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_W_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_W_E']), 'W', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_D_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_D_E']), 'D', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_K_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_K_E']), 'K', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_N_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_N_E2']), 'N', ' '
         )))))
}

# function to code for tide phase
tidecode <- function(daycode = day) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_L_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_L_E']), 'L', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_LH_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_LH_E']), 'LH', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_H_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_H_E']), 'H', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_HL_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_HL_E']), 'HL', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_L_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_L_E2']), 'L', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_LH_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_LH_E2']), 'LH', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_H_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_H_E2']), 'H', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_HL_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_HL_E2']), 'HL', 'Z'
         ))))))))
}

# function to code for salmon feeding times
smealcode <- function(daycode = day, pennum = pen) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_E', sep = "")]), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_E', sep = "")]), 'Y', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_S2', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_E2', sep = "")]), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_S2', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_E2', sep = "")]), 'Y', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_S3', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_E3', sep = "")]), 'N', 'Z'
         )))))
}

# function to code for wrasse jelly feed times
jellycode <- function(daycode = day, fb = feed.block) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('AG', fb, '_N_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('AG', fb, '_N_E', sep = "")]), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('AG', fb, '_Y_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('AG', fb, '_Y_E', sep = "")]), 'Y', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('AG', fb, '_M_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('AG', fb, '_M_E', sep = "")]), 'M', 'Z'
         )))
}

# function to code for lumpfish feeding times
lumpelcode <- function(daycode = day) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'LUMPEL_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'LUMPEL_E']), 'Y', 'N')
}

# function to code for fish location
locationcode <- function(n7code, w7code, s7code, e7code, n8code, w8code, s8code, e8code) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[n7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[n7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[n7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[n7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[n7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[n7code, 'zmax'], n7code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[w7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[w7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[w7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[w7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[w7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[w7code, 'zmax'], w7code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[s7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[s7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[s7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[s7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[s7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[s7code, 'zmax'], s7code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[e7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[e7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[e7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[e7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[e7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[e7code, 'zmax'], e7code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[n8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[n8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[n8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[n8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[n8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[n8code, 'zmax'], n8code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[w8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[w8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[w8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[w8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[w8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[w8code, 'zmax'], w8code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[s8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[s8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[s8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[s8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[s8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[s8code, 'zmax'], s8code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[e8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[e8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[e8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[e8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[e8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[e8code, 'zmax'], e8code, '' 
         ))))))))
}

# function to code for fish in hide
hidecode <- function(p7h1code, p7h2code, p8h1code, p8h2code) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p7h1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p7h1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p7h1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p7h1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p7h1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p7h1code, 'zmax'], p7h1code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p7h2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p7h2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p7h2code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p7h2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p7h2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p7h2code, 'zmax'], p7h2code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8h1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8h1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8h1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8h1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8h1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8h1code, 'zmax'], p8h1code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8h2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8h2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8h2code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8h2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8h2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8h2code, 'zmax'], p8h2code, ''
         
         ))))
}

# function to code for fish at feed blocks
atfeedcode <- function(p7fb1code, p7fb2code, p8fb1code, p8fb2code) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p8fb1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8fb1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8fb1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8fb1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8fb1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8fb1code, 'zmax'], p8fb1code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p8fb2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8fb2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8fb2code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8fb2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8fb2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8fb2code, 'zmax'], p8fb2code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8fb1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8fb1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8fb1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8fb1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8fb1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8fb1code, 'zmax'], p8fb1code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8fb2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8fb2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8fb2code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8fb2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8fb2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8fb2code, 'zmax'], p8fb2code, ''
         
         ))))
}

# function to code for fish in moving hide
dynamic.hidecode <- function(p7nwhide, p7sehide, p8swhide, p8nehide, radius, depth, height) {
  ifelse(dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > (dayfile_tbl$P8SW.x - radius) & dayfile_tbl$PosX < (dayfile_tbl$P8SW.x + radius) & dayfile_tbl$PosY > (dayfile_tbl$P8SW.y - radius) & 
           dayfile_tbl$PosY < (dayfile_tbl$P8SW.y + radius) & dayfile_tbl$PosZ > (dayfile_tbl$P8SW.z - height) & dayfile_tbl$PosZ < (dayfile_tbl$P8SW.z + depth), p8swhide, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > (dayfile_tbl$P8NE.x - radius) & dayfile_tbl$PosX < (dayfile_tbl$P8NE.x + radius) & dayfile_tbl$PosY > (dayfile_tbl$P8NE.y - radius) & 
           dayfile_tbl$PosY < (dayfile_tbl$P8NE.y + radius) & dayfile_tbl$PosZ > (dayfile_tbl$P8NE.z - height) & dayfile_tbl$PosZ < (dayfile_tbl$P8NE.z + depth), p8nehide, ''
         
         ))
}


# function to code for fish at centre of cage
centrecode <- function(highcode7, midcode7, lowcode7, highcode8, midcode8, lowcode8) {
  ifelse(dayfile_tbl$PosX > locations.lookup[highcode7, 'xmin'] & dayfile_tbl$PosX < locations.lookup[highcode7, 'xmax'] & dayfile_tbl$PosY > locations.lookup[highcode7, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[highcode7, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[highcode7, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[highcode7, 'zmax'], highcode7, ifelse
         (dayfile_tbl$PosX > locations.lookup[midcode7, 'xmin'] & dayfile_tbl$PosX < locations.lookup[midcode7, 'xmax'] & dayfile_tbl$PosY > locations.lookup[midcode7, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[midcode7, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[midcode7, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[midcode7, 'zmax'], midcode7, ifelse
         (dayfile_tbl$PosX > locations.lookup[lowcode7, 'xmin'] & dayfile_tbl$PosX < locations.lookup[lowcode7, 'xmax'] & dayfile_tbl$PosY > locations.lookup[lowcode7, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[lowcode7, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[lowcode7, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[lowcode7, 'zmax'], lowcode7, ifelse
         (dayfile_tbl$PosX > locations.lookup[highcode8, 'xmin'] & dayfile_tbl$PosX < locations.lookup[highcode8, 'xmax'] & dayfile_tbl$PosY > locations.lookup[highcode8, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[highcode8, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[highcode8, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[highcode8, 'zmax'], highcode8, ifelse
         (dayfile_tbl$PosX > locations.lookup[midcode8, 'xmin'] & dayfile_tbl$PosX < locations.lookup[midcode8, 'xmax'] & dayfile_tbl$PosY > locations.lookup[midcode8, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[midcode8, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[midcode8, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[midcode8, 'zmax'], midcode8, ifelse
         (dayfile_tbl$PosX > locations.lookup[lowcode8, 'xmin'] & dayfile_tbl$PosX < locations.lookup[lowcode8, 'xmax'] & dayfile_tbl$PosY > locations.lookup[lowcode8, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[lowcode8, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[lowcode8, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[lowcode8, 'zmax'], lowcode8, ''
         ))))))
}


hide.filter <- function(hide, smooth = 10, thresh = 2.5){
  
  fish.id <- hide
  filt <- rep(1/smooth, smooth)
  rem.tot <- data.frame(numeric(0))
  iteration <- 0
  
  repeat{
    
    fish.id$PosX.ma <- filter(fish.id$PosX, filt, sides = 1)
    fish.id$PosY.ma <- filter(fish.id$PosY, filt, sides = 1)
    fish.id$PosZ.ma <- filter(fish.id$PosZ, filt, sides = 1)
    fish.id$PosX.ma <- as.numeric(fish.id$PosX.ma)
    fish.id$PosY.ma <- as.numeric(fish.id$PosY.ma)
    fish.id$PosZ.ma <- as.numeric(fish.id$PosZ.ma)
    
    rem <- subset(fish.id, !(fish.id$PosX < (fish.id$PosX.ma+thresh) & fish.id$PosX > (fish.id$PosX.ma-thresh) & fish.id$PosY < (fish.id$PosY.ma+thresh) & fish.id$PosY > (fish.id$PosY.ma-thresh) & fish.id$PosZ < (fish.id$PosZ.ma+thresh) & fish.id$PosZ > (fish.id$PosZ.ma-thresh) | is.na(fish.id$PosX.ma) == TRUE))
    fish.id <- subset(fish.id, fish.id$PosX < (fish.id$PosX.ma+thresh) & fish.id$PosX > (fish.id$PosX.ma-thresh) & fish.id$PosY < (fish.id$PosY.ma+thresh) & fish.id$PosY > (fish.id$PosY.ma-thresh) & fish.id$PosZ < (fish.id$PosZ.ma+thresh) & fish.id$PosZ > (fish.id$PosZ.ma-thresh) | is.na(fish.id$PosX.ma) == TRUE)
    
    rem.tot <- rbind(rem.tot, rem)
    iteration <- iteration+1
    
    if (nrow(rem) == 0){break}
    rem <- data.frame(numeric(0))
  }
  
  fish.id$PosX.ma <- NULL
  fish.id$PosY.ma <- NULL
  fish.id$PosZ.ma <- NULL
  
  fish.id <<- fish.id
  
}


# function to calculate fish headings from positions (outputs vector of fish headings)

heading.func <- function(){
  
  diffx <- diff(dayfile$PosX)
  diffy <- diff(dayfile$PosY)
  heading <- numeric()
  
  for (i in 1:length(diffx)){
    
    
    if(diffx[[i]] > 0.02 & diffy[[i]] > 0.02) {
      
      heading <- c(heading, round((atan(diffy[[i]]/diffx[[i]]))*180/pi, 2))
      
    } else {
      
      if(diffx[[i]] > 0.02 & diffy[[i]] < -0.02) {
        
        heading <- c(heading, round(90+((atan((diffy[[i]]*-1)/diffx[[i]]))*180/pi), 2)) 
        
      } else {
        
        if(diffx[[i]] < -0.02 & diffy[[i]] < -0.02) {
          
          heading <- c(heading, round(270-((atan((diffy[[i]]*-1)/(diffx[[i]]*-1)))*180/pi), 2))
          
        } else {
          
          if(diffx[[i]] < -0.02 & diffy[[i]] > 0.02){
            
            heading <- c(heading, round(270+((atan(diffy[[i]]/(diffx[[i]]*-1)))*180/pi), 2)) 
            
          } else {
            
            if(diffx[[i]] == 0 & diffy[[i]] > 0.02) {
              
              heading <- c(heading, 0)
              
            } else {
              
              if(diffx[[i]] > 0.02 & diffy[[i]] == 0) {
                
                heading <- c(heading, 90)
                
              } else {
                
                if(diffx[[i]] == 0 & diffy[[i]] < -0.02) {
                  
                  heading <- c(heading, 180)
                  
                } else {
                  
                  if(diffx[[i]] < -0.02 & diffy[[i]] == 0) {
                    
                    heading <- c(heading, 270)
                    
                  } else {
                    
                    heading <- c(heading, NA)
                    
                  }
                  
                }
                
                
              }
              
              
            }
            
          }
          
        }
        
      }
      
    }
    
  }
  
  heading <<- heading
  
}


# function to calculate fish turn angles from positions (outputs vector of fish turn angles)

turn.angles <- function(){

theta <- numeric()

d1 <- sqrt(diff(dayfile$PosX)^2+diff(dayfile$PosY)^2+diff(dayfile$PosZ)^2)
d1 <- head(d1, length(d1)-1)
d2 <- sqrt(diff(dayfile$PosX)^2+diff(dayfile$PosY)^2+diff(dayfile$PosZ)^2)
d2 <- tail(d2, length(d2)-1)
d3 <- sqrt(diff(dayfile$PosX, lag = 2)^2+diff(dayfile$PosY, lag = 2)^2+diff(dayfile$PosZ, lag = 2)^2)

for (i in 1:(nrow(dayfile)-2)){
  
  theta <- c(theta, 180-(acos(((d1[[i]])^2+(d2[[i]])^2-(d3[[i]])^2)/(2*d1[[i]]*d2[[i]]))*180/pi))
  
}

theta <<- theta


}











