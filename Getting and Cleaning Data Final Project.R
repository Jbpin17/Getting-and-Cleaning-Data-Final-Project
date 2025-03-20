path <- getwd()
sapply(packages, require, character.only=TRUE, quietly=TRUE)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

#Loading Labels
Labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names=c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names=c("index", "featureNames"))
features_wanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[features_wanted, featureNames]
measurements <- gsub('[()]', '', measurements)

#Loading Trained Data
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, features_wanted, with=FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivites <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"),
                        col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"),
                       col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivites, train)

#Loading Test Data
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, features_wanted, with=FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names= c("SubjectNum"))

test <- cbind(testSubjects, testActivities, test)

#Combining Data
combine <- rbind(train, test)


combine[["Activity"]] <- factor(combine[, Activity],
                                levels = Labels[["classLabels"]],
                                labels = Labels[["activityName"]])
combine[["SubjectNum"]] <- as.factor(combine[, SubjectNum])
combine <- reshape2::melt(data = combine, id = c("SubjectNum", "Activity"))
combine <- reshape2::dcast(data = combine, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combine, file = "tidyData.txt", quote = FALSE)