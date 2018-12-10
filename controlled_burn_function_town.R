#controlled_burn_function

#libraries to identify connected components
library(raster)
#library(igraph)

controlled_burn <- function(map, budget, params){
  clump_limit_lower <- params[1]
  clump_limit_upper <- params[2]
  cut_cost <- params[3]
  search_range_min <- params[4]
  search_range_max <- params[5]
  x   <- map
  n   <- nrow(x)
  m   <- ncol(x)
  x_understory <- x
  x_understory[x_understory==1]<-0
  #mask off the area we care about
  x_masked <- x_understory
  inner_lim_min <- 100-search_range_min
  inner_lim_max <- 101+search_range_min
  outer_lim_min <- 100-search_range_max
  outer_lim_max <- 101+search_range_max
  
  x_masked[inner_lim_min:inner_lim_max, inner_lim_min:inner_lim_max] <- 0
  x_masked[1:outer_lim_min,] <- 0
  x_masked[outer_lim_max:n,] <- 0
  x_masked[,1:outer_lim_min] <- 0
  x_masked[,outer_lim_max:n] <- 0
  #build connected components
  #raster <- raster(x_understory)
  #clump <- as.matrix(clump(raster, directions=4))
  #clump_tab_understory <- table(clump)
  
  raster <- raster(x_masked)
  clump_2 <- as.matrix(clump(raster, directions=4))
  clump_tab_understory_masked <- table(clump_2)
  #find clumps greater than n contiguous squares
  targets <- sort(clump_tab_understory_masked[which(clump_tab_understory_masked >= clump_limit_lower)],
                  decreasing = T)
  
  #cut clumps larger than m squares (maybe later)
  #targets_2 <- targets[which(targets >= clump_limit_upper)]
  
  #clear trees around largest burn clumps, then ignite, burn, and subtract from budget
  wdist <- matrix(c(0,1,0,1,0,1,0,1,0), ncol=3)
  while(budget > 0 & length(targets>0)){
    burn_target <- targets[1] #get clump to burn
    targets <- targets[-1] #remove clump from list
    removal_mat <- x
    removal_mat[clump_2==as.integer(names(burn_target))] <- 6
    neighbors <- simecol::neighbors(removal_mat, state=6, wdist=wdist)
    trees_remove <- which(neighbors!=0)
    actual_trees <- x[trees_remove]
    trees_remove_true <- trees_remove[actual_trees==1]
    cost <- length(trees_remove_true*cut_cost) + 5
    if(cost <= budget){
      x[trees_remove_true] <- 0
      x[which(clump_2==as.integer(names(burn_target)))[1]] <- 4
      budget <- budget - cost
    }
  }
  return(list(x, budget))
}
