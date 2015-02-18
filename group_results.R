# Combines patient results summaries to produce final tables and figures for paper
# 
# Author: Miqdad Asaria
# Date: 2014
####################################################################################

source("format_results.R")

args = commandArgs(trailingOnly=TRUE)
num_pat = as.numeric(args[1])
patient_group = as.character(args[2])
patient_file = ""

if(is.na(num_pat)){
	num_pat = 10
	print(paste("patient not provided setting to default patient: ", num_pat, sep=""))
}
if(is.na(patient_group)){
	patient_group = "deciles"
	print(paste("patient group not provided setting to default group: ", patient_group, sep=""))
} else if (patient_group=="manual") {
	# load patient characteristics from disk
	patient_file = as.character(args[3])	
}

cycle_length_days = 90

summarise_psa_results(num_pat,patient_group,patient_file)
generate_markov_trace_plots(num_pat,cycle_length_days,patient_group,patient_file)
generate_max_price_plots(num_pat,patient_group,patient_file)