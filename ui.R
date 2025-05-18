library(shiny)
library(DT)

shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    
    div(class = "title-panel",
        titlePanel(
          div(
            icon("chart-line", class = "me-2"),
            "Coal Index Price Dashboard",
            class = "text-center"
          )
        )
    ),
    
    div(class = "fixed-sidebar",
        h4("Upload CSV File"),
        fileInput("file", label = NULL, accept = ".csv"),
        helpText("Only .csv files allowed."),
        helpText("Please upload according to the standard format only."),
        uiOutput("inputsUI"),
        br(),
        h4("Download Format"),
        downloadButton("download_format", "Download Format"),
        br(),
        br(),
        h4("Download Results"),
        downloadButton("download_final", "Download Index Output CSV")
    ),
    
    div(class = "main-content",
        conditionalPanel(
          condition = "output.fileUploaded",
          tabsetPanel(
            tabPanel("General Charts",
                     plotOutput("gg_line"),
                     br(), br(),
                     plotOutput("gg_bar"),
                     br(), br(),
                     plotOutput("gg_box")
            ),
            tabPanel("Interactive Charts",
                     plotlyOutput("plotly_line", height = '400px'),
                     br(), br(),
                     plotlyOutput("plotly_donut", height = '450px')
            ),
            tabPanel("Table/Indices", DTOutput("indexTable")),
            
          
            tabPanel("Notes",
                     fluidPage(
                       h2("App Features"),
                       tags$ul(
                         tags$li(strong("CSV Upload:"), " Upload raw deal data in .csv format."),
                         tags$li(strong("VWAP Calculation:"), " Calculates Volume Weighted Average Price (VWAP) per day."),
                         tags$li(strong("Index Inclusion Criteria:"),
                                 tags$ul(
                                   tags$li("Only include deals where delivery starts within 180 days of the deal date."),
                                   tags$li("COAL2: Delivery in ARA, AMS, ROT, or ANT."),
                                   tags$li("COAL4: Commodity Source Location is South Africa.")
                                 )),
                         tags$li(strong("Interactive Filters:"), " Select indices and deal date ranges dynamically."),
                         tags$li(strong("Charts:"), " Visualize index trends via ggplot2 and Plotly charts."),
                         tags$li(strong("Table Output:"), " View clean DT table with export options."),
                         tags$li(strong("Downloads:"), " Download the input format and final index output as CSV.")
                       )
                     )
            )
          ),
          
          br(),
          div("By Tarun Barkoti", class = "text-center",
              style = "margin-top: 30px; font-weight: bold; font-size: 16px;")
        )
    )
  )
)
