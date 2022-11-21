library(tidymodels)
library(vetiver)
library(pins)
#### Modify your code here
car_mod <-
  workflow(mpg ~ ., decision_tree(mode = "regression")) %>%
  fit(mtcars)


##### Saving the model here #####
# bad practice 1: using a local folder to save a model
v <- vetiver_model(car_mod, "cars_mpg")
model_board <- board_folder("pins-r", versioned = TRUE)
model_board %>% vetiver_pin_write(v)
vetiver_write_plumber(model_board, "cars_mpg",rsconnect = FALSE)
# git add the butchered model inside the folder, and plumber.R