
# Code calculates the number of iterations to reach 1 for starting numbers 1 to 10,000
# according to the famous Collatz conjecture
# https://en.wikipedia.org/wiki/Collatz_conjecture

# this function returns the data frame with collatz()$data, a scatter plot with collatz()$plot
# and a line plot with collatz()$lineplot


collatz <- function(num = c(1:10)) {
  
  ptm <- proc.time()
  library(ggplot2)

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
  

  # implementation of the Sieve of Eratosthenes algorithm for prime numbers

  sieve <- function(n)
  {
    n <- as.integer(n)
    if(n > 1e6) stop("n too large")
    primes <- rep(TRUE, n)
    primes[1] <- FALSE
    last.prime <- 2L
    for(i in last.prime:floor(sqrt(n)))
    {
      primes[seq.int(2L*last.prime, n, last.prime)] <- FALSE
      last.prime <- last.prime + min(which(primes[(last.prime+1):n]))
    }
    which(primes)
  }
  

  # create list of prime numbers
  primes <- sieve(max(num))
  
  # Add prime number flag to data.frame
  num_t$isPrime <- F
  num_t[num_t$num0 %in% primes, ]$isPrime <- T
  
  plot <- qplot(num0, t, data=num_t, xlab="Starting number", ylab="Iterations until 1", colour=isPrime)
  lineplot <- qplot(num0, t, data=num_t, xlab="Starting number", ylab="Iterations until 1", 
                    geom=c("path","point"), colour=isPrime)
  #plot <- qplot(t, num0, data=num_t, ylab="Starting number", xlab="Iterations until 1")
  
  time <- paste("Elapsed time is", round((proc.time() - ptm)[3],2), "seconds")
  
  print(time)
  results <- list("plot"=plot, "data"=num_t, "lineplot"=lineplot)
  return(results)
}

# Run the algorithm with 10,000 incremental numbers
output <- collatz(c(1:10000))

output$lineplot
output$plot


###########

# Plot the iteration paths for a subset of numbers

collatz_path <- function(iterations = 20, num = 1:1000) {
  
  library(ggplot2)
  # num = seq(1, 20, 3)
  num_t = data.frame("t"=character(), "num0"=character(), "num_n"=character())
  
  for (n in 1:length(num)) {
    num0 = num[n]
    num_n = num[n]
    for (t in 1:iterations) {
      if (num_n %% 2 == 0) {
        num_n = num_n / 2
      } else {
        num_n = num_n * 3 + 1
      }
      num_t = rbind(num_t, data.frame(t, num0, num_n))
    }
  }
  
  plot <- qplot(t, num_n, data=num_t, colour=as.factor(num0), geom="path")
  #ggplot(num_t, aes(x=t, y=num_n)) + geom_line(aes(colour=as.factor(num0), group=num0))
  
  results <- list("plot"=plot, "data"=num_t)
  return(results)
}


output_path <- collatz_path(120, as.vector(output$data[, 1]))
output_path$plot

table(aggregate(output_path$data$num_n, by=list(output_path$data$num0), FUN=max)[,2])
