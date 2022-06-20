library(dplyr)
library(ggplot2)
library(reticulate)
# https://stackoverflow.com/questions/45861045/importing-python-module-in-r
# path_to_python <- "C:\\ProgramData\\Anaconda3"
# use_python(path_to_python)
setwd("C://R_data")
data <- read.csv('jena_climate_2009_2016.csv')
data

glimpse(data)

# 시간에 따른 연간 해수면 기온
ggplot(data, aes(x = 1:nrow(data), y = `T..degC.`)) + geom_line()

ggplot(data[1:1440,], aes(x = 1:1440, y = `T..degC.`)) + geom_line()


# 데이터 정규화

# 날짜 제외
data <- as.matrix(data[,-1])

# 훈련데이터셋으로 데이터 정규화

# 훈련 데이터만으로 정규화하는 것에 유의, 테스트 데이터는 미리 주어지지 않기 때문에 
# 정규화 시에 사용될 평균과 편차에는 반영되면 안됨, 하지만 테스트 데이터도 정규화한 후에 테스트

train_data <- data[1:200000,]

mean <- apply(train_data, 2, mean)
std <- apply(train_data, 2, sd)
data <- scale(data, center = mean, scale = std)

# batch마다 데이터 생성하는 함수
generator <- function(data, lookback, delay, min_index, max_index,
                      shuffle = FALSE, batch_size = 128, step = 6) {
  if (is.null(max_index)) # max_index의 값이 없는 경우에는
    max_index <- nrow(data) - delay - 1 # 전체 데이터 수 - delay(몇분 뒤 예측할 것인지)
  i <- min_index + lookback # 학습 시작 지점에서 lookback만큼 그 다음시점을 만들어 놓음
  
  function() {
    if (shuffle) {
      rows <- sample(c((min_index + lookback):max_index), size = batch_size)
    } else {
      if (i + batch_size >= max_index)
        i <- min_index + lookback
      rows <- c(i:min(i + batch_size - 1, max_index))
      i <- i + length(rows)
    }
    
    samples <- array(0, dim = c(length(rows),
                                lookback / step,
                                dim(data)[[-1]]))
    targets <- array(0, dim = c(length(rows)))
    
    for (j in 1:length(rows)){
      indices <- seq(rows[[j]] - lookback, rows[[j]] - 1, # 시작 시점부터 다음 시작시점 직전 까지
                     length.out = dim(samples)[[2]]) # lookback만큼의 데이터를 생성
      samples[j,,] <- data[indices,]
      targets[[j]] <- data[rows[[j]] - 1 + delay, 2] # delay만큼 뒤의 값을 읽어옴
    }
    list(samples, targets)
  }
}

lookback <- 1440 # 1440 포인트를 한 세트의 학습데이터로 사용
step <- 1 # 1 포인트마다 데이터 읽어오기
delay <- 144 # 144 포인트 뒤의 값을 예측
batch_size <- 128 # 한번에 128개 세트씩 학습하는데 사용

# train -> 1:200000
train_gen <- generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 1,
  max_index = 200000,
  shuffle = TRUE,
  step = step,
  batch_size = batch_size
)

# validation -> 200001:300000
val_gen <- generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 200001,
  max_index = 300000,
  step = step,
  batch_size = batch_size
)

# test -> 300001:
test_gen <- generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 300001,
  max_index = NULL,
  step = step,
  batch_size = batch_size
)

# 검증/테스트 횟수 설정
val_steps <- (300000 - 200001 - lookback) / (batch_size)
test_steps <- (nrow(data) - 300001 - lookback) / (batch_size)

# DNN
model <- keras_model_sequential() %>% 
  layer_flatten(input_shape = c(lookback / step, dim(data)[-1])) %>% 
  layer_dense(units = 32, activation = "relu") %>% 
  layer_dense(units = 1)

# 모델 컴파일
# 파라미터 최적화 알고리즘 설정
# loss : 정답과 알고리즘이 푼 답의 차이 MAE

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

# 배치별로 데이터를 만들어 나가면서 학습시킴
history <- model %>% fit_generator(
  train_gen,
  steps_per_epoch = 500, # 한 번의 epoch에 500번 반복하면서 최적값을 찾음
  epochs = 20,
  validation_data = val_gen,
  validation_steps = val_steps
)


plot(history)