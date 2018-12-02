#test script to see if things work together

source('./fire_sim_function.R')
source('./controlled_burn_function.R')
source('./under_clear_function.R')
library(simecol)
library(igraph)
library(raster)

n <- 200

init <- matrix(sample(c(0:2), n*n, replace=T), nrow=n, ncol=n)
  
bud_burn <- 400
bud_clear <- 100

params_growth_burn <- c(p_treeburn <- 0.5,
                        p_uburn <- 1,
                        p_burnout_u <- 0.4,
                        p_stayburn_u <- 0.2, 
                        p_burnout_t <- 1,
                        p_seed <- 0.0005,
                        p_spread <- 0.1,
                        p_grow <- 0.1)

params_clear <- c(max_conn_size <- 30,
                  min_conn_size <- 10,
                  clearing_cost <- 0.5)

params_cburn <- c(clump_limit_lower <- 30,
                  clump_limit_upper <- 100000,
                  cut_cost <- 2)

budget_clear <- bud_clear
budget_burn <- bud_burn
wildfire_size <- numeric(0)
controlled_burn_size <- numeric(0)

for(i in 1:100){
  #conduct clearing
  first_output <- under_clear(init, budget_clear, params_clear)
  image_fire(first_output[[1]])
  budget_clear <- bud_clear + first_output[[2]]
  #conduct controlled burn
  second_output <- controlled_burn(first_output[[1]], budget_burn, params_cburn)
  num_fires <- length(which(second_output[[1]]==4))
  image_fire(second_output[[1]])
  budget_burn <- bud_burn + second_output[[2]]
  third_output <- fire_sim_control(second_output[[1]], params_growth_burn)
  image_fire(third_output)
  total_fire_size <- length(which(second_output[[1]]==1|second_output[[1]]==2))-
    length(which(third_output==1|third_output==2))
  controlled_burn_size <- c(controlled_burn_size, total_fire_size/num_fires)
  #grow forest
  fourth_output <- growth_sim(third_output, params_growth_burn)
  image_fire(fourth_output)
  #run wildfires
  fifth_output <- fire_sim(fourth_output, params_growth_burn)
  image_fire(fifth_output)
  wildfire_size <- c(wildfire_size, length(which(fourth_output==1|fourth_output==2))-
    length(which(fifth_output==1|fifth_output==2)))
  init <- fifth_output
}


hist(wildfire_size[wildfire_size!=0 & wildfire_size !=(-1)], breaks=20)
hist(c(controlled_burn_size, wildfire_size[wildfire_size!=0 & wildfire_size !=(-1)]))
