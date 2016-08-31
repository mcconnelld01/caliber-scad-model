--- GPRD Lookup Tables
DROP TABLE IF EXISTS lkup_entity;
CREATE TABLE lkup_entity(
enttype int primary key,
description varchar,
filetype varchar,
category varchar,
data_fields int, 
data1 varchar,
data1_lkup varchar,
data2 varchar,
data2_lkup varchar,
data3 varchar,
data3_lkup varchar,
data4 varchar,
data4_lkup varchar,
data5 varchar,
data5_lkup varchar,
data6 varchar,
data6_lkup varchar,
data7 varchar,
data7_lkup varchar,
data8 varchar,
data8_lkup varchar);

COPY lkup_entity(enttype,description,filetype,category,data_fields,data1,data1_lkup,data2,data2_lkup,data3,data3_lkup,data4,data4_lkup,data5,data5_lkup,data6,data6_lkup,data7,data7_lkup,data8,data8_lkup) FROM 'C:\CALIBER\Documents\Lookups\Entity.csv' DELIMITER ',' CSV HEADER;
CREATE INDEX entity_enttype_index ON lkup_entity(enttype);
CREATE INDEX entity_cat_index ON lkup_entity(category);


DROP TABLE IF EXISTS lkup_bnf CASCADE;
CREATE TABLE lkup_bnf(
bnfcode int primary key,
bnf varchar);

COPY lkup_bnf(bnfcode, bnf) FROM 'C:\CALIBER\Documents\Lookups\bnfcodes.csv' DELIMITER ',' CSV HEADER;

-- update reformat bnfcodes into standard 8 character format 
UPDATE lkup_bnf SET bnf = CASE WHEN char_length(bnf)=7 THEN '0'||bnf ELSE bnf END;

DROP TABLE IF EXISTS lkup_common_dosages;
CREATE TABLE lkup_common_dosages(
textid int primary key,
text varchar,
daily_dose float,
dose_number float,
dose_unit varchar,
dose_frequency float,
dose_interval float,
choice_of_dose int,
dose_max_average int,
change_dose int,
dose_duration float
);

COPY lkup_common_dosages(textid,text,daily_dose,dose_number,dose_unit,dose_frequency,dose_interval,choice_of_dose,dose_max_average,change_dose,dose_duration) FROM 'C:\CALIBER\Documents\Lookups\common_dosages.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS lkup_icd;
CREATE TABLE lkup_icd(
icdcode varchar primary key,
description varchar);

COPY lkup_icd(icdcode, description) FROM 'C:\CALIBER\Documents\Lookups\icd.txt' DELIMITER E'\t';


DROP TABLE IF EXISTS lkup_medical;
CREATE TABLE lkup_medical(
medcode int primary key,
readcode varchar,
description varchar);

COPY lkup_medical(medcode,readcode,description) FROM 'C:\CALIBER\Documents\Lookups\medical.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX lkup_medical_readcode_index ON lkup_medical(readcode);


DROP TABLE IF EXISTS lkup_packtype;
CREATE TABLE lkup_packtype(
packtype int primary key,
description varchar);

COPY lkup_packtype(packtype,description) FROM 'C:\CALIBER\Documents\Lookups\packtype.csv' DELIMITER ',' CSV HEADER;


DROP TABLE IF EXISTS lkup_product;
CREATE TABLE lkup_product(
prodcode int primary key,
multilexcode varchar,
productname varchar,
drugsubstance varchar,
strength varchar,
formulation varchar,
route varchar,
bnfcode varchar,
bnfchapter varchar 
);

COPY lkup_product(prodcode,multilexcode,productname,drugsubstance,strength,formulation,route,bnfcode,bnfchapter) FROM 'C:\CALIBER\Documents\Lookups\product.csv' DELIMITER ',' CSV HEADER;

-- update reformat bnfcodes into standard 8 character format 
UPDATE lkup_product SET bnfcode = CASE WHEN char_length(bnfcode)=7 THEN '0'||bnfcode ELSE bnfcode END;

DROP TABLE IF EXISTS lkup_scoremethod;
CREATE TABLE lkup_scoremethod(
code int primary key,
scoringmethod varchar);

COPY lkup_scoremethod(code,scoringmethod) FROM 'C:\CALIBER\Documents\Lookups\scoremethod.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS lkup_rol;
CREATE TABLE lkup_rol(
role_code int primary key,
description varchar);

COPY lkup_rol(role_code, description) FROM 'C:\CALIBER\Documents\Lookups\ROL.txt';

DROP TABLE IF EXISTS lkup_cot;
CREATE TABLE lkup_cot(
consult_type_code int primary key,
description varchar);

COPY lkup_cot(consult_type_code, description) FROM 'C:\CALIBER\Documents\Lookups\COT.txt';

DROP TABLE IF EXISTS lkup_sed;
CREATE TABLE lkup_sed(
sed_code int primary key,
description varchar);

COPY lkup_sed(sed_code, description) FROM 'C:\CALIBER\Documents\Lookups\SED.txt';

DROP TABLE IF EXISTS lkup_epi;
CREATE TABLE lkup_epi(
epi_code int primary key,
description varchar);

COPY lkup_epi(epi_code, description) FROM 'C:\CALIBER\Documents\Lookups\EPI.txt';


--- GPRD Staff Table

DROP TABLE IF EXISTS staff;
CREATE TABLE staff(
staffid int primary key,
gender int,
role int
);

COPY staff(staffid,gender,role) FROM 'C:\CALIBER\1_RawData\staff.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX staff_staffid_index ON staff(staffid);
CREATE INDEX staff_role_index ON staff(role);
CLUSTER staff USING staff_staffid_index;
ALTER TABLE staff ADD CONSTRAINT staff_role FOREIGN KEY (role) REFERENCES lkup_rol (role_code);

--- GPRD Patient Table

DROP TABLE IF EXISTS patient;
CREATE TABLE patient(
anonpatid int primary key,
pracid int,
pracregion int,
pracuts date,
praclcd date,
frd date,
crd date,
tod date,
deathdate date,
toreason int,
gender int,
year_of_birth int,
in_hes_source int,
hes_start date,
hes_end date,
hes_ethnicity varchar,
in_hes int);

COPY patient(anonpatid,pracid,pracregion,pracuts,praclcd,frd,crd,tod,deathdate,toreason,gender,year_of_birth,in_hes_source,hes_start,hes_end,hes_ethnicity,in_hes) FROM 'C:\CALIBER\1_RawData\patients.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX patient_patid_index ON patient(anonpatid);
CLUSTER patient USING patient_patid_index;

--- GPRD Consultation Table

DROP TABLE IF EXISTS consultation;
CREATE TABLE consultation(
consultationid serial primary key,
anonpatid int,
eventdate date,
"sysdate" date,
constype int,
consid int,
staffid int,
duration int
);

COPY consultation(anonpatid,eventdate,sysdate,constype,consid,staffid,duration) FROM 'C:\CALIBER\1_RawData\consultation.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX consultation_patid_index ON consultation(anonpatid);
CREATE INDEX consultation_staffid_index ON consultation(staffid);
CREATE INDEX consultation_eventdate_index ON consultation(eventdate);
CREATE INDEX consultation_constype_index ON consultation(constype);
CLUSTER consultation USING consultation_patid_index;
ALTER TABLE consultation ADD CONSTRAINT consultation_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
UPDATE consultation SET staffid=NULL WHERE staffid=0;
ALTER TABLE consultation ADD CONSTRAINT consultation_staff FOREIGN KEY (staffid) REFERENCES staff (staffid);
ALTER TABLE consultation ADD CONSTRAINT consultation_constype FOREIGN KEY (constype) REFERENCES lkup_cot (consult_type_code);

--- GPRD Clinical Table

DROP TABLE IF EXISTS clinical;
CREATE TABLE clinical(
clinicalid serial primary key,
anonpatid int,
eventdate date,
"sysdate" date,
constype int,
consid int,
medcode int,
staffid int,
textid int,
episode int,
enttype int,
adid int,
data1 varchar,
data2 varchar,
data3 varchar,
data4 varchar,
data5 varchar,
data6 varchar,
data7 varchar
);

COPY clinical(anonpatid,eventdate,sysdate,constype,consid,medcode,staffid,textid,episode,enttype,adid,data1,data2,data3,data4,data5,data6,data7) FROM 'C:\CALIBER\1_RawData\clinical.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX clinical_patid_index ON clinical(anonpatid);
CREATE INDEX clinical_medcode_index ON clinical(medcode);
CREATE INDEX clinical_enttype_index ON clinical(enttype);
CREATE INDEX clinical_staffid_index ON clinical(staffid);
CREATE INDEX clinical_episode_index ON clinical(episode);
CLUSTER clinical USING clinical_patid_index;
ALTER TABLE clinical ADD CONSTRAINT clinical_entity FOREIGN KEY (enttype) REFERENCES lkup_entity (enttype);
ALTER TABLE clinical ADD CONSTRAINT clinical_medical FOREIGN KEY (medcode) REFERENCES lkup_medical (medcode);
ALTER TABLE clinical ADD CONSTRAINT clinical_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
UPDATE clinical SET staffid=NULL WHERE staffid=0;
ALTER TABLE clinical ADD CONSTRAINT clinical_staff FOREIGN KEY (staffid) REFERENCES staff (staffid);
ALTER TABLE clinical ADD CONSTRAINT clinical_constype FOREIGN KEY (constype) REFERENCES lkup_sed (sed_code);
UPDATE clinical SET episode = 0 WHERE episode > 4;
ALTER TABLE clinical ADD CONSTRAINT clinical_episode FOREIGN KEY (episode) REFERENCES lkup_epi (epi_code);

--- GPRD Test Table

DROP TABLE IF EXISTS test;
CREATE TABLE test(
testid SERIAL primary key,
anonpatid int,
eventdate date,
sysdate date,
constype int,
consid int,
medcode int,
staffid int,
textid int,
enttype int,
data1 varchar,
data2 varchar,
data3 varchar,
data4 varchar,
data6 varchar,
data7 varchar
);

COPY test(anonpatid,eventdate,sysdate,constype,consid,medcode,staffid,textid,enttype,data1,data2,data3,data4,data6,data7) FROM 'C:\CALIBER\1_RawData\test.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX test_patid_index ON test(anonpatid);
CREATE INDEX test_medcode_index ON test(medcode);
CREATE INDEX test_enttype_index ON test(enttype);
CREATE INDEX test_staffid_index ON test(staffid);
CLUSTER test USING test_patid_index;
ALTER TABLE test ADD CONSTRAINT test_entity FOREIGN KEY (enttype) REFERENCES lkup_entity (enttype);
ALTER TABLE test ADD CONSTRAINT test_medical FOREIGN KEY (medcode) REFERENCES lkup_medical (medcode);
ALTER TABLE test ADD CONSTRAINT test_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
UPDATE test SET staffid=NULL WHERE staffid=0;
ALTER TABLE test ADD CONSTRAINT test_staff FOREIGN KEY (staffid) REFERENCES staff (staffid);
ALTER TABLE test ADD CONSTRAINT test_constype FOREIGN KEY (constype) REFERENCES lkup_sed (sed_code);

-- GPRD Therapy Table

DROP TABLE IF EXISTS therapy;
CREATE TABLE therapy(
therapyid serial primary key,
anonpatid int,
eventdate date,
"sysdate" date,
consid int,
prodcode int,
staffid int,
textid int,
bnfcode int,
qty float,
ndd float,
numdays int,
numpacks int,
packtype int,
issueseq int
);

COPY therapy(anonpatid,eventdate,sysdate,consid,prodcode,staffid,textid,bnfcode,qty,ndd,numdays,numpacks,packtype,issueseq) FROM 'C:\CALIBER\1_RawData\therapy.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX therapy_patid_index ON therapy(anonpatid);
CREATE INDEX therapy_bnfcode_index ON therapy(bnfcode);
CREATE INDEX therapy_prodcode_index ON therapy(prodcode);
CREATE INDEX therapy_consid_index ON therapy(consid);
CREATE INDEX therapy_packtype_index ON therapy(packtype);
CREATE INDEX therapy_textid_index ON therapy(textid);
CREATE INDEX therapy_staffid_index ON therapy(staffid);
CLUSTER therapy USING therapy_patid_index;

UPDATE therapy SET bnfcode=NULL WHERE bnfcode=0;
ALTER TABLE therapy ADD CONSTRAINT therapy_bnf FOREIGN KEY (bnfcode) REFERENCES lkup_bnf (bnfcode);
--UPDATE therapy SET textid=NULL WHERE textid=0;
--ALTER TABLE therapy ADD CONSTRAINT therapy_dosage FOREIGN KEY (textid) REFERENCES lkup_common_dosages (textid);
--UPDATE therapy SET packtype=NULL WHERE packtype=0;
--ALTER TABLE therapy ADD CONSTRAINT therapy_packtype FOREIGN KEY (packtype) REFERENCES lkup_packtype (packtype);
ALTER TABLE therapy ADD CONSTRAINT therapy_product FOREIGN KEY (prodcode) REFERENCES lkup_product (prodcode);
ALTER TABLE therapy ADD CONSTRAINT therapy_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
UPDATE therapy SET staffid=NULL WHERE staffid=0;
ALTER TABLE therapy ADD CONSTRAINT therapy_staff FOREIGN KEY (staffid) REFERENCES staff (staffid);

--- GPRD HES Tables

DROP TABLE IF EXISTS hes_episode;
CREATE TABLE hes_episode(
hes_episode_id SERIAL primary key,
anonpatid int,
spno int,
epikey int,
admidate date,
epistart date,
epiend date,
discharged date,
eorder int,
epidur int,
epitype int,
admimeth int,
admisorc int,
disdest int,
dismeth int,
mainspef int,
tretspef int,
pconsult varchar,
intmanig int,
classpat int,
firstreg int
);

COPY hes_episode(anonpatid,spno,epikey,admidate,epistart,epiend,discharged,eorder,epidur,epitype,admimeth,admisorc,disdest,dismeth,mainspef,tretspef,pconsult,intmanig,classpat,firstreg) FROM 'C:\CALIBER\1_RawData\hes_episodes.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX hes_episode_patid_index ON hes_episode(anonpatid);
CREATE INDEX hes_episode_spno_index ON hes_episode(spno);
CLUSTER hes_episode USING hes_episode_patid_index;

ALTER TABLE hes_episode ADD CONSTRAINT hes_episode_pkey PRIMARY KEY (anonpatid,epikey,eorder);
ALTER TABLE hes_episode ADD CONSTRAINT hes_episode_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);


DROP TABLE IF EXISTS hes_procedure;
CREATE TABLE hes_procedure(
hes_procedure_id SERIAL primary key,
anonpatid int,
spno int,
epikey int,
admidate date,
epistart date,
epiend date,
discharged date,
opcs varchar,
evdate date
);

COPY hes_procedure(anonpatid,spno,epikey,admidate,epistart,epiend,discharged,opcs,evdate) FROM 'C:\CALIBER\1_RawData\hes_procedures.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX hes_procedure_patid_index ON hes_procedure(anonpatid);
CREATE INDEX hes_procedure_spno_index ON hes_procedure(spno);
CREATE INDEX hes_procedure_opcs_index ON hes_procedure(opcs);
CLUSTER hes_procedure USING hes_procedure_patid_index;

ALTER TABLE hes_procedure ADD CONSTRAINT hes_procedure_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
--ALTER TABLE hes_procedure ADD CONSTRAINT hes_procedure_episode FOREIGN KEY (epikey) REFERENCES hes_episode (epikey);


DROP TABLE IF EXISTS hes_hospital;
CREATE TABLE hes_hospital(
hes_hospital_id SERIAL,
anonpatid int,
spno int,
admidate date,
discharged date,
admimeth int,
admisorc int,
disdest int,
dismeth int,
duration int,
elecdate date,
elecdur int
);

COPY hes_hospital(anonpatid,spno,admidate,discharged,admimeth,admisorc,disdest,dismeth,duration,elecdate,elecdur) FROM 'C:\CALIBER\1_RawData\hes_hospital.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX hes_hospital_patid_index ON hes_hospital(anonpatid);
CREATE INDEX hes_hospital_spno_index ON hes_hospital(spno);
CLUSTER hes_hospital USING hes_hospital_patid_index;

ALTER TABLE hes_hospital ADD CONSTRAINT hes_hospital_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);


DROP TABLE IF EXISTS hes_diag_epi;
CREATE TABLE hes_diag_epi(
hes_diag_epi_id SERIAL primary key,
anonpatid int,
spno int,
epikey int,
epistart date,
epiend date,
icd varchar,
primary_epi int
);

COPY hes_diag_epi(anonpatid,spno,epikey,epistart,epiend,icd,primary_epi) FROM 'C:\CALIBER\1_RawData\hes_diag_epi.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX hes_diag_epi_patid_index ON hes_diag_epi(anonpatid);
CREATE INDEX hes_diag_epi_spno_index ON hes_diag_epi(spno);
CREATE INDEX hes_diag_epi_icd_index ON hes_diag_epi(icd);
CLUSTER hes_diag_epi USING hes_diag_epi_patid_index;

ALTER TABLE hes_diag_epi ADD CONSTRAINT hes_diag_epi_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
--ALTER TABLE hes_diag_epi ADD CONSTRAINT hes_diag_epi_icd FOREIGN KEY (icd) REFERENCES lkup_icd (icdcode);
--ALTER TABLE hes_diag_epi ADD CONSTRAINT hes_diag_epi_episode FOREIGN KEY (epikey) REFERENCES hes_episode (epikey);


DROP TABLE IF EXISTS hes_diag_hosp;
CREATE TABLE hes_diag_hosp(
hes_diag_hosp_id SERIAL primary key,
anonpatid int,
spno int,
admidate date,
discharged date,
icd varchar
);

COPY hes_diag_hosp(anonpatid,spno,admidate,discharged,icd) FROM 'C:\CALIBER\1_RawData\hes_diag_hosp.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX hes_diag_hosp_patid_index ON hes_diag_hosp(anonpatid);
CREATE INDEX hes_diag_hosp_spno_index ON hes_diag_hosp(spno);
CREATE INDEX hes_diag_hosp_icd_index ON hes_diag_hosp(icd);
CLUSTER hes_diag_hosp USING hes_diag_hosp_patid_index;

ALTER TABLE hes_diag_hosp ADD CONSTRAINT hes_diag_hosp_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
--ALTER TABLE hes_diag_hosp ADD CONSTRAINT hes_diag_hosp_icd FOREIGN KEY (icd) REFERENCES lkup_icd (icdcode);


DROP TABLE IF EXISTS hes_primary_diag_hosp;
CREATE TABLE hes_primary_diag_hosp(
hes_primary_diag_hosp_id SERIAL primary key,
anonpatid int,
spno int,
admidate date,
discharged date,
primary_icd varchar
);

COPY hes_primary_diag_hosp(anonpatid,spno,admidate,discharged,primary_icd) FROM 'C:\CALIBER\1_RawData\hes_primary_diag_hosp.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX hes_primary_diag_hosp_patid_index ON hes_primary_diag_hosp(anonpatid);
CREATE INDEX hes_primary_diag_hosp_spno_index ON hes_primary_diag_hosp(spno);
CREATE INDEX hes_primary_diag_hosp_primary_icd_index ON hes_primary_diag_hosp(primary_icd);
CLUSTER hes_primary_diag_hosp USING hes_primary_diag_hosp_patid_index;

ALTER TABLE hes_primary_diag_hosp ADD CONSTRAINT hes_diag_primary_hosp_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);
--ALTER TABLE hes_primary_diag_hosp ADD CONSTRAINT hes_primary_diag_hosp_icd FOREIGN KEY (primary_icd) REFERENCES lkup_icd (icdcode);

--- MINAP Table

DROP TABLE IF EXISTS minap;
CREATE TABLE minap(
minapid serial primary key,
anonpatid int,
id_hospital varchar,
id_hospital_rec varchar,
id_nhs_number varchar,
gender int,
age float,
admin_status int,
ethnicity int,
EthnicGroupV6 varchar,
admission_diagnosis int,
admission_method int,
ecg_determ_treatment int,
admission_antiplatelet int,
history_ami int,
history_angina int,
hypertension int,
hypercholesterolaemia int,
peripheral_vd int,
cvd int,
asthma int,
renal_failure int,
heart_failure int,
cardiac_markers_raised int,
smoking_status int,
diabetes int,
history_pci int,
history_cabg int,
admission_consultant int,
admission_ecg int,
prior_bblocker int,
prior_acei int,
prior_statin int,
prior_thienopyridin int,
leftventricularejectionfraction int,
family_history int,
cardiological_care int,
site_of_infarction int,
reason_reperf_not_given int,
delay_before_treatment int,
initial_reperf_location int,
initial_reperf_decision int,
serum_glucose float,
serum_cholesterol float,
creatinine float,
haemoglobin float,
height float,
weight float,
bp_systolic float,
heart_rate float,
peaktroponin float,
date_symptom_onset date, 
date_call_help date,
date_arrival_help date,
date_arrival_services date,
date_admission date,
date_reperfusion date,
date_arrest date,
cardiac_arrest_location varchar,
arrest_presenting_rhythm int,
outcome_of_arrest int,
admission_ward int,
peak_creatinine_kinase float,
heparin_unfr int,
heparin_lmw int,
thienopyridine_pi int,
other_oral_antiplatelet int,
_2b_3a_iv int,
bblocker_iv int,
calcium_cb int,
nitrate_iv int,
nitrate_oral int,
pcm int,
warfarin int,
angiotensin_ii_blocker int,
diuretic_thiazide int,
diuretic_loop int,
spironolactone int,
thrombolytic_drug int,
troponin_assay int,
fondaparinux int,
init_reperf_treatment int,
additional_reperfusion_treatment int,
WasReperfusionAttemptedV6 varchar,
inpatient_diabetes_mgmt int,
discharge_diabetic int,
date_discharge date,
discharge_diagnosis int,
bleeding_complications int,
death_in_hospital int,
discharge_bblocker int,
discharge_angiotensin int,
discharge_statin int,
discharge_antiplatelet int,
discharge_clopidogrel int,
cardiac_rehab int,
execg int,
echocardiography int,
radionuclide int,
coronary_angio int,
coronary_intervention int,
date_referral_inv date,
discharge_destination int,
date_daycase_transfer date,
date_local_angio date,
date_first_local_intervention date,
date_return_referral date,
followed_up_by int,
reinfarction int,
IMDScore float,
HealthScore float,
InPatientCareDIGAMI varchar,
RecommendedTherapyAtDischarge varchar,
date_death_discharge date,
life_status int,
date_census_death date);

COPY minap(anonpatid,id_hospital,id_hospital_rec,id_nhs_number,gender,age,admin_status,ethnicity,EthnicGroupV6,admission_diagnosis,admission_method,ecg_determ_treatment,admission_antiplatelet,history_ami,history_angina,hypertension,hypercholesterolaemia,peripheral_vd,cvd,asthma,renal_failure,heart_failure,cardiac_markers_raised,smoking_status,diabetes,history_pci,history_cabg,admission_consultant,admission_ecg,prior_bblocker,prior_acei,prior_statin,prior_thienopyridin,leftventricularejectionfraction,family_history,cardiological_care,site_of_infarction,reason_reperf_not_given,delay_before_treatment,initial_reperf_location,initial_reperf_decision,serum_glucose,serum_cholesterol,creatinine,haemoglobin,height,weight,bp_systolic,heart_rate,peaktroponin,date_symptom_onset,date_call_help,date_arrival_help,date_arrival_services,date_admission,date_reperfusion,date_arrest,cardiac_arrest_location,arrest_presenting_rhythm,outcome_of_arrest,admission_ward,peak_creatinine_kinase,heparin_unfr,heparin_lmw,thienopyridine_pi,other_oral_antiplatelet,_2b_3a_iv,bblocker_iv,calcium_cb,nitrate_iv,nitrate_oral,pcm,warfarin,angiotensin_ii_blocker,diuretic_thiazide,diuretic_loop,spironolactone,thrombolytic_drug,troponin_assay,fondaparinux,init_reperf_treatment,additional_reperfusion_treatment,WasReperfusionAttemptedV6,inpatient_diabetes_mgmt,discharge_diabetic,date_discharge,discharge_diagnosis,bleeding_complications,death_in_hospital,discharge_bblocker,discharge_angiotensin,discharge_statin,discharge_antiplatelet,discharge_clopidogrel,cardiac_rehab,execg,echocardiography,radionuclide,coronary_angio,coronary_intervention,date_referral_inv,discharge_destination,date_daycase_transfer,date_local_angio,date_first_local_intervention,date_return_referral,followed_up_by,reinfarction,IMDScore,HealthScore,InPatientCareDIGAMI,RecommendedTherapyAtDischarge,date_death_discharge,life_status,date_census_death) FROM 'C:\CALIBER\1_RawData\minap.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX minap_patid_index ON minap(anonpatid);
CLUSTER minap USING minap_patid_index;

ALTER TABLE minap ADD CONSTRAINT minap_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);


--- ONS Mortality Table

DROP TABLE IF EXISTS ONS;
CREATE TABLE ONS(
onsid serial primary key,
anonpatid int,
dod date,
cod varchar,
cod_1 varchar,
cod_2 varchar,
cod_3 varchar,
cod_4 varchar,
cod_5 varchar,
cod_6 varchar,
cod_7 varchar,
cod_8 varchar,
cod_9 varchar,
cod_10 varchar,
cod_11 varchar,
cod_12 varchar,
cod_13 varchar,
cod_14 varchar,
cod_15 varchar);

COPY ONS(anonpatid,dod,cod,cod_1,cod_2,cod_3,cod_4,cod_5,cod_6,cod_7,cod_8,cod_9,cod_10,cod_11,cod_12,cod_13,cod_14,cod_15) FROM 'C:\CALIBER\1_RawData\ons.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX ons_patid_index ON ONS(anonpatid);
CLUSTER ONS USING ons_patid_index;

ALTER TABLE ONS ADD CONSTRAINT ons_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);


--- CALIBER Patient Cohort

DROP TABLE IF EXISTS SCAD_cohort;
CREATE TABLE SCAD_cohort(
SCAD_id SERIAL primary key,
caliber_id float,
anonpatid int,
date_entry date,
date_exit date,
dxSCAD_date date,
dxSCAD_type varchar,
age int,
sex boolean,
ethnos varchar,
BMI float,
SMOKING varchar,
IMD_SCORE float,
HDL float,
LDL float,
TCHOL float,
HEART_RATE int,
SBP float,
DBP float,
creatinine float,
haemoglobin float,
white_cell_count float,
CRP float,
DIABETIC boolean,
daysToCABG_fromDx int,
daysToPCI_fromDx int,
statins_atDx boolean,
BPdrugs_atDx boolean,
histOf_HF boolean,
histOf_stroke boolean,
histOf_atrialFib boolean,
histOf_PAD boolean,
histOf_MI boolean,
CHD_event boolean,
CVD_event boolean,
CENSOR_DATE date,
timeToCHD_event float);

COPY SCAD_cohort(caliber_id,anonpatid,date_entry,date_exit,dxSCAD_date,dxSCAD_type,age,sex,ethnos,BMI,SMOKING,IMD_SCORE,HDL,LDL,TCHOL,HEART_RATE,SBP,DBP,creatinine,haemoglobin,white_cell_count,CRP,DIABETIC,daysToCABG_fromDx,daysToPCI_fromDx,statins_atDx,BPdrugs_atDx,histOf_HF,histOf_stroke,histOf_atrialFib,histOf_PAD,histOf_MI,CHD_event,CVD_event,CENSOR_DATE,timeToCHD_event) FROM 'C:\CALIBER\2_Cohort\SCAD_cohort.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX SCAD_cohort_patid_index ON SCAD_cohort(anonpatid);

ALTER TABLE SCAD_cohort ADD CONSTRAINT SCAD_cohort_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);


--- CALIBER Defined Variables

DROP TABLE IF EXISTS var_SMst;
CREATE TABLE var_SMst(
SMst_id SERIAL primary key,
anonpatid int,
eventdate date,
SMst varchar
);

COPY var_SMst(anonpatid,eventdate,SMst) FROM 'C:\CALIBER\3_Variables\SMst.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_SMst_patid_index ON var_SMst(anonpatid);
CLUSTER var_SMst USING var_SMst_patid_index;

DROP TABLE IF EXISTS var_bp;
CREATE TABLE var_bp(
bp_id SERIAL primary key,
anonpatid int,
eventdate date,
diastolic float,
systolic float
);

COPY var_bp(anonpatid,eventdate,diastolic,systolic) FROM 'C:\CALIBER\3_Variables\bp.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_bp_patid_index ON var_bp(anonpatid);
CLUSTER var_bp USING var_bp_patid_index;

DROP TABLE IF EXISTS var_cabg;
CREATE TABLE var_cabg(
cabg_id SERIAL primary key,
anonpatid int,
eventdate date,
source varchar
);

COPY var_cabg(anonpatid,eventdate,source) FROM 'C:\CALIBER\3_Variables\cabg.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_cabg_patid_index ON var_cabg(anonpatid);
CLUSTER var_cabg USING var_cabg_patid_index;

DROP TABLE IF EXISTS var_crea;
CREATE TABLE var_crea(
crea_id SERIAL primary key,
anonpatid int,
eventdate date,
operator varchar,
value float,
units varchar);

COPY var_crea(anonpatid,eventdate,operator,value,units) FROM 'C:\CALIBER\3_Variables\crea.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_crea_patid_index ON var_crea(anonpatid);
CLUSTER var_crea USING var_crea_patid_index;

DROP TABLE IF EXISTS var_hb;
CREATE TABLE var_hb(
hb_id SERIAL primary key,
anonpatid int,
eventdate date,
operator varchar,
value float,
units varchar,
orig float);

COPY var_hb(anonpatid,eventdate,operator,value,units,orig) FROM 'C:\CALIBER\3_Variables\hb.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_hb_patid_index ON var_hb(anonpatid);
CLUSTER var_hb USING var_hb_patid_index;

DROP TABLE IF EXISTS var_hdl;
CREATE TABLE var_hdl(
hdl_id SERIAL primary key,
anonpatid int,
eventdate date,
operator varchar,
value float,
units varchar);

COPY var_hdl(anonpatid,eventdate,operator,value,units) FROM 'C:\CALIBER\3_Variables\hdl.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_hdl_patid_index ON var_hdl(anonpatid);
CLUSTER var_hdl USING var_hdl_patid_index;

DROP TABLE IF EXISTS var_ldl;
CREATE TABLE var_ldl(
ldl_id SERIAL primary key,
anonpatid int,
eventdate date,
operator varchar,
value float,
units varchar);

COPY var_ldl(anonpatid,eventdate,operator,value,units) FROM 'C:\CALIBER\3_Variables\ldl.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_ldl_patid_index ON var_ldl(anonpatid);
CLUSTER var_ldl USING var_ldl_patid_index;

DROP TABLE IF EXISTS var_mi;
CREATE TABLE var_mi(
mi_id SERIAL primary key,
anonpatid int,
eventdate date,
category varchar,
source varchar,
mitype varchar);

COPY var_mi(anonpatid,eventdate,category,source,mitype) FROM 'C:\CALIBER\3_Variables\mi.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_mi_patid_index ON var_mi(anonpatid);
CLUSTER var_mi USING var_mi_patid_index;

DROP TABLE IF EXISTS var_pci;
CREATE TABLE var_pci(
pci_id SERIAL primary key,
anonpatid int,
eventdate date,
source varchar
);

COPY var_pci(anonpatid,eventdate,source) FROM 'C:\CALIBER\3_Variables\pci.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_pci_patid_index ON var_pci(anonpatid);
CLUSTER var_pci USING var_pci_patid_index;

DROP TABLE IF EXISTS var_usa;
CREATE TABLE var_usa(
usa_id SERIAL primary key,
anonpatid int,
eventdate date,
source varchar
);

COPY var_usa(anonpatid,eventdate,source) FROM 'C:\CALIBER\3_Variables\usa.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_usa_patid_index ON var_usa(anonpatid);
CLUSTER var_usa USING var_usa_patid_index;

DROP TABLE IF EXISTS var_wbc;
CREATE TABLE var_wbc(
wbc_id SERIAL primary key,
anonpatid int,
eventdate date,
operator varchar,
value float,
units varchar);

COPY var_wbc(anonpatid,eventdate,operator,value,units) FROM 'C:\CALIBER\3_Variables\wbc.csv' DELIMITER ',' CSV HEADER;

CREATE INDEX var_wbc_patid_index ON var_wbc(anonpatid);
CLUSTER var_wbc USING var_wbc_patid_index;


--- Add foreign keys

ALTER TABLE var_SMst ADD CONSTRAINT var_SMst_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_bp ADD CONSTRAINT var_bp_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_cabg ADD CONSTRAINT var_cabg_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_crea ADD CONSTRAINT var_crea_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_hb ADD CONSTRAINT var_hb_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_hdl ADD CONSTRAINT var_hdl_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_ldl ADD CONSTRAINT var_ldl_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_mi ADD CONSTRAINT var_mi_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_pci ADD CONSTRAINT var_pci_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_usa ADD CONSTRAINT var_usa_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);

ALTER TABLE var_wbc ADD CONSTRAINT var_wbc_patient FOREIGN KEY (anonpatid) REFERENCES patient (anonpatid);


ANALYZE VERBOSE;