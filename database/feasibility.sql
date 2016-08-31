-- AF prior to entry into SCAD cohort
SELECT f.total, wac.wac, wa.wa, ac.ac, wc.wc, dual.dual, w.w, a.a, c.c, single FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_af_intermittent WHERE dxscad_date >= dxaf_date) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wac FROM cohort_af_intermittent WHERE is_treated='WAC' AND dxscad_date >= dxaf_date) wac
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wa FROM cohort_af_intermittent WHERE is_treated='WA' AND dxscad_date >= dxaf_date) wa
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ac FROM cohort_af_intermittent WHERE is_treated='AC' AND dxscad_date >= dxaf_date) ac
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wc FROM cohort_af_intermittent WHERE is_treated='WC' AND dxscad_date >= dxaf_date) wc
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) dual FROM cohort_af_intermittent WHERE (is_treated='WA' OR is_treated='AC' OR is_treated='WC') AND dxscad_date >= dxaf_date) dual
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) w FROM cohort_af_intermittent WHERE is_treated='W' AND dxscad_date >= dxaf_date) w
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) a FROM cohort_af_intermittent WHERE is_treated='A' AND dxscad_date >= dxaf_date) a
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) c FROM cohort_af_intermittent WHERE is_treated='C' AND dxscad_date >= dxaf_date) c
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) single FROM cohort_af_intermittent WHERE (is_treated='W' OR is_treated='A' OR is_treated='C') AND dxscad_date >= dxaf_date) single;


SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND dxscad_date >= dxaf_date) mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND dxscad_date >= dxaf_date) chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND dxscad_date >= dxaf_date) stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND dxscad_date >= dxaf_date) sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND dxscad_date >= dxaf_date) bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND dxscad_date >= dxaf_date) hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND dxscad_date >= dxaf_date) usa_acs
);

-- AF any time in the dataset

SELECT f.total, wac.wac, wa.wa, ac.ac, wc.wc, dual.dual, w.w, a.a, c.c, single FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_af_intermittent) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wac FROM cohort_af_intermittent WHERE is_treated='WAC') wac
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wa FROM cohort_af_intermittent WHERE is_treated='WA') wa
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ac FROM cohort_af_intermittent WHERE is_treated='AC') ac
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wc FROM cohort_af_intermittent WHERE is_treated='WC') wc
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) dual FROM cohort_af_intermittent WHERE is_treated='WA' OR is_treated='AC' OR is_treated='WC') dual
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) w FROM cohort_af_intermittent WHERE is_treated='W') w
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) a FROM cohort_af_intermittent WHERE is_treated='A') a
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) c FROM cohort_af_intermittent WHERE is_treated='C') c
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) single FROM cohort_af_intermittent WHERE is_treated='W' OR is_treated='A' OR is_treated='C') single;


SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL) mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL) chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL) stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL) sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL) bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL) hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL) usa_acs
);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='WAC') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='WAC') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='WAC') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='WAC') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='WAC') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='WAC') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='WAC') usa_acs);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='WA') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='WA') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='WA') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='WA') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='WA') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='WA') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='WA') usa_acs);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='AC') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='AC') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='AC') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='AC') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='AC') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='AC') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='AC') usa_acs);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='WC') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='WC') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='WC') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='WC') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='WC') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='WC') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='WC') usa_acs);


SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND (is_treated='WA' OR is_treated='AC' OR is_treated='WC')) usa_acs);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='W') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='W') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='W') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='W') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='W') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='W') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='W') usa_acs);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='A') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='A') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='A') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='A') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='A') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='A') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='A') usa_acs);

SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND is_treated='C') mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND is_treated='C') chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND is_treated='C') stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND is_treated='C') sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND is_treated='C') bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND is_treated='C') hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND is_treated='C') usa_acs);


SELECT mi.mi, chd.chd, stroke.stroke, sd.sd, bleed.bleed, hf.hf FROM
(
(SELECT COUNT(distinct(anonpatid)) mi FROM cohort_af_intermittent WHERE mi IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) mi
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) chd FROM cohort_af_intermittent WHERE chd_death IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) chd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) stroke FROM cohort_af_intermittent WHERE stroke IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) stroke
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) sd FROM cohort_af_intermittent WHERE stroke_death IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) sd
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) bleed FROM cohort_af_intermittent WHERE bleed IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) bleed
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) hf FROM cohort_af_intermittent WHERE hf IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) hf
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) usa_acs FROM cohort_af_intermittent WHERE usa_acs IS NOT NULL AND (is_treated='W' OR is_treated='A' OR is_treated='C')) usa_acs);

SELECT f.total, wac.wac, wa.wa, ac.ac, wc.wc, dual.dual, w.w, a.a, c.c, single FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_af_continuous) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wac FROM cohort_af_continuous WHERE is_treated='WAC') wac
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wa FROM cohort_af_continuous WHERE is_treated='WA') wa
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ac FROM cohort_af_continuous WHERE is_treated='AC') ac
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) wc FROM cohort_af_continuous WHERE is_treated='WC') wc
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) dual FROM cohort_af_continuous WHERE is_treated='WA' OR is_treated='AC' OR is_treated='WC') dual
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) w FROM cohort_af_continuous WHERE is_treated='W') w
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) a FROM cohort_af_continuous WHERE is_treated='A') a
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) c FROM cohort_af_continuous WHERE is_treated='C') c
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) single FROM cohort_af_continuous WHERE is_treated='W' OR is_treated='A' OR is_treated='C') single;


SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention) ci;

SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI WHERE mi IS NOT NULL) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline WHERE mi IS NOT NULL) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention WHERE mi IS NOT NULL) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline WHERE mi IS NOT NULL) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention WHERE mi IS NOT NULL) ci;

SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI WHERE chd_death IS NOT NULL) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline WHERE chd_death IS NOT NULL) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention WHERE chd_death IS NOT NULL) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline WHERE chd_death IS NOT NULL) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention WHERE chd_death IS NOT NULL) ci;


SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI WHERE stroke IS NOT NULL) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline WHERE stroke IS NOT NULL) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention WHERE stroke IS NOT NULL) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline WHERE stroke IS NOT NULL) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention WHERE stroke IS NOT NULL) ci;


SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI WHERE stroke_death IS NOT NULL) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline WHERE stroke_death IS NOT NULL) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention WHERE stroke_death IS NOT NULL) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline WHERE stroke_death IS NOT NULL) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention WHERE stroke_death IS NOT NULL) ci;


SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI WHERE hf IS NOT NULL) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline WHERE  hf IS NOT NULL) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention WHERE  hf IS NOT NULL) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline WHERE  hf IS NOT NULL) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention WHERE  hf IS NOT NULL) ci;


SELECT f.total, ib.ib, ii.ii, cb.cb, ci.ci FROM
(SELECT COUNT(distinct(anonpatid)) total FROM cohort_post_MI WHERE usa_acs IS NOT NULL) f
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ib FROM cohort_intermittent_secondary_prevention_baseline WHERE  usa_acs IS NOT NULL) ib
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ii FROM cohort_intermittent_secondary_prevention_intervention WHERE  usa_acs IS NOT NULL) ii
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) cb FROM cohort_continuous_secondary_prevention_baseline WHERE  usa_acs IS NOT NULL) cb
CROSS JOIN
(SELECT COUNT(distinct(anonpatid)) ci FROM cohort_continuous_secondary_prevention_intervention WHERE usa_acs IS NOT NULL) ci;