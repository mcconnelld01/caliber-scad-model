source("timedep_functions.R")

## Parameters for testing only
prediction_years=31
cycle_length_days=1

## Enter the parameters

fe_mi_HR=timedep_trt_eff(
  "start_yr"=5,
  "end_yr"=5,
  "startHR"=0.5,
  "endHR"=1,
  "annual_discontinuation_rate"=0.05
)

fe_stroke_i_HR=timedep_trt_eff(
    "start_yr"=5,
    "end_yr"=5,
    "startHR"=0.5,
    "endHR"=1,
    "annual_discontinuation_rate"=0.05
  )
  
fe_fatal_cvd_HR=fe_stroke_i_HR

fe_fatal_cvd_HR=fatal_cvd_post_mi_HR=fatal_cvd_post_stroke_i_HR=
  fatal_cvd_post_stroke_h_HR=fe_stroke_i_HR



## The code below simply constructs the required data frames - this could be inserted intothe Markov model bit



on_treatment_HR=data.frame(
  "fe_mi_haz"=fe_mi_HR,
  "fe_stroke_i_haz"=fe_stroke_i_HR,
  "fe_fatal_cvd_haz"=fe_fatal_cvd_HR,
  "fatal_cvd_post_mi_haz"=fatal_cvd_post_mi_HR,
  "fatal_cvd_post_stroke_i_haz"=fatal_cvd_post_stroke_i_HR,
  "fatal_cvd_post_stroke_h_haz"=fatal_cvd_post_stroke_h_HR)



# Create a 'no treatment effect' data frame with all hazard ratios equal to 1
non_treatment_HR=on_treatment_HR
non_treatment_HR[TRUE==TRUE]=1



