----------------------------
--- CALCULATE DRUG COSTS ---
----------------------------

DROP TABLE IF EXISTS lkup_PCA_drugsubstance_costs_2012;
CREATE TABLE lkup_PCA_drugsubstance_costs_2012(
drugsubstance varchar,
bnfcode varchar,
nic float
);

COPY lkup_PCA_drugsubstance_costs_2012(drugsubstance,bnfcode,nic) 
FROM 'C:\CALIBER\Documents\Lookups\PCA_2012_drugsubstance.csv' DELIMITER ',' CSV HEADER;

-- update reformat bnfcodes into standard 8 character format 
UPDATE lkup_PCA_drugsubstance_costs_2012 SET bnfcode = CASE WHEN char_length(bnfcode)=7 THEN '0'||bnfcode ELSE bnfcode END;

DROP TABLE IF EXISTS lkup_PCA_subpara_costs_2012;
CREATE TABLE lkup_PCA_subpara_costs_2012(
subpara varchar,
bnfcode varchar,
nic float
);

COPY lkup_PCA_subpara_costs_2012(subpara,bnfcode,nic) 
FROM 'C:\CALIBER\Documents\Lookups\PCA_2012_sub_para.csv' DELIMITER ',' CSV HEADER;

UPDATE lkup_PCA_subpara_costs_2012 SET bnfcode = CASE WHEN char_length(bnfcode)=7 THEN '0'||bnfcode ELSE bnfcode END;


DROP TABLE IF EXISTS lkup_PCA_para_costs_2012;
CREATE TABLE lkup_PCA_para_costs_2012(
bnfcode varchar,
nic float
);

COPY lkup_PCA_para_costs_2012(bnfcode,nic) 
FROM 'C:\CALIBER\Documents\Lookups\PCA_2012_para.csv' DELIMITER ',' CSV HEADER;

-- update reformat bnfcodes into standard 8 character format 
UPDATE lkup_PCA_para_costs_2012 SET bnfcode = CASE WHEN char_length(bnfcode)=7 THEN '0'||bnfcode ELSE bnfcode END;


DROP TABLE IF EXISTS lkup_PCA_section_costs_2012;
CREATE TABLE lkup_PCA_section_costs_2012(
section varchar,
bnfcode varchar,
nic float
);

COPY lkup_PCA_section_costs_2012(section,bnfcode,nic) 
FROM 'C:\CALIBER\Documents\Lookups\PCA_2012_section.csv' DELIMITER ',' CSV HEADER;

-- update reformat bnfcodes into standard 8 character format 
UPDATE lkup_PCA_section_costs_2012 SET bnfcode = CASE WHEN char_length(bnfcode)=7 THEN '0'||bnfcode ELSE bnfcode END;


DROP TABLE IF EXISTS lkup_PCA_chapter_costs_2012;
CREATE TABLE lkup_PCA_chapter_costs_2012(
chapter varchar,
bnfcode varchar,
nic float
);

COPY lkup_PCA_chapter_costs_2012(chapter,bnfcode,nic) 
FROM 'C:\CALIBER\Documents\Lookups\PCA_2012_chapter.csv' DELIMITER ',' CSV HEADER;

-- update reformat bnfcodes into standard 8 character format 
UPDATE lkup_PCA_chapter_costs_2012 SET bnfcode = CASE WHEN char_length(bnfcode)=7 THEN '0'||bnfcode ELSE bnfcode END;

-- start by matching on bnf sub paragraph
DROP TABLE IF EXISTS lkup_drug_costs;
CREATE TABLE lkup_drug_costs AS
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_subpara_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 1 for 8)
ORDER BY p.bnfcode;
-- use second bnfcode if fail to match on first
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_subpara_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 10 for 8)
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;

-- fill in missing values at the bnf paragraph level
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_para_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 1 for 6)||'00'
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;
-- use second bnfcode if fail to match on first
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_para_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 10 for 6)||'00'
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;

-- fill in missing values at the bnf section level
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_section_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 1 for 4)||'0000'
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;
-- use second bnfcode if fail to match on first
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_section_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 10 for 4)||'0000'
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;

-- fill in missing values at the bnf chapter level
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_chapter_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 1 for 2)||'000000'
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;
-- use second bnfcode if fail to match on first
INSERT INTO lkup_drug_costs
SELECT p.*, c.nic FROM 
lkup_product p
INNER JOIN
lkup_PCA_chapter_costs_2012 c
ON c.bnfcode = substring(p.bnfcode from 10 for 2)||'000000'
WHERE p.bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
ORDER BY p.bnfcode;

CREATE INDEX drug_costs_prodcode_index ON lkup_drug_costs(prodcode);
CREATE INDEX drug_costs_bnfcode_index ON lkup_drug_costs(bnfcode);

-- summary of uncosted bnf codes
SELECT bnfcode, count(bnfcode) count FROM lkup_product WHERE bnfcode NOT IN
(SELECT bnfcode FROM lkup_drug_costs)
GROUP BY bnfcode ORDER BY count DESC;

select count(distinct(prodcode)) from lkup_drug_costs; 

-- create table to cache therapy costs for faster calculations
DROP TABLE IF EXISTS therapy_cost;
CREATE TABLE therapy_cost AS
SELECT t.therapyid, t.anonpatid, t.eventdate, t.prodcode, d.nic AS cost 
FROM therapy t INNER JOIN lkup_drug_costs d
ON t.prodcode = d.prodcode;
CREATE INDEX therapy_cost_patid_index ON therapy_cost(anonpatid);
CREATE INDEX therapy_cost_eventdate_index ON therapy_cost(eventdate);
ALTER TABLE therapy_cost ADD CONSTRAINT tc_patid FOREIGN KEY (anonpatid) REFERENCES patient(anonpatid);
ALTER TABLE therapy_cost ADD CONSTRAINT tc_therapyid FOREIGN KEY (therapyid) REFERENCES therapy(therapyid);
ALTER TABLE therapy_cost ADD CONSTRAINT tc_prodcode FOREIGN KEY (prodcode) REFERENCES lkup_product(prodcode);

------------------------------------
--- CALCULATE CONSULTATION COSTS ---
------------------------------------

--- load consultation costs taken from Sam Brilleman
DROP TABLE IF EXISTS lkup_consult_costs;
CREATE TABLE lkup_consult_costs(
role_code int,
consult_type_code int,
cost float);

COPY lkup_consult_costs(role_code,consult_type_code,cost) FROM 'C:\CALIBER\Documents\Lookups\consult_costs.csv' DELIMITER ',' CSV HEADER;
CREATE INDEX consult_costs_role_index ON lkup_consult_costs(role_code);
CREATE INDEX consult_costs_constype_index ON lkup_consult_costs(consult_type_code);
ALTER TABLE lkup_consult_costs ADD CONSTRAINT consult_costs_role FOREIGN KEY (role_code) REFERENCES lkup_rol (role_code);
ALTER TABLE lkup_consult_costs ADD CONSTRAINT consult_costs_type FOREIGN KEY (consult_type_code) REFERENCES lkup_cot (consult_type_code);

--- create table to cache consultation costs for faster calculation
DROP TABLE IF EXISTS consultation_cost;
CREATE TABLE consultation_cost AS
SELECT c.consultationid, c.anonpatid, c.constype, s.role, c.staffid, c.eventdate, lc.cost FROM consultation c 
INNER JOIN staff s ON c.staffid = s.staffid
INNER JOIN lkup_consult_costs lc ON s.role = lc.role_code AND c.constype = lc.consult_type_code;
CREATE INDEX consultation_cost_patid_index ON consultation_cost(anonpatid);
CREATE INDEX consultation_cost_eventdate_index ON consultation_cost(eventdate);
ALTER TABLE consultation_cost ADD CONSTRAINT cons_costs_staff FOREIGN KEY (staffid) REFERENCES staff (staffid);
ALTER TABLE consultation_cost ADD CONSTRAINT cons_costs_patid FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
ALTER TABLE consultation_cost ADD CONSTRAINT cons_costs_role FOREIGN KEY (role) REFERENCES lkup_rol (role_code);
ALTER TABLE consultation_cost ADD CONSTRAINT cons_costs_type FOREIGN KEY (constype) REFERENCES lkup_cot (consult_type_code);

--- count consultation type / staff role which combinations to determine which are worth costing
SELECT r.description staff_role, ct.description consultation_type, count(*) num FROM consultation_cost c
INNER JOIN lkup_rol r ON r.role_code = c.role
INNER JOIN lkup_cot ct ON ct.consult_type_code = c.constype
GROUP BY r.description, ct.description ORDER BY num DESC;

----------------------------
--- CALCULATE TEST COSTS ---
----------------------------
DROP TABLE IF EXISTS lkup_test_costs;
CREATE TABLE lkup_test_costs(
enttype int,
cost float);

COPY lkup_test_costs(enttype,cost) FROM 'C:\CALIBER\Documents\Lookups\test_costs.csv' DELIMITER ',' CSV HEADER;
CREATE INDEX test_costs_enttype_index ON lkup_test_costs(enttype);
ALTER TABLE lkup_test_costs ADD CONSTRAINT test_costs_enttype FOREIGN KEY (enttype) REFERENCES lkup_entity (enttype);

--- create table to cache test costs for faster calculation
DROP TABLE IF EXISTS test_cost;
CREATE TABLE test_cost AS
SELECT t.testid, t.anonpatid, t.enttype, t.eventdate, tc.cost FROM test t
INNER JOIN lkup_test_costs tc ON t.enttype = tc.enttype;
CREATE INDEX test_cost_patid_index ON test_cost(anonpatid);
CREATE INDEX test_cost_eventdate_index ON test_cost(eventdate);
ALTER TABLE test_cost ADD CONSTRAINT test_cost_patid FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
ALTER TABLE test_cost ADD CONSTRAINT test_cost_testid FOREIGN KEY (testid) REFERENCES test (testid);
ALTER TABLE test_cost ADD CONSTRAINT test_cost_entity FOREIGN KEY (enttype) REFERENCES lkup_entity (enttype);

DROP TABLE IF EXISTS lkup_test_costs_cat;
CREATE TABLE lkup_test_costs_cat(
category varchar,
cost float);

COPY lkup_test_costs_cat(category,cost) FROM 'C:\CALIBER\Documents\Lookups\test_costs_category.csv' DELIMITER ',' CSV HEADER;
CREATE INDEX test_costs_category_index ON lkup_test_costs_cat(category);

--- create table to cache test costs for faster calculation
DROP TABLE IF EXISTS test_cost_cat;
CREATE TABLE test_cost_cat AS
SELECT t.testid, t.anonpatid, t.enttype, e.category, t.eventdate, tc.cost FROM test t
INNER JOIN lkup_entity e ON t.enttype = e.enttype
INNER JOIN lkup_test_costs_cat tc ON e.category = tc.category;
CREATE INDEX test_cost_cat_patid_index ON test_cost_cat(anonpatid);
CREATE INDEX test_cost_cat_eventdate_index ON test_cost_cat(eventdate);
ALTER TABLE test_cost_cat ADD CONSTRAINT test_cost_cat_patid FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
ALTER TABLE test_cost_cat ADD CONSTRAINT test_cost_cat_testid FOREIGN KEY (testid) REFERENCES test (testid);
ALTER TABLE test_cost_cat ADD CONSTRAINT test_cost_cat_entity FOREIGN KEY (enttype) REFERENCES lkup_entity (enttype);

--- count which tests are most frequent to prioritise which to get correct costs against
SELECT tc.enttype, le.description, tc.category, count(*) num FROM test_cost_cat tc 
INNER JOIN lkup_entity le ON tc.enttype = le.enttype 
GROUP BY tc.enttype, le.description, tc.category ORDER BY num DESC;


