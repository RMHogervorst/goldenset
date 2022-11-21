library(vetiver)
library(tidyverse)
library(workflows)
library(yardstick)
library(pins)

# load model
b <- board_folder(path = "pins-r")
v <- vetiver_pin_read(b, "cars_mpg")


cars <- read_csv("https://vetiver.rstudio.com/get-started/new-cars.csv")
original_cars <- slice(cars, 1:14)
new_cars <- slice(cars, -1:-7)



convert_to_warning <- function(dataframe){
  res <- dataframe %>% 
    filter(warn < .estimate)
  if(nrow(res)> 0){
    for(i in 1:nrow(res)){
      warning(
        paste0(
          'Warning ',
          res$.metric[i]," = ",
          round(res$.estimate[i], 3), 
          " which is larger then boundary ",
          res$warn[i] ),
        call. = FALSE
      )
    }
  }
  
  dataframe
}
convert_to_errors <- function(dataframe){
  res <- dataframe %>% 
    filter(fail < .estimate)
  if(nrow(res)> 0){
    errs <- ""
    for(i in 1:nrow(res)){
      
        err1 <- paste0(
          'Error ',
          res$.metric[i]," = ",
          round(res$.estimate[i], 3), 
          " which is larger then fail condition ",
          res$fail[i] )
        errs <- paste(errs, err1,collapse = " \n")
    }
    stop(paste0("Failconditions met: ",errs),call. = FALSE)
  }
  
  dataframe
}
# we are interested in 
# - rmse, root mean squared error; same units as data
# - huber_loss, less sensitive to outliers than rmse
# - mape,  mean absolute percentage error; relative units.
measurements <- metric_set(
  rmse,huber_loss, mape
)

## and we set the criteria here
criteria <- data.frame(
  .metric = c("rmse","huber_loss","mape"),
  warn = c(4.5, 4, 17),
  fail = c(5, 4.5, 18)
)

# augment, adds the prediction result column (.pred) to the original data.
verification_results <-
  augment(v, new_data = new_cars) %>% 
  measurements(mpg, estimate = .pred) %>% 
  inner_join(criteria, by='.metric')
  
verification_results %>% 
  convert_to_warning() %>% 
  convert_to_errors()

