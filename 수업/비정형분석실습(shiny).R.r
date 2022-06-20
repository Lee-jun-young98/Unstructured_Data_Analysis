library(shiny)

# 샤이니 예제 
runExample()

runExample(example = '01_hello')

ui <- fluidPage(
  'Hello, Data Science!'
)

server <- function(input, output, session) {}

shinyApp(ui = ui, server = server)


ui <- fluidPage(
  selectInput(inputId = 'dataset',
              label = '데이터셋', 
              choices = ls(name = 'pacakge:datasets')),
  verbatimTextOutput(outputId = 'summary'),
  tableOutput(outputId = 'table')
)
