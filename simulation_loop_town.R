#overnight simulation of this shite, full sweep
#loads
source('./fire_sim_function_town.R')
source('./controlled_burn_function_town.R')
source('./under_clear_function_town.R')
library(simecol)
library(raster)

#wdists
winds <- as.list(1:3)
winds[[1]] <- matrix(c(0,1,0,1,0,1,0,1,0), ncol=3)
winds[[2]] <- matrix(c(0,.1,0,0,0,.1,0.2,1,0,0,0.2,2,0,0.5,0,0.1,0.2,1,0,0,0,.1,0,0,0), ncol=5,
                   byrow = T)
winds[[3]] <- matrix(c(0,.5,0,0,0,.5,1,2,0,0,1,3,0,1,0,0.5,1,2,0,0,0,.5,0,0,0), ncol=5,
                     byrow = T)

#budgets

clear_bud <- c(0, 500, 250, 125, 375)
burn_bud <- c(500, 0, 250, 375, 125)

#parameters

params_growth_burn <- c(p_treeburn <- 0.5,
                        p_uburn <- 1,
                        p_burnout_u <- 0.4,
                        p_stayburn_u <- 0.2, 
                        p_burnout_t <- 1,
                        p_seed <- 0.0005,
                        p_spread <- 0.1,
                        p_grow <- 0.1)

params_clear <- c(max_conn_size <- 64,
                  min_conn_size <- 1,
                  clearing_cost <- 1,
                  search_range <- 8)

params_cburn <- c(clump_limit_lower <- 1,
                  clump_limit_upper <- 100000,
                  cut_cost <- 1,
                  search_range_min <- 8,
                  search_range_max <- 30)

#initialize data
data_wildfire <- as.list(1:15)
data_controlled <- as.list(1:15)
data_townburn <- as.list(1:15)

#loop through all
index <- 0
for(i in 1:3){
  wind_dist <- winds[[i]]
  for(j in 1:5){
    index <- index + 1
    bud_clear <- clear_bud[j]
    bud_burn <- burn_bud[j]
    budget_clear <- bud_clear
    budget_burn <- bud_burn
    wildfire_size <- numeric(0)
    controlled_burn_size <- numeric(0)
    init <- matrix(sample(c(0:2), 200*200, replace=T), nrow=200, ncol=200)
    init[100:101,100:101] <- 5
    for(k in 1:20){
      first_output <- under_clear(init, budget_clear, params_clear)
      budget_clear <- bud_clear + first_output[[2]]
      image_fire(first_output[[1]])
      #conduct controlled burn
      second_output <- controlled_burn(first_output[[1]], budget_burn, params_cburn)
      num_fires <- length(which(second_output[[1]]==4))
      budget_burn <- bud_burn + second_output[[2]]
      image_fire(second_output[[1]])
      third_output <- fire_sim_control(second_output[[1]], params_growth_burn, wind_dist=wind_dist)
      total_fire_size <- length(which(second_output[[1]]==1|second_output[[1]]==2))-
        length(which(third_output==1|third_output==2))
      controlled_burn_size <- c(controlled_burn_size, total_fire_size/num_fires)
      image_fire(third_output)
      #grow forest
      fourth_output <- growth_sim(third_output, params_growth_burn)
      image_fire(fourth_output)
      #run wildfires
      fifth_output <- fire_sim(fourth_output, params_growth_burn, wind_dist=wind_dist)
      wildfire_size <- c(wildfire_size, length(which(fourth_output==1|fourth_output==2))-
                           length(which(fifth_output==1|fifth_output==2)))
      image_fire(fifth_output)
      init <- fifth_output
      if(length(which(init==-1))==4){
        break
      }
    }
    data_townburn[[index]] <- c(which(init==-1), k)
    data_wildfire[[index]] <- wildfire_size
    data_controlled[[index]] <- controlled_burn_size
  }
}

#save(data_wildfire, data_controlled, file='burn_data.RData')