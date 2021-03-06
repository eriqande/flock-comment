######Code for Converting Flock pop Q values to Structure formated pop - Q values
######Written for Flock Comment with Eric Anderson

###### Note: individuals parts of the code rely on Java and should be run individually 
###### If they are all run together you will probably experience a heap error. 

### packages that we will need that might not be installed
install.packages("XLConnect")
install.packages("stringr")

### load packages
require("XLConnect")
require("stringr")
require("ggplot2")

#We are going to work in a folder called 'ForPipeline'
#So long as the R scrip launches from this point the working directory 
#should be whereever that script is stored. 

#first let's make sure the wd is what we expect, change it if not
wd<-getwd()

#Where are flock results stored?
FOR<-"Flock-output-Raw"
#Note: we are going to do a lot of importing of different runs. 
# The generic naming of flock output is 'k2 Steelhead_Run1_Defaults.xls'
# where k and Run # will change

#how many clusters?
k.max=6
#how many reps did we do?
rep=6

# First need to save population based allocation of individuals page in flock output as 
# a .csv with only one header line!
# Flock saves the population allocation information in the sheet labelled "Samples allocation matrix"
options(java.parameters = "-Xmx4g" )

#read in the excel file and output a .csv 
#Writing all these .csv files may be time intensive, but 
#I already wrote the code to process the .csv file, so let's just
#live with this inefficency.
for (k in 2:k.max){
for (r in 1:rep){
excel.file <- file.path(FOR,paste("k",k," Steelhead_Run",r,"_Defaults.xls",sep=""))
assign(x="temp",value=(readWorksheetFromFile(excel.file, sheet="Samples allocation matrix", header=TRUE)))
temp<-temp[-(1:3),]
write.csv(x=temp,file=file.path(FOR,paste("k",k," Steelhead_Run",r,"_Defaults-popq.csv",sep="")),row.names=F)
}#over r reps
}#over k clusters

########################################################################################
# For the next part I am going to need a way of repeating strings with different indexing
# For this I'll write a function that takes k as an input and outputs a string
#Eric suggested a vectorized form to replace the loop. 
temp.string <- function(k) {
  i<-3:(k+1); paste(paste('(formatC(Mpopq.str[,',i, '],width=7,flag=','"+"','))',sep=""), collapse=",")}


# now we are going to read in each of the structure 
# output files so that we can eventually put our flock 
# in them so that we can run it all through CLUMP & Distruct
for (k in 2:k.max){
  for (r in 1:rep){
# Read in the Structure pop-q information that we need for formating
popq.str<-scan(file=file.path("Structure-Output",paste("StructOuput_genos_slg_pipe.txt_dat001_k00",k,"_Rep00",r,".txt_f",sep="")), what = "character", skip=30,nlines=63)
# put it into a matrix
Mpopq.str<-matrix(data=popq.str,nrow=63,ncol=k+2,byrow=T)
#read in Flock pop_q values
Flock_popq<-read.csv(file=file.path("Flock-output-Raw",paste("k",k," Steelhead_Run",r,"_Defaults-popq.csv",sep="")),header=T)
#Convert popq values to percentages
Flock_popq[,k+2]<-rowSums(Flock_popq[,(seq(from=2, to=k+1,by=1))])#put rowsum in last column
Flock_popq[,seq(from=2, to=k+1,by=1)]<-round(Flock_popq[,seq(from=2, to=k+1,by=1)]/Flock_popq[,k+2],3)
Flock_popq<-as.matrix(Flock_popq)
# Put flock results in structure output
Mpopq.str[,(seq(from=2, to=k+1,by=1))]<- Flock_popq[,c(seq(from=2, to=k+1,by=1))]

# Now I need to write them out with formatting!
# This will produce some text files will the correct formatting to 
# paste into the Structure output
if (k==2){
line.temp<-paste((formatC(Mpopq.str[,1],width=4,flag="+")),(formatC(Mpopq.str[,2],width=10,flag="+")),(formatC(Mpopq.str[,3],width=7,flag="+")),(formatC(Mpopq.str[,4],width=16,flag="+")),sep="")
}
if(k>=3){
  String2pass<-paste('paste((formatC(Mpopq.str[,1],width=4,flag="+"))','(formatC(Mpopq.str[,2],width=10,flag="+"))',(temp.string(k)),paste('(formatC(Mpopq.str[,',k+2,'],width=9,flag="+"))',sep=""),'sep="")',sep=",")
  line.temp<-eval(parse(text=String2pass))
}

# Write to file to paste in!
write(line.temp, file = paste("Flock_PopQ_k=",k,"run",r,".txt", sep = ""))
}#do for all reps
}#do for all k clusters

#########################################################################################
# Lets write some code for extracting the individual q values
# We have already set the number of max clusters and reps above
# if running code from here, remember to set these (k.max & rep)

for (k in 2:k.max){
  for (r in 1:rep){
# Read in the Structure pop-q information that we need for formating
#Note that number of lines to skip adds 2 to each file so skipping has to account for this
Indq.str<-scan(file=file.path("Structure-Output",paste("StructOuput_genos_slg_pipe.txt_dat001_k00",k,"_Rep00",r,".txt_f",sep="")), what = "character", skip=(113+k+(k-2)),nlines=2596)
Mindq.str<-matrix(data=Indq.str,nrow=2596,ncol=k+5,byrow=T)

# Above we designated the place where we store Flock results in the variable
# FOR - we are now going to read in a different sheet from the same workbook
# This should take a bit longer because we are dealing with 2956 individuals
# instead of just 63 pops.... might have some Java errors
# I suggest shutting down other Java apps ~ took my mac less than a minute to process
# them


    excel.file <- file.path(FOR,paste("k",k," Steelhead_Run",r,"_Defaults.xls",sep=""))
    assign(x="temp",value=(readWorksheetFromFile(excel.file, sheet="All specs alloc and likelihoods", header=TRUE)))
    temp<-temp[-(1),] # get rid of the extra header
    write.csv(x=temp,file=file.path(FOR,paste("k",k," Steelhead_Run",r,"_Defaults-indq.csv",sep="")),row.names=F)

#read in Flock ind_q values
Flock_indq<-read.csv(file=file.path("Flock-output-Raw",paste("k",k," Steelhead_Run",r,"_Defaults-indq.csv",sep="")),header=T)

# structure rounds the q_i values to the 3rd decimal place
# probably should do this with Flock results in case 
# Clump and Distruct hiccup on that
index<- list(c(10,11),c(11,12,13),c(13,14,15,16),c(15,16,17,18,19),c(17,18,19,20,21,22))
Flock_indq[,index[[k-1]]]<-round(Flock_indq[,index[[k-1]]],3)
Flock_indq<-as.matrix(Flock_indq)

#Move flock indq values into the structure matrix
Mindq.str[,seq(from=6, to=6+(k-1),by=1)]<-Flock_indq[,index[[k-1]]]

# do some formatting on the structure matrix so that they can be pasted in
# Some strange formatting in the structure file. Below 1000 numbers in first column 
# are left justified with blank padding, above they aren't padded. 
# Might need to be creative to get it the exact formating.
Mindq.str.1st<-Mindq.str[1:999,]
Mindq.str.2nd<-Mindq.str[1000:2596,]

# Going to make some repeating strings for all the k's we have to loop over
# And we'll have to make two different strings, one for the first 999 and then another 
# for those after 10000

temp.string2.1<-function(k){
  string<- vector()
  for (i in 7:(6+(k-1))){
    string[i]<-paste('(formatC(Mindq.str.1st[,',i, '],width=5,flag=','"+"','))',sep="")
  }
  string<-string[-(1:6)]
  string<-paste(string,collapse=",")
  return(string)
}
temp.string2.2<-function(k){
  string<- vector()
  for (i in 7:(6+(k-1))){
    string[i]<-paste('(formatC(Mindq.str.2nd[,',i, '],width=5,flag=','"+"','))',sep="")
  }
  string<-string[-(1:6)]
  string<-paste(string,collapse=",")
  return(string)
}

String2pass2.1<-paste('paste(formatC(Mindq.str.1st[,1],width=2,flag="+"),formatC(Mindq.str.1st[,2],width=8,flag="+"),formatC(Mindq.str.1st[,3],width=6,flag="+"),formatC(Mindq.str.1st[,4],width=4,flag="+"),formatC(Mindq.str.1st[,5],width=1,flag="+"),formatC(Mindq.str.1st[,6],width=6,flag="+")',(temp.string2.1(k)),'formatC("",width=0,flag="+")','sep=" ")',sep=",")
String2pass2.2<-paste('paste(formatC(Mindq.str.2nd[,1],width=2,flag="+"),formatC(Mindq.str.2nd[,2],width=8,flag="+"),formatC(Mindq.str.2nd[,3],width=6,flag="+"),formatC(Mindq.str.2nd[,4],width=4,flag="+"),formatC(Mindq.str.2nd[,5],width=1,flag="+"),formatC(Mindq.str.2nd[,6],width=6,flag="+")',(temp.string2.1(k)),'formatC("",width=0,flag="+")','sep=" ")',sep=",")
line.temp2.1<-eval(parse(text=String2pass2.1))
line.temp2.2<-eval(parse(text=String2pass2.2)) 

write(line.temp2.1, file = paste("Flock_IndQ_k=",k,"run",r,".txt", sep = ""))
write(line.temp2.2, file = paste("Flock_IndQ_k=",k,"run",r,".txt", sep = ""),append=T)
}#over r
}#over k


#########################################################################################
#Use sed to paste in the file!
#sed '/INCLUDE/ r file' <in >out 
##sed '/INCLUDE/d' file >out 
#which file to insert


for (k in 2:6){
for (r in 1:6){
Flock.pop<- paste("Flock_PopQ_k=",k,"run",r,".txt",sep="") 
Flock.ind<-paste("Flock_IndQ_k=",k,"run",r,".txt",sep="") 
  
path<-paste("sed '/INSERT POP_Q HERE/ r ",Flock.pop,"' <StructOuput_skeleton_k=",k,".txt >Intermediate.txt",sep="")
system(path)
system("sed '/INSERT POP_Q HERE/d' 'Intermediate.txt' >Intermediate2.txt")

path2<- paste("sed '/INSERT IND_Q HERE/ r ",Flock.ind, "' <Intermediate2.txt >Intermediate3.txt",sep="")
system(path2)

output.file<- paste("StructOuput_genos_slg_pipe.txt_dat002_k00",k,"_Rep00",r,".txt_f",sep="")
path3<-paste("sed '/INSERT IND_Q HERE/d' 'Intermediate3.txt' >",output.file,sep="")
system(path3)
system("rm Inter*.txt")
}#runs
}#k
#tidy up the space


#Lets clean up the files that we aren't using anymore

# run a system command - Folder = Flock_PopQ
folder<-'Flock_PopQ'
system(paste0("mkdir ",folder))
String2pass<-paste('mv ',wd,'/Flock_PopQ_k=*run*.txt ',wd,'/Flock_PopQ',sep="")
system(String2pass)

# run a system command - Folder = 'Flock_IndQ'
folder<-'Flock_IndQ'
system(paste0("mkdir ",folder))
String2pass<-paste('mv ',wd,'/Flock_IndQ_k=*run*.txt ',wd,'/Flock_IndQ',sep="")
system(String2pass)

# run a system command - Folder = 'Flock-output-Formatted'
folder<-'Flock-output-Formatted'
system(paste0("mkdir ",folder))
String2pass<-paste('mv ',wd,'/StructOuput_genos_slg_pipe.txt_dat002_k00*_Rep00*.txt_f ',wd,'/Flock-output-Formatted',sep="")
system(String2pass)

#########################################################################################
#########################################################################################
#For CLUMP and Distruct we will need the names of each of the populations
#Extract Pop name and number
Names<-Flock_popq[,1]
length(Names)
Names<-str_split(Names,pattern="-")
NameMat<-matrix(data=NA,nrow=63,ncol=2)
for (n in 1:63){
  for (j in 1:2){
  NameMat[n,j]<-Names[[n]][j]
}
}
Names<-paste(formatC(x=NameMat[,1],width=2,flag="-"),formatC(x=NameMat[,2],width=4,flag="-"),sep=" ")
write(Names,file="Pops.txt")

##########################################################
# After running CLUMP and Distruct we can play with the output
# Here is a user defined function to compare the results from different
#flock and structure runs

Comp.runs<-function(k=k,Str.run=Str.run,Flock.run=Flock.run,greyscale=TRUE,FigOut='Fig2.eps'){
## Inputs
#k -> which k are we analyzing?
#Str.run -> which run from structure do we want to compare
#Flock.run -> which run from Flock do we want to compare
#greyscale -> do we want our plot to be greyscale or color?
#FigOut -> name the Figure... NOTE that the extension determines the type of file we use ggsave


# Extract the results from the files in some strings
q.str<-readLines(con=file.path("intermediate",paste("Output_00",k,".perms_",Str.run,sep="")))
q.floc<-readLines(con=file.path("intermediate",paste("Output_00",k,".perms_",Flock.run+6,sep="")))
#split the strings and put them into some matrices
q.str.string<-strsplit(q.str,split="[ ]+") # repeating spaces [ ]+
q.floc.string<-strsplit(q.floc,split="[ ]+")

#get rid of 0s from 1-999
for (r in 1:999){
q.str.string[[r]]<-q.str.string[[r]][2:(6+k)]
q.floc.string[[r]]<-q.floc.string[[r]][2:(6+k)]
}

# make a nice matrix with sample,flock q, structure q values
q.matrix<-matrix(data=NA, ncol=1+k*2,nrow=2596)

for (n in 1:length(q.str)){
for (j in 1:k){
  q.matrix[n,j]<-q.str.string[[n]][j+5]
  q.matrix[n,k+j]<-q.floc.string[[n]][j+5]
}
q.matrix[n,2*k+1]<-q.str.string[[n]][1]
}

#let's make the plot in ggplot
# we need a new matrix for ggplot, and it isn't easy just to melt the one we have
q.matrix.g<-matrix(data=NA,ncol=4,nrow=k*length(q.str))
colnames(q.matrix.g)<-c("k","Ind","Flock_q","Struct_q")
q.matrix.g[,1]<-rep(seq(from=1,to=k,by=1),times=length(q.str))
q.matrix.g[,2]<-rep(seq(from=1, to=length(q.str),by=1),each=k)
k.max<-k
  for (j in 1:k){#over clusters for every individual
    q.matrix.g[(seq(from=j,to=(length(q.str)*k.max)+(-k.max+j),by=k.max)),4]<-as.numeric(q.matrix[,j])#Structure Values
    q.matrix.g[(seq(from=j,to=(length(q.str)*k.max)+(-k.max+j),by=k.max)),3]<-as.numeric(q.matrix[,j+k.max])#Flock Values
  }#clusters & individuals
df<-data.frame(q.matrix.g)

if (greyscale==TRUE) {
p1 <- ggplot(data=df, aes(x=Flock_q, y=Struct_q, shape=factor(k))) +
  geom_point(alpha=0.5) +
  scale_shape_discrete(name="Cluster (k)") +
  theme_bw() +
  theme(legend.key = element_blank()) +
  theme(panel.grid=element_blank()) +
  theme(legend.position='bottom') +
  #theme(legend.background = element_rect(fill="gray95", size=.5, linetype="dotted")) +
  labs(y=expression(paste("Structure ", italic(q[i])," values",sep=""), "values",sep=" "),x=expression(paste("Flock ", italic(q[i])," values",sep=""))) +
  geom_abline(intercept=0, slope=1, linetype=2)
p1
} else {
  p1 <- ggplot(data=df, aes(x=Flock_q, y=Struct_q, shape=factor(k),color=factor(k))) +
    geom_point(alpha=0.5) +
    scale_shape_discrete(name="Cluster (k)") +
    scale_color_discrete(name="Cluster (k)") +
    theme_bw() +
    theme(legend.key = element_blank()) +
    theme(panel.grid=element_blank()) +
    theme(legend.position='bottom') +
    #theme(legend.background = element_rect(fill="gray95", size=.5, linetype="dotted")) +
    labs(y=expression(paste("Structure ", italic(q[i])," values",sep=""), "values",sep=" "),x=expression(paste("Flock ", italic(q[i])," values",sep=""))) +
    geom_abline(intercept=0, slope=1, linetype=2)
p1
} #end else
# export high res image
ggsave(plot=p1,filename=file.path(wd,FigOut),dpi=300,width=6,height=6,units='in')
} # End of Function 

Comp.runs(k=5,Str.run=1,Flock.run=5,greyscale=T,FigOut='Fig2.pdf')

######################################################################################
# Get STRUCTURE LnP(D) values and DeltaK
LnP<-matrix(data=NA,nrow=k.max-1,ncol=rep)
for (k in 2:k.max){
  for (r in 1:rep){
    # Read in the Structure pop-q information that we need for formating
    LnP.temp<-scan(file=file.path("Structure-Output",paste("StructOuput_genos_slg_pipe.txt_dat001_k00",k,"_Rep00",r,".txt_f",sep="")), what = "character", skip=(105+k+(k-2)),nlines=1)
    LnP[k-1,r]<-as.numeric(LnP.temp[7])
  }#over reps
}#over k
#Label things
colnames(LnP)<-paste(rep("Rep",times=rep),seq(from=1,to=rep,by=1),sep="")
rownames(LnP)<- paste(rep("K",times=k.max-1),seq(from=2,to=k.max,by=1),sep="")
#add mean
LnP.mean<- as.vector(rowMeans(LnP))
LnP<-cbind(LnP,LnP.mean)
#add stdev
LnP.sd<-vector()
for (sd in 1:k.max-1){
  LnP.sd[sd]<-sqrt(var(LnP[sd,(1:k.max)]))
}
LnP<-cbind(LnP,LnP.sd)

#K'
K_prime<-vector()
K_prime[1]<-NA
for (k in (1:(k.max-2))){
  K_prime[(k+1)]<-LnP[(k+1),7]-LnP[k,7]
}
LnP<-cbind(LnP,K_prime)

#k''
K_2prime<-as.vector(rep(NA,times=(k.max-1)))
for (k in (1:(k.max-3))){
  K_2prime[(k+1)]<-abs(LnP[(k+2),9]-LnP[k+1,9])
}
LnP<-cbind(LnP,K_2prime)

#DeltaK
Delta_K<-as.vector(LnP[,10]/LnP[,8])
LnP<-cbind(LnP,Delta_K)


# Make some graphs!
LnP.df<-as.data.frame(LnP)
p2<- qplot(x = seq(from=2,to=k.max,by=1), y = LnP.mean, data = LnP.df,xlab="K",ylab='L(K)') +
  theme_bw() + geom_line()+
  geom_errorbar(width=.05, aes(ymin=LnP.mean-LnP.sd, ymax=LnP.mean+LnP.sd), colour="black") 
p3 <- qplot(x = seq(from=2,to=k.max,by=1), y = K_prime, data = LnP.df,xlab="K",ylab="L(K')") +
  theme_bw() + geom_line()
p4<- qplot(x = seq(from=2,to=k.max,by=1), y = K_2prime, data = LnP.df,xlab="K",ylab="L(K'')") +
  theme_bw() +geom_line()
p5<-qplot(x = seq(from=2,to=k.max,by=1), y = Delta_K, data = LnP.df,xlab="K",ylab="Delta K") +
  theme_bw() + geom_line()
#### Multiplot function from
#### http://www.peterhaschke.com/r/2013/04/24/MultiPlot.html
multiplot <- function(..., plotlist = NULL, file, cols = 1, layout = NULL) {
  require(grid)
  
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  if (is.null(layout)) {
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots == 1) {
    print(plots[[1]])
    
  } else {
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    for (i in 1:numPlots) {
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
###########################################################################################

multiplot(p2,p4,p3,p5,cols=2)
