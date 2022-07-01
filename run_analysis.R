##run_analysis.R:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##Install necessary packages, if not already installed
if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("dplyr")) {
  install.packages("dplyr")
}

require("data.table")
require("dplyr")

##Read data
test_data <- read.table("./UCI HAR Dataset/test/X_test.txt")
train_data <- read.table("./UCI HAR Dataset/train/X_train.txt")
var_labels <- read.table("./UCI HAR Dataset/features.txt")
test_subjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_subjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")

##Read activity labels (as numbers)
test_activity <- read.table("./UCI HAR Dataset/test/y_test.txt")
train_activity <- read.table("./UCI HAR Dataset/train/y_train.txt")

##Merge "test_subjects" with "train_subjects"
subjects <- rbind(test_subjects, train_subjects)

##Merge the "test" and "train" datasets
data <- rbind(test_data, train_data)

##Merge activity labels (as numbers)
activities <- rbind(test_activity, train_activity)

##Rename variables
library(data.table)
subjects <- setnames(subjects, "V1", "Subject")
data <- setnames(data, names(data), var_labels$V2)

##Find variables with "mean" or "std"
mean_or_std <- grep("mean|std", names(data))

##Select only columns with "mean" or "std"
library(dplyr)
data_select <- select(data, mean_or_std)

##Convert numbers to descriptive activity labels
activity_codes <- c("walking" = 1, "walking upstairs" = 2, "walking downstairs" = 3, 
				"sitting" = 4, "standing" = 5, "laying" = 6)
Activity <- names(activity_codes)[match(activities$V1, activity_codes)]

##Merge activity labels with "alldata_select" and convert to tibble
combined_data <- tbl_df(cbind(subjects, Activity, data_select))

##Melt data
id_labels <- c("Subject", "Activity")
data_labels <- setdiff(colnames(combined_data), id_labels)
melt_data <- melt(combined_data, id = id_labels, measure.vars = data_labels)

##Create independent tidy data set with the average of each variable for each activity and each subject
tidy_data <- dcast(melt_data, Subject + Activity ~ variable, mean)

##Print tidy data set to a file
write.table(tidy_data, file = "./tidy_data.txt", row.name=FALSE)