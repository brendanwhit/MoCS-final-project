#controlled_burn_function

#libraries to identify connected components
library(raster)
library(igraph)

controlled_burn <- function(map, budget, params){
  clump_limit_lower <- params[1]
  clump_limit_upper <- params[2]
  cut_cost <- params[3]
  x   <- map
  n   <- nrow(x)
  m   <- ncol(x)
  x_understory <- x
  x_understory[x_understory==1]<-0
  #build connected components
  raster <- raster(x_understory)
  clump <- as.matrix(clump(raster, directions=4))
  clump_tab_understory <- table(clump)
  
  #find clumps greater than n contiguous squares
  targets <- sort(clump_tab_understory[which(clump_tab_understory >= clump_limit_lower)],
                  decreasing = T)
  
  #cut clumps larger than m squares (maybe later)
  #targets_2 <- targets[which(targets >= clump_limit_upper)]
  
  #clear trees around largest burn clumps, then ignite, burn, and subtract from budget
  wdist <- matrix(c(0,1,0,1,0,1,0,1,0), ncol=3)
  while(budget > 0 & length(targets>0)){
    burn_target <- targets[1] #get clump to burn
    targets <- targets[-1] #remove clump from list
    removal_mat <- x
    removal_mat[clump==as.integer(names(burn_target))] <- 6
    neighbors <- simecol::neighbors(removal_mat, state=6, wdist=wdist)
    trees_remove <- which(neighbors!=0)
    actual_trees <- x[trees_remove]
    trees_remove_true <- trees_remove[actual_trees==1]
    cost <- length(trees_remove_true*cut_cost) + 5
    if(cost <= budget){
      x[trees_remove_true] <- 0
      x[which(clump==as.integer(names(burn_target)))[1]] <- 4
      budget <- budget - cost
    }
  }
  return(list(x, budget))
}