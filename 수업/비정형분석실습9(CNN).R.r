library(keras)
library(reticulate)
library(tensorflow)
library(keras)
############################### 개와 고양이 분류 #########################################
original_dataset_dir <- "C:\\R_data\\dogs-vs-cats\\train"
base_dir <- "catdogclassficiation"

dir.create(base_dir)
train_dir <- file.path(base_dir, "train")
dir.create(train_dir)

validation_dir <- file.path(base_dir, "validation")
dir.create(validation_dir)

test_dir <- file.path(base_dir, "test")
dir.create(test_dir)


# 데이터 저장 폴더 생성
# 다시 개와 고양이 폴더를 만들어서 넣어두고 각 폴더에서 데이터를 읽어옴

train_cats_dir <- file.path(train_dir, "cats")
dir.create(train_cats_dir)

train_dogs_dir <- file.path(train_dir, "dogs")
dir.create(train_dogs_dir)

validation_cats_dir <- file.path(validation_dir, "cats")
dir.create(validation_cats_dir)

validation_dogs_dir <- file.path(validation_dir, "dogs")
dir.create(validation_dogs_dir)

test_cats_dir <- file.path(test_dir, "cats")
dir.create(test_cats_dir)

test_dogs_dir <- file.path(test_dir, "dogs")
dir.create(test_dogs_dir)

# 디렉터리에 이미지 복사

# train 고양이 1000
fnames <- paste0("cat.", 1:1000, ".jpg")

file.copy(file.path(original_dataset_dir, fnames),
          file.path(train_cats_dir))

# validation 고양이 500
fnames <- paste0("cat.", 1001:1500, ".jpg")
file.copy(file.path(original_dataset_dir, fnames),
          file.path(validation_cats_dir))

fnames <- paste0("cat.", 1501:2000, ".jpg")
file.copy(file.path(original_dataset_dir, fnames),
          file.path(test_cats_dir))


# 모델 구축

model <- keras_model_sequential() %>% 
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = 'relu',
                input_shape = c(150, 150, 3)) %>% 
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  layer_conv_2d(filters = 64, kernel_size = c(3,3), activation = "relu") %>% 
  layer_max_pooling_2d(pool_size = c(2, 2)) %>% 
  layer_conv_2d(filters = 128, kernel_size = c(3,3), activation = "relu") %>% 
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  layer_conv_2d(filters = 128, kernel_size = c(3,3), activation = "relu") %>% 
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  layer_flatten() %>% 
  layer_dense(units = 512, activation = "relu") %>% 
  layer_dense(units = 1, activation = "sigmoid")


model %>% compile(
  loss = "binary_crossentropy", # binary classification 
  optimizer = optimizer_rmsprop(learning_rate = 1e-4),
  metrics = c("acc")
)  


# 데이터 전처리
# keras에서는 image_data_generator() 함수를 사용하여 디스크의 이미지 파일을 전처리된 텐서 배치들로 자동 변환
# (0, 255) 사이의 값을 [0, 1]로 값 조정
train_datagen <- image_data_generator(rescale = 1/255)
validation_datagen <- image_data_generator(rescale = 1/255)

# flow_images_from_directory() 함수를 사용하여 해당 경로의 타켓사이즈, 배치 사이즈 등을 조절

train_generator <- flow_images_from_directory(
  train_dir , train_datagen,
  target_size = c(150, 150), # 이미지 사이즈 (150, 150)
  batch_size = 20, # 각 배치마다 20개의 표본
  class_mode = "binary"
)

validation_generator <- flow_images_from_directory(
  validation_dir , validation_datagen,
  target_size = c(150, 150), # 이미지 사이즈 (150, 150)
  batch_size = 20, # 각 배치마다 20개의 표본
  class_mode = "binary"
)

# 배치 생성
# 한번에 학습 모델에 투입될 데이터의 양을 정하고 batch 크기 만큼의 학습 데이터를 생성

batch <- generator_next(train_generator)
str(batch)

history <- model %>% fit_generator(
  train_generator,
  steps_per_epoch = 100,
  epochs = 10,
  validation_data = validation_generator,
  validation_steps = 50
)


# 이미지 보강을 사용하여 정확도 높이기
datagen <- image_data_generator(
  rescale = 1/255,
  rotation_range = 40, # 각도 단위 값(0~180), 그림을 임의로 회전
  width_shift_range = 0.2,
  height_shift_range = 0.2, # 그림을 가로 또는 세로로 임의 변환하는 범위(전체 범위 또는 높이의 일부)
  shear_range = 0.2, # 임의로 가위질 변환을 적용
  zoom_range = 0.2, # 그림을 무작위로 확대
  horizontal_flip = TRUE, # 수평 비대칭을 가정하고 있지 않은 경우(ex 실물 사진) 관련 이미지의 절반을 무작위로 반전
  fill_mode = "nearest" # 새로 생성된 픽셀을 채우는데 사용되며 회전, 너비/높이 이동 후에 나타날 수 있음
)

# train_cat 이미지 경로
train_cats_dir <- "C:/Users/student/Documents/catdogclassficiation/train/cats"

fnames <- list.files(train_cats_dir, full.names = TRUE)
img_path <- fnames[[4]] # 보강할 이미지 선택

# 이미지를 읽어 크기를 조정
img <- image_load(img_path, target_size = c(150, 150))

# img를 (150, 150, 3)인 배열로 바꿈
img_array <- image_to_array(img)

# 배열을 (1, 150, 150, 3) 모양으로 바꿈, 이미지 변환할 때 여러 이미지를 배열 형태로 넣게 되어있는데 
# 이 부분을 지금은 1개의 이미지를 넣을 것이지만 그래도 배열 형태로 변경
img_array <- array_reshape(img_array, c(1, 150, 150, 3))


# 변경된 이미지 보기
augmentation_generator <- flow_images_from_data(
  img_gray,
  generator = datagen,
  batch_size = 1
)


# 그림 그릴 영역 분할
op <- par(mfrow = c(2, 2), pty = "s", mar = c(1, 0, 1, 0))

# 이미지 보강을 4번 수행
for (i in 1:4) {
  batch <- generator_next(augmentation_generator)
  plot(as.raster(batch[1,,,]))
}

