## Getting and Cleaning Data Course project
##=========================================

library(dplyr)
library(data.table)

##1. Merges the training and the test sets to create one data set.

data_X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
data_X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
data <- rbind(data_X_test, data_X_train)

## merge activities's data

data_y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
data_y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
data_activities <- rbind(data_y_test, data_y_train)

## data contains 561 names of data X_test and X_train

data_names <- read.table("./UCI HAR Dataset/features.txt")

## data of the 6 activities with their number ID.

data_ID_activities <- read.table("./UCI HAR Dataset/activity_labels.txt")

data_activities_testtrain <- merge(data_activities, data_ID_activities, by="V1")

## merge data subject test and train

data_subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
data_subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
data_subject <- rbind(data_subject_test, data_subject_train)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.

names(data)=data_names[,2]
column_names <- make.names(names(data), unique=TRUE)
names(data) <- column_names
data_mean_std <- select(data,contains("mean"), contains("std"), -contains("Freq"), -contains("angle"))

## 3. Uses descriptive activity names to name the activities in the data set

finaldata<-cbind(data_activities_testtrain$V2, data_mean_std)
colnames(finaldata)<-c("activities", names(data_mean_std))

## 4. Appropriately labels the data set with descriptive variable names.

names(finaldata) <- gsub("Acc", "Accelerator", names(finaldata))
names(finaldata) <- gsub("Mag", "Magnitude", names(finaldata))
names(finaldata) <- gsub("Gyro", "Gyroscope", names(finaldata))
names(finaldata) <- gsub("^t", "time", names(finaldata))
names(finaldata) <- gsub("^f", "frequency", names(finaldata))

## 5. From the data set in step 4, creates a second, independent tidy data set
## with the average of each variable for each activity and each subject.

data2<-cbind(data_subject, finaldata)
colnames(data2)<-c("subjects",names(finaldata))

data2_tablet <- data.table(data2)
tidyData<-data2_tablet[ ,lapply(.SD,mean), by="activities,subjects"]
write.table(tidyData, file = "./tidyData.txt", row.names=FALSE)