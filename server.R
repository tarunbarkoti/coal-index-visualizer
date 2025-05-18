library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(lubridate)
library(readr)
library(plotly)

shinyServer(function(input, output, session) {

  output$fileUploaded <- reactive({ !is.null(input$file) })
  outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)
  
  deals_data <- reactive({
    req(input$file)
    data <- read_csv(input$file$datapath, show_col_types = FALSE)
    
    data <- data %>%
      mutate(
        Deal_Date = dmy(Deal_Date),
        Start_Date = as.Date(paste("01", Delivery_Month, Delivery_Year), format = "%d %b %Y")
      ) %>%
      filter(Start_Date <= Deal_Date + 180) %>%
      mutate(Index = case_when(
        Delivery_Location %in% c("ARA", "AMS", "ROT", "ANT") ~ "COAL2",
        Commodity_Source_Location == "South Africa" ~ "COAL4",
        TRUE ~ NA_character_
      )) %>%
      filter(!is.na(Index))
  })

    
  
  output$inputsUI <- renderUI({
    req(deals_data())
    tagList(
      selectInput("indexChoice", "Select Index", choices = unique(deals_data()$Index), 
                  selected = unique(deals_data()$Index), multiple = TRUE),
      dateRangeInput("dateRange", "Select Deal Date Range",
                     start = min(deals_data()$Deal_Date, na.rm = TRUE),
                     end = max(deals_data()$Deal_Date, na.rm = TRUE))
    )
  })
  
  filtered_data <- reactive({
    req(deals_data(), input$indexChoice, input$dateRange)
    deals_data() %>%
      filter(
        Index %in% input$indexChoice,
        Deal_Date >= input$dateRange[1],
        Deal_Date <= input$dateRange[2]
      )
  })
  
  index_prices <- reactive({
    filtered_data() %>%
      group_by(Index, Deal_Date) %>%
      summarise(
        VWAP = round(sum(Price * Volume) / sum(Volume), 2),
        .groups = "drop"
      )
  })
  
  
  
  output$indexTable <- renderDT({
    data <- index_prices()
    req(nrow(data) > 0)
    
    datatable(
      data,
      extensions = c('Buttons', 'Scroller'),
      options = list(
        dom = 'Bfrtip',
        buttons = c('print'),
        scrollX = TRUE,
        scrollY = 400,
        scroller = TRUE,
        pageLength = 10,
        autoWidth = TRUE
      ),
      rownames = FALSE,
      class = "display nowrap beautiful-table"
    )
  })
  
  
  # ---------------- ggplot2 Charts ----------------
  output$gg_line <- renderPlot({
    ggplot(index_prices(), aes(x = Deal_Date, y = VWAP, color = Index)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 3) +
      labs(title = "Index Price Over Time (ggplot2)", y = "VWAP", x = "Deal Date") +
      theme_minimal(base_size = 15)
  })
  
  output$gg_bar <- renderPlot({
    index_prices() %>%
      group_by(Index) %>%
      summarise(Average_VWAP = mean(VWAP, na.rm = TRUE)) %>%
      ggplot(aes(x = Index, y = Average_VWAP, fill = Index)) +
      geom_bar(stat = "identity", width = 0.5) +
      labs(title = "Average VWAP by Index (ggplot2)", y = "Avg VWAP", x = "Index") +
      theme_minimal(base_size = 15) +
      theme(legend.position = "none")
  })
  
  output$gg_box <- renderPlot({
    ggplot(index_prices(), aes(x = Index, y = VWAP, fill = Index)) +
      geom_boxplot() +
      labs(title = "VWAP Distribution by Index (ggplot2)", y = "VWAP", x = "Index") +
      theme_minimal(base_size = 15) +
      theme(legend.position = "none")
  })
  
  
  
  # ---------------- Plotly Charts ----------------
  output$plotly_line <- renderPlotly({
    plot_ly(index_prices(), x = ~Deal_Date, y = ~VWAP, color = ~Index,
            type = 'scatter', mode = 'lines+markers') %>%
      layout(title = "Index Price Over Time (Plotly)", yaxis = list(title = "VWAP"))
  })
  
  output$plotly_donut <- renderPlotly({
    filtered_data() %>%
      group_by(Index) %>%
      summarise(TotalVolume = sum(Volume, na.rm = TRUE)) %>%
      plot_ly(labels = ~Index, values = ~TotalVolume, type = 'pie',
              hole = 0.5, textinfo = 'label+percent') %>%
      layout(title = "Volume Distribution (Donut)")
  })
  
  
  output$download_format <- downloadHandler(
    filename = function() {
      "standard_format.csv"
    },
    content = function(file) {
      file.copy("www/standard_format.csv", file)
    }
  )
  
  
  output$download_final <- downloadHandler(
    filename = function() {
      paste0("Index_Prices_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write_csv(index_prices(), file)
    }
  )
})