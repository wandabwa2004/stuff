
# Code calculates the number of iterations to reach 1 for starting numbers 1 to 10,000
# according to the famous Collatz conjecture
# https://en.wikipedia.org/wiki/Collatz_conjecture

collatz <- function(num = c(1:10000)) {
  
  ptm <- proc.time()
  library(ggplot2)
  # num = seq(1, 20, 3)
  num_t = data.frame("num0"=character(), "t"=character())
  
  for (n in 1:length(num)) {
    t = 0
    num0 = num[n]
    num_n = num[n]
    
    while (num_n > 1) {
      t = t + 1
      
      if (num_n %% 2 == 0) {
        num_n = num_n / 2
      } else {
        num_n = num_n * 3 + 1
      }
      return
    }
    num_t = rbind(num_t, data.frame(num0, t))
  }
  plot <- qplot(num0, t, data=num_t, xlab="Starting number", ylab="Iterations until 1")
  
  time <- paste("Elapsed time is", round((proc.time() - ptm)[3],2), "seconds")
  
  print(time)
  results <- list("plot"=plot, "data"=num_t)
  return(results)
}

output <- collatz(c(1:10000))
output$plot


