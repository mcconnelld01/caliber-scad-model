DROP VIEW IF EXISTS competing_risks_events;
CREATE OR REPLACE VIEW competing_risks_events AS
SELECT scad.anonpatid, 
scad.start_date AS patient_start, 
CASE WHEN scad.end_date < COALESCE(eventdate,scad.end_date) THEN eventdate ELSE scad.end_date END AS patient_end, 
COALESCE(event,'CENSORED') AS event, 
COALESCE(time_to_event,scad.end_date-scad.start_date) AS time_to_event, 
COALESCE(eventdate,scad.end_date) AS event_date, 
COALESCE(fatal,FALSE) AS fatal, 
COALESCE(event_number,1) AS event_number 
FROM 
(SELECT anonpatid, (dxscad_date+180) AS start_date, CASE WHEN date_exit>censor_date THEN date_exit ELSE censor_date END AS end_date FROM SCAD_cohort WHERE censor_date-dxscad_date > 180) scad 
LEFT JOIN che_patient_event events ON events.anonpatid = scad.anonpatid AND eventdate > start_date 
ORDER BY anonpatid, event_date;

CREATE OR REPLACE FUNCTION calculate_patient_cost_panel(patid int, start_date date, end_date date) RETURNS RECORD AS $$
DECLARE
	select_statement TEXT;
	hospital_fce float;
	hospital_fce_count int;
	hospital_fce_cvd float;
	hospital_fce_count_cvd int;
	hospital_fce_chd float;
	hospital_fce_count_chd int;
	hospital_spell float;
	hospital_spell_count int;
	hospital_spell_cvd float;
	hospital_spell_count_cvd int;
	hospital_spell_chd float;
	hospital_spell_count_chd int;
	consult float; 
	consult_count int; 
	therapy float; 
	therapy_count int; 
	therapy_cvd float; 
	therapy_count_cvd int;
	on_anticoag boolean;
	on_acei_arb boolean;
	on_antiplat boolean;
	on_beta_blocker boolean;
	on_ccb boolean;
	on_statin boolean;
	los int;
	los_cvd int;
	los_chd int;
	pci_count int;
	cabg_count int;
	test_cat float; 
	test float; 
	test_count int; 
	total float;
	total_count int;
	total_cvd float;
	total_count_cvd int;
	total_chd float;
	total_count_chd int;
	costs RECORD;
BEGIN
 
	select_statement = 'SELECT SUM(fce_cost)+SUM(unbundled_cost) AS cost, COUNT(epikey) AS count FROM hes_episode_cost WHERE anonpatid = '|| patid || ' AND epistart >= ' || quote_literal(start_date) || ' AND epistart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_fce, hospital_fce_count;
	IF hospital_fce IS NULL THEN hospital_fce = 0; END IF;
	IF hospital_fce_count IS NULL THEN hospital_fce_count = 0; END IF;

	select_statement = 'SELECT SUM(fce_cost)+SUM(unbundled_cost) AS cost, COUNT(a.epikey) AS count 
	FROM hes_episode_cost a 
	INNER JOIN (SELECT DISTINCT anonpatid, epikey, epistart FROM hes_diag_epi WHERE anonpatid = '|| patid ||' AND icd LIKE ''I%'')  b 
	ON a.anonpatid = b.anonpatid AND a.epikey = b.epikey AND a.epistart = b.epistart
	WHERE a.anonpatid = '|| patid || ' AND a.epistart >= ' || quote_literal(start_date) || ' AND a.epistart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_fce_cvd, hospital_fce_count_cvd;
	IF hospital_fce_cvd IS NULL THEN hospital_fce_cvd = 0; END IF;
	IF hospital_fce_count_cvd IS NULL THEN hospital_fce_count_cvd = 0; END IF;

	select_statement = 'SELECT SUM(fce_cost)+SUM(unbundled_cost) AS cost, COUNT(a.epikey) AS count 
	FROM hes_episode_cost a 
	INNER JOIN (SELECT DISTINCT anonpatid, epikey, epistart FROM hes_diag_epi WHERE anonpatid = '|| patid ||' AND (icd LIKE ''I20%'' OR icd LIKE ''I21%'' OR icd LIKE ''I22%'' OR icd LIKE ''I23%'' OR icd LIKE ''I24%'' OR icd LIKE ''I25%''))  b 
	ON a.anonpatid = b.anonpatid AND a.epikey = b.epikey AND a.epistart = b.epistart
	WHERE a.anonpatid = '|| patid || ' AND a.epistart >= ' || quote_literal(start_date) || ' AND a.epistart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_fce_chd, hospital_fce_count_chd;
	IF hospital_fce_chd IS NULL THEN hospital_fce_chd = 0; END IF;
	IF hospital_fce_count_chd IS NULL THEN hospital_fce_count_chd = 0; END IF;


	select_statement = 'SELECT SUM(spell_cost) AS cost, COUNT(spno) AS count FROM hes_spell_cost WHERE anonpatid = '|| patid || ' AND spstart >= ' || quote_literal(start_date) || ' AND spstart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_spell, hospital_spell_count;
	IF hospital_spell IS NULL THEN hospital_spell = 0; END IF;
	IF hospital_spell_count IS NULL THEN hospital_spell_count = 0; END IF;

	select_statement = 'SELECT SUM(spell_cost) AS cost, COUNT(a.spno) AS count 
	FROM hes_spell_cost a
	INNER JOIN (SELECT DISTINCT anonpatid, spno FROM hes_diag_epi WHERE anonpatid = '|| patid ||' AND icd LIKE ''I%'')  b 
	ON a.anonpatid = b.anonpatid AND a.spno = b.spno 
	WHERE a.anonpatid = '|| patid || ' AND a.spstart >= ' || quote_literal(start_date) || ' AND a.spstart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_spell_cvd, hospital_spell_count_cvd;
	IF hospital_spell_cvd IS NULL THEN hospital_spell_cvd = 0; END IF;
	IF hospital_spell_count_cvd IS NULL THEN hospital_spell_count_cvd = 0; END IF;

	select_statement = 'SELECT SUM(spell_cost) AS cost, COUNT(a.spno) AS count 
	FROM hes_spell_cost a
	INNER JOIN (SELECT DISTINCT anonpatid, spno FROM hes_diag_epi WHERE anonpatid = '|| patid ||' AND (icd LIKE ''I20%'' OR icd LIKE ''I21%'' OR icd LIKE ''I22%'' OR icd LIKE ''I23%'' OR icd LIKE ''I24%'' OR icd LIKE ''I25%''))  b 
	ON a.anonpatid = b.anonpatid AND a.spno = b.spno 
	WHERE a.anonpatid = '|| patid || ' AND a.spstart >= ' || quote_literal(start_date) || ' AND a.spstart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_spell_chd, hospital_spell_count_chd;
	IF hospital_spell_chd IS NULL THEN hospital_spell_chd = 0; END IF;
	IF hospital_spell_count_chd IS NULL THEN hospital_spell_count_chd = 0; END IF;


	select_statement = 'SELECT SUM(cost) AS cost, COUNT(consultationid) AS count FROM consultation_cost WHERE cost>0 AND anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO consult, consult_count;
	IF consult IS NULL THEN consult = 0; END IF;
	IF consult_count IS NULL THEN consult_count = 0; END IF;

	select_statement = 'SELECT SUM(cost) AS cost, COUNT(therapyid) AS count FROM therapy_cost WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO therapy, therapy_count;
	IF therapy IS NULL THEN therapy = 0; END IF;
	IF therapy_count IS NULL THEN therapy_count = 0; END IF;

	select_statement = 'SELECT SUM(cost) AS cost, COUNT(therapyid) AS count 
	FROM therapy_cost a 
	INNER JOIN lkup_cvd_drugs b
	ON a.prodcode = b.prodcode
	WHERE a.anonpatid = '|| patid || ' AND a.eventdate >= ' || quote_literal(start_date) || ' AND a.eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO therapy_cvd, therapy_count_cvd;
	IF therapy_cvd IS NULL THEN therapy_cvd = 0; END IF;
	IF therapy_count_cvd IS NULL THEN therapy_count_cvd = 0; END IF;

	select_statement = 'SELECT SUM(cost) AS cost FROM test_cost_cat WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO test_cat;
	IF test_cat IS NULL THEN test_cat = 0; END IF;
	
	select_statement = 'SELECT SUM(cost) AS cost, COUNT(testid) AS count FROM test_cost WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO test, test_count;
	IF test IS NULL THEN test = 0; END IF;
	IF test_count IS NULL THEN test_count = 0; END IF;

	select_statement = 'SELECT count(*)>1 FROM var_statin s INNER JOIN treatment_date_threshold t ON t.date_id = s.date_id WHERE anonpatid = '|| patid || ' AND s.numdays_treated > 0 AND (month_start BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' OR month_end BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' )';
	EXECUTE select_statement INTO on_statin;

	select_statement = 'SELECT count(*)>1 FROM var_anticoagulant s INNER JOIN treatment_date_threshold t ON t.date_id = s.date_id WHERE anonpatid = '|| patid || ' AND s.numdays_treated > 0 AND (month_start BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' OR month_end BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' )';
	EXECUTE select_statement INTO on_anticoag;
	
	select_statement = 'SELECT count(*)>1 FROM var_ace_inhibitor_arb s INNER JOIN treatment_date_threshold t ON t.date_id = s.date_id WHERE anonpatid = '|| patid || ' AND s.numdays_treated > 0 AND (month_start BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' OR month_end BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' )';
	EXECUTE select_statement INTO on_acei_arb;
	
	select_statement = 'SELECT count(*)>1 FROM var_antiplatelet s INNER JOIN treatment_date_threshold t ON t.date_id = s.date_id WHERE anonpatid = '|| patid || ' AND s.numdays_treated > 0 AND (month_start BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' OR month_end BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' )';
	EXECUTE select_statement INTO on_antiplat;

	select_statement = 'SELECT count(*)>1 FROM var_beta_blocker s INNER JOIN treatment_date_threshold t ON t.date_id = s.date_id WHERE anonpatid = '|| patid || ' AND s.numdays_treated > 0 AND (month_start BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' OR month_end BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' )';
	EXECUTE select_statement INTO on_beta_blocker;
	
	select_statement = 'SELECT count(*)>1 FROM var_calcium_channel_blocker s INNER JOIN treatment_date_threshold t ON t.date_id = s.date_id WHERE anonpatid = '|| patid || ' AND s.numdays_treated > 0 AND (month_start BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' OR month_end BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' )';
	EXECUTE select_statement INTO on_ccb;

	select_statement = 'SELECT SUM((epiend-epistart)+1) AS los FROM hes_episode_cost WHERE anonpatid = '|| patid || ' AND epistart BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date);
	EXECUTE select_statement INTO los;
	IF los IS NULL THEN los = 0; END IF;

	select_statement = 'SELECT SUM((a.epiend-a.epistart)+1) AS los 
	FROM hes_episode_cost a 
	INNER JOIN (SELECT DISTINCT anonpatid, epikey, epistart FROM hes_diag_epi WHERE anonpatid = '|| patid ||' AND icd LIKE ''I%'')  b 
	ON a.anonpatid = b.anonpatid AND a.epikey = b.epikey AND a.epistart = b.epistart
	WHERE a.anonpatid = '|| patid || ' AND a.epistart BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date);
	EXECUTE select_statement INTO los_cvd;
	IF los_cvd IS NULL THEN los_cvd = 0; END IF;

	select_statement = 'SELECT SUM((a.epiend-a.epistart)+1) AS los 
	FROM hes_episode_cost a 
	INNER JOIN (SELECT DISTINCT anonpatid, epikey, epistart FROM hes_diag_epi WHERE anonpatid = '|| patid ||' AND (icd LIKE ''I20%'' OR icd LIKE ''I21%'' OR icd LIKE ''I22%'' OR icd LIKE ''I23%'' OR icd LIKE ''I24%'' OR icd LIKE ''I25%''))  b 
	ON a.anonpatid = b.anonpatid AND a.epikey = b.epikey AND a.epistart = b.epistart
	WHERE a.anonpatid = '|| patid || ' AND a.epistart BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date) || ' AND  a.eorder = 1';
	EXECUTE select_statement INTO los_chd;
	IF los_chd IS NULL THEN los_chd = 0; END IF;

	select_statement = 'SELECT count(*) FROM var_pci WHERE anonpatid = '|| patid ||' AND eventdate BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date);
	EXECUTE select_statement INTO pci_count;
	IF pci_count IS NULL THEN pci_count = 0; END IF;

	select_statement = 'SELECT count(*) FROM var_cabg WHERE anonpatid = '|| patid ||' AND eventdate BETWEEN ' || quote_literal(start_date) || ' AND ' || quote_literal(end_date);
	EXECUTE select_statement INTO cabg_count;
	IF cabg_count IS NULL THEN cabg_count = 0; END IF;

	total = hospital_fce + consult + therapy + test;
	total_count = hospital_fce_count + consult_count + therapy_count + test_count;
	total_cvd = hospital_fce_cvd + consult + therapy_cvd + test;
	total_count_cvd = hospital_fce_count_cvd + consult_count + therapy_count_cvd + test_count;
	total_chd = hospital_fce_chd + consult + therapy_cvd + test;
	total_count_chd = hospital_fce_count_chd + consult_count + therapy_count_cvd + test_count;
	costs = (patid, start_date, end_date, hospital_fce_count, hospital_fce, hospital_fce_count_cvd, hospital_fce_cvd, hospital_spell_count, hospital_spell, hospital_spell_count_cvd, hospital_spell_cvd, consult_count, consult, therapy_count, therapy, therapy_count_cvd, therapy_cvd, test_cat, test_count, test, total_count, total, total_count_cvd, total_cvd, total_count_chd, total_chd, hospital_spell_count_chd, hospital_spell_chd, hospital_fce_count_chd, hospital_fce_chd, on_anticoag, on_acei_arb, on_antiplat, on_beta_blocker, on_ccb, on_statin, los, los_cvd, los_chd, pci_count, cabg_count);
	
	RETURN costs; 
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION calculate_panel_cost(cycle_length INT) RETURNS int AS $$
DECLARE 
	events CURSOR FOR SELECT * FROM competing_risks_events ORDER BY anonpatid, event_date;
	table_name TEXT;
	sql_statement TEXT;
	numrows INT;
	count INT;
	period_start DATE;
	period_end DATE;
	mi BOOLEAN;
	stroke_i BOOLEAN;
	stroke_h BOOLEAN;
	cvd_fatal BOOLEAN;
	non_cvd_fatal BOOLEAN;
	censored BOOLEAN;
	patid INT;
	period INT;
	event_period INT;
	carried_days INT;
BEGIN
	count = 0;
	numrows = 0;
	table_name = 'che_cost_panel_'|| cycle_length ||'_days_cycle_length_old';
	sql_statement = 'DROP TABLE IF EXISTS '|| table_name ||' CASCADE';
	EXECUTE sql_statement;
	sql_statement = 
	'CREATE TABLE '|| table_name ||'(
	anonpatid int,
	period_number int,
	event_number int,
	event_period int,
	event_date date,
	event_mi boolean,
	event_stroke_i boolean,
	event_stroke_h boolean,
	event_fatal_cvd boolean,
	event_fatal_non_cvd boolean,
	censored boolean,
	start_date date,
	end_date date,
	hospital_fce_count int,
	hospital_fce float,
	hospital_fce_count_cvd int,
	hospital_fce_cvd float,
	hospital_spell_count int,
	hospital_spell float,
	hospital_spell_count_cvd int,
	hospital_spell_cvd float,
	consult_count int,
	consult float,
	therapy_count int,
	therapy float,
	therapy_count_cvd int,
	therapy_cvd float,
	test_cat float,
	test_count int,
	test float,
	total_count int,
	total float,
	total_count_cvd int,
	total_cvd float,
	total_count_chd int, 
	total_chd float, 
	hospital_spell_count_chd int, 
	hospital_spell_chd float, 
	hospital_fce_count_chd int, 
	hospital_fce_chd float, 
	on_anticoag boolean, 
	on_acei_arb boolean, 
	on_antiplat boolean, 
	on_beta_blocker boolean, 
	on_ccb boolean, 
	on_statin boolean, 
	los int, 
	los_cvd int, 
	los_chd int, 
	pci_count int,
	cabg_count int)';
	EXECUTE sql_statement;
		
	FOR event IN events LOOP
		IF count % 20 = 0 THEN
			RAISE INFO 'Calculating costs for patient with ID: %, % events processed, total periods recorded: %', event.anonpatid, count, numrows;
		END IF;
		count = count + 1;

		IF event.anonpatid <> COALESCE(patid,-1) THEN
			period = 1;
			patid = event.anonpatid;
			period_start = event.patient_start;
			carried_days = 0;
			mi = FALSE;
			stroke_i = FALSE;
			stroke_h = FALSE;
			cvd_fatal = FALSE;
			non_cvd_fatal = FALSE;
			censored = FALSE;
		END IF;
			
		period_start = period_start - carried_days;
		carried_days = 0;
		event_period = 1;

		WHILE (period_start <= event.event_date) AND (carried_days = 0) LOOP
			IF (period_start + cycle_length) <= event.event_date THEN
				period_end = period_start + cycle_length;
			ELSIF event.event = 'CENSORED' THEN	
				period_end = period_start + cycle_length;
				censored = TRUE;
				carried_days = 0;
			ELSIF event.fatal THEN	
				period_end = period_start + cycle_length;
				carried_days = 0;
				CASE
				WHEN event.event = 'MI' OR event.event = 'STEMI' OR event.event = 'NSTEMI' THEN
					mi = TRUE;
				WHEN event.event = 'STROKE_I' THEN
					stroke_i = TRUE;
				WHEN event.event = 'STROKE_H' THEN
					stroke_h = TRUE;
				WHEN event.event = 'OTHER_CVD_DEATH' THEN
					cvd_fatal = TRUE;
				WHEN event.event = 'OTHER_DEATH' THEN
					non_cvd_fatal = TRUE;
				ELSE
				END CASE;
				IF mi OR stroke_i OR stroke_h THEN
					cvd_fatal = TRUE;
				END IF;
			ELSE
				carried_days = event.event_date-period_start;
				IF carried_days > 0 THEN
					period_end = event.event_date;
				ELSE
					period_end = period_start + cycle_length;
				END IF;
				CASE
				WHEN event.event = 'MI' OR event.event = 'STEMI' OR event.event = 'NSTEMI' THEN
					mi = TRUE;
				WHEN event.event = 'STROKE_I' THEN
					stroke_i = TRUE;
				WHEN event.event = 'STROKE_H' THEN
					stroke_h = TRUE;
				ELSE
				END CASE;
			END IF;
			
 			IF carried_days = 0 THEN
				sql_statement = 'INSERT INTO '|| table_name ||' 
				SELECT patid,'|| period ||','|| event.event_number ||','|| event_period ||','|| quote_literal(event.event_date) ||','|| mi ||','|| stroke_i ||','|| stroke_h ||','|| cvd_fatal ||','|| non_cvd_fatal ||','|| censored ||
				', start_date, end_date, 
				hospital_fce_count, hospital_fce, hospital_fce_count_cvd, hospital_fce_cvd, 
				hospital_spell_count, hospital_spell, hospital_spell_count_cvd, hospital_spell_cvd, 
				consult_count, consult, therapy_count, therapy, therapy_count_cvd, therapy_cvd, 
				test_cat, test_count, test, total_count, total, total_count_cvd, total_cvd,
				total_count_chd, total_chd, 
				hospital_spell_count_chd, hospital_spell_chd, 
				hospital_fce_count_chd, hospital_fce_chd, 
				on_anticoag, on_acei_arb, on_antiplat, on_beta_blocker, on_ccb, on_statin, 
				los, los_cvd, los_chd, 
				pci_count, cabg_count 
				FROM calculate_patient_cost_panel(' || event.anonpatid ||','|| quote_literal(period_start) ||','|| quote_literal(period_end)||') 
				AS (patid int, start_date date, end_date date, 
				hospital_fce_count int, hospital_fce float, hospital_fce_count_cvd int, hospital_fce_cvd float, 
				hospital_spell_count int, hospital_spell float, hospital_spell_count_cvd int, hospital_spell_cvd float, 
				consult_count int, consult float, therapy_count int, therapy float, therapy_count_cvd int, therapy_cvd float, 
				test_cat float, test_count int, test float, total_count int, total float, total_count_cvd int, total_cvd float,
				total_count_chd int, total_chd float, 
				hospital_spell_count_chd int, hospital_spell_chd float, 
				hospital_fce_count_chd int, hospital_fce_chd float, 
				on_anticoag boolean, on_acei_arb boolean, on_antiplat boolean, on_beta_blocker boolean, on_ccb boolean, on_statin boolean, 
				los int, los_cvd int, los_chd int, 
				pci_count int, cabg_count int)';					
				--RAISE INFO '%', sql_statement;
				--RAISE INFO 'Inserted % rows: ', numrows;
				EXECUTE sql_statement;
				numrows = numrows + 1;
				period = period + 1;
				event_period = event_period + 1;
				mi = FALSE;
				stroke_i = FALSE;
				stroke_h = FALSE;
				cvd_fatal = FALSE;
				non_cvd_fatal = FALSE;
				censored = FALSE;
			END IF;
			
			period_start = period_end;
		END LOOP;
		
	END LOOP;

	--sql_statement = 'ALTER TABLE '|| table_name ||' ADD PRIMARY KEY (anonpatid, period)';
	--EXECUTE sql_statement;
	
	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION calculate_panel_cost2(cycle_length INT) RETURNS int AS $$
DECLARE 
	events CURSOR FOR SELECT * FROM
		(SELECT anonpatid, patient_start, event AS first_event, event_date AS first_event_date, fatal AS first_event_fatal FROM competing_risks_events WHERE event_number = 1) first 
		INNER JOIN
		(SELECT anonpatid AS final_patid, event AS final_event, event_date AS final_event_date, fatal AS final_event_fatal FROM competing_risks_events WHERE (anonpatid,event_number) IN (SELECT anonpatid, MAX(event_number) FROM competing_risks_events GROUP BY anonpatid)) final
		ON first.anonpatid = final.final_patid
		ORDER BY anonpatid;
	table_name TEXT;
	sql_statement TEXT;
	numrows INT;
	count INT;
	period_start DATE;
	period_end DATE;
	mi BOOLEAN;
	stroke_i BOOLEAN;
	stroke_h BOOLEAN;
	cvd_fatal BOOLEAN;
	non_cvd_fatal BOOLEAN;
	censored BOOLEAN;
	patid INT;
	period INT;
BEGIN
	count = 0;
	numrows = 0;
	table_name = 'che_cost_panel_'|| cycle_length ||'_days_cycle_length';
	sql_statement = 'DROP TABLE IF EXISTS '|| table_name ||' CASCADE';
	EXECUTE sql_statement;
	sql_statement = 
	'CREATE TABLE '|| table_name ||'(
	anonpatid int,
	period_number int,
	event_mi boolean,
	event_stroke_i boolean,
	event_stroke_h boolean,
	event_fatal_cvd boolean,
	event_fatal_non_cvd boolean,
	censored boolean,
	start_date date,
	end_date date,
	hospital_fce_count int,
	hospital_fce float,
	hospital_fce_count_cvd int,
	hospital_fce_cvd float,
	hospital_spell_count int,
	hospital_spell float,
	hospital_spell_count_cvd int,
	hospital_spell_cvd float,
	consult_count int,
	consult float,
	therapy_count int,
	therapy float,
	therapy_count_cvd int,
	therapy_cvd float,
	test_cat float,
	test_count int,
	test float,
	total_count int,
	total float,
	total_count_cvd int,
	total_cvd float,
	total_count_chd int, 
	total_chd float, 
	hospital_spell_count_chd int, 
	hospital_spell_chd float, 
	hospital_fce_count_chd int, 
	hospital_fce_chd float, 
	on_anticoag boolean, 
	on_acei_arb boolean, 
	on_antiplat boolean, 
	on_beta_blocker boolean, 
	on_ccb boolean, 
	on_statin boolean, 
	los int, 
	los_cvd int, 
	los_chd int, 
	pci_count int,
	cabg_count int)';
	EXECUTE sql_statement;
		
	FOR event IN events LOOP
		IF count % 20 = 0 THEN
			RAISE INFO 'Calculating costs for patient with ID: %, % events processed, total periods recorded: %', event.anonpatid, count, numrows;
		END IF;
		count = count + 1;
		period = 1;
		patid = event.anonpatid;
		period_start = event.patient_start;
		mi = FALSE;
		stroke_i = FALSE;
		stroke_h = FALSE;
		cvd_fatal = FALSE;
		non_cvd_fatal = FALSE;
		censored = FALSE;

		WHILE (period_start <= event.final_event_date) LOOP
			period_end = period_start + cycle_length;
			-- if in a cycle before or after first event occurs
			IF (period_start + cycle_length) <= event.first_event_date OR period_start > event.first_event_date THEN
				-- if final event occurs in this cylce record it
				IF (period_start + cycle_length) >= event.final_event_date THEN
					CASE
					WHEN event.final_event = 'MI' OR event.final_event = 'STEMI' OR event.final_event = 'NSTEMI' THEN
						mi = TRUE;
					WHEN event.final_event = 'STROKE_I' THEN
						stroke_i = TRUE;
					WHEN event.final_event = 'STROKE_H' THEN
						stroke_h = TRUE;
					WHEN event.final_event = 'OTHER_CVD_DEATH' THEN
						cvd_fatal = TRUE;
					WHEN event.final_event = 'OTHER_DEATH' THEN
						non_cvd_fatal = TRUE;
					WHEN event.final_event = 'CENSORED' THEN	
						censored = TRUE;
					ELSE
					END CASE;
					IF mi OR stroke_i OR stroke_h THEN
						cvd_fatal = TRUE;
					END IF;	
				END IF;
			-- if a first event occurs in this cycle
			ELSE 	
				CASE
				WHEN event.first_event = 'CENSORED' THEN
					censored = TRUE;				
				WHEN event.first_event = 'MI' OR event.first_event = 'STEMI' OR event.first_event = 'NSTEMI' THEN
					mi = TRUE;
				WHEN event.first_event = 'STROKE_I' THEN
					stroke_i = TRUE;
				WHEN event.first_event = 'STROKE_H' THEN
					stroke_h = TRUE;
				WHEN event.first_event = 'OTHER_CVD_DEATH' THEN
					cvd_fatal = TRUE;
				WHEN event.first_event = 'OTHER_DEATH' THEN
					non_cvd_fatal = TRUE;
				ELSE
				END CASE;
				IF (mi OR stroke_i OR stroke_h) AND event.first_event_fatal THEN
					cvd_fatal = TRUE;
				END IF;
			END IF;
			

			sql_statement = 'INSERT INTO '|| table_name ||' 
			SELECT patid,'|| period ||','|| mi ||','|| stroke_i ||','|| stroke_h ||','|| cvd_fatal ||','|| non_cvd_fatal ||','|| censored ||
			', start_date, end_date, 
			hospital_fce_count, hospital_fce, hospital_fce_count_cvd, hospital_fce_cvd, 
			hospital_spell_count, hospital_spell, hospital_spell_count_cvd, hospital_spell_cvd, 
			consult_count, consult, therapy_count, therapy, therapy_count_cvd, therapy_cvd, 
			test_cat, test_count, test, total_count, total, total_count_cvd, total_cvd,
			total_count_chd, total_chd, 
			hospital_spell_count_chd, hospital_spell_chd, 
			hospital_fce_count_chd, hospital_fce_chd, 
			on_anticoag, on_acei_arb, on_antiplat, on_beta_blocker, on_ccb, on_statin, 
			los, los_cvd, los_chd, 
			pci_count, cabg_count 
			FROM calculate_patient_cost_panel(' || event.anonpatid ||','|| quote_literal(period_start) ||','|| quote_literal(period_end)||') 
			AS (patid int, start_date date, end_date date, 
			hospital_fce_count int, hospital_fce float, hospital_fce_count_cvd int, hospital_fce_cvd float, 
			hospital_spell_count int, hospital_spell float, hospital_spell_count_cvd int, hospital_spell_cvd float, 
			consult_count int, consult float, therapy_count int, therapy float, therapy_count_cvd int, therapy_cvd float, 
			test_cat float, test_count int, test float, total_count int, total float, total_count_cvd int, total_cvd float,
			total_count_chd int, total_chd float, 
			hospital_spell_count_chd int, hospital_spell_chd float, 
			hospital_fce_count_chd int, hospital_fce_chd float, 
			on_anticoag boolean, on_acei_arb boolean, on_antiplat boolean, on_beta_blocker boolean, on_ccb boolean, on_statin boolean, 
			los int, los_cvd int, los_chd int, 
			pci_count int, cabg_count int)';					
			--RAISE INFO '%', sql_statement;
			--RAISE INFO 'Inserted % rows: ', numrows;
			EXECUTE sql_statement;
			numrows = numrows + 1;
			period = period + 1;
			mi = FALSE;
			stroke_i = FALSE;
			stroke_h = FALSE;
			cvd_fatal = FALSE;
			non_cvd_fatal = FALSE;
			censored = FALSE;
			
			period_start = period_end;
		END LOOP;
		
	END LOOP;

	--sql_statement = 'ALTER TABLE '|| table_name ||' ADD PRIMARY KEY (anonpatid, period)';
	--EXECUTE sql_statement;
	
	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;


SELECT calculate_panel_cost2(90);


COPY (SELECT anonpatid,
	period_number,
	CASE event_mi WHEN TRUE THEN 1 ELSE 0 END AS event_mi,
	CASE event_stroke_i WHEN TRUE THEN 1 ELSE 0 END AS event_stroke_i,
	CASE event_stroke_h  WHEN TRUE THEN 1 ELSE 0 END AS event_stroke_h,
	CASE event_fatal_cvd  WHEN TRUE THEN 1 ELSE 0 END AS event_fatal_cvd,
	CASE event_fatal_non_cvd  WHEN TRUE THEN 1 ELSE 0 END AS event_fatal_non_cvd,
	CASE censored  WHEN TRUE THEN 1 ELSE 0 END AS censored,
	start_date,
	end_date,
	hospital_fce_count,
	hospital_fce,
	hospital_fce_count_cvd,
	hospital_fce_cvd,
	hospital_spell_count,
	hospital_spell,
	hospital_spell_count_cvd,
	hospital_spell_cvd,
	consult_count,
	consult,
	therapy_count,
	therapy,
	therapy_count_cvd,
	therapy_cvd,
	test_cat,
	test_count,
	test,
	total_count,
	total,
	total_count_cvd,
	total_cvd,
	total_count_chd, 
	total_chd, 
	hospital_spell_count_chd, 
	hospital_spell_chd, 
	hospital_fce_count_chd, 
	hospital_fce_chd, 
	CASE on_anticoag WHEN TRUE THEN 1 ELSE 0 END AS on_anticoag, 
	CASE on_acei_arb WHEN TRUE THEN 1 ELSE 0 END AS on_acei_arb,  
	CASE on_antiplat WHEN TRUE THEN 1 ELSE 0 END AS on_antiplat,  
	CASE on_beta_blocker WHEN TRUE THEN 1 ELSE 0 END AS on_beta_blocker, 
	CASE on_ccb WHEN TRUE THEN 1 ELSE 0 END AS on_ccb,  
	CASE on_statin WHEN TRUE THEN 1 ELSE 0 END AS on_statin,  
	los, 
	los_cvd, 
	los_chd, 
	pci_count, 
	cabg_count 
	FROM che_cost_panel_90_days_cycle_length ORDER BY anonpatid, period_number) TO 'C:/CALIBER/cost_panel_90_day_cycle_export.csv' CSV HEADER;


CREATE OR REPLACE FUNCTION calculate_one_year_post_event_cost() RETURNS int AS $$
DECLARE 
	events CURSOR FOR SELECT inc.* FROM
	(SELECT *, event_date+365 AS one_year_post_event FROM competing_risks_events WHERE event_number=1 AND event != 'CENSORED' AND fatal=FALSE) inc
	LEFT JOIN
	(SELECT anonpatid AS patid, event_date AS cens_date FROM competing_risks_events WHERE event='CENSORED') exc
	ON inc.anonpatid = exc.patid AND one_year_post_event > cens_date
	WHERE patid IS NULL ORDER BY anonpatid;
	table_name TEXT;
	sql_statement TEXT;
	numrows INT;
	count INT;
	mi BOOLEAN;
	stroke_i BOOLEAN;
	stroke_h BOOLEAN;
BEGIN
	count = 0;
	numrows = 0;
	table_name = 'che_cost_one_year_post_event';
	sql_statement = 'DROP TABLE IF EXISTS '|| table_name ||' CASCADE';
	EXECUTE sql_statement;
	sql_statement = 
	'CREATE TABLE '|| table_name ||'(
	anonpatid int,
	event_mi boolean,
	event_stroke_i boolean,
	event_stroke_h boolean,
	start_date date,
	end_date date,
	hospital_fce_count int,
	hospital_fce float,
	hospital_fce_count_cvd int,
	hospital_fce_cvd float,
	hospital_spell_count int,
	hospital_spell float,
	hospital_spell_count_cvd int,
	hospital_spell_cvd float,
	consult_count int,
	consult float,
	therapy_count int,
	therapy float,
	therapy_count_cvd int,
	therapy_cvd float,
	test_cat float,
	test_count int,
	test float,
	total_count int,
	total float,
	total_count_cvd int,
	total_cvd float,
	total_count_chd int, 
	total_chd float, 
	hospital_spell_count_chd int, 
	hospital_spell_chd float, 
	hospital_fce_count_chd int, 
	hospital_fce_chd float, 
	on_anticoag boolean, 
	on_acei_arb boolean, 
	on_antiplat boolean, 
	on_beta_blocker boolean, 
	on_ccb boolean, 
	on_statin boolean, 
	los int, 
	los_cvd int, 
	los_chd int, 
	pci_count int,
	cabg_count int)';
	EXECUTE sql_statement;
		
	FOR event IN events LOOP
		IF count % 20 = 0 THEN
			RAISE INFO 'Calculating costs for patient with ID: %, % events processed, total periods recorded: %', event.anonpatid, count, numrows;
		END IF;
		count = count + 1;
		mi = FALSE;
		stroke_i = FALSE;
		stroke_h = FALSE;

		CASE
		WHEN event.event = 'MI' OR event.event = 'STEMI' OR event.event = 'NSTEMI' THEN
			mi = TRUE;
		WHEN event.event = 'STROKE_I' THEN
			stroke_i = TRUE;
		WHEN event.event = 'STROKE_H' THEN
			stroke_h = TRUE;
		ELSE
		END CASE;

		sql_statement = 'INSERT INTO '|| table_name ||' 
		SELECT patid,' || mi ||','|| stroke_i ||','|| stroke_h ||
		', start_date, end_date, 
		hospital_fce_count, hospital_fce, hospital_fce_count_cvd, hospital_fce_cvd, 
		hospital_spell_count, hospital_spell, hospital_spell_count_cvd, hospital_spell_cvd, 
		consult_count, consult, therapy_count, therapy, therapy_count_cvd, therapy_cvd, 
		test_cat, test_count, test, total_count, total, total_count_cvd, total_cvd,
		total_count_chd, total_chd, 
		hospital_spell_count_chd, hospital_spell_chd, 
		hospital_fce_count_chd, hospital_fce_chd, 
		on_anticoag, on_acei_arb, on_antiplat, on_beta_blocker, on_ccb, on_statin, 
		los, los_cvd, los_chd, 
		pci_count, cabg_count 
		FROM calculate_patient_cost_panel(' || event.anonpatid ||','|| quote_literal(event.event_date) ||','|| quote_literal(event.one_year_post_event)||') 
		AS (patid int, start_date date, end_date date, 
		hospital_fce_count int, hospital_fce float, hospital_fce_count_cvd int, hospital_fce_cvd float, 
		hospital_spell_count int, hospital_spell float, hospital_spell_count_cvd int, hospital_spell_cvd float, 
		consult_count int, consult float, therapy_count int, therapy float, therapy_count_cvd int, therapy_cvd float, 
		test_cat float, test_count int, test float, total_count int, total float, total_count_cvd int, total_cvd float,
		total_count_chd int, total_chd float, 
		hospital_spell_count_chd int, hospital_spell_chd float, 
		hospital_fce_count_chd int, hospital_fce_chd float, 
		on_anticoag boolean, on_acei_arb boolean, on_antiplat boolean, on_beta_blocker boolean, on_ccb boolean, on_statin boolean, 
		los int, los_cvd int, los_chd int, 
		pci_count int, cabg_count int)';					
		EXECUTE sql_statement;
		numrows = numrows + 1;
		mi = FALSE;
		stroke_i = FALSE;
		stroke_h = FALSE;
	END LOOP;

	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_one_year_post_event_cost();


COPY (SELECT anonpatid,
	CASE event_mi WHEN TRUE THEN 1 ELSE 0 END AS event_mi,
	CASE event_stroke_i WHEN TRUE THEN 1 ELSE 0 END AS event_stroke_i,
	CASE event_stroke_h  WHEN TRUE THEN 1 ELSE 0 END AS event_stroke_h,
	start_date,
	end_date,
	hospital_fce_count,
	hospital_fce,
	hospital_fce_count_cvd,
	hospital_fce_cvd,
	hospital_spell_count,
	hospital_spell,
	hospital_spell_count_cvd,
	hospital_spell_cvd,
	consult_count,
	consult,
	therapy_count,
	therapy,
	therapy_count_cvd,
	therapy_cvd,
	test_cat,
	test_count,
	test,
	total_count,
	total,
	total_count_cvd,
	total_cvd,
	total_count_chd, 
	total_chd, 
	hospital_spell_count_chd, 
	hospital_spell_chd, 
	hospital_fce_count_chd, 
	hospital_fce_chd, 
	CASE on_anticoag WHEN TRUE THEN 1 ELSE 0 END AS on_anticoag, 
	CASE on_acei_arb WHEN TRUE THEN 1 ELSE 0 END AS on_acei_arb,  
	CASE on_antiplat WHEN TRUE THEN 1 ELSE 0 END AS on_antiplat,  
	CASE on_beta_blocker WHEN TRUE THEN 1 ELSE 0 END AS on_beta_blocker, 
	CASE on_ccb WHEN TRUE THEN 1 ELSE 0 END AS on_ccb,  
	CASE on_statin WHEN TRUE THEN 1 ELSE 0 END AS on_statin,  
	los, 
	los_cvd, 
	los_chd, 
	pci_count, 
	cabg_count 
	FROM che_cost_one_year_post_event ORDER BY anonpatid) TO 'C:/CALIBER/cost_one_year_post_event_export.csv' CSV HEADER;
