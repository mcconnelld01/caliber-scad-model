# This function creates a vector with length equal to the number of cycles
# where each element is a per-cycle hazard ratio


timedep_trt_eff=function(start_yr=1,end_yr=1,startHR=1,endHR=1,annual_discontinuation_rate=0)
{
  
  time=prediction_years*365
  
  # Number of cycles
  n=round(time/cycle_length_days)
  
  # Proportion on treatment by cycle  
  per_cycle_disc=1-(1-annual_discontinuation_rate)^(cycle_length_days/365)
  on_trt=(1-per_cycle_disc)^seq(0,n)
  
  
  # Calculate time-dependent treatment effect for those still on treatment
  
  start_cycle=ceiling(start_yr*365/cycle_length_days)
  end_cycle=ceiling(end_yr*365/cycle_length_days)
  trt_effect=rep(1,n+1)
  
  
  for (t in 0:n)
  {
    # Apply the startHR until the waning effect begins
    if (t<start_cycle)
    {
      trt_effect[t+1]=startHR
    }
    # Gradually move the HR towards the value of endHR
    else if (t<end_cycle)
    {
      trt_effect[t+1]=startHR+(t+1-start_cycle)*(endHR-startHR)/(end_cycle-start_cycle)
    }
    else
    {
      trt_effect[t+1]=endHR
    }
  }
  
  # Combine treatment effect with discontinuations and return the cohort-level treatment effect
  
  return(trt_effect*on_trt+(1-on_trt))
}

# The function beolw takes as input a vector of per-cycle cumulative hazards (without treatment),
# as well as a vector of per-cycle treatment effects, and returns the cumulative hazards associated with 
# this intervention.

apply_timedep_eff = function(cumulative_hazards,trt_eff_vec)
{
  #n=length(cumulative_hazards)
  #trt_cumulative_hazards=rep(NA,n)
  chdiff=(cumulative_hazards-c(0,cumulative_hazards[-length(cumulative_hazards)]))
  trt_cumulative_hazards=cumsum(trt_eff_vec*chdiff)
  #trt_cumulative_hazards[1]=cumulative_hazards[1]
  #for (i in 2:n)
  #{
  #  trt_cumulative_hazards[i]=
  #            trt_cumulative_hazards[i-1]+
  #            trt_eff_vec[i]*(cumulative_hazards[i]-cumulative_hazards[i-1])
    
  #}
  return(trt_cumulative_hazards)
}
