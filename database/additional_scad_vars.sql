-- Define a SP cohort as those who are part of the scad cohort have an MI and then are stable for 60 days
DROP TABLE IF EXISTS scad_sp_cohort;
CREATE TABLE scad_sp_cohort(
anonpatid int PRIMARY KEY,
dxsp_date date,
dxsp_type text
)
INSERT INTO scad_sp_cohort
SELECT a.anonpatid, a.eventdate, a.event FROM 
che_mi_composite_30days a INNER JOIN
(SELECT mi.anonpatid, min(mi.eventdate) AS eventdate FROM 
che_mi_composite_30days mi 
INNER JOIN scad_cohort s 
ON mi.anonpatid = s.anonpatid AND mi.eventdate >= s.dxscad_date AND s.date_exit - mi.eventdate >= 60 AND mi.stable_post_mi = TRUE
GROUP BY mi.anonpatid) b
ON a.anonpatid = b.anonpatid AND a.eventdate = b.eventdate;
DELETE FROM scad_sp_cohort WHERE anonpatid IN (
SELECT sp.anonpatid FROM scad_sp_cohort sp INNER JOIN ONS o 
ON sp.anonpatid = o.anonpatid AND o.dod - sp.dxsp_date < 60
)
CREATE INDEX scad_sp_cohort_patid ON scad_sp_cohort(anonpatid);
CREATE INDEX scad_sp_cohort_spdate ON scad_sp_cohort(dxsp_date);
CREATE INDEX scad_sp_cohort_sptype ON scad_sp_cohort(dxsp_type);

-- Defines outcomes for the SP cohort
DROP TABLE IF EXISTS scad_sp_cohort_outcomes;
CREATE TABLE scad_sp_cohort_outcomes(
anonpatid int PRIMARY KEY,
prev_mi_count int,
prev_stemi_count int,
prev_nstemi_count int,
prev_stroke_count int,
prev_usa_count int,
prev_severe_bleed_count int,
prev_hf boolean,
mi_count int,
stemi_count int,
nstemi_count int,
stroke_count int,
usa_count int,
severe_bleed_count int,
hf boolean,
hypertension boolean DEFAULT FALSE,
chads_score int,
chadsvas_score int,
stroke_death boolean,
chd_death boolean,
first_mi_date date,
second_mi_date date,
first_stemi_date date,
second_stemi_date date,
first_nstemi_date date,
second_nstemi_date date,
first_stroke_date date,
second_stroke_date date,
first_usa_date date,
second_usa_date date,
first_severe_bleed_date date,
second_severe_bleed_date date,
cohort_exit_date date,
cohort_exit_type text
);

-------------------------------------------------------------
---- Add outcome counts and dates for SCAD SP cohort ----
-------------------------------------------------------------
DROP FUNCTION IF EXISTS calculate_scad_sp_cohort_outcomes(censor_date date);
CREATE OR REPLACE FUNCTION calculate_scad_sp_cohort_outcomes(censor_date date) RETURNS void AS $$
DECLARE 
	patients CURSOR FOR SELECT DISTINCT(s.anonpatid), s.dxscad_date, s.censor_date, o.deathdate, p.tod, sp.dxsp_date 
	FROM SCAD_cohort s 
	INNER JOIN patient p ON s.anonpatid = p.anonpatid 
	INNER JOIN scad_sp_cohort sp ON s.anonpatid=sp.anonpatid
	LEFT OUTER JOIN (SELECT anonpatid, MAX(dod) AS deathdate FROM ons GROUP BY anonpatid) o ON s.anonpatid = o.anonpatid
	ORDER BY s.anonpatid;
	num_mi int;
	num_stemi int;
	num_nstemi int;
	num_stroke int;
	num_usa int;
	num_hf int;
	stroke_death boolean;
	chd_death boolean;
	num_severe_bleeds int;
	num_prev_mi int;
	num_prev_stemi int;
	num_prev_nstemi int;
	num_prev_stroke int;
	num_prev_usa int;
	num_prev_hf int;
	num_prev_severe_bleeds int;
	death_count int;
	l_chads_score int;
	l_chadsvas_score int;
	age int;
	histof_hf boolean;
	histof_mi boolean;
	histof_pad boolean;
	histof_stroke boolean;
	diabetic boolean;
	sex boolean;
	count int;
	date_first_mi date;
	date_second_mi date;
	date_first_stemi date;
	date_second_stemi date;
	date_first_nstemi date;
	date_second_nstemi date;
	date_first_stroke date;
	date_second_stroke date;
	date_first_usa date;
	date_second_usa date;
	date_first_severe_bleed date;
	date_second_severe_bleed date;	
	date_exit date;
	type_exit text;
BEGIN

	TRUNCATE TABLE scad_sp_cohort_outcomes;

	CREATE TEMPORARY TABLE event_frequency ON COMMIT DROP AS 
	SELECT e.anonpatid, e.event, count(e.event) freq 
	FROM che_cvd_composite_30days e 
	INNER JOIN scad_sp_cohort c ON e.anonpatid = c.anonpatid 
	WHERE e.eventdate > c.dxsp_date 
	GROUP BY e.anonpatid, e.event ORDER BY e.anonpatid;
	CREATE INDEX event_frequency_patid_in ON event_frequency(anonpatid);
	
	INSERT INTO event_frequency SELECT e.anonpatid, 'severe_bleed', count(e.anonpatid) 
	FROM che_severe_bleed_30days e 
	INNER JOIN scad_sp_cohort c ON e.anonpatid = c.anonpatid 
	WHERE e.eventdate > c.dxsp_date
	GROUP BY e.anonpatid ORDER BY e.anonpatid;

	CREATE TEMPORARY TABLE prev_event_frequency ON COMMIT DROP AS 
	SELECT e.anonpatid, e.event, count(e.event) freq 
	FROM che_cvd_composite_30days e 
	INNER JOIN scad_sp_cohort c ON e.anonpatid = c.anonpatid 
	WHERE e.eventdate <= c.dxsp_date 
	GROUP BY e.anonpatid, e.event ORDER BY e.anonpatid;
	CREATE INDEX prev_event_frequency_patid_in ON prev_event_frequency(anonpatid);
	
	INSERT INTO prev_event_frequency SELECT e.anonpatid, 'severe_bleed', count(e.anonpatid) 
	FROM che_severe_bleed_30days e 
	INNER JOIN scad_sp_cohort c ON e.anonpatid = c.anonpatid 
	WHERE e.eventdate <= c.dxsp_date
	GROUP BY e.anonpatid ORDER BY e.anonpatid;

	count=0;
	-- for each patient update the counts
	FOR patient IN patients	LOOP
		IF count % 100 = 0 THEN
			RAISE INFO 'Calculating outcome vars for patient with ID: %, % patients processed', patient.anonpatid, count;
		END IF;
		count = count + 1;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'stemi' INTO num_stemi; 
		IF(num_stemi IS NULL) THEN
			num_stemi = 0;
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'nstemi' INTO num_nstemi; 
		IF(num_nstemi IS NULL) THEN
			num_nstemi = 0;
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'mi' INTO num_mi; 
		IF(num_mi IS NULL) THEN
			num_mi = 0;
		END IF;
		num_mi = num_mi + num_stemi + num_nstemi;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'stroke' INTO num_stroke; 
		IF(num_stroke IS NULL) THEN
			num_stroke = 0;
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'hf' INTO num_hf; 
		IF(num_hf IS NULL) THEN
			num_hf = 0;
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'usa' INTO num_usa; 
		IF(num_usa IS NULL) THEN
			num_usa = 0;
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'stroke_death' INTO death_count; 
		IF(death_count IS NULL) THEN
			stroke_death = FALSE;
		ELSE
			stroke_death = TRUE;
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'chd_death' INTO death_count; 
		IF(death_count IS NULL) THEN
			chd_death = FALSE;
		ELSE
			chd_death = TRUE;			
		END IF;
		SELECT freq FROM event_frequency WHERE anonpatid = patient.anonpatid AND event = 'severe_bleed' INTO num_severe_bleeds; 
		IF(num_severe_bleeds IS NULL) THEN
			num_severe_bleeds = 0;
		END IF;
		-- count events prior to cohort entry
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'stemi' INTO num_prev_stemi; 
		IF(num_prev_stemi IS NULL) THEN
			num_prev_stemi = 0;
		END IF;
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'nstemi' INTO num_prev_nstemi; 
		IF(num_prev_nstemi IS NULL) THEN
			num_prev_nstemi = 0;
		END IF;
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'mi' INTO num_prev_mi; 
		IF(num_prev_mi IS NULL) THEN
			num_prev_mi = 0;
		END IF;
		num_prev_mi = num_prev_mi + num_prev_stemi + num_prev_nstemi;
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'stroke' INTO num_prev_stroke; 
		IF(num_prev_stroke IS NULL) THEN
			num_prev_stroke = 0;
		END IF;
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'hf' INTO num_prev_hf; 
		IF(num_prev_hf IS NULL) THEN
			num_prev_hf = 0;
		END IF;
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'usa' INTO num_prev_usa; 
		IF(num_prev_usa IS NULL) THEN
			num_prev_usa = 0;
		END IF;
		SELECT freq FROM prev_event_frequency WHERE anonpatid = patient.anonpatid AND event = 'severe_bleed' INTO num_prev_severe_bleeds; 
		IF(num_prev_severe_bleeds IS NULL) THEN
			num_prev_severe_bleeds = 0;
		END IF;

		-- calculate chads score and chadsvas
		SELECT s.age, s.sex, s.diabetic, s.histof_hf, s.histof_mi, s.histof_pad, s.histof_stroke FROM scad_cohort s WHERE anonpatid = patient.anonpatid INTO age, sex, diabetic, histof_hf, histof_mi, histof_pad, histof_stroke;
		l_chads_score = 0;
		l_chadsvas_score = 0;
		IF(age >= 75) THEN
			l_chads_score = l_chads_score + 1;
			l_chadsvas_score = l_chadsvas_score + 2;
		END IF;
		IF(age >=65 AND age <= 74) THEN
			l_chadsvas_score = l_chadsvas_score + 1;
		END IF;
		IF(sex) THEN
			l_chadsvas_score = l_chadsvas_score + 1;
		END IF;
		IF(histof_hf) THEN
			l_chads_score = l_chads_score + 1;
			l_chadsvas_score = l_chadsvas_score + 1;		
		END IF;
		IF(diabetic) THEN
			l_chads_score = l_chads_score + 1;
			l_chadsvas_score = l_chadsvas_score + 1;		
		END IF;
		IF(histof_stroke) THEN
			l_chads_score = l_chads_score + 2;
			l_chadsvas_score = l_chadsvas_score + 2;		
		END IF;
		IF(histof_mi OR histof_pad) THEN
			l_chadsvas_score = l_chadsvas_score + 1;		
		END IF;


		-- get the first mi date
		SELECT eventdate FROM (SELECT * FROM che_mi_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date ORDER BY eventdate LIMIT 1) sub INTO date_first_mi;
		-- get the second mi date
		SELECT eventdate FROM (SELECT * FROM che_mi_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_mi;
		IF(date_first_mi >= date_second_mi) THEN
			date_second_mi = NULL;
		END IF;
		
		-- get the first stemi date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='stemi' ORDER BY eventdate LIMIT 1) sub INTO date_first_stemi;
		-- get the second stemi date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='stemi' ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_stemi;
		IF(date_first_stemi >= date_second_stemi) THEN
			date_second_stemi = NULL;
		END IF;

		-- get the first nstemi date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='nstemi' ORDER BY eventdate LIMIT 1) sub INTO date_first_nstemi;
		-- get the second nstemi date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='nstemi' ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_nstemi;
		IF(date_first_nstemi >= date_second_nstemi) THEN
			date_second_nstemi = NULL;
		END IF;

		-- get the first usa date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='usa' ORDER BY eventdate LIMIT 1) sub INTO date_first_usa;
		-- get the second usa date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='usa' ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_usa;
		IF(date_first_usa >= date_second_usa) THEN
			date_second_usa = NULL;
		END IF;
		
		-- get the first stroke date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='stroke' ORDER BY eventdate LIMIT 1) sub INTO date_first_stroke;
		-- get the second stroke date
		SELECT eventdate FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date AND event='stroke' ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_stroke;
		IF(date_first_stroke >= date_second_stroke) THEN
			date_second_stroke = NULL;
		END IF;

		-- get the first severe bleed date
		SELECT eventdate FROM (SELECT * FROM che_severe_bleed_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date ORDER BY eventdate LIMIT 1) sub INTO date_first_severe_bleed;
		-- get the second severe bleed date
		SELECT eventdate FROM (SELECT * FROM che_severe_bleed_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_severe_bleed;
		IF(date_first_severe_bleed >= date_second_severe_bleed) THEN
			date_second_severe_bleed = NULL;
		END IF;

		-- calculate the exit date 
		IF(patient.deathdate IS NULL AND patient.tod IS NULL) THEN
			date_exit = CASE WHEN censor_date < patient.censor_date THEN patient.censor_date ELSE censor_date END;
			type_exit = 'end_of_dataset';
		END IF;
		IF(patient.deathdate IS NULL AND patient.tod IS NOT NULL) THEN
			date_exit = CASE WHEN patient.tod < patient.censor_date THEN patient.censor_date ELSE patient.tod END;
			type_exit = 'transferred_out';
		END IF;
		IF(patient.deathdate IS NOT NULL AND patient.tod IS NULL) THEN
			date_exit = patient.deathdate;
			type_exit = 'dead';
		END IF;
		IF(patient.deathdate IS NOT NULL AND patient.tod IS NOT NULL) THEN
			IF(patient.deathdate <= patient.tod) THEN
				date_exit = patient.deathdate;
				type_exit = 'dead';
			ELSE
				date_exit = CASE WHEN patient.tod < patient.censor_date THEN patient.censor_date ELSE patient.tod END;
				type_exit = 'transferred_out';		
			END IF;
		END IF;

		INSERT INTO scad_sp_cohort_outcomes 
		(anonpatid,
		prev_mi_count,
		prev_stemi_count,
		prev_nstemi_count,
		prev_stroke_count,
		prev_usa_count,
		prev_severe_bleed_count,
		prev_hf,
		mi_count,
		stemi_count,
		nstemi_count,
		stroke_count,
		usa_count,
		severe_bleed_count,
		hf,
		chads_score,
		chadsvas_score,
		stroke_death,
		chd_death,
		first_mi_date,
		second_mi_date,
		first_stemi_date,
		second_stemi_date,
		first_nstemi_date,
		second_nstemi_date,
		first_stroke_date,
		second_stroke_date,
		first_usa_date,
		second_usa_date,
		first_severe_bleed_date,
		second_severe_bleed_date,
		cohort_exit_date,
		cohort_exit_type
		) 
		VALUES 
		(patient.anonpatid,
		 num_prev_mi,
		 num_prev_stemi,
 		 num_prev_nstemi,
 		 num_prev_stroke,
		 num_prev_usa,
		 num_prev_severe_bleeds,
		 num_prev_hf>0,
		 num_mi,
		 num_stemi,
		 num_nstemi,
		 num_stroke,
		 num_usa,
		 num_severe_bleeds,
		 num_hf>0,
		 l_chads_score,
		 l_chadsvas_score,
		 stroke_death,
		 chd_death,
		 date_first_mi,
		 date_second_mi,
		 date_first_stemi,
		 date_second_stemi,
		 date_first_nstemi,
		 date_second_nstemi,
		 date_first_stroke,
		 date_second_stroke,
		 date_first_usa,
		 date_second_usa,
		 date_first_severe_bleed,
		 date_second_severe_bleed,
		 date_exit,
		 type_exit);
	END LOOP;


	-- update hypertension falg and chads / chadsvas scores
	RAISE INFO 'SET HYPERTENSION FLAG AND UPDATE CHADS/CHADSVAS SCORES';
	UPDATE scad_sp_cohort_outcomes SET hypertension=TRUE, chads_score=chads_score+1, chadsvas_score=chadsvas_score+1 WHERE anonpatid IN
	(SELECT DISTINCT(s.anonpatid) FROM scad_sp_cohort s 
	INNER JOIN 
	(SELECT anonpatid, eventdate FROM cal_ht
	UNION
	SELECT anonpatid, date_admission AS eventdate FROM cal_ht_hes) ht
	ON s.anonpatid=ht.anonpatid
	WHERE ht.eventdate < s.dxsp_date);

END; $$
LANGUAGE PLPGSQL;

SELECT calculate_scad_sp_cohort_outcomes('2010-03-25');

---------------------------
--- costs for modelling ---
---------------------------

DROP TABLE IF EXISTS scad_sp_cohort_costs;
CREATE TABLE scad_sp_cohort_costs(
anonpatid int PRIMARY KEY,
cost_6months_hospital float,
cost_6months_drug float,
cost_6months_consult float,
cost_6months_test float,
cost_6months_total float,
cost_1year_hospital float,
cost_1year_drug float,
cost_1year_consult float,
cost_1year_test float,
cost_1year_total float,
bg_cost_to_first_event_hospital float,
bg_cost_to_first_event_drug float,
bg_cost_to_first_event_consult float,
bg_cost_to_first_event_test float,
bg_cost_to_first_event_total float,
cost_30days_post_first_event_hospital float,
cost_30days_post_first_event_drug float,
cost_30days_post_first_event_consult float,
cost_30days_post_first_event_test float,
cost_30days_post_first_event_total float,
cost_6months_post_first_event_hospital float,
cost_6months_post_first_event_drug float,
cost_6months_post_first_event_consult float,
cost_6months_post_first_event_test float,
cost_6months_post_first_event_total float,
cost_1year_post_first_event_hospital float,
cost_1year_post_first_event_drug float,
cost_1year_post_first_event_consult float,
cost_1year_post_first_event_test float,
cost_1year_post_first_event_total float,
bg_cost_to_second_event_hospital float,
bg_cost_to_second_event_drug float,
bg_cost_to_second_event_consult float,
bg_cost_to_second_event_test float,
bg_cost_to_second_event_total float,
cost_30days_post_second_event_hospital float,
cost_30days_post_second_event_drug float,
cost_30days_post_second_event_consult float,
cost_30days_post_second_event_test float,
cost_30days_post_second_event_total float,
cost_6months_post_second_event_hospital float,
cost_6months_post_second_event_drug float,
cost_6months_post_second_event_consult float,
cost_6months_post_second_event_test float,
cost_6months_post_second_event_total float,
cost_1year_post_second_event_hospital float,
cost_1year_post_second_event_drug float,
cost_1year_post_second_event_consult float,
cost_1year_post_second_event_test float,
cost_1year_post_second_event_total float,
cost_30days_post_first_stroke_hospital float,
cost_30days_post_first_stroke_drug float,
cost_30days_post_first_stroke_consult float,
cost_30days_post_first_stroke_test float,
cost_30days_post_first_stroke_total float,
cost_6months_post_first_stroke_hospital float,
cost_6months_post_first_stroke_drug float,
cost_6months_post_first_stroke_consult float,
cost_6months_post_first_stroke_test float,
cost_6months_post_first_stroke_total float,
cost_1year_post_first_stroke_hospital float,
cost_1year_post_first_stroke_drug float,
cost_1year_post_first_stroke_consult float,
cost_1year_post_first_stroke_test float,
cost_1year_post_first_stroke_total float,
cost_30days_post_second_stroke_hospital float,
cost_30days_post_second_stroke_drug float,
cost_30days_post_second_stroke_consult float,
cost_30days_post_second_stroke_test float,
cost_30days_post_second_stroke_total float,
cost_6months_post_second_stroke_hospital float,
cost_6months_post_second_stroke_drug float,
cost_6months_post_second_stroke_consult float,
cost_6months_post_second_stroke_test float,
cost_6months_post_second_stroke_total float,
cost_1year_post_second_stroke_hospital float,
cost_1year_post_second_stroke_drug float,
cost_1year_post_second_stroke_consult float,
cost_1year_post_second_stroke_test float,
cost_1year_post_second_stroke_total float,
cost_30days_post_first_mi_hospital float,
cost_30days_post_first_mi_drug float,
cost_30days_post_first_mi_consult float,
cost_30days_post_first_mi_test float,
cost_30days_post_first_mi_total float,
cost_6months_post_first_mi_hospital float,
cost_6months_post_first_mi_drug float,
cost_6months_post_first_mi_consult float,
cost_6months_post_first_mi_test float,
cost_6months_post_first_mi_total float,
cost_1year_post_first_mi_hospital float,
cost_1year_post_first_mi_drug float,
cost_1year_post_first_mi_consult float,
cost_1year_post_first_mi_test float,
cost_1year_post_first_mi_total float,
cost_30days_post_second_mi_hospital float,
cost_30days_post_second_mi_drug float,
cost_30days_post_second_mi_consult float,
cost_30days_post_second_mi_test float,
cost_30days_post_second_mi_total float,
cost_6months_post_second_mi_hospital float,
cost_6months_post_second_mi_drug float,
cost_6months_post_second_mi_consult float,
cost_6months_post_second_mi_test float,
cost_6months_post_second_mi_total float,
cost_1year_post_second_mi_hospital float,
cost_1year_post_second_mi_drug float,
cost_1year_post_second_mi_consult float,
cost_1year_post_second_mi_test float,
cost_1year_post_second_mi_total float,
cost_30days_post_first_stemi_hospital float,
cost_30days_post_first_stemi_drug float,
cost_30days_post_first_stemi_consult float,
cost_30days_post_first_stemi_test float,
cost_30days_post_first_stemi_total float,
cost_6months_post_first_stemi_hospital float,
cost_6months_post_first_stemi_drug float,
cost_6months_post_first_stemi_consult float,
cost_6months_post_first_stemi_test float,
cost_6months_post_first_stemi_total float,
cost_1year_post_first_stemi_hospital float,
cost_1year_post_first_stemi_drug float,
cost_1year_post_first_stemi_consult float,
cost_1year_post_first_stemi_test float,
cost_1year_post_first_stemi_total float,
cost_30days_post_second_stemi_hospital float,
cost_30days_post_second_stemi_drug float,
cost_30days_post_second_stemi_consult float,
cost_30days_post_second_stemi_test float,
cost_30days_post_second_stemi_total float,
cost_6months_post_second_stemi_hospital float,
cost_6months_post_second_stemi_drug float,
cost_6months_post_second_stemi_consult float,
cost_6months_post_second_stemi_test float,
cost_6months_post_second_stemi_total float,
cost_1year_post_second_stemi_hospital float,
cost_1year_post_second_stemi_drug float,
cost_1year_post_second_stemi_consult float,
cost_1year_post_second_stemi_test float,
cost_1year_post_second_stemi_total float,
cost_30days_post_first_nstemi_hospital float,
cost_30days_post_first_nstemi_drug float,
cost_30days_post_first_nstemi_consult float,
cost_30days_post_first_nstemi_test float,
cost_30days_post_first_nstemi_total float,
cost_6months_post_first_nstemi_hospital float,
cost_6months_post_first_nstemi_drug float,
cost_6months_post_first_nstemi_consult float,
cost_6months_post_first_nstemi_test float,
cost_6months_post_first_nstemi_total float,
cost_1year_post_first_nstemi_hospital float,
cost_1year_post_first_nstemi_drug float,
cost_1year_post_first_nstemi_consult float,
cost_1year_post_first_nstemi_test float,
cost_1year_post_first_nstemi_total float,
cost_30days_post_second_nstemi_hospital float,
cost_30days_post_second_nstemi_drug float,
cost_30days_post_second_nstemi_consult float,
cost_30days_post_second_nstemi_test float,
cost_30days_post_second_nstemi_total float,
cost_6months_post_second_nstemi_hospital float,
cost_6months_post_second_nstemi_drug float,
cost_6months_post_second_nstemi_consult float,
cost_6months_post_second_nstemi_test float,
cost_6months_post_second_nstemi_total float,
cost_1year_post_second_nstemi_hospital float,
cost_1year_post_second_nstemi_drug float,
cost_1year_post_second_nstemi_consult float,
cost_1year_post_second_nstemi_test float,
cost_1year_post_second_nstemi_total float,
cost_30days_post_first_usa_hospital float,
cost_30days_post_first_usa_drug float,
cost_30days_post_first_usa_consult float,
cost_30days_post_first_usa_test float,
cost_30days_post_first_usa_total float,
cost_6months_post_first_usa_hospital float,
cost_6months_post_first_usa_drug float,
cost_6months_post_first_usa_consult float,
cost_6months_post_first_usa_test float,
cost_6months_post_first_usa_total float,
cost_1year_post_first_usa_hospital float,
cost_1year_post_first_usa_drug float,
cost_1year_post_first_usa_consult float,
cost_1year_post_first_usa_test float,
cost_1year_post_first_usa_total float,
cost_30days_post_second_usa_hospital float,
cost_30days_post_second_usa_drug float,
cost_30days_post_second_usa_consult float,
cost_30days_post_second_usa_test float,
cost_30days_post_second_usa_total float,
cost_6months_post_second_usa_hospital float,
cost_6months_post_second_usa_drug float,
cost_6months_post_second_usa_consult float,
cost_6months_post_second_usa_test float,
cost_6months_post_second_usa_total float,
cost_1year_post_second_usa_hospital float,
cost_1year_post_second_usa_drug float,
cost_1year_post_second_usa_consult float,
cost_1year_post_second_usa_test float,
cost_1year_post_second_usa_total float,
cost_30days_post_first_severe_bleed_hospital float,
cost_30days_post_first_severe_bleed_drug float,
cost_30days_post_first_severe_bleed_consult float,
cost_30days_post_first_severe_bleed_test float,
cost_30days_post_first_severe_bleed_total float,
cost_6months_post_first_severe_bleed_hospital float,
cost_6months_post_first_severe_bleed_drug float,
cost_6months_post_first_severe_bleed_consult float,
cost_6months_post_first_severe_bleed_test float,
cost_6months_post_first_severe_bleed_total float,
cost_1year_post_first_severe_bleed_hospital float,
cost_1year_post_first_severe_bleed_drug float,
cost_1year_post_first_severe_bleed_consult float,
cost_1year_post_first_severe_bleed_test float,
cost_1year_post_first_severe_bleed_total float,
cost_30days_post_second_severe_bleed_hospital float,
cost_30days_post_second_severe_bleed_drug float,
cost_30days_post_second_severe_bleed_consult float,
cost_30days_post_second_severe_bleed_test float,
cost_30days_post_second_severe_bleed_total float,
cost_6months_post_second_severe_bleed_hospital float,
cost_6months_post_second_severe_bleed_drug float,
cost_6months_post_second_severe_bleed_consult float,
cost_6months_post_second_severe_bleed_test float,
cost_6months_post_second_severe_bleed_total float,
cost_1year_post_second_severe_bleed_hospital float,
cost_1year_post_second_severe_bleed_drug float,
cost_1year_post_second_severe_bleed_consult float,
cost_1year_post_second_severe_bleed_test float,
cost_1year_post_second_severe_bleed_total float,
cost_to_exit_hospital float,
cost_to_exit_drug float,
cost_to_exit_consult float,
cost_to_exit_test float,
cost_to_exit_total float,
cost_30days_prior_to_exit_hospital float,
cost_30days_prior_to_exit_drug float,
cost_30days_prior_to_exit_consult float,
cost_30days_prior_to_exit_test float,
cost_30days_prior_to_exit_total float
);
DROP FUNCTION IF EXISTS calculate_scad_sp_cohort_costs();
CREATE OR REPLACE FUNCTION calculate_scad_sp_cohort_costs() RETURNS int AS $$
DECLARE 
	patients CURSOR FOR SELECT DISTINCT(anonpatid), dxsp_date FROM scad_sp_cohort ORDER BY anonpatid;
	select_statement TEXT;
	insert_statement TEXT;
	numrows INT;
	count INT;
	costs_6months RECORD;
	costs_1year RECORD;
	costs_bg_to_first_event RECORD;
	costs_30days_post_first_event RECORD;
	costs_6months_post_first_event RECORD;
	costs_1year_post_first_event RECORD;
	costs_bg_to_second_event RECORD;
	costs_30days_post_second_event RECORD;
	costs_6months_post_second_event RECORD;
	costs_1year_post_second_event RECORD;
	costs_to_exit RECORD;
	costs_30days_prior_to_exit RECORD;
	costs_30days_post_first_mi RECORD;
	costs_6months_post_first_mi RECORD;
	costs_1year_post_first_mi RECORD;
	costs_30days_post_second_mi RECORD;
	costs_6months_post_second_mi RECORD;
	costs_1year_post_second_mi RECORD;
	costs_30days_post_first_stemi RECORD;
	costs_6months_post_first_stemi RECORD;
	costs_1year_post_first_stemi RECORD;
	costs_30days_post_second_stemi RECORD;
	costs_6months_post_second_stemi RECORD;
	costs_1year_post_second_stemi RECORD;
	costs_30days_post_first_nstemi RECORD;
	costs_6months_post_first_nstemi RECORD;
	costs_1year_post_first_nstemi RECORD;
	costs_30days_post_second_nstemi RECORD;
	costs_6months_post_second_nstemi RECORD;
	costs_1year_post_second_nstemi RECORD;
	costs_30days_post_first_stroke RECORD;
	costs_6months_post_first_stroke RECORD;
	costs_1year_post_first_stroke RECORD;
	costs_30days_post_second_stroke RECORD;
	costs_6months_post_second_stroke RECORD;
	costs_1year_post_second_stroke RECORD;
	costs_30days_post_first_usa RECORD;
	costs_6months_post_first_usa RECORD;
	costs_1year_post_first_usa RECORD;
	costs_30days_post_second_usa RECORD;
	costs_6months_post_second_usa RECORD;
	costs_1year_post_second_usa RECORD;
	costs_30days_post_first_severe_bleed RECORD;
	costs_6months_post_first_severe_bleed RECORD;
	costs_1year_post_first_severe_bleed RECORD;
	costs_30days_post_second_severe_bleed RECORD;
	costs_6months_post_second_severe_bleed RECORD;
	costs_1year_post_second_severe_bleed RECORD;
	date_first_event date;
	type_first_event text;
	date_second_event date;
	type_second_event text;
	date_first_mi date;
	date_second_mi date;
	date_first_stemi date;
	date_second_stemi date;
	date_first_nstemi date;
	date_second_nstemi date;
	date_first_stroke date;
	date_second_stroke date;
	date_first_usa date;
	date_second_usa date;
	date_first_severe_bleed date;
	date_second_severe_bleed date;
	date_exit date;
	type_exit text;
BEGIN
	count = 0;
	numrows = 0;

	-- clear out results table
	TRUNCATE TABLE scad_sp_cohort_costs;
		
	FOR patient IN patients	LOOP
		IF numrows % 100 = 0 THEN
			RAISE INFO 'Calculating costs for patient with ID: %, % patients processed', patient.anonpatid, numrows;
		END IF;

		SELECT first_mi_date,
		second_mi_date,
		first_stemi_date,
		second_stemi_date,
		first_nstemi_date,
		second_nstemi_date,
		first_stroke_date,
		second_stroke_date,
		first_usa_date,
		second_usa_date,
		first_severe_bleed_date,
		second_severe_bleed_date,
		cohort_exit_date 
		FROM scad_sp_cohort_outcomes
		WHERE anonpatid = patient.anonpatid
		INTO 
		date_first_mi, 
		date_second_mi, 
		date_first_stemi, 
		date_second_stemi, 
		date_first_nstemi, 
		date_second_nstemi, 
		date_first_stroke,
		date_second_stroke,
		date_first_usa,
		date_second_usa,
		date_first_severe_bleed,
		date_second_severe_bleed,
		date_exit;

		-- get the first event date
		SELECT eventdate, event FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date ORDER BY eventdate LIMIT 1) sub INTO date_first_event, type_first_event;
		-- get the second event date
		SELECT eventdate, event FROM (SELECT * FROM che_cvd_composite_30days WHERE anonpatid = patient.anonpatid AND eventdate > patient.dxsp_date ORDER BY eventdate LIMIT 2) sub  ORDER BY eventdate DESC LIMIT 1 INTO date_second_event, type_second_event;
		IF(date_first_event >= date_second_event) THEN
			date_second_event = NULL;
		END IF;

		-- 6 months costs
		SELECT * FROM calculate_patient_cost(patient.anonpatid,patient.dxsp_date,patient.dxsp_date+183) 
		AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
		INTO costs_6months;
		-- 1 year costs
		SELECT * FROM calculate_patient_cost(patient.anonpatid,patient.dxsp_date,patient.dxsp_date+365) 
		AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
		INTO costs_1year;

		IF(date_first_event IS NOT NULL) THEN
			IF(patient.dxsp_date + 365 < date_first_event) THEN
				-- bg to first event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,patient.dxsp_date+365,date_first_event) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_bg_to_first_event;
			END IF;
			-- if event is non-fatal
			IF(type_first_event != 'stroke_death' AND type_first_event != 'chd_death') THEN
				-- 30 days post first event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_event,date_first_event+30) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_30days_post_first_event;
				-- 6 months post first event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_event,date_first_event+183) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_6months_post_first_event;
				-- 1 year post first event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_event,date_first_event+365) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_1year_post_first_event;
			END IF;
		END IF;
		
		IF(date_second_event IS NOT NULL) THEN
			IF(date_first_event + 365 < date_second_event) THEN
				-- bg to second event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_event+365,date_second_event) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_bg_to_second_event;
			END IF;
			-- if event is non-fatal
			IF(type_second_event != 'stroke_death' AND type_second_event != 'chd_death') THEN
				-- 30 days post second event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_event,date_second_event+30) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_30days_post_second_event;
				-- 6 months post second event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_event,date_second_event+183) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_6months_post_second_event;
				-- 1 year post second event
				SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_event,date_second_event+365) 
				AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
				INTO costs_1year_post_second_event;
			END IF;
		END IF;

		IF(date_first_mi IS NOT NULL) THEN
			-- 30 days post first mi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_mi,date_first_mi+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_first_mi;
			-- 6 months post first mi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_mi,date_first_mi+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_first_mi;
			-- 1 year post first mi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_mi,date_first_mi+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_first_mi;
		END IF;
		IF(date_second_mi IS NOT NULL) THEN
			-- 30 days post second mi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_mi,date_second_mi+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_second_mi;
			-- 6 months post second mi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_mi,date_second_mi+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_second_mi;
			-- 1 year post second mi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_mi,date_second_mi+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_second_mi;
		END IF;

		IF(date_first_stemi IS NOT NULL) THEN
			-- 30 days post first stemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_stemi,date_first_stemi+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_first_stemi;
			-- 6 months post first stemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_stemi,date_first_stemi+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_first_stemi;
			-- 1 year post first stemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_stemi,date_first_stemi+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_first_stemi;
		END IF;
		IF(date_second_stemi IS NOT NULL) THEN
			-- 30 days post second stemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_stemi,date_second_stemi+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_second_stemi;
			-- 6 months post second stemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_stemi,date_second_stemi+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_second_stemi;
			-- 1 year post second stemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_stemi,date_second_stemi+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_second_stemi;
		END IF;

		IF(date_first_nstemi IS NOT NULL) THEN
			-- 30 days post first nstemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_nstemi,date_first_nstemi+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_first_nstemi;
			-- 6 months post first nstemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_nstemi,date_first_nstemi+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_first_nstemi;
			-- 1 year post first nstemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_nstemi,date_first_nstemi+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_first_nstemi;
		END IF;
		IF(date_second_nstemi IS NOT NULL) THEN
			-- 30 days post second nstemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_nstemi,date_second_nstemi+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_second_nstemi;
			-- 6 months post second nstemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_nstemi,date_second_nstemi+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_second_nstemi;
			-- 1 year post second nstemi
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_nstemi,date_second_nstemi+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_second_nstemi;
		END IF;
		
		IF(date_first_severe_bleed IS NOT NULL) THEN
			-- 30 days post first sb
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_severe_bleed,date_first_severe_bleed+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_first_severe_bleed;
			-- 6 months post first sb
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_severe_bleed,date_first_severe_bleed+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_first_severe_bleed;
			-- 1 year post first sb
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_severe_bleed,date_first_severe_bleed+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_first_severe_bleed;
		END IF;
		IF(date_second_severe_bleed IS NOT NULL) THEN
			-- 30 days post second sb
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_severe_bleed,date_second_severe_bleed+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_second_severe_bleed;
			-- 6 months post second sb
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_severe_bleed,date_second_severe_bleed+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_second_severe_bleed;
			-- 1 year post second sb
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_severe_bleed,date_second_severe_bleed+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_second_severe_bleed;
		END IF;
		
		IF(date_first_stroke IS NOT NULL) THEN
			-- 30 days post first stroke
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_stroke,date_first_stroke+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_first_stroke;
			-- 6 months post first stroke
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_stroke,date_first_stroke+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_first_stroke;
			-- 1 year post first stroke
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_stroke,date_first_stroke+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_first_stroke;
		END IF;
		IF(date_second_stroke IS NOT NULL) THEN
			-- 30 days post second stroke
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_stroke,date_second_stroke+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_second_stroke;
			-- 6 months post second stroke
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_stroke,date_second_stroke+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_second_stroke;
			-- 1 year post second stroke
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_stroke,date_second_stroke+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_second_stroke;
		END IF;
		
		IF(date_first_usa IS NOT NULL) THEN
			-- 30 days post first usa
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_usa,date_first_usa+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_first_usa;
			-- 6 months post first usa
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_usa,date_first_usa+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_first_usa;
			-- 1 year post first usa
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_first_usa,date_first_usa+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_first_usa;
		END IF;
		IF(date_second_usa IS NOT NULL) THEN
			-- 30 days post second usa
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_usa,date_second_usa+30) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_post_second_usa;
			-- 6 months post second usa
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_usa,date_second_usa+183) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_6months_post_second_usa;
			-- 1 year post second usa
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_second_usa,date_second_usa+365) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_1year_post_second_usa;
		END IF;

		-- costs over full period
		SELECT * FROM calculate_patient_cost(patient.anonpatid,patient.dxsp_date,date_exit) 
		AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
		INTO costs_to_exit;

		IF(patient.dxsp_date < date_exit-30) THEN
			SELECT * FROM calculate_patient_cost(patient.anonpatid,date_exit-30,date_exit) 
			AS (patid int, start_date date, end_date date,hospital_fce float, hospital_spell float, consultation float, therapy float, test_cat float, test float) 
			INTO costs_30days_prior_to_exit;
		END IF;


		-- save this patient level cost information
		INSERT INTO scad_sp_cohort_costs 
		(anonpatid,
		cost_6months_hospital,cost_6months_drug,cost_6months_consult,cost_6months_test,cost_6months_total,
		cost_1year_hospital,cost_1year_drug,cost_1year_consult,cost_1year_test,cost_1year_total,
		cost_to_exit_hospital,cost_to_exit_drug,cost_to_exit_consult,cost_to_exit_test,cost_to_exit_total)
		VALUES
		(patient.anonpatid,
		costs_6months.hospital_fce,costs_6months.therapy,costs_6months.consultation,costs_6months.test,costs_6months.hospital_fce+costs_6months.therapy+costs_6months.consultation+costs_6months.test,
		costs_1year.hospital_fce,costs_1year.therapy,costs_1year.consultation,costs_1year.test,costs_1year.hospital_fce+costs_1year.therapy+costs_1year.consultation+costs_1year.test,
		costs_to_exit.hospital_fce,costs_to_exit.therapy,costs_to_exit.consultation,costs_to_exit.test,costs_to_exit.hospital_fce+costs_to_exit.therapy+costs_to_exit.consultation+costs_to_exit.test);
		
		IF(date_first_event IS NOT NULL) THEN
			IF(patient.dxsp_date + 365 < date_first_event) THEN
				UPDATE scad_sp_cohort_costs SET
				bg_cost_to_first_event_hospital = costs_bg_to_first_event.hospital_fce,
				bg_cost_to_first_event_drug = costs_bg_to_first_event.therapy,
				bg_cost_to_first_event_consult = costs_bg_to_first_event.consultation,
				bg_cost_to_first_event_test = costs_bg_to_first_event.test,
				bg_cost_to_first_event_total = costs_bg_to_first_event.hospital_fce+costs_bg_to_first_event.therapy+costs_bg_to_first_event.consultation+costs_bg_to_first_event.test
				WHERE anonpatid=patient.anonpatid;
			END IF;
			IF(type_first_event != 'stroke_death' AND type_first_event != 'chd_death') THEN
				UPDATE scad_sp_cohort_costs SET
				cost_30days_post_first_event_hospital = costs_30days_post_first_event.hospital_fce,
				cost_30days_post_first_event_drug = costs_30days_post_first_event.therapy,
				cost_30days_post_first_event_consult = costs_30days_post_first_event.consultation,
				cost_30days_post_first_event_test = costs_30days_post_first_event.test,
				cost_30days_post_first_event_total = costs_30days_post_first_event.hospital_fce+costs_30days_post_first_event.therapy+costs_30days_post_first_event.consultation+costs_30days_post_first_event.test,
				cost_6months_post_first_event_hospital = costs_6months_post_first_event.hospital_fce,
				cost_6months_post_first_event_drug = costs_6months_post_first_event.therapy,
				cost_6months_post_first_event_consult = costs_6months_post_first_event.consultation,
				cost_6months_post_first_event_test = costs_6months_post_first_event.test,
				cost_6months_post_first_event_total = costs_6months_post_first_event.hospital_fce+costs_6months_post_first_event.therapy+costs_6months_post_first_event.consultation+costs_6months_post_first_event.test,
				cost_1year_post_first_event_hospital = costs_1year_post_first_event.hospital_fce,
				cost_1year_post_first_event_drug = costs_1year_post_first_event.therapy,
				cost_1year_post_first_event_consult = costs_1year_post_first_event.consultation,
				cost_1year_post_first_event_test = costs_1year_post_first_event.test,
				cost_1year_post_first_event_total = costs_1year_post_first_event.hospital_fce+costs_1year_post_first_event.therapy+costs_1year_post_first_event.consultation+costs_1year_post_first_event.test
				WHERE anonpatid=patient.anonpatid;
			END IF;
		END IF;

		IF(date_second_event IS NOT NULL) THEN
			IF(date_first_event + 365 < date_second_event) THEN
				UPDATE scad_sp_cohort_costs SET
				bg_cost_to_second_event_hospital = costs_bg_to_second_event.hospital_fce,
				bg_cost_to_second_event_drug = costs_bg_to_second_event.therapy,
				bg_cost_to_second_event_consult = costs_bg_to_second_event.consultation,
				bg_cost_to_second_event_test = costs_bg_to_second_event.test,
				bg_cost_to_second_event_total = costs_bg_to_second_event.hospital_fce+costs_bg_to_second_event.therapy+costs_bg_to_second_event.consultation+costs_bg_to_second_event.test
				WHERE anonpatid=patient.anonpatid;
			END IF;
			IF(type_second_event != 'stroke_death' AND type_second_event != 'chd_death') THEN
				UPDATE scad_sp_cohort_costs SET
				cost_30days_post_second_event_hospital = costs_30days_post_second_event.hospital_fce,
				cost_30days_post_second_event_drug = costs_30days_post_second_event.therapy,
				cost_30days_post_second_event_consult = costs_30days_post_second_event.consultation,
				cost_30days_post_second_event_test = costs_30days_post_second_event.test,
				cost_30days_post_second_event_total = costs_30days_post_second_event.hospital_fce+costs_30days_post_second_event.therapy+costs_30days_post_second_event.consultation+costs_30days_post_second_event.test,
				cost_6months_post_second_event_hospital = costs_6months_post_second_event.hospital_fce,
				cost_6months_post_second_event_drug = costs_6months_post_second_event.therapy,
				cost_6months_post_second_event_consult = costs_6months_post_second_event.consultation,
				cost_6months_post_second_event_test = costs_6months_post_second_event.test,
				cost_6months_post_second_event_total = costs_6months_post_second_event.hospital_fce+costs_6months_post_second_event.therapy+costs_6months_post_second_event.consultation+costs_6months_post_second_event.test,
				cost_1year_post_second_event_hospital = costs_1year_post_second_event.hospital_fce,
				cost_1year_post_second_event_drug = costs_1year_post_second_event.therapy,
				cost_1year_post_second_event_consult = costs_1year_post_second_event.consultation,
				cost_1year_post_second_event_test = costs_1year_post_second_event.test,
				cost_1year_post_second_event_total = costs_1year_post_second_event.hospital_fce+costs_1year_post_second_event.therapy+costs_1year_post_second_event.consultation+costs_1year_post_second_event.test
				WHERE anonpatid=patient.anonpatid;
			END IF;
		END IF;
		IF(date_first_stroke IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_first_stroke_hospital = costs_30days_post_first_stroke.hospital_fce,
			cost_30days_post_first_stroke_drug = costs_30days_post_first_stroke.therapy,
			cost_30days_post_first_stroke_consult = costs_30days_post_first_stroke.consultation,
			cost_30days_post_first_stroke_test = costs_30days_post_first_stroke.test,
			cost_30days_post_first_stroke_total = costs_30days_post_first_stroke.hospital_fce+costs_30days_post_first_stroke.therapy+costs_30days_post_first_stroke.consultation+costs_30days_post_first_stroke.test,
			cost_6months_post_first_stroke_hospital = costs_6months_post_first_stroke.hospital_fce,
			cost_6months_post_first_stroke_drug = costs_6months_post_first_stroke.therapy,
			cost_6months_post_first_stroke_consult = costs_6months_post_first_stroke.consultation,
			cost_6months_post_first_stroke_test = costs_6months_post_first_stroke.test,
			cost_6months_post_first_stroke_total = costs_6months_post_first_stroke.hospital_fce+costs_6months_post_first_stroke.therapy+costs_6months_post_first_stroke.consultation+costs_6months_post_first_stroke.test,
			cost_1year_post_first_stroke_hospital = costs_1year_post_first_stroke.hospital_fce,
			cost_1year_post_first_stroke_drug = costs_1year_post_first_stroke.therapy,
			cost_1year_post_first_stroke_consult = costs_1year_post_first_stroke.consultation,
			cost_1year_post_first_stroke_test = costs_1year_post_first_stroke.test,
			cost_1year_post_first_stroke_total = costs_1year_post_first_stroke.hospital_fce+costs_1year_post_first_stroke.therapy+costs_1year_post_first_stroke.consultation+costs_1year_post_first_stroke.test
			WHERE anonpatid=patient.anonpatid;
		END IF;
		IF(date_second_stroke IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_second_stroke_hospital = costs_30days_post_second_stroke.hospital_fce,
			cost_30days_post_second_stroke_drug = costs_30days_post_second_stroke.therapy,
			cost_30days_post_second_stroke_consult = costs_30days_post_second_stroke.consultation,
			cost_30days_post_second_stroke_test = costs_30days_post_second_stroke.test,
			cost_30days_post_second_stroke_total = costs_30days_post_second_stroke.hospital_fce+costs_30days_post_second_stroke.therapy+costs_30days_post_second_stroke.consultation+costs_30days_post_second_stroke.test,
			cost_6months_post_second_stroke_hospital = costs_6months_post_second_stroke.hospital_fce,
			cost_6months_post_second_stroke_drug = costs_6months_post_second_stroke.therapy,
			cost_6months_post_second_stroke_consult = costs_6months_post_second_stroke.consultation,
			cost_6months_post_second_stroke_test = costs_6months_post_second_stroke.test,
			cost_6months_post_second_stroke_total = costs_6months_post_second_stroke.hospital_fce+costs_6months_post_second_stroke.therapy+costs_6months_post_second_stroke.consultation+costs_6months_post_second_stroke.test,
			cost_1year_post_second_stroke_hospital = costs_1year_post_second_stroke.hospital_fce,
			cost_1year_post_second_stroke_drug = costs_1year_post_second_stroke.therapy,
			cost_1year_post_second_stroke_consult = costs_1year_post_second_stroke.consultation,
			cost_1year_post_second_stroke_test = costs_1year_post_second_stroke.test,
			cost_1year_post_second_stroke_total = costs_1year_post_second_stroke.hospital_fce+costs_1year_post_second_stroke.therapy+costs_1year_post_second_stroke.consultation+costs_1year_post_second_stroke.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		IF(date_first_mi IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_first_mi_hospital = costs_30days_post_first_mi.hospital_fce,
			cost_30days_post_first_mi_drug = costs_30days_post_first_mi.therapy,
			cost_30days_post_first_mi_consult = costs_30days_post_first_mi.consultation,
			cost_30days_post_first_mi_test = costs_30days_post_first_mi.test,
			cost_30days_post_first_mi_total = costs_30days_post_first_mi.hospital_fce+costs_30days_post_first_mi.therapy+costs_30days_post_first_mi.consultation+costs_30days_post_first_mi.test,
			cost_6months_post_first_mi_hospital = costs_6months_post_first_mi.hospital_fce,
			cost_6months_post_first_mi_drug = costs_6months_post_first_mi.therapy,
			cost_6months_post_first_mi_consult = costs_6months_post_first_mi.consultation,
			cost_6months_post_first_mi_test = costs_6months_post_first_mi.test,
			cost_6months_post_first_mi_total = costs_6months_post_first_mi.hospital_fce+costs_6months_post_first_mi.therapy+costs_6months_post_first_mi.consultation+costs_6months_post_first_mi.test,
			cost_1year_post_first_mi_hospital = costs_1year_post_first_mi.hospital_fce,
			cost_1year_post_first_mi_drug = costs_1year_post_first_mi.therapy,
			cost_1year_post_first_mi_consult = costs_1year_post_first_mi.consultation,
			cost_1year_post_first_mi_test = costs_1year_post_first_mi.test,
			cost_1year_post_first_mi_total = costs_1year_post_first_mi.hospital_fce+costs_1year_post_first_mi.therapy+costs_1year_post_first_mi.consultation+costs_1year_post_first_mi.test
			WHERE anonpatid=patient.anonpatid;
		END IF;
		IF(date_second_mi IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_second_mi_hospital = costs_30days_post_second_mi.hospital_fce,
			cost_30days_post_second_mi_drug = costs_30days_post_second_mi.therapy,
			cost_30days_post_second_mi_consult = costs_30days_post_second_mi.consultation,
			cost_30days_post_second_mi_test = costs_30days_post_second_mi.test,
			cost_30days_post_second_mi_total = costs_30days_post_second_mi.hospital_fce+costs_30days_post_second_mi.therapy+costs_30days_post_second_mi.consultation+costs_30days_post_second_mi.test,
			cost_6months_post_second_mi_hospital = costs_6months_post_second_mi.hospital_fce,
			cost_6months_post_second_mi_drug = costs_6months_post_second_mi.therapy,
			cost_6months_post_second_mi_consult = costs_6months_post_second_mi.consultation,
			cost_6months_post_second_mi_test = costs_6months_post_second_mi.test,
			cost_6months_post_second_mi_total = costs_6months_post_second_mi.hospital_fce+costs_6months_post_second_mi.therapy+costs_6months_post_second_mi.consultation+costs_6months_post_second_mi.test,
			cost_1year_post_second_mi_hospital = costs_1year_post_second_mi.hospital_fce,
			cost_1year_post_second_mi_drug = costs_1year_post_second_mi.therapy,
			cost_1year_post_second_mi_consult = costs_1year_post_second_mi.consultation,
			cost_1year_post_second_mi_test = costs_1year_post_second_mi.test,
			cost_1year_post_second_mi_total = costs_1year_post_second_mi.hospital_fce+costs_1year_post_second_mi.therapy+costs_1year_post_second_mi.consultation+costs_1year_post_second_mi.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		IF(date_first_stemi IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_first_stemi_hospital = costs_30days_post_first_stemi.hospital_fce,
			cost_30days_post_first_stemi_drug = costs_30days_post_first_stemi.therapy,
			cost_30days_post_first_stemi_consult = costs_30days_post_first_stemi.consultation,
			cost_30days_post_first_stemi_test = costs_30days_post_first_stemi.test,
			cost_30days_post_first_stemi_total = costs_30days_post_first_stemi.hospital_fce+costs_30days_post_first_stemi.therapy+costs_30days_post_first_stemi.consultation+costs_30days_post_first_stemi.test,
			cost_6months_post_first_stemi_hospital = costs_6months_post_first_stemi.hospital_fce,
			cost_6months_post_first_stemi_drug = costs_6months_post_first_stemi.therapy,
			cost_6months_post_first_stemi_consult = costs_6months_post_first_stemi.consultation,
			cost_6months_post_first_stemi_test = costs_6months_post_first_stemi.test,
			cost_6months_post_first_stemi_total = costs_6months_post_first_stemi.hospital_fce+costs_6months_post_first_stemi.therapy+costs_6months_post_first_stemi.consultation+costs_6months_post_first_stemi.test,
			cost_1year_post_first_stemi_hospital = costs_1year_post_first_stemi.hospital_fce,
			cost_1year_post_first_stemi_drug = costs_1year_post_first_stemi.therapy,
			cost_1year_post_first_stemi_consult = costs_1year_post_first_stemi.consultation,
			cost_1year_post_first_stemi_test = costs_1year_post_first_stemi.test,
			cost_1year_post_first_stemi_total = costs_1year_post_first_stemi.hospital_fce+costs_1year_post_first_stemi.therapy+costs_1year_post_first_stemi.consultation+costs_1year_post_first_stemi.test
			WHERE anonpatid=patient.anonpatid;
		END IF;
		IF(date_second_stemi IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_second_stemi_hospital = costs_30days_post_second_stemi.hospital_fce,
			cost_30days_post_second_stemi_drug = costs_30days_post_second_stemi.therapy,
			cost_30days_post_second_stemi_consult = costs_30days_post_second_stemi.consultation,
			cost_30days_post_second_stemi_test = costs_30days_post_second_stemi.test,
			cost_30days_post_second_stemi_total = costs_30days_post_second_stemi.hospital_fce+costs_30days_post_second_stemi.therapy+costs_30days_post_second_stemi.consultation+costs_30days_post_second_stemi.test,
			cost_6months_post_second_stemi_hospital = costs_6months_post_second_stemi.hospital_fce,
			cost_6months_post_second_stemi_drug = costs_6months_post_second_stemi.therapy,
			cost_6months_post_second_stemi_consult = costs_6months_post_second_stemi.consultation,
			cost_6months_post_second_stemi_test = costs_6months_post_second_stemi.test,
			cost_6months_post_second_stemi_total = costs_6months_post_second_stemi.hospital_fce+costs_6months_post_second_stemi.therapy+costs_6months_post_second_stemi.consultation+costs_6months_post_second_stemi.test,
			cost_1year_post_second_stemi_hospital = costs_1year_post_second_stemi.hospital_fce,
			cost_1year_post_second_stemi_drug = costs_1year_post_second_stemi.therapy,
			cost_1year_post_second_stemi_consult = costs_1year_post_second_stemi.consultation,
			cost_1year_post_second_stemi_test = costs_1year_post_second_stemi.test,
			cost_1year_post_second_stemi_total = costs_1year_post_second_stemi.hospital_fce+costs_1year_post_second_stemi.therapy+costs_1year_post_second_stemi.consultation+costs_1year_post_second_stemi.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		IF(date_first_nstemi IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_first_nstemi_hospital = costs_30days_post_first_nstemi.hospital_fce,
			cost_30days_post_first_nstemi_drug = costs_30days_post_first_nstemi.therapy,
			cost_30days_post_first_nstemi_consult = costs_30days_post_first_nstemi.consultation,
			cost_30days_post_first_nstemi_test = costs_30days_post_first_nstemi.test,
			cost_30days_post_first_nstemi_total = costs_30days_post_first_nstemi.hospital_fce+costs_30days_post_first_nstemi.therapy+costs_30days_post_first_nstemi.consultation+costs_30days_post_first_nstemi.test,
			cost_6months_post_first_nstemi_hospital = costs_6months_post_first_nstemi.hospital_fce,
			cost_6months_post_first_nstemi_drug = costs_6months_post_first_nstemi.therapy,
			cost_6months_post_first_nstemi_consult = costs_6months_post_first_nstemi.consultation,
			cost_6months_post_first_nstemi_test = costs_6months_post_first_nstemi.test,
			cost_6months_post_first_nstemi_total = costs_6months_post_first_nstemi.hospital_fce+costs_6months_post_first_nstemi.therapy+costs_6months_post_first_nstemi.consultation+costs_6months_post_first_nstemi.test,
			cost_1year_post_first_nstemi_hospital = costs_1year_post_first_nstemi.hospital_fce,
			cost_1year_post_first_nstemi_drug = costs_1year_post_first_nstemi.therapy,
			cost_1year_post_first_nstemi_consult = costs_1year_post_first_nstemi.consultation,
			cost_1year_post_first_nstemi_test = costs_1year_post_first_nstemi.test,
			cost_1year_post_first_nstemi_total = costs_1year_post_first_nstemi.hospital_fce+costs_1year_post_first_nstemi.therapy+costs_1year_post_first_nstemi.consultation+costs_1year_post_first_nstemi.test
			WHERE anonpatid=patient.anonpatid;
		END IF;
		IF(date_second_nstemi IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_second_nstemi_hospital = costs_30days_post_second_nstemi.hospital_fce,
			cost_30days_post_second_nstemi_drug = costs_30days_post_second_nstemi.therapy,
			cost_30days_post_second_nstemi_consult = costs_30days_post_second_nstemi.consultation,
			cost_30days_post_second_nstemi_test = costs_30days_post_second_nstemi.test,
			cost_30days_post_second_nstemi_total = costs_30days_post_second_nstemi.hospital_fce+costs_30days_post_second_nstemi.therapy+costs_30days_post_second_nstemi.consultation+costs_30days_post_second_nstemi.test,
			cost_6months_post_second_nstemi_hospital = costs_6months_post_second_nstemi.hospital_fce,
			cost_6months_post_second_nstemi_drug = costs_6months_post_second_nstemi.therapy,
			cost_6months_post_second_nstemi_consult = costs_6months_post_second_nstemi.consultation,
			cost_6months_post_second_nstemi_test = costs_6months_post_second_nstemi.test,
			cost_6months_post_second_nstemi_total = costs_6months_post_second_nstemi.hospital_fce+costs_6months_post_second_nstemi.therapy+costs_6months_post_second_nstemi.consultation+costs_6months_post_second_nstemi.test,
			cost_1year_post_second_nstemi_hospital = costs_1year_post_second_nstemi.hospital_fce,
			cost_1year_post_second_nstemi_drug = costs_1year_post_second_nstemi.therapy,
			cost_1year_post_second_nstemi_consult = costs_1year_post_second_nstemi.consultation,
			cost_1year_post_second_nstemi_test = costs_1year_post_second_nstemi.test,
			cost_1year_post_second_nstemi_total = costs_1year_post_second_nstemi.hospital_fce+costs_1year_post_second_nstemi.therapy+costs_1year_post_second_nstemi.consultation+costs_1year_post_second_nstemi.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		IF(date_first_usa IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_first_usa_hospital = costs_30days_post_first_usa.hospital_fce,
			cost_30days_post_first_usa_drug = costs_30days_post_first_usa.therapy,
			cost_30days_post_first_usa_consult = costs_30days_post_first_usa.consultation,
			cost_30days_post_first_usa_test = costs_30days_post_first_usa.test,
			cost_30days_post_first_usa_total = costs_30days_post_first_usa.hospital_fce+costs_30days_post_first_usa.therapy+costs_30days_post_first_usa.consultation+costs_30days_post_first_usa.test,
			cost_6months_post_first_usa_hospital = costs_6months_post_first_usa.hospital_fce,
			cost_6months_post_first_usa_drug = costs_6months_post_first_usa.therapy,
			cost_6months_post_first_usa_consult = costs_6months_post_first_usa.consultation,
			cost_6months_post_first_usa_test = costs_6months_post_first_usa.test,
			cost_6months_post_first_usa_total = costs_6months_post_first_usa.hospital_fce+costs_6months_post_first_usa.therapy+costs_6months_post_first_usa.consultation+costs_6months_post_first_usa.test,
			cost_1year_post_first_usa_hospital = costs_1year_post_first_usa.hospital_fce,
			cost_1year_post_first_usa_drug = costs_1year_post_first_usa.therapy,
			cost_1year_post_first_usa_consult = costs_1year_post_first_usa.consultation,
			cost_1year_post_first_usa_test = costs_1year_post_first_usa.test,
			cost_1year_post_first_usa_total = costs_1year_post_first_usa.hospital_fce+costs_1year_post_first_usa.therapy+costs_1year_post_first_usa.consultation+costs_1year_post_first_usa.test
			WHERE anonpatid=patient.anonpatid;
		END IF;
		IF(date_second_usa IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_second_usa_hospital = costs_30days_post_second_usa.hospital_fce,
			cost_30days_post_second_usa_drug = costs_30days_post_second_usa.therapy,
			cost_30days_post_second_usa_consult = costs_30days_post_second_usa.consultation,
			cost_30days_post_second_usa_test = costs_30days_post_second_usa.test,
			cost_30days_post_second_usa_total = costs_30days_post_second_usa.hospital_fce+costs_30days_post_second_usa.therapy+costs_30days_post_second_usa.consultation+costs_30days_post_second_usa.test,
			cost_6months_post_second_usa_hospital = costs_6months_post_second_usa.hospital_fce,
			cost_6months_post_second_usa_drug = costs_6months_post_second_usa.therapy,
			cost_6months_post_second_usa_consult = costs_6months_post_second_usa.consultation,
			cost_6months_post_second_usa_test = costs_6months_post_second_usa.test,
			cost_6months_post_second_usa_total = costs_6months_post_second_usa.hospital_fce+costs_6months_post_second_usa.therapy+costs_6months_post_second_usa.consultation+costs_6months_post_second_usa.test,
			cost_1year_post_second_usa_hospital = costs_1year_post_second_usa.hospital_fce,
			cost_1year_post_second_usa_drug = costs_1year_post_second_usa.therapy,
			cost_1year_post_second_usa_consult = costs_1year_post_second_usa.consultation,
			cost_1year_post_second_usa_test = costs_1year_post_second_usa.test,
			cost_1year_post_second_usa_total = costs_1year_post_second_usa.hospital_fce+costs_1year_post_second_usa.therapy+costs_1year_post_second_usa.consultation+costs_1year_post_second_usa.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		IF(date_first_severe_bleed IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_first_severe_bleed_hospital = costs_30days_post_first_severe_bleed.hospital_fce,
			cost_30days_post_first_severe_bleed_drug = costs_30days_post_first_severe_bleed.therapy,
			cost_30days_post_first_severe_bleed_consult = costs_30days_post_first_severe_bleed.consultation,
			cost_30days_post_first_severe_bleed_test = costs_30days_post_first_severe_bleed.test,
			cost_30days_post_first_severe_bleed_total = costs_30days_post_first_severe_bleed.hospital_fce+costs_30days_post_first_severe_bleed.therapy+costs_30days_post_first_severe_bleed.consultation+costs_30days_post_first_severe_bleed.test,
			cost_6months_post_first_severe_bleed_hospital = costs_6months_post_first_severe_bleed.hospital_fce,
			cost_6months_post_first_severe_bleed_drug = costs_6months_post_first_severe_bleed.therapy,
			cost_6months_post_first_severe_bleed_consult = costs_6months_post_first_severe_bleed.consultation,
			cost_6months_post_first_severe_bleed_test = costs_6months_post_first_severe_bleed.test,
			cost_6months_post_first_severe_bleed_total = costs_6months_post_first_severe_bleed.hospital_fce+costs_6months_post_first_severe_bleed.therapy+costs_6months_post_first_severe_bleed.consultation+costs_6months_post_first_severe_bleed.test,
			cost_1year_post_first_severe_bleed_hospital = costs_1year_post_first_severe_bleed.hospital_fce,
			cost_1year_post_first_severe_bleed_drug = costs_1year_post_first_severe_bleed.therapy,
			cost_1year_post_first_severe_bleed_consult = costs_1year_post_first_severe_bleed.consultation,
			cost_1year_post_first_severe_bleed_test = costs_1year_post_first_severe_bleed.test,
			cost_1year_post_first_severe_bleed_total = costs_1year_post_first_severe_bleed.hospital_fce+costs_1year_post_first_severe_bleed.therapy+costs_1year_post_first_severe_bleed.consultation+costs_1year_post_first_severe_bleed.test
			WHERE anonpatid=patient.anonpatid;
		END IF;
		IF(date_second_severe_bleed IS NOT NULL) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_post_second_severe_bleed_hospital = costs_30days_post_second_severe_bleed.hospital_fce,
			cost_30days_post_second_severe_bleed_drug = costs_30days_post_second_severe_bleed.therapy,
			cost_30days_post_second_severe_bleed_consult = costs_30days_post_second_severe_bleed.consultation,
			cost_30days_post_second_severe_bleed_test = costs_30days_post_second_severe_bleed.test,
			cost_30days_post_second_severe_bleed_total = costs_30days_post_second_severe_bleed.hospital_fce+costs_30days_post_second_severe_bleed.therapy+costs_30days_post_second_severe_bleed.consultation+costs_30days_post_second_severe_bleed.test,
			cost_6months_post_second_severe_bleed_hospital = costs_6months_post_second_severe_bleed.hospital_fce,
			cost_6months_post_second_severe_bleed_drug = costs_6months_post_second_severe_bleed.therapy,
			cost_6months_post_second_severe_bleed_consult = costs_6months_post_second_severe_bleed.consultation,
			cost_6months_post_second_severe_bleed_test = costs_6months_post_second_severe_bleed.test,
			cost_6months_post_second_severe_bleed_total = costs_6months_post_second_severe_bleed.hospital_fce+costs_6months_post_second_severe_bleed.therapy+costs_6months_post_second_severe_bleed.consultation+costs_6months_post_second_severe_bleed.test,
			cost_1year_post_second_severe_bleed_hospital = costs_1year_post_second_severe_bleed.hospital_fce,
			cost_1year_post_second_severe_bleed_drug = costs_1year_post_second_severe_bleed.therapy,
			cost_1year_post_second_severe_bleed_consult = costs_1year_post_second_severe_bleed.consultation,
			cost_1year_post_second_severe_bleed_test = costs_1year_post_second_severe_bleed.test,
			cost_1year_post_second_severe_bleed_total = costs_1year_post_second_severe_bleed.hospital_fce+costs_1year_post_second_severe_bleed.therapy+costs_1year_post_second_severe_bleed.consultation+costs_1year_post_second_severe_bleed.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		IF(patient.dxsp_date < date_exit-30) THEN
			UPDATE scad_sp_cohort_costs SET
			cost_30days_prior_to_exit_hospital = costs_30days_prior_to_exit.hospital_fce,
			cost_30days_prior_to_exit_drug = costs_30days_prior_to_exit.therapy,
			cost_30days_prior_to_exit_consult = costs_30days_prior_to_exit.consultation,
			cost_30days_prior_to_exit_test = costs_30days_prior_to_exit.test,
			cost_30days_prior_to_exit_total = costs_30days_prior_to_exit.hospital_fce+costs_30days_prior_to_exit.therapy+costs_30days_prior_to_exit.consultation+costs_30days_prior_to_exit.test
			WHERE anonpatid=patient.anonpatid;
		END IF;

		numrows = numrows+1;
	END LOOP;
	
	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_scad_sp_cohort_costs();




-- calculate durations on different treatments for the SCAD SP cohort


DROP TABLE IF EXISTS scad_sp_cohort_treatment_durations;
CREATE TABLE scad_sp_cohort_treatment_durations(
anonpatid int PRIMARY KEY,
clopidogrel_end_date date,
aspirin_end_date date,
statin_end_date date,
beta_blocker_end_date date,
ace_inhibitor_arb_end_date date,
clopidogrel_end_type text,
aspirin_end_type text,
statin_end_type text,
beta_blocker_end_type text,
ace_inhibitor_arb_end_type text
);

DROP FUNCTION IF EXISTS calculate_scad_sp_cohort_treatment_durations(max_censor_date date);
CREATE OR REPLACE FUNCTION calculate_scad_sp_cohort_treatment_durations(max_censor_date date) RETURNS int AS $$
DECLARE 
	patients CURSOR FOR SELECT sp.anonpatid, sp.dxsp_date, spo.cohort_exit_date, spo.cohort_exit_type 
	FROM scad_sp_cohort sp INNER JOIN scad_sp_cohort_outcomes spo ON sp.anonpatid = spo.anonpatid
	ORDER BY anonpatid;
	count int;
	death_date date;
	next_mi_date date;
	cohort_censor_date date;
	l_censor_date date;
	censor_type text;
	clopidogrel_end_date date;
	aspirin_end_date date;
	statin_end_date date;
	beta_blocker_end_date date;
	ace_inhibitor_arb_end_date date;
	clopidogrel_end_type text;
	aspirin_end_type text;
	statin_end_type text;
	beta_blocker_end_type text;
	ace_inhibitor_arb_end_type text;
	acute_days int;
BEGIN
	count = 0;
	acute_days = 61;
	TRUNCATE TABLE scad_sp_cohort_treatment_durations;

	FOR p IN patients LOOP
		IF count % 100 = 0 THEN
			RAISE INFO 'Calculating duration on treatment for patient with ID: %, % patients processed', p.anonpatid, count;
		END IF;
		count = count + 1;
		SELECT eventdate FROM che_mi_composite_30days WHERE anonpatid = p.anonpatid AND eventdate > p.dxsp_date ORDER BY eventdate ASC LIMIT 1 INTO next_mi_date;
	
		-- figure out the earliest possible censor point
		IF (next_mi_date IS NULL) THEN
			l_censor_date = p.cohort_exit_date;
			censor_type = p.cohort_exit_type;
		ELSE
			l_censor_date = CASE WHEN next_mi_date <= p.cohort_exit_date THEN next_mi_date ELSE p.cohort_exit_date END;
			censor_type = CASE WHEN next_mi_date <= p.cohort_exit_date THEN 'mi' ELSE p.cohort_exit_type END;
		END IF;

		-- figure out the earliest point treatment stopped
		-- clopidogrel
		SELECT MIN(month_start) FROM on_clopidogrel o INNER JOIN lkup_date d ON o.date_id = d.date_id 
		WHERE o.anonpatid = p.anonpatid AND d.month_start >= (p.dxsp_date + acute_days) AND (o.is_treated = 'N' OR o.is_treated IS NULL) INTO clopidogrel_end_date;
		IF(clopidogrel_end_date > l_censor_date) THEN 
			clopidogrel_end_date = CASE WHEN(l_censor_date<p.dxsp_date) THEN p.dxsp_date ELSE l_censor_date END;
			clopidogrel_end_type = censor_type;
		ELSE 
			IF(clopidogrel_end_date - p.dxsp_date <= (acute_days+30)) THEN
				clopidogrel_end_date = p.dxsp_date;
				clopidogrel_end_type = 'lt_3_months';
			ELSE
				clopidogrel_end_type = 'stopped';
			END IF;
		END IF;
		-- aspirin
		SELECT MIN(month_start) FROM on_aspirin o INNER JOIN lkup_date d ON o.date_id = d.date_id 
		WHERE o.anonpatid = p.anonpatid AND d.month_start >= (p.dxsp_date + acute_days) AND (o.is_treated = 'N' OR o.is_treated IS NULL) INTO aspirin_end_date;
		IF(aspirin_end_date > l_censor_date) THEN 
			aspirin_end_date = CASE WHEN(l_censor_date<p.dxsp_date) THEN p.dxsp_date ELSE l_censor_date END;
			aspirin_end_type = censor_type;
		ELSE 
			IF(aspirin_end_date - p.dxsp_date <= (acute_days+30)) THEN
				aspirin_end_date = p.dxsp_date;
				aspirin_end_type = 'lt_3_months';
			ELSE
				aspirin_end_type = 'stopped';
			END IF;
		END IF;
		-- statin
		SELECT MIN(month_start) FROM on_statin o INNER JOIN lkup_date d ON o.date_id = d.date_id 
		WHERE o.anonpatid = p.anonpatid AND d.month_start >= (p.dxsp_date + acute_days) AND (o.is_treated = 'N' OR o.is_treated IS NULL) INTO statin_end_date;
		IF(statin_end_date > l_censor_date) THEN 
			statin_end_date = CASE WHEN(l_censor_date<p.dxsp_date) THEN p.dxsp_date ELSE l_censor_date END;
			statin_end_type = censor_type;
		ELSE 
			IF(statin_end_date - p.dxsp_date <= (acute_days+30)) THEN
				statin_end_date = p.dxsp_date;
				statin_end_type = 'lt_3_months';
			ELSE
				statin_end_type = 'stopped';
			END IF;
		END IF;
		-- beta_blocker
		SELECT MIN(month_start) FROM on_beta_blocker o INNER JOIN lkup_date d ON o.date_id = d.date_id 
		WHERE o.anonpatid = p.anonpatid AND d.month_start >= (p.dxsp_date + acute_days) AND (o.is_treated = 'N' OR o.is_treated IS NULL) INTO beta_blocker_end_date;
		IF(beta_blocker_end_date > l_censor_date) THEN 
			beta_blocker_end_date = CASE WHEN(l_censor_date<p.dxsp_date) THEN p.dxsp_date ELSE l_censor_date END;
			beta_blocker_end_type = censor_type;
		ELSE 
			IF(beta_blocker_end_date - p.dxsp_date <= (acute_days+30)) THEN
				beta_blocker_end_date = p.dxsp_date;
				beta_blocker_end_type = 'lt_3_months';
			ELSE
				beta_blocker_end_type = 'stopped';
			END IF;
		END IF;
		-- ace_inhibitor_arb
		SELECT MIN(month_start) FROM on_ace_inhibitor_arb o INNER JOIN lkup_date d ON o.date_id = d.date_id 
		WHERE o.anonpatid = p.anonpatid AND d.month_start >= (p.dxsp_date + acute_days) AND (o.is_treated = 'N' OR o.is_treated IS NULL) INTO ace_inhibitor_arb_end_date;
		IF(ace_inhibitor_arb_end_date > l_censor_date) THEN 
			ace_inhibitor_arb_end_date = CASE WHEN(l_censor_date<p.dxsp_date) THEN p.dxsp_date ELSE l_censor_date END;
			ace_inhibitor_arb_end_type = censor_type;
		ELSE 
			IF(ace_inhibitor_arb_end_date - p.dxsp_date <= (acute_days+30)) THEN
				ace_inhibitor_arb_end_date = p.dxsp_date;
				ace_inhibitor_arb_end_type = 'lt_3_months';
			ELSE
				ace_inhibitor_arb_end_type = 'stopped';
			END IF;
		END IF;

		INSERT INTO scad_sp_cohort_treatment_durations (
		anonpatid,
		clopidogrel_end_date,
		clopidogrel_end_type,
		aspirin_end_date,
		aspirin_end_type,
		statin_end_date,
		statin_end_type,
		beta_blocker_end_date,
		beta_blocker_end_type,
		ace_inhibitor_arb_end_date,
		ace_inhibitor_arb_end_type) 
		VALUES 
		(
		p.anonpatid,
		clopidogrel_end_date,
		clopidogrel_end_type,
		aspirin_end_date,
		aspirin_end_type,
		statin_end_date,
		statin_end_type,
		beta_blocker_end_date,
		beta_blocker_end_type,
		ace_inhibitor_arb_end_date,
		ace_inhibitor_arb_end_type);	
	END LOOP;
	
	RETURN count;
END; $$
LANGUAGE PLPGSQL;

SELECT calculate_scad_sp_cohort_treatment_durations('2010-03-25');





-----------
	--- set cohort flags
-- 	RAISE INFO 'CREATING AF COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af ON COMMIT DROP AS
-- 	SELECT anonpatid, dxaf_date, dxscad_date 
-- 	FROM
-- 	(SELECT anonpatid, min(eventdate) dxaf_date, dxscad_date FROM 
-- 	((SELECT af.anonpatid, af.eventdate, sc.dxscad_date FROM cal_af_gprd af INNER JOIN scad_cohort sc ON af.anonpatid = sc.anonpatid WHERE af.eventdate <= sc.dxscad_date)
-- 	UNION
-- 	(SELECT af.anonpatid, af.date_admission AS eventdate, sc.dxscad_date FROM cal_af_hes af INNER JOIN scad_cohort sc ON af.anonpatid = sc.anonpatid WHERE af.date_admission <= sc.dxscad_date)) x
-- 	GROUP BY anonpatid, dxscad_date) y;
-- 
-- 	RAISE INFO 'CREATING AF I COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent ON COMMIT DROP AS
-- 	SELECT sp.*, y.dxaf_date, d.month_start, d.month_end, y.dxscad_date 
-- 	FROM
-- 	cohort_af y 
-- 	INNER JOIN on_warfarin_aspirin_clopidogrel_intermittent sp ON y.anonpatid = sp.anonpatid
-- 	INNER JOIN lkup_date d ON sp.date_id = d.date_id;
-- 	CREATE INDEX cohort_af_intermittent_patid_in ON cohort_af_intermittent(anonpatid);
-- 	CREATE INDEX cohort_af_intermittent_treated_in ON cohort_af_intermittent(is_treated);
-- 
-- 	RAISE INFO 'CREATING AF I WAC COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_wac ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WA', 'AC', 'WC', 'W', 'A', 'C', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_wac_patid_in ON cohort_af_intermittent_wac(anonpatid);
-- 
-- 	RAISE INFO 'CREATING AF I WA COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_wa ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WAC', 'AC', 'WC', 'W', 'A', 'C', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_wa_patid_in ON cohort_af_intermittent_wa(anonpatid);
-- 
-- 	RAISE INFO 'CREATING AF I AC COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_ac ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WA', 'WAC', 'WC', 'W', 'A', 'C', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_ac_patid_in ON cohort_af_intermittent_ac(anonpatid);
-- 
-- 	RAISE INFO 'CREATING AF I WC COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_wc ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WA', 'AC', 'WAC', 'W', 'A', 'C', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_wc_patid_in ON cohort_af_intermittent_wc(anonpatid);
-- 
-- 	RAISE INFO 'CREATING AF I W COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_w ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WA', 'AC', 'WC', 'WAC', 'A', 'C', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_w_patid_in ON cohort_af_intermittent_w(anonpatid);
-- 
-- 	RAISE INFO 'CREATING AF I A COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_a ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WA', 'AC', 'WC', 'W', 'WAC', 'C', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_a_patid_in ON cohort_af_intermittent_a(anonpatid);
-- 
-- 	RAISE INFO 'CREATING AF I C COHORT';
-- 	CREATE TEMPORARY TABLE cohort_af_intermittent_c ON COMMIT DROP AS
-- 	SELECT * FROM cohort_af_intermittent WHERE anonpatid NOT IN 
-- 	(SELECT DISTINCT(anonpatid) FROM cohort_af_intermittent WHERE is_treated IN ('WA', 'AC', 'WC', 'W', 'A', 'WAC', 'N') AND month_start < (dxscad_date+90));
-- 	CREATE INDEX cohort_af_intermittent_c_patid_in ON cohort_af_intermittent_c(anonpatid);
-- 
-- 	RAISE INFO 'UPDATING AF';
-- 	UPDATE scad_cohort_additional_vars SET af_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af); 
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_wac_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_wac);
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_wa_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_wa);
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_ac_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_ac);
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_wc_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_wc);
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_w_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_w);
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_a_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_a);
-- 	UPDATE scad_cohort_additional_vars SET af_cohort_c_i_3months_cohort=TRUE WHERE anonpatid IN (SELECT anonpatid FROM cohort_af_intermittent_c);
-- 	
-----------------