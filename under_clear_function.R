#under_clear_function

#libraries to identify connected components
library(raster)

under_clear <- function(map, budget, params) {
  max_conn_size <- params[1]
  min_conn_size <- params[2]
  clearing_cost <- params[3]
  
  # change the map to only consider understory
  #print(sum(map))
  understory <- map
  understory[understory == 1] <- 0
  
  # determine connected components
  raster <- raster(understory)
  clump <- as.matrix(clump(raster, directions=4))
  clump_tab_understory <- table(clump)
  
  targets <- sort(clump_tab_understory[which(clump_tab_understory <= max_conn_size &
                                               clump_tab_understory>=min_conn_size)], decreasing = T)
  
  # use the maximum possible budget
  while (budget > max(targets)[1] * clearing_cost) {
    # clear the maximum possible clump size as often as possible
    clear_targets <- targets[targets==max(targets)]
    to_clear <- sample(clear_targets, 1)
    
    map[clump == as.integer(names(to_clear))] <- 1
    
    budget <- budget - to_clear * clearing_cost
  }
  # use the remaining budget on the next possible largest forest size
  
  while (budget > min_conn_size * clearing_cost) {
    clear_conn_size = floor(budget / clearing_cost)
    
    clear_targets <- targets[targets==clear_conn_size]
    while(length(clear_targets)==0 & clear_conn_size>=min_conn_size){
      clear_conn_size <- clear_conn_size - 1
      clear_targets <- targets[targets==clear_conn_size]
    }
    to_clear <- sample(clear_targets, 1)
    
    map[clump == as.integer(names(to_clear))] <- 1
    
    budget <- budget - clear_conn_size * clearing_cost
  }
  
  return(list(map, budget))
}
