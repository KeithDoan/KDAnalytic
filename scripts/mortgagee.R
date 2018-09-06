# This file is generated and can be overwritten.
 library(dplyr) 

refine_dataframe <- function(df) { 
  df <- mutate( df ,`HouseholdIncome` = stringr::str_replace_all(`HouseholdIncome`, stringr::regex("[\\\\$\\\\.]"), ""))
  df <- mutate( df ,`HouseholdIncome` = as.integer(`HouseholdIncome`))
  df <- rename( df ,`Income` = `HouseholdIncome`)
  df <- mutate( df ,`SalePrice` = as.integer(`SalePrice`))
  df <- mutate( df ,`Location` = as.integer(`Location`))
  df <- mutate( df ,`Age` = as.integer(`Age`))
  df <- mutate( df ,`EducationLevel` = as.integer(`EducationLevel`))
  df <- mutate( df ,`YearsWithCurrentEmployer` = as.integer(`YearsWithCurrentEmployer`))
  df <- mutate( df ,`YearsAtCurrentAddress` = as.integer(`YearsAtCurrentAddress`))
  df <- mutate( df ,`LoanAmount` = as.double(`LoanAmount`))
  df <- mutate( df ,`DebtIncomeRatio` = as.double(`DebtIncomeRatio`))
  df <- mutate( df ,`CreditCardDebt` = as.double(`CreditCardDebt`))
  df <- mutate( df ,`OtherDebt` = as.double(`OtherDebt`))
  df <- mutate( df ,`NumberOfCards` = as.integer(`NumberOfCards`))
  df <- tidyr::separate( df ,`City`, into = c('State','CityArea'), remove = TRUE, extra = 'merge', fill = 'right')
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