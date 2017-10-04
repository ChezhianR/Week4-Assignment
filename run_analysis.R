	##Download Files
	
	if(!file.exists("./data"))
	{
		dir.create("./data")
	}

	download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./data/Dataset.zip")

	##unzip files 

	unzip(zipfile="./data/Dataset.zip",exdir="./data")
	ref_path <- file.path("./data" , "UCI HAR Dataset")
	files<-list.files(ref_path, recursive=TRUE)

	##Load Datas 
	TestActivitydata  <- read.table(file.path(ref_path, "test" , "Y_test.txt" ),header = FALSE)
	TrainActivitydata <- read.table(file.path(ref_path, "train", "Y_train.txt"),header = FALSE)
	TrainSubjectdata <- read.table(file.path(ref_path, "train", "subject_train.txt"),header = FALSE)
	TestSubjectdata  <- read.table(file.path(ref_path, "test" , "subject_test.txt"),header = FALSE)
	TestFeaturesdata  <- read.table(file.path(ref_path, "test" , "X_test.txt" ),header = FALSE)
	TrainFeaturesdata <- read.table(file.path(ref_path, "train", "X_train.txt"),header = FALSE)
	
	##Combine Datas
	Subjectdata <- rbind(TrainSubjectdata, TestSubjectdata)
	Activitydata<- rbind(TrainActivitydata, TestActivitydata)
	Featuresdata<- rbind(TrainFeaturesdata, TestFeaturesdata)

	names(Subjectdata)<-c("subject")
	names(Activitydata)<- c("activity")
	FeaturesdataNames <- read.table(file.path(ref_path, "features.txt"),head=FALSE)
	names(Featuresdata)<- FeaturesdataNames$V2

	Comineddata <- cbind(Subjectdata, Activitydata)
	FinalData <- cbind(Featuresdata, Comineddata)
	 

	##Extracts only the measurements on the mean and standard deviation for each measurement
	subFeaturesdataNames<-FeaturesdataNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesdataNames$V2)]

	selectedNames<-c(as.character(subFeaturesdataNames), "subject", "activity" )
	FinalData<-subset(FinalData,select=selectedNames)

	##Uses descriptive activity names to name the activities in the data set
	str(FinalData)
	activityLabels <- read.table(file.path(ref_path, "activity_labels.txt"),header = FALSE)

	head(FinalData$activity,30)

	##Appropriately labels the data set with descriptive variable names
	names(FinalData)<-gsub("^t", "time", names(FinalData))
	names(FinalData)<-gsub("^f", "frequency", names(FinalData))
	names(FinalData)<-gsub("Acc", "Accelerometer", names(FinalData))
	names(FinalData)<-gsub("Gyro", "Gyroscope", names(FinalData))
	names(FinalData)<-gsub("Mag", "Magnitude", names(FinalData))
	names(FinalData)<-gsub("BodyBody", "Body", names(FinalData))
	
	##Creates a second,independent tidy data set and ouput it
	names(FinalData)
	library(plyr);
	Data2<-aggregate(. ~subject + activity, FinalData, mean)
	Data2<-Data2[order(Data2$subject,Data2$activity),]
	write.table(Data2, file = "tidydata.txt",row.name=FALSE)