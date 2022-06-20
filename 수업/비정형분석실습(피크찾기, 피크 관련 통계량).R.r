library(pracma)

x <- seq(0, 1, len = 1024)
pos <- c(0.1, 0.13, 0.15, 0.23, 0.25, 0.40, 0.44, 0.65, 0.76, 0.78, 0.81)
hgt <- c(4, 5, 3, 4, 5, 4.2, 2.1, 4.3, 3.1, 5.1, 4.2)
wdt <-
  c(0.005, 0.005, 0.006, 0.01, 0.01, 0.03, 0.01, 0.01, 0.005, 0.008, 0.005)
pSignal <- numeric(length(x))
for (i in seq(along=pos)) {
  pSignal <- pSignal + hgt[i]/(1 + abs((x - pos[i])/wdt[i]))^4
}
plot(pSignal, type="l", col="navy")

# 피크찾기
findpeaks(pSignal, npeaks=3, threshold=4, sortstr = TRUE)

x <- findpeaks(pSignal, npeaks = 3, threshold=4, sortstr=TRUE)
points(x[,2], x[,1], pch=20, col="maroon")


####################### 피크 관련 통계량 ##############################
# 피크 간격에 대한 평균
mean(diff(sort(x[,2])))

# 피크 간격의 산포
std(diff(sort(x[,2])))

# 피크 값에 대한 평균
mean((x[,1]))



