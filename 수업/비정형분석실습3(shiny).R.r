library(shiny)

# 'name'은 입력 'id'이며, 'input$name'으로 'server' 객체에 전달 됨
# 알파벳 대소문자, 숫자 및 언더바만 가능
# label App 화면에 출력되는 문자열
# value : 기본값을 설정할 수 있음

ui <- fluidPage(
  sidebarPanel(
    textInput(inputId = 'name',
              label = '이름을 입력하세요.',
              value = '홍길동')
  )
)

server <- function(input, output, session) {
  
}

shinyApp(ui = ui, server = server)

# 비밀번호 입력 함수 
# passwordInput()
# value에 힌트를 줄 수 도 있음
# 문자열은 점처리 됨 
ui <- fluidPage(
  sidebarPanel(
    passwordInput(inputId = 'pw',
              label = '비밀번호를 입력하세요.',
              value = '타인에게 노출되지 않도록 주의하세요')
  )
)

# 문자열 여러 줄 입력 함수 
ui <- fluidPage(
  sidebarPanel(
    textAreaInput(inputId= 'intro',
                  label = h3('자기소개 부탁합니다.'), # HTML <h1> ~ <h6> 제목 태그 
                  value = '',
                  rows = 3, # 문자열 입력할 칸 크기 지정
                  placeholder = '간단하게 작성해주세요.')
  )
)

# 숫자 입력 함수
ui <- fluidPage(
  sidebarPanel(
    numericInput(inputId = 'ht',
                 label = h4('키(cm)를 입력하세요.'),
                 value = 172.4,
                 min = 50,
                 max = 250)
  )
)

# 슬라이드 입력 함수
sliderInput(inputId = 'age',
            label = '나이를 입력하세요',
            value = 25,
            min = 1,
            max = 120,
            step = 1)

# 제출 버튼 함수
submitButton(text = '변경사항을 적용합니다.',
             icon = icon(name = 'refresh'))

# 도움말 관련 함수
helpText("위 버튼을 누르면 변경사항을 업데이트 합니다")

# 날짜 입력 함수
dateInput(inputId = 'birth',
          label = '생일을 입력하세요.',
          value = '2000-01-01')  # 날짜를 지정할 때 연도 4자리 월 2자리 일 2자리
# 날짜 범위
dateRangeInput(inputId = 'period',
               label = '기간을 선택하세요.')

# 체크박스 그룹 입력
# choices <- c('R' = 'R', 'Python' = 'P', '통계' = 'S', '머신러닝' = 'M') 가능
checkboxGroupInput(inputId = 'item',
                   label = '관심사항을 모두 선택하세요.',
                   choices = c('R', 'Python', '통계', '머신러닝'),
                   selected = NULL, # App 화면의 보기 중 미리 체크할 항목을 지정 -> 기본 값이 NULL은 체크 x
                   inline = TRUE) # 보기를 한 줄로 난열 default 값은 FALSE -> 여러줄 

# 선택 입력 함수
selectInput(inputId = 'edu',
            label = '최종학력을 선택하세요.',
            choices = c('고졸 ' = 'H', '대졸' = 'U', '석사' = 'M', '박사' = 'P'),
            selected = 'U',
            multiple = FALSE)

# 컬럼 선택 함수
varSelectInput(inputId = 'vars',
               label = '컬럼을 선택하세요.',
               data = iris, # 데이터 프레임 지정
               selected = 'Sepal.Length', # 'multiple'인자에 TRUE을 할당하면 여러 개의 컬럼병 벡터 지정
               multiple = TRUE) # 'mulitple' 인자에 FALSE 또는 TRUE 중 할당된 값에 따라 server 함수 input$id 표기 방법 달라짐

# 라디오 버튼 입력 함수
radioButtons(inputId = 'major',
             label = '전공을 선택하세요',
             choices = c("통계학", "산업공학", "컴퓨터공학", '기타'),
             selected = NULL,
             inline = FALSE)

# 파일 입력 함수
# 파일 불러오기 용량은 5M
# 큰 파일 불러올려면 허용용량을 늘려야함
# options('shiny.maxRequestSize' = 30 * 1024^2)
fileInput(inputId = 'resume',
          label = '이력서를 첨부해주세요.',
          buttonLabel = '찾아보기',
          placeholder = '아직 파일이 선택되지 않았습니다!')

# 액션 버튼 함수
# App 화면에서 버튼을 클릭했을 때 'server'에서 준비된 작업 실행
# 처음에는 0이며 클릭 할 수록 숫자가 1, 2, 3으로 증가
# isolate()랑 같이 사용됨 
actionButton(inputId = 'do', label = '클릭하세요!')


ui <- fluidPage(
  sidebarPanel(
    textInput(inputId = 'name',
              label = '이름을 입력하세요.',
              value = '홍길동'),
    passwordInput(inputId = 'pw',
                  label = '비밀번호를 입력하세요.',
                  value = '타인에게 노출되지 않도록 주의하세요'),
    textAreaInput(inputId= 'intro',
                  label = h3('자기소개 부탁합니다.'), # HTML <h1> ~ <h6> 제목 태그 
                  value = '',
                  rows = 3, # 문자열 입력할 칸 크기 지정
                  placeholder = '간단하게 작성해주세요.'),
    numericInput(inputId = 'ht',
                 label = h4('키(cm)를 입력하세요.'),
                 value = 172.4,
                 min = 50,
                 max = 250),
    # 슬라이드 입력 함수
    sliderInput(inputId = 'age',
                label = '나이를 입력하세요',
                value = 25,
                min = 1,
                max = 120,
                step = 1),
    # 제출 버튼 함수
    submitButton(text = '변경사항을 적용합니다.',
                  icon = icon(name = 'refresh')),
    # 도움말 관련 함수
    helpText("위 버튼을 누르면 변경사항을 업데이트 합니다"),
    # 날짜 입력 함수
    dateInput(inputId = 'birth',
              label = '생일을 입력하세요.',
              value = '2000-01-01'),  # 날짜를 지정할 때 연도 4자리 월 2자리 일 2자리
    # 날짜 범위
    dateRangeInput(inputId = 'period',
                   label = '기간을 선택하세요.'),
    # 체크박스 그룹 입력
    # choices <- c('R' = 'R', 'Python' = 'P', '통계' = 'S', '머신러닝' = 'M') 가능
    checkboxGroupInput(inputId = 'item',
                       label = '관심사항을 모두 선택하세요.',
                       choices = c('R', 'Python', '통계', '머신러닝'),
                       selected = NULL, # App 화면의 보기 중 미리 체크할 항목을 지정 -> 기본 값이 NULL은 체크 x
                       inline = TRUE), # 보기를 한 줄로 난열 default 값은 FALSE -> 여러줄 
    # 선택 입력 함수
    selectInput(inputId = 'edu',
                label = '최종학력을 선택하세요.',
                choices = c('고졸 ' = 'H', '대졸' = 'U', '석사' = 'M', '박사' = 'P'),
                selected = 'U',
                multiple = FALSE),
    # 컬럼 선택 함수
    varSelectInput(inputId = 'vars',
                   label = '컬럼을 선택하세요.',
                   data = iris, # 데이터 프레임 지정
                   selected = 'Sepal.Length', # 'multiple'인자에 TRUE을 할당하면 여러 개의 컬럼병 벡터 지정
                   multiple = TRUE), # 'mulitple' 인자에 FALSE 또는 TRUE 중 할당된 값에 따라 server 함수 input$id 표기 방법 달라짐
    # 라디오 버튼 입력 함수
    radioButtons(inputId = 'major',
                 label = '전공을 선택하세요',
                 choices = c("통계학", "산업공학", "컴퓨터공학", '기타'),
                 selected = NULL,
                 inline = FALSE),
    # 파일 입력 함수
    # 파일 불러오기 용량은 5M
    # 큰 파일 불러올려면 허용용량을 늘려야함
    # options('shiny.maxRequestSize' = 30 * 1024^2)
    fileInput(inputId = 'resume',
              label = '이력서를 첨부해주세요.',
              buttonLabel = '찾아보기',
              placeholder = '아직 파일이 선택되지 않았습니다!'),
    # 액션 버튼 함수
    # App 화면에서 버튼을 클릭했을 때 'server'에서 준비된 작업 실행
    # 처음에는 0이며 클릭 할 수록 숫자가 1, 2, 3으로 증가
    # isolate()랑 같이 사용됨 
    actionButton(inputId = 'do', label = '클릭하세요!')
  )
)


shinyApp(ui = ui, server = server)


