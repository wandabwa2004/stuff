## 
## File defines two functions which together cache the inverse of a matrix
## The first function sets and gets the matrix and inverse in a list, and 
## the second takes the list from the first and either calculates the inverse
## or gets the cached inverse
##

## The makeCacheMatrix function takes a matrix as input and:
## 1. sets the value of the matrix
## 2. gets the value of the matrix
## 3. sets the value for the inverse of the matrix
## 4. gets the value for the inverse of the matrix

makeCacheMatrix <- function(x = matrix()) {
  m <- NULL
  set <- function(y) {
    x <<- y
    m <<- NULL
  }
  get <- function() x
  setinverse <- function(solve) m <<- solve
  getinverse <- function() m
  list(set = set, get = get,
       setinverse = setinverse,
       getinverse = getinverse)
}


## cacheSolve takes the list returned from makeCacheMatrix and checks to see if the 
## matrix inverse has already been calculated.  If so, it gets the cached matrix 
## inverse, otherwise it calculates the matrix inverse.

cacheSolve <- function(x, ...) {
  m <- x$getinverse()
  if(!is.null(m)) {
    message("getting cached data")
    return(m)
  }
  else {
  data <- x$get()
  m <- solve(data, ...)
  solve(data, ...)
  x$setinverse(m)
  message("calculating matrix inverse")
  return(m)
  }
}

## To test the function, you can use the below code

x <- matrix(cbind(c(1,2,3),c(2,3,4),c(1,2,1)),ncol=3)
x.cache <- cacheSolve(makeCacheMatrix(x))
mcm <- makeCacheMatrix(x)
Y <- cacheSolve(mcm)

