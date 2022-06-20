setwd("C:/R_data/motion-sense-master/motion-sense-master/data/A_DeviceMotion_data/A_DeviceMotion_data")
library(stringr)
library(tidyverse)
d <- getwd()
print(d)

fls <- dir(d, recursive = TRUE)
fls

for (f in fls) { # 파일 이름 읽어와서 끝까지 반복
  a <- file.path(str_c(d, "/", f)) # 폴더명과 경로명을 붙혀 경로를 만듦
  temp <- read.csv(a) # 폴더가 나타나면 폴더 안으로 들어가 파일 읽어오기
  assign(f, temp)
}

str_detect(fls,"sub_1.csv")

user1 <- fls[str_detect(fls, ("sub_1.csv"))]
user1
user_walking <- user1[str_detect(user1, "wlk_.")]
user_walking


# 샘플 데이터 추출
user1_walking_total <- data.frame()

# user1의 walking 데이터를 하나씩 읽어와서 데이터 프레임에 넣기
# regmatches(f, 패턴의 위치) : 패턴의 위치의 문자를 반환, 즉 찾는 패턴을 반환
# gregexpr(패턴, 문자열) : 문자열에서 패턴이 있는 위치를 반환 :digit:는 정수형 요소 찾기
for(f in user_walking) {
  temp <- get(f) # user1의 walking데이터를 차례대로 받음
  # 문자열이 가르키는 데이터를 뽑아옴
  user1_walking_total <- rbind(user1_walking_total,
                               temp %>% mutate(exp_no = unlist(regmatches(f, gregexpr("[[:digit:]]+", f)[1]))[1], # exp_no는 행동 번호 15, 7, 8
                                               id = unlist(regmatches(f, gregexpr("[[:digit:]]+", f)[1]))[2])) # id는 사용자 id
}

# sqrt(.x^2 + .y^2 + .z^2) 식 구하기
mag <- function(df, column){
  df[,str_c("mag", column)] <-
    with(df, sqrt(get(str_c(column, ".x"))^2 + get(str_c(column, ".y"))^2 + get(str_c(column, '.z'))^2))
  return(df)
}

user1_walking_total <- mag(user1_walking_total, "userAcceleration")
user1_walking_total

library(ggplot2)

user1_walking_total

# 시간값 생성
user1_walking_total <-
  user1_walking_total %>% group_by(exp_no) %>% mutate(time=row_number()) %>% ungroup()

ggplot(user1_walking_total, aes(x=time, y=maguserAcceleration)) + geom_line() +
  facet_wrap(.~exp_no, nrow=3)


# 전체데이터 넣기
HAR_total <- data.frame()
fls
length(fls)

for (f in fls){
  temp <- get(f)
  print(f)
  HAR_total <- rbind(HAR_total, temp %>% mutate(exp_no=unlist(regmatches(f, gregexpr("[[:digit:]]+", f)[1]))[1],
                                                id=unlist(regmatches(f, gregexpr("[[:digit:]]+", f)[1]))[2],
                                                activity=unlist(str_split(f,"\\_"))[1]))
}

head(HAR_total, n=100)

# 가속도, 회전에 대해 magnitude 변수 만들기
HAR_total <- mag(HAR_total, "userAcceleration")
HAR_total <- mag(HAR_total, "rotationRate")
HAR_total


# skewness 함수 만들기
skewness <- function(x){
  (sum((x-mean(x))^3)/length(x))/((sum((x-mean(x))^2)/length(x)))^(3/2)
}

HAR_summary <- HAR_total %>% group_by(id, exp_no, activity) %>% 
  summarize_at(.vars=c("maguserAcceleration", "magrotationRate"),.funs = c(mean,
                                                                           min, max, sd, skewness))
HAR_summary


############################### user1의 jog일 때 데이터 시각화 ##########################
user1_jogging_total <- data.frame()

user_jogging <- user1[str_detect(user1, "jog_.")]
user_jogging


for(f in user_jogging) {
  temp <- get(f) # user1의 walking데이터를 차례대로 받음
  # 문자열이 가르키는 데이터를 뽑아옴
  user1_jogging_total <- rbind(user1_jogging_total,
                               temp %>% mutate(exp_no = unlist(regmatches(f, gregexpr("[[:digit:]]+", f)[1]))[1], # exp_no는 행동 번호 15, 7, 8
                                               id = unlist(regmatches(f, gregexpr("[[:digit:]]+", f)[1]))[2])) # id는 사용자 id
}
user1_jogging_total

user1_jogging_total <- mag(user1_jogging_total, "userAcceleration")
user1_jogging_total

# 시간값 생성
user1_jogging_total <-
  user1_jogging_total %>% group_by(exp_no) %>% mutate(time=row_number()) %>% ungroup()

ggplot(user1_jogging_total, aes(x=time, y=maguserAcceleration)) + geom_line() +
  facet_wrap(.~exp_no, nrow=3)


############################################ RWeka ########################################################
library(RWeka)
library(randomForest)

# 알고리즘 구축
# m <- J48(class~., data=df이름) 트리기반 알고리즘
# m <- RF(class~., data=df이름)

RF <- make_Weka_classifier("weka/classifiers/trees/RandomForest")
Bayes_net <- make_Weka_classifier("weka/classifiers/bayes/BayesNet")
RF
Bayes_net

# Weka에서 사용할 때에는 클래스 변수를 팩터형으로 넣어야함
HAR_summary$activity <- as.factor(HAR_summary$activity)



str_detect(colnames(HAR_summary), "mag")

activity <- HAR_summary %>% ungroup() %>% select(c(colnames(HAR_summary)[str_detect(colnames(HAR_summary), "mag")], "activity"))
activity


m <- J48(activity~., data=activity)
m

# 교차검증 
# Kappa 통계량 : 우연히 맞출 확률을 배제함 
e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)
e

# 랜덤포레스트
rf_activity <- randomForest(activity~., data=activity)
rf_activity



library(pracma)
library(signal)
library(seewave)
library(e1071)

rss <- function(x) {
  rms(x) * (length(x))^0.5
}

HAR_summary_extends <- HAR_total %>% group_by(id, exp_no,
                                              activity) %>% summarize_at(.vars = c("maguserAcceleration", "magrotationRate"),
                                                                         .funs=c(mean, min, max, sd, skewness, rms, rss, IQR, e1071::kurtosis))
HAR_summary_extends

sapply(HAR_summary_extends, class)

HAR_summary_extends2 <- HAR_summary_extends %>% ungroup() %>% select(-c("id","exp_no"))
HAR_summary_extends2


# 트리 알고리즘
m <- J48(as.factor(activity)~., data=HAR_summary_extends2)

e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)

e

# 주성분 분석
mtcars.pca <- prcomp(HAR_summary_extends2 %>% ungroup() %>% select(-activity), center = TRUE, scale. = TRUE)
mtcars.pca


m <- J48(as.factor(activity)~., data=HAR_summary_extends2 %>% select(1,2,11,12,15,16))
e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE)
e


############################### 원본데이터에 센서의 크기 변수 추가##########################
for (d in fls){
  f <- get(d)
  f <- mag(f, "rotationRate")
  f <- mag(f, "userAcceleration")
  assign(d, f)
  
}

library(pracma)
Peak_rslt <- data.frame()

for (d in fls) {
  f <- get(d)
  p <- findpeaks(f$magrotationRate, threshold = 4) # 4 이상의 값을 피크로 도출
  Peak_rslt <- rbind(Peak_rslt, data.frame(d, f_n = ifelse(!is.null(p), dim(p)[1], 0), # 피크 추출 결과 p가 null이 아니면 행의 개수 추출
                                           p_interval = ifelse(!is.null(p), ifelse(dim(p)[1]>1, mean(diff(sort(p[,2]))), 0), 0), # 행의 개수가 두개 이상이면, diff 함수를 써서 행의 차이를 구함, 피크 간격 차이를 구하고 평균을 구함
                                           p_interval_std = ifelse(!is.null(p), ifelse(dim(p)[1]>2, std(diff(p[,2])),0),0),# 피크 간격의 표준편차를 구함
                                           p_mean = ifelse(!is.null(p), mean(p[,1]),0), # 피크 평균 구하기
                                           p_max = ifelse(!is.null(p), max(p[,1]),0), # 피크 max값 구하기
                                           p_min = ifelse(!is.null(p), min(p[,1]),0), # 피크 min값 구하기
                                           p_std = ifelse(!is.null(p), ifelse(!is.nan(std(p[,1])), std(p[,1]),0), 0)))} # 피크 표준편차 구하기



Peak_rslt

temp <- get(fls[1])
plot(temp$magrotationRate)

# 선형 그래프로 그리기
plot(1:length(temp$magrotationRate), temp$magrotationRate, "l")


# 크기가 5이상인 피크 도출
p_temp <- findpeaks(temp$magrotationRate, threshold = 5)

points(p_temp[,2], p_temp[,1])

######################## 파고율 #####################################
# 피크가 얼마나 극단적인지를 나타내는 척도(값이 1인 경우 : 피크가 없다, 값이 큰 경우 : 피크가 극단적임)
# crest(값, 50hz, plot)
# 미세한 변화를 찾을려면 hz를 높게 측정 최소 100, 200
seewave::crest(temp$magrotationRate,50,plot=TRUE)
# $C : 파고율, $ val : peak 발생 위치의 y값, $ loc : peak 발생 위치

temp <- data.frame()

for (d in fls) {
  f <- get(d)
  f <- f %>% select(magrotationRate, maguserAcceleration)
  cfR <- crest(f$magrotationRate, 50, plot=TRUE)
  cfA <- crest(f$maguserAcceleration, 50, plot=TRUE)
  temp <- rbind(temp, data.frame(d, cfR = cfR$C, cfA = cfA$C))
}

Peak_final <- merge(Peak_rslt, temp, by="d")


id_f <- function(x) {
  exp_no = unlist(regmatches(x, gregexpr("[[:digit:]]+", x)[1]))[1]
  id = unlist(regmatches(x, gregexpr("[[:digit:]]+", x)[1]))[2]
  activity = unlist(str_split(x, "\\_"))[1]
  return(cbind(exp_no, id, activity))
  
}


temp <- data.frame()
for(i in 1:nrow(Peak_final)){
  temp <- rbind(temp, id_f(Peak_final$d[i]))
}

Peak_final2 <- cbind(Peak_final, temp)
Peak_final2

activity_Peak <- Peak_final2 %>% ungroup() %>% select(-d, -exp_no, -id)


m <- randomForest(as.factor(activity)~., data=activity_Peak)
summary(m)

e <- evaluate_Weka_classifier(m, numFolds=10, complexity = TRUE, class = TRUE)

e

m <- J48(as.factor(activity)~., data=HAR_summary_extends2 %>% select(1,2,11,12,15,16))

# 변화 분석
library(changepoint)
ch_pt <- data.frame()

for (d in fls) {
  f <- get(d)
  f <- mag(f, "rotationRate")
  f <- mag(f, "userAcceleration")
  rslt <- sapply(f %>% select(magrotationRate, maguserAcceleration), cpt.mean) # 변화 평균
  rslt_cpts1 <- cpts(rslt$magrotationRate)
  rslt_cpts2 <- cpts(rslt$maguserAcceleration)
  rslt2 <- sapply(f %>% select(magrotationRate, maguserAcceleration), cpt.var) # 변화 분산
  rslt2_cpts1 <- cpts(rslt2$magrotationRate)
  rslt2_cpts2 <- cpts(rslt2$maguserAcceleration)
  rslt3 <- sapply(f %>% select(magrotationRate, maguserAcceleration), cpt.meanvar) # 변화 분산 평균
  rslt3_cpts1 <- cpts(rslt3$magrotationRate)
  rslt3_cpts2 <- cpts(rslt3$maguserAcceleration)
  
  ch_pt <- rbind(ch_pt, data.frame(d, cp1=length(rslt_cpts1), cp2 = length(rslt_cpts2), cp3=length(rslt2_cpts1), cp4=length(rslt2_cpts2), cp5=length(rslt3_cpts1), cp6=length(rslt3_cpts2)))
}

temp <- data.frame()
for (i in 1:nrow(ch_pt)){
  temp <- rbind(temp, id_f(ch_pt$d[i]))
}



head(ch_pt)
ch_pt <- cbind(ch_pt, temp)
ch_pt


# 원본 데이터에 두 변수의 magnitude를 구해서 변수 추가
for  (d in fls){
  f <- get(d)
  f <- mag(f, "rotationRate")
  f <- mag(f, "userAcceleration")
  assign(d, f)
}


# 파일명에서 activity, id 등의 정보 추출하기
# temp에 exp_no, id, activity를 넣음
ch_pt2 <- ch_pt %>% ungroup() %>% select(-d, -exp_no, -id)

m <- RF(as.factor(activity)~., data=ch_pt2)
table(activity_Peak$activity)
e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)
e


# 변화 특징을 이용하여 분류모델 구축

# 필요없는 변수 제거Peak_final3 <- merge(Peak_final2, ch_pt, by = c("d", "exp_no", "id", "activity"))

combined <- peak_final3 %>% select(-d, -exp_no, -id)
colnames(combined)

m <- RF(as.factor(activity)~., data=combined)

e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)
e



# 모든 데이터 사용
peak_final4 <- merge(Peak_final3, HAR_summary_extends, by = c("id", "exp_no", "activity"))
combined2 <- peak_final4 %>% select(-d, -exp_no, -id)

m <- RF(as.factor(activity)~., data=combined2)

e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)
e
