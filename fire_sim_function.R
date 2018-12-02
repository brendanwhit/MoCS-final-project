#fire_sim function

library(simecol)

#fire_sim  <- function(init, params) {
#  p_treeburn <- params[1]
#  p_uburn <- params[2]
#  p_burnout_u <- params[3]
#  p_stayburn_u <- params[4]
#  p_burnout_t <- params[5]
#  p_seed <- params[6]
#  p_spread <- params[7]
#  p_grow <- params[8]
#  x   <- init
#  n   <- nrow(x)
#  m   <- ncol(x)
#  wdist <- matrix(c(0,1,0,1,0,1,0,1,0), ncol=3)
#  trees  <- simecol::neighbors(init, state=1, wdist=wdist)
#  utrees <- simecol::neighbors(init, state=2, wdist=wdist)
#  t_fires <- simecol::neighbors(init, state=3, wdist=wdist)
#  u_fires <- simecol::neighbors(init, state=4, wdist=wdist)
#  rand_mat <- runif(init)
#  if(any(x>=3)){
#    ## burning rules
#    x[which(init==1 & t_fires>0 & rand_mat < (1-p_treeburn^t_fires))] <- 3
#    x[which(init==2 & (t_fires>0 | u_fires>0) & rand_mat < p_uburn)] <- 4
#    ## burnout rules
#    x[which(init==4 & rand_mat < p_burnout_u)] <- 1
#    x[which(init==4 & rand_mat >= (p_burnout_u+p_stayburn_u))] <- 3
#    x[which(init==3& rand_mat <p_burnout_t) ] <- 0
#  }else{
#    ## lightning rule
#    x[which(init==2 & rand_mat<(3/n^2))] <- 4
#    ## growth of trees and understory growth
#    x[which(init==0 & rand_mat < p_seed)] <- 1
#    x[which(init==1 & rand_mat < p_grow)] <- 2
#   x[which(init==0 & (trees>0 |utrees>0) & rand_mat < p_spread*(trees+utrees))] <- 1
#  }
#  return(x)
#}

fire_sim <- function(init, params, wind_dist){
  #run fire until burnt out
  p_treeburn <- params[1]
  p_uburn <- params[2]
  p_burnout_u <- params[3]
  p_stayburn_u <- params[4]
  p_burnout_t <- params[5]
  p_seed <- params[6]
  p_spread <- params[7]
  p_grow <- params[8]
  while((length(which(init==3))+length(which(init==4)))>0){
    x   <- init
    t_fires <- simecol::neighbors(init, state=3, wdist=wind_dist)
    u_fires <- simecol::neighbors(init, state=4, wdist=wind_dist)
    rand_mat <- runif(init)
    
    ## burning rules
    x[which(init==1 & t_fires>0 & rand_mat < (1-p_treeburn^t_fires))] <- 3
    x[which(init==2 & (t_fires>0 | u_fires>0) & rand_mat < p_uburn)] <- 4
    ## burnout rules
    x[which(init==4 & rand_mat < p_burnout_u)] <- 1
    x[which(init==4 & rand_mat >= (p_burnout_u+p_stayburn_u))] <- 3
    x[which(init==3& rand_mat <p_burnout_t) ] <- 0
    
    init <- x
  }
  return(init)
}

fire_sim_control <- function(init, params, wind_dist){
  #run fire until burnt out
  p_treeburn <- params[1]
  p_uburn <- params[2]
  p_burnout_u <- params[3]
  p_stayburn_u <- params[4]
  p_burnout_t <- params[5]
  p_seed <- params[6]
  p_spread <- params[7]
  p_grow <- params[8]
  while((length(which(init==3))+length(which(init==4)))>0){
    x   <- init
    t_fires <- simecol::neighbors(init, state=3, wdist=wind_dist)
    u_fires <- simecol::neighbors(init, state=4, wdist=wind_dist)
    rand_mat <- runif(init)
    
    ## burning rules
    x[which(init==1 & t_fires>0 & rand_mat < (1-p_treeburn^t_fires))] <- 3
    x[which(init==2 & (t_fires>0 | u_fires>0))] <- 4
    ## burnout rules
    x[which(init==4 & rand_mat < p_burnout_u)] <- 1
    x[which(init==4 & rand_mat >= (p_burnout_u+p_stayburn_u))] <- 3
    x[which(init==3& rand_mat <p_burnout_t) ] <- 0
    
    init <- x
  }
  return(init)
}

growth_sim <- function(init, params, n=1){
  p_treeburn <- params[1]
  p_uburn <- params[2]
  p_burnout_u <- params[3]
  p_stayburn_u <- params[4]
  p_burnout_t <- params[5]
  p_seed <- params[6]
  p_spread <- params[7]
  p_grow <- params[8]
  nrow <- nrow(init)
  for(i in 1:n){
    x   <- init
    wdist <- matrix(c(0,1,0,1,0,1,0,1,0), ncol=3)
    trees  <- simecol::neighbors(init, state=1, wdist=wdist)
    utrees <- simecol::neighbors(init, state=2, wdist=wdist)
    rand_mat <- runif(init)
    ## lightning rule
    x[which(init==2 & rand_mat<(3/nrow^2))] <- 4
    ## growth of trees and understory growth
    x[which(init==0 & rand_mat < p_seed)] <- 1
    x[which(init==1 & rand_mat < p_grow)] <- 2
    x[which(init==0 & (trees>0 |utrees>0) & rand_mat < p_spread*(trees+utrees))] <- 1
    init <- x
  }
  return(x)
}

image_fire <- function(x){
  if(identical(sort(unique(c(x))),c(0,1,2,3,4))){
    image(x, col=c('white', 'green', 'darkgreen', 'orange', 'red'), xaxt='n', yaxt = 'n')
  }
  if(identical(sort(unique(c(x))),c(0,1,2,3))){
    image(x, col=c('white', 'green', 'darkgreen', 'orange'), xaxt='n', yaxt = 'n')
  }
  if(identical(sort(unique(c(x))),c(0,1,2,4))){
    image(x, col=c('white', 'green','darkgreen','darkgreen', 'red'), xaxt='n', yaxt = 'n')
  }
  if(identical(sort(unique(c(x))),c(0,1,2))){
    image(x, col=c('white', 'green', 'darkgreen'), xaxt='n', yaxt = 'n')
  }
}