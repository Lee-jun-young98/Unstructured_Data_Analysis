library(keras)
# install_keras()
library(reticulate)
library(tensorflow)
library(keras)


mnist <- dataset_mnist()
reticulate::py_config()


sys <- import("sys", convert = TRUE)
sys$path

# 학습 데이터
train_images <- mnist$train$x
train_labels <- mnist$train$y

# 시험 데이터
test_images <- mnist$test$x
test_labels <- mnist$test$y

str(train_images)

# train_lables는 10개 class에 대한 label이 들어 있음, 숫자 0~9까지
str(train_labels)

# test_images는 1만 개의 28*28 픽셀의 데이터로 array로 저장되어 있음
str(test_images)

# test_labels는 10개 class에 대한 label
str(test_labels)

# (60000,28,28)인 데이터를 (60000, 28*28)로 재구성(reshape)하고 모든 값이 [0,1]구간이 되도록 전처리

train_images <- array_reshape(train_images, c(60000, 28 * 28))
# 이전 훈련 이미지가 [0, 255]구간의 값이 데이터여서 전체 데이터를 255로 나누어 0과 1사이의 값으로 변환
train_images <- train_images/255

test_images <- array_reshape(test_images, c(10000, 28*28))
test_images <- test_images/255

digit <- train_images[5,]

plot(as.raster(digit, max = 255))


################################## Output 준비하기 #################################
# 결과(class)값 변환
# train_label, test_label은 class 값을 가지는데, 다른 기계학습과는 달리 neural network에서의 output은
# class 값만큼의 output node를 생성하고,
# 각 노드의 값에 0, 1의 값을 넣어서 category 값으로 만듦
# to_categorical() 함수를 통해 one-hot encoding을 수행

# 레이블 준비하기
train_labels <- to_categorical(train_labels)
test_labels <- to_categorical(test_labels)
head(train_labels)
head(test_labels)


################################# 모델 구성 ################################
# 1. 신경망은 keras_model_sequential()로 모델의 초기 뼈대를 만들고
# 2. layer_dense()를 이용해 hidden layer(입력값을 추상화하느 계층) 구성
# 3. output은 10개의 노드로 구성
#  신경망 아키텍쳐
network <- keras_model_sequential() %>% 
  layer_dense(units = 512, activation = 'relu', input_shape = c(28*28)) %>% 
  layer_dense(units = 10, activation = 'softmax')



################################ 모델 컴파일 ################################
# 구성한 모델을 학습시키기 위한 조건 설정
# compile() 함수를 통해 loss function(손실 함수: 정답과 알고리즘의 결과값의 차이를 정의), optimizer(최적화 방법),
# metrics(평가 기준)을 설정
# categorical_crossentropy : category 변수를 output으로 가질 때 쓰는 손실 함수
# 컴파일
network %>% compile(
  optimizer = 'rmsprop',
  loss = 'categorical_crossentropy',
  metrics = c("accuracy")
)


################################# 최적화 알고리즘#################################
# 초기 weight는 임의의 값으로 설정되므로 이를 최적화 해야함
# learning rate : 얼마나 빠르게 경사를 내려갈 것인가를 결정
# momentum : 경사를 타고 내려가는데, 빨간색 방향으로도 이동하도록 모멘텀 설정
# moentum(관성)을 이용하면 현재 기울기를 통해 이동하는 방향과 별개로
# 과거에 이동했던 방식을 기억하면서 그 방향으로 일정 정도를 추가적으로 이동하는 방식

################################# 데이터 입력 및 학습 #################################
# fit() 함수를 통해 학습 및 평가
# epochs 몇 단계까지 학습을 할건지
# batch_size : 한 번에 몇개의 데이터를 이용해서 weight를 최적화시킬(학습)건지

# rpytools 모듈 실행
history <- network %>% fit(train_images, train_labels, epochs = 5, batch_size = 128)
plot(history)

# 학습 결과 평가
metrics <- network %>% evaluate(test_images, test_labels)
metrics


# 케라스 모델에 맞게 이미지 데이터 준비하기
# (60000, 28, 28)인 데이터를 (60000, 28, 28, 1)로 재구성(reshape)하고 모든 값이 [0, 1]구간이 되도록 전처리
library(keras)
py_module_available('keras')
py_module_available('tensorflow')
reticulate::py_discover_config("tensorflow")
# 하이퍼 파라미터 설정
batch_size <- 128
num_classes <- 10
epochs <- 12

# input 크기 설정
img_rows <- 28
img_cols <- 28

# 훈련, 검증 데이터 분리
mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

# 이미지 모델에 맞게 데이터 설정
x_train <- array_reshape(x_train, c(nrow(x_train), img_rows, img_cols, 1))
x_test <- array_reshape(x_test, c(nrow(x_test), img_rows, img_cols, 1))
input_shape <- c(img_rows, img_cols, 1)

# Class 값을 one-hot encoidng으로 만들기
y_train <- to_categorical(y_train, num_classes)
y_test <- to_categorical(y_test, num_classes)

# 합성망 구축
model <- keras_model_sequential() %>% 
  layer_conv_2d(filters = 32, kernel_size = c(3,3), activation = 'relu',
                input_shape = input_shape) %>% 
  layer_conv_2d(filters = 64, kernel_size = c(3,3), activation = 'relu') %>% 
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  layer_dropout(rate = 0.25) %>% 
  layer_flatten() %>% 
  layer_dense(units = 128, activation = 'relu') %>% 
  layer_dropout(rate = 0.5) %>% 
  layer_dense(units = num_classes, activation = 'softmax')

# 모델 컴파일
# 다중 분류에서는 categorical crossentropy loss를 사용함
# weight 최적화 기법은 rmsprop를 사용

model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = 'rmsprop',
  metrics = c("accuracy")
)


# 데이터로 학습
# 하이퍼파라미터를 튜닝하기 위해 validation set 사용
# 언제 학습을 멈출지를 정함
model %>% fit(x_train, y_train, batch_size = batch_size,
              epochs = epochs, validation_split = 0.2)



