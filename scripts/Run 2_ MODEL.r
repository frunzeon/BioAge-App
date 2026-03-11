# app.R

# ------------------------------------------------------------------------------
# # Shiny Bee Age Prediction App (Immune Aging Index)
# Copyright (c) 2025 Olga Frunze
# Licensed under the MIT License.
# See LICENSE file in the repository root for full license text.

# Contact:
# Prof. Hyung-Wook Kwon – Department of Life Sciences, Incheon National University
# Email: hwkwon@inu.ac.kr
# ------------------------------------------------------------------------------

library(shiny)
library(readr)
library(dplyr)
library(stringr)
library(glmnet)
library(openxlsx)
library(ggplot2)
library(tibble)

# -------------------------------
# 1. Hardcoded training data
# -------------------------------
training_data <- data.frame(
  Group_days = c(rep("1(0-8)", 12), rep("2(10-16)", 12), rep("3(18-21)", 6), rep("4(25-26)", 3)),
  Dome = c(1,1,1,1.36,1.38,1.69,0.9,1.03,0.78,1.21,1.53,1.42,
           1.65,1.45,1.42,1.74,1.49,1.38,1.64,1.35,1.33,1.65,2.38,1.72,
           1.77,1.77,2.66,3.16,2.57,4.38,
           2.99,4.38,3.14),
  SOD1 = c(1,1,1,5.82,7.06,7.26,1.97,2.66,2.3,2.19,2.5,3.1,
           2.14,1.89,2.38,2.00,2.11,1.97,0.78,1.29,1.46,2.27,2.62,2.68,
           1.84,2.33,2.45,2.25,2.25,2.5,
           1.21,1.37,1.24),
  Relish = c(1,1,1,2.3,1.49,1.03,2.23,1.77,1.26,2.08,1.65,1.45,
             4.32,2.87,2.2,1.96,1.43,1.51,1.92,1.65,1.26,2.73,2.89,2.11,
             2.31,2.08,1.56,7.16,4.44,2.97,
             229.13,196.72,150.12),
  Apid1 = c(1,1,1,26.35,32.67,34.06,29.24,33.36,34.54,67.18,83.87,77.17,
            143.01,127.12,116.16,72.00,91.14,89.88,84.45,80.45,89.88,102.54,114.56,117.78,
            167.73,177.29,240.52,151.17,132.51,165.42,
            75.06,150.12,103.97)
)

training_data <- training_data %>%
  mutate(Age_mid = str_extract(Group_days, "\\d+-\\d+") %>%
           str_split("-", simplify = TRUE) %>%
           apply(1, function(x) mean(as.numeric(x))))

X_train <- as.matrix(training_data[, c("Dome", "SOD1", "Relish", "Apid1")])
y_train <- training_data$Age_mid

# Fit model
set.seed(123)
model <- cv.glmnet(X_train, y_train, alpha = 0.5)
best_lambda <- model$lambda.min

# Hardcoded reference for normalization
ref <- data.frame(
  Ct_Actin_SOD1 = mean(c(16.52, 16.46, 16.32)),
  Ct_SOD1 = mean(c(19.82, 19.81, 19.73)),
  Ct_Actin_Dome_Apid1 = mean(c(16.07, 16.07, 16.08)),
  Ct_Dome = mean(c(23.77, 23.53, 23.6)),
  Ct_Apid1 = mean(c(25.72, 25.83, 25.87)),
  Ct_Actin_Relish = mean(c(16.28, 16.34, 16.25)),
  Ct_Relish = mean(c(22.66, 22.39, 22.01))
)

# -------------------------------
# UI
# -------------------------------
ui <- fluidPage(
  titlePanel("Biological Age Prediction of Honey Bees (Immune Aging Index)"),
  sidebarLayout(
    sidebarPanel(
      fileInput("datafile", "Upload Gene Expression File (.txt)", accept = ".txt"),
      helpText("The input .txt file should contain the following columns:",
               "Sampleage, Ct_Actin_SOD1, Ct_SOD1, Ct_Actin_Dome_Apid1, Ct_Dome, Ct_Apid1, Ct_Actin_Relish, Ct_Relish."),
      downloadButton("download_excel", "Download Excel"),
      downloadButton("download_plot", "Download Plot")
    ),
    mainPanel(
      plotOutput("bee_plot"),
      tableOutput("result_table")
    )
  )
)

# -------------------------------
# Server
# -------------------------------
server <- function(input, output) {
  user_data <- reactive({
    req(input$datafile)
    df <- read.table(input$datafile$datapath, sep = "\t", header = TRUE)
    
    # Check for required columns
    req(all(c("Sampleage", "Ct_Actin_SOD1", "Ct_SOD1", "Ct_Actin_Dome_Apid1", 
              "Ct_Dome", "Ct_Apid1", "Ct_Actin_Relish", "Ct_Relish") %in% names(df)))
    
    df
  })
  
  prediction_result <- reactive({
    df <- user_data()
    
    df_norm <- df %>%
      mutate(
        deltaCt_SOD1 = Ct_SOD1 - Ct_Actin_SOD1,
        deltaCt_Dome = Ct_Dome - Ct_Actin_Dome_Apid1,
        deltaCt_Apid1 = Ct_Apid1 - Ct_Actin_Dome_Apid1,
        deltaCt_Relish = Ct_Relish - Ct_Actin_Relish,
        
        ddCt_SOD1 = deltaCt_SOD1 - (ref$Ct_SOD1 - ref$Ct_Actin_SOD1),
        ddCt_Dome = deltaCt_Dome - (ref$Ct_Dome - ref$Ct_Actin_Dome_Apid1),
        ddCt_Apid1 = deltaCt_Apid1 - (ref$Ct_Apid1 - ref$Ct_Actin_Dome_Apid1),
        ddCt_Relish = deltaCt_Relish - (ref$Ct_Relish - ref$Ct_Actin_Relish),
        
        relExp_Dome = 2^(-ddCt_Dome),
        relExp_SOD1 = 2^(-ddCt_SOD1),
        relExp_Relish = 2^(-ddCt_Relish),
        relExp_Apid1 = 2^(-ddCt_Apid1)
      )
    
    X_user <- as.matrix(df_norm[, c("relExp_Dome", "relExp_SOD1", "relExp_Relish", "relExp_Apid1")])
    prediction <- predict(model, newx = X_user, s = best_lambda)
    
    df_norm$Predicted_Age_Days <- round(as.numeric(prediction), 2)
    df_norm
  })
  
  output$result_table <- renderTable({
    prediction_result() %>% select(Sampleage, Predicted_Age_Days)
  })
  
  output$bee_plot <- renderPlot({
    df <- prediction_result()
    ggplot(df, aes(x = Sampleage, y = Predicted_Age_Days)) +
      geom_point(color = "steelblue", size = 3) +
      labs(title = "Predicted biological age (Immune Aging Index) of Individual Honey Bee Samples",
           x = "Sample", y = "Predicted Age (day-equivalent)") +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 18, face = "bold"),
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"),
        axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
        axis.text.y = element_text(size = 12),
        panel.grid = element_blank(),
        axis.line = element_line(color = "black")
      )
  })
  
  output$download_excel <- downloadHandler(
    filename = function() { "Predicted_Age_Results.xlsx" },
    content = function(file) {
      df <- prediction_result()
      wb <- createWorkbook()
      addWorksheet(wb, "Results")
      writeData(wb, "Results", df)
      
      # Style for Predicted_Age_Days column: white bold text on blue background
      predicted_style <- createStyle(fontColour = "#FFFFFF", bgFill = "#1F77B4", textDecoration = "bold")
      addStyle(wb, sheet = "Results", style = predicted_style, 
               rows = 2:(nrow(df) + 1), cols = which(names(df) == "Predicted_Age_Days"), gridExpand = TRUE)
      
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
  
  output$download_plot <- downloadHandler(
    filename = function() { "Predicted_Age_Plot.png" },
    content = function(file) {
      df <- prediction_result()
      g <- ggplot(df, aes(x = Sampleage, y = Predicted_Age_Days)) +
        geom_point(color = "steelblue", size = 3) +
        labs(title = "Predicted Age of Individual Honey Bee Samples",
             x = "Sample", y = "Predicted Age (days)") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 18, face = "bold"),
          axis.title.x = element_text(size = 14, face = "bold"),
          axis.title.y = element_text(size = 14, face = "bold"),
          axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
          axis.text.y = element_text(size = 12),
          panel.grid = element_blank(),
          axis.line = element_line(color = "black")
        )
      ggsave(file, g, width = 10, height = 6)
    }
  )
}

# -------------------------------
# Launch the app
# -------------------------------

shinyApp(ui = ui, server = server)
