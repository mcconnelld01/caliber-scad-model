# Estimate survival models to calculate transition probabilities in the SCAD 
# population these will be combined in a competing risks framework and used in
# a markov cohort state transition model
# 
# Author: Miqdad Asaria
# Date: 2014
###############################################################################
library(mitools)
library(survival)
library(flexsurv)

##########################################################################################
## generalised gamma model
##########################################################################################

# extracts the coefficients from the generalised gamma model
# if psa_iterations > 1 then generates the specified number of 
# probabilistics draws in place of mean values for these coeffs
get_gengamma_params = function(model, psa_iterations, subdist="gengamma", AIC, loglik){
	if(psa_iterations == 1){
		betas = matrix(model$coef,nrow=1,byrow=TRUE, dimnames=list("coefficients",names(model$coef)))
	} else {
		set.seed(123)
		cholesky = chol(model$var)
		randoms = matrix(rnorm(length(model$coef)*psa_iterations),nrow=psa_iterations)
		betas = matrix(rep(model$coef,psa_iterations),nrow=psa_iterations,byrow=TRUE) + randoms%*%cholesky
	}
	mu = matrix(betas[,"mu"],nrow=nrow(betas),byrow=TRUE)
	if(subdist=="gengamma"){
		sigma = matrix(exp(betas[,"sigma"]),nrow=nrow(betas),byrow=TRUE)
		Q = matrix(betas[,"Q"],nrow=nrow(betas),byrow=TRUE)
	}else if(subdist=="lognormal"){
		sigma = matrix(exp(betas[,"sigma"]),nrow=nrow(betas),byrow=TRUE)
		Q = matrix(0,nrow=nrow(betas),byrow=TRUE)
	}else if(subdist=="weibull"){
		sigma = matrix(exp(betas[,"sigma"]),nrow=nrow(betas),byrow=TRUE)
		Q = matrix(1,nrow=nrow(betas),byrow=TRUE)
	}else if(subdist=="exponential"){
		sigma = matrix(1,nrow=nrow(betas),byrow=TRUE)
		Q = matrix(1,nrow=nrow(betas),byrow=TRUE)
	}
	names_beta = setdiff(colnames(betas),c("mu","sigma","Q"))
	betas = matrix(betas[,names_beta],nrow=nrow(betas),dimnames=list(1:nrow(betas),names_beta))
	params = cbind(betas,mu,sigma,Q,mean(AIC),mean(loglik))
	colnames(params) = c(names_beta,"mu","sigma","Q","AIC","loglik")
	return(params)
}

# estimates the generalised gamma model for the data and outcome specified returning model coeffs
# if no covariates are to be used then covariates should be specified as "1" else the required covars
# should be given in standard R forumla notation. if a cached model estimate exists and the cached flag 
# is true this pre-calculated model is used, otherwise the model is estimated and saved to disk for future use
# specifying an appropriate subdist allows the estimation of a model nested in the generalised gamma model 
# subdist must be one of: gengamma, lognormal, weibull or exponential 
# if re-estimating a model use_initial_values=TRUE uses previously estimated values as starting values
# when subdist not equal to gengamma use_initial_values must be set to TRUE 
estimate_gengamma_model = function(time_var, outcome_var, covariates, data, psa_iterations, cached=TRUE, subdist="gengamma", use_initial_values=TRUE){
	formula = as.formula(paste("Surv(",time_var,",",outcome_var,") ~ ",covariates,sep=""))
	if(nchar(covariates)>1){ cv = "covars"	} else { cv = "nocovars" }	
	filename = paste("parameter_estimates/",subdist,"_",cv,"_",outcome_var,".RData",sep="")
	gen_gamma_filename = paste("parameter_estimates/","gengamma","_",cv,"_",outcome_var,".RData",sep="")
	# this takes really really long to run so just load a pre-saved version if we have one
	if(cached){
		load(filename)
	} else {
		if(use_initial_values | subdist!="gengamma"){
			# load standard gengamma model to use for initial values
			load(gen_gamma_filename)
			saved_gg = gg
		}
		gg = vector("list", length(data))
		for(i in 1:length(data)){
			if(subdist=="gengamma" & !use_initial_values){
				gg[[i]] = flexsurvreg(formula = formula, dist="gengamma", data=data[[i]])
			}else if(subdist=="gengamma"){
				initial_values = saved_gg[[i]]$res[,"est"]
				gg[[i]] = flexsurvreg(formula = formula, dist="gengamma", data=data[[i]], inits=initial_values)
			}else if(subdist=="lognormal"){
				initial_values = saved_gg[[i]]$res[,"est"]
				initial_values["Q"] = 0	
				gg[[i]] = flexsurvreg(formula = formula, dist="gengamma", data=data[[i]], inits=initial_values, fixedpars=c(3))
			}else if(subdist=="weibull"){
				initial_values = saved_gg[[i]]$res[,"est"]
				initial_values["Q"] = 1
				gg[[i]] = flexsurvreg(formula = formula, dist="gengamma", data=data[[i]], inits=initial_values, fixedpars=c(3))
			}else if(subdist=="exponential"){
				initial_values = saved_gg[[i]]$res[,"est"]
				initial_values["Q"] = 1
				initial_values["sigma"] = 1
				gg[[i]] = flexsurvreg(formula = formula, dist="gengamma", data=data[[i]], inits=initial_values, fixedpars=c(2,3))
			}
		}
		save(gg,file=filename)
	}
	coefs = MIextract(gg, fun=coef)
	# remove fixed parameters as they are not estimated and so not in vcov
	if(subdist=="lognormal" | subdist=="weibull"){
		for(i in 1:length(data)){
			coefs[[i]] = coefs[[i]][-grep("Q",names(coefs[[i]]))]
		}
	}else if(subdist=="exponential"){
		for(i in 1:length(data)){
			coefs[[i]] = coefs[[i]][-grep("Q",names(coefs[[i]]))]
			coefs[[i]] = coefs[[i]][-grep("sigma",names(coefs[[i]]))]
		}
	}
	vars = MIextract(gg, fun=vcov)
	model = MIcombine(coefs, vars)
	AIC = vector("numeric",length(data))
	loglik = vector("numeric",length(data))
	for(i in 1:length(data)){
		AIC[i] = gg[[i]]$AIC
		loglik[i] = gg[[i]]$loglik
	}
	params = get_gengamma_params(model, psa_iterations, subdist, AIC, loglik)
	rm(gg)
	return(params)
}

##########################################################################################
## survival analysis to estimate risk equations
##########################################################################################
# loads saved survival analysis data set
get_survival_data = function(){
	load("input_data/survival_data.RData")
	return(survival_data)
}

# function to estimate the survival models that comprise our 11 risk equations
# returning the coefficients of these risk equations in a survival parameters obeject
estimate_hazard_models = function(covars=TRUE, psa_iterations=1, cached=TRUE, use_initial_values=TRUE){
	data = get_survival_data()
	fe_data = data[["fe_data"]]
	post_mi_mort_data = data[["post_mi_mort_data"]]
	post_stroke_i_mort_data = data[["post_stroke_i_mort_data"]]
	post_stroke_h_mort_data = data[["post_stroke_h_mort_data"]]

	# set up the model covariates to use to estimate different hazard functions
	if(covars){
		fe_mi_covariates_list = "sex+age0+age0:sex+IMD5+dx7+earlyPCI+earlyCABG+recurrent_mi+nitrates_long+smcat+hypertension+diabetes+hist_hf+hist_pad+hist_af+hist_stroke+hist_renal+hist_copd+hist_cancer+hist_liver+depression+hist_anxiety+pulse_rate+HDL+TCHOL+CREAT+WCC+HGB"
		fe_stroke_i_covariates_list = "sex+age0+age0:sex+IMD5+dx7+earlyPCI+earlyCABG+recurrent_mi+nitrates_long+smcat+hypertension+diabetes+hist_hf+hist_pad+hist_af+hist_stroke+hist_renal+hist_copd+hist_cancer+hist_liver+depression+hist_anxiety+pulse_rate+HDL+TCHOL+CREAT+WCC+HGB"
		fe_stroke_h_covariates_list = "sex+age0+age0:sex"
		fe_fatal_cvd_covariates_list = "sex+age0+age0:sex+IMD5+dx7+earlyPCI+earlyCABG+recurrent_mi+nitrates_long+smcat+hypertension+diabetes+hist_hf+hist_pad+hist_af+hist_stroke+hist_renal+hist_copd+hist_cancer+hist_liver+depression+hist_anxiety+pulse_rate+HDL+TCHOL+CREAT+WCC+HGB"
		fe_fatal_non_cvd_covariates_list = "sex+age0+age0:sex+IMD5+dx7+earlyPCI+earlyCABG+recurrent_mi+nitrates_long+smcat+hypertension+diabetes+hist_hf+hist_pad+hist_af+hist_stroke+hist_renal+hist_copd+hist_cancer+hist_liver+depression+hist_anxiety+pulse_rate+HDL+TCHOL+CREAT+WCC+HGB"
		se_covariates_list = "sex+age0+age0:sex"
	} else {
		fe_mi_covariates_list = "1"
		fe_stroke_i_covariates_list = "1"
		fe_stroke_h_covariates_list = "1"
		fe_fatal_cvd_covariates_list = "1"
		fe_fatal_non_cvd_covariates_list = "1"
		se_covariates_list = "1"
	}
	
	# estimate each parametric model 
	parametric_models = c("gengamma","lognormal","weibull","exponential")
	models = vector("list", length(parametric_models))
	names(models) = parametric_models
	for(dist in parametric_models){
		## estimate the five first event hazard functions for the five competing risks
		# non fatal MI
		fe_mi_params = estimate_gengamma_model("fe_time","fe_mi",fe_mi_covariates_list,fe_data,psa_iterations,cached,dist,use_initial_values)
		# non fatal stroke_i
		fe_stroke_i_params = estimate_gengamma_model("fe_time","fe_stroke_i",fe_stroke_i_covariates_list,fe_data,psa_iterations,cached,dist,use_initial_values)
		# non fatal stroke_h
		fe_stroke_h_params = estimate_gengamma_model("fe_time","fe_stroke_h",fe_stroke_h_covariates_list,fe_data,psa_iterations,cached,dist,use_initial_values)
		# fatal cvd
		fe_fatal_cvd_params = estimate_gengamma_model("fe_time","fe_fatal_cvd",fe_fatal_cvd_covariates_list,fe_data,psa_iterations,cached,dist,use_initial_values)
		# fatal non cvd
		fe_fatal_non_cvd_params = estimate_gengamma_model("fe_time","fe_fatal_non_cvd",fe_fatal_non_cvd_covariates_list,fe_data,psa_iterations,cached,dist,use_initial_values)
		# we use the life tables to extrapolate non cvd hazards beyond the observed period 
		# this gives more plausible estimates than using the limited data in our dataset 
		# to extrapolate with regards to the non-cvd mortaliity of older people
		lifetable = read.csv("input_data/life_tables.csv")
		lifetable = cbind(lifetable,lifetable[,2]-lifetable[,4],lifetable[,3]-lifetable[,5])
		life_table_non_cvd_daily_hazards = cbind(rep(-log(1-lifetable[,6])/365,each=365),rep(-log(1-lifetable[,7])/365,each=365))
		colnames(life_table_non_cvd_daily_hazards) = c("haz_non_cvd_men","haz_non_cvd_women")
			
		## now estimate mortality post MI and post stroke
		# post MI fatal cvd
		fatal_cvd_post_mi_params = estimate_gengamma_model("post_mi_mort_time","post_mi_cvd_mort",se_covariates_list,post_mi_mort_data,psa_iterations,cached,dist,use_initial_values)
		# post MI fatal non cvd
		fatal_non_cvd_post_mi_params = estimate_gengamma_model("post_mi_mort_time","post_mi_non_cvd_mort",se_covariates_list,post_mi_mort_data,psa_iterations,cached,dist,use_initial_values)
		# post stroke I fatal cvd
		fatal_cvd_post_stroke_i_params = estimate_gengamma_model("post_stroke_i_mort_time","post_stroke_i_cvd_mort",se_covariates_list,post_stroke_i_mort_data,psa_iterations,cached,dist,use_initial_values)
		# post stroke I fatal non cvd
		fatal_non_cvd_post_stroke_i_params = estimate_gengamma_model("post_stroke_i_mort_time","post_stroke_i_non_cvd_mort",se_covariates_list,post_stroke_i_mort_data,psa_iterations,cached,dist,use_initial_values)
		# post stroke H fatal cvd
		fatal_cvd_post_stroke_h_params = estimate_gengamma_model("post_stroke_h_mort_time","post_stroke_h_cvd_mort",se_covariates_list,post_stroke_h_mort_data,psa_iterations,cached,dist,use_initial_values)
		# post stroke H fatal cvd
		fatal_non_cvd_post_stroke_h_params = estimate_gengamma_model("post_stroke_h_mort_time","post_stroke_h_non_cvd_mort",se_covariates_list,post_stroke_h_mort_data,psa_iterations,cached,dist,use_initial_values)

		# create a combined result set to return
		survival_params = list(fe_mi_params,fe_stroke_i_params,fe_stroke_h_params,fe_fatal_cvd_params,fe_fatal_non_cvd_params,
						life_table_non_cvd_daily_hazards,		
						fatal_cvd_post_mi_params,fatal_non_cvd_post_mi_params,
						fatal_cvd_post_stroke_i_params,fatal_non_cvd_post_stroke_i_params,
						fatal_cvd_post_stroke_h_params,fatal_non_cvd_post_stroke_h_params)
		names(survival_params) = c("fe_mi_params","fe_stroke_i_params","fe_stroke_h_params","fe_fatal_cvd_params","fe_fatal_non_cvd_params",
				"life_table_non_cvd_daily_hazards",
				"fatal_cvd_post_mi_params","fatal_non_cvd_post_mi_params",
				"fatal_cvd_post_stroke_i_params","fatal_non_cvd_post_stroke_i_params",
				"fatal_cvd_post_stroke_h_params","fatal_non_cvd_post_stroke_h_params")
		models[[dist]] = survival_params
	}
	return(models)
}

##########################################################################################
## save survival parameters for 11 risk equations and probabilistic draws of these
##########################################################################################
save_survival_params = function(psa_iterations = 10000){
	covars = TRUE
	cached = TRUE
	all_survival_params = estimate_hazard_models(covars, psa_iterations, cached)
	survival_params_psa = vector("list", length(all_survival_params[["gengamma"]]))
	names(survival_params_psa) = names(all_survival_params[["gengamma"]])
	survival_params_psa[["fe_mi_params"]] = all_survival_params[["weibull"]][["fe_mi_params"]]
	survival_params_psa[["fe_stroke_i_params"]] = all_survival_params[["weibull"]][["fe_stroke_i_params"]]
	survival_params_psa[["fe_stroke_h_params"]] = all_survival_params[["exponential"]][["fe_stroke_h_params"]]
	survival_params_psa[["fe_fatal_cvd_params"]] = all_survival_params[["weibull"]][["fe_fatal_cvd_params"]]
	survival_params_psa[["fe_fatal_non_cvd_params"]] = all_survival_params[["weibull"]][["fe_fatal_non_cvd_params"]]
	survival_params_psa[["fatal_cvd_post_mi_params"]] = all_survival_params[["lognormal"]][["fatal_cvd_post_mi_params"]]
	survival_params_psa[["fatal_non_cvd_post_mi_params"]] = all_survival_params[["gengamma"]][["fatal_non_cvd_post_mi_params"]]
	survival_params_psa[["fatal_cvd_post_stroke_i_params"]] = all_survival_params[["gengamma"]][["fatal_cvd_post_stroke_i_params"]]
	survival_params_psa[["fatal_non_cvd_post_stroke_i_params"]] = all_survival_params[["gengamma"]][["fatal_non_cvd_post_stroke_i_params"]]
	survival_params_psa[["fatal_cvd_post_stroke_h_params"]] = all_survival_params[["lognormal"]][["fatal_cvd_post_stroke_h_params"]]
	survival_params_psa[["fatal_non_cvd_post_stroke_h_params"]] = all_survival_params[["weibull"]][["fatal_non_cvd_post_stroke_h_params"]]
	survival_params_psa[["life_table_non_cvd_daily_hazards"]] = all_survival_params[["exponential"]][["life_table_non_cvd_daily_hazards"]]
	save(survival_params_psa,file="parameter_estimates/survival_params_psa.RData")
	all_survival_params = estimate_hazard_models(covars, 1, cached)
	save(all_survival_params,file="parameter_estimates/survival_params_all.RData")
	survival_params = vector("list", length(all_survival_params[["gengamma"]]))
	names(survival_params) = names(all_survival_params[["gengamma"]])
	survival_params[["fe_mi_params"]] = all_survival_params[["weibull"]][["fe_mi_params"]]
	survival_params[["fe_stroke_i_params"]] = all_survival_params[["weibull"]][["fe_stroke_i_params"]]
	survival_params[["fe_stroke_h_params"]] = all_survival_params[["exponential"]][["fe_stroke_h_params"]]
	survival_params[["fe_fatal_cvd_params"]] = all_survival_params[["weibull"]][["fe_fatal_cvd_params"]]
	survival_params[["fe_fatal_non_cvd_params"]] = all_survival_params[["weibull"]][["fe_fatal_non_cvd_params"]]
	survival_params[["fatal_cvd_post_mi_params"]] = all_survival_params[["lognormal"]][["fatal_cvd_post_mi_params"]]
	survival_params[["fatal_non_cvd_post_mi_params"]] = all_survival_params[["gengamma"]][["fatal_non_cvd_post_mi_params"]]
	survival_params[["fatal_cvd_post_stroke_i_params"]] = all_survival_params[["gengamma"]][["fatal_cvd_post_stroke_i_params"]]
	survival_params[["fatal_non_cvd_post_stroke_i_params"]] = all_survival_params[["gengamma"]][["fatal_non_cvd_post_stroke_i_params"]]
	survival_params[["fatal_cvd_post_stroke_h_params"]] = all_survival_params[["lognormal"]][["fatal_cvd_post_stroke_h_params"]]
	survival_params[["fatal_non_cvd_post_stroke_h_params"]] = all_survival_params[["weibull"]][["fatal_non_cvd_post_stroke_h_params"]]
	survival_params[["life_table_non_cvd_daily_hazards"]] = all_survival_params[["exponential"]][["life_table_non_cvd_daily_hazards"]]
	save(survival_params,file="parameter_estimates/survival_params.RData")
}

##########################################################################################
# Take results of costs regression and generate cost parameters by taking probabilitstic
# draws from a normal distribution 
##########################################################################################

get_cost_params_psa = function(psa_iterations, type){
	set.seed(1234)
	cholesky = as.matrix(read.csv(paste("input_data/",type,"_cost_cholesky.csv",sep=""), row.names=1))
	betas = read.csv(paste("input_data/",type,"_cost.csv",sep=""), row.names=1)
	randoms = matrix(rnorm(nrow(betas)*psa_iterations),nrow=psa_iterations)
	betas_psa = matrix(rep(betas$coef,psa_iterations),nrow=psa_iterations,byrow=TRUE) + randoms%*%cholesky
	colnames(betas_psa) = rownames(betas)
	return(betas_psa)
}

save_cost_params = function(psa_iterations=10000){
	cost_params = list()
	cost_params_psa = list()
	for(type in c("total","cvd","chd")){
		cost_params[[type]] = t(as.matrix(read.csv(paste("input_data/",type,"_cost.csv",sep=""), row.names=1)))
		cost_params_psa[[type]] = get_cost_params_psa(psa_iterations,type) 
	}
	save(cost_params, file="parameter_estimates/cost_params.RData")
	save(cost_params_psa, file="parameter_estimates/cost_params_psa.RData")
}

##########################################################################################
# Take Sullivan utility regression output and convert into HRQoL per state
# beta distribution on the constant and a gamma distribution on the decrements
##########################################################################################
save_hrql_params = function(psa_iterations=10000){
	set.seed(1234)
	hrql = as.matrix(read.csv(paste("input_data/hrql.csv",sep=""), row.names=1))
	mean = hrql["_cons","coef"]
	variance = hrql["_cons","se"]^2
	beta_alpha = mean*((mean*(1-mean)/variance)-1)
	beta_beta = (1-mean)*((mean*(1-mean)/variance)-1)
	constant = rbeta(psa_iterations,beta_alpha,beta_beta)
	means = hrql[-1,"coef"]
	means[-grep("male",names(means))] = means[-grep("male",names(means))]*-1
	variances = hrql[-1,"se"]^2
	gamma_shape = means^2/variances
	gamma_scale = variances/means
	decrements = sapply(1:(nrow(hrql)-1),function(i){
				rgamma(psa_iterations, gamma_shape[i], scale=gamma_scale[i])				
			})
	colnames(decrements) = names(means)
	decrements[,-grep("male",colnames(decrements))] = decrements[,-grep("male",colnames(decrements))]*-1
	hrql_params_psa = cbind(constant,decrements)
	colnames(hrql_params_psa) = row.names(hrql)  
	hrql_params = t(as.matrix(hrql[,1]))
	save(hrql_params, file="parameter_estimates/hrql_params.RData")
	save(hrql_params_psa, file="parameter_estimates/hrql_params_psa.RData")
}