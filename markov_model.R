# This code builds a Markov cohort state transition model based on competing risks
# by using the cumulative incidence of first events and subsequent mortality to
# produce a state transition matrix - including the appropriate numbers of tunnel
# states to capture the time varying nature of the underlying transition hazards
# 
# Author: Miqdad Asaria
# Date: 2014
####################################################################################

source("competing_risks.R")

##########################################################################################
# create transition probability matrix
##########################################################################################

clean_transition_probability = function(transition_probability){
	if(is.infinite(transition_probability) | is.na(transition_probability)){
		return(0)
	}else{
		return(transition_probability)
	}
}

# state transition matrix with third dimension as cycles in model
create_3d_state_transition_matrix = function(patient, prediction_years, cycle_length_days, survival_params, data_years, treatment_HR, scenario){
	num_cycles = ceiling((prediction_years*365)/cycle_length_days)
	num_tunnels = num_cycles - 1
	post_mi_states = paste("post_mi",1:num_tunnels,sep="_")
	post_stroke_i_states = paste("post_stroke_i",1:num_tunnels,sep="_")
	post_stroke_h_states = paste("post_stroke_h",1:num_tunnels,sep="_")
	states = c("SCAD",post_mi_states,post_stroke_i_states,post_stroke_h_states,"fatal_cvd","fatal_non_cvd")
	
	fe_mi_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=1)
	fe_stroke_i_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=1)
	fe_stroke_h_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=1)
	fe_fatal_cvd_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=1)
	fe_fatal_non_cvd_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=1)
	fatal_cvd_post_mi_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=num_cycles)
	fatal_non_cvd_post_mi_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=num_cycles)
	fatal_cvd_post_stroke_i_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=num_cycles)
	fatal_non_cvd_post_stroke_i_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=num_cycles)
	fatal_cvd_post_stroke_h_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=num_cycles)
	fatal_non_cvd_post_stroke_h_ci = matrix(NA,nrow=((prediction_years+1)*365),ncol=num_cycles)
	
	ci = calculate_competing_risks_model(survival_params, patient, prediction_years+1, data_years, 1, treatment_HR, scenario)
	fe_mi_ci[,1] = ci[["fe_mi"]][,2]
	fe_stroke_i_ci[,1] = ci[["fe_stroke_i"]][,2]
	fe_stroke_h_ci[,1] = ci[["fe_stroke_h"]][,2]
	fe_fatal_cvd_ci[,1] = ci[["fe_fatal_cvd"]][,2]
	fe_fatal_non_cvd_ci[,1] = ci[["fe_fatal_non_cvd"]][,2]
	# constrain infinite values of CI to 1
	fe_mi_ci[fe_mi_ci>1 | is.na(fe_mi_ci)] = 1
	fe_stroke_i_ci[fe_stroke_i_ci>1 | is.na(fe_stroke_i_ci)] = 1
	fe_stroke_h_ci[fe_stroke_h_ci>1 | is.na(fe_stroke_h_ci)] = 1
	fe_fatal_cvd_ci[fe_fatal_cvd_ci>1 | is.na(fe_fatal_cvd_ci)] = 1
	fe_fatal_non_cvd_ci[fe_fatal_non_cvd_ci>1 | is.na(fe_fatal_non_cvd_ci)] = 1
	# if these add up to more than one due to rounding errors - make correction in fatal non-cvd
	rounding_errors = fe_mi_ci + fe_stroke_i_ci + fe_stroke_h_ci + fe_fatal_cvd_ci + fe_fatal_non_cvd_ci > 1
	fe_fatal_non_cvd_ci[rounding_errors] = 1 - (fe_mi_ci + fe_stroke_i_ci + fe_stroke_h_ci + fe_fatal_cvd_ci)[rounding_errors] 
	
	patient_ageing = patient
	data_years_remaining = data_years
	for(i in 1:num_cycles){
		ci = calculate_competing_risks_model(survival_params, patient_ageing, prediction_years+1, data_years_remaining, 1, treatment_HR, scenario)
		fatal_cvd_post_mi_ci[,i] = ci[["post_mi_fatal_cvd"]][,2]
		fatal_non_cvd_post_mi_ci[,i] = ci[["post_mi_fatal_non_cvd"]][,2]
		fatal_cvd_post_stroke_i_ci[,i] = ci[["post_stroke_i_fatal_cvd"]][,2]
		fatal_non_cvd_post_stroke_i_ci[,i] = ci[["post_stroke_i_fatal_non_cvd"]][,2]
		fatal_cvd_post_stroke_h_ci[,i] = ci[["post_stroke_h_fatal_cvd"]][,2]
		fatal_non_cvd_post_stroke_h_ci[,i] = ci[["post_stroke_h_fatal_non_cvd"]][,2]
		patient_ageing[1,"age0"] = patient[1,"age0"] + (i*cycle_length_days)/365
		data_years_remaining = max(0, data_years-(i*cycle_length_days)/365)
	}
	
	# constrain infinite values of CI to 1
	# if post mi adds up to more than one make correction in fatal non cvd
	fatal_non_cvd_post_mi_ci[is.infinite(fatal_non_cvd_post_mi_ci) | is.na(fatal_non_cvd_post_mi_ci)] = 1
	fatal_cvd_post_mi_ci[fatal_cvd_post_mi_ci>1 | is.na(fatal_cvd_post_mi_ci)] = 1
	fatal_non_cvd_post_mi_ci[(fatal_non_cvd_post_mi_ci+fatal_cvd_post_mi_ci)>1] = 1-fatal_cvd_post_mi_ci[(fatal_non_cvd_post_mi_ci+fatal_cvd_post_mi_ci)>1]
	# if post stroke i adds up to more than one make correction in fatal non cvd
	fatal_non_cvd_post_stroke_i_ci[is.infinite(fatal_non_cvd_post_stroke_i_ci) | is.na(fatal_non_cvd_post_stroke_i_ci)] = 1
	fatal_cvd_post_stroke_i_ci[fatal_cvd_post_stroke_i_ci>1 | is.na(fatal_cvd_post_stroke_i_ci)] = 1
	fatal_non_cvd_post_stroke_i_ci[(fatal_non_cvd_post_stroke_i_ci+fatal_cvd_post_stroke_i_ci)>1] = 1-fatal_cvd_post_stroke_i_ci[(fatal_non_cvd_post_stroke_i_ci+fatal_cvd_post_stroke_i_ci)>1]
	# if stroke h adds up to more than one make correction in fatal cvd
	fatal_non_cvd_post_stroke_h_ci[fatal_non_cvd_post_stroke_h_ci>1 | is.na(fatal_non_cvd_post_stroke_h_ci)] = 1
	fatal_cvd_post_stroke_h_ci[is.infinite(fatal_cvd_post_stroke_h_ci) | is.na(fatal_cvd_post_stroke_h_ci)] = 1
	fatal_cvd_post_stroke_h_ci[(fatal_cvd_post_stroke_h_ci+fatal_non_cvd_post_stroke_h_ci)>1] = 1-fatal_non_cvd_post_stroke_h_ci[(fatal_cvd_post_stroke_h_ci+fatal_non_cvd_post_stroke_h_ci)>1]
	
	all_fe_ci = fe_mi_ci + fe_stroke_i_ci + fe_stroke_h_ci + fe_fatal_cvd_ci + fe_fatal_non_cvd_ci
	post_mi = fatal_cvd_post_mi_ci + fatal_non_cvd_post_mi_ci
	post_stroke_i = fatal_cvd_post_stroke_i_ci + fatal_non_cvd_post_stroke_i_ci
	post_stroke_h = fatal_cvd_post_stroke_h_ci + fatal_non_cvd_post_stroke_h_ci
	
	transition_matrix_3d = vector("list", num_cycles)
	prev_scad = 1
	prev_post_mi = rep(1,num_cycles)
	prev_post_stroke_i = rep(1,num_cycles)
	prev_post_stroke_h = rep(1,num_cycles)
	
	for(cycle in 1:num_cycles){
		trans_mat_cycle = matrix(0,length(states),length(states),dimnames=list(states,states))
		trans_mat_cycle["fatal_cvd","fatal_cvd"] = 1
		trans_mat_cycle["fatal_non_cvd","fatal_non_cvd"] = 1
		# calculate probability of transitions from SCAD
		# (P(t)-P(t-1))/scad_pop(t-1) where P = cumulative incidence of event
		# first event MI
		trans_mat_cycle["SCAD","post_mi_1"] = clean_transition_probability((fe_mi_ci[cycle_length_days*cycle]-ifelse(cycle>1,fe_mi_ci[cycle_length_days*(cycle-1)],0))/prev_scad)
		# first event stroke (I)
		trans_mat_cycle["SCAD","post_stroke_i_1"] = clean_transition_probability((fe_stroke_i_ci[cycle_length_days*cycle]-ifelse(cycle>1,fe_stroke_i_ci[cycle_length_days*(cycle-1)],0))/prev_scad)
		# first event stroke (H)
		trans_mat_cycle["SCAD","post_stroke_h_1"] = clean_transition_probability((fe_stroke_h_ci[cycle_length_days*cycle]-ifelse(cycle>1,fe_stroke_h_ci[cycle_length_days*(cycle-1)],0))/prev_scad)
		# first event fatal CVD
		trans_mat_cycle["SCAD","fatal_cvd"] = clean_transition_probability((fe_fatal_cvd_ci[cycle_length_days*cycle]-ifelse(cycle>1,fe_fatal_cvd_ci[cycle_length_days*(cycle-1)],0))/prev_scad)
		# first event fatal non-CVD
		trans_mat_cycle["SCAD","fatal_non_cvd"] = clean_transition_probability((fe_fatal_non_cvd_ci[cycle_length_days*cycle]-ifelse(cycle>1,fe_fatal_non_cvd_ci[cycle_length_days*(cycle-1)],0))/prev_scad)
		# update previous SCAD
		prev_scad = prev_scad - prev_scad*sum(trans_mat_cycle["SCAD",])
		# SCAD = 1 - sum(moving out of SCAD)
		trans_mat_cycle["SCAD","SCAD"] = 1 - sum(trans_mat_cycle["SCAD",])
		# now deal with the transitions from post event states
		for(tunnel in 1:num_tunnels){
			mi_i = paste("post_mi",tunnel,sep="_")
			mi_j = ifelse(tunnel<num_tunnels,paste("post_mi",tunnel+1,sep="_"),paste("post_mi",tunnel,sep="_"))
			stroke_i_i = paste("post_stroke_i",tunnel,sep="_")
			stroke_i_j = ifelse(tunnel<num_tunnels,paste("post_stroke_i",tunnel+1,sep="_"),paste("post_stroke_i",tunnel,sep="_"))
			stroke_h_i = paste("post_stroke_h",tunnel,sep="_")
			stroke_h_j = ifelse(tunnel<num_tunnels,paste("post_stroke_h",tunnel+1,sep="_"),paste("post_stroke_h",tunnel,sep="_"))
			# if it is not possible to get this far in the model at this cycle then set transition probabilities to 0
			if(tunnel>=cycle){
				trans_mat_cycle[mi_i,"fatal_cvd"] = 0
				trans_mat_cycle[mi_i,"fatal_non_cvd"] = 0
				trans_mat_cycle[stroke_i_i,"fatal_cvd"] = 0
				trans_mat_cycle[stroke_i_i,"fatal_non_cvd"] = 0
				trans_mat_cycle[stroke_h_i,"fatal_cvd"] = 0
				trans_mat_cycle[stroke_h_i,"fatal_non_cvd"] = 0
				# just stay in state
				trans_mat_cycle[mi_i,mi_i] = 1 
				trans_mat_cycle[stroke_i_i,stroke_i_i] = 1 
				trans_mat_cycle[stroke_h_i,stroke_h_i] = 1 
			} else {
				# (P(t)-P(t-1))/pop_cohort(t-1) where P = cumulative incidence of event for cohort who had their first event together	
				# post MI transitions
				trans_mat_cycle[mi_i,"fatal_cvd"] = clean_transition_probability((fatal_cvd_post_mi_ci[cycle_length_days*tunnel,cycle-tunnel]-ifelse(tunnel>1,fatal_cvd_post_mi_ci[cycle_length_days*(tunnel-1),cycle-tunnel],0))/prev_post_mi[cycle-tunnel])
				trans_mat_cycle[mi_i,"fatal_non_cvd"] = clean_transition_probability((fatal_non_cvd_post_mi_ci[cycle_length_days*tunnel,cycle-tunnel]-ifelse(tunnel>1,fatal_non_cvd_post_mi_ci[cycle_length_days*(tunnel-1),cycle-tunnel],0))/prev_post_mi[cycle-tunnel])
				prev_post_mi[cycle-tunnel] = prev_post_mi[cycle-tunnel] - prev_post_mi[cycle-tunnel]*sum(trans_mat_cycle[mi_i,])
				# post stroke (I) tranistions
				trans_mat_cycle[stroke_i_i,"fatal_cvd"] = clean_transition_probability((fatal_cvd_post_stroke_i_ci[cycle_length_days*tunnel,cycle-tunnel]-ifelse(tunnel>1,fatal_cvd_post_stroke_i_ci[cycle_length_days*(tunnel-1),cycle-tunnel],0))/prev_post_stroke_i[cycle-tunnel])
				trans_mat_cycle[stroke_i_i,"fatal_non_cvd"] = clean_transition_probability((fatal_non_cvd_post_stroke_i_ci[cycle_length_days*tunnel,cycle-tunnel]-ifelse(tunnel>1,fatal_non_cvd_post_stroke_i_ci[cycle_length_days*(tunnel-1),cycle-tunnel],0))/prev_post_stroke_i[cycle-tunnel])
				prev_post_stroke_i[cycle-tunnel] = prev_post_stroke_i[cycle-tunnel] - prev_post_stroke_i[cycle-tunnel]*sum(trans_mat_cycle[stroke_i_i,])
				# post stroke (H) transitions
				trans_mat_cycle[stroke_h_i,"fatal_cvd"] = clean_transition_probability((fatal_cvd_post_stroke_h_ci[cycle_length_days*tunnel,cycle-tunnel]-ifelse(tunnel>1,fatal_cvd_post_stroke_h_ci[cycle_length_days*(tunnel-1),cycle-tunnel],0))/prev_post_stroke_h[cycle-tunnel])
				trans_mat_cycle[stroke_h_i,"fatal_non_cvd"] = clean_transition_probability((fatal_non_cvd_post_stroke_h_ci[cycle_length_days*tunnel,cycle-tunnel]-ifelse(tunnel>1,fatal_non_cvd_post_stroke_h_ci[cycle_length_days*(tunnel-1),cycle-tunnel],0))/prev_post_stroke_h[cycle-tunnel])
				prev_post_stroke_h[cycle-tunnel] = prev_post_stroke_h[cycle-tunnel] - prev_post_stroke_h[cycle-tunnel]*sum(trans_mat_cycle[stroke_h_i,])
				# probability of moving to next tunnel is 1 - probability something else happened
				trans_mat_cycle[mi_i,mi_j] = 1 - sum(trans_mat_cycle[mi_i,]) 
				trans_mat_cycle[stroke_i_i,stroke_i_j] = 1 - sum(trans_mat_cycle[stroke_i_i,]) 
				trans_mat_cycle[stroke_h_i,stroke_h_j] = 1 - sum(trans_mat_cycle[stroke_h_i,]) 
			}
		}
		transition_matrix_3d[[cycle]] = trans_mat_cycle
	}
	return(transition_matrix_3d)
}

##########################################################################################
# calculate costs attached to model states
##########################################################################################

calculate_baseline_cost = function(patient, cost_params_specific){
	baseline_cost = cost_params_specific[1,"_cons"]
	baseline_cost = baseline_cost + cost_params_specific[1,"sex"]*patient[1,"sex"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_renal"]*patient[1,"hist_renal"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_cancer"]*patient[1,"hist_cancer"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_copd"]*patient[1,"hist_copd"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_pad"]*patient[1,"hist_pad"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_af"]*patient[1,"hist_af"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_hf"]*patient[1,"hist_hf"]
	baseline_cost = baseline_cost + cost_params_specific[1,"hist_liver"]*patient[1,"hist_liver"]
	baseline_cost = baseline_cost + cost_params_specific[1,"diabetes"]*patient[1,"diabetes"]
	baseline_cost = baseline_cost + cost_params_specific[1,"age0"]*patient[1,"age0"]
	baseline_cost = baseline_cost + cost_params_specific[1,"CHD"]*patient[1,"dx7CHD"]
	baseline_cost = baseline_cost + cost_params_specific[1,"NSTEMI"]*patient[1,"dx7NSTEMI"]
	baseline_cost = baseline_cost + cost_params_specific[1,"STEMI"]*patient[1,"dx7STEMI"]
	baseline_cost = baseline_cost + cost_params_specific[1,"UA"]*patient[1,"dx7UA"]
	
	return(baseline_cost)
}

create_cost_matrix = function(patient, cost_params, prediction_years, cycle_length_days){
	num_cycles = ceiling((prediction_years*365)/cycle_length_days)+1
	num_tunnels = num_cycles - 2
	post_mi_states = paste("post_mi",1:num_tunnels,sep="_")
	post_stroke_i_states = paste("post_stroke_i",1:num_tunnels,sep="_")
	post_stroke_h_states = paste("post_stroke_h",1:num_tunnels,sep="_")
	states = c("SCAD",post_mi_states,post_stroke_i_states,post_stroke_h_states,"fatal_cvd","fatal_non_cvd")
	
	cost_matrix = matrix(0,nrow=num_cycles,ncol=length(states),dimnames=list(1:num_cycles,states))
	cost_matrices = list(cost_matrix,cost_matrix,cost_matrix)
	names(cost_matrices) = c("total","cvd","chd")

	for(type in names(cost_matrices)){
		baseline_cost = calculate_baseline_cost(patient,cost_params[[type]])
		
		for(cycle in 1:num_cycles){
			# add time period cost every cycle
			baseline_cost = baseline_cost + cost_params[[type]][1,"timeperiod"]
			
			# add costs in non_tunnel states
			# SCAD
			cost_matrices[[type]][cycle,"SCAD"] = baseline_cost
			# fatal CVD
			cost_matrices[[type]][cycle,"fatal_cvd"] = baseline_cost + cost_params[[type]][1,"fatalCVD"]
			# fatal non-CVD		
			cost_matrices[[type]][cycle,"fatal_non_cvd"] = baseline_cost + cost_params[[type]][1,"fatalNONCVD"]
			
			for(tunnel in 1:num_tunnels){
				if(tunnel==1){
					cost_matrices[[type]][cycle,"post_mi_1"] = baseline_cost + cost_params[[type]][1,"firsteventMI"] + cost_params[[type]][1,"MIdiabetes"]*patient[1,"diabetes"]
					cost_matrices[[type]][cycle,"post_stroke_i_1"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_I"]
					cost_matrices[[type]][cycle,"post_stroke_h_1"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_H"]
				}else if(tunnel==2){
					cost_matrices[[type]][cycle,"post_mi_2"] = baseline_cost + cost_params[[type]][1,"firsteventMI2"] + cost_params[[type]][1,"MIdiabetes2"]*patient[1,"diabetes"]
					cost_matrices[[type]][cycle,"post_stroke_i_2"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_I2"]
					cost_matrices[[type]][cycle,"post_stroke_h_2"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_H2"]
				}else if(tunnel==3){
					cost_matrices[[type]][cycle,"post_mi_3"] = baseline_cost + cost_params[[type]][1,"firsteventMI3"] + cost_params[[type]][1,"MIdiabetes3"]*patient[1,"diabetes"]
					cost_matrices[[type]][cycle,"post_stroke_i_3"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_I3"]
					cost_matrices[[type]][cycle,"post_stroke_h_3"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_H3"]
				}else if(tunnel==4){
					cost_matrices[[type]][cycle,"post_mi_4"] = baseline_cost + cost_params[[type]][1,"firsteventMI4"] + cost_params[[type]][1,"MIdiabetes4"]*patient[1,"diabetes"]
					cost_matrices[[type]][cycle,"post_stroke_i_4"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_I4"]
					cost_matrices[[type]][cycle,"post_stroke_h_4"] = baseline_cost + cost_params[[type]][1,"firsteventStroke_H4"]
				}else{
					cost_matrices[[type]][cycle,paste("post_mi_",tunnel,sep="")] = baseline_cost + cost_params[[type]][1,"feMI"] + cost_params[[type]][1,"feMIdiabetes"]*patient[1,"diabetes"]
					cost_matrices[[type]][cycle,paste("post_stroke_i_",tunnel,sep="")] = baseline_cost + cost_params[[type]][1,"feSTROKE_I"]
					cost_matrices[[type]][cycle,paste("post_stroke_h_",tunnel,sep="")] = baseline_cost + cost_params[[type]][1,"feSTROKE_H"]
				} 
			}
		}
	}
	return(cost_matrices)
}


##########################################################################################
# calculate HRQL attached to model states
##########################################################################################

create_hrql_matrix = function(patient, hrql_params_iteration, prediction_years, cycle_length_days){
	num_cycles = ceiling((prediction_years*365)/cycle_length_days)+1
	num_tunnels = num_cycles - 2
	post_mi_states = paste("post_mi",1:num_tunnels,sep="_")
	post_stroke_i_states = paste("post_stroke_i",1:num_tunnels,sep="_")
	post_stroke_h_states = paste("post_stroke_h",1:num_tunnels,sep="_")
	states = c("SCAD",post_mi_states,post_stroke_i_states,post_stroke_h_states,"fatal_cvd","fatal_non_cvd")
	hrql_matrix_1yr = matrix(0,nrow=num_cycles,ncol=length(states),dimnames=list(1:num_cycles,states))
	hrql_matrix_const = matrix(0,nrow=num_cycles,ncol=length(states),dimnames=list(1:num_cycles,states))
	baseline_hrql = hrql_params_iteration[1,"_cons"] + hrql_params_iteration[1,"angina"]
	baseline_hrql = baseline_hrql +  hrql_params_iteration[1,"male"]*(1-patient[1,"sex"])
	baseline_hrql = baseline_hrql +  hrql_params_iteration[1,"hf"]*patient[1,"hist_hf"]
	baseline_hrql = baseline_hrql +  hrql_params_iteration[1,"age"]*(patient[1,"age0_ori"] - 48)
	baseline_hrql_const = baseline_hrql +  hrql_params_iteration[1,"stroke"]*patient[1,"hist_stroke"] 
	baseline_hrql_const = baseline_hrql_const +  hrql_params_iteration[1,"old_mi"]*min(1,(patient[1,"dx7CHD"]+patient[1,"dx7NSTEMI"]+patient[1,"dx7STEMI"]+patient[1,"recurrent_mi"])) 
	# adjust for cycle length
	baseline_hrql = baseline_hrql*cycle_length_days/365 
	baseline_hrql_const = baseline_hrql_const*cycle_length_days/365
	
	for(cycle in 1:num_cycles){
		baseline_hrql = baseline_hrql + hrql_params_iteration[1,"age"]*(cycle_length_days/365)
		hrql_matrix_1yr[cycle,"SCAD"] = baseline_hrql
		hrql_matrix_const[cycle,"SCAD"] = baseline_hrql
		for(tunnel in 1:num_tunnels){
			if((tunnel-1)*cycle_length_days<365){
				if(tunnel*cycle_length_days <= 365){
					proportion = cycle_length_days/365
				} else {
					proportion = (cycle_length_days-((tunnel*cycle_length_days)-365))/365
				}
				hrql_matrix_1yr[cycle,paste("post_mi_",tunnel,sep="")] = baseline_hrql + hrql_params_iteration[1,"acute_mi"]*proportion		
				hrql_matrix_1yr[cycle,paste("post_stroke_i_",tunnel,sep="")] = baseline_hrql + hrql_params_iteration[1,"stroke"]*proportion		
				hrql_matrix_1yr[cycle,paste("post_stroke_h_",tunnel,sep="")] = baseline_hrql + hrql_params_iteration[1,"stroke"]*proportion			
				hrql_matrix_const[cycle,paste("post_mi_",tunnel,sep="")] = baseline_hrql_const + hrql_params_iteration[1,"acute_mi"]*proportion + hrql_params_iteration[1,"old_mi"]*((cycle_length_days/365)-proportion)		
			}else{
				hrql_matrix_1yr[cycle,paste("post_mi_",tunnel,sep="")] = baseline_hrql		
				hrql_matrix_1yr[cycle,paste("post_stroke_i_",tunnel,sep="")] = baseline_hrql		
				hrql_matrix_1yr[cycle,paste("post_stroke_h_",tunnel,sep="")] = baseline_hrql
				hrql_matrix_const[cycle,paste("post_mi_",tunnel,sep="")] = baseline_hrql_const + hrql_params_iteration[1,"old_mi"]*cycle_length_days/365		
			}
			#only add stroke decrement if not had stroke at baseline
			hrql_matrix_const[cycle,paste("post_stroke_i_",tunnel,sep="")] = baseline_hrql_const + (1-patient[1,"hist_stroke"])*hrql_params_iteration[1,"stroke"]*cycle_length_days/365		
			hrql_matrix_const[cycle,paste("post_stroke_h_",tunnel,sep="")] = baseline_hrql_const + (1-patient[1,"hist_stroke"])*hrql_params_iteration[1,"stroke"]*cycle_length_days/365		
		}
	}	
	hrql_matrix = list(hrql_matrix_1yr, hrql_matrix_const)
	names(hrql_matrix) = c("hrql_matrix_1yr", "hrql_matrix_const")
	return(hrql_matrix)
}

##########################################################################################
# calculate model results for a particular intervention
##########################################################################################

calculate_intervention_results = function(prediction_years, cycle_length_days, data_years, 
		survival_params, cost_matrix, hrql_matrix, patient, model_cycles, discount_factors,
		treatment_HR, scenario, patient_number){
	# create the transition matrix
	transition_matrix_3d = create_3d_state_transition_matrix(patient, prediction_years, cycle_length_days, survival_params, data_years, treatment_HR, scenario)
	
	# create a placeholder to hold the markov trace
	markov_trace = array(NA,c(model_cycles,nrow(transition_matrix_3d[[1]])),dimnames = list(1:model_cycles,row.names(transition_matrix_3d[[1]])))
	
	# set up the initial row of the markov trace
	population = c(1,rep(0,nrow(transition_matrix_3d[[1]])-1))
	markov_trace[1,] = population
	
	# calculate the markov trace and write to output file
	for(cycle in 1:(model_cycles-1)){
		markov_trace[cycle+1,] = t(markov_trace[cycle,]) %*% transition_matrix_3d[[cycle]]
	}
	
	# calculate lifeyears as the sum of those in non fatal states
	life_years = rowSums(markov_trace[,!grepl("fatal",colnames(markov_trace))])*cycle_length_days/365
	
	## Should delete all references to HR here
	
	print(paste("patient: ",patient_number," - scenario: ",scenario," - baseline age: ",round(patient[1,"age0"]+70,2)," - life expectancy = ", round(patient[1,"age0"]+70+sum(life_years),2),sep=""))
	
	qalys_1yr = rowSums(markov_trace * hrql_matrix[["hrql_matrix_1yr"]])
	
	qalys_const = rowSums(markov_trace * hrql_matrix[["hrql_matrix_const"]])
	
	# create result object with SCAD, cost, cvd cost, life years and utilities columns + discounted at 3.5%
	# create modified markov trace to remove people dead in previous cycles
	dead = markov_trace[,grepl("fatal",colnames(markov_trace))]
	dead_prev = rbind(c(0,0),dead[-nrow(dead),])
	modified_markov_trace = cbind(markov_trace[,!grepl("fatal",colnames(markov_trace))],dead-dead_prev)
	total_costs = rowSums(modified_markov_trace * cost_matrix[["total"]])
	cvd_costs = rowSums(modified_markov_trace * cost_matrix[["cvd"]])
	chd_costs = rowSums(modified_markov_trace * cost_matrix[["chd"]])
	
	scad = markov_trace[,"SCAD"]
	fe_mi = markov_trace[,"post_mi_1"]
	fe_stroke_i = markov_trace[,"post_stroke_i_1"]
	fe_stroke_h = markov_trace[,"post_stroke_h_1"]
	fatal_cvd = markov_trace[,"fatal_cvd"]
	fatal_non_cvd = markov_trace[,"fatal_non_cvd"]
	cycle_mi = rowSums(markov_trace[,grepl("post_mi",colnames(markov_trace))])
	cycle_stroke_i = rowSums(markov_trace[,grepl("post_stroke_i",colnames(markov_trace))])
	cycle_stroke_h = rowSums(markov_trace[,grepl("post_stroke_h",colnames(markov_trace))])
	
	# discount and then take cumulative sums and bind together into results object present per patient
	results = cbind(scad,cycle_mi,cycle_stroke_i,cycle_stroke_h,cumsum(fe_mi),cumsum(fe_stroke_i),cumsum(fe_stroke_h),fatal_cvd,fatal_non_cvd,cumsum(life_years),cumsum(qalys_1yr),cumsum(qalys_const),cumsum(total_costs),cumsum(cvd_costs),cumsum(chd_costs),cumsum(discount_factors*life_years),cumsum(discount_factors*qalys_1yr),cumsum(discount_factors*qalys_const),cumsum(discount_factors*total_costs),cumsum(discount_factors*cvd_costs),cumsum(discount_factors*chd_costs))
	colnames(results) = c("cycle_SCAD","cycle_mi","cycle_stroke_i","cycle_stroke_h","fe_mi","fe_stroke_i","fe_stroke_h","fatal_cvd","fatal_non_cvd","life_years","qalys_1year","qalys_const","total_costs","cvd_costs","chd_costs","discounted_life_years","discounted_qalys_1year","discounted_qalys_const","discounted_total_costs","discounted_cvd_costs","discounted_chd_costs") 
	
	# Again, get rid of references to treatment HR here
	
	colnames(results) = paste(colnames(results),scenario,sep="_")
	return(results)
}

##########################################################################################
# load patient profile from csv file
##########################################################################################
load_patient = function(patient_file, patient_number){
	patient = read.csv(patient_file,row.names=1)[patient_number,]
	# R replaces : with . in column names undo this
	names(patient) = gsub("\\.",":",names(patient))
	
	# add standardised versions of variables for use in model
	standardisation_table = read.csv("input_data/standardisation.csv",row.names=1)
	for(var in grep("_ori",names(patient),value=TRUE)){
		new_var_name = gsub("_ori", "", var)
		patient[,new_var_name] = (patient[,var]-standardisation_table["mu",new_var_name])/standardisation_table["sigma",new_var_name]
	}
	# for individuals as opposed to populations fill in the age sex interaction
	if(patient[,"sex"]==1){
		patient[,"sex:age0"]=patient[,"age0"]
	} else if (patient[,"sex"]==1) {
		patient[,"sex:age0"]=0
	}
	# for populations the age0:sex variable contains the mean difference in age by sex mutiplied by
	# the proportion of the population where sex==1
	
	patient[,"(Intercept)"] = 1
	return(as.matrix(patient, nrow=1))
}


##########################################################################################
# run the model for a particular patient profile
##########################################################################################

# patient number indicates which decile to run model for
# iteration number indicates which PSA iteration to use
# iteration number of -1 indicates deterministic
run_model = function(patient_number, iteration_number, patient_group, patient_file="", life_tables_only=FALSE){
	print(paste("Running model for patient: ",patient_number, " iteration: ", iteration_number,sep=""))
	
	# set the model life cycle and the cycle length
	prediction_years = 70
	cycle_length_days = 90
	# decide how many years of data to base non-CVD hazards on
	if(life_tables_only){ data_years = 0 } else { data_years = 10 }
	
	# load up key model parameters from file these are: cost_params, cost_params_psa
	# hrql_params, hrql_params_psa, survival_params, survival_params_psa, 
	# patients_clinical and patients_deciles for upto 10,000 PSA iterations
	load(file="CALIBER_SCAD_params.RData")
	
	# initially set the model inputs to determisitic mean values
	survival_params_iteration = survival_params 
	cost_params_iteration = cost_params 
	hrql_params_iteration = hrql_params 
	
	# if we are running the model probabilistically update these parameters
	# to calculate the model for the given PSA iteration
	if(iteration_number > 0){
		for(i in names(survival_params_iteration)){
			survival_params_iteration[[i]] = t(as.matrix(survival_params_psa[[i]][iteration_number,]))
		}
		survival_params_iteration[["life_table_non_cvd_daily_hazards"]] = survival_params[["life_table_non_cvd_daily_hazards"]]
		for(i in names(cost_params_iteration)){
			cost_params_iteration[[i]] = t(as.matrix(cost_params_psa[[i]][iteration_number,]))
		}
		hrql_params_iteration = t(as.matrix(hrql_params_psa[iteration_number,]))
	}

	# we need to run the model for some specific set of patient characteristics
	# either risk groups or clinically selected patient characteristics
	if(patient_group == "deciles"){
		patient = patients_deciles[[patient_number]]
	} else if(patient_group == "clinical"){
		patient = patients_clinical[[patient_number]]
	} else if(patient_group == "manual"){
		patient = load_patient(patient_file, patient_number)
	}
	
	# create total and CVD cost matrix of same dimension
	cost_matrix = create_cost_matrix(patient, cost_params_iteration, prediction_years, cycle_length_days)
	
	# create utility matrix of same dimension
	hrql_matrix = create_hrql_matrix(patient, hrql_params_iteration, prediction_years, cycle_length_days)
	
	# calculate the number of model cycles based on the model lifetime and the cycle length
	model_cycles = ceiling((prediction_years*365)/cycle_length_days)+1
	
	# set the discount rate
	annual_discount_rate = 0.035
	cycle_discount_rate = (1+annual_discount_rate)^(1/(365/cycle_length_days))-1
	discount_factors = 1/(1+cycle_discount_rate)^(1:model_cycles)
	
	# Create the time-dependent hazard vectors
	source("timedep_params.R")
	
	
	# basecase no intervention results
	results = calculate_intervention_results(prediction_years, cycle_length_days, data_years, 
			survival_params_iteration, cost_matrix, hrql_matrix, patient, model_cycles, discount_factors,
			treatment_HR = non_treatment_HR, scenario = "basecase", patient_number)
	
	scenarios = c("fe_cvd")	
	
	
		for(scenario in scenarios){
			# calculate model results for each treatment (represented by a HR) under each scenario 
			results = cbind(results,
				calculate_intervention_results(prediction_years, cycle_length_days, data_years, 
				survival_params_iteration, cost_matrix, hrql_matrix, patient, model_cycles, discount_factors,
				on_treatment_HR, scenario, patient_number))
		}

	
	if(iteration_number > 0){
	  dir.create(paste0("output/model_results/",patient_group,"/"), recursive=TRUE,showWarnings=FALSE)
		filename = paste("output/model_results/",patient_group,"/ce_results_pat_",patient_number,"_iteration_",iteration_number,".csv",sep="")
	} else {
	  dir.create(paste0("output/model_summary/",patient_group,"/"), recursive=TRUE,showWarnings=FALSE)
		filename = paste("output/model_summary/",patient_group,"/ce_results_pat_",patient_number,"_deterministic.csv",sep="")
	}
	write.csv(results,file=filename)	
}
