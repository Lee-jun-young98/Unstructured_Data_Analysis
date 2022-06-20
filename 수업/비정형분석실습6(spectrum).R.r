setwd("C:/R_data/motion-sense-master/motion-sense-master/data/A_DeviceMotion_data/A_DeviceMotion_data")
library(stringr)
library(tidyverse)
library(dplyr)
d <- getwd()
print(d)

fls <- dir(d, recursive = TRUE)
fls

mag <- function(df, column){
  df[,str_c("mag", column)] <-
    with(df, sqrt(get(str_c(column, ".x"))^2 + get(str_c(column, ".y"))^2 + get(str_c(column, '.z'))^2))
  return(df)
}

for (f in fls) { # 파일 이름 읽어와서 끝까지 반복
  a <- file.path(str_c(d, "/", f)) # 폴더명과 경로명을 붙혀 경로를 만듦
  temp <- read.csv(a) # 폴더가 나타나면 폴더 안으로 들어가 파일 읽어오기
  temp <- mag(temp, "rotationRate")
  temp <- mag(temp, "userAcceleration")
  assign(f, temp)
}

# 계단 내려가기
r.spec <- spectrum(`dws_1/sub_1.csv`$magrotationRate, plot = TRUE)

# 앉아있기
r.spec <- spectrum(`sit_13/sub_1.csv`$magrotationRate, plot = TRUE)


# 조깅
r.spec <- spectrum(`jog_16/sub_1.csv`$magrotationRate, plot = TRUE)

# 주파수 파워 계산
# log = "no" : spectrum이 log scale로 계산되어서 나옴, 로그 스케일은 작은 값에서의 차이를 증폭하는 효과가 있음  
# span = 10 : SPIKE가 너무 많이 생성됨, 정해놓은 구간에 10개 데이터를 smoothin 한 후에 spectrum 계산
r.spec <- spectrum(`dws_1/sub_1.csv`$magrotationRate, log = "no", span = 10, plot = TRUE)

# 주요 주파수 산출
# freq가 작은 순서대로 나옴
r.spec$freq


# 주파수별 강도
r.spec$spec

# spectrum 그려보기
frequency
fr <- r.spec$freq/50
sp <- r.spec$spec
plot(sp~fr, xlab = "frequency", ylab = "spectrum", type = "l")


# 조깅
r.spec <- spectrum(`sit_13/sub_1.csv`$magrotationRate, log = "no", span = 10, plot = TRUE)

# 앉아 있기
r.spec <- spectrum(`jog_16/sub_1.csv`$magrotationRate, log = "no", span = 10, plot = TRUE)

library(signal)
# high pass 필터 적용
bf <- butter(1, 0.05, type = "high") # 주파수가 0.05이상인 값만 통과시키기기
# 그냥 적용
spectrum(`jog_16/sub_10.csv`$maguserAcceleration, log = "no", span = 10, plot = TRUE)

# 필터 적용
spectrum(signal::filter(bf,`jog_16/sub_10.csv`$maguserAcceleration), log = "no", span = 10, plot = TRUE)

freq_rslt <- data.frame()

for (d in fls) {
  f <- get(d)
  r.spec <- spectrum(f$magrotationRate) # 이렇게 하면
  
  fr <- r.spec$freq * 50
  sp <- r.spec$spec * 2
  # 이 부분에 상위 5개 추출하는 코드 작성 # frequency가 작은거 5개순으로 뽑음
  freq_rslt <- rbind(freq_rslt, as.data.frame(t(c(d, fr[1:5], sp[1:5]))))
}

head(freq_rslt)
freq_rslt

id_f <- function(x) {
  exp_no = unlist(regmatches(x, gregexpr("[[:digit:]]+", x)[1]))[1]
  id = unlist(regmatches(x, gregexpr("[[:digit:]]+", x)[1]))[2]
  activity = unlist(str_split(x, "\\_"))[1]
  return(cbind(exp_no, id, activity))
  
}

temp <- data.frame()

for(i in 1:nrow(freq_rslt)){
  temp <- rbind(temp, id_f(freq_rslt$V1[i]))
}


freq_rslt <- cbind(freq_rslt, temp)

activity_freq <- freq_rslt %>% select(-V1, -exp_no, -id)

library(RWeka)
RF <- make_Weka_classifier("weka/classifiers/trees/RandomForest")

colnames(activity_freq)
for (n_col in 1:10){
  activity_freq[,n_col] = as.numeric(activity_freq[,n_col])
}


m <- RF(as.factor(activity)~., data = activity_freq)

e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)

e

library(pracma)
# 스펙트럼 가속도 센서와 유저 센서 추가 
bf <- butter(1, 0.05, type = "high")
ff_result <- data.frame()
for (i in fls){
  temp <- get(i)
  
  spec1 <- spectrum(signal::filter(bf,temp$magrotationRate), log = "no", span = 10, plot = FALSE)
  spec2 <- spectrum(signal::filter(bf,temp$maguserAcceleration), log = "no", span = 10, plot = FALSE)
  fr <- spec1$freq * 50
  sp <- spec1$spec * 2
  fr2 <- spec2$freq * 50
  sp2 <- spec2$spec*2
  
  sp.s <- as.numeric(sp[which(sp %in% sort(sp, decreasing = TRUE)[1:5])])
  fr.s <- as.numeric(fr[which(sp %in% sort(sp, decreasing = TRUE)[1:5])])
  sp2.s <- as.numeric(sp2[which(sp2 %in% sort(sp2, decreasing = TRUE)[1:5])])
  fr2.s <- as.numeric(fr2[which(sp2 %in% sort(sp2, decreasing = TRUE)[1:5])])
  ff_result <- rbind(ff_result, as.data.frame(t(c(id_f(i), fr.s, sp.s, fr2.s, sp2.s))))
  }


colnames(ff_result)
for (n_col in 4:length(colnames(ff_result))){
  ff_result[,n_col] = as.numeric(ff_result[,n_col])
}
set.seed("16512314")
RF <- make_Weka_classifier("weka/classifiers/trees/RandomForest")
m <- RF(as.factor(V3)~., data = ff_result %>% select(-V1, -V2))

e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)

e


# peak 분석
ff_peak_result <- data.frame()
for (i in fls){
  temp <- get(i)
  
  spec1 <- spectrum(signal::filter(bf, temp$magrotationRate), log = "no", span = 10, plot = FALSE)
  spec2 <- spectrum(signal::filter(bf, temp$maguserAcceleration), log = "no", span = 10, plot = FALSE)
  fr <- spec1$freq * 50
  sp <- spec1$spec * 2
  fr2 <- spec2$freq * 50
  sp2 <- spec2$spec*2
  p <- findpeaks(sp)
  
  p <- as.data.frame(p)
  p <- arrange(p, desc(V1))
  
  p2 <- findpeaks(sp2)
  
  p2 <- as.data.frame(p2)
  p2 <- arrange(p2, desc(V1))
  
  ff_peak_result <- rbind(ff_peak_result, cbind(id_f(i),data.frame(p[1:10, 1:2]), data.frame(p2[1:10, 1:2])))
}

ff_peak_result
colnames(ff_peak_result) <- c("exp_no", "id", "activity", "V1", "V2", "V3", "V4")
str(ff_peak_result)


m <- RF(as.factor(activity)~., data = ff_peak_result %>% select(-exp_no, -id))

e <- evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)

e
