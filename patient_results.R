# Average across all PSA results for patient
# 
# Author: Miqdad Asaria 
# Date: 2014 
###############################################################################

source("format_results.R")

args = commandArgs(trailingOnly=TRUE)
patient_number = as.numeric(args[1])
num_iterations = as.numeric(args[2])
patient_group = as.character(args[3])

if(is.na(patient_number)){
	patient_number = 1
	print(paste("patient not provided setting to default patient: ", patient_number, sep=""))
}
if(is.na(num_iterations)){
	num_iterations = 1000
	print(paste("number of iterations not provided setting to default: ", num_iterations, sep=""))
}
if(is.na(patient_group)){
	patient_group = "clinical"
	print(paste("patient group not provided setting to default group: ", patient_group, sep=""))
}

summarise_ce_results(patient_number, num_iterations, patient_group)
