## Postgres database connection

# Install the package
install.packages("RPostgreSQL")
# Load the package to memory
library(RPostgreSQL)

# Load the postgres driver
drv <- dbDriver("PostgreSQL")
# Connect to the postgres server
con <- dbConnect(drv, host=""
                 ,dbname=""
                 ,user=""
                 ,password="")

## Submits a statement
rs <- dbSendQuery(con, "select * from sales limit 100")
## fetch all elements from the result set
sales <- fetch(rs,n=-1)

## Closes the connection
dbDisconnect(con)
## Frees all the resources on the driver
dbUnloadDriver(drv)


