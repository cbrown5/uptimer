# Shiny
library(shiny)
library(plotly)
library(dplyr)
library(lubridate)
 # devtools::load_all("..")
#TODO: missing students with zero hours from table
source("data-prep.R")

ui <- fluidPage(

  titlePanel("Uptimer: an R app for time management"),
      tabsetPanel(
        tabPanel("Dashboard",
          fluidRow(
            column(4,
            sliderInput(inputId = "recent_days",
                           label = "Weeks before now",
                           min = 0,
                           max = 48,
                           value = 4),
            textOutput("hours_spent"),
            tags$head(tags$style("#hours_spent{color:grey;}"))
          ),
          column(6, DT::dataTableOutput("table"))
          ),
          fluidRow(br(),
            column(6, style='padding:1rem;',
                   plotlyOutput("plot_recent2")
            ),
            column(6, style='padding:1rem;',
                   plotlyOutput("plot_recent")
          )
        )),
        tabPanel("Projects by time",
        fluidRow(
          plotlyOutput("plot1")
          ),

          fluidRow(
            dateRangeInput(inputId = "date_range",
                        label = "Date Range",
                        start = date(Sys.time())-365,
                        startview = "year",
                        weekstart = 1)
            ,
            numericInput(inputId = "max_proj",
                            label = "Maximum projects to display",
                            value = 10),
            checkboxGroupInput(inputId = "remove_these",
                               label = c("Remove from graph"),
                               choices = rm_grps,
                               selected = rm_grps,
                               inline = TRUE)
          )
        ),
        tabPanel("Single project",
                 fluidRow(plotlyOutput("plot2")),
                 fluidRow(
                   dateRangeInput(inputId = "date_range2",
                                  label = "Date Range",
                                  start = "2015-10-14",
                                  startview = "year",
                                  weekstart = 1),
                   selectInput(inputId = "projcode",
                               label = "Project code",
                               selected = "email",
                               choices = project_codes,
                               multiple = TRUE),
                   checkboxInput(inputId = "plot_cum",
                                      label = c("Plot cumulative hours?"),
                                      value = TRUE),
                   checkboxInput(inputId = "add_lines",
                                 label = c("Plot baselines?"),
                                 value = TRUE)
                 )
        ),
        tabPanel("Data",
                 fluidRow(
                   selectInput(inputId = "projcode_targets",
                               label = "Project code",
                               choices = project_codes,
                               multiple = FALSE),
                   numericInput(inputId = "hours_targets", label = "Target (hours)", value = 100)
                 ),
        fluidRow(actionButton("submit", "Submit"))
        )
  )
)

server <- function(input, output) {

  output$hours_spent <- renderText({
    hdat <- dat %>% filter(datex > (date(Sys.time()) -input$recent_days*7)) %>%
      summarize(hours = sum(time_taken)/60)
    paste(
          round(hdat$hours/8,1),"/",input$recent_days*5)
  })

  # students_table <- sdat %>% filter(datex > (date(Sys.time()) -input$recent_days*7)) %>%
    # group_by(Person) %>% summarize(hours = round(sum(time_taken)/60,1)) %>%
    # arrange(desc(hours))
  
    output$table <- DT::renderDataTable(
    DT::datatable(sdat %>% group_by(Person) %>% 
                    mutate(hours_recent = 
                             ifelse(datex > (date(Sys.time()) -input$recent_days*7),
                           time_taken,0)) %>%
                    summarize(hours = round(sum(hours_recent)/60,1)) %>%
                    tidyr::complete(Person, fill  =list(hours = 0)) %>%
                    arrange(desc(hours)),
    options = list(paging = FALSE, searching = FALSE)))

  output$plot_recent2 <- renderPlotly({
    date_filt <- date(Sys.time()) -input$recent_days*7
    rdat <- dat %>% filter(datex > date_filt) %>%
      group_by(Task) %>%
      summarize(hours = sum(time_taken)/60) %>%
      arrange(desc(hours))
    xform <- list(categoryorder = "array",
                  categoryarray = rdat$Task,
                  title ="")
    m <- list(l = 50, r = 50,  b = 200,t = 20,  pad = 4)
    plot_ly(data=rdat, x = ~Task, y = ~hours, type = "bar",
            text = ~Task) %>%
      layout(xaxis = xform, margin = m)
  })

    output$plot_recent <- renderPlotly({
      date_filt <- date(Sys.time()) - input$recent_days*7
      rdat <- dat %>% filter(datex > date_filt) %>%
        filter(!(Project %in% input$remove_these)) %>%
        group_by(Project) %>%
        summarize(hours = sum(time_taken)/60) %>%
        arrange(desc(hours))
      rdat <- rdat[1:10,]
      xform <- list(categoryorder = "array",
                    categoryarray = rdat$Project,
                    title ="")
      m <- list(l = 50, r = 50,  b = 200,t = 20,  pad = 4)
      plot_ly(data=rdat, x = ~Project, y = ~hours, type = "bar",
              text = ~Project) %>%
        layout(xaxis = xform, margin = m, title = "Top 10 projects")
    })



    output$plot1 <- renderPlotly({
      pdat <- dat %>% filter((datex > input$date_range[1]) & (datex < input$date_range[2])) %>%
        filter(!(Project %in% input$remove_these)) %>%
        group_by(Project) %>%
        summarize(hours = sum(time_taken)/60) %>%
        arrange(desc(hours))
      pdat <- pdat[1:input$max_proj,]

      xform <- list(categoryorder = "array",
                    categoryarray = pdat$Project,
                    title ="")
       m <- list(l = 50, r = 50,  b = 200,t = 20,  pad = 4)
      plot_ly(data=pdat, x = ~Project, y = ~hours, type = "bar",
              text = ~Project) %>%
        layout(xaxis = xform, margin = m)
    })

    output$plot2 <- renderPlotly({

      pdat2 <- dat %>%
        filter((datex > input$date_range2[1]) & (datex < input$date_range2[2])) %>%
        filter(Project %in% input$projcode) %>%
        group_by(datex) %>%
        summarize(hours = sum(time_taken)/60, Notes = paste(Notes[!is.na(Notes)], collapse = "; ")) %>%
        arrange(datex) %>%
        mutate(cum_hrs = cumsum(hours))
      if (sum(input$projcode %in% rm_grps)>=1) {
        col <- "orange"
          } else {
        col <- "steelblue"}
      shapes <- NULL
     if(input$plot_cum){
         yform <- formula(paste("~", "cum_hrs"))
         min_x <- min(pdat2$datex)
         max_x <- max(pdat2$datex)
         yaxt <- list(title = "Cumulative hours")

         if (input$add_lines){
        shapes <- list(
                    list(type = "line", x0=min_x, x1 = max_x,
                                    y0=mintime, y1=mintime,
                                  line = list(color = "grey", dash = "dash")),
                    list(type = "line", x0=min_x, x1 = max_x,
                         y0=maxtime, y1=maxtime,
                         line = list(color = "grey", dash = "dash")),
                    list(type = "line", x0=min_x, x1 = max_x,
                         y0=medtime, y1=medtime,
                         line = list(color = "grey")))

         }
      } else {
        yform <- formula(paste("~", "hours"))
        yaxt <- list(title = "Hours")
      }

      m <- list(l = 50, r = 50,  b = 40,t = 20,  pad = 4)
      xaxt <- list(title ="")

      plot_ly(data=pdat2, x = ~datex, y = yform, type = "bar",
              marker = list(color = col), 
              text = ~paste(Notes)) %>%
        layout(xaxis = xaxt, margin = m, yaxis = yaxt, shapes = shapes)

    })
    
    #Tab for setting project targets 
    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData()
    })     

}

source("save-data.R")

shinyApp(ui = ui, server = server)
