library(simecol)

fire_sim  <- function(init, params) {
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
  wdist <- matrix(c(0,1,0,1,0,1,0,1,0), ncol=3)
  trees  <- simecol::neighbors(init, state=1, wdist=wdist)
  utrees <- simecol::neighbors(init, state=2, wdist=wdist)
  t_fires <- simecol::neighbors(init, state=3, wdist=wdist)
  u_fires <- simecol::neighbors(init, state=4, wdist=wdist)
  rand_mat <- runif(init)
  if(any(x>=3)){
    ## burning rules
    x[which(init==1 & t_fires>0 & rand_mat < (1-p_treeburn^t_fires))] <- 3
    x[which(init==2 & (t_fires>0 | u_fires>0) & rand_mat < p_uburn)] <- 4
    ## burnout rules
    x[which(init==4 & rand_mat < p_burnout_u)] <- 1
    x[which(init==4 & rand_mat >= (p_burnout_u+p_stayburn_u))] <- 3
    x[which(init==3& rand_mat <p_burnout_t) ] <- 0
  }else{
    ## lightning rule
    x[which(init==2 & rand_mat<(3/n^2))] <- 4
    ## growth of trees and understory growth
    x[which(init==0 & rand_mat < p_seed)] <- 1
    x[which(init==1 & rand_mat < p_grow)] <- 2
    x[which(init==0 & (trees>0 |utrees>0) & rand_mat < p_spread*(trees+utrees))] <- 1
  }
  return(x)
}

n <- 200

init <- matrix(sample(c(0:2), n*n, replace=T), nrow=n, ncol=n)

x <- init

params <- c(p_treeburn <- 0.5,
            p_uburn <- 1,
            p_burnout_u <- 0.4,
            p_stayburn_u <- 0.2, 
            p_burnout_t <- 1,
            p_seed <- 0.0005,
            p_spread <- 0.1,
            p_grow <- 0.1)

jpeg("/tmp/foo%03d.jpg")
fire_sum <- as.list(1:5)
for(i in 1:5000){
  x <- fire_sim(x, params)
  fire_sum[[1]] <- c(fire_sum[[1]], length(which(x==0))/n^2)
  fire_sum[[2]] <- c(fire_sum[[2]], length(which(x==1))/n^2)
  fire_sum[[3]] <- c(fire_sum[[3]], length(which(x==2))/n^2)
  fire_sum[[4]] <- c(fire_sum[[4]], length(which(x==3))/n^2)
  fire_sum[[5]] <- c(fire_sum[[5]], length(which(x==4))/n^2)
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
dev.off()

perc_empty <- fire_sum[[1]][-1]
perc_tree <- fire_sum[[2]][-1]
perc_us <- fire_sum[[3]][-1]
perc_tree_burn <- fire_sum[[4]][-1]
perc_us_burn <- fire_sum[[5]][-1]

plot(perc_tree+perc_us, type='l', col='green', lwd=2, ylab='Tree Density', xlab='Time')
plot(perc_tree, type='l', col='green', lwd=2, ylab='Tree Density', xlab='Time', ylim=c(0,1))
lines(perc_us, type='l', col='darkgreen', lwd=2)
lines(perc_tree+perc_us, lwd=2)
legend('topleft', lwd=c(2,2,2), col=c('black', 'green', 'darkgreen'),
       legend=c('total trees', 'trees', 'understoried'), bty="n", horiz=T)

matrix_us <- matrix(perc_us, ncol=500)

maxes <- numeric(0)
for(i in 1:7){
  maxes <- c(maxes, max(matrix_us[i,]))
}

mean(maxes)
min(maxes)
max(maxes)
