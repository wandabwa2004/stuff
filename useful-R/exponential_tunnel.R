
library(ggplot2)

# Exponential Tunnel

s = 0:750

x <- c(exp(-0.012 * s) * cos(1.24 * s), 
        exp(-0.012 * s) * cos(1.24 * s + 0.5236))
y <- c(exp(-0.012 * s) * sin(1.24 * s), 
        exp(-0.012 * s) * sin(-1.24 * s - 0.5236))

plot(x, y, type="l")
#qplot(x, y, size=I(0.75), geom="point")


# Star trails

a <- -0.42
b <- 0.63

x <- 0
y <- 0

for (i in 1:15) {
  xx<- x * x - y * y + a
  yy <- 2 * x * y + b
  x <- c(x, xx)
  y <- c(y, yy)
}

qplot(x, y, xlim =c(-50,50), ylim = c(-50,50))
