# run_analysis.R
## Description
This file produces a tidy dataset based on the dataset of Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012.  

The dataset is obtained via https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.  
Subsequently, this dataset is referred to as the *original* dataset.

## Tidy dataset
The tidy (subsequently referred to as *tidy*) dataset produced by this script contains the average of the mean and standard deviation measurements for each activity and each subject found in the *original* dataset.

### Prerequisites
* The original dataset is unzipped into the directory *"UCI HAR Dataset"*
* The directory *"UCI HAR Dataset"* is found under the working directory

### Producing the tidy dataset
1. source("path_to_/run_analysis.R")
2. setwd("path_to_directory_which_contain_UCI HAR Dataset_directory")
3. runAnalysis("output_file_name")

where *output_file_name* is the name of the file where the tidy data is written to.  
Default is *tidydata.txt* if the *output_file_name* is not specified
    
The output file is found under the working directory

### Reading in the tidy dataset
Execute *read.table("file_name", header = TRUE)*

### How *runAnalysis* works
* First read *features.txt*.  The feature names are to be used as data labels in later steps
* The *merged-test* dataset is produced by:
    + reading in *subject_test.txt* (subject)
    + reading in *X_test.txt* (measurements)
    + reading in *y_test.txt* (activity)
    + column-merged the 3 datasets above; setting subject data as the first column, activity data as the second column,
        and subsequent columns are from measurements data
    + label merged dataset as follows: *"subject"* for the first column, *"activity"* for the second column, 
        561-feature labels read in from file *features.txt* for columns 3-563
    + label are assigned this way, especially the features from *features.txt*, so that the mean and 
        standard deviation measurements can be identified
    + *getDataSet* function is written to perform this process
* The *merged-train* dataset is produced using the train files (*subject_train.txt*, *X_train.txt*, *y_train.txt*) 
in the same was as the *merged-test* dataset, using *getDataSet* function
* Row-merge the *merged-test* and *merged-train* datasets into a single dataset (subsequently referred to as *merged* dataset)
* Based on the *original* dataset's *features_info.txt* file, features with *mean()* and *std()* are Mean and Standard deviation values, respectively, of the measured signals.  So, to extract the mean and standard deviation measures, search column names of the *merged* dataset which contain *mean(*, *std(*
* Produce a new dataset by subsetting the *merged* dataset using *subject*, *activity* columns, 
and the columns found in the previous step.  This new dataset is subsequently refered to as the *mean_and_std* dataset
* Label (data in) the *activity* column of the *mean_and_std* dataset (as factors) using the data read from file *activity_labels.txt*
* Produce a new (*tidy*) dataset which contains the average values for each *subject*, *activity*, using the *ddply* function
from the *plyr* package.  The important implementation is the inline function - the parameter value of *.fun* paramter of the *ddply* function.  
By specify *subject*, *activity* as the key variable in argument of *ddply*, *ddply* gives the function - parameter value of its
*.fun* parameter - only the rows for a unique combination of *subject*, *activity*.  Average values (for data, ie column 3 - 563) can be easily calculated using *colMeans*
* Finally, write *tidy* data to a file in the working directory.  Column labels are kept the same as feature labels so that
average values can be easily related to (the *original* dataset)
