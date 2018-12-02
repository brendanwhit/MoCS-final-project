#controlled_burn_function

#libraries to identify connected components
library(raster)
library(igraph)

controlled_burn <- function(map, budget, params){
  p_treeburn <- params[1]
  p_uburn <- params[2]
  p_burnout_u <- params[3]
  p_stayburn_u <- params[4]
  p_burnout_t <- params[5]
  p_seed <- params[6]
  p_spread <- params[7]
  p_grow <- params[8]
  x   <- init
  n   <- nrow(x)
  m   <- ncol(x)
  x <- init
  raster <- raster(x)
  clump <- as.matrix(clump(raster, directions=4))
  clump_tab <- table(clump)
}