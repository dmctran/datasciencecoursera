## Assumptions:
## 1. The Samsung data is in the working directory, ie the working directory contains
##     the directory "UCI HAR Dataset" and its files and sub-directories as specified in the
##     dataset's README.txt
runAnalysis <- function(outputFileName = "tidydata.txt") {
    # non-base package requirement
    require(plyr)
    
    # set up directory names
    baseDir <-  file.path(getwd(), "UCI HAR Dataset")
    featuresFileName <- file.path(baseDir, "features.txt")
    
    # read features file to be used as data (column) labels
    features <- read.table(featuresFileName, as.is = TRUE)
    dataLabels <- features[,2]
    
    # Implementation of step 1 & 4
    # 
    # row-merge test and train datasets
    # the merged dataset has columns with position as follows:
    #   1: subject
    #   2: activity
    #   3-563 : 561-feature vector 
    mergedData <- rbind(getDataSet("test", dataLabels, baseDir), 
                        getDataSet("train", dataLabels, baseDir))
    
    # Implementation of step 2
    # 
    # The aim is to get a data set which contains: subject, activity, mean and standard deviation data.
    # 
    # 1, 2 are column indices for subject and activity columns
    # As noted in the UCI HAR Dataset/features_info.txt, mean() and std() are Mean and Standard deviation
    # values, respectively.  Find index of columns with name contain "mean(", "std("
    # 
    filteredCols <- c(1, 2, which(grepl("(mean\\(|std\\()", names(mergedData), ignore.case = TRUE)))
    data <- mergedData[, filteredCols]
    
    # Implementation of step 3
    activityLabelsFileName <- file.path(baseDir, "activity_labels.txt")
    activityLabels <- read.table(activityLabelsFileName, as.is = TRUE)
    data$activity <- factor(data$activity, levels = activityLabels[, 1], labels = activityLabels[, 2])
    
    # Implementation of step 4
    # 
    # Done in step 1 - Leave the label to match the features so it can be easily cross-checked/related
    # to the original data if required
    
    # Implementation of step 5
    # 
    startCol = 3
    endCol = ncol(data)
    data2 <- ddply(data, .(subject, activity), 
                            function(x, startCol = 3, endCol = 68) {
                                colMeans(x[, startCol : endCol])
                            }, startCol = startCol, endCol = endCol
                   )
    
    write.table(data2, file.path(getwd(), outputFileName), row.names = FALSE)
}

## This function reads related files (subject_{}.txt, X_{}.txt, and y_{}.txt) 
## for a set (ie test or train), column-merge them together to form a single data set.
## Inertial Signals data are not read because these data will not be used anyway 
## (Point 2 of the instruction: 
##  Extracts only the measurements on the mean and standard deviation for each measurement.)
getDataSet <- function(setName, dataLabels, baseDir = "") {
    # subject data
    subjectFileName <- file.path(baseDir, setName, paste0("subject_", setName, ".txt"))
    subjectData <- read.table(subjectFileName, as.is = TRUE);
    names(subjectData) <- "subject"
    
    # 561-feature vector with time and frequency domain variables
    # labels are taken from features.txt
    xFileName <- file.path(baseDir, setName, paste0("X_", setName, ".txt"))
    xData <- read.table(xFileName, as.is = TRUE)
    names(xData) <- dataLabels
    
    # activity
    yFileName <- file.path(baseDir, setName, paste0("y_", setName, ".txt"))
    yData <- read.table(yFileName, as.is = TRUE);
    names(yData) <- "activity"
    
    # column-merge: subject, activity, 561-feature vector
    # the labels for 561-feature vector are taken from features.txt
    data <- cbind(subjectData, yData, xData)
}