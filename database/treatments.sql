--- Stored procedures to calculate days on treatment

CREATE OR REPLACE FUNCTION calculate_treatment_tables(treatment TEXT) RETURNS VOID AS $$
DECLARE 
	create_statement TEXT;
	drop_statement TEXT;
	index_statement TEXT;
BEGIN
	-- create treatment table
	drop_statement = 'DROP TABLE IF EXISTS var_'||treatment||' CASCADE';
	EXECUTE drop_statement;
	create_statement = 
	'CREATE TABLE var_'||treatment||'(
	'||treatment||'_id SERIAL PRIMARY KEY,
	anonpatid int,
	date_id int,
	numdays_treated int
	)';
	EXECUTE create_statement;
	-- create indices on treatment table
	index_statement = 'CREATE INDEX var_'||treatment||'_patid_index ON var_'||treatment||'(anonpatid)';
	EXECUTE index_statement;
	index_statement = 'CREATE INDEX var_'||treatment||'_dateid_index ON var_'||treatment||'(date_id)';
	EXECUTE index_statement;

	-- create temporary table to calculate number of days on treatment
	create_statement = 
	'CREATE TEMPORARY TABLE temp_var_'||treatment||' ON COMMIT DROP 
	AS 
	SELECT t.anonpatid, t.eventdate, t.textid, t.qty, t.ndd, t.prodcode,
	CASE 
	WHEN (t.qty>0 AND t.ndd>0) THEN t.eventdate + (t.qty/t.ndd)::int - 1
	WHEN (t.qty>0 AND t.ndd=0) THEN t.eventdate + t.qty::int - 1
	WHEN (t.qty=0) THEN t.eventdate
	ELSE null
	END enddate
	FROM '||treatment||' st 
	INNER JOIN therapy t ON st.prodcode=t.prodcode
	INNER JOIN SCAD_cohort s ON t.anonpatid=s.anonpatid
	ORDER BY t.anonpatid, t.eventdate';
	EXECUTE create_statement;
	-- create indeces on temporary table
	index_statement = 'CREATE INDEX temp_var_'||treatment||'_patid_index ON temp_var_'||treatment||'(anonpatid)';
	EXECUTE index_statement;
	index_statement = 'CREATE INDEX temp_var_'||treatment||'_eventdate_index ON temp_var_'||treatment||'(eventdate)';
	EXECUTE index_statement;
	index_statement = 'CREATE INDEX temp_var_'||treatment||'_enddate_index ON temp_var_'||treatment||'(enddate)';
	EXECUTE index_statement;

	-- create view to show who is on treatment
	create_statement = 
	'CREATE OR REPLACE VIEW on_'||treatment||' AS 
	SELECT s.*, CASE 
	WHEN (s.numdays_treated >= d.threshold) THEN '||quote_literal('C')||'
	WHEN (s.numdays_treated < d.threshold AND s.numdays_treated > 0) THEN '||quote_literal('I')||'
	WHEN (s.numdays_treated = 0) THEN '||quote_literal('N')||'
	ELSE null
	END is_treated
	FROM var_'||treatment||' s INNER JOIN treatment_date_threshold d 
	ON s.date_id = d.date_id';
	EXECUTE create_statement;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION calculateDaysOnTreatment(treatment TEXT, period_start_date DATE, period_end_date DATE, patid INT) RETURNS int AS $$
DECLARE 
	select_statement TEXT;
	numresults int;
	sumresults int;
	numdays int;
	max_numdays int;
BEGIN
	numdays = 0;
	max_numdays = (period_end_date - period_start_date) + 1;
	numresults = 0;
	sumresults = 0;

	select_statement = 'SELECT COUNT(*) FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate <= ' || quote_literal(period_start_date) || ' AND enddate >= ' || quote_literal(period_end_date);
	EXECUTE select_statement INTO numresults;
	-- if prescription contains entire period 
	IF numresults > 0 THEN
		numdays = max_numdays;
	ELSE
		-- if prescription starts before period start date and ends before period end date count days between period start date and end of prescription
		select_statement = 'SELECT COUNT(*) FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate <= ' || quote_literal(period_start_date) || ' AND enddate >= ' || quote_literal(period_start_date) || ' AND enddate <= '|| quote_literal(period_end_date);
		EXECUTE select_statement INTO numresults;
		IF numresults > 0 THEN
			select_statement = 'SELECT SUM(enddate-'||quote_literal(period_start_date)||') FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate <= ' || quote_literal(period_start_date) || ' AND enddate >= ' || quote_literal(period_start_date) || ' AND enddate <= '|| quote_literal(period_end_date);
			EXECUTE select_statement INTO sumresults;
			numdays = numdays + numresults + sumresults;
		END IF;
		-- if prescription starts after period start date and ends after period end date count days between prescription start and period end date
		select_statement = 'SELECT COUNT(*) FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate >= ' || quote_literal(period_start_date) || ' AND eventdate <= ' || quote_literal(period_end_date) || ' AND enddate >= '|| quote_literal(period_end_date);
		EXECUTE select_statement INTO numresults;
		IF numresults > 0 THEN
			select_statement = 'SELECT SUM('||quote_literal(period_end_date)||'-eventdate) FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate >= ' || quote_literal(period_start_date) || ' AND eventdate <= ' || quote_literal(period_end_date) || ' AND enddate >= '|| quote_literal(period_end_date);
			EXECUTE select_statement INTO sumresults;
			numdays = numdays + numresults + sumresults;
		END IF;
		-- if one or more prescriptions fall within period start and end dates add these to numdays
		select_statement = 'SELECT COUNT(*) FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate >= ' || quote_literal(period_start_date) || ' AND enddate <= ' || quote_literal(period_end_date) || ' AND enddate < '|| quote_literal(period_end_date);
		EXECUTE select_statement INTO numresults;
		IF numresults > 0 THEN
			select_statement = 'SELECT SUM(enddate-eventdate) FROM  temp_var_' || treatment || ' WHERE anonpatid =' || patid || ' AND eventdate >= ' || quote_literal(period_start_date) || ' AND enddate <= ' || quote_literal(period_end_date) || ' AND enddate < '|| quote_literal(period_end_date);
			EXECUTE select_statement INTO sumresults;
			numdays = numdays + numresults + sumresults;
		END IF;
	END IF;
	
	RETURN LEAST(numdays,max_numdays);
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION calculate_treatment_days(treatment TEXT) RETURNS int AS $$
DECLARE 
	patients CURSOR FOR SELECT DISTINCT(anonpatid), dxscad_date, CASE WHEN date_exit >= censor_date THEN date_exit WHEN date_exit < censor_date THEN censor_date END max_date FROM SCAD_cohort ORDER BY anonpatid;
	dates CURSOR FOR SELECT * FROM lkup_date ORDER BY date_id;
	create_statement TEXT;
	insert_statement TEXT;
	drop_statement TEXT;
	index_statement TEXT;
	numrows int;
	numdaystreated int;
	count int;
BEGIN
	count = 0;
	numrows = 0;
	numdaystreated = 0;

	-- create temporary and permenant treatment tables
	PERFORM calculate_treatment_tables(treatment);
	
	FOR patient IN patients	LOOP
		IF count % 100 = 0 THEN
			RAISE INFO 'Calculating days on % for patient with ID: %, % patients processed', treatment, patient.anonpatid, count;
		END IF;
		count = count + 1;
		-- loop through all possible months
		FOR adate IN dates LOOP
			-- if period end date is before patient joined cohort or 
			-- period start date is after patient left cohort
			-- enter nulls in treatment tables for date
			IF adate.month_end < patient.dxscad_date OR adate.month_start > patient.max_date THEN
				insert_statement = 'INSERT INTO var_' || treatment || ' (anonpatid, date_id, numdays_treated) VALUES (' || patient.anonpatid || ',' || adate.date_id || ', null)';
				EXECUTE insert_statement;
			
			ELSE
			-- count how many days on each treatment this period
				SELECT calculateDaysOnTreatment(treatment, adate.month_start, adate.month_end, patient.anonpatid) INTO numdaystreated;
				-- save results for this patient for this period for each treatment back to database
				insert_statement = 'INSERT INTO var_' || treatment || ' (anonpatid, date_id, numdays_treated) VALUES (' || patient.anonpatid || ',' || adate.date_id || ',' || numdaystreated || ')';
				EXECUTE insert_statement;
			END IF;
			numrows = numrows+1;
		END LOOP;
	END LOOP;
	
	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;

--- Add a month lookup table

DROP TABLE IF EXISTS lkup_date CASCADE;
CREATE TABLE lkup_date(
date_id SERIAL PRIMARY KEY,
month_start date,
month_end date,
numdays int
);
COPY lkup_date(date_id, month_start, month_end, numdays) FROM 'C:\CALIBER\Documents\Lookups\dates.csv' DELIMITER ',' CSV HEADER;

--- Add some views to help with analysis
CREATE OR REPLACE VIEW statin AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%statins%';

CREATE OR REPLACE VIEW ace_inhibitor_arb AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%angiotensin-converting enzyme inhibitors%' OR LOWER(bnfchapter) LIKE '%angiotensin-ii receptor antagonists%';

CREATE OR REPLACE VIEW beta_blocker AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%beta-adrenoceptor blocking drugs%';

CREATE OR REPLACE VIEW aspirin AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%antiplatelet drugs%' AND LOWER(drugsubstance) LIKE '%aspirin%';

CREATE OR REPLACE VIEW anticoagulant AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%anticoagulant%';

CREATE OR REPLACE VIEW antiplatelet AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%antiplatelet drugs%';

CREATE OR REPLACE VIEW cv_hypertension AS 
SELECT e.enttype, e.description AS entity_description, c.medcode, m.readcode, m.description, COUNT(c.medcode) AS num 
FROM lkup_entity e, clinical c, lkup_medical m 
WHERE e.category = 'CV / Hypertension' AND e.filetype='Clinical' AND e.enttype=c.enttype AND m.medcode=c.medcode 
GROUP BY e.enttype, c.medcode, m.readcode, m.description 
ORDER BY enttype, num desc;

CREATE OR REPLACE VIEW clopidogrel AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%antiplatelet drugs%' AND LOWER(drugsubstance) LIKE '%clopidogrel%';

CREATE OR REPLACE VIEW warfarin AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%anticoagulant%' AND LOWER(drugsubstance) LIKE '%warfarin%';

CREATE OR REPLACE VIEW heparin AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%anticoagulant%' AND LOWER(drugsubstance) LIKE '%heparin%';

CREATE OR REPLACE VIEW nitrate AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%nitrates%';

CREATE OR REPLACE VIEW calcium_channel_blocker AS 
SELECT prodcode, productname, bnfchapter 
FROM lkup_product 
WHERE LOWER(bnfchapter) LIKE '%calcium channel blockers%'; 

--- set the threshold for what we mean by continuous treatment
CREATE OR REPLACE VIEW treatment_date_threshold AS 
SELECT *, ROUND(numdays*0.8) threshold FROM lkup_date
ORDER BY date_id;

--- calculate treatment days on each treatment
SELECT calculate_treatment_days('statin');
ALTER TABLE var_statin ADD CONSTRAINT var_statin_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('aspirin');
ALTER TABLE var_aspirin ADD CONSTRAINT var_aspirin_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('beta_blocker');
ALTER TABLE var_beta_blocker ADD CONSTRAINT var_beta_blocker_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('ace_inhibitor_arb');
ALTER TABLE var_ace_inhibitor_arb ADD CONSTRAINT var_ace_inhibitor_arb_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('anticoagulant');
ALTER TABLE var_anticoagulant ADD CONSTRAINT var_anticoagulant_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('antiplatelet');
ALTER TABLE var_antiplatelet ADD CONSTRAINT var_antiplatelet_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('clopidogrel');
ALTER TABLE var_clopidogrel ADD CONSTRAINT var_clopidogrel_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('warfarin');
ALTER TABLE var_warfarin ADD CONSTRAINT var_warfarin_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('heparin');
ALTER TABLE var_heparin ADD CONSTRAINT var_heparin_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('nitrate');
ALTER TABLE var_nitrate ADD CONSTRAINT var_nitrate_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

SELECT calculate_treatment_days('calcium_channel_blocker');
ALTER TABLE var_calcium_channel_blocker ADD CONSTRAINT var_calcium_channel_blocker_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);

------ views to decide if patients are on treatment ---------

CREATE OR REPLACE VIEW on_secondary_prevention AS 
SELECT beta.anonpatid, beta.date_id, beta.is_treated on_beta_blocker, ace_arb.is_treated on_ace_arb, statin.is_treated on_statin, aspirin.is_treated on_aspirin, clopidogrel.is_treated on_clopidogrel,
CASE 
WHEN (beta.is_treated = 'C' AND ace_arb.is_treated='C' AND statin.is_treated='C' AND aspirin.is_treated='C' AND clopidogrel.is_treated='C') THEN 'C' -- consistently on all
WHEN (beta.is_treated = 'N' AND ace_arb.is_treated='N' AND statin.is_treated='N' AND aspirin.is_treated='N' AND clopidogrel.is_treated='N') THEN 'N' -- definitely not on any
WHEN (beta.is_treated = 'N' OR ace_arb.is_treated='N' OR statin.is_treated='N' OR aspirin.is_treated='N' OR clopidogrel.is_treated='N') THEN 'P' -- on some but not all treatments (partial)
WHEN (beta.is_treated = 'I' OR ace_arb.is_treated='I' OR statin.is_treated='I' OR aspirin.is_treated='I' OR clopidogrel.is_treated='I') THEN 'I' -- on all drugs but atleast one is intermittent
ELSE null
END is_treated,
CASE 
WHEN (beta.is_treated = 'C' AND ace_arb.is_treated='C' AND statin.is_treated='C' AND aspirin.is_treated='C') THEN 'C' -- consistently on all
WHEN (beta.is_treated = 'N' AND ace_arb.is_treated='N' AND statin.is_treated='N' AND aspirin.is_treated='N') THEN 'N' -- definitely not on any
WHEN (beta.is_treated = 'N' OR ace_arb.is_treated='N' OR statin.is_treated='N' OR aspirin.is_treated='N') THEN 'P' -- on some but not all treatments (partial)
WHEN (beta.is_treated = 'I' OR ace_arb.is_treated='I' OR statin.is_treated='I' OR aspirin.is_treated='I') THEN 'I' -- on all drugs but atleast one is intermittent
ELSE null
END is_treated_minus_clopidogrel
FROM on_beta_blocker beta 
INNER JOIN on_ace_inhibitor_arb ace_arb
ON beta.anonpatid = ace_arb.anonpatid AND beta.date_id=ace_arb.date_id
INNER JOIN on_statin statin
ON beta.anonpatid = statin.anonpatid AND beta.date_id=statin.date_id
INNER JOIN on_aspirin aspirin
ON beta.anonpatid = aspirin.anonpatid AND beta.date_id=aspirin.date_id
INNER JOIN on_clopidogrel clopidogrel
ON beta.anonpatid = clopidogrel.anonpatid AND beta.date_id=clopidogrel.date_id;

CREATE OR REPLACE VIEW on_warfarin_aspirin_clopidogrel_continuous AS 
SELECT w.anonpatid, w.date_id, w.is_treated on_warfarin, a.is_treated on_aspirin, c.is_treated on_clopidogrel,
CASE 
WHEN (w.is_treated='C' AND a.is_treated='C' AND c.is_treated='C') THEN 'WAC'
WHEN (w.is_treated='C' AND a.is_treated='C' AND c.is_treated!='C') THEN 'WA'
WHEN (w.is_treated='C' AND a.is_treated!='C' AND c.is_treated='C') THEN 'WC'
WHEN (w.is_treated!='C' AND a.is_treated='C' AND c.is_treated='C') THEN 'AC'
WHEN (w.is_treated='C' AND a.is_treated!='C' AND c.is_treated!='C') THEN 'W'
WHEN (w.is_treated!='C' AND a.is_treated='C' AND c.is_treated!='C') THEN 'A'
WHEN (w.is_treated!='C' AND a.is_treated!='C' AND c.is_treated='C') THEN 'C'
WHEN (w.is_treated!='C' AND a.is_treated!='C' AND c.is_treated!='C') THEN 'N'
ELSE null
END is_treated
FROM on_warfarin w 
INNER JOIN on_aspirin a ON w.anonpatid = a.anonpatid AND w.date_id=a.date_id
INNER JOIN on_clopidogrel c ON w.anonpatid = c.anonpatid AND w.date_id=c.date_id;

CREATE OR REPLACE VIEW on_warfarin_aspirin_clopidogrel_intermittent AS 
SELECT w.anonpatid, w.date_id, w.is_treated on_warfarin, a.is_treated on_aspirin, c.is_treated on_clopidogrel,
CASE 
WHEN ((w.is_treated='C' OR w.is_treated='I') AND (a.is_treated='C' OR a.is_treated='I') AND (c.is_treated='C' OR c.is_treated='I')) THEN 'WAC'
WHEN ((w.is_treated='C' OR w.is_treated='I') AND (a.is_treated='C' OR a.is_treated='I') AND (c.is_treated='N')) THEN 'WA'
WHEN ((w.is_treated='C' OR w.is_treated='I') AND (a.is_treated='N') AND (c.is_treated='C' OR c.is_treated='I')) THEN 'WC'
WHEN ((w.is_treated='N') AND (a.is_treated='C' OR a.is_treated='I') AND (c.is_treated='C' OR c.is_treated='I')) THEN 'AC'
WHEN ((w.is_treated='C' OR w.is_treated='I') AND (a.is_treated='N') AND (c.is_treated='N')) THEN 'W'
WHEN ((w.is_treated='N') AND (a.is_treated='C' OR a.is_treated='I') AND (c.is_treated='N')) THEN 'A'
WHEN ((w.is_treated='N') AND (a.is_treated='N') AND (c.is_treated='C' OR c.is_treated='I')) THEN 'C'
WHEN (w.is_treated='N' AND a.is_treated='N' AND c.is_treated='N') THEN 'N'
ELSE null
END is_treated
FROM on_warfarin w 
INNER JOIN on_aspirin a ON w.anonpatid = a.anonpatid AND w.date_id=a.date_id
INNER JOIN on_clopidogrel c ON w.anonpatid = c.anonpatid AND w.date_id=c.date_id;