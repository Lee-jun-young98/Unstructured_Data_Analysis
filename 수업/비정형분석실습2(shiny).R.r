library(shiny)

# selectInput() : 함수는 선택 입력을 받을 때 추가 주문서와 같은 역할
# inputId : 문자열은 'ID'로 'server' 객체에 전달
# label : 인자에 할당된 문자열은 App에 레이블로 출력
# choices : datasets 패키지에 속한 데이터프레임의 목록 지정
# verbatimTextoutput() 및 tableOutput() 함수 안 'outputId'인자는 'server'
# 함수의 실행 결과를 받아서 App 화면에 출력하는 기능

ui <- fluidPage(
  selectInput(inputId = 'dataset',
              label = '데이터셋', 
              choices = ls(name = 'package:datasets')),
  verbatimTextOutput(outputId = 'summary'),
  tableOutput(outputId = 'table')
)


# get 함수를 이용해 내용물을 반환
# renderPrint() 함수는 콘솔에 출력되는 내용을 App 화면에 출력하려고 할 때 사용
# 나중에 App 화면에서 데이터 프레임을 선택하면 'ui$dataset'에 해당 문자열이 저장 됨 -> 'server'가 전달 받아 dataset 생성
# 'server'는 'output$summary'를 'ui'로 전달
# 'ui'는 verbatimTextoutput() 함수는 콘솔 그대로 App 화면에 출력

# renderTable() 함수는 테이블로 App 화면에 출력할 때 사용
# reactive() 함수로 코드 중복을 회피함
# renderTable() 함수의 실행 결과를 'table'이라는 'outputId'에 할당하여 'ui'로 넘김
# 'ui'의 tableOutput()은 App
server <- function(input, output, session) {
  output$summary <- renderPrint({
    dataset <- get(x = input$dataset,
                   pos = 'package:datasets')
    summary(object = dataset)
  })
  output$table <- renderTable({
    dataset <- get(x = input$dataset,
                   pos = 'package:datasets')
    dataset
  })
}

shinyApp(ui = ui, server = server)

#################### side bar layout ##############################
ui <- fluidPage(
  titlePanel(title = '데이터셋 살펴보기'), # App 화면의 제목 설정
  sidebarPanel(  # sidebarLayout() 함수를 사용하지 않고 sidebarPanel() 및 mainPanel() 함수만 사용해도 됨 
    selectInput(
      inputId = 'dataset',
      label = '데이터셋',
      choices = ls(name = 'package:datasets'))
    
  ),
  mainPanel(
    verbatimTextOutput(outputId = 'summary'),
    tableOutput(outputId = 'table')
  )
)


