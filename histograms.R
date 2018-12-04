#histogram drawing

library(ggplot2)
library(dplyr)

load('burn_data.RData')

plots <- as.list(1:15)
for(i in 1:15){
  data_cont <- data_controlled[[i]]
  data_wild <- data_wildfire[[i]]
  index <- c(rep('Wildfire',length(data_wild[data_wild!=0 & data_wild!=-1])),
             rep('Controlled', length(data_cont[!is.na(data_cont)])))
  frame <- data.frame(log(c(data_wild[data_wild!=0 & data_wild!=-1],data_cont[!is.na(data_cont)])), index)
  colnames(frame) <- c('Log Fire Size', 'Index')
  plots[[i]] <- ggplot(frame, aes(x=`Log Fire Size`, fill=`Index`)) + geom_histogram() +ylim(0,500) + xlim(0,10)
}
plots[[1]]
plots[[2]]
plots[[3]]
plots[[4]]
plots[[5]]
plots[[6]]
plots[[7]]
plots[[8]]
plots[[9]]
plots[[10]]
plots[[11]]
plots[[12]]
plots[[13]]
plots[[14]]
plots[[15]]

