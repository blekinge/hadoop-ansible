library(sparklyr)
library(arrow)

# get the default config
conf <- spark_config()

conf$spark.authenticate.secret <- "test123"
sc <- spark_connect(master = "yarn", config = conf)



install.packages(c("nycflights13", "Lahman"))

library(dplyr)
iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)


flights_tbl %>% filter(dep_delay == 2)

