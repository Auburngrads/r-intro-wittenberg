
clean_columns <- function(data,theme = "flatly", width = '100%', 
                          css = './resources/shinyApps.css',height = '600px',...) {

do.call('library',args = list('DT'))
do.call('library',args = list('data.table'))
do.call('library',args = list('shiny'))

ui = fluidPage(theme = shinythemes::shinytheme(theme = theme),
               tags$head(try(includeCSS(css), silent = T)),
               
sidebarLayout(
  sidebarPanel(width = 3,
    uiOutput("names"),
    actionButton('done',h4('Finish'), width = '100%')), 
  
    mainPanel(width = 9,
              DT::dataTableOutput("cleandata", height = "600px"))))

server = function(input, output) {

output$names <- renderUI({
  
  selectizeInput('remove', 
                 h4('Columns To Remove'),
                 choices = colnames(data),
                 selected = NULL, 
                 multiple = TRUE)
})


clean.data <- reactive({ as.data.table(data)[,as.character(input$remove):= NULL] })

  output$cleandata <- DT::renderDataTable({
    
      DT::datatable(clean.data(),
                    fillContainer = T,
                    width = '100%')
    
})
  observeEvent(input$done, { 
    
    colnums = lapply(X = input$remove,
                     FUN = function(x) { which(colnames(data)==x)})
    
    paste1 <- paste(c(unlist(colnums)), collapse = ',')
    paste2 <- parse(text = paste(c('c(',paste1,')'), collapse = ''))
    script <- paste(c('data[, -',paste2[[1]],']'), collapse = '')
    
    stopApp(list(data = as.data.frame( clean.data() ),
                 script = parse(text = script)[[1]]))
    
})
}
runGadget(app = ui,
          server = server,
          viewer = browserViewer(browser = getOption("browser")))
}
