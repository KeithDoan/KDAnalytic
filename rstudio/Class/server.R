#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  library(shiny)
  library(data.table)
  library(ggplot2)
  library(randomForest)
  
  ## load data and model
  newClassDF <- read.csv("./new_class.csv")
  oldClassDF <- read.csv("./class.csv")
  
  classModel <- readRDS(file = "./ClassModel.rds")
  
  ## Render plot and conditional statement for new points
  output$plot <- renderPlot({
    if(input$newPoints == F){
      ggplot(oldClassDF, aes_string(x=input$xvar, y=input$yvar)) + 
        geom_point(aes(color = Location, shape = Location), size = 2) +
        theme_minimal()
    } else
      ggplot(oldClassDF, aes_string(x=input$xvar, y=input$yvar)) + 
      geom_point(aes(color = Location, shape = Location), size = 2) +
      geom_point(data = newClassDF, aes_string(x = input$xvar, y = input$yvar), size = 4, shape = 8) +
      theme_minimal()
    
  })
  
  ## Render table with new records
  output$table <- DT::renderDataTable(DT::datatable({
    
    data <- newClassDF[, c("CustomerID", "LengthOfTime", "CurrentBalance",
                            "Location", "AvgTrans", "WorkingFulltime", "Income")]
    
    data
    
  }))
  
  ## Get predictions based on user input
  toPredict <- eventReactive(input$getPrediction,{
    
    toPredictDF <- data.frame(
      LengthOfTime = input$lengthOfTime,
      CurrentBalance = input$currentBalance,
      Location = as.factor(input$location),
      Income = input$income,
      LineOfCredit = input$lineOfCredit,
      HomeLoan = input$homeLoan,
      Superanuation = input$superanuation,
      EducationSaver = input$educationSaver,
      Investment = input$investment,
      WorkingFulltime = input$workingFulltime,
      AvgTrans = input$avgTrans)
    
    levels(toPredictDF$Location) <- c("Urban", "Suburban", "Rural")
    
    prediction <- predict(classModel, toPredictDF)
    
    prediction
  
    
  })  
  
  ## Render the prediction in the UI
  output$predict <- renderPrint({
    toPredict()
    
  })
  
})
