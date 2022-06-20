library(shiny)
library(tidyverse)
library(shinythemes)

ui <- fluidPage(
  theme = shinytheme(theme = 'united'),
  titlePanel(title = '텍스트 파일을 불러와서 산점도를 그립니다.'),
  sidebarPanel(
      fileInput(inputId = 'file',
                 label = '`csv`또는 `txt`파일을 선택하세요.',
                 multiple = FALSE,
                 buttonLabel = icon(name = 'serach'),
                 placeholder = '아직 파일이 선택되지 않았습니다.'),
      radioButtons(inputId = 'sep',   # App 화면에서 출력되는 '보기'와 넘어가는 값이 서로 다름
                   label = '구분자를 선택하세요.',
                   choices = c('콤마' = ',', '세미콜론' = ';',
                           '탭' = '\t', '공백' = ''),
                 selected = ',', # '보기'의 기본값으로 콤마(,)를 체크된 상태로 출력합니다.
                 inline = TRUE), # '보기'를 한 줄로 출력합니다.
      checkboxInput(inputId = 'header', # 선택할 수 있는 컬럼의 목록을 처음에는 NULL로 설정하지만, 'server'에서 텍스트 파일을 불러올 때 컬럼명으로 업데이트
                label = '첫 번째 행은 헤더입니다.',
                value = TRUE),
      selectInput(inputId = 'x',
              label = 'x축에 놓을 숫자형 변수를 선택하세요.',
              choices = NULL), # 선택할 수 있는 컬럼의 목록을 처음에는 NULL로 설정하지만, 'server'에서 텍스트 파일을 불러올 때 컬럼명으로 업데이트 됩니다.
      selectInput(inputId = 'y',
              label = 'y축에 놓을 숫자형 변수를 선택하세요.',
              choices = NULL),
      selectInput(inputId = 'z',
              label = '색상을 참고할 범주형 변수를 선택하세요.',
              choices = NULL),
      submitButton(text = '변경사항을 적용합니다.',
               icon = icon(name = 'sync'))
      ),
  mainPanel(
  uiOutput(outputId = 'mainUI') # 'server'에서 renderUI() 함수로 만든 'mainUI'를 출력
  )
)


server <- function(input, output, session) {
  df <- reactive({
    if(is.null(x = input$file)) return()
    read.csv(file = input$file$datapath, header = input$header,
             sep = input$sep, stringsAsFactors = TRUE)
  })
  
  observe({
    cols <- colnames(x=df())
    updateSelectInput(session = session, inputId = 'x', choices = cols)
    updateSelectInput(session = session, inputId = 'y', choices = cols)
    updateSelectInput(session = session, inputId = 'z', choices = cols)
  })
  
  output$table <- renderTable({
    if(is.null(x = df())) return() else df()[1:5,] # df()의 처음 5행만 테이블로 출력
  })
  
  output$glimpse <- renderPrint({
    if(is.null(x = df())) return() else glimpse(x = df()) # df()의 컬럼별 속성과 미리보기를 출력
  })
  
  output$plot <- renderPlot({
    ggplot(data = df(),
           mapping = aes(x = df()[,input$x],
                         y = df()[,input$y],
                         color = df()[,input$z])) +
      geom_point(shape = 19, size = 3) +
      labs(title = 'Scatter plot', x = input$x, y =input$y) +
      theme_bw() +
      theme(plot.title = element_text(face = 'bold', hjust = 0.5),
            legend.title = element_blank(),
            legend.position = 'bottom')
  })
  
  output$mainUI <- renderUI({
    if(is.null(x = df()))h4("아직 표시할 내용이 없습니다.")
    else tabsetPanel(
      tabPanel(title = 'Data',
               tableOutput(outputId = 'table'),
               verbatimTextOutput(outputId = 'glimpse')),
      tabPanel(title = 'Plot',
               plotOutput(outputId = 'plot'))
    ) # tabsetPanel() 함수 닫음
  }) # renderUI() 함수 닫음
} # function 함수 닫음

shinyApp(ui = ui, server = server)
