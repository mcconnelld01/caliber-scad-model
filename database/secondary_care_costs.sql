--- Stored procedure to convert HES data into a form that works with the NHS IC grouper to generate HRG codes

CREATE OR REPLACE FUNCTION hes_for_grouper() RETURNS int AS $$
DECLARE 
	patients CURSOR FOR SELECT DISTINCT(anonpatid) FROM scad_cohort;
	episodes CURSOR (pat integer) FOR SELECT * FROM hes_episode WHERE anonpatid=pat;
	diags CURSOR (pat integer, episode integer) FOR SELECT substr(icd,1,4) icd FROM hes_diag_epi WHERE anonpatid=pat AND epikey=episode ORDER BY primary_epi DESC;
	procs CURSOR (pat integer, episode integer) FOR SELECT substr(opcs,1,4) opcs FROM hes_procedure WHERE anonpatid=pat AND epikey=episode AND opcs!='&';
	ICD1 varchar;
	ICD2 varchar;
	ICD3 varchar;
	ICD4 varchar;
	ICD5 varchar;
	ICD6 varchar;
	ICD7 varchar;
	ICD8 varchar;
	ICD9 varchar;
	ICD10 varchar;
	ICD11 varchar;
	ICD12 varchar;
	ICD13 varchar;
	ICD14 varchar;
	OPCS1 varchar;
	OPCS2 varchar;
	OPCS3 varchar;
	OPCS4 varchar;
	OPCS5 varchar;
	OPCS6 varchar;
	OPCS7 varchar;
	OPCS8 varchar;
	OPCS9 varchar;
	OPCS10 varchar;
	OPCS11 varchar;
	OPCS12 varchar;
	numrows int;
BEGIN
	numrows = 0;
	DROP TABLE IF EXISTS hes_episode_grouper;
	CREATE TABLE hes_episode_grouper(
	ANONPATID int,
	EPIKEY int,
	PROCODET int,
	PROVSPNO int,
	EPIORDER int,
	STARTAGE int,
	SEX int,
	CLASSPAT int,
	ADMISORC int,
	ADMIMETH int,
	DISDEST int,
	DISMETH int,
	EPIDUR int,
	MAINSPEF int,
	NEOCARE int,
	TRETSPEF int,
	DIAG_01 varchar,
	DIAG_02 varchar,
	DIAG_03 varchar,
	DIAG_04 varchar,
	DIAG_05 varchar,
	DIAG_06 varchar,
	DIAG_07 varchar,
	DIAG_08 varchar,
	DIAG_09 varchar,
	DIAG_10 varchar,
	DIAG_11 varchar,
	DIAG_12 varchar,
	DIAG_13 varchar,
	DIAG_14 varchar,
	OPER_01 varchar,
	OPER_02 varchar,
	OPER_03 varchar,
	OPER_04 varchar,
	OPER_05 varchar,
	OPER_06 varchar,
	OPER_07 varchar,
	OPER_08 varchar,
	OPER_09 varchar,
	OPER_10 varchar,
	OPER_11 varchar,
	OPER_12 varchar,
	CRITICALCAREDAYS varchar,
	REHABILITATIONDAYS int,
	SPCDAYS int
	);
	
	FOR patient IN patients	LOOP
		FOR episode IN episodes(pat:=patient.anonpatid) LOOP
			-- loop through ICD codes
			OPEN diags(pat:=patient.anonpatid, episode:=episode.epikey);
			FETCH diags INTO ICD1;
			FETCH diags INTO ICD2;
			FETCH diags INTO ICD3;
			FETCH diags INTO ICD4;
			FETCH diags INTO ICD5;
			FETCH diags INTO ICD6;
			FETCH diags INTO ICD7;
			FETCH diags INTO ICD8;
			FETCH diags INTO ICD9;
			FETCH diags INTO ICD10;
			FETCH diags INTO ICD11;
			FETCH diags INTO ICD12;
			FETCH diags INTO ICD13;
			FETCH diags INTO ICD14;
			CLOSE diags;
			-- loop through OPCS codes
			OPEN procs(pat:=patient.anonpatid, episode:=episode.epikey);
			FETCH procs INTO OPCS1;
			FETCH procs INTO OPCS2;
			FETCH procs INTO OPCS3;
			FETCH procs INTO OPCS4;
			FETCH procs INTO OPCS5;
			FETCH procs INTO OPCS6;
			FETCH procs INTO OPCS7;
			FETCH procs INTO OPCS8;
			FETCH procs INTO OPCS9;
			FETCH procs INTO OPCS10;
			FETCH procs INTO OPCS11;
			FETCH procs INTO OPCS12;
			CLOSE procs;

			INSERT INTO hes_episode_grouper
			SELECT 
			patient.anonpatid ANONPATID,
			episode.epikey EPIKEY,
			1 PROCODET,
			episode.spno PROVSPNO,
			episode.eorder EPIORDER,
			extract(year FROM episode.epistart)-p.year_of_birth STARTAGE, 
			p.gender SEX, 
			episode.classpat CLASSPAT, 
			episode.admisorc ADMISORC,
			episode.admimeth ADMIMETH,
			episode.disdest DISDEST,
			episode.dismeth DISMETH,
			episode.epidur EPIDUR,
			episode.mainspef MAINSPEF,
			8 NEOCARE,
			episode.tretspef TRETSPEF,
			ICD1 DIAG_01,
			ICD2 DIAG_02,
			ICD3 DIAG_03,
			ICD4 DIAG_04,
			ICD5 DIAG_05,
			ICD6 DIAG_06,
			ICD7 DIAG_07,
			ICD8 DIAG_08,
			ICD9 DIAG_09,
			ICD10 DIAG_10,
			ICD11 DIAG_11,
			ICD12 DIAG_12,
			ICD13 DIAG_13,
			ICD14 DIAG_14,
			OPCS1 OPER_01,
			OPCS2 OPER_02,
			OPCS3 OPER_03,
			OPCS4 OPER_04,
			OPCS5 OPER_05,
			OPCS6 OPER_06,
			OPCS7 OPER_07,
			OPCS8 OPER_08,
			OPCS9 OPER_09,
			OPCS10 OPER_10,
			OPCS11 OPER_11,
			OPCS12 OPER_12,
			0 CRITICALCAREDAYS,
			0 REHABILITATIONDAYS,
			0 SPCDAYS
			FROM patient p WHERE p.anonpatid = patient.anonpatid;
			numrows = numrows+1;
		END LOOP;
	END LOOP;
	RETURN numrows;
END; $$
LANGUAGE PLPGSQL;

--- output HES data in grouper format
SELECT hes_for_grouper();
COPY hes_episode_grouper TO 'C:\CALIBER\1_RawData\hes_episode_grouper.csv' DELIMITER ',' CSV HEADER;

--- create table to store results returned from grouper
DROP TABLE IF EXISTS hes_episode_grouper_output;
CREATE TABLE hes_episode_grouper_output(
hes_episode_HRG_id SERIAL primary key,
anonpatid int,
epikey int,
PROCODET int,
PROVSPNO int,
EPIORDER int,
STARTAGE int,
SEX int,
CLASSPAT int,
ADMISORC int,
ADMIMETH int,
DISDEST int,
DISMETH int,
EPIDUR int,
MAINSPEF int,
NEOCARE int,
TRETSPEF int,
DIAG_01 varchar,
DIAG_02 varchar,
DIAG_03 varchar,
DIAG_04 varchar,
DIAG_05 varchar,
DIAG_06 varchar,
DIAG_07 varchar,
DIAG_08 varchar,
DIAG_09 varchar,
DIAG_10 varchar,
DIAG_11 varchar,
DIAG_12 varchar,
DIAG_13 varchar,
DIAG_14 varchar,
OPER_01 varchar,
OPER_02 varchar,
OPER_03 varchar,
OPER_04 varchar,
OPER_05 varchar,
OPER_06 varchar,
OPER_07 varchar,
OPER_08 varchar,
OPER_09 varchar,
OPER_10 varchar,
OPER_11 varchar,
OPER_12 varchar,
CRITICALCAREDAYS varchar,
REHABILITATIONDAYS int,
SPCDAYS int,
RowNo int,
FCE_HRG	varchar,
GroupingMethodFlag varchar,
DominantProcedure varchar,
FCE_PBC varchar,	
CalcEpidur int,	
ReportingEPIDUR	int,
FCETrimpoint int,	
FCEExcessBeddays int,	
SpellReportFlag varchar,	
SpellHRG varchar,	
SpellGroupingMethodFlag varchar,	
SpellDominantProcedure varchar,	
SpellPDiag varchar,	
SpellSDiag varchar,	
SpellEpisodeCount int,	
SpellLOS int,	
ReportingSpellLOS int,	
SpellTrimpoint int,
SpellExcessBeddays int,	
SpellCCDays int,	
SpellPBC varchar,	
UnbundledHRG1 varchar,
UnbundledHRG2 varchar,
UnbundledHRG3 varchar,
UnbundledHRG4 varchar,
UnbundledHRG5 varchar,
UnbundledHRG6 varchar,
UnbundledHRG7 varchar,
UnbundledHRG8 varchar
);

--- import results from grouper
COPY hes_episode_grouper_output(anonpatid,epikey,PROCODET,PROVSPNO,EPIORDER,STARTAGE,SEX,CLASSPAT,ADMISORC,ADMIMETH,DISDEST,DISMETH,EPIDUR,MAINSPEF,NEOCARE,TRETSPEF,DIAG_01,DIAG_02,DIAG_03,DIAG_04,DIAG_05,DIAG_06,DIAG_07,DIAG_08,DIAG_09,DIAG_10,DIAG_11,DIAG_12,DIAG_13,DIAG_14,OPER_01,OPER_02,OPER_03,OPER_04,OPER_05,OPER_06,OPER_07,OPER_08,OPER_09,OPER_10,OPER_11,OPER_12,CRITICALCAREDAYS,REHABILITATIONDAYS,SPCDAYS,RowNo,FCE_HRG,GroupingMethodFlag,DominantProcedure,FCE_PBC,CalcEpidur,ReportingEPIDUR,FCETrimpoint,FCEExcessBeddays,SpellReportFlag,SpellHRG,SpellGroupingMethodFlag,SpellDominantProcedure,SpellPDiag,SpellSDiag,SpellEpisodeCount,SpellLOS,ReportingSpellLOS,SpellTrimpoint,SpellExcessBeddays,SpellCCDays,SpellPBC,UnbundledHRG1,UnbundledHRG2,UnbundledHRG3,UnbundledHRG4,UnbundledHRG5,UnbundledHRG6,UnbundledHRG7)
FROM 'C:\CALIBER\1_RawData\grouper_FCE_part_1.csv' DELIMITER ',' CSV HEADER;

COPY hes_episode_grouper_output(anonpatid,epikey,PROCODET,PROVSPNO,EPIORDER,STARTAGE,SEX,CLASSPAT,ADMISORC,ADMIMETH,DISDEST,DISMETH,EPIDUR,MAINSPEF,NEOCARE,TRETSPEF,DIAG_01,DIAG_02,DIAG_03,DIAG_04,DIAG_05,DIAG_06,DIAG_07,DIAG_08,DIAG_09,DIAG_10,DIAG_11,DIAG_12,DIAG_13,DIAG_14,OPER_01,OPER_02,OPER_03,OPER_04,OPER_05,OPER_06,OPER_07,OPER_08,OPER_09,OPER_10,OPER_11,OPER_12,CRITICALCAREDAYS,REHABILITATIONDAYS,SPCDAYS,RowNo,FCE_HRG,GroupingMethodFlag,DominantProcedure,FCE_PBC,CalcEpidur,ReportingEPIDUR,FCETrimpoint,FCEExcessBeddays,SpellReportFlag,SpellHRG,SpellGroupingMethodFlag,SpellDominantProcedure,SpellPDiag,SpellSDiag,SpellEpisodeCount,SpellLOS,ReportingSpellLOS,SpellTrimpoint,SpellExcessBeddays,SpellCCDays,SpellPBC,UnbundledHRG1,UnbundledHRG2,UnbundledHRG3,UnbundledHRG4,UnbundledHRG5,UnbundledHRG6,UnbundledHRG7,UnbundledHRG8)
FROM 'C:\CALIBER\1_RawData\grouper_FCE_part_2.csv' DELIMITER ',' CSV;

--- clean up the unbundled HRG codes
UPDATE hes_episode_grouper_output SET UnbundledHRG1 = substring(UnbundledHRG1 from 1 for 5) WHERE UnbundledHRG1 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG2 = substring(UnbundledHRG2 from 1 for 5) WHERE UnbundledHRG2 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG3 = substring(UnbundledHRG3 from 1 for 5) WHERE UnbundledHRG3 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG4 = substring(UnbundledHRG4 from 1 for 5) WHERE UnbundledHRG4 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG5 = substring(UnbundledHRG5 from 1 for 5) WHERE UnbundledHRG5 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG6 = substring(UnbundledHRG6 from 1 for 5) WHERE UnbundledHRG6 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG7 = substring(UnbundledHRG7 from 1 for 5) WHERE UnbundledHRG7 LIKE '%*1%';
UPDATE hes_episode_grouper_output SET UnbundledHRG8 = substring(UnbundledHRG8 from 1 for 5) WHERE UnbundledHRG8 LIKE '%*1%';

--- create table to store NHS reference costs
DROP TABLE IF EXISTS lkup_nhs_reference_costs_2011_12;
CREATE TABLE lkup_nhs_reference_costs_2011_12(
hrg4 varchar primary key,
hrg4_description varchar,
unit_cost_total float,
unit_cost_ei float,
unit_cost_ei_xs float,
unit_cost_nei_l float,
unit_cost_nei_l_xs float,
unit_cost_nei_s float,
unit_cost_dc float
);

--- import NHS reference costs FCE level
COPY lkup_nhs_reference_costs_2011_12(hrg4,hrg4_description,unit_cost_total,unit_cost_ei,unit_cost_ei_xs,unit_cost_nei_l,unit_cost_nei_l_xs,unit_cost_nei_s,unit_cost_dc) 
FROM 'C:\CALIBER\Documents\Lookups\NSRC01 2011-12.csv' DELIMITER ',' CSV HEADER;

UPDATE lkup_nhs_reference_costs_2011_12 SET unit_cost_ei_xs = 0 WHERE unit_cost_ei_xs IS NULL;
UPDATE lkup_nhs_reference_costs_2011_12 SET unit_cost_nei_l_xs = 0 WHERE unit_cost_nei_l_xs IS NULL;

--- add imputed costs used by health policy team

DELETE FROM lkup_nhs_reference_costs_2011_12 WHERE hrg4 IN ('LA08E','UZ01Z','WD22Z','WD11Z','WF01A','WF02A');

INSERT INTO lkup_nhs_reference_costs_2011_12 
(hrg4, hrg4_description, unit_cost_total, unit_cost_ei, unit_cost_ei_xs, unit_cost_nei_l, unit_cost_nei_l_xs, unit_cost_nei_s, unit_cost_dc) 
VALUES
('LA08E','Imputed 2009-10', 0, 531.08, 0, 510.39, 0, 510.39, 510.39);

INSERT INTO lkup_nhs_reference_costs_2011_12 
(hrg4, hrg4_description, unit_cost_total, unit_cost_ei, unit_cost_ei_xs, unit_cost_nei_l, unit_cost_nei_l_xs, unit_cost_nei_s, unit_cost_dc) 
VALUES
('UZ01Z','Imputed 2009-10', 1329.59, 1161.08, 0, 1329.59, 0, 1329.59, 1161.08);

INSERT INTO lkup_nhs_reference_costs_2011_12 
(hrg4, hrg4_description, unit_cost_total, unit_cost_ei, unit_cost_ei_xs, unit_cost_nei_l, unit_cost_nei_l_xs, unit_cost_nei_s, unit_cost_dc) 
VALUES
('WD22Z','Imputed 2009-10', 0, 1161.08, 0, 1329.59, 0, 1329.59, 1161.08);

INSERT INTO lkup_nhs_reference_costs_2011_12 
(hrg4, hrg4_description, unit_cost_total, unit_cost_ei, unit_cost_ei_xs, unit_cost_nei_l, unit_cost_nei_l_xs, unit_cost_nei_s, unit_cost_dc) 
VALUES
('WD11Z','Imputed 2009-10', 0, 1161.08, 0, 1329.59, 0, 1329.59, 1161.08);

INSERT INTO lkup_nhs_reference_costs_2011_12 
(hrg4, hrg4_description, unit_cost_total, unit_cost_ei, unit_cost_ei_xs, unit_cost_nei_l, unit_cost_nei_l_xs, unit_cost_nei_s, unit_cost_dc) 
VALUES
('WF01A','Imputed 2009-10', 0, 1161.08, 0, 1329.59, 0, 1329.59, 1161.08);

INSERT INTO lkup_nhs_reference_costs_2011_12 
(hrg4, hrg4_description, unit_cost_total, unit_cost_ei, unit_cost_ei_xs, unit_cost_nei_l, unit_cost_nei_l_xs, unit_cost_nei_s, unit_cost_dc) 
VALUES
('WF02A','Imputed', 0, 1161.08, 0, 1329.59, 0, 1329.59, 1161.08);

--- create a table to show episode level costs
DROP TABLE IF EXISTS hes_episode_cost;
CREATE TABLE hes_episode_cost AS
SELECT g.anonpatid, g.epikey, g.fce_hrg, g.classpat, g.admimeth, e.epistart, e.epiend, e.admidate, e.eorder,
CASE
WHEN g.classpat=2 AND c.unit_cost_dc IS NOT NULL THEN c.unit_cost_dc
WHEN g.classpat=2 AND c.unit_cost_dc IS NULL THEN c.unit_cost_total
WHEN (g.admimeth < 20 OR g.admimeth > 30) AND c.unit_cost_ei IS NOT NULL THEN c.unit_cost_ei + g.fceexcessbeddays*c.unit_cost_ei_xs
WHEN (g.admimeth < 20 OR g.admimeth > 30) AND c.unit_cost_ei IS NULL THEN c.unit_cost_total
WHEN g.admimeth > 20 AND g.admimeth < 30 AND g.epidur < 2 AND c.unit_cost_nei_s IS NOT NULL THEN c.unit_cost_nei_s
WHEN g.admimeth > 20 AND g.admimeth < 30 AND g.epidur < 2 AND c.unit_cost_nei_s IS NULL THEN c.unit_cost_total
WHEN g.admimeth > 20 AND g.admimeth < 30 AND c.unit_cost_nei_l IS NOT NULL THEN c.unit_cost_nei_l + g.fceexcessbeddays*c.unit_cost_nei_l_xs
WHEN g.admimeth > 20 AND g.admimeth < 30 AND c.unit_cost_nei_l IS NULL THEN c.unit_cost_total
ELSE null
END fce_cost,
(u.U1+u.U2+u.U3+u.U4+u.U5+u.U6+u.U7+u.U8) unbundled_cost 
FROM hes_episode_grouper_output g
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 c ON g.fce_hrg = c.hrg4
INNER JOIN hes_episode e ON e.epikey = g.epikey AND e.anonpatid = g.anonpatid AND e.eorder = g.epiorder
INNER JOIN (
SELECT g.anonpatid, g.epikey, g.epiorder,
CASE WHEN U1.unit_cost_total IS NULL THEN 0 ELSE U1.unit_cost_total END U1, 
CASE WHEN U2.unit_cost_total IS NULL THEN 0 ELSE U2.unit_cost_total END U2, 
CASE WHEN U3.unit_cost_total IS NULL THEN 0 ELSE U3.unit_cost_total END U3, 
CASE WHEN U4.unit_cost_total IS NULL THEN 0 ELSE U4.unit_cost_total END U4, 
CASE WHEN U5.unit_cost_total IS NULL THEN 0 ELSE U5.unit_cost_total END U5, 
CASE WHEN U6.unit_cost_total IS NULL THEN 0 ELSE U6.unit_cost_total END U6, 
CASE WHEN U7.unit_cost_total IS NULL THEN 0 ELSE U7.unit_cost_total END U7, 
CASE WHEN U8.unit_cost_total IS NULL THEN 0 ELSE U8.unit_cost_total END U8
FROM hes_episode_grouper_output g 
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U1 ON U1.hrg4 = g.unbundledhrg1
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U2 ON U2.hrg4 = g.unbundledhrg2
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U3 ON U3.hrg4 = g.unbundledhrg3
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U4 ON U4.hrg4 = g.unbundledhrg4
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U5 ON U5.hrg4 = g.unbundledhrg5
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U6 ON U6.hrg4 = g.unbundledhrg6
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U7 ON U7.hrg4 = g.unbundledhrg7
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12 U8 ON U8.hrg4 = g.unbundledhrg8
) u ON u.epikey = g.epikey AND u.anonpatid = g.anonpatid AND u.epiorder=g.epiorder;

CREATE INDEX episode_cost_patid_index ON hes_episode_cost(anonpatid);
CREATE INDEX episode_cost_epistart_index ON hes_episode_cost(epistart); 
CREATE INDEX episode_cost_epiend_index ON hes_episode_cost(epiend); 
CREATE INDEX episode_cost_admidate_index ON hes_episode_cost(admidate); 

ALTER TABLE hes_episode_cost ADD CONSTRAINT epi_cost_pkey PRIMARY KEY (anonpatid,epikey,eorder);
ALTER TABLE hes_episode_cost ADD CONSTRAINT epi_cost_patid FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);
ALTER TABLE hes_episode_cost ADD CONSTRAINT epi_cost_hrg FOREIGN KEY (fce_hrg) REFERENCES lkup_nhs_reference_costs_2011_12(hrg4);

--- check for missing data
SELECT fce_HRG, count(fce_HRG) count FROM hes_episode_cost WHERE fce_cost IS NULL GROUP BY fce_hrg ORDER BY count;

SELECT fce_HRG, count(fce_HRG) count FROM hes_episode_cost WHERE fce_HRG IN ('LA08E','UZ01Z','WD22Z','WD11Z','WF01A','WF02A') GROUP BY fce_hrg ORDER BY count DESC;

--- import spell level reference costs
DROP TABLE IF EXISTS nhs_reference_costs_2011_12_spells;
CREATE TABLE nhs_reference_costs_2011_12_spells(
org varchar,
dept varchar,
hrg4 varchar,
unit_cost float,
activity int,
inlier_bed_days int,
excess_bed_days int,
mean float,
actual_cost float,
expected_cost float,
mapping_pot varchar
);

--- import NHS reference costs spell level
COPY nhs_reference_costs_2011_12_spells(org, dept, hrg4, unit_cost, activity, inlier_bed_days, excess_bed_days, mean, actual_cost, expected_cost, mapping_pot) 
FROM 'C:\CALIBER\Documents\Lookups\11 Spells data.csv' DELIMITER ',' CSV HEADER;

--- group into appropriate format for costing
DROP TABLE IF EXISTS lkup_nhs_reference_costs_2011_12_spell;
CREATE TABLE lkup_nhs_reference_costs_2011_12_spell AS
SELECT HRG.hrg4, unit_cost_ei, unit_cost_nei_l, unit_cost_nei_s, unit_cost_dc FROM
(
(SELECT DISTINCT(hrg4) FROM nhs_reference_costs_2011_12_spells) HRG
LEFT OUTER JOIN
(SELECT hrg4, max(mean) AS unit_cost_ei FROM nhs_reference_costs_2011_12_spells WHERE dept='EI' GROUP BY hrg4) EI
ON HRG.hrg4=EI.hrg4
LEFT OUTER JOIN
(SELECT hrg4, max(mean) AS unit_cost_nei_l FROM nhs_reference_costs_2011_12_spells WHERE dept='NEI_L' GROUP BY hrg4) NEI_L
ON HRG.hrg4=NEI_L.hrg4
LEFT OUTER JOIN
(SELECT hrg4, max(mean) AS unit_cost_nei_s FROM nhs_reference_costs_2011_12_spells WHERE dept='NEI_S' GROUP BY hrg4) NEI_S
ON HRG.hrg4=NEI_S.hrg4
LEFT OUTER JOIN
(SELECT hrg4, max(mean) AS unit_cost_dc FROM nhs_reference_costs_2011_12_spells WHERE dept='DC' GROUP BY hrg4) DC
ON HRG.hrg4=DC.hrg4);

ALTER TABLE lkup_nhs_reference_costs_2011_12_spell ADD CONSTRAINT nhs_spell_hrg PRIMARY KEY (hrg4);


INSERT INTO lkup_nhs_reference_costs_2011_12_spell 
(hrg4,unit_cost_ei,unit_cost_nei_l,unit_cost_nei_s, unit_cost_dc) 
VALUES
('WF01A', 1161.08, 1329.59, 1329.59, 1161.08);

INSERT INTO lkup_nhs_reference_costs_2011_12_spell 
(hrg4,unit_cost_ei,unit_cost_nei_l,unit_cost_nei_s, unit_cost_dc) 
VALUES
('WF02A', 1161.08, 1329.59, 1329.59, 1161.08);

INSERT INTO lkup_nhs_reference_costs_2011_12_spell
(hrg4,unit_cost_ei,unit_cost_nei_l,unit_cost_nei_s, unit_cost_dc) 
VALUES
('LA08E', 531.08, 510.39, 510.39, 510.39);

--- create a table to show spells with hrg4
DROP TABLE IF EXISTS hes_spell;
CREATE TABLE hes_spell AS SELECT E.*, HRG.hrg4 FROM (
(SELECT anonpatid, spno, min(admimeth) admimeth, min(admidate) admidate, sum(epidur) spdur, min(epistart) spstart, max(epiend) spend, min(classpat) classpat FROM hes_episode GROUP BY anonpatid, spno) E
LEFT OUTER JOIN 
(SELECT anonpatid, provspno, min(SpellHRG) HRG4 FROM hes_episode_grouper_output GROUP BY anonpatid, provspno) HRG
ON E.anonpatid=HRG.anonpatid AND E.spno = HRG.provspno);

ALTER TABLE hes_spell ADD CONSTRAINT spell_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);
ALTER TABLE hes_spell ADD CONSTRAINT hes_spell_hrg FOREIGN KEY (hrg4) REFERENCES lkup_nhs_reference_costs_2011_12_spell(hrg4);

DROP TABLE IF EXISTS hes_spell_cost;
CREATE TABLE hes_spell_cost AS
SELECT s.*,
CASE
WHEN s.classpat=2 AND c.unit_cost_dc IS NOT NULL THEN c.unit_cost_dc
WHEN (s.admimeth < 20 OR s.admimeth > 30) AND c.unit_cost_ei IS NOT NULL THEN c.unit_cost_ei
WHEN (s.admimeth < 20 OR s.admimeth > 30) AND s.spdur < 2 AND c.unit_cost_ei IS NULL THEN c.unit_cost_nei_s
WHEN (s.admimeth < 20 OR s.admimeth > 30) AND c.unit_cost_ei IS NULL THEN c.unit_cost_nei_l
WHEN (s.admimeth > 20 AND s.admimeth < 30) AND s.spdur < 2 AND c.unit_cost_nei_s IS NOT NULL THEN c.unit_cost_nei_s
WHEN (s.admimeth > 20 AND s.admimeth < 30) AND c.unit_cost_nei_l IS NOT NULL THEN c.unit_cost_nei_l
ELSE null
END spell_cost 
FROM hes_spell s
LEFT OUTER JOIN lkup_nhs_reference_costs_2011_12_spell c ON s.hrg4 = c.hrg4;

CREATE INDEX spell_cost_patid_index ON hes_spell_cost(anonpatid);
CREATE INDEX spell_cost_epistart_index ON hes_spell_cost(spstart); 
CREATE INDEX spell_cost_epiend_index ON hes_spell_cost(spend); 
CREATE INDEX spell_cost_admidate_index ON hes_spell_cost(admidate);

ALTER TABLE hes_spell_cost ADD CONSTRAINT spell_cost_pat FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);
ALTER TABLE hes_spell_cost ADD CONSTRAINT spell_cost_hrg FOREIGN KEY (hrg4) REFERENCES lkup_nhs_reference_costs_2011_12_spell(hrg4);
