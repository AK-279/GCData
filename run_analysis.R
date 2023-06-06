## - Please note that for various steps, I have looked at multiple examples online, understood how others have done it and then built my own code
## Basic housekeeping block/steps - Good habit to always remember to initiate packages using library function
library(dplyr)
library(data.table)

## First Step - Download the requisite files from the given weblink, and process them to understand the underlying data

path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path,"GCData-assignment.zip"))
unzip(zipfile = "GCData-assignment.zip")

## Second step - Look into the data in the working directory and understand the data in the files. From Readme file, there are 5 broad categories - Features info, Features labels, Training/ Test set, Training / Test labels
## Reading the respective files using read.table; first look for column labels etc

Labels_Activity <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE) ## Getting activity labels
Names_Features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE) ## Getting Feature names

## Next, read.table for both test and train sets looking for data, Activity, subject and features

Test_Activity <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
Train_Activity <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)

Test_Subject <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
Train_Subject <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)

Test_Features <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
Train_Features <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)

## Merging the above apples to apples data from test and train sets

Data_Activity <- rbind(Test_Activity, Train_Activity)
Data_Subject <- rbind(Test_Subject, Train_Subject)
Data_Features <- rbind(Test_Features, Train_Features)

## Fixing Names for readability

names(Data_Activity) <- "Activity_N"
names(Labels_Activity) <- c("Activity_N", "Activity")

## Finding factor of Activity names
Activity <- left_join(Data_Activity, Labels_Activity, "Activity_N")[, 2]

##Same process for others
names(Data_Subject) <- "Subject"
names(Data_Features) <- Names_Features$V2

##Compiling the details to setup a combined Dataset and then taking only mean and sd
Data_Set1 <- cbind(Data_Subject, Activity)
Data_Set1 <- cbind(Data_Set1, Data_Features)

Names_subFeatures <- Names_Features$V2[grep("mean\\(\\)|std\\(\\)", Names_Features$V2)]
DataNames <- c("Subject", "Activity", as.character(Names_subFeatures))
Data_Set1 <- subset(Data_Set1, select=DataNames)

## Another independent tidy data set with the average of each variable for each activity and each subject
Data_Set2<-aggregate(. ~Subject + Activity, Data_Set1, mean)
Data_Set2<-Data_Set2[order(Data_Set2$Subject,Data_Set2$Activity),]

#Saving to local file
write.table(Data_Set2, file = "Data_Set2_tidydata.txt",row.name=FALSE)
