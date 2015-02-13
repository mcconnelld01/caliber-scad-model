# Average across all PSA results for patient
# 
# Author: Miqdad Asaria 
# Date: 2014 
###############################################################################

summarise_ce_results = function(patient_number, num_iterations, patient_group){
	print(paste("summarising results for patient:", patient_number, " over ", num_iterations, " iterations for patient group: ", patient_group ,sep=""))
	cycle_length_days = 90
	iteration_number = 1
	iteration_count = 1
	total_results = read.csv(file=paste("output/model_results/",patient_group,"/ce_results_pat_",patient_number,"_iteration_",iteration_number,".csv",sep=""))
	summary_results = total_results[nrow(total_results),]
	summary_results[1,grep("^cycle",colnames(total_results))] = colSums(total_results[,grep("^cycle",colnames(total_results))])*cycle_length_days/365
	summary_results[1,grep("^fe_",colnames(summary_results))] = summary_results[,grep("^fe_",colnames(summary_results))]*100
	summary_results[1,grep("^fatal_",colnames(summary_results))] = summary_results[,grep("^fatal_",colnames(summary_results))]*100
	for(iteration_number in 2:num_iterations){
		filename=paste("output/model_results/",patient_group,"/ce_results_pat_",patient_number,"_iteration_",iteration_number,".csv",sep="")
		if(file.exists(filename)){
			iter_results = read.csv(file=filename)
			iter_summary_results = iter_results[nrow(iter_results),]
			iter_summary_results[1,grep("^cycle",colnames(iter_results))] = colSums(iter_results[,grep("^cycle",colnames(iter_results))])*cycle_length_days/365
			iter_summary_results[1,grep("^fe_",colnames(iter_summary_results))] = iter_summary_results[,grep("^fe_",colnames(iter_summary_results))]*100
			iter_summary_results[1,grep("^fatal_",colnames(iter_summary_results))] = iter_summary_results[,grep("^fatal_",colnames(iter_summary_results))]*100
			summary_results = rbind(summary_results,iter_summary_results)
			total_results = total_results + iter_results
			iteration_count = iteration_count + 1
		} else {
			print(paste("file not found: ", filename,sep=""))
		}
	}
	total_results = total_results[,-1]/iteration_count
	summary_results = summary_results[,-1]
	psa_summary = t(rbind(apply(summary_results,2,mean),apply(summary_results,2,sd),apply(summary_results,2,quantile,probs=c(0,0.025,0.25,0.5,0.75,0.975,1))))
	colnames(psa_summary)  = c("mean","se",colnames(psa_summary)[-c(1,2)])
	write.csv(total_results,file=paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_mean_probabilistic.csv",sep=""))
	write.csv(summary_results,file=paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_PSA.csv",sep=""))
	write.csv(psa_summary,file=paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_PSA_summary.csv",sep=""))
}


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
