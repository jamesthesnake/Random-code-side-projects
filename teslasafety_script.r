####Partial replication & reanalysis of "NHTSA’s Implausible Safety Claim for Tesla’s Autosteer Driver Assistance System" by Quality Control Systems Corp####
####This script was written by Aube on Feb 13, 2019####
####Feel free to do whatever you want with it as long as you give proper attribution####
 
 
library(openxlsx)
setwd("K:\\Rfiles\\Data")
 
##preliminary steps: load data, trying to replicate QCS report as understood by skimming the intro##
teslasheet <- read.xlsx("teslasafety.xlsx",na.strings="-") #this is a copy of spreadsheet: "PE16_007_PRODUCTION DATA" from http://www.safetyresearch.net/Library/2018-11-26%2520Redacted%2520PE16_007_PRODUCT
ION%2520DATA_jlq_working_file_10Jan2017%2520.xlsx
#teslatable <- read.csv("teslasafety.csv",header=TRUE,sep=",",na.strings=c("-",""),nrows=43781,stringsAsFactors=FALSE) #nrows does not count header row!
 
dim(teslasheet)
 
redacted_cols <- rep(0,dim(teslasheet)[2])
num_redacted <- 0
for(i in 1:dim(teslasheet)[2]){
    if(grepl("REDACTED",names(teslasheet)[i])){
        num_redacted <- num_redacted+1
        redacted_cols[num_redacted] <- i
    }
}
 
teslasheet_redacted <- teslasheet[,-redacted_cols[1:num_redacted]]
 
teslasheet_red_com <- teslasheet_redacted[teslasheet_redacted[,2]==teslasheet_redacted[,3],]
events_before <- sum(teslasheet_red_com[,6],na.rm=T) #note here that cols 6 and 7 show that no car had more than 1 event before/after
events_after <- sum(teslasheet_red_com[,7],na.rm=T)
 
miles_before <- sum(teslasheet_red_com[,8],na.rm=T)
miles_after <- sum(teslasheet_red_com[,9],na.rm=T)
 
poisson.test(c(events_before,events_after),c(miles_before,miles_after))
#point estimate favours before autosteer, but difference not statistically significant at 95% confidence level
 
sum(teslasheet_red_com[,6] & !teslasheet_red_com[,8],na.rm=T)
which(teslasheet_red_com[,6] & !teslasheet_red_com[,8])
teslasheet_red_com[16543,]
#one event in which an event occured before installation of autosteer even though 0 miles driven. Logically impossible observation should be omitted
sum(teslasheet_red_com[,7] & !teslasheet_red_com[,9],na.rm=T)
which(teslasheet_red_com[,7] & !teslasheet_red_com[,9])
teslasheet_red_com[9162,]
#also not possible. Miles driven is 0, but had an event
events_before <- events_before-1
events_after <- events_after-1
miles_after <- miles_after-1624
 
poisson.test(c(events_before,events_after),c(miles_before,miles_after))
#still not significant
#doesn't match QCS conclusions, but not particularly unexpected. Will follow their methodology more closely in another pass
 
##Confirming NHTSA methodology, following page 8 of QCS Report##
sum(teslasheet_redacted[,2]!=teslasheet_redacted[,8],na.rm=T) #assumption about method for calculating miles before autosteer is correct
sum(is.na(teslasheet_redacted[,2])!=is.na(teslasheet_redacted[,8])) #oh wait, we have na in one but not another? Let's take a closer look
 
teslasheet_redacted[which(is.na(teslasheet_redacted[,2])!=is.na(teslasheet_redacted[,8])),c(2,8)]
#messy way of treating data, interchanging NA and 0, but can be lived with
 
sum(teslasheet_redacted[,9]!=(teslasheet_redacted[,1]-teslasheet_redacted[,3]),na.rm=T) #assumption about method for calculating miles after autosteer is also corrected
 
##Choosing the subset per QCS: previous mileage before autosteer install should match next mileage after install
sum(teslasheet_redacted[,2]==teslasheet_redacted[,3],na.rm=T) #20408!=5714. Something's wrong
 
sum((teslasheet_redacted[,2]==teslasheet_redacted[,3])&!is.na(teslasheet_redacted[,2]),na.rm=T) #explicitly omitting where previous mileage is unknown doesn't help
 
sum((teslasheet_redacted[,2]!=teslasheet_redacted[,3]),na.rm=T) #omit where final mileage is unknown, as they mentioned, lowers the number slightly
 
sum((teslasheet_redacted[,2]==teslasheet_redacted[,3])&(teslasheet_redacted[,2]>0),na.rm=T) #restrict to where previous mileage is >0 to ensure comparability - 5719, very close!
 
sum((teslasheet_redacted[,2]==teslasheet_redacted[,3])&(teslasheet_redacted[,2]>0)&!is.na(teslasheet_redacted[,1]),na.rm=T) #omit file mileage unknown cases on top of that, 5714, bingo
 
complete_only <- (teslasheet_redacted[,2]==teslasheet_redacted[,3])&(teslasheet_redacted[,2]>0)&!is.na(teslasheet_redacted[,1])
complete_indices <- which(complete_only)
teslasheet_com <- teslasheet_redacted[complete_indices,]
 
events_before <- sum(teslasheet_com[,4],na.rm=T)
events_after <- sum(teslasheet_com[,5],na.rm=T)
 
mileage_before <- sum(teslasheet_com[,8],na.rm=T)
mileage_after <- sum(teslasheet_com[,9],na.rm=T)
#numbers match up with Figure 1 in QCS report
 
outcome_QCS <- c(teslasheet_com[,4],teslasheet_com[,5])
mileage_QCS <- c(teslasheet_com[,8],teslasheet_com[,9])
has_autosteer <- c(rep(0,5714),rep(1,5714))
 
model_logit <- glm(outcome_QCS~mileage_QCS+has_autosteer,family=binomial(link="logit")) 
summary(model_logit)
#results match that of Table 1, doesn't show odds ratios, etc. but when estimates and p-values match, I'm willing to take the rest of the printout on faith
 
##Replicating NHTSA part 2##
neither_only <- (teslasheet_redacted[,2]==0|is.na(teslasheet_redacted[,2]))&(teslasheet_redacted[,3]==0|is.na(teslasheet_redacted[,3]))&(teslasheet_redacted[,1]>0)&!is.na(teslasheet_redacted[,1])
sum(neither_only)
#14792 versus 14791 reported by QCS. I'm not sure what exclusion criteria I'm missing
#the ones I used are: mileage before not reported or 0, mileage after not reported or 0, total mileage neither unreported nor 0
 
 
#I'm not comfortable with interpretting 0 miles as "unreported" without further evidence. Let's see if that choice can be validated
teslasheet_redacted[which(neither_only&teslasheet_redacted[,6]),] #one of the paradoxical before events happened where miles before install was reported at 0 (observation 39290). This supports excluding 0 mileage before install cases
 
 
##Replicating exposure gap##
incomp <- which((teslasheet_redacted[,2]<teslasheet_redacted[,3])&(teslasheet_redacted[,2]>0)&!is.na(teslasheet_redacted[,1])) #mileage before strictly less than mileage after
length(incomp)
teslasheet_incomp <- teslasheet_redacted[incomp,]
gap <- sum(teslasheet_incomp[,3]-teslasheet_incomp[,2]) #total exposure gap miles
known_before <- sum(teslasheet_incomp[,8])
known_after <- sum(teslasheet_incomp[,9])
gap/known_before
 
#it's not clear to me how Figures 3A and 3B were constructed since it should vary depending on the order in which the points are added?
#this is how I visualize the same data
plot(teslasheet_incomp[,8],teslasheet_incomp[,3]-teslasheet_incomp[,2]) #the higher the known miles, the smaller the gap
plot(teslasheet_incomp[,9],teslasheet_incomp[,3]-teslasheet_incomp[,2])
plot(teslasheet_incomp[,9],teslasheet_incomp[,3]-teslasheet_incomp[,2],xlim=c(0,40000),ylim=c(0,6*10^4)) #omits a few outliers. Maybe a positive correlation?
 
 
##Mileage before not reported, mileage after known##
one_report <- which(((teslasheet_redacted[,2]==0)|is.na(teslasheet_redacted[,2]))&(teslasheet_redacted[,3]>0)&!is.na(teslasheet_redacted[,3])&!is.na(teslasheet_redacted[,1])&(teslasheet_redacted[,1]>0))
length(one_report)
teslasheet_one <- teslasheet_redacted[one_report,]
gap_one <- sum(teslasheet_one[,3])
after_one <- sum(teslasheet_one[,9])
 
##The numbers as computed by NHTSA##
events_before_all <- sum(teslasheet_redacted[,6],na.rm=T)
events_after_all <- sum(teslasheet_redacted[,7],na.rm=T)
 
miles_before_all <- sum(teslasheet_redacted[,8],na.rm=T)
miles_after_all <- sum(teslasheet_redacted[,9],na.rm=T)
 
poisson.test(c(events_before_all,events_after_all),c(miles_before_all,miles_after_all))
(events_before_all/miles_before_all-events_after_all/miles_after_all)/(events_before_all/miles_before_all)
 
 
##Permutation test (my own contribution to the analysis, based on cases where data is complete)##
#H_0: the probability of having an event per mile is the same after the installation of autosteering as before
#H_1: the probability of having an event per mile is not the same after the installation of autosteering as before
#We will only use the cases where an event happened, and ask "what is the chance of getting a number of events_before at least as extreme as the one we observed if the null hypothesis is true?"
#the threshold of significance is 0.05, per convention
 
events <- (teslasheet_com[,4]==T)+(teslasheet_com[,5]==T)
sum(events) #96 total events
 
 
teslasheet_events <- teslasheet_com[which(events>0),]
num_events <- teslasheet_events[,4]+teslasheet_events[,5]
events_index=1
 
events_cutoff <- rep(0,sum(events))
for(i in 1:dim(teslasheet_events)[1]){
    cutoff <- teslasheet_events[i,8]/teslasheet_events[i,1] #assuming uniform probability of accident for any car, the chance of an accident before install would correspond to the proportion of miles before autosteer
    if(num_events[i]==1){
        events_cutoff[events_index] <- cutoff
        events_index <- events_index+1
    }else{
        for(i in 1:num_events[i]){
            events_cutoff[events_index] <- cutoff
            events_index <- events_index+1
        }
    }
}
 
sim_num <- 10^6
 
set.seed(2007)
random_mat <- matrix(runif(sim_num*sum(events)),sum(events),sim_num) #this is a 96x(10^6) matrix of numbers selected from U(0,1) distribution
 
result_mat <- matrix(NA,sum(events),sim_num)
for(i in 1:sim_num){
    result_mat[,i] <- (random_mat[,i]<events_cutoff) #if the random number is smaller than the cutoff, the event happens before installation, otherwise it happens afterwards (implicitly)
}
 
events_before_BS <- colSums(result_mat) #in this manner, we generate a bootstrap distribution for the number of events before installation
sum(events_before_BS<=events_before)/sim_num #0.000295
#since we are doing a two-tailed test, we need to double the above number to get the estimated p-value
2*sum(events_before_BS<=events_before)/sim_num #0.00059
 
pval <- 2*sum(events_before_BS<=events_before)/sim_num #0.00059
#this is much, much lower than the threshold, so we reject the null hypothesis
