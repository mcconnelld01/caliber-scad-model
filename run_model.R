# Run the model based on arguments passed in from the command line using Rscript
# 
#  Author: Miqdad Asaria
# Date: 2014
####################################################################################
start_time = proc.time()
source("markov_model.R")

args = commandArgs(trailingOnly=TRUE)
pat = as.numeric(args[1])
iter = as.numeric(args[2])
patient_group = as.character(args[3])
patient_file = ""

if(is.na(pat)){
	pat = 1
	print(paste("patient not provided setting to default patient: ", pat, sep=""))
}
if(is.na(iter)){
	iter = -1
	print(paste("iteration number not provided setting to default deterministic: ", iter, sep=""))
}
if(is.na(patient_group)){
	patient_group = "clinical"
	print(paste("patient group not provided setting to default group: ", patient_group, sep=""))
} else if (patient_group=="manual") {
	# load patient characteristics from disk
	patient_file = as.character(args[4])	
}

run_model(pat, iter, patient_group, patient_file, life_tables_only=FALSE)

end_time = proc.time()
print(paste("total run time: ",round((end_time["elapsed"]-start_time["elapsed"])/60,2)," mins", sep=""))
