--------------------------------
--- CALCULATE COSTS FUNCTION ---
--------------------------------

CREATE OR REPLACE FUNCTION calculate_patient_cost(patid int, start_date date, end_date date) RETURNS RECORD AS $$
DECLARE
	select_statement TEXT;
	hospital_fce float;
	hospital_spell float;
	consult float; 
	therapy float; 
	test_cat float; 
	test float; 
	total float;
	costs RECORD;
BEGIN
	select_statement = 'SELECT SUM(fce_cost)+SUM(unbundled_cost) FROM hes_episode_cost WHERE anonpatid = '|| patid || ' AND epistart >= ' || quote_literal(start_date) || ' AND epistart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_fce;
	IF hospital_fce IS NULL THEN hospital_fce = 0; END IF;

	select_statement = 'SELECT SUM(spell_cost) FROM hes_spell_cost WHERE anonpatid = '|| patid || ' AND spstart >= ' || quote_literal(start_date) || ' AND spstart <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO hospital_spell;
	IF hospital_spell IS NULL THEN hospital_spell = 0; END IF;

	select_statement = 'SELECT SUM(cost) FROM consultation_cost WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO consult;
	IF consult IS NULL THEN consult = 0; END IF;

	select_statement = 'SELECT SUM(cost) FROM therapy_cost WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO therapy;
	IF therapy IS NULL THEN therapy = 0; END IF;

	select_statement = 'SELECT SUM(cost) FROM test_cost_cat WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO test_cat;
	IF test_cat IS NULL THEN test_cat = 0; END IF;
	
	select_statement = 'SELECT SUM(cost) FROM test_cost WHERE anonpatid = '|| patid || ' AND eventdate >= ' || quote_literal(start_date) || ' AND eventdate <= ' || quote_literal(end_date);
	EXECUTE select_statement INTO test;
	IF test IS NULL THEN test = 0; END IF;
	
	total = hospital_fce + consult + therapy + test;
	costs = (patid, start_date, end_date, hospital_fce, hospital_spell, consult, therapy, test_cat, test);
	
	RETURN costs; 
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION calculate_period_cost(num_days_since_cohort_entry INT) RETURNS int AS $$
DECLARE 
	patients CURSOR FOR SELECT anonpatid, dxscad_date FROM SCAD_cohort ORDER BY anonpatid;
	create_statement TEXT;
	drop_statement TEXT;
	insert_statement TEXT;
	numrows INT;
	count INT;
BEGIN
	count = 0;
	numrows = 0;
	drop_statement = 'DROP TABLE IF EXISTS cohort_'|| num_days_since_cohort_entry ||'_days_cost CASCADE';
	EXECUTE drop_statement;
	create_statement = 
	'CREATE TABLE cohort_'|| num_days_since_cohort_entry ||'_days_cost(
	anonpatid int PRIMARY KEY,
	start_date date,
	end_date date,
	hospital_fce float,
	hospital_spell float,
	consult float,
	therapy float,
	test_cat float,
	test float
	)';
	EXECUTE create_statement;
		
	FOR patient IN patients	LOOP
		IF count % 100 = 0 THEN
			RAISE INFO 'Calculating costs for patient with ID: %, % patients processed', patient.anonpatid, count;
		END IF;
		count = count + 1;
		insert_statement = 'INSERT INTO cohort_'|| num_days_since_cohort_entry ||'_days_cost 
		SELECT patid, start_date, end_date, hospital_fce, hospital_spell, consultation, therapy, test_cat, test FROM calculate_patient_cost(' ||patient.anonpatid ||','|| quote_literal(patient.dxscad_date) ||','|| quote_literal(patient.dxscad_date+num_days_since_cohort_entry)||') AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float)';
		--RAISE INFO '%', insert_statement;
		EXECUTE insert_statement;
		numrows = numrows+1;
	END LOOP;
	
	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;




