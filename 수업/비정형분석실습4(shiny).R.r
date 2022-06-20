library(shiny)
library(stringr)

ui <- fluidPage(
  h3('문자열 업데이트 실습'), # 문자열 업데이트 함수 <h3> 태그를 이용해 제목처럼 문자열 크게 입력
  textInput(inputId = 'bllod', label = '혈액형을 입력하세요.', value = 'A'), # 혈액형을 문자열로 입력받아 input$blood에 할당
  textInput(inputId = 'detail', label = 'A형의 매력은?'), # 처음 App 화면에 출력할 라벨 설정 입력되는 혈액형 문자열에 따라 변경됨
  h3('범위 업데이트 실습'), # 숫자 업데이트 함수
  numericInput(inputId = 'min', label = '최소값 설정', value = 0),
  numericInput(inputId = 'max', label = '최대값 설정', value = 10),
  sliderInput(inputId = 'range', label = '', min = 0, max = 10, value = 5),
  h3('슬라이드 업데이트 실습'), # 숫자 업데이트 함수와 비슷하지만 지정할 수 있는 인자가 다름
  numericInput(inputId = 'income', label = '월소득(만원)', value = 300),
  sliderInput(inputId = 'save', label = '희망 월적립금(만원)',
              value = 50, min = 0, max = 150),
  h3('선택 업데이트 실습'),
  textInput(inputId = 'example', label = '보기를 입력하세요.',
            placeholder = '[보기1, 보기2]와 같이 콤마를 추가하세요.'),
  selectInput(inputId = 'inSelect', label = '', choices = NULL),
)


server <- function(input, output, session) {
  observe({
    updateTextInput(session = session, inputId = 'detail',
                    label = str_c(input$blood, '형의 매력은?'))
  })
  observe({
    updateNumericInput(session = session, inputId = 'range',
                       min = input$min, max = input$max) # input$min과 input$max로 sliderInput() 함수의 최소값 및 최대값 업데이트
  })
  observe({
    x <- input$income # input$income을 여러번 사용하므로, 'x'로 할당해놓음 
    updateNumericInput(session = session, inputId = 'save',
                       value = x * 0.5, min = x * 0.2, max = x *0.8)
  })
  observe({
    x <- str_split(string = input$example, pattern = ',') %>% unlist()
    updateSelectInput(session = session, inputId = 'inSelect', choices = x,
                      label = '다음 보기 중 하나만 고르세요.')
  })
}

shinyApp(ui = ui, server = server)
