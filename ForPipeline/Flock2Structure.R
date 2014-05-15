######Code for Converting Flock pop Q values to Structure formated pop - Q values
######Written for Flock Comment with Eric Anderson

###### Note: individuals parts of the code rely on Java and should be run individually 
###### If they are all run together you will probably experience a heap error. 

### packages that we will need that probably aren't installed
install.packages("XLConnect")
install.packages("stringr")

### 
require("XLConnect")
require("stringr")

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
temp.string<-function(k){
  #need a clever way of repeating stuff inside of a formating loop
  #this way I don't have to copy and paste for all k
  string<- vector()
  for (i in 3:(k+1)){
    string[i]<-paste('(formatC(Mpopq.str[,',i, '],width=7,flag=','"+"','))',sep="")
  }
  string<-string[-(1:2)]
  string<-paste(string,collapse=",")
  return(string)
}

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
# This will produce some text files will the correct formating to 
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

# Let's tidy up the space and put them in a folder 
# run a system command - Folder = Flock PopQ
folder<-'Flock\" \"PopQ'
system(paste0("mkdir ",folder))
String2pass<-paste('mv ',wd,'/Flock_PopQ_k=*run*.txt ',wd,'/Flock\" \"PopQ',sep="")
system(String2pass)

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

# Let's tidy up the space and put them in a folder 
# run a system command - Folder = 'Flock IndQ'
folder<-'Flock\" \"IndQ'
system(paste0("mkdir ",folder))
String2pass<-paste('mv ',wd,'/Flock_IndQ_k=*run*.txt ',wd,'/Flock\" \"IndQ',sep="")
system(String2pass)

#########################################################################################

#Now here you have to manually paste in the flock popq and indq values into 
#The correct location of the Structure output so that Clump and Distruct 
#can do their thing. 

#If I wanted to write some script one way of doing it would be to split the original 
#Structure output into 3 sections: Before the popq values, between popq and indq 
# and after the indq values. I would convert each of those to strings and then 
# paste all the bits and pieces together. 

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
# Lets look at certainty of assignment
#lets start by pulling two that should look really similar 
# Read in the clumped files -> clump files should be reorganized.
k<-5 #which k are we analyzing?
#which runs do we want to compare
Str.run<-1
Flock.run<-5
# Extract the results from the files in some strings
q.str<-readLines(con=file.path("intermediate",paste("Output_00",k,".perms_",Str.run,sep="")))
q.floc<-readLines(con=file.path("intermediate",paste("Output_00",k,".perms_",Flock.run+6,sep="")))
#split the strings and put them into some matrices
q.str.string<-strsplit(q.str,split="[ ]+") # repeating spaces [ ]+
q.floc.string<-strsplit(q.floc,split="[ ]+")
head(q.str.string)
head(q.floc.string)

#get rid of 0s from 1-999
for (r in 1:999){
q.str.string[[r]]<-q.str.string[[r]][2:(6+k)]
q.floc.string[[r]]<-q.floc.string[[r]][2:(6+k)]
}

# make a nice matrix with sample,flock q, structure q values
q.matrix<-matrix(data=NA, ncol=1+k*2,nrow=2596)

for (n in 1:2596){
for (j in 1:k){
  q.matrix[n,j]<-q.str.string[[n]][j+5]
  q.matrix[n,k+j]<-q.floc.string[[n]][j+5]
}
q.matrix[n,2*k+1]<-q.str.string[[n]][1]
}
write.csv(q.matrix,"Qval.csv",eol = "\r\n")

par(mfrow=c(1,1))
plot(q.matrix[,k+1],q.matrix[,1],xlab="Q-val Flock",ylab="Q-val Structure",col="Dark Green")
abline(0,1)
points(q.matrix[,k+2],q.matrix[,2],col="Blue")
points(q.matrix[,k+3],q.matrix[,3],col="Orange")
points(q.matrix[,k+4],q.matrix[,4],col="Hot Pink")
points(q.matrix[,k+5],q.matrix[,5],col="Yellow2")
#plot(q.matrix[,k+6],q.matrix[,6],xlab="Q-val Flock",ylab="Q-val Structure",col="Purple")
#abline(0,1)

