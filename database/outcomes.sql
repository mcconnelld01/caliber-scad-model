-- stored procedure to remove repeated events defaults to recoding one event every 30 days
CREATE OR REPLACE FUNCTION remove_duplicate_events(events_table TEXT, repeat_event_window_days INT DEFAULT 30) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT DISTINCT(anonpatid) FROM SCAD_cohort ORDER BY anonpatid;
	events REFCURSOR;
	output_table TEXT;
	create_statement TEXT;
	insert_statement TEXT;
	drop_statement TEXT;
	index_statement TEXT;
	event_date DATE;
	previous_event_date DATE;
BEGIN
	-- create output table named events_table_xdays where x = @repeat_event_window_days
	output_table = events_table||'_'||repeat_event_window_days||'days';
	drop_statement = 'DROP TABLE IF EXISTS '||output_table||' CASCADE';
	EXECUTE drop_statement;
	create_statement = 
	'CREATE TABLE '||output_table||'(
	id SERIAL PRIMARY KEY,
	anonpatid int,
	eventdate date
	)';
	EXECUTE create_statement;

	-- for each patient
	FOR patient IN patients	LOOP
		previous_event_date = '01-01-1900'; -- zero date
		-- find all the events for the patient and loop through them storing those more than 
		-- or equal to @previous_event_date apart into the output table
		OPEN events FOR EXECUTE 'SELECT eventdate FROM ' || events_table || ' WHERE anonpatid='||patient.anonpatid||' ORDER BY eventdate';
		LOOP
			FETCH events INTO event_date;
			EXIT WHEN NOT FOUND;
			IF (event_date - previous_event_date) >= repeat_event_window_days THEN
				insert_statement = 'INSERT INTO ' || output_table || ' (anonpatid, eventdate) VALUES (' || patient.anonpatid || ',' || quote_literal(event_date) || ')';
				EXECUTE insert_statement;
				previous_event_date = event_date;
			END IF;
		END LOOP;
		CLOSE events;
	END LOOP;
	
	-- create index on output table
	index_statement = 'CREATE INDEX ' || output_table || '_patid_index ON ' || output_table || '(anonpatid)';
	EXECUTE index_statement;
END; $$
LANGUAGE PLPGSQL;

----------------------------------
--- define outcome variables -----
----------------------------------

DROP TABLE IF EXISTS che_mi_stemi;
CREATE TABLE che_mi_stemi AS
SELECT anonpatid, eventdate FROM 
(
SELECT anonpatid, eventdate FROM cal_stemi_gprd WHERE stemi_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_mi_minap WHERE mi_minap = 1
) x;
CREATE INDEX che_mi_stemi_patid_index ON che_mi_stemi(anonpatid);
SELECT remove_duplicate_events('che_mi_stemi');

DROP TABLE IF EXISTS che_mi_nstemi;
CREATE TABLE che_mi_nstemi AS
SELECT anonpatid, eventdate FROM 
(
SELECT anonpatid, eventdate FROM cal_nstemi_gprd WHERE nstemi_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_mi_minap WHERE mi_minap = 2
) x;
CREATE INDEX che_mi_nstemi_patid_index ON che_mi_nstemi(anonpatid);
SELECT remove_duplicate_events('che_mi_nstemi');

DROP TABLE IF EXISTS che_mi_nos;
CREATE TABLE che_mi_nos AS
SELECT anonpatid, eventdate FROM 
(
SELECT anonpatid, eventdate FROM cal_mi_nos_gprd WHERE mi_nos_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_mi_hes WHERE mi_hes = 3 OR mi_hes = 4
UNION
SELECT anonpatid, dod AS eventdate FROM cal_mi_ons
) x;
CREATE INDEX che_mi_nos_patid_index ON che_mi_nos(anonpatid);
SELECT remove_duplicate_events('che_mi_nos');
-- remove any unspecified mi which is within 30 days of a stemi/nstemi
DELETE FROM che_mi_nos_30days WHERE (anonpatid, eventdate) IN (
	SELECT nos.anonpatid, nos.eventdate
	FROM che_mi_nos_30days nos INNER JOIN
	(SELECT anonpatid, eventdate FROM che_mi_stemi
	UNION
	SELECT  anonpatid, eventdate FROM che_mi_nstemi) s
	ON nos.anonpatid = s.anonpatid AND ABS(nos.eventdate-s.eventdate) < 30
)

DROP TABLE IF EXISTS che_chd_death;
CREATE TABLE che_chd_death AS
SELECT anonpatid, dod AS eventdate FROM cal_chd_death_ons;
CREATE INDEX che_chd_death_patid_index ON che_chd_death(anonpatid);
SELECT remove_duplicate_events('che_chd_death');


DROP TABLE IF EXISTS che_usa;
CREATE TABLE che_usa AS
SELECT anonpatid, eventdate FROM
(
SELECT anonpatid, eventdate FROM cal_acs_gprd WHERE acs_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_uangina_hes WHERE uangina_hes = 1
UNION
SELECT anonpatid, eventdate FROM cal_unangina_gprd WHERE unangina_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_uangina_minap WHERE uangina_minap = 1
) x;
CREATE INDEX che_usa_patid_index ON che_usa(anonpatid);
SELECT remove_duplicate_events('che_usa');
-- remove any USA which is on the same date as an MI
DELETE FROM che_usa_30days WHERE (anonpatid, eventdate) IN (SELECT anonpatid, eventdate	FROM che_mi_composite_30days);

DROP TABLE IF EXISTS che_stroke;
CREATE TABLE che_stroke AS
SELECT anonpatid, eventdate FROM
(
SELECT anonpatid, eventdate FROM cal_stroke_nos_gprd WHERE stroke_nos_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_stroke_nos_hes WHERE stroke_nos_hes = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_stroke_nos_opcs WHERE stroke_nos_opcs = 3
UNION
SELECT anonpatid, eventdate FROM cal_ischaem_stroke_gprd WHERE ischaem_stroke_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_ischaem_stroke_hes WHERE ischaem_stroke_hes = 3
UNION
SELECT anonpatid, eventdate FROM cal_cerebral_haem WHERE cerebral_haem IN (3,7)
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_cerebral_stroke_hes WHERE cerebral_stroke_hes IN (3,7)
) x;
CREATE INDEX che_stroke_patid_index ON che_stroke(anonpatid);
SELECT remove_duplicate_events('che_stroke');


DROP TABLE IF EXISTS che_stroke_I;
CREATE TABLE che_stroke_I AS
SELECT anonpatid, eventdate FROM
(
SELECT anonpatid, eventdate FROM cal_stroke_nos_gprd WHERE stroke_nos_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_stroke_nos_hes WHERE stroke_nos_hes = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_stroke_nos_opcs WHERE stroke_nos_opcs = 3
UNION
SELECT anonpatid, eventdate FROM cal_ischaem_stroke_gprd WHERE ischaem_stroke_gprd = 3
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_ischaem_stroke_hes WHERE ischaem_stroke_hes = 3
) x;
CREATE INDEX che_stroke_I_patid_index ON che_stroke_I(anonpatid);
SELECT remove_duplicate_events('che_stroke_I');

DROP TABLE IF EXISTS che_stroke_H;
CREATE TABLE che_stroke_H AS
SELECT anonpatid, eventdate FROM
(
SELECT anonpatid, eventdate FROM cal_cerebral_haem WHERE cerebral_haem IN (3,7)
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_cerebral_stroke_hes WHERE cerebral_stroke_hes IN (3,7)
) x;
CREATE INDEX che_stroke_H_patid_index ON che_stroke_H(anonpatid);
SELECT remove_duplicate_events('che_stroke_H');


DROP TABLE IF EXISTS che_stroke_death;
CREATE TABLE che_stroke_death AS
SELECT anonpatid, eventdate FROM 
(
SELECT anonpatid, dod AS eventdate FROM cal_isch_stroke_ons
UNION
SELECT anonpatid, dod AS eventdate FROM cal_cerebral_stroke_ons
UNION
SELECT anonpatid, dod AS eventdate FROM cal_stroke_nos_ons
) x;
CREATE INDEX che_stroke_death_patid_index ON che_stroke_death(anonpatid);
SELECT remove_duplicate_events('che_stroke_death');

DROP TABLE IF EXISTS che_stroke_I_death;
CREATE TABLE che_stroke_I_death AS
SELECT anonpatid, eventdate FROM 
(
SELECT anonpatid, dod AS eventdate FROM cal_isch_stroke_ons
UNION
SELECT anonpatid, dod AS eventdate FROM cal_stroke_nos_ons
) x;
CREATE INDEX che_stroke_I_death_patid_index ON che_stroke_I_death(anonpatid);
SELECT remove_duplicate_events('che_stroke_I_death');

DROP TABLE IF EXISTS che_stroke_H_death;
CREATE TABLE che_stroke_H_death AS SELECT anonpatid, dod AS eventdate FROM cal_cerebral_stroke_ons;
CREATE INDEX che_stroke_H_death_patid_index ON che_stroke_H_death(anonpatid);
SELECT remove_duplicate_events('che_stroke_H_death');


DROP TABLE IF EXISTS che_other_cvd_death;
CREATE TABLE che_other_cvd_death AS 
SELECT anonpatid, eventdate FROM 
(SELECT anonpatid, dod AS eventdate FROM ons WHERE cod LIKE 'I%' AND anonpatid NOT IN 
	(SELECT anonpatid FROM che_chd_death
	UNION
	SELECT anonpatid FROM che_stroke_death) 
)x;
CREATE INDEX che_other_cvd_death_patid_index ON che_other_cvd_death(anonpatid);


DROP TABLE IF EXISTS che_noncvd_death;
CREATE TABLE che_noncvd_death AS
SELECT anonpatid, MIN(dod) AS eventdate FROM ons WHERE anonpatid NOT IN 
(
SELECT anonpatid FROM che_chd_death
UNION
SELECT anonpatid FROM che_stroke_death
UNION
SELECT anonpatid FROM che_other_cvd_death
) GROUP BY anonpatid;
CREATE INDEX che_noncvd_patid_index ON che_noncvd_death(anonpatid);


DROP TABLE IF EXISTS che_hf;
CREATE TABLE che_hf AS
SELECT anonpatid, eventdate FROM 
(
SELECT anonpatid, eventdate FROM cal_hf_gprd WHERE hf_gprd IN(3,4,5,6)
UNION
SELECT anonpatid, date_admission AS eventdate FROM cal_hf_hes WHERE hf_hes IN(3,4,5,6)
UNION
SELECT anonpatid, dod AS eventdate FROM cal_hf_ons
) x;
CREATE INDEX che_hf_patid_index ON che_hf(anonpatid);
SELECT remove_duplicate_events('che_hf');

DROP TABLE IF EXISTS che_cvd_composite_30days;
CREATE TABLE che_cvd_composite_30days(
anonpatid int,
eventdate date,
event text
);
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'stroke_death' FROM che_stroke_death_30days;
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'stroke' FROM che_stroke_30days;
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'usa' FROM che_usa_30days;
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'chd_death' FROM che_chd_death_30days;
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'mi' FROM che_mi_nos_30days;
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'stemi' FROM che_mi_stemi_30days;
INSERT INTO che_cvd_composite_30days SELECT anonpatid, eventdate, 'nstemi' FROM che_mi_nstemi_30days;
CREATE INDEX che_cvd_composite_30days_patid_index ON che_cvd_composite_30days(anonpatid);
CREATE INDEX che_cvd_composite_30days_eventdate_index ON che_cvd_composite_30days(eventdate);
CREATE INDEX che_cvd_composite_30days_event_index ON che_cvd_composite_30days(event);

DROP TABLE IF EXISTS che_acs_composite_30days;
CREATE TABLE che_acs_composite_30days(
anonpatid int,
eventdate date,
event text
);
INSERT INTO che_acs_composite_30days SELECT anonpatid, eventdate, 'usa' FROM che_usa_30days;
INSERT INTO che_acs_composite_30days SELECT anonpatid, eventdate, 'chd_death' FROM che_chd_death_30days;
INSERT INTO che_acs_composite_30days SELECT anonpatid, eventdate, 'mi' FROM che_mi_nos_30days;
INSERT INTO che_acs_composite_30days SELECT anonpatid, eventdate, 'stemi' FROM che_mi_stemi_30days;
INSERT INTO che_acs_composite_30days SELECT anonpatid, eventdate, 'nstemi' FROM che_mi_nstemi_30days;
CREATE INDEX che_acs_composite_30days_patid_index ON che_acs_composite_30days(anonpatid);
CREATE INDEX che_acs_composite_30days_eventdate_index ON che_acs_composite_30days(eventdate);
CREATE INDEX che_acs_composite_30days_event_index ON che_acs_composite_30days(event);

-- bleeds calculated by R code
SELECT remove_duplicate_events('che_bleed');
DROP TABLE IF EXISTS che_severe_bleed;
CREATE TABLE che_severe_bleed AS SELECT * FROM che_bleed WHERE category >1;
SELECT remove_duplicate_events('che_severe_bleed');

-- create composite mi
DROP TABLE IF EXISTS che_mi_composite_30days;
CREATE TABLE che_mi_composite_30days AS SELECT * FROM (
SELECT anonpatid, eventdate, 'MI' AS event FROM che_mi_nos_30days
UNION
SELECT anonpatid, eventdate, 'STEMI' AS event FROM che_mi_stemi_30days
UNION
SELECT anonpatid, eventdate, 'NSTEMI' AS event FROM che_mi_nstemi_30days) mi;
CREATE INDEX che_mi_composite_30days_patid_index ON che_mi_composite_30days(anonpatid);
CREATE INDEX che_mi_composite_30days_eventdate_index ON che_mi_composite_30days(eventdate);
CREATE INDEX che_mi_composite_30days_event_index ON che_mi_composite_30days(event);


-- record if stable for 60 days post mi so can be added to SCAD post mi cohort
ALTER TABLE che_mi_composite_30days ADD COLUMN stable_post_mi BOOLEAN DEFAULT TRUE;
UPDATE che_mi_composite_30days SET stable_post_mi = FALSE WHERE (anonpatid,eventdate) IN (SELECT anonpatid, eventdate FROM 
(SELECT mi.anonpatid, mi.eventdate
FROM che_mi_composite_30days mi
LEFT OUTER JOIN che_cvd_composite_30days c
ON c.anonpatid = mi.anonpatid AND c.eventdate >= mi.eventdate AND c.eventdate - mi.eventdate < 60
GROUP BY mi.anonpatid, mi.eventdate, c.eventdate
HAVING count(c.eventdate) > 1
ORDER BY anonpatid) sub);


-- create composite event table
DROP TABLE IF EXISTS che_all_events_30days;
CREATE TABLE che_all_events_30days(
eventid SERIAL PRIMARY KEY,
anonpatid int,
eventdate date,
event varchar,
event_type varchar,
fatal boolean
);
CREATE INDEX che_all_events_30days_patid_index ON che_all_events_30days(anonpatid);
CREATE INDEX che_all_events_30days_eventdate_index ON che_all_events_30days(eventdate);
CREATE INDEX che_all_events_30days_event_index ON che_all_events_30days(event);
CREATE INDEX che_all_events_30days_eventtype_index ON che_all_events_30days(event_type);

-- stored procedure to insert any missing fatal events and remove deaths
CREATE OR REPLACE FUNCTION clean_all_events() RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT DISTINCT(anonpatid) FROM SCAD_cohort ORDER BY anonpatid;
	events REFCURSOR;
	update_statement TEXT;
	delete_statement TEXT;
	event che_all_events_30days%ROWTYPE;
	previous_event che_all_events_30days%ROWTYPE;
BEGIN

	TRUNCATE TABLE che_all_events_30days;
	INSERT INTO che_all_events_30days (anonpatid, eventdate, event, event_type, fatal) SELECT * FROM (
	SELECT anonpatid, eventdate, 'MI' AS event, 'ACS' AS event_type, FALSE AS fatal FROM che_mi_nos_30days
	UNION
	SELECT anonpatid, eventdate, 'STEMI' AS event, 'ACS' AS event_type, FALSE AS fatal FROM che_mi_stemi_30days
	UNION
	SELECT anonpatid, eventdate, 'NSTEMI' AS event, 'ACS' AS event_type, FALSE AS fatal FROM che_mi_nstemi_30days
	UNION
	--SELECT anonpatid, eventdate, 'USA' AS event, 'ACS' AS event_type, FALSE AS fatal FROM che_usa_30days
	SELECT anonpatid, eventdate, 'OTHER_CVD_DEATH' AS event, 'CVD_DEATH' AS event_type, TRUE AS fatal FROM che_chd_death_30days
	UNION
	SELECT anonpatid, eventdate, 'CHD_DEATH' AS event, 'ACS' AS event_type, TRUE AS fatal FROM che_chd_death_30days
	UNION
	SELECT anonpatid, eventdate, 'STROKE_I' AS event, 'STROKE' AS event_type, FALSE AS fatal FROM che_stroke_I_30days
	UNION
	SELECT anonpatid, eventdate, 'STROKE_H' AS event, 'STROKE' AS event_type, FALSE AS fatal FROM che_stroke_H_30days
	UNION
	SELECT anonpatid, eventdate, 'STROKE_I_DEATH' AS event, 'STROKE' AS event_type, TRUE AS fatal FROM che_stroke_I_death_30days
	UNION
	SELECT anonpatid, eventdate, 'STROKE_H_DEATH' AS event, 'STROKE' AS event_type, TRUE AS fatal FROM che_stroke_H_death_30days
	UNION
	SELECT anonpatid, eventdate, 'OTHER_DEATH' AS event, 'NONCVD_DEATH' AS event_type, TRUE AS fatal  FROM che_noncvd_death
	ORDER BY anonpatid, eventdate) events;


	-- for each patient
	FOR patient IN patients	LOOP
		event = NULL;
		previous_event = NULL;
		OPEN events FOR EXECUTE 'SELECT * FROM che_all_events_30days WHERE anonpatid='||patient.anonpatid||' ORDER BY eventdate, fatal';
		LOOP
		FETCH events INTO event;
		EXIT WHEN NOT FOUND;
			-- remove multiple events on same day keep latest one as this will be the fatal one if either is fatal
			IF event.eventdate = previous_event.eventdate THEN
				delete_statement = 'DELETE FROM che_all_events_30days WHERE eventid = ' ||  previous_event.eventid;
				EXECUTE delete_statement;
			END IF;

			IF event.event = 'CHD_DEATH' THEN
				CASE 
				WHEN previous_event IS NULL THEN
				 	update_statement = 'UPDATE che_all_events_30days SET event = ''MI'' WHERE eventid =' || event.eventid;
				WHEN previous_event.event_type != 'ACS' OR previous_event.eventdate-event.eventdate>30 THEN
					update_statement = 'UPDATE che_all_events_30days SET event = ''MI'' WHERE eventid =' || event.eventid;
				ELSE
					delete_statement = 'DELETE FROM che_all_events_30days WHERE eventid = ' ||  event.eventid;
					EXECUTE delete_statement;
					update_statement = 'UPDATE che_all_events_30days SET fatal = TRUE WHERE eventid =' || previous_event.eventid;
				END CASE;
				EXECUTE update_statement;
			END IF;
			IF event.event = 'STROKE_I_DEATH' THEN
				CASE 
				WHEN previous_event IS NULL THEN
				 	update_statement = 'UPDATE che_all_events_30days SET event = ''STROKE_I'' WHERE eventid =' || event.eventid;
				WHEN previous_event.event_type != 'STROKE' OR previous_event.eventdate-event.eventdate>30 THEN
				 	update_statement = 'UPDATE che_all_events_30days SET event = ''STROKE_I'' WHERE eventid =' || event.eventid;
				ELSE
					delete_statement = 'DELETE FROM che_all_events_30days WHERE eventid = ' ||  event.eventid;
					EXECUTE delete_statement;
					update_statement = 'UPDATE che_all_events_30days SET fatal = TRUE WHERE eventid =' || previous_event.eventid;
				END CASE;
				EXECUTE update_statement;
			END IF;
			IF event.event = 'STROKE_H_DEATH' THEN
				CASE 
				WHEN previous_event IS NULL THEN
				 	update_statement = 'UPDATE che_all_events_30days SET event = ''STROKE_H'' WHERE eventid =' || event.eventid;
				WHEN previous_event.event_type != 'STROKE' OR previous_event.eventdate-event.eventdate>30 THEN
				 	update_statement = 'UPDATE che_all_events_30days SET event = ''STROKE_H'' WHERE eventid =' || event.eventid;
				ELSE
					delete_statement = 'DELETE FROM che_all_events_30days WHERE eventid = ' ||  event.eventid;
					EXECUTE delete_statement;
					update_statement = 'UPDATE che_all_events_30days SET fatal = TRUE WHERE eventid =' || previous_event.eventid;
				END CASE;
				EXECUTE update_statement;
			END IF;
			previous_event = event;
		END LOOP;
		CLOSE events;
	END LOOP;
END; $$
LANGUAGE PLPGSQL;

SELECT clean_all_events();

-- create patient event table for survival analysis
DROP TABLE IF EXISTS che_patient_event;
CREATE TABLE che_patient_event (
pat_event_id SERIAL PRIMARY KEY,
anonpatid int,
time_to_event int,
event varchar,
event_type varchar,
eventdate date,
fatal boolean,
event_number int, 
history_of_acs boolean,
history_of_mi boolean,
history_of_stemi boolean,
history_of_nstemi boolean,
--history_of_usa boolean,
history_of_stroke boolean
);
CREATE INDEX che_patient_event_patid_index ON che_patient_event(anonpatid);

-- stored procedure to calculate time to events for survival analysis
CREATE OR REPLACE FUNCTION calculate_time_to_events() RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date, UPPER(dxscad_type) AS dxscad_type, date_exit, histof_mi, histof_stroke FROM SCAD_cohort WHERE censor_date-dxscad_date > 180 ORDER BY anonpatid;
	events REFCURSOR;
	sql_statement TEXT;
	event che_all_events_30days%ROWTYPE;
	previous_event che_all_events_30days%ROWTYPE;
	days_to_event int;
	acs boolean;
	mi boolean;
	stemi boolean;
	nstemi boolean;
	stroke boolean;
	event_number int;
	start_date DATE;
	event_count int;
	fatal_event_experienced boolean;
BEGIN
	TRUNCATE TABLE che_patient_event;
	-- for each patient
	FOR patient IN patients	LOOP
		event = NULL;
		previous_event = NULL;
		days_to_event = 0;
		-- set the various patient history flags
		acs = FALSE;
		mi = FALSE;
		stemi = FALSE;
		nstemi = FALSE;
		stroke = FALSE;
		event_count = 0;
		fatal_event_experienced = FALSE;
		IF patient.dxscad_type IN ('MI', 'STEMI', 'NSTEMI') OR patient.histof_mi THEN 
			acs = TRUE;
			mi = TRUE;
			IF patient.dxscad_type = 'STEMI' THEN 
				stemi = TRUE;
			END IF;
			IF patient.dxscad_type = 'NSTEMI' THEN 
				nstemi = TRUE;
			END IF;
		END IF;
		IF patient.histof_stroke THEN 
			stroke = TRUE;
		END IF;
		start_date = patient.dxscad_date;
		event_number = 1;

		OPEN events FOR EXECUTE 'SELECT * FROM che_all_events_30days WHERE anonpatid='||patient.anonpatid||' AND eventdate > '|| quote_literal(patient.dxscad_date + 180) ||' AND eventdate <= '|| quote_literal(patient.date_exit) ||' ORDER BY eventdate, fatal';
		LOOP
		FETCH events INTO event;
		EXIT WHEN NOT FOUND;
			IF previous_event IS NOT NULL THEN
				start_date = previous_event.eventdate;
			END IF;
			days_to_event = event.eventdate - start_date;
			sql_statement = 'INSERT INTO che_patient_event (anonpatid, time_to_event, event, event_type, eventdate, fatal, event_number, history_of_acs, history_of_mi, history_of_stemi, history_of_nstemi, history_of_stroke)
			VALUES ('||patient.anonpatid||','|| days_to_event ||','|| quote_literal(event.event) ||','|| quote_literal(event.event_type) || ','|| quote_literal(event.eventdate) || ',' || event.fatal ||','|| event_number ||','|| acs ||','|| mi ||','|| stemi ||','|| nstemi ||','|| stroke ||')';

			-- if patient is already dead any further events in data set must be errors so ignore them
			IF fatal_event_experienced = FALSE THEN
				EXECUTE sql_statement; 
				-- update the patient history flags
				CASE 
					WHEN event.event = 'MI' THEN
						mi = TRUE;
						acs = TRUE;
					WHEN event.event = 'STEMI' THEN
						mi = TRUE;
						acs = TRUE;
						stemi  = TRUE;
					WHEN event.event = 'NSTEMI' THEN
						mi = TRUE;
						acs = TRUE;
						nstemi  = TRUE;
					WHEN event.event_type = 'STROKE' THEN
						stroke = TRUE;
					ELSE
				END CASE;
				previous_event = event;
				event_number = event_number + 1;
			END IF;
			IF event.fatal THEN
				fatal_event_experienced = TRUE;
			END IF;
		END LOOP;
		-- if the final event is non fatal then add the remaining time as censored
		IF previous_event.fatal = FALSE THEN
			days_to_event = patient.date_exit - previous_event.eventdate;
			IF days_to_event >= 0 THEN
				sql_statement = 'INSERT INTO che_patient_event (anonpatid, time_to_event, event, event_type, eventdate, fatal, event_number, history_of_acs, history_of_mi, history_of_stemi, history_of_nstemi, history_of_stroke)
				VALUES ('||patient.anonpatid||','|| days_to_event ||',''CENSORED'',''CENSORED'','|| quote_literal(patient.date_exit) ||','|| FALSE ||','|| event_number ||','|| acs ||','|| mi ||','|| stemi ||','|| nstemi ||','|| stroke ||')';
				EXECUTE sql_statement;
			END IF;
		END IF;
		CLOSE events;

		-- add censored row if no event occurs for patient
		IF event_number = 1 THEN
			days_to_event = patient.date_exit - start_date;
			IF days_to_event > 0 THEN
				sql_statement = 'INSERT INTO che_patient_event (anonpatid, time_to_event, event, event_type, eventdate, fatal, event_number, history_of_acs, history_of_mi, history_of_stemi, history_of_nstemi, history_of_stroke)
				VALUES ('||patient.anonpatid||','|| days_to_event ||',''CENSORED'',''CENSORED'','|| quote_literal(patient.date_exit) ||',' || FALSE ||','|| event_number ||','|| acs ||','|| mi ||','|| stemi ||','|| nstemi ||','|| stroke ||')';
				EXECUTE sql_statement;
			END IF;
		END IF;
		
	END LOOP;
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_time_to_events();




