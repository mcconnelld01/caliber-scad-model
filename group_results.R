# Combines patient results summaries to produce final tables and figures for paper
# 
# Author: Miqdad Asaria
# Date: 2014
####################################################################################

library(ggplot2)
library(scales)
library(gridExtra)
library(reshape2)

source("competing_risks.R")

format_results = function(r){
	accuracy = 2
	if(r[1]>100){
		accuracy = 0
	}
	return(paste(format(round(r[1],accuracy),big.mark=",")," (", format(round(r[2],accuracy),big.mark=",")," to ",format(round(r[3],accuracy),big.mark=","),")",sep=""))
}

summarise_psa_results = function(num_patients, patient_group){
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
	rownames(overall_summary) = rep(1:num_patients)
	colnames(overall_summary) = rownames(total_results)
	rownames(simple_summary) = rep(1:num_patients)
	colnames(simple_summary) = rownames(total_results)
	write.csv(t(overall_summary),file=paste("output/model_summary/",patient_group,"/ce_results_all_patients_PSA_summary_formatted.csv",sep=""))
	write.csv(t(simple_summary),file=paste("output/model_summary/",patient_group,"/ce_results_all_patients_PSA_summary.csv",sep=""))
	
}

generate_markov_trace_plots = function(num_patients, cycle_length_days, patient_group){
	markov_plots = vector("list", num_patients)
	
	for(patient_number in 1:num_patients){
		results = read.csv(file=paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_mean_probabilistic.csv",sep=""),row.names=1)[,c(1,2,3,4,8,9)]
		colnames(results) = c("Event Free","MI","Ischaemic Stroke","Haemorrhagic Stroke","Fatal CVD","Fatal non-CVD")		
		results$years = (1:nrow(results))*cycle_length_days/365
		graph_data = melt(results,id=c("years"))
		if(patient_number==1){
			graph_data$risk = "lowest risk"
		}else if(patient_number==num_patients) {
			graph_data$risk = "highest risk"
		}else{ 
			graph_data$risk = patient_number
		}
		colnames(graph_data) = c("years","State","population","Risk_Decile")
		markov_plots[[patient_number]] = graph_data	
	}
	
	graph_data = do.call("rbind", markov_plots)
	graph_data$Risk_Decile = factor(graph_data$Risk_Decile, levels=c("lowest risk",2:(num_patients-1),"highest risk"))
	levels(graph_data$Risk_Decile)=c("lowest risk",2:(num_patients-1),"highest risk")
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

generate_max_price_plots = function(num_patients, patient_group){
	threshold = 20000
	all_data = read.csv(file=paste("output/model_summary/",patient_group,"/ce_results_all_patients_PSA_summary.csv",sep=""), row.names=1)
	
	load("CALIBER_SCAD_params.RData")

	if(patient_group == "deciles"){
		patients = patients_deciles
	} else if(patient_group == "clinical"){
		patients = patients_clinical
	}
	
	fe_5yr_prob = rep(0,num_patients)
	for(p in 1:num_patients){
		fe_5yr_prob[p] = calculate_fe_5yr_risk(patients[[p]], survival_params)	
	}
	
	scenarios = c("fe_cvd")	
	HRs = c(0.9,0.8,0.7,0.6)
	HR_labs = paste((1-HRs)*100,"%",sep="") 
	
	max_prices = vector("list", length(scenarios)*length(HRs))
	names(max_prices) = paste(rep(scenarios,each=length(HRs)),HRs, sep="_")
	
	for(scenario in scenarios){
		for(HR in HRs){
			name = paste(scenario,HR,sep="_")
			if(scenario=="fe_cvd"){
				nmb_fe_cvd = ((all_data[paste("qalys_const_",name,sep=""),1:num_patients]-all_data["qalys_const_basecase_1",1:num_patients])*threshold -  (all_data[paste("total_costs_",name,sep=""),1:num_patients]-all_data["total_costs_basecase_1",1:num_patients])) 
				max_price = nmb_fe_cvd/all_data[paste("cycle_SCAD_",name,sep=""),1:num_patients]
			} else if(scenario=="all_cvd"){
				nmb_all_cvd = ((all_data[paste("qalys_const_",name,sep=""),1:num_patients]-all_data["qalys_const_basecase_1",1:num_patients])*threshold -  (all_data[paste("total_costs_",name,sep=""),1:num_patients]-all_data["total_costs_basecase_1",1:num_patients])) 
				max_price = nmb_all_cvd/all_data[paste("life_years_",name,sep=""),1:num_patients]
			}
			max_prices[[name]] = t(rbind(1:num_patients,fe_5yr_prob,max_price,gsub("_"," ",paste(toupper(scenario)," ",(1-HR)*100,"%",sep=""))))
		}
	}
	
	graph_data = do.call("rbind", max_prices)
	colnames(graph_data) = c("patient","fe_5yr_risk","max_price","scenario")
	rownames(graph_data) = NULL
	graph_data = as.data.frame(graph_data, stringsAsFactors=FALSE)
	graph_data$patient = as.factor(as.numeric(graph_data$patient))	
	levels(graph_data$patient) = c("lowest risk",2:(num_patients-1),"highest risk")
	graph_data$fe_5yr_risk = as.numeric(graph_data$fe_5yr_risk)	
	graph_data$max_price = as.numeric(graph_data$max_price)	
	graph_data$scenario = as.factor(graph_data$scenario)	
	
	legend_title = "Treatment effect\n(hazard reduction)\non a typical\ncomposite trial\nendpoint of\nMI/stroke and\nCVD death"
	
	max_price_bar_plot = ggplot(graph_data, aes(x=patient,y=max_price,fill=scenario)) + 
			geom_bar(position="dodge", stat="identity") +
			scale_fill_grey(name=legend_title, labels=HR_labs) +
			xlab("Risk Group") + 
			ylab(enc2utf8("Maximum Annual Price (\u00A3)")) +
			scale_y_continuous(labels=comma,breaks=seq(0,max(graph_data$max_price + 100),100)) +
			theme_bw() +
			theme(legend.position="right")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price_bars.pdf",sep=""),plot=max_price_bar_plot,width=27,height=19,units="cm")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price.png",sep=""),plot=max_price_bar_plot,width=27,height=19,units="cm",dpi=300)

	max_price_line_plot = ggplot(graph_data, aes(x=fe_5yr_risk,y=max_price)) + 
			geom_line(aes(colour=scenario,linetype=scenario)) +
			geom_point(aes(shape=scenario)) +
			scale_colour_grey(name=legend_title, labels=HR_labs) +
			scale_linetype_discrete(name=legend_title, labels=HR_labs) +
			scale_shape_discrete(name=legend_title, labels=HR_labs) +
			xlab("Five Year CVD Event Risk") + 
			ylab("Maximum Annual Price (\u00A3)") +
			scale_y_continuous(labels=comma,breaks=seq(0,max(graph_data$max_price + 100),100)) +
			scale_x_continuous(labels=percent) +
			theme_bw() +
			theme(legend.position="right")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price_lines.pdf",sep=""),plot=max_price_line_plot,width=27,height=19,units="cm")
	ggsave(filename=paste("output/model_summary/",patient_group,"/max_price_lines.png",sep=""),plot=max_price_line_plot,width=27,height=19,units="cm",dpi=300)
	
	write.csv(graph_data,file=paste("output/model_summary/",patient_group,"/max_price.csv",sep=""))
}


args = commandArgs(trailingOnly=TRUE)
num_pat = as.numeric(args[1])
patient_group = as.character(args[2])

if(is.na(num_pat)){
	num_pat = 10
	print(paste("patient not provided setting to default patient: ", num_pat, sep=""))
}
if(is.na(patient_group)){
	patient_group = "deciles"
	print(paste("patient group not provided setting to default group: ", patient_group, sep=""))
}

cycle_length_days = 90

summarise_psa_results(num_pat,patient_group)
generate_markov_trace_plots(num_pat,cycle_length_days,patient_group)
generate_max_price_plots(num_pat,patient_group)