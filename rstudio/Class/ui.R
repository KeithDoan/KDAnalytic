#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
newClassDF <- read.csv("new_class.csv")
oldClassDF <- read.csv("class.csv")

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Analyse Recent Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("xvar",
                  label = h3("Choose X-axis Variable"),
                  choices = colnames(newClassDF[, -1])
      ),
      selectInput("yvar",
                  label = h3("Choose Y-axis Variable"),
                  choices = colnames(newClassDF[, -1]),
                  selected = "CurrentBalance"
      ),
      br(),
      checkboxInput("newPoints", label = "Plot new class data?")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Explore", plotOutput("plot"),
                           br(), br(),
                           h4("Table of Recent Data:"),
                           fluidRow(
                             DT::dataTableOutput("table"))
                  ), 
                  tabPanel("Model",
                           br(), br(),
                           "Please enter data points for prediction.  The model will return a classification.", 
                           br(), hr(),
                           fluidRow(
                             column(4,
                                    selectInput("location", "Location:", choices = c("Urban", "Rural", "Suburban")),
                                    numericInput("lengthOfTime", "Length of Time (years):", min = 0.63, max = 9.38, value = 0.63, width = 75),
                                    numericInput("currentBalance", "Current Balance (AUD):", min = 434.75, max = 1935.305, value = 434.75, width = 75),
                                    numericInput("income", "Income:", min = 27000, max = 232000, value = 27000, width = 75)),
                             column(4,
                                    numericInput("workingFulltime", "Working FullTime:", min = 0, max = 1, value = 1, width = 75),
                                    numericInput("avgTrans", "Average Transactions per Year:", min = 16, max = 80, value = 16, width = 75),
                                    numericInput("lineOfCredit", "Line of Credit:", min = 0, max = 1, value = 1, width = 75),
                                    numericInput("homeLoan", "Home Loan:", min = 0, max = 1, value = 1, width = 75)),
                             column(4,
                                    numericInput("superanuation", "Superanuation:", min = 0, max = 1, value = 0, width = 75),
                                    numericInput("educationSaver", "Education Saver:", min = 0, max = 1, value = 0, width = 75),
                                    numericInput("investment", "Investment:", min = 0, max = 1, value = 0, width = 75))
                           ),
                           br(),br(),
                           actionButton("getPrediction", "Determine Class"),
                           verbatimTextOutput("predict")
                  )
                  
      )
    )
  )
)
)
