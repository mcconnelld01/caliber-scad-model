
## Enter the parameters in the following format:
# event_HR = timedep_trt_eff(
# "start_yr"=...
# "end_yr"=...
# "startHR"=...
# "end_HR"=...
# "annual_discontinuation_rate"=.....)
# where
# 1. start_yr denotes the year at which the treatment effect starts to change (note years start at 0 in the model)
# 2. startHR is the hazard ratio before the treatment effect changes 
# 3. end_yr is the the year at which the treatment effect has finished changing 
# 4. endHR is the hazard ratio after the treatment effect has finished changing
# 5. annual_discontinuation_rate should be self-explanatory
# You can enter fractions of a year if necessary for start_yr and end_yr.
# For a 'time-constant' treatment effect just set end_yr to be -1
# For a 'sudden change in effect' set start_HR=end_HR at whatever point in time you want this to happen


#Here is an example of a time-varying treatment effect

fe_mi_HR=timedep_trt_eff(
  "start_yr"=5,
  "end_yr"=10,
  "startHR"=0.6,
  "endHR"=0.9,
  "annual_discontinuation_rate"=0.05
)


# Here is a time-constant one, but with discontinuations: note that endHR will be ignored here
fe_stroke_i_HR=timedep_trt_eff(
    "start_yr"=-1,
    "end_yr"=-1,
    "startHR"=0.5,
    "endHR"=1,
    "annual_discontinuation_rate"=0.01
  )
  
# Here is an example of no treatment effect:


fe_fatal_cvd_HR=timedep_trt_eff(
  "start_yr"=-1,
  "end_yr"=-1,
  "startHR"=1,
  "endHR"=1,
  "annual_discontinuation_rate"=0.00
  )


# Out of laziness, I have set all the other treatment effects to be equal to fe_mi_HR here
fatal_cvd_post_mi_HR=fatal_cvd_post_stroke_i_HR=
  fatal_cvd_post_stroke_h_HR=fe_stroke_i_HR=fe_mi_HR








