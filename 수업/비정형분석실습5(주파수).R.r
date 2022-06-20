t <- seq(0, 200, by = 0.1) # 0.1초 단위로 신호 생성
x <- cos(2*pi*t/16) + 0.75 * sin(2*pi*t/5)

plot(t, x, type = "l")

# 신호를 구성하는 frequency를 구한 다음에 각 frequency의 power를 확률밀도 함수로 나타냄
x.spec <- spectrum(x)

str(x.spec)


# 스펙트림 변수 생성
spx <- x.spec$freq * 1/0.1 # 0.1초 단위로 데이터를 생성했으므로 frequency도 0.1 단위로 추출

spy <- 2*x.spec$spec # spectrum*2를 곱해서 크기를 구하고(계산과정에서 주파수 +, -가 존재하도록 유도되는데 spectrum 함수는 + 주파수의 전력만 보여주기 때문에 *2로 해야 해당 주파수의 전력이 절대 값이 산출됨)

plot(spy~spx, xlab = 'frequency', ylab="spectral density")

# 상위 두개를 추출하여 변수화 하기로 함
spx[which(spy %in% sort(spy, decreasing = TRUE)[1:2])]

