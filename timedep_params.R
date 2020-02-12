
## Enter the parameters

fe_mi_HR=timedep_trt_eff(
  "start_yr"=-2,
  "end_yr"=-2,
  "startHR"=0.6,
  "endHR"=1,
  "annual_discontinuation_rate"=0.00
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






