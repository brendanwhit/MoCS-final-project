#test script to see if things work together

source('./fire_sim_function.R')
source('./controlled_burn_function.R')
source('./under_clear_function.R')
library(simecol)
library(igraph)
library(raster)

n <- 200

init <- matrix(sample(c(0:2), n*n, replace=T), nrow=n, ncol=n)
  
budget_burn <- 250
budget_clear <- 250

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

  
for(i in 1:100){
  first_output <- under_clear(init, budget_clear, params_clear)
  image_fire(first_output[[1]])
  budget_clear <- 250 + first_output[[2]]
  second_output <- controlled_burn(first_output[[1]], budget_burn, params_cburn)
  image_fire(second_output[[1]])
  budget_burn <- 250 + second_output[[2]]
  third_output <- fire_sim_control(second_output[[1]], params_growth_burn)
  image_fire(third_output)
  fourth_output <- growth_sim(third_output, params_growth_burn)
  image_fire(fourth_output)
  fifth_output <- fire_sim(fourth_output, params_growth_burn)
  image_fire(fifth_output)
  init <- fifth_output
}
