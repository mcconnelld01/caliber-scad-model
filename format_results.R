# Average across all PSA results for patients and produce display items for paper
# 
# Author: Miqdad Asaria 
# Date: 2014 
###############################################################################
library(ggplot2)
library(scales)
library(gridExtra)
library(reshape2)

source("markov_model.R")

format_results = function(r){
	accuracy = 2
	if(r[1]>100){
		accuracy = 0
	}
	return(paste(format(round(r[1],accuracy),big.mark=",")," (", format(round(r[2],accuracy),big.mark=",")," to ",format(round(r[3],accuracy),big.mark=","),")",sep=""))
}

summarise_psa_results = function(num_patients, patient_group, patient_file=""){
	for(patient_number in 1:num_patients){
		total_results = read.csv(file=paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_PSA_summary.csv",sep=""),row.names=1)
		if(patient_number == 1){
			overall_summary = apply(total_results[,c(1,4,8)],1,format_results)
			simple_summary = total_results[,"mean"]
		} else {
			overall_summary = rbind(overall_summary,apply(total_results[,c(1,4,8)],1,format_results))
			simple_summary = rbind(simple_summary,total_results[,"mean"])
		}
	}
	if(patient_group != "manual"){
		patient_names = seq(1:num_patients)
	} else {
		patient_names = row.names(read.csv(patient_file,row.names=1))
	}
	rownames(overall_summary) = patient_names
	colnames(overall_summary) = rownames(total_results)
	rownames(simple_summary) = patient_names
	colnames(simple_summary) = rownames(total_results)
	write.csv(t(overall_summary),file=paste("output/model_summary/",patient_group,"/ce_results_all_patients_PSA_summary_formatted.csv",sep=""))
	write.csv(t(simple_summary),file=paste("output/model_summary/",patient_group,"/ce_results_all_patients_PSA_summary.csv",sep=""))
	
}

generate_markov_trace_plots = function(num_patients, cycle_length_days, patient_group, patient_file=""){
	markov_plots = vector("list", num_patients)
	
	if(patient_group=="manual"){
		patient_names = row.names(read.csv(patient_file,row.names=1))
	} else {
		patient_names = c("lowest risk",2:(num_patients-1),"highest risk")
	}
	
	for(patient_number in 1:num_patients){
		results = read.csv(file=paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_mean_probabilistic.csv",sep=""),row.names=1)[,c(1,2,3,4,8,9)]
		colnames(results) = c("Event Free","MI","Ischaemic Stroke","Haemorrhagic Stroke","Fatal CVD","Fatal non-CVD")		
		results$years = (1:nrow(results))*cycle_length_days/365
		graph_data = melt(results,id=c("years"))
		graph_data$risk = patient_names[patient_number]
		colnames(graph_data) = c("years","State","population","Risk_Decile")
		markov_plots[[patient_number]] = graph_data	
	}
	
	graph_data = do.call("rbind", markov_plots)
	graph_data$Risk_Decile = factor(graph_data$Risk_Decile, levels=patient_names)
	markov_plot = ggplot(graph_data, aes(years,population)) +
			geom_area(aes(colour=State, fill=State), position="Stack") + 
			xlab("Years from Cohort Entry") +
			ylab("Proportion of Population") + 
			scale_fill_grey(name="Model State") +
			scale_color_manual(values=rep("#000000",ncol(results)),name="Model State") +
			theme_minimal() + 
			facet_wrap( ~ Risk_Decile, nrow=2)
	
	ggsave(filename=paste("output/model_summary/",patient_group,"/markov_trace.pdf",sep=""),plot=markov_plot,width=27,height=19,units="cm")
	ggsave(filename=paste("output/model_summary/",patient_group,"/markov_trace.png",sep=""),plot=markov_plot,width=27,height=19,units="cm",dpi=300)
	
}

calculate_fe_5yr_risk = function(patient, survival_params){
	ci = calculate_competing_risks_model(survival_params,patient,5,10, 1, treatment_HR = 1, scenario = "basecase")
	fe_5yr_risk = ci$fe_mi[1825,2] + ci$fe_stroke_i[1825,2] + ci$fe_stroke_h[1825,2] + ci$fe_fatal_cvd[1825,2]
	return(fe_5yr_risk)
}

generate_max_price_plots = function(num_patients, patient_group, patient_file=""){
	all_data = read.csv(file=paste("output/model_summary/",patient_group,"/ce_results_all_patients_PSA_summary.csv",sep=""), row.names=1)
	
	load("CALIBER_SCAD_params.RData")
	
	if(patient_group == "deciles"){
		patients = patients_deciles
		patient_names = c("lowest risk",2:(num_patients-1),"highest risk")
	} else if(patient_group == "clinical"){
		patients = patients_clinical
		patient_names = c("lowest risk",2:(num_patients-1),"highest risk")
	} else if(patient_group == "manual"){
		patients = list()
		for(p in 1:num_patients){
			patients[[p]] = load_patient(patient_file, p)
		}
		patient_names = row.names(read.csv(patient_file,row.names=1))
	}
	
	fe_5yr_prob = rep(0,num_patients)
	for(p in 1:num_patients){
		if(patient_group == "deciles"){
			fe_5yr_prob[p] = patients[[p]][1,"ci_fe"]
		} else {
			fe_5yr_prob[p] = calculate_fe_5yr_risk(patients[[p]], survival_params)
		}
	}
	
	scenarios = c("fe_cvd")	
	HRs = c(0.9,0.8,0.7,0.6)
	HR_labs = paste((1-HRs)*100,"%",sep="") 
	thresholds = c(10000,20000,30000,40000)
	
	max_prices = list()
	
	for(scenario in scenarios){
		for(HR in HRs){
			for(threshold in thresholds){
				name = paste(scenario,HR,sep="_")
				nmb = ((all_data[paste("qalys_const_",name,sep=""),1:num_patients]-all_data["qalys_const_basecase_1",1:num_patients])*threshold -  (all_data[paste("total_costs_",name,sep=""),1:num_patients]-all_data["total_costs_basecase_1",1:num_patients])) 
				max_price = nmb/all_data[paste("cycle_SCAD_",name,sep=""),1:num_patients]
				max_prices[[paste(name,threshold,sep="_")]] = t(rbind(1:num_patients,fe_5yr_prob,max_price,gsub("_"," ",paste(toupper(scenario)," ",(1-HR)*100,"%",sep="")),paste("Threshold = \u00A3",formatC(threshold,format="d",big.mark=",")," per QALY",sep="")))
			}
		}
	}
	
	graph_data = do.call("rbind", max_prices)
	colnames(graph_data) = c("patient","fe_5yr_risk","max_price","scenario","threshold")
	rownames(graph_data) = NULL
	graph_data = as.data.frame(graph_data, stringsAsFactors=FALSE)
	graph_data$patient = as.factor(as.numeric(graph_data$patient))	
	levels(graph_data$patient) = patient_names
	graph_data$fe_5yr_risk = as.numeric(graph_data$fe_5yr_risk)	
	graph_data$max_price = as.numeric(graph_data$max_price)	
	graph_data$scenario = as.factor(graph_data$scenario)	
	
	legend_title = "Treatment effect\n(hazard reduction)\non a typical\ncomposite trial\nendpoint of\nMI/stroke and\nCVD death"
	
	max_price_bar_plot = ggplot(graph_data, aes(x=patient,y=max_price,fill=scenario)) + 
			geom_bar(position="dodge", stat="identity") +
			scale_fill_grey(name=legend_title, labels=HR_labs) +
			xlab("Risk Group") + 
			ylab(enc2utf8("Maximum Annual Price (\u00A3)")) +
			scale_y_continuous(labels=comma)+#,breaks=seq(0,max(graph_data$max_price + 100),100)) +
			theme_bw() +
			theme(legend.position="right", panel.margin = unit(1.5, "lines")) + 
			facet_wrap( ~ threshold, ncol=2, scales="free")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price_bars.pdf",sep=""),plot=max_price_bar_plot,width=29,height=20,units="cm")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price.png",sep=""),plot=max_price_bar_plot,width=29,height=20,units="cm",dpi=300)
	
	max_price_line_plot = ggplot(graph_data, aes(x=fe_5yr_risk,y=max_price)) + 
			geom_line(aes(colour=scenario,linetype=scenario)) +
			geom_point(aes(shape=scenario)) +
			scale_colour_grey(name=legend_title, labels=HR_labs) +
			scale_linetype_discrete(name=legend_title, labels=HR_labs) +
			scale_shape_discrete(name=legend_title, labels=HR_labs) +
			xlab("Five Year CVD Event Risk") + 
			ylab("Maximum Annual Price (\u00A3)") +
			scale_y_continuous(labels=comma)+#,breaks=seq(0,max(graph_data$max_price + 100),100)) +
			scale_x_continuous(labels=percent) +
			theme_bw() +
			theme(legend.position="right", panel.margin = unit(1.5, "lines")) + 
			facet_wrap( ~ threshold, ncol=2, scales="free")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price_lines.pdf",sep=""),plot=max_price_line_plot,width=27,height=19,units="cm")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price_lines.png",sep=""),plot=max_price_line_plot,width=27,height=19,units="cm",dpi=300)
	
	write.csv(graph_data,file=paste("output/model_summary/",patient_group,"/max_price.csv",sep=""))
}

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