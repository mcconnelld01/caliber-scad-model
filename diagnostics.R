# Diagnostics to compare parametric estimates of modelled events to observed event
# rates from both the underlying data and external data sources 
# 
# Author: Miqdad Asaria
# Date: 2014
###############################################################################
start_time = proc.time()
library(etm)
library(muhaz)
library(mitools)
library(survival)
library(flexsurv)
library(compiler)

# import helper functions
source("estimate_model_params.R")
source("competing_risks.R")

###############################################################################################
# save formatted survival regression results to csv files for publication
###############################################################################################

output_parameter_estimates = function(){
	for(event in c("fe_mi","fe_stroke_i","fe_stroke_h","fe_fatal_cvd","fe_fatal_non_cvd","post_mi_cvd_mort","post_mi_non_cvd_mort","post_stroke_i_cvd_mort","post_stroke_i_non_cvd_mort","post_stroke_h_cvd_mort","post_stroke_h_non_cvd_mort")){
			for(subdist in c("gengamma","lognormal","weibull","exponential")){
			
			load(paste("parameter_estimates/",subdist,"_covars_",event,".RData",sep=""))
			coefs = MIextract(gg, fun=coef)
			# remove fixed parameters as they are not estimated and so not in vcov
			if(subdist=="lognormal" | subdist=="weibull"){
				for(i in 1:length(gg)){
					coefs[[i]] = coefs[[i]][-grep("Q",names(coefs[[i]]))]
				}
			}else if(subdist=="exponential"){
				for(i in 1:length(gg)){
					coefs[[i]] = coefs[[i]][-grep("Q",names(coefs[[i]]))]
					coefs[[i]] = coefs[[i]][-grep("sigma",names(coefs[[i]]))]
				}
			}
			vars = MIextract(gg, fun=vcov)
			model = MIcombine(coefs, vars)
			AIC = vector("numeric",length(gg))
			loglik = vector("numeric",length(gg))
			for(i in 1:length(gg)){
				AIC[i] = gg[[i]]$AIC
				loglik[i] = gg[[i]]$loglik
			}
			loglik = mean(loglik)
			AIC = mean(AIC)
			
			se = sqrt(diag(model$variance))
			x = model$coefficients
			res = cbind(x,x-1.96*se,x+1.96*se)
			mu = grep("mu", rownames(res))
			if(subdist=="gengamma"){
				Q =  grep("Q", rownames(res))
				res[-c(mu,Q),] = exp(res[-c(mu,Q),])
			} else {
				res[-c(mu),] = exp(res[-c(mu),])
			}
			res = rbind(res,loglik)
			res = rbind(res,AIC)
			write.csv(res,file=paste("output/survival/all_covars/",event,"_",subdist,".csv",sep=""))
			
		}
	}
}


###############################################################################################
# calculate observed mortality values from life tables to compare/calibrate model predictions
###############################################################################################
calculate_p_lifetable_survival = function(age, sex, years,lifetable){
	offset = 2
	p_mort = lifetable[age:(age+years),sex+offset]
	p_surv = 1-p_mort
	p_cum_surv=array(NA,length(p_surv))
	p_cum_surv[1] = 1
	for(i in 1:(length(p_surv)-1)){
		p_cum_surv[i+1] = p_cum_surv[i]*p_surv[i]
	}
	return(p_cum_surv)
} 

calculate_lifetable_mortality = function(lifetable,age_sex,years){
	age = age_sex[1,"age"]
	sex = age_sex[1,"sex"]
	survival = calculate_p_lifetable_survival(age,sex,years,lifetable)	
	mortality_probability_observed = (1-survival)[-1]
	cvd_mortality_probability_observed = cumsum((survival*lifetable[age:(age+years),sex+4])[-1])
	non_cvd_mortality_probability_observed = mortality_probability_observed - cvd_mortality_probability_observed
	# aggregate if we have more than one patient
	if(nrow(age_sex)>1){
		for(i in 2:nrow(age_sex)){
			age = age_sex[i,"age"]
			sex = age_sex[i,"sex"]
			survival = calculate_p_lifetable_survival(age,sex,years,lifetable)	
			mortality_probability_observed_i = (1-survival)[-1]
			cvd_mortality_probability_observed_i = cumsum((survival*lifetable[age:(age+years),sex+4])[-1])
			non_cvd_mortality_probability_observed_i = mortality_probability_observed_i - cvd_mortality_probability_observed_i
			mortality_probability_observed = mortality_probability_observed + mortality_probability_observed_i
			cvd_mortality_probability_observed = cvd_mortality_probability_observed + cvd_mortality_probability_observed_i
			non_cvd_mortality_probability_observed = non_cvd_mortality_probability_observed + non_cvd_mortality_probability_observed_i	
		}
	}
	# average over number of patients
	mortality_probability_observed = mortality_probability_observed/nrow(age_sex)
	cvd_mortality_probability_observed = cvd_mortality_probability_observed/nrow(age_sex)
	non_cvd_mortality_probability_observed = non_cvd_mortality_probability_observed/nrow(age_sex)
	# bind into mortality results
	mortality_results = cbind(mortality_probability_observed,cvd_mortality_probability_observed,non_cvd_mortality_probability_observed)
	return(mortality_results)
}

###############################################################################################
# plot average cumulative incidences over a patient population
###############################################################################################
plot_incidences = function(patients, prediction_years, title, batch_size = 1000){
	model_time = round(prediction_years*365)
	times = seq(0, model_time, cycle_length_days)
	
	# if we have more than batch_size patients we need to split into smaller subgroups
	# in order to prevent us from running out of memory when calculating cumulative incidences 
	num_pats = nrow(patients)
	num_batches = ceiling(num_pats/batch_size)
	final_batch_proportion = abs(((batch_size*(num_batches-1))-num_pats)/batch_size)
	batch_weights = c(rep(1,(num_batches-1)), final_batch_proportion)
	lifetable = read.csv("input_data/life_tables.csv")
	
	load(file="parameter_estimates/survival_params.RData")
	if(num_batches > 1){
		patient_batch = patients[1:batch_size,]
		ci = calculate_competing_risks_model(survival_params, patient_batch, prediction_years, observed_data_years = 10,cycle_length_days = 1,treatment_HR = 1, scenario = "basecase")
		
		fe_mi_ci = ci[["fe_mi"]]
		fe_stroke_i_ci = ci[["fe_stroke_i"]]
		fe_stroke_h_ci = ci[["fe_stroke_h"]]
		fe_fatal_cvd_ci = ci[["fe_fatal_cvd"]]
		fe_fatal_non_cvd_ci = ci[["fe_fatal_non_cvd"]]
		fatal_cvd_post_mi_ci = ci[["post_mi_fatal_cvd"]]
		fatal_non_cvd_post_mi_ci = ci[["post_mi_fatal_non_cvd"]]
		fatal_cvd_post_stroke_i_ci = ci[["post_stroke_i_fatal_cvd"]]
		fatal_non_cvd_post_stroke_i_ci = ci[["post_stroke_i_fatal_non_cvd"]]
		fatal_cvd_post_stroke_h_ci = ci[["post_stroke_h_fatal_cvd"]]
		fatal_non_cvd_post_stroke_h_ci = ci[["post_stroke_h_fatal_non_cvd"]]
		
		age_sex = matrix(cbind(round(patient_batch[,"age0"] + 70), round(patient_batch[,"sex"])), nrow=nrow(patient_batch), dimnames=list(1:nrow(patient_batch), c("age","sex")))
		mortality_probability_observed = calculate_lifetable_mortality(lifetable, age_sex, prediction_years)
		
		# calculate a weighted aggregation to account for any difference in size of the final batch 
		for(i in 2:num_batches){
			# print some trace information
			print(paste("Calculating cumulative incidence, patient batch: ",i," of ",num_batches,", ",date(),sep=""))
			
			first_patient = (((i-1)*batch_size)+1)
			last_patient = (((i-1)*batch_size)+batch_weights[i]*batch_size)
			patient_batch = matrix(patients[first_patient:last_patient,], ncol=ncol(patients), dimnames=list(first_patient:last_patient,colnames(patients)) )
			
			ci = calculate_competing_risks_model(survival_params, patient_batch, prediction_years, observed_data_years = 10,cycle_length_days = 1,treatment_HR = 1, scenario = "basecase")
			fe_mi_ci = fe_mi_ci + (batch_weights[i] * ci[["fe_mi"]])
			fe_stroke_i_ci = fe_stroke_i_ci + (batch_weights[i] * ci[["fe_stroke_i"]])
			fe_stroke_h_ci = fe_stroke_h_ci + (batch_weights[i] * ci[["fe_stroke_h"]])
			fe_fatal_cvd_ci = fe_fatal_cvd_ci + (batch_weights[i] * ci[["fe_fatal_cvd"]])
			fe_fatal_non_cvd_ci = fe_fatal_non_cvd_ci + (batch_weights[i] * ci[["fe_fatal_non_cvd"]])
			fatal_cvd_post_mi_ci = fatal_cvd_post_mi_ci + (batch_weights[i] * ci[["post_mi_fatal_cvd"]])
			fatal_non_cvd_post_mi_ci = fatal_non_cvd_post_mi_ci + (batch_weights[i] * ci[["post_mi_fatal_non_cvd"]])
			fatal_cvd_post_stroke_i_ci = fatal_cvd_post_stroke_i_ci + (batch_weights[i] * ci[["post_stroke_i_fatal_cvd"]])
			fatal_non_cvd_post_stroke_i_ci = fatal_non_cvd_post_stroke_i_ci + (batch_weights[i] * ci[["post_stroke_i_fatal_non_cvd"]])
			fatal_cvd_post_stroke_h_ci = fatal_cvd_post_stroke_h_ci + (batch_weights[i] * ci[["post_stroke_h_fatal_cvd"]])
			fatal_non_cvd_post_stroke_h_ci = fatal_non_cvd_post_stroke_h_ci + (batch_weights[i] * ci[["post_stroke_h_fatal_non_cvd"]])
			
			age_sex = matrix(cbind(round(patient_batch[,"age0"] + 70),round(patient_batch[,"sex"])),nrow=nrow(patient_batch),dimnames=list(1:nrow(patient_batch),c("age","sex")))
			mortality_probability_observed = mortality_probability_observed + (batch_weights[i] * calculate_lifetable_mortality(lifetable,age_sex,prediction_years))
		} 
		# calculate average using weights to correct for any heterogeneity in batch sizes
		fe_mi_ci = fe_mi_ci/sum(batch_weights)
		fe_stroke_i_ci = fe_stroke_i_ci/sum(batch_weights)
		fe_stroke_h_ci = fe_stroke_h_ci/sum(batch_weights)
		fe_fatal_cvd_ci = fe_fatal_cvd_ci/sum(batch_weights)
		fe_fatal_non_cvd_ci = fe_fatal_non_cvd_ci/sum(batch_weights)
		fatal_cvd_post_mi_ci = fatal_cvd_post_mi_ci/sum(batch_weights)
		fatal_non_cvd_post_mi_ci = fatal_non_cvd_post_mi_ci/sum(batch_weights)
		fatal_cvd_post_stroke_i_ci = fatal_cvd_post_stroke_i_ci/sum(batch_weights)
		fatal_non_cvd_post_stroke_i_ci = fatal_non_cvd_post_stroke_i_ci/sum(batch_weights)
		fatal_cvd_post_stroke_h_ci = fatal_cvd_post_stroke_h_ci/sum(batch_weights)
		fatal_non_cvd_post_stroke_h_ci = fatal_non_cvd_post_stroke_h_ci/sum(batch_weights)
		mortality_probability_observed = mortality_probability_observed/sum(batch_weights)		
	} else{
		ci = calculate_competing_risks_model(survival_params, patients, prediction_years, observed_data_years = 10,cycle_length_days = 1,treatment_HR = 1, scenario = "basecase")
		fe_mi_ci = ci[["fe_mi"]]
		fe_stroke_i_ci = ci[["fe_stroke_i"]]
		fe_stroke_h_ci = ci[["fe_stroke_h"]]
		fe_fatal_cvd_ci = ci[["fe_fatal_cvd"]]
		fe_fatal_non_cvd_ci = ci[["fe_fatal_non_cvd"]]
		fatal_cvd_post_mi_ci = ci[["post_mi_fatal_cvd"]]
		fatal_non_cvd_post_mi_ci = ci[["post_mi_fatal_non_cvd"]]
		fatal_cvd_post_stroke_i_ci = ci[["post_stroke_i_fatal_cvd"]]
		fatal_non_cvd_post_stroke_i_ci = ci[["post_stroke_i_fatal_non_cvd"]]
		fatal_cvd_post_stroke_h_ci = ci[["post_stroke_h_fatal_cvd"]]
		fatal_non_cvd_post_stroke_h_ci = ci[["post_stroke_h_fatal_non_cvd"]]
		
		age_sex = matrix(cbind(round(patients[,"age0"] + 70), round(patients[,"sex"])), nrow=nrow(patients), dimnames=list(1:nrow(patients), c("age","sex")))
		mortality_probability_observed = calculate_lifetable_mortality(lifetable, age_sex, prediction_years)
	}
	
	# cumulative incidence as calculated above used to compute mortality probabilities
	cvd_mortality_probability_predicted = fe_fatal_cvd_ci[,"cumulative_incidence"] + fe_mi_ci[,"cumulative_incidence"]*fatal_cvd_post_mi_ci[,"cumulative_incidence"] + fe_stroke_i_ci[,"cumulative_incidence"]*fatal_cvd_post_stroke_i_ci[,"cumulative_incidence"] + fe_stroke_h_ci[,"cumulative_incidence"]*fatal_cvd_post_stroke_h_ci[,"cumulative_incidence"]  
	non_cvd_mortality_probability_predicted = fe_fatal_non_cvd_ci[,"cumulative_incidence"] + fe_mi_ci[,"cumulative_incidence"]*fatal_non_cvd_post_mi_ci[,"cumulative_incidence"] + fe_stroke_i_ci[,"cumulative_incidence"]*fatal_non_cvd_post_stroke_i_ci[,"cumulative_incidence"] + fe_stroke_h_ci[,"cumulative_incidence"]*fatal_non_cvd_post_stroke_h_ci[,"cumulative_incidence"]  
	
	# calculate non parametric competing risk for observed period 
	id = first_events$anonpatid
	time = first_events$fe_time
	from = rep("scad",nrow(first_events))
	to = ifelse(first_events$fe_mi, "mi", ifelse(first_events$fe_stroke_i, "stroke_i", ifelse(first_events$fe_stroke_h, "stroke_h", ifelse(first_events$fe_fatal_cvd, "fatal_cvd", ifelse(first_events$fe_fatal_non_cvd, "fatal_non_cvd", "cens")))))
	etm.data = data.frame(id, from, to, time)
	tra = matrix(FALSE, nrow=6, ncol=6)
	tra[1,2:6] = TRUE
	dimnames(tra) = list(c("scad", "mi", "stroke_i", "stroke_h", "fatal_cvd", "fatal_non_cvd"),c("scad", "mi", "stroke_i", "stroke_h", "fatal_cvd", "fatal_non_cvd"))
	etm.ci = etm(etm.data, c("scad", "mi", "stroke_i", "stroke_h", "fatal_cvd", "fatal_non_cvd"), tra, "cens", s=0)
	
	# plot a stacked graph of the probabilities of first event predicted versus observed
	five_years = round(5*365/cycle_length_days)
	plot((fe_mi_ci[,"time"]/365), fe_mi_ci[,"cumulative_incidence"], ylim=c(0,1), type="l", col="black", xlab="years since SCAD date", ylab="probability", main=paste("Cumulative Incidence of First Event",title,sep=""))
	lines((etm.ci$time/365), etm.ci$est["scad","mi",], col="black", lty=2)
	lines((fe_mi_ci[,"time"]/365), fe_stroke_i_ci[,"cumulative_incidence"]+fe_mi_ci[,"cumulative_incidence"], col="darkblue")
	lines((etm.ci$time/365), etm.ci$est["scad","mi",]+etm.ci$est["scad","stroke_i",], col="darkblue", lty=2)
	lines((fe_mi_ci[,"time"]/365),fe_stroke_h_ci[,"cumulative_incidence"]+fe_stroke_i_ci[,"cumulative_incidence"]+fe_mi_ci[,"cumulative_incidence"], col="lightblue")
	lines((etm.ci$time/365), etm.ci$est["scad","mi",]+etm.ci$est["scad","stroke_i",]+etm.ci$est["scad","stroke_h",], col="lightblue", lty=2)
	lines((fe_mi_ci[,"time"]/365),fe_stroke_h_ci[,"cumulative_incidence"]+fe_stroke_i_ci[,"cumulative_incidence"]+fe_mi_ci[,"cumulative_incidence"]+fe_fatal_cvd_ci[,"cumulative_incidence"], col="darkred")
	lines((etm.ci$time/365), etm.ci$est["scad","mi",]+etm.ci$est["scad","stroke_i",]+etm.ci$est["scad","stroke_h",]+etm.ci$est["scad","fatal_cvd",], col="darkred", lty=2)
	lines((fe_mi_ci[,"time"]/365),fe_stroke_h_ci[,"cumulative_incidence"]+fe_stroke_i_ci[,"cumulative_incidence"]+fe_mi_ci[,"cumulative_incidence"]+fe_fatal_cvd_ci[,"cumulative_incidence"]+fe_fatal_non_cvd_ci[,"cumulative_incidence"], col="darkgreen")
	lines((etm.ci$time/365), etm.ci$est["scad","mi",]+etm.ci$est["scad","stroke_i",]+etm.ci$est["scad","stroke_h",]+etm.ci$est["scad","fatal_cvd",]+etm.ci$est["scad","fatal_non_cvd",], col="darkgreen", lty=2)
	abline(h=1,lty=3,col="darkgrey")
	legend("right", cex=0.7, lty=1, title=paste("Risk of FE (total @ 5yrs=",round(fe_stroke_h_ci[five_years,"cumulative_incidence"]+fe_stroke_i_ci[five_years,"cumulative_incidence"]+fe_mi_ci[five_years,"cumulative_incidence"]+fe_fatal_cvd_ci[five_years,"cumulative_incidence"]+fe_fatal_non_cvd_ci[five_years,"cumulative_incidence"],2),")",sep=""), 
			col = rev(c("black", "darkblue", "lightblue", "darkred", "darkgreen")), legend = rev(c("MI","Ischaemic Stroke","Hemorrhagic Stroke","Fatal CVD","Fatal non-CVD")))
	
	# plot a stacked graph of mortality probabilities from life tables against our predictions
	plot(0:prediction_years, c(0,mortality_probability_observed[,1]), type="l", lty=2, col="black", xlab="years from SCAD date", ylab="probability", ylim=c(0,1), main=paste("Cumulative Mortality Probability",title,sep=""))
	lines(times/365, c(0,cvd_mortality_probability_predicted+non_cvd_mortality_probability_predicted), lty=1, col="black")
	lines(0:prediction_years, c(0,mortality_probability_observed[,2]), lty=2, col="darkred")
	lines(times/365, c(0,cvd_mortality_probability_predicted), lty=1, col="darkred")
	lines(0:prediction_years, c(0,mortality_probability_observed[,3]), lty=2, col="darkgreen")
	lines(times/365, c(0,non_cvd_mortality_probability_predicted), lty=1, col="darkgreen")
	abline(h=1, lty=3, col="darkgrey")
	legend("right", cex=0.7, lty=c(2,1,2,1,2,1), col = c("black","black","darkred","darkred","darkgreen","darkgreen"), legend = c("Life Table All Cause Mortality","Predicted All Cause Mortality","Life Table CVD Mortality","Predicted CVD Mortality","Life Table Non-CVD Mortality","Predicted Non-CVD Mortality"))
}


##########################################################################################
## plot non-parametric and parametric survival and hazard functions for each event
##########################################################################################
remove_infinite_hazards = function(hazards_batch){
	cleaned_hazards_batch = hazards_batch[,is.finite(hazards_batch[nrow(hazards_batch),])]
	num_replaced_hazards = ncol(hazards_batch) - ncol(cleaned_hazards_batch)
	if(num_replaced_hazards>0){
		mean_hazard = rowMeans(cleaned_hazards_batch)
		for(i in 1:num_replaced_hazards){
			cleaned_hazards_batch = cbind(cleaned_hazards_batch,mean_hazard)
		}
	}
	return(cleaned_hazards_batch)
}
		
		
plot_hazards = function(model_time, data, patients, event_var, time_var, title, survival_params, cycle_length_days, batch_size = 1000){
	if(nrow(patients)>0){
		haz = pehaz(data[,time_var], data[,event_var])
		risk_equation = paste(event_var,"_params",sep="")
		parametric_models = c("gengamma","lognormal","weibull","exponential")
		parametric_hazards = vector("list", length(parametric_models))
		names(parametric_hazards) = parametric_models
		for(dist in parametric_models){
			# if we have more than batch_size patients we need to split into smaller subgroups
			# in order to prevent us from running out of memory when calculating cumulative incidences 
			num_pats = nrow(patients)
			num_batches = ceiling(num_pats/batch_size)
			final_batch_proportion = abs(((batch_size*(num_batches-1))-num_pats)/batch_size)
			batch_weights = c(rep(1,(num_batches-1)),final_batch_proportion)
			if(num_batches > 1){
				patient_batch = patients[1:batch_size,]
				parametric_hazards[[dist]] = rowMeans(remove_infinite_hazards(gengamma_hazards(model_time,survival_params[[dist]][[risk_equation]],patient_batch,cycle_length_days)))
				for(i in 2:num_batches){
					# print some trace information
					if(i %% 50 == 0){
						print(paste("Calculating hazards for: ",event_var,", distribution: ",dist,", patient batch: ",i," of ",num_batches,", ",date(),sep=""))
					}
					first_patient = (((i-1)*batch_size)+1)
					last_patient = (((i-1)*batch_size)+batch_weights[i]*batch_size)
					patient_batch = matrix(patients[first_patient:last_patient,],ncol=ncol(patients),dimnames=list(first_patient:last_patient,colnames(patients)) )
					hazards_batch = remove_infinite_hazards(gengamma_hazards(model_time,survival_params[[dist]][[risk_equation]],patient_batch,cycle_length_days))
					parametric_hazards[[dist]] = parametric_hazards[[dist]] + (batch_weights[i] * rowMeans(hazards_batch))
				}
				parametric_hazards[[dist]] = parametric_hazards[[dist]]/sum(batch_weights)
			} else {
				hazards_batch = rowMeans(remove_infinite_hazards(gengamma_hazards(model_time,survival_params[[dist]][[risk_equation]],patients,cycle_length_days)))
				parametric_hazards[[dist]] = hazards_batch			
			}	
			# remove discontinuity at 0
			parametric_hazards[[dist]][1] = parametric_hazards[[dist]][2]
			# constrain to be between 0 and 20 for hazards and 0 and 1 for survival
			parametric_hazards[[dist]] = sapply(sapply(parametric_hazards[[dist]],function(x)min(x,20)),function(x)max(x,0))
		}
		parametric_models_legend = parametric_models
		for(i in 1:length(parametric_models)){
			parametric_models_legend[i] = paste(parametric_models[i]," (AIC=",round(survival_params[[parametric_models[i]]][[risk_equation]][1,"AIC"]),", log-likelihood=",round(survival_params[[parametric_models[i]]][[risk_equation]][1,"loglik"]),")",sep="") 
		}
	
		min_hazards = min(haz$Hazard[-length(haz$Hazard)])
		max_hazards = max(haz$Hazard[-length(haz$Hazard)])
		
		for(dist in parametric_models){
			min_hazards = min(parametric_hazards[[dist]], min_hazards)
			max_hazards = max(parametric_hazards[[dist]], max_hazards)
		}
		
		ylabel = "hazard"
		parametric_hazards_cols = c("darkred","darkblue","darkgreen","darkorange")
		plot(x=seq(0,round(model_time/cycle_length_days)*cycle_length_days,cycle_length_days)/365,
				y=parametric_hazards[[1]], 
				col=parametric_hazards_cols[1],
				type="l", lty=1,ylim=c(min_hazards,max_hazards),
				main=paste(title," (N=",sum(data[,event_var]),")",sep=""), xlab="years from SCAD index date", ylab=ylabel)
				for(i in 2:length(parametric_hazards)){
					lines(x=seq(0,round(model_time/cycle_length_days)*cycle_length_days,cycle_length_days)/365,	y=parametric_hazards[[i]],col=parametric_hazards_cols[i],lty=1)
				}
				x=c(0,rep(haz$Cuts[c(-1,-length(haz$Cuts))],each=2))
				y=rep(haz$Hazard[-length(haz$Hazard)],each=2)
				lines(x[-length(x)]/365,y,col="black",lty=2)
				legend("top", cex=0.7, col = c("black", parametric_hazards_cols), lty = c(2,rep(1,length(parametric_hazards))), legend = c("Peicewise Exponential",parametric_models_legend))
		
		parametric_hazards[["NP"]] = haz
		return(parametric_hazards)
	} else {
		return(NULL)
	} 
}


plot_survival = function(model_time, data, patients, event_var, time_var, title, survival_params, cycle_length_days, batch_size = 1000){
	if(nrow(patients)>0){
		km = survfit(Surv(data[,time_var], data[,event_var]) ~ 1)			
		risk_equation = paste(event_var,"_params",sep="")
		parametric_models = c("gengamma","lognormal","weibull","exponential")
		parametric_hazards = vector("list", length(parametric_models))
		names(parametric_hazards) = parametric_models
		for(dist in parametric_models){
			# if we have more than batch_size patients we need to split into smaller subgroups
			# in order to prevent us from running out of memory when calculating cumulative incidences 
			num_pats = nrow(patients)
			num_batches = ceiling(num_pats/batch_size)
			final_batch_proportion = abs(((batch_size*(num_batches-1))-num_pats)/batch_size)
			batch_weights = c(rep(1,(num_batches-1)),final_batch_proportion)
			if(num_batches > 1){
				patient_batch = patients[1:batch_size,]
				parametric_hazards[[dist]] = rowMeans(exp(-1*cumulative_gengamma_hazards(model_time,survival_params[[dist]][[risk_equation]],patient_batch,cycle_length_days)))
				for(i in 2:num_batches){
					# print some trace information
					if(i %% 50 == 0){
						print(paste("Calculating survival for: ",event_var,", distribution: ",dist,", patient batch: ",i," of ",num_batches,", ",date(),sep=""))
					}
					first_patient = (((i-1)*batch_size)+1)
					last_patient = (((i-1)*batch_size)+batch_weights[i]*batch_size)
					patient_batch = matrix(patients[first_patient:last_patient,],ncol=ncol(patients),dimnames=list(first_patient:last_patient,colnames(patients)) )
					hazards_batch = exp(-1*cumulative_gengamma_hazards(model_time,survival_params[[dist]][[risk_equation]],patient_batch,cycle_length_days))
					parametric_hazards[[dist]] = parametric_hazards[[dist]] + (batch_weights[i] * rowMeans(hazards_batch))
				}
				parametric_hazards[[dist]] = parametric_hazards[[dist]]/sum(batch_weights)
			} else {
				hazards_batch = rowMeans(exp(-1*cumulative_gengamma_hazards(model_time,survival_params[[dist]][[risk_equation]],patients,cycle_length_days)))
				parametric_hazards[[dist]] = hazards_batch			
			}	
			# remove discontinuity at 0
			parametric_hazards[[dist]][1] = parametric_hazards[[dist]][2]
			# constrain survival to be between 0 and 1 for survival
			parametric_hazards[[dist]] = sapply(sapply(parametric_hazards[[dist]],function(x)min(x,1)),function(x)max(x,0))
		}
		parametric_models_legend = parametric_models
		for(i in 1:length(parametric_models)){
			parametric_models_legend[i] = paste(parametric_models[i]," (AIC=",round(survival_params[[parametric_models[i]]][[risk_equation]][1,"AIC"]),", log-likelihood=",round(survival_params[[parametric_models[i]]][[risk_equation]][1,"loglik"]),")",sep="") 
		}
		
		min_hazards = min(km$surv)
		max_hazards = max(km$surv)
		
		for(dist in parametric_models){
			min_hazards = min(parametric_hazards[[dist]], min_hazards)
			max_hazards = max(parametric_hazards[[dist]], max_hazards)
		}
		
		ylabel = "survival probability"
		parametric_hazards_cols = c("darkred","darkblue","darkgreen","darkorange")
		plot(x=seq(0,round(model_time/cycle_length_days)*cycle_length_days,cycle_length_days)/365,
				y=parametric_hazards[[1]], 
				col=parametric_hazards_cols[1],
				type="l", lty=1,ylim=c(min_hazards,max_hazards),
				main=paste(title," (N=",sum(data[,event_var]),")",sep=""), xlab="years from SCAD index date", ylab=ylabel)
				for(i in 2:length(parametric_hazards)){
					lines(x=seq(0,round(model_time/cycle_length_days)*cycle_length_days,cycle_length_days)/365, y=parametric_hazards[[i]],col=parametric_hazards_cols[i],lty=1)
				}
				x=km$time/365
				y=km$surv
				lines(x,y,col="black",lty=2)
				legend("top", cex=0.7, col = c("black", parametric_hazards_cols), lty = c(2,rep(1,length(parametric_hazards))), legend = c("Kaplan-Meier",parametric_models_legend))

		parametric_hazards[["NP"]] = km$surv
		return(parametric_hazards)
	} else {
		return(NULL)
	} 
}

###############################################################################################
# calculate diagnostics and draw plots to give an idea of how well functions fit
###############################################################################################

# generate diagnostic output for sets of patients 
generate_diagnostic_plots = function(equations, survival_params, patients, prediction_years, title, batch_size = 1000, plot_hazards=TRUE, plot_survival=TRUE){
	model_time = round(prediction_years*365)
	hazards = list()
	survival = list()
	first_events = fe_data[[1]]
	post_mi = post_mi_mort_data[[1]]
	post_stroke_i = post_stroke_i_mort_data[[1]]
	post_stroke_h = post_stroke_h_mort_data[[1]]
	# limit to only the patients we have unless only one patient then use all
	if(nrow(patients)>1){
		pats = as.data.frame(unique(patients[,"anonpatid"]))
		names(pats) = "anonpatid"
		first_events = merge(y=first_events, x=pats, by="anonpatid", all=FALSE)
		post_mi = merge(y=post_mi, x=pats, by="anonpatid", all=FALSE)
		post_stroke_i = merge(y=post_stroke_i, x=pats, by="anonpatid", all=FALSE)
		post_stroke_h = merge(y=post_stroke_h, x=pats, by="anonpatid", all=FALSE)
	} 
	# rename columns to make consistent with survival params
	names(post_mi)[grep("post_mi_cvd_mort", names(post_mi))] = "fatal_cvd_post_mi"
	names(post_mi)[grep("post_mi_non_cvd_mort", names(post_mi))] = "fatal_non_cvd_post_mi"
	names(post_stroke_i)[grep("post_stroke_i_cvd_mort", names(post_stroke_i))] = "fatal_cvd_post_stroke_i"
	names(post_stroke_i)[grep("post_stroke_i_non_cvd_mort", names(post_stroke_i))] = "fatal_non_cvd_post_stroke_i"		
	names(post_stroke_h)[grep("post_stroke_h_cvd_mort", names(post_stroke_h))] = "fatal_cvd_post_stroke_h"
	names(post_stroke_h)[grep("post_stroke_h_non_cvd_mort", names(post_stroke_h))] = "fatal_non_cvd_post_stroke_h"
	# plot first event predicted parametric hazards versus observed non parametric hazards
	cycle_length_days_haz = 90

	if(plot_hazards){
		print("plotting hazards")
		if(1 %in% equations){
			print("fe_mi")
			hazards[["fe_mi"]] = plot_hazards(model_time, first_events, patients, "fe_mi", "fe_time", paste("First Event Non-Fatal MI", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(2 %in% equations){
			print("fe_stroke_i")
			hazards[["fe_stroke_i"]] = plot_hazards(model_time, first_events, patients, "fe_stroke_i", "fe_time", paste("First Event Non-Fatal Ischaemic Stroke", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(3 %in% equations){
			print("fe_stroke_h")
			hazards[["fe_stroke_h"]] = plot_hazards(model_time, first_events, patients, "fe_stroke_h", "fe_time", paste("First Event Non-Fatal Hemorrhagic Stroke", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(4 %in% equations){
			print("fe_fatal_cvd")
			hazards[["fe_fatal_cvd"]] = plot_hazards(model_time, first_events, patients,"fe_fatal_cvd", "fe_time", paste("First Event Fatal CVD", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(5 %in% equations){
			print("fe_fatal_non_cvd")
			hazards[["fe_fatal_non_cvd"]] = plot_hazards(model_time, first_events, patients, "fe_fatal_non_cvd", "fe_time", paste("First Event Fatal Non-CVD", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(6 %in% equations){
			print("fatal_cvd_post_mi")
			hazards[["fatal_cvd_post_mi"]] = plot_hazards(model_time, post_mi, subset(patients, patients[,"anonpatid"] %in% post_mi[,"anonpatid"]), "fatal_cvd_post_mi", "post_mi_mort_time", paste("Post MI CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(7 %in% equations){
			print("fatal_non_cvd_post_mi")
			hazards[["fatal_non_cvd_post_mi"]] = plot_hazards(model_time, post_mi, subset(patients, patients[,"anonpatid"] %in% post_mi[,"anonpatid"]), "fatal_non_cvd_post_mi", "post_mi_mort_time", paste("Post MI Non-CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(8 %in% equations){
			print("fatal_cvd_post_stroke_i")
			hazards[["fatal_cvd_post_stroke_i"]] = plot_hazards(model_time, post_stroke_i, subset(patients, patients[,"anonpatid"] %in% post_stroke_i[,"anonpatid"]), "fatal_cvd_post_stroke_i", "post_stroke_i_mort_time", paste("Post Ischaemic Stroke CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(9 %in% equations){
			print("fatal_non_cvd_post_stroke_i")
			hazards[["fatal_non_cvd_post_stroke_i"]] = plot_hazards(model_time, post_stroke_i, subset(patients, patients[,"anonpatid"] %in% post_stroke_i[,"anonpatid"]), "fatal_non_cvd_post_stroke_i", "post_stroke_i_mort_time", paste("Post Ischaemic Stroke non-CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(10 %in% equations){
			print("fatal_cvd_post_stroke_h")
			hazards[["fatal_cvd_post_stroke_h"]] = plot_hazards(model_time, post_stroke_h, subset(patients, patients[,"anonpatid"] %in% post_stroke_h[,"anonpatid"]), "fatal_cvd_post_stroke_h", "post_stroke_h_mort_time", paste("Post Hemorrhagic Stroke CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(11 %in% equations){
			print("fatal_non_cvd_post_stroke_h")
			hazards[["fatal_non_cvd_post_stroke_h"]] = plot_hazards(model_time, post_stroke_h, subset(patients, patients[,"anonpatid"] %in% post_stroke_h[,"anonpatid"]), "fatal_non_cvd_post_stroke_h", "post_stroke_h_mort_time", paste("Post Hemorrhagic Stroke non-CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
	}
	
	if(plot_survival){
		print("plotting survival")
		if(1 %in% equations){
			print("fe_mi")
			survival[["fe_mi"]] = plot_survival(model_time, first_events, patients, "fe_mi", "fe_time", paste("First Event Non-Fatal MI", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(2 %in% equations){
			print("fe_stroke_i")
			survival[["fe_stroke_i"]] = plot_survival(model_time, first_events, patients, "fe_stroke_i", "fe_time", paste("First Event Non-Fatal Ischaemic Stroke", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(3 %in% equations){
			print("fe_stroke_h")
			survival[["fe_stroke_h"]] = plot_survival(model_time, first_events, patients, "fe_stroke_h", "fe_time", paste("First Event Non-Fatal Hemorrhagic Stroke", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(4 %in% equations){
			print("fe_fatal_cvd")
			survival[["fe_fatal_cvd"]] = plot_survival(model_time, first_events, patients,"fe_fatal_cvd", "fe_time", paste("First Event Fatal CVD", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(5 %in% equations){
			print("fe_fatal_non_cvd")
			survival[["fe_fatal_non_cvd"]] = plot_survival(model_time, first_events, patients, "fe_fatal_non_cvd", "fe_time", paste("First Event Fatal Non-CVD", title, sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(6 %in% equations){
			print("fatal_cvd_post_mi")
			survival[["fatal_cvd_post_mi"]] = plot_survival(model_time, post_mi, subset(patients, patients[,"anonpatid"] %in% post_mi[,"anonpatid"]), "fatal_cvd_post_mi", "post_mi_mort_time", paste("Post MI CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(7 %in% equations){
			print("fatal_non_cvd_post_mi")
			survival[["fatal_non_cvd_post_mi"]] = plot_survival(model_time, post_mi, subset(patients, patients[,"anonpatid"] %in% post_mi[,"anonpatid"]), "fatal_non_cvd_post_mi", "post_mi_mort_time", paste("Post MI Non-CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(8 %in% equations){
			print("fatal_cvd_post_stroke_i")
			survival[["fatal_cvd_post_stroke_i"]] = plot_survival(model_time, post_stroke_i, subset(patients, patients[,"anonpatid"] %in% post_stroke_i[,"anonpatid"]), "fatal_cvd_post_stroke_i", "post_stroke_i_mort_time", paste("Post Ischaemic Stroke CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(9 %in% equations){
			print("fatal_non_cvd_post_stroke_i")
			survival[["fatal_non_cvd_post_stroke_i"]] = plot_survival(model_time, post_stroke_i, subset(patients, patients[,"anonpatid"] %in% post_stroke_i[,"anonpatid"]), "fatal_non_cvd_post_stroke_i", "post_stroke_i_mort_time", paste("Post Ischaemic Stroke non-CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(10 %in% equations){
			print("fatal_cvd_post_stroke_h")
			survival[["fatal_cvd_post_stroke_h"]] = plot_survival(model_time, post_stroke_h, subset(patients, patients[,"anonpatid"] %in% post_stroke_h[,"anonpatid"]), "fatal_cvd_post_stroke_h", "post_stroke_h_mort_time", paste("Post Hemorrhagic Stroke CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
		if(11 %in% equations){
			print("fatal_non_cvd_post_stroke_h")
			survival[["fatal_non_cvd_post_stroke_h"]] = plot_survival(model_time, post_stroke_h, subset(patients, patients[,"anonpatid"] %in% post_stroke_h[,"anonpatid"]), "fatal_non_cvd_post_stroke_h", "post_stroke_h_mort_time", paste("Post Hemorrhagic Stroke non-CVD Mortality",title,sep=""), survival_params, cycle_length_days_haz, batch_size)
		}
	}
	results = list(hazards, survival)
	names(results) = c("hazards","survival")
	return(results)
}

##########################################################################################
# set up the patients we will use to carry out our model predictions
##########################################################################################
# set key prediction parameters
prediction_years = 70
cycle_length_days = 1 # if higher than one hazard approximations are not quite correct 

# import CALIBER data for first and subsequent events
data = get_survival_data()
fe_data = data[["fe_data"]]
post_mi_mort_data = data[["post_mi_mort_data"]]
post_stroke_i_mort_data = data[["post_stroke_i_mort_data"]]
post_stroke_h_mort_data = data[["post_stroke_h_mort_data"]]

# calculate risk equations these can be very slow to run (a few days) so suggest using cached values
load("parameter_estimates/survival_params_all.RData")

##########################################################################################
# set up the patients we will use to carry out our model predictions
##########################################################################################
# combine all 5 imputations generated in the MI process and extract the patient covariates from these in
# a suitable format using lm
all_first_events = rbind(fe_data[[1]],fe_data[[2]],fe_data[[3]],fe_data[[4]],fe_data[[5]])
fe_patients = lm(fe_mi  ~ anonpatid+sex+age0+age0:sex+IMD5+dx7+earlyPCI+earlyCABG+recurrent_mi+nitrates_long+smcat+hypertension+diabetes+hist_hf+hist_pad+hist_af+hist_stroke+hist_renal+hist_copd+hist_cancer+hist_liver+depression+hist_anxiety+pulse_rate+HDL+TCHOL+CREAT+WCC+HGB+age0_ori+pulse_rate_ori+HDL_ori+TCHOL_ori+CREAT_ori+WCC_ori+HGB_ori, x=TRUE, data=all_first_events)$x 
fe_patients = as.data.frame(fe_patients)

all_post_mi_mort_data = rbind(post_mi_mort_data[[1]],post_mi_mort_data[[2]],post_mi_mort_data[[3]],post_mi_mort_data[[4]],post_mi_mort_data[[5]]) 
post_mi_patients = lm(fe_time  ~ anonpatid+sex+age0+age0:sex+IMD5+smcat, x=TRUE, data=all_post_mi_mort_data)$x 

all_post_stroke_i_mort_data = rbind(post_stroke_i_mort_data[[1]],post_stroke_i_mort_data[[2]],post_stroke_i_mort_data[[3]],post_stroke_i_mort_data[[4]],post_stroke_i_mort_data[[5]]) 
post_stroke_i_patients = lm(fe_time  ~ anonpatid+sex+age0+age0:sex+IMD5+smcat, x=TRUE, data=all_post_stroke_i_mort_data)$x 

all_post_stroke_h_mort_data = rbind(post_stroke_h_mort_data[[1]],post_stroke_h_mort_data[[2]],post_stroke_h_mort_data[[3]],post_stroke_h_mort_data[[4]],post_stroke_h_mort_data[[5]]) 
post_stroke_h_patients = lm(fe_time  ~ anonpatid+sex+age0+age0:sex+IMD5+smcat, x=TRUE, data=all_post_stroke_h_mort_data)$x 

###############################################################################################
# generate diagnostics for various subsets of patients outputting results to PDF files
###############################################################################################

args = commandArgs(trailingOnly=TRUE)
equation = as.numeric(args[1])
if(is.na(equation)){
	equation = 1:11
	print(paste("equation number not provided running diagnostics for all 11 equations"))
}

if(length(equation)>1){
	filename = "output/diagnostics/average_overall_results_multiple_survival_equations.pdf"
} else {
	filename = paste("output/diagnostics/average_overall_results_survival_equation_",equation,".pdf",sep="")
}

pdf(filename)
	overall_patients = as.matrix(fe_patients)
	title = ": Overall Average"
	diagnostics = generate_diagnostic_plots(equation, all_survival_params, overall_patients, prediction_years, title, plot_hazards = TRUE, plot_survival = TRUE)
dev.off()

end_time = proc.time()
print(paste("total run time: ",round((end_time["elapsed"]-start_time["elapsed"])/60,2)," mins", sep=""))
