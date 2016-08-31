-----------------------------------------------------------
-----------------------------------------------------------
-- the fist set of functions create datasets in the form
-- suitable for analysis by the mstate R package
-- the second set of functions create equivalent datasets
-- in the form suitable for analysis by the msm R package
-----------------------------------------------------------
-----------------------------------------------------------

DROP TABLE IF EXISTS che_transitions_model_a;
CREATE TABLE che_transitions_model_a (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
from_state int,
to_state int,
trans int,
Tstart int,
Tstop int,
time int, 
status int
);
CREATE INDEX che_transitions_model_a_patid_index ON che_transitions_model_a(anonpatid);

-- stored procedure to calculate transition times for model a
DROP FUNCTION IF EXISTS calculate_transition_times_model_a();
CREATE OR REPLACE FUNCTION calculate_transition_times_model_a() RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date FROM SCAD_cohort WHERE censor_date-dxscad_date >= 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	previous_state int;
	start_time int;
	stop_time int;
	total_time int; 
	current_state int;
	trans int;
BEGIN

TRUNCATE TABLE che_transitions_model_a;

FOR patient IN patients	LOOP
	previous_state = 1;
	start_time = 180;
	FOR event IN events(pat:=patient.anonpatid, scad:=patient.dxscad_date) LOOP
		stop_time = event.eventdate - patient.dxscad_date;	
		total_time = stop_time - start_time;
		CASE 
		WHEN previous_state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 2;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 3;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 2, 1, start_time, stop_time, total_time, CASE WHEN previous_state = 2 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 3, 2, start_time, stop_time, total_time, CASE WHEN previous_state = 3 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 16, 3, start_time, stop_time, total_time,  CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 17, 4, start_time, stop_time, total_time,  CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 18, 5, start_time, stop_time, total_time,  CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		WHEN previous_state = 2 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 4;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 5;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 4, 6, start_time, stop_time, total_time, CASE WHEN previous_state = 4 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 5, 7, start_time, stop_time, total_time, CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 16, 8, start_time, stop_time, total_time, CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 17, 9, start_time, stop_time, total_time, CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 18, 10, start_time, stop_time, total_time, CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		WHEN previous_state = 3 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 6;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 7;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 6, 11, start_time, stop_time, total_time, CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 7, 12, start_time, stop_time, total_time, CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 16, 13, start_time, stop_time, total_time, CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 17, 14, start_time, stop_time, total_time, CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 18, 15, start_time, stop_time, total_time, CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		WHEN previous_state = 4 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 8;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 9;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 8, 16, start_time, stop_time, total_time, CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 9, 17, start_time, stop_time, total_time, CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 16, 18, start_time, stop_time, total_time, CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 17, 19, start_time, stop_time, total_time, CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 18, 20, start_time, stop_time, total_time, CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		WHEN previous_state = 5 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 10;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 11;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 5, 10, 21, start_time, stop_time, total_time, CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 5, 11, 22, start_time, stop_time, total_time, CASE WHEN previous_state = 11 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 5, 16, 23, start_time, stop_time, total_time, CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 5, 17, 24, start_time, stop_time, total_time, CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 5, 18, 25, start_time, stop_time, total_time, CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		WHEN previous_state = 6 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 12;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 13;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 6, 12, 26, start_time, stop_time, total_time, CASE WHEN previous_state = 12 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 6, 13, 27, start_time, stop_time, total_time, CASE WHEN previous_state = 13 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 6, 16, 28, start_time, stop_time, total_time, CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 6, 17, 29, start_time, stop_time, total_time, CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 6, 18, 30, start_time, stop_time, total_time, CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		WHEN previous_state = 7 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 14;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 15;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 16;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 17;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 18;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 7, 14, 31, start_time, stop_time, total_time, CASE WHEN previous_state = 14 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 7, 15, 32, start_time, stop_time, total_time, CASE WHEN previous_state = 15 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 7, 16, 33, start_time, stop_time, total_time, CASE WHEN previous_state = 16 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 7, 17, 34, start_time, stop_time, total_time, CASE WHEN previous_state = 17 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_a (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 7, 18, 35, start_time, stop_time, total_time, CASE WHEN previous_state = 18 THEN 1 ELSE 0 END);
		ELSE -- all remianing states are treated as absorbing so no further transitions
		END CASE;
		start_time = stop_time;
	END LOOP;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_transition_times_model_a();


DROP TABLE IF EXISTS che_transitions_model_b;
CREATE TABLE che_transitions_model_b (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
from_state int,
to_state int,
trans int,
Tstart int,
Tstop int,
time int, 
status int
);
CREATE INDEX che_transitions_model_b_patid_index ON che_transitions_model_b(anonpatid);

-- stored procedure to calculate transition times for model B
DROP FUNCTION IF EXISTS calculate_transition_times_model_b(acute_days INT);
CREATE OR REPLACE FUNCTION calculate_transition_times_model_b(acute_days INT DEFAULT 365) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date FROM SCAD_cohort WHERE censor_date-dxscad_date >= 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	previous_state int;
	start_time int;
	stop_time int;
	total_time int; 
	current_state int;
	trans int;
BEGIN

TRUNCATE TABLE che_transitions_model_b;

FOR patient IN patients	LOOP
	previous_state = 1;
	start_time = 180;
	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		stop_time = event.eventdate - patient.dxscad_date;	
		total_time = stop_time - start_time;
		CASE 
		WHEN previous_state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 5;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 6;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 8;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 9;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 10;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 5, 1, start_time, stop_time, total_time, CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 6, 2, start_time, stop_time, total_time, CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 8, 3, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 9, 4, start_time, stop_time, total_time,  CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 10, 5, start_time, stop_time, total_time,  CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
		WHEN previous_state = 2 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 5;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 7;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 8;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 9;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 10;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 5, 6, start_time, stop_time, total_time, CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 7, 7, start_time, stop_time, total_time, CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 8, 8, start_time, stop_time, total_time, CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 9, 9, start_time, stop_time, total_time, CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 2, 10, 10, start_time, stop_time, total_time, CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
		WHEN previous_state = 3 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 7;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 6;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 8;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 9;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 10;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 6, 11, start_time, stop_time, total_time, CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 7, 12, start_time, stop_time, total_time, CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 8, 13, start_time, stop_time, total_time, CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 9, 14, start_time, stop_time, total_time, CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 3, 10, 15, start_time, stop_time, total_time, CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
		WHEN previous_state = 4 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 7;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 7;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 8;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 9;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 10;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;		
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 7, 16, start_time, stop_time, total_time, CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 8, 17, start_time, stop_time, total_time, CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 9, 18, start_time, stop_time, total_time, CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 4, 10, 19, start_time, stop_time, total_time, CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
		WHEN previous_state = 5 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 2, 20, start_time, start_time+acute_days, acute_days, 1);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 7, 21, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 8, 22, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 9, 23, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 10, 24, start_time, start_time+acute_days, acute_days, 0);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 5;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 7;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 8;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 9;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 10;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 5, 6, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 7, 7, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 8, 8, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 9, 9, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 10, 10, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 0;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 7;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 8;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 9;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 10;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 2, 20, start_time, stop_time, total_time, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 7, 21, start_time, stop_time, total_time, CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 8, 22, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 9, 23, start_time, stop_time, total_time,  CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 5, 10, 24, start_time, stop_time, total_time,  CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			END IF;
		WHEN previous_state = 6 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 3, 25, start_time, start_time+acute_days, acute_days, 1);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 7, 26, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 8, 27, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 9, 28, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 10, 29, start_time, start_time+acute_days, acute_days, 0);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 7;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 6;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 8;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 9;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 10;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 6, 11, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 7, 12, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 8, 13, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 9, 14, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 10, 15, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 7;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 0;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 8;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 9;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 10;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 3, 25, start_time, stop_time, total_time, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 7, 26, start_time, stop_time, total_time, CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 8, 27, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 9, 28, start_time, stop_time, total_time,  CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 6, 10, 29, start_time, stop_time, total_time,  CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			END IF;
		WHEN previous_state = 7 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 4, 30, start_time, start_time+acute_days, acute_days, 1);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 8, 31, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 9, 32, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 10, 33, start_time, start_time+acute_days, acute_days, 0);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 7;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 7;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 8;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 9;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 10;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 4, 7, 16, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 7 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 4, 8, 17, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 4, 9, 18, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 4, 10, 19, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 0;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 0;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 8;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 9;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 10;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 4, 30, start_time, stop_time, total_time, 0);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 8, 31, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 9, 32, start_time, stop_time, total_time,  CASE WHEN previous_state = 9 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_b (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 7, 10, 33, start_time, stop_time, total_time,  CASE WHEN previous_state = 10 THEN 1 ELSE 0 END);
			END IF;
		ELSE -- states 8,9 and 10 are absorbing so no further transitions
		END CASE;
		start_time = stop_time;
	END LOOP;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_transition_times_model_b();


DROP TABLE IF EXISTS che_transitions_model_c;
CREATE TABLE che_transitions_model_c (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
from_state int,
to_state int,
trans int,
Tstart int,
Tstop int,
time int, 
status int,
age int,
sex boolean,
has_hf boolean,
mi_count int,
stroke_count int
);
CREATE INDEX che_transitions_model_c_patid_index ON che_transitions_model_c(anonpatid);

-- stored procedure to calculate transition times for model c
DROP FUNCTION IF EXISTS calculate_transition_times_model_c(acute_days INT);
CREATE OR REPLACE FUNCTION calculate_transition_times_model_c(acute_days INT DEFAULT 365) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date, date_exit, age, sex FROM SCAD_cohort WHERE censor_date-dxscad_date >= 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	previous_state int;
	start_time int;
	stop_time int;
	total_time int; 
	current_state int;
	trans int;
	num_mi int;
	num_stroke int;
	hf_date date;
	hf boolean;
	pat_age int;
	pat_age_acute int;
BEGIN

TRUNCATE TABLE che_transitions_model_c;

FOR patient IN patients	LOOP
	previous_state = 1;
	start_time = 180;

	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'ACS' INTO num_mi;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'STROKE' INTO num_stroke;

	-- calculate hf date for patient
	SELECT MIN(eventdate) FROM che_hf WHERE anonpatid=patient.anonpatid INTO hf_date;
	IF hf_date IS NULL THEN
		hf_date = patient.date_exit;
	END IF;
	hf = FALSE;
	IF hf_date < patient.dxscad_date+180 THEN
		hf = TRUE;
	END IF;

	
	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		stop_time = event.eventdate - patient.dxscad_date;	
		total_time = stop_time - start_time;
		pat_age = patient.age + round(stop_time/365);
		pat_age_acute = patient.age + round(acute_days/365);

		IF hf_date < event.eventdate THEN
			hf = TRUE;
		END IF;

		CASE 
		WHEN previous_state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 3;
				num_stroke = num_stroke + 1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 6;
			WHEN event.event = 'OTHER_CVD_DEATH' THEN
				previous_state = 7;
			WHEN event.event = 'OTHER_DEATH' THEN
				previous_state = 8;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 2, 1, start_time, stop_time, total_time, CASE WHEN previous_state = 2 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 3, 2, start_time, stop_time, total_time, CASE WHEN previous_state = 3 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 5, 3, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 6, 4, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 7, 5, start_time, stop_time, total_time,  CASE WHEN previous_state = 7 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 8, 6, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 1, 0, -1, start_time, stop_time, total_time,  CASE WHEN previous_state = 0 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
		WHEN previous_state = 2 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 4, 8, start_time, start_time+acute_days, acute_days, 1, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 3, 7, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 5, 9, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 6, 10, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 7, 11, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 8, 12, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 0, -1, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 2;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 3;
					num_stroke = num_stroke + 1;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 5;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 6;
					num_stroke = num_stroke + 1;
				WHEN event.event = 'OTHER_CVD_DEATH' THEN
					previous_state = 7;
				WHEN event.event = 'OTHER_DEATH' THEN
					previous_state = 8;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 2, 19, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 2 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 3, 20, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 3 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 5, 21, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 5 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 6, 22, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 6 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 7, 23, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 7 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 8, 24, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 8 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 0, -1, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 0 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 0;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 3;
					num_stroke = num_stroke + 1;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 5;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 6;
					num_stroke = num_stroke + 1;
				WHEN event.event = 'OTHER_CVD_DEATH' THEN
					previous_state = 7;
				WHEN event.event = 'OTHER_DEATH' THEN
					previous_state = 8;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 4, 8, start_time, stop_time, total_time, 0, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 3, 7, start_time, stop_time, total_time, CASE WHEN previous_state = 3 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 5, 9, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 6, 10, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 7, 11, start_time, stop_time, total_time,  CASE WHEN previous_state = 7 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 8, 12, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 2, 0, -1, start_time, stop_time, total_time,  CASE WHEN previous_state = 0 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			END IF;
		WHEN previous_state = 3 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 4, 14, start_time, start_time+acute_days, acute_days, 1, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 2, 13, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 5, 15, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 6, 16, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 7, 17, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 8, 18, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 0, -1, start_time, start_time+acute_days, acute_days, 0, pat_age_acute, patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 2;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 3;
					num_stroke = num_stroke + 1;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 5;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 6;
					num_stroke = num_stroke + 1;
				WHEN event.event = 'OTHER_CVD_DEATH' THEN
					previous_state = 7;
				WHEN event.event = 'OTHER_DEATH' THEN
					previous_state = 8;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 2, 19, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 2 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 3, 20, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 3 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 5, 21, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 5 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 6, 22, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 6 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 7, 23, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 7 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 8, 24, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 8 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 4, 0, -1, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 0 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 2;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 0;
					num_stroke = num_stroke + 1;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 5;
					num_mi = num_mi + 1;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 6;
					num_stroke = num_stroke + 1;
				WHEN event.event = 'OTHER_CVD_DEATH' THEN
					previous_state = 7;
				WHEN event.event = 'OTHER_DEATH' THEN
					previous_state = 8;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 4, 14, start_time, stop_time, total_time, 0, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 2, 13, start_time, stop_time, total_time, CASE WHEN previous_state = 2 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 5, 15, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 6, 16, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 7, 17, start_time, stop_time, total_time,  CASE WHEN previous_state = 7 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 8, 18, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
				INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
				(patient.anonpatid, 3, 0, -1, start_time, stop_time, total_time,  CASE WHEN previous_state = 0 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			END IF;
		WHEN previous_state = 4 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 3;
				num_stroke = num_stroke + 1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 6;
				num_stroke = num_stroke + 1;
			WHEN event.event = 'OTHER_CVD_DEATH' THEN
				previous_state = 7;
			WHEN event.event = 'OTHER_DEATH' THEN
				previous_state = 8;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 2, 19, start_time, stop_time, total_time, CASE WHEN previous_state = 2 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 3, 20, start_time, stop_time, total_time, CASE WHEN previous_state = 3 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 5, 21, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 6, 22, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 7, 23, start_time, stop_time, total_time,  CASE WHEN previous_state = 7 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 8, 24, start_time, stop_time, total_time,  CASE WHEN previous_state = 8 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
			INSERT INTO che_transitions_model_c (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status, age, sex, has_hf, mi_count, stroke_count) VALUES
			(patient.anonpatid, 4, 0, -1, start_time, stop_time, total_time,  CASE WHEN previous_state = 0 THEN 1 ELSE 0 END, pat_age, patient.sex, hf, num_mi, num_stroke);
		ELSE -- states 5, 6, 7 and 8 are absorbing so no further transitions
		END CASE;
		start_time = stop_time;
	END LOOP;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_transition_times_model_c();


DROP TABLE IF EXISTS che_transitions_model_d;
CREATE TABLE che_transitions_model_d (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
from_state int,
to_state int,
trans int,
Tstart int,
Tstop int,
time int, 
status int
);
CREATE INDEX che_transitions_model_d_patid_index ON che_transitions_model_d(anonpatid);

-- stored procedure to calculate transition times for model d
DROP FUNCTION IF EXISTS calculate_transition_times_model_d(acute_days INT);
CREATE OR REPLACE FUNCTION calculate_transition_times_model_d(acute_days INT DEFAULT 365) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date FROM SCAD_cohort WHERE censor_date-dxscad_date >= 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	previous_state int;
	start_time int;
	stop_time int;
	total_time int; 
	current_state int;
	trans int;
BEGIN

TRUNCATE TABLE che_transitions_model_d;

FOR patient IN patients	LOOP
	previous_state = 1;
	start_time = 180;
	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		stop_time = event.eventdate - patient.dxscad_date;	
		total_time = stop_time - start_time;
		CASE 
		WHEN previous_state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				previous_state = 2;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				previous_state = 3;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				previous_state = 4;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				previous_state = 5;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				previous_state = 6;
			ELSE -- CENSORED
				previous_state = 0;
			END CASE;
			INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 2, 1, start_time, stop_time, total_time, CASE WHEN previous_state = 2 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 3, 2, start_time, stop_time, total_time, CASE WHEN previous_state = 3 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 4, 6, start_time, stop_time, total_time,  CASE WHEN previous_state = 4 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 5, 10, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
			INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
			(patient.anonpatid, 1, 6, 3, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
		WHEN previous_state = 2 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 1, 4, start_time, start_time+acute_days, acute_days, 1);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 3, 5, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 4, 6, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 5, 10, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 6, 7, start_time, start_time+acute_days, acute_days, 0);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 2;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 3;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 4;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 5;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 6;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 2, 1, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 2 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 3, 2, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 3 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 4, 6, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 4 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 5, 10, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 6, 3, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 0;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 3;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 4;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 5;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 6;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 1, 4, start_time, stop_time, total_time, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 3, 5, start_time, stop_time, total_time, CASE WHEN previous_state = 3 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 4, 6, start_time, stop_time, total_time,  CASE WHEN previous_state = 4 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 5, 10, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 2, 6, 7, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			END IF;
		WHEN previous_state = 3 THEN
			IF total_time > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 1, 8, start_time, start_time+acute_days, acute_days, 1);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 2, 9, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 4, 6, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 5, 10, start_time, start_time+acute_days, acute_days, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 6, 11, start_time, start_time+acute_days, acute_days, 0);
				-- then add transitions from non-acute state
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 2;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 3;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 4;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 5;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 6;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 2, 1, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 2 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 3, 2, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 3 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 4, 6, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 4 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 5, 10, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 1, 6, 3, start_time+acute_days, stop_time, stop_time-(start_time+acute_days), CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			ELSE
				CASE 
				WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
					previous_state = 2;
				WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
					previous_state = 0;
				WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
					previous_state = 4;
				WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
					previous_state = 5;
				WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
					previous_state = 6;
				ELSE -- CENSORED
					previous_state = 0;
				END CASE;		
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 1, 8, start_time, stop_time, total_time, 0);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 2, 9, start_time, stop_time, total_time, CASE WHEN previous_state = 2 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 4, 6, start_time, stop_time, total_time,  CASE WHEN previous_state = 4 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 5, 10, start_time, stop_time, total_time,  CASE WHEN previous_state = 5 THEN 1 ELSE 0 END);
				INSERT INTO che_transitions_model_d (anonpatid, from_state, to_state, trans, Tstart, Tstop, time, status) VALUES
				(patient.anonpatid, 3, 6, 11, start_time, stop_time, total_time,  CASE WHEN previous_state = 6 THEN 1 ELSE 0 END);
			END IF;
		ELSE -- states 4, 5 and 6 are absorbing so no further transitions
		END CASE;
		start_time = stop_time;
	END LOOP;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_transition_times_model_d();


DROP TABLE IF EXISTS che_events_msm_B;
CREATE TABLE che_events_msm_B (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
state int,
days int, 
status int,
age int,
sex boolean,
has_hf boolean,
mi_count int,
stroke_count int
);
CREATE INDEX che_events_msm_B_patid_index ON che_events_msm_B(anonpatid);

-- stored procedure to calculate transition times for model B
DROP FUNCTION IF EXISTS calculate_che_events_msm_B(acute_days INT);
CREATE OR REPLACE FUNCTION calculate_che_events_msm_B(acute_days INT DEFAULT 365) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date, date_exit, age, sex FROM SCAD_cohort WHERE censor_date-dxscad_date >= 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	start_days int;
	previous_start_days int;
	total_days int;
	state int;
	status int;
	num_mi int;
	num_stroke int;
	hf_date date;
	hf boolean;
BEGIN

TRUNCATE TABLE che_events_msm_B;

FOR patient IN patients	LOOP
	-- all patients start in SCAD state (state 1)
	state = 1;
	status = 1;
	previous_start_days = 0;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'ACS' INTO num_mi;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'STROKE' INTO num_stroke;

	-- calculate hf date for patient
	SELECT MIN(eventdate) FROM che_hf WHERE anonpatid=patient.anonpatid INTO hf_date;
	IF hf_date IS NULL THEN
		hf_date = patient.date_exit;
	END IF;
	hf = FALSE;
	IF hf_date < patient.dxscad_date+180 THEN
		hf = TRUE;
	END IF;
	
	INSERT INTO che_events_msm_B (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, 0 , status, patient.age, patient.sex, hf, num_mi, num_stroke);
	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		start_days = event.eventdate - (patient.dxscad_date+180);	
		total_days = start_days - previous_start_days;
		status = 1;
		IF hf_date < event.eventdate THEN
			hf = TRUE;
		END IF;
		CASE
		WHEN event.fatal = TRUE AND state < 5 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 8;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 9;
				num_stroke = num_stroke+1;
			ELSE -- other death
				state = 10;
			END CASE;
		WHEN state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 6;
				num_stroke = num_stroke+1;
			ELSE -- CENSORED
				status = 0;
			END CASE;
		WHEN state = 2 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 7;
				num_stroke = num_stroke+1;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 3 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 7;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 6;
				num_stroke = num_stroke+1;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 4 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 7;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 7;
				num_stroke = num_stroke+1;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 5 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_B (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 2, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 7;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 8;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 9;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				state = 10;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 6 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_B (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 3, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 7;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 6;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 8;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 9;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				state = 10;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 7 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_B (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 4, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 7;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 7;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 8;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 9;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				state = 10;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		ELSE -- states 8,9 and 10 are absorbing so no further transitions
		END CASE;

		IF total_days > 0 THEN
			INSERT INTO che_events_msm_B (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, start_days, status, patient.age + round((event.eventdate-patient.dxscad_date)/365), patient.sex, hf, num_mi, num_stroke);
		END IF;
		previous_start_days = start_days;
	END LOOP;
	-- if no events add final row for patient to say no events occured
	IF status = 1 AND state=1 THEN
		-- if no events and final row would be nonsense then delete patient
		IF patient.date_exit - (patient.dxscad_date+180) <= 0 THEN
			DELETE FROM che_events_msm_B WHERE anonpatid=patient.anonpatid; 
		ELSE
			IF hf_date < patient.date_exit THEN
				hf = TRUE;
			END IF;
			INSERT INTO che_events_msm_B (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, patient.date_exit - (patient.dxscad_date+180), 0, patient.age + round((patient.date_exit-patient.dxscad_date)/365), patient.sex, hf, num_mi, num_stroke);
		END IF;
	END IF;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_che_events_msm_B();


DROP TABLE IF EXISTS che_events_msm_C;
CREATE TABLE che_events_msm_C (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
state int,
days int, 
status int,
age int,
sex boolean,
has_hf boolean,
mi_count int,
stroke_count int
);
CREATE INDEX che_events_msm_C_patid_index ON che_events_msm_C(anonpatid);

-- stored procedure to calculate transition times for model C
DROP FUNCTION IF EXISTS calculate_che_events_msm_C(acute_days INT);
CREATE OR REPLACE FUNCTION calculate_che_events_msm_C(acute_days INT DEFAULT 365) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date, date_exit, age, sex FROM SCAD_cohort WHERE censor_date-dxscad_date >= 365 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+365 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	start_days int;
	previous_start_days int;
	total_days int;
	state int;
	status int;
	num_mi int;
	num_stroke int;
	hf_date date;
	hf boolean;
BEGIN

TRUNCATE TABLE che_events_msm_C;

FOR patient IN patients	LOOP
	-- all patients start in SCAD state (state 1)
	state = 1;
	status = 1;
	previous_start_days = 0;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'ACS' INTO num_mi;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'STROKE' INTO num_stroke;

	-- calculate hf date for patient
	SELECT MIN(eventdate) FROM che_hf WHERE anonpatid=patient.anonpatid INTO hf_date;
	IF hf_date IS NULL THEN
		hf_date = patient.date_exit;
	END IF;
	hf = FALSE;
	IF hf_date < patient.dxscad_date+180 THEN
		hf = TRUE;
	END IF;
	
	INSERT INTO che_events_msm_C (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, 0 , status, patient.age, patient.sex, hf, num_mi, num_stroke);
	
	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		start_days = event.eventdate - (patient.dxscad_date+180);	
		total_days = start_days - previous_start_days;
		status = 1;
		IF hf_date < event.eventdate THEN
			hf = TRUE;
		END IF;
		
		CASE
		WHEN event.fatal = TRUE AND state IN (1,4) THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 6;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' THEN
				state = 7;
			ELSE -- other death
				state = 8;
			END CASE;
		WHEN state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			ELSE -- CENSORED
				status = 0;
			END CASE;
		WHEN state = 4 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 2 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_C (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 4, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 6;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' THEN
				state = 7;
			WHEN event.event = 'OTHER_DEATH' THEN
				state = 8;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 3 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_C (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 4, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 5;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 6;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' THEN
				state = 7;
			WHEN event.event = 'OTHER_DEATH' THEN
				state = 8;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
	
		ELSE -- states 5, 6 and 7 are absorbing so no further transitions
		END CASE;

		IF total_days > 0 THEN
			INSERT INTO che_events_msm_C (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, start_days, status, patient.age + round((event.eventdate-patient.dxscad_date)/365), patient.sex, hf, num_mi, num_stroke);
		END IF;
		previous_start_days = start_days;
	END LOOP;
	-- if no events add final row for patient to say no events occured
	IF status = 1 AND state=1 THEN
		-- if no events and final row would be nonsense then delete patient
		IF patient.date_exit - (patient.dxscad_date+180) <= 0 THEN
			DELETE FROM che_events_msm_C WHERE anonpatid=patient.anonpatid; 
		ELSE
			IF hf_date < patient.date_exit THEN
				hf = TRUE;
			END IF;
			INSERT INTO che_events_msm_C (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, patient.date_exit - (patient.dxscad_date+180), 0, patient.age + round((patient.date_exit-patient.dxscad_date)/365), patient.sex, hf, num_mi, num_stroke);
		END IF;
	END IF;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_che_events_msm_C();

DROP TABLE IF EXISTS che_events_msm_D;
CREATE TABLE che_events_msm_D (
transition_id SERIAL PRIMARY KEY,
anonpatid int,
state int,
days int, 
status int,
age int,
sex boolean,
has_hf boolean,
mi_count int,
stroke_count int
);
CREATE INDEX che_events_msm_D_patid_index ON che_events_msm_D(anonpatid);

-- stored procedure to calculate transition times for model D
DROP FUNCTION IF EXISTS calculate_che_events_msm_D(acute_days INT);
CREATE OR REPLACE FUNCTION calculate_che_events_msm_D(acute_days INT DEFAULT 365) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date, date_exit, age, sex FROM SCAD_cohort WHERE censor_date-dxscad_date >= 180 ORDER BY anonpatid;
	events CURSOR (pat integer, scad date) FOR SELECT * FROM che_patient_event WHERE anonpatid=pat AND eventdate > scad+180 ORDER BY anonpatid, eventdate, event_number;
	sql_statement TEXT;
	start_days int;
	previous_start_days int;
	total_days int;
	state int;
	status int;
	num_mi int;
	num_stroke int;
	hf_date date;
	hf boolean;
BEGIN

TRUNCATE TABLE che_events_msm_D;

FOR patient IN patients	LOOP
	-- all patients start in SCAD state (state 1)
	state = 1;
	status = 1;
	previous_start_days = 0;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'ACS' INTO num_mi;
	SELECT COUNT(eventdate) FROM che_patient_event WHERE anonpatid = patient.anonpatid AND eventdate <= (patient.dxscad_date+180) AND event_type = 'STROKE' INTO num_stroke;

	-- calculate hf date for patient
	SELECT MIN(eventdate) FROM che_hf WHERE anonpatid=patient.anonpatid INTO hf_date;
	IF hf_date IS NULL THEN
		hf_date = patient.date_exit;
	END IF;
	hf = FALSE;
	IF hf_date < patient.dxscad_date+180 THEN
		hf = TRUE;
	END IF;
	
	INSERT INTO che_events_msm_D (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, 0 , status, patient.age, patient.sex, hf, num_mi, num_stroke);
	FOR event IN events(pat:=patient.anonpatid,scad:=patient.dxscad_date) LOOP
		start_days = event.eventdate - (patient.dxscad_date+180);	
		total_days = start_days - previous_start_days;
		status = 1;
		IF hf_date < event.eventdate THEN
			hf = TRUE;
		END IF;
		
		CASE
		WHEN state = 1 THEN
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 4;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 5;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				state = 6;				
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 2 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_D (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 1, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 4;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 5;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				state = 6;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
		WHEN state = 3 THEN
			IF total_days > acute_days THEN
				-- go back to non-acute state
				INSERT INTO che_events_msm_D (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, 1, previous_start_days+acute_days, 1, patient.age + round((previous_start_days+acute_days)/365), patient.sex, hf, num_mi, num_stroke);
				-- then add transitions from non-acute state
			END IF;
			CASE 
			WHEN event.event_type = 'ACS' AND event.fatal = FALSE THEN
				state = 2;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = FALSE THEN
				state = 3;
				num_stroke = num_stroke+1;
			WHEN event.event_type = 'ACS' AND event.fatal = TRUE THEN
				state = 4;
				num_mi = num_mi + 1;
			WHEN event.event_type = 'STROKE' AND event.fatal = TRUE THEN
				state = 5;
				num_stroke = num_stroke+1;
			WHEN event.event = 'OTHER_CVD_DEATH' OR event.event = 'OTHER_DEATH' THEN
				state = 6;
			ELSE -- CENSORED
				status = 0;
			END CASE;		
	
		ELSE -- states 4, 5 and 6 are absorbing so no further transitions
		END CASE;

		IF total_days > 0 THEN
			INSERT INTO che_events_msm_D (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, start_days, status, patient.age + round((event.eventdate-patient.dxscad_date)/365), patient.sex, hf, num_mi, num_stroke);
		END IF;
		previous_start_days = start_days;
	END LOOP;
	-- if no events add final row for patient to say no events occured
	IF status = 1 AND state=1 THEN
		-- if no events and final row would be nonsense then delete patient
		IF patient.date_exit - (patient.dxscad_date+180) <= 0 THEN
			DELETE FROM che_events_msm_D WHERE anonpatid=patient.anonpatid; 
		ELSE
			IF hf_date < patient.date_exit THEN
				hf = TRUE;
			END IF;
			INSERT INTO che_events_msm_D (anonpatid, state, days, status, age, sex, has_hf, mi_count, stroke_count) VALUES (patient.anonpatid, state, patient.date_exit - (patient.dxscad_date+180), 0, patient.age + round((patient.date_exit-patient.dxscad_date)/365), patient.sex, hf, num_mi, num_stroke);
		END IF;
	END IF;
END LOOP;	
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_che_events_msm_D();

select max(anonpatid) from (select distinct(anonpatid) from  che_events_msm_D order by anonpatid limit 2000) x;