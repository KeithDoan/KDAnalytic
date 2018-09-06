# This file is generated and can be overwritten.
 library(dplyr) 

refine_dataframe <- function(df) { 
  df <- mutate( df ,`CUST_ID`=digest::digest(`CUST_ID`, seed=2, algo="md5"))
  df <- select( df ,-`BIRTH_DATE`)
  df <- mutate( df ,`INVESTMENT` = as.integer(`INVESTMENT`))
  df <- mutate( df ,`AGE` = as.integer(`AGE`))
  df <- mutate( df ,`ACTIVITY` = as.integer(`ACTIVITY`))
  df <- mutate( df ,` YRLY_AMT` = as.double(` YRLY_AMT`))
  df <- mutate( df ,`AVG_DAILY_TX` = as.double(`AVG_DAILY_TX`))
  df <- mutate( df ,`YRLY_TX` = as.integer(`YRLY_TX`))
  df <- mutate( df ,`AVG_TX_AMT` = as.double(`AVG_TX_AMT`))
  df <- mutate( df ,`NEGTWEETS` = as.integer(`NEGTWEETS`))
  df <- mutate( df ,`label` = as.integer(`label`))
  df <- mutate( df ,`INCOME` = as.integer(`INCOME`))
  df <- mutate( df ,`AGE_GROUP` = `AGE`/20)
  df <- mutate( df ,`AGE_GROUP` = as.integer(`AGE_GROUP`))
  return (df) 
}

refine_file <- function(inputFile, outputFile) { 
  if(file.exists(inputFile)){ 
    if (!is.na(outputFile) && file.exists(outputFile)) {
      return(paste0("Output file: ", outputFile, " already exists "))
    }
    df <- read.csv(inputFile, check.names=FALSE) 
    df <- refine_dataframe(df) 
    if (!is.na(outputFile)) {
        write.csv(df, file = outputFile, row.names=FALSE)
        print(paste0(paste0("Writing to ", outputFile) ," file is complete"))
    } else {
      return (df)
    }
  } else {
    print(paste0(inputFile, " file does not exist ")) 
   }
} 

args <- commandArgs(TRUE)
if (length(args)>0) { 
  refine_file(args[1], args[2])
}