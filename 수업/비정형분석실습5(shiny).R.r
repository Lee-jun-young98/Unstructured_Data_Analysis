library(shiny)
library(ggplot2)

ui <- fluidPage(
  sidebarPanel(
    textInput(inputId = 'name',
              label = '이름을 입력하세요.',
              value = '홍길동'),
    numericInput(inputId = 'ht',
                 label = h4('키(cm)를 입력하세요.'),
                 value = 172.4,
                 min = 50,
                 max = 250),
    sliderInput(inputId = 'age',
                label = '나이를 입력하세요',
                value = 25,
                min = 1,
                max = 120,
                step = 1),
    sliderInput(inputId = 'sample',
                label = '샘플 크기를 입력하세요.',
                value = 1000,
                min = 100,
                max = 5000,
                step = 100),
    varSelectInput(inputId = 'vars',
                   label = '컬럼을 선택하세요.',
                   data = iris, # 데이터 프레임 지정
                   selected = 'Sepal.Length', # 'multiple'인자에 TRUE을 할당하면 여러 개의 컬럼병 벡터 지정
                   multiple = TRUE)
  ),
  mainPanel(
    tableOutput(outputId = "profile"),
    uiOutput(outputId = "mainUI"),

  )

)

server <- function(input, output, session) {
  output$profile <- renderTable({
    data.frame(name = input$name, height = input$ht, age = input$age)
  })
  
  output$histogram <- renderPlot({
    heights <- rnorm(n = input$ht, mean = 172.4, sd = 5.7)
    hist(x = heights, breaks = 20, col = 'gray50', border = 'gray30')
  })
  
  output$boxplot <- renderPlot({
    ggplot(data = iris, mapping = aes(y = !!input$vars[[1]])) +
      geom_boxplot() + theme_bw()
  })
  
  output$mainUI <- renderUI({
    if(input$name == '홍길동'){ # App 화면에서 이름이 여전히 '홍길동'이면, 'profile''과 함께 안내 문구 추가
      tagList(
        h5('[안내] 입력하시는 내용으로 변경됩니다.'),
        tabPanel(title = 'profile', tableOutput(outputId = 'profile'))
      )
    } else { # 만약 이름을 다른 문자열로 변경하는 경우, 기존 mainPanel() 함수 부분 출력
      tabsetPanel(
        type = 'tabs',
        tabPanel(title = 'profile', tableOutput(outputId = 'profile')),
        tabPanel(title = 'plot1', plotOutput(outputId = 'histogram')),
        tabPanel(title = 'plot2', plotOutput(outputId = 'boxplot'))
      )
    }
  })


}

shinyApp(ui = ui, server = server)
