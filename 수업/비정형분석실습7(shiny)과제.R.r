library(shiny)
library(ggplot2)
library(tidyverse)
library(shinythemes)
library(RWeka)
library(e1071)
library(pracma)
library(signal)
library(seewave)


options(shiny.maxRequestSize=600*1024^2)
memory.limit(size=10000000024)
options(java.parameters = "-Xmx4g" )
RF <- make_Weka_classifier("weka/classifiers/trees/RandomForest")
Bayes_net <- make_Weka_classifier("weka/classifiers/bayes/BayesNet")



ui <- fluidPage(
  theme = shinytheme(theme = 'united'),
  titlePanel(title = "Feature 추출과 학습과정"),
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
    selectInput(inputId = 'feature',
                label = '추출할 변수를 선택하세요.',
                choices = NULL,
                multiple = TRUE),
    radioButtons(inputId = "model",
                 label = "모델을 선택하세요",
                 choices = c("Random Forest" = "RF", "J48" = "J48")),
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
    updateSelectInput(session = session, inputId = "feature", choices = cols)
  })


  
  output$rf <- renderPrint(
    if(is.null(x = df())) {
      return()
    } else {
      rf_data <- df()[c(input$features, "activity")]
      result <- RF(as.factor(activity)~., data = rf_data)
      summary(result)
    }
  )
  
  output$J48 <- renderPrint(
    if(is.null(x = df())){
      return()
    } else {
      J48_data <- df()[c(input$features, "activity")]
      result <- J48(as.factor(activity)~., data = J48_data)
      summary(result)
    }
  )
  
  output$table <- renderTable({
    if(is.null(x = df())) return() else df()[input$feature] %>% head() # df()의 처음 5행만 테이블로 출력
  })
  
  output$glimpse <- renderPrint({
    if(is.null(x = df())) return() else glimpse(x = df()[input$feature]) # df()의 컬럼별 속성과 미리보기를 출력
  })
  
  output$mainUI <- renderUI({
    if(is.null(x = df()))h4("아직 표시할 내용이 없습니다.")
    else tabsetPanel(
      tabPanel(title = 'Data',
               tableOutput(outputId = 'table'),
               verbatimTextOutput(outputId = 'glimpse')),
      if(input$model=="RF") {
        tabPanel(title = "RF",
                 verbatimTextOutput(outputId = "rf"))
      }else if(input$model == "J48") {
        tabPanel(title = "J48",
                 verbatimTextOutput(outputId = "J48"))
      })  # tabsetPanel() 함수 닫음
  }) # renderUI() 함수 닫음
  
} # function 함수 닫음

shinyApp(ui = ui, server = server)
