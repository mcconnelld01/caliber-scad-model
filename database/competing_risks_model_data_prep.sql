DROP TABLE IF EXISTS che_cr_model_fe;
CREATE TABLE che_cr_model_fe (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
fe_time int,
fe_mi boolean,
fe_stroke_i boolean,
fe_stroke_h boolean,
fe_fatal_cvd boolean,
fe_fatal_non_cvd boolean
);
CREATE INDEX che_cr_model_fe_patid_index ON che_cr_model_fe(anonpatid);

DROP TABLE IF EXISTS che_cr_model_post_mi;
CREATE TABLE che_cr_model_post_mi (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
post_mi_mort_time int,
post_mi_mort boolean,
post_mi_cvd_mort boolean,
post_mi_non_cvd_mort boolean
);
CREATE INDEX che_cr_model_post_mi_patid_index ON che_cr_model_post_mi(anonpatid);

DROP TABLE IF EXISTS che_cr_model_post_stroke_h;
CREATE TABLE che_cr_model_post_stroke_h (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
post_stroke_h_mort_time int,
post_stroke_h_mort boolean,
post_stroke_h_cvd_mort boolean,
post_stroke_h_non_cvd_mort boolean
);
CREATE INDEX che_cr_model_post_stroke_h_patid_index ON che_cr_model_post_stroke_h(anonpatid);

DROP TABLE IF EXISTS che_cr_model_post_stroke_i;
CREATE TABLE che_cr_model_post_stroke_i (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
post_stroke_i_mort_time int,
post_stroke_i_mort boolean,
post_stroke_i_cvd_mort boolean,
post_stroke_i_non_cvd_mort boolean
);
CREATE INDEX che_cr_model_post_stroke_i_patid_index ON che_cr_model_post_stroke_i(anonpatid);

-- stored procedure to calculate transition times for competing risks first event model
DROP FUNCTION IF EXISTS calculate_transition_times_cr_model();
CREATE OR REPLACE FUNCTION calculate_transition_times_cr_model() RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date, CASE WHEN date_exit>censor_date THEN date_exit ELSE censor_date END AS end_date FROM SCAD_cohort WHERE censor_date-dxscad_date > 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement text;
	first_event boolean;
	fatal_event boolean;
	start_time int;
	stop_time int;
	total_time int; 
	mi boolean;
	stroke_i boolean;
	stroke_h boolean;
	fatal_cvd boolean;
	fatal_non_cvd boolean;
BEGIN

TRUNCATE TABLE che_cr_model_fe;
TRUNCATE TABLE che_cr_model_post_mi;
TRUNCATE TABLE che_cr_model_post_stroke_i;
TRUNCATE TABLE che_cr_model_post_stroke_h;

FOR patient IN patients	LOOP
	start_time = 180;
	first_event = TRUE;
	mi = FALSE;
	stroke_i = FALSE;
	stroke_h = FALSE;
	fatal_cvd = FALSE;
	fatal_non_cvd = FALSE;

	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		stop_time = event.eventdate - patient.dxscad_date;	
		total_time = stop_time - start_time;

		CASE 
		WHEN first_event THEN
			first_event = FALSE;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				fatal_event = FALSE;
				mi = TRUE;
			WHEN event.event = 'STROKE_I' AND event.fatal = FALSE THEN
				fatal_event = FALSE;
				stroke_i = TRUE;
			WHEN event.event = 'STROKE_H' AND event.fatal = FALSE THEN
				fatal_event = FALSE;
				stroke_h = TRUE;
			WHEN (event.event_type = 'ACS' OR event.event_type = 'STROKE' OR event.event_type = 'CVD_DEATH') AND event.fatal = TRUE THEN
				fatal_event = TRUE;
				fatal_cvd = TRUE;
			WHEN event.event_type = 'NONCVD_DEATH' THEN
				fatal_event = TRUE;
				fatal_non_cvd = TRUE;
			ELSE -- CENSORED
				fatal_event = FALSE;
			END CASE;
			INSERT INTO che_cr_model_fe (anonpatid, fe_time, fe_mi, fe_stroke_i, fe_stroke_h, fe_fatal_cvd, fe_fatal_non_cvd) VALUES (patient.anonpatid, total_time, mi, stroke_i, stroke_h, fatal_cvd, fatal_non_cvd);
		ELSE 
			CASE
			WHEN fatal_event != TRUE AND event.fatal = TRUE AND mi = TRUE THEN
				IF (event.event_type = 'ACS' OR event.event_type = 'STROKE' OR event.event_type = 'CVD_DEATH') THEN
					INSERT INTO che_cr_model_post_mi (anonpatid, post_mi_mort_time, post_mi_mort, post_mi_cvd_mort, post_mi_non_cvd_mort) VALUES (patient.anonpatid, total_time, TRUE, TRUE, FALSE);
				ELSE
					INSERT INTO che_cr_model_post_mi (anonpatid, post_mi_mort_time, post_mi_mort, post_mi_cvd_mort, post_mi_non_cvd_mort) VALUES (patient.anonpatid, total_time, TRUE, FALSE, TRUE);
				END IF;
			WHEN fatal_event != TRUE AND event.fatal = TRUE AND stroke_i = TRUE THEN
				IF (event.event_type = 'ACS' OR event.event_type = 'STROKE' OR event.event_type = 'CVD_DEATH') THEN
					INSERT INTO che_cr_model_post_stroke_i (anonpatid, post_stroke_i_mort_time, post_stroke_i_mort, post_stroke_i_cvd_mort, post_stroke_i_non_cvd_mort) VALUES (patient.anonpatid, total_time, TRUE, TRUE, FALSE);
				ELSE 
					INSERT INTO che_cr_model_post_stroke_i (anonpatid, post_stroke_i_mort_time, post_stroke_i_mort, post_stroke_i_cvd_mort, post_stroke_i_non_cvd_mort) VALUES (patient.anonpatid, total_time, TRUE, FALSE, TRUE);
				END IF;
			WHEN fatal_event != TRUE AND event.fatal = TRUE AND stroke_h = TRUE THEN
				IF (event.event_type = 'ACS' OR event.event_type = 'STROKE' OR event.event_type = 'CVD_DEATH') THEN
					INSERT INTO che_cr_model_post_stroke_h (anonpatid, post_stroke_h_mort_time, post_stroke_h_mort, post_stroke_h_cvd_mort, post_stroke_h_non_cvd_mort) VALUES (patient.anonpatid, total_time, TRUE, TRUE, FALSE);
				ELSE
					INSERT INTO che_cr_model_post_stroke_h (anonpatid, post_stroke_h_mort_time, post_stroke_h_mort, post_stroke_h_cvd_mort, post_stroke_h_non_cvd_mort) VALUES (patient.anonpatid, total_time, TRUE, FALSE, TRUE);
				END IF;
			WHEN fatal_event != TRUE AND event.event_type = 'CENSORED' AND mi = TRUE THEN
				INSERT INTO che_cr_model_post_mi (anonpatid, post_mi_mort_time, post_mi_mort, post_mi_cvd_mort, post_mi_non_cvd_mort) VALUES (patient.anonpatid, total_time, FALSE, FALSE, FALSE);
			WHEN fatal_event != TRUE AND event.event_type = 'CENSORED' AND stroke_i = TRUE THEN
				INSERT INTO che_cr_model_post_stroke_i (anonpatid, post_stroke_i_mort_time, post_stroke_i_mort, post_stroke_i_cvd_mort, post_stroke_i_non_cvd_mort) VALUES (patient.anonpatid, total_time, FALSE, FALSE, FALSE);
			WHEN fatal_event != TRUE AND event.event_type = 'CENSORED' AND stroke_h = TRUE THEN
				INSERT INTO che_cr_model_post_stroke_h (anonpatid, post_stroke_h_mort_time, post_stroke_h_mort, post_stroke_h_cvd_mort, post_stroke_h_non_cvd_mort) VALUES (patient.anonpatid, total_time, FALSE, FALSE, FALSE);
			ELSE -- Ignore all subsequent non-fatal events
			
			END CASE;
		END CASE;
		start_time = stop_time;
	END LOOP;
	-- if no events enter a censored row in first event table
	IF first_event THEN
		total_time = patient.end_date - (patient.dxscad_date +180);
		INSERT INTO che_cr_model_fe (anonpatid, fe_time, fe_mi, fe_stroke_i, fe_stroke_h, fe_fatal_cvd, fe_fatal_non_cvd) VALUES (patient.anonpatid, total_time, mi, stroke_i, stroke_h, fatal_cvd, fatal_non_cvd);		
	END IF;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_transition_times_cr_model();

-- DROP TABLE IF EXISTS che_cumulative_incidence;
-- CREATE TABLE che_cumulative_incidence(
-- mi_id int,
-- anonpatid int,
-- event text,
-- time int,
-- ci float
-- );
-- ALTER TABLE che_cumulative_incidence ADD PRIMARY KEY(mi_id, anonpatid, event, time); 
-- CREATE INDEX che_cumulative_incidence_event ON che_cumulative_incidence(event); 
-- 
-- --select count(distinct(anonpatid)) from che_cumulative_incidence;
-- TRUNCATE TABLE che_cumulative_incidence;
-- COPY che_cumulative_incidence(mi_id,anonpatid,event,time,ci) FROM 'C:/CALIBER/R/TEEHTA/competing_risks/output/all_patient_cum_incidence.csv' DELIMITER ',' CSV;
-- 
-- -- save five year risk deciles
-- DROP TABLE IF EXISTS che_5yr_fe_risk_deciles;
-- SELECT mi_id, anonpatid, ci_fe, ntile(10) OVER (ORDER BY ci_fe) AS decile 
-- 		INTO che_5yr_fe_risk_deciles
-- 		FROM (SELECT mi_id, anonpatid, SUM(ci) ci_fe 
-- 			FROM che_cumulative_incidence 
-- 			WHERE event IN ('fe_mi','fe_stroke_i','fe_stroke_h','fe_fatal_cvd') AND time=1825
-- 			GROUP BY mi_id, anonpatid
-- 		) x;
-- SELECT decile, AVG(ci_fe) FROM che_5yr_fe_risk_deciles GROUP BY decile ORDER BY DECILE; 
