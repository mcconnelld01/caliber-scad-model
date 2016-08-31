-- Generated: 2013-07-08 11:47:29
   DROP TABLE IF EXISTS cal_copd_exac_gprd;

   CREATE TABLE cal_copd_exac_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 1446,7884,28743,29669,312,5978,11072,21145,11101,9043,43362,21492,49794,31886,93153,29273,48593,64890,65916,1382,24800,20198,41137,2581,68,9389,29166,22795,30653,24316,16287,19400,29457,148,17359,11150,40159,73100 );

   CREATE INDEX cal_copd_exac_gprdanonpatid ON cal_copd_exac_gprd( anonpatid );

   ALTER TABLE cal_copd_exac_gprd ADD COLUMN copd_exac_gprd INT DEFAULT NULL;

UPDATE cal_copd_exac_gprd SET copd_exac_gprd = '1' WHERE medcode IN ( 7884,1446 );
UPDATE cal_copd_exac_gprd SET copd_exac_gprd = '2' WHERE medcode IN ( 40159,24316,68,17359,21145,1382,11072,49794,73100,43362,11150,29273,5978,31886,29457,148,24800,29166,28743,2581,21492,20198,30653,22795,48593,9043,65916,9389,19400,11101,41137,29669,312,16287,64890,93153 );



-- Generated: 2013-06-26 08:52:12
   DROP TABLE IF EXISTS cal_copd_gprd;

   CREATE TABLE cal_copd_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 4519,10403,19434,45770,42313,19721,50396,71370,55391,4899,7092,3163,1934,152,3480,25603,15626,61118,37959,61513,27819,5798,5909,24248,66043,45089,68066,92955,70787,59263,63479,12166,22905,54893,9520,37371,18621,11287,26018,45998,18792,28755,34202,34215,1001,998,3243,14798,44525,15157,794,26306,56860,68662,60188,23492,46578,10980,40788,16410,33450,10863,10802,9876,93568,67040,5710,37247,66058,65733,28743,29669,312,5978,11072,21145,11101,9043,43362,21492,49794,31886,93153,29273,48593,64890,65916,1382,24800,20198,41137,2581,68,9389,29166,22795,30653,24316,16287,19400,29457,148,17359,11150,40159,73100,1446,7884,45777,42258,38074 );

   CREATE INDEX cal_copd_gprdanonpatid ON cal_copd_gprd( anonpatid );

   ALTER TABLE cal_copd_gprd ADD COLUMN copd_gprd INT DEFAULT NULL;

UPDATE cal_copd_gprd SET copd_gprd = '2' WHERE medcode IN ( 66043,7092,92955,10403,27819,59263,24248,3163,37959,4899,4519,3480,12166,54893,63479,71370,152,45770,42313,61118,55391,1934,15626,70787,19721,22905,45089,61513,68066,50396,5798,5909,25603,19434 );
UPDATE cal_copd_gprd SET copd_gprd = '3' WHERE medcode IN ( 67040,56860,794,34202,9520,40788,3243,9876,37247,60188,998,65733,15157,37371,68662,1001,14798,26306,10802,11287,33450,5710,45998,34215,66058,10863,18621,46578,93568,44525,18792,26018,28755,10980,16410,23492 );
UPDATE cal_copd_gprd SET copd_gprd = '4' WHERE medcode IN ( 40159,24316,68,17359,21145,1382,11072,49794,73100,43362,11150,29273,5978,31886,29457,148,24800,29166,28743,2581,21492,20198,30653,22795,48593,9043,65916,9389,19400,11101,41137,29669,312,16287,64890,93153 );
UPDATE cal_copd_gprd SET copd_gprd = '5' WHERE medcode IN ( 7884,1446 );
UPDATE cal_copd_gprd SET copd_gprd = '6' WHERE medcode IN ( 42258,38074,45777 );



DROP TABLE IF EXISTS cal_copd_hes;
CREATE TABLE cal_copd_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN
        (icd LIKE 'J430%'
        OR icd LIKE 'J438%'
        OR icd LIKE 'J41%'
        OR icd LIKE 'J411%'
        OR icd LIKE 'J432%'
        OR icd LIKE 'J43%'
        OR icd LIKE 'J439%'
        OR icd LIKE 'J418%'
        OR icd LIKE 'J40X%'
        OR icd LIKE 'J431%'
        OR icd LIKE 'J410%'
        OR icd LIKE 'J42X%') 
        THEN 2
    WHEN
        (icd LIKE 'J449%'
	OR icd LIKE 'J44%'
	OR icd LIKE 'J448%')
	THEN 3
    WHEN
        (icd LIKE 'J209%'
         OR icd LIKE 'J200%'
	OR icd LIKE 'J203%'
	OR icd LIKE 'J202%'
	OR icd LIKE 'J201%'
	OR icd LIKE 'J206%'
	OR icd LIKE 'J20%'
	OR icd LIKE 'J205%'
	OR icd LIKE 'J207%'
	OR icd LIKE 'J208%'
	OR icd LIKE 'J204%')
	THEN 4
    WHEN
	(icd LIKE 'J440%'
         OR icd LIKE 'J441%')
         THEN 5
    ELSE 9 
    END copd_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM  cal_copd_hes WHERE copd_hes = 9;

UPDATE
    cal_copd_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_copd_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_copd_hes DROP COLUMN spno;

-- CREATE INDEX anonpatid ON cal_copd_hes( anonpatid );

DROP TABLE IF EXISTS cal_drugs_copd;
CREATE TABLE cal_drugs_copd AS
SELECT
   t.anonpatid,
   t.eventdate,
   t.consid,
   t.prodcode,
   t.qty,
   t.ndd,
   t.numdays,
   t.numpacks,
   t.packtype,
   t.issueseq   
FROM
   patient p,
   therapy t
WHERE
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
AND
   t.prodcode IN ( 1801,5837,40637,959,882,5516,38079,17185,3163,898,22430,10407,7239,17696,454,34919,5521,22313,31,6325,34315,578,33988,16577,1630,1861,23905,14514,4171,6911,28508,2160,4926,5335,9906,35000,35631,3065,19376,35461,2994,21482,32102,6719,6522,2020,34859,41549,14736,7964,5804,7602,2510,35638,21859,8635,1518,1259,5261,4514,17002,3786,8183,1974,3289,6746,28577,6616,9651,10254,34619,6276,8,5309,1972,4759,36869,743,9658,3220,34794,752,35652,1741,20095,30649,35905,862,23741,5780,10360,34702,16018,41515,14306,11588,1832,14590,10433,34310,7953,28859,2704,9018,2995,1424,33888,4365,881,1628,8806,40057,5172,6526,2722,638,1734,6315,12699,30212,7724,7042,11497,1258,34404,30238,34452,7965,35288,5170,26873,29267,6780,1975,18537,5992,35862,3570,235,27340,5308,7133,7733,4412,34029,13040,8505,4268,27962,34631,5753,17005,6802,36401,1961,10561,6081,38226,22828,2723,746,534,29273,3743,32050,6512,557,2147,35825,1952,31933,35503,12808,1959,15706,11307,5898,16148,1242,21102,13206,4593,9895,28376,1414,24898,6619,5522,11478,34938,860,39102,3534,1676,19141,15979,1063,17,911,5453,20838,907,30118,37612,4055,31327,35744,35602,590,34311,895,17670,856,1834,4499,25784,5942,35299,6419,38214,6050,2229,28881,9921,10458,16584,5773,18314,16054,7031,9571,16124,35107,6569,956,947,1087,35430,34781,13996,2951,5885,9092,30229,3075,6462,4545,35106,5975,99,8267,4688,1885,21769,1697,556,10043,2282,16207,6556,28375,30596,36090,34914,28640,39099,13307,35165,10968,37432,7017,24418,1409,510,9477,15214,33089,7935,7140,549,13815,1236,23567,41269,3850,34162,2148,6848,35861,11732,13037,960,7891,35580,3018,35986,35557,24380,21833,11410,1426,21402,4640,16305,21417,40709,5223,11046,4165,18456,1410,1346,1950,1698,40655,26616,18299,2992,38419,4942,5143,1619,19401,23269,13529,29333,17644,34018,31082,3584,18394,1882,2440,665,2758,3443,18484,2437,21330,34134,2851,24674,14567,16151,41691,4413,10808,35611,2869,8522,36290,1962,1725,35392,14757,674,957,465,23961,13038,17465,1537,5185,13181,10218,4801,37470,5718,35374,1269,19389,5558,15301,18421,8333,32803,38407,1635,8057,2893,6796,40218,14561,35725,3546,4665,555,32835,12530,15613,34109,10331,12909,17140,38120,9164,1957,6768,23512,1960,880,9727,11618,9805,11719,8111,13273,12994,1680,719,2757,5057,38416,9384,19121,6988,12240,2892,11198,3363,5889,30240,1552,17874,35071,2850,6772,40832,910,17590,4601,23709,18848,10825,7730,4842,1097,34660,34995,1415,1243,896,13757,35118,37447,4634,8056,5941,4497,35522,7954,35566,35011,37791,4803,38097,2159,7711,34739,4538,1711,1642,8676,3345,6420,33691,3989,942,955,7841,39879,24456,1423,25339,44,2152,1833,95,5490,3119,2862,14700,12822,39200,7268,3947,3556,4222,2655,35772,987,41745,10831,3305,29325,41412,1093,908,16625,14739,36462,23572,14524,10321,33588,10723,10090,3927,33849,2335,16994,26063,11149,36021,3254,3994,2125,7270,1412,27188,3039,9599,863,16433,30204,5584,33373,5864,2978,36864,5913,5551,35225,30230,282,9889,1551,35113,6976,11659,31845,30210,6758,31532,1956,21005,2949,7788,27679,35408,1406,40599,2224,9642,4132,40177,33817,7732,6938,35014,5116,5683,1951,33990,3297,8757,696,1794,27505,18622,9577,34461,2092,16523,9681,7653,9711,20825,3557,4791,879,11993,3306,1727,1620,15281,6423,12042,35293,11779,31774,958,2600,33258,35700,35724,5740,21331,19031,38136,16158,15365,3347,7948,14294,7731,32874,909,883,28761,34428,15284,3993,5580,3388,18140,35510,41548,14321,3150,28073,25204,5161,5822,35542,9270,14483,39040,13290,4131,7638,1100,15326,5976,9233,34618,4541,2368,8433,38,13365,1411,34393,7013,17654,14525,3666 );

DROP TABLE IF EXISTS cal_drugs_copd_exac;
CREATE TABLE cal_drugs_copd_exac AS
SELECT
   t.anonpatid,
   t.eventdate,
   t.consid,
   t.prodcode,
   t.qty,
   t.ndd,
   t.numdays,
   t.numpacks,
   t.packtype,
   t.issueseq   
FROM
   patient p,
   therapy t
WHERE
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
AND
   t.prodcode IN ( 13239,23740,331,40796,31801,41192,20409,30772,24150,39642,40243,28349,5662,36514,34885,2507,578,33988,34913,7636,39010,33693,14816,728,40884,21799,1638,36701,30743,19414,30528,6121,41389,11613,13167,62,22017,3042,28544,32643,33334,825,34494,34650,9154,19160,24200,21829,4153,40391,9343,30786,29343,30705,19184,2976,993,32872,33383,9219,28592,5357,27072,39613,1722,25751,34838,25484,509,29458,569,12235,36569,12248,485,31110,9925,19152,33109,24126,40784,33222,1202,26233,2227,8906,20095,33697,415,36599,8085,25127,15713,480,438,41515,27714,33343,32235,31286,28859,2704,30783,8008,34559,29697,765,34234,7364,21963,34714,2350,33705,19138,26992,13910,7485,4154,2153,26262,34253,34404,32181,2719,13262,19330,33989,10455,41584,34452,34974,21835,34857,34795,32622,28874,13285,10326,399,3180,4010,27962,34631,33671,36578,2174,34479,34855,366,29353,9583,3572,400,3736,2376,40320,21775,39669,557,15071,34423,33701,4689,4489,6306,29748,7526,7430,1140,37022,36054,4582,36544,12378,22042,28871,28376,27254,17121,26059,27725,19141,1063,36330,427,9520,2202,31327,31535,545,37755,26207,9267,2326,26289,11989,24618,33689,33570,25384,33110,4596,41605,498,32640,24396,6803,34781,38163,27203,33703,28130,24090,1860,34448,34322,8051,34478,9664,264,40914,30234,21808,29463,34811,28375,34914,33690,48,30771,9148,40073,22321,28872,17645,34133,24149,31661,32910,38684,33329,9903,14386,32642,24127,21844,20432,3737,33695,192,8724,34694,10304,14511,28882,21828,19161,26392,9603,155,14904,1038,25595,21833,583,34775,9,2281,21417,18930,17207,34655,12276,41453,30520,11634,34853,34972,3523,33112,25278,532,9157,29333,34680,34594,16747,1693,14607,7752,15148,163,41106,1146,39118,30707,38997,21860,31689,37304,20992,29337,865,6651,34300,19133,19209,31690,2429,41734,4576,16612,14371,33802,26157,9243,29472,34638,34042,585,327,33696,10190,12330,34512,30745,34734,970,40747,41560,40980,26236,23432,22415,9293,38407,32803,22029,830,21038,29344,33692,553,847,29464,39913,5859,33686,32835,21845,681,30980,30498,34384,14407,33165,34109,34679,34760,524,33706,9689,23512,27768,5341,9727,40238,39703,41604,34001,103,201,1072,1391,34493,9698,31514,21878,6671,3669,17282,23967,39616,20881,24006,33304,18682,30739,18643,6396,503,3152,33685,34660,641,3979,32902,14396,22016,27681,34765,870,1384,34308,4091,10200,8019,19144,26989,1837,3609,8625,281,37694,29858,28722,6687,733,997,34334,23405,439,34912,18786,40915,3345,2226,33691,955,32066,537,13635,21979,44,95,5490,11611,24220,12987,35570,2661,2884,39623,27495,37796,11433,22015,397,2171,34605,41745,18243,27017,23238,14429,28870,3209,29356,22438,29474,401,40945,14171,34873,1046,268,829,319,9690,5913,41049,34231,29154,23954,32419,24129,34533,31423,34394,7737,29281,31532,23244,2949,20420,34852,31428,26840,15290,34435,41736,1812,2428,63,1637,33990,41561,31014,21827,34461,34175,33694,3557,41090,24203,15192,34869,26747,29202,17711,41230,39417,133,7889,34608,13216,33248,26365,31827,40148,25370,40168,10454,31825,6623,23017,34647,2225,7560,4610,30177,23819,34189,13848,18451,34297,32898,34779,1713,3742,34973,33699,9434,25280,28875,318,105,27504,4672,34232,34837,17746,24093,31530,39632,4372,13120,2368,17150,34393 );


DROP TABLE IF EXISTS cal_mrc_breath;
CREATE TABLE cal_mrc_breath AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS mrc_breath
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 19432, 19427, 19426, 19430, 19429 );

DROP TABLE IF EXISTS cal_spirometry;
CREATE TABLE cal_spirometry AS
SELECT
    t.anonpatid,
    t.eventdate,
    t.medcode,
    t.enttype,
    t.data2 AS value
FROM
   test t,
   patient p
WHERE
   eventdate IS NOT NULL
AND
    ( enttype = 395 OR enttype = 396 OR enttype = 394 )
AND
    data1 = 3
AND
   t.anonpatid = p.anonpatid;
   
DROP TABLE IF EXISTS cal_cirrhosis_gprd;
CREATE TABLE cal_cirrhosis_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN
   c.medcode IN ( 40953,40963 ) THEN 0
   WHEN
   c.medcode IN ( 21713,58630,19512,3450,6015,15424,27438,60104,47257,6863,71453,55454,16725,9494,68376,48928,5638,8363,40567,1638,16455,8206,44676,44120,69204,4743,22841,26319,92909,73482,18739,25383 ) THEN 3 
   WHEN
   c.medcode IN ( 34642,91591,96664,58184 ) THEN 4
   ELSE 9 
   END cirrhosis_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_cirrhosis_gprd WHERE cirrhosis_gprd = 9;

-- CREATE INDEX anonpatid ON cal_cirrhosis_gprd( anonpatid );
DROP TABLE IF EXISTS cal_cirrhosis_hes;
CREATE TABLE cal_cirrhosis_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    3 AS cirrhosis_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    ( icd LIKE 'K702%'
    OR icd LIKE 'K703%'
    OR icd LIKE 'K717%'
    OR icd LIKE 'K74%' );


UPDATE
    cal_cirrhosis_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_cirrhosis_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_cirrhosis_hes DROP COLUMN spno;

-- CREATE INDEX anonpatid ON cal_cirrhosis_hes( anonpatid );
DROP TABLE IF EXISTS cal_liver_disease_hes;
CREATE TABLE cal_liver_disease_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    3 AS liver_disease_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    ( icd LIKE 'K70%'
    OR icd LIKE 'K72%'
    OR icd LIKE 'K73%'
    OR icd LIKE 'K74%'
    OR icd LIKE 'K75%'
    OR icd LIKE 'K76%' );

UPDATE
    cal_liver_disease_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_liver_disease_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_liver_disease_hes DROP COLUMN spno;

-- CREATE INDEX anonpatid ON cal_liver_disease_hes( anonpatid );
-- Generated: 2013-02-19 18:09:42
   DROP TABLE IF EXISTS cal_ckdstage_gprd;

   CREATE TABLE cal_ckdstage_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 94789,97980,95572,29013,95146,97979,95121,12586,97978,95177,95175,12566,95180,95123,94965,95176,95408,95179,95145,95571,95178,95188,94793,12479,97587,95406,95122,97683,12585,95508,95405 );

   -- CREATE INDEX anonpatid ON cal_ckdstage_gprd( anonpatid );

   ALTER TABLE cal_ckdstage_gprd ADD COLUMN ckdstage_gprd INT DEFAULT NULL;

   UPDATE cal_ckdstage_gprd SET ckdstage_gprd = '1' WHERE medcode IN ( 94789,97980,95572,29013 );
UPDATE cal_ckdstage_gprd SET ckdstage_gprd = '2' WHERE medcode IN ( 95146,97979,95121,12586,97978 );
UPDATE cal_ckdstage_gprd SET ckdstage_gprd = '3' WHERE medcode IN ( 95177,95175,12566,95180,95123,94965,95176,95408,95179,95145,95571,95178,95188,94793 );
UPDATE cal_ckdstage_gprd SET ckdstage_gprd = '4' WHERE medcode IN ( 12479,97587,95406,95122 );
UPDATE cal_ckdstage_gprd SET ckdstage_gprd = '5' WHERE medcode IN ( 97683,12585,95508,95405 );

--Note: no records found in GPRD test table.-- Generated: 2013-02-19 17:58:36

   DROP TABLE IF EXISTS cal_dialysis_gprd;

   CREATE TABLE cal_dialysis_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 60446,72336,74905,59315,60498,2996,96347,60302,64828,30709,8037,88597,45160,30756,63502,2994,46438,23773,28158,20196,11773,63038,96184,20073,22252,48639,69760,69266,63488,36442,46145,60743,52088,44422,86419,66714 );

   -- CREATE INDEX anonpatid ON cal_dialysis_gprd( anonpatid );

   ALTER TABLE cal_dialysis_gprd ADD COLUMN dialysis_gprd INT DEFAULT NULL;

   UPDATE cal_dialysis_gprd SET dialysis_gprd = '3' WHERE medcode IN ( 60446,72336,74905,59315,60498,2996,96347,60302 );
UPDATE cal_dialysis_gprd SET dialysis_gprd = '4' WHERE medcode IN ( 64828,30709,8037,88597,45160,30756,63502,2994,46438,23773 );
UPDATE cal_dialysis_gprd SET dialysis_gprd = '5' WHERE medcode IN ( 28158,20196,11773,63038,96184,20073,22252,48639,69760,69266,63488,36442,46145,60743,52088,44422,86419,66714 );
-- Generated: 2013-02-19 18:01:09
   DROP TABLE IF EXISTS cal_dialysis_opcs;

   CREATE TABLE cal_dialysis_opcs AS
   SELECT 
      c.anonpatid,
      c.admidate   AS date_admission,
      c.evdate     AS date_procedure,
      c.discharged AS date_discharge,
      c.opcs
   FROM 
      hes_procedure c
   WHERE
      c.opcs IN ( 'X403','L746','X421','X405','X412','X411','X402','X406','X401' );

   -- CREATE INDEX anonpatid ON cal_dialysis_opcs( anonpatid );

   ALTER TABLE cal_dialysis_opcs ADD COLUMN dialysis_opcs INT DEFAULT NULL;

   UPDATE cal_dialysis_opcs SET dialysis_opcs = '3' WHERE opcs IN ( 'X403','L746' );
UPDATE cal_dialysis_opcs SET dialysis_opcs = '4' WHERE opcs IN ( 'X421','X405','X412','X411','X402','X406' );
UPDATE cal_dialysis_opcs SET dialysis_opcs = '5' WHERE opcs IN ( 'X401' );
-- Generated: 2013-06-26 08:49:53
   DROP TABLE IF EXISTS cal_renal_gprd;

   CREATE TABLE cal_renal_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 6774,9959,8828,20196,44422,29013,12586,94789,95572,95146,95121,49046,2088,5417,29384,67460,63599,20027,94261,48261,55100,47838,20129,23990,2266,10837,46242,31369,57919,97198,35235,25582,9379,31581,66136,66503,54312,61814,2546,64482,38698,53945,63277,72458,96179,69433,15945,63760,24676,24292,12720,12566,12479,12585,94965,95179,94793,95123,95408,95175,95178,95177,95122,95406,95508,95405,60302,90952,31549,48022,64636,56760,59194,83513,65089,17253,52272,49235,67197,2475,35107,57621,66872,59365,64571,24836,10418,12640,52969,61145,21687,68112,29323,16929,25394,22897,19454,4668,39649,43935,32423,15106,63466,67232,63000,21837,28684,68659,40956,97533,2773,2999,9840,1803,29634,57926,23913,22852,19316,21947,50472,21989,56987,17365,63786,47922,2471,58750,47672,22205,94373,27427,7804,10647,11875,34998,10809,61494,65064,60960,97758,4669,65400,63615,15097,33580,4850,11873,16008,5291,12465,67995,62868,24384,57072,21423,67193,50305,36342,41881,97388,94350,58164,41676,45867,36125,60128,62520,30301,35065,27335,34669,44055,5182,512,10081,53852,6712,350,4809,11787,6842,8919,29638,68114,34648,50728,66062,34637,30310,39840,56939,41013,5072,50804,48475,25980,55389,71174,97734,41285,58060,50200,62320,61317,49642,60484,60856,85659,21297,66505,40413,57168,56893,73026,60198,60857,61811,36205,51113,41239,44270,58671,91738,62980,45523,64622,41148,8607,41159,57784,50893,8330,49150,15780,4654,57568,35360,48855,2939,48111,38572,53944,1899,95710,59121,36273,8098,11992,10460,15340,44657,34675,20516,2991,71709,94842,72478,61930,53940,70157,96819,56896,71314,70422,47080,38312,92579,54938,96724,15917,20629,4503,56852,9240,59018,67486,59031,50331,72877,73373,47342,11554,39598,55858,74905,52088,96347,11773,20073,2994,2996,88597,30756,64828,36442,8037,23773,30709,48639,46438,59315,96184,69266,28158,66714,54844,60446,72336,60498,63502,22252,60743,46145,63488,45160,63038,69760,2997,55151,11745,66705,24361,98364,89924,96133,70874,5504,48121,72004,26862,93366,48057,11553,54990,18774,5911,19473,30735,71271,30739,72962,72964,88494,69679 );

   -- CREATE INDEX anonpatid ON cal_renal_gprd( anonpatid );

   ALTER TABLE cal_renal_gprd ADD COLUMN renal_gprd INT DEFAULT NULL;

   UPDATE cal_renal_gprd SET renal_gprd = '1' WHERE medcode IN ( 44422,20196,9959,6774,8828 );
UPDATE cal_renal_gprd SET renal_gprd = '3' WHERE medcode IN ( 95146,94789,95572,29013,95121,12586 );
UPDATE cal_renal_gprd SET renal_gprd = '4' WHERE medcode IN ( 24292,63277,31369,54312,66136,31581,2266,48261,61814,35235,49046,10837,15945,55100,46242,96179,38698,20027,20129,94261,64482,57919,47838,23990,29384,72458,5417,2546,24676,9379,2088,53945,97198,63599,67460,69433,66503,63760,25582 );
UPDATE cal_renal_gprd SET renal_gprd = '5' WHERE medcode IN ( 6712,51113,95177,12566,58671,35360,36342,94965,49150,38312,15106,29323,68112,74905,2471,11875,22205,50804,58750,40956,54938,57168,56939,24384,22852,57568,60856,512,41239,41013,57072,15780,71174,21423,21837,29638,33580,97533,10460,50305,30301,41159,39840,4809,52272,63786,91738,12720,2773,350,56852,20516,15097,4669,11554,4654,1803,34998,67232,70157,1899,38572,62320,61930,65089,10418,8098,95122,60960,94793,64636,68114,50200,62868,41676,35065,47080,44657,65064,94350,29634,50728,10081,55858,55389,59365,72877,50472,67193,22897,12585,34648,21297,95179,59018,48855,4850,57784,60484,2999,56896,20629,48475,11787,35107,59031,66505,95175,61145,53944,85659,60198,63466,16008,96819,45523,83513,94842,39649,60857,2475,43935,62980,17365,97758,5072,30310,62520,2939,50893,8919,90952,6842,64622,17253,4668,53852,44055,56893,61811,48022,52969,21989,39598,60128,21687,63000,72478,12465,47342,71709,28684,27335,49642,67197,12479,61317,61494,8607,95123,34669,48111,57621,59121,64571,41148,19316,47672,73373,7804,19454,94373,50331,31549,71314,34637,66062,66872,63615,97734,68659,70422,25394,24836,44270,10809,65400,58060,12640,96724,56760,95710,59194,4503,97388,67995,41285,9240,9840,32423,45867,67486,95405,47922,11992,21947,58164,95508,60302,25980,92579,73026,15917,57926,5291,15340,95178,8330,36125,49235,5182,23913,27427,11873,16929,56987,52088,53940,36273,95408,10647,41881,2991,34675,95406,36205,40413 );
UPDATE cal_renal_gprd SET renal_gprd = '6' WHERE medcode IN ( 28158,72336,64828,30709,8037,11773,63038,45160,96184,30756,59315,20073,46438,22252,23773,54844,48639,69760,2996,63488,69266,88597,46145,36442,60743,60446,60498,63502,2994,96347,66714 );
UPDATE cal_renal_gprd SET renal_gprd = '7' WHERE medcode IN ( 11553,48121,5504,96133,54990,98364,18774,89924,66705,72004,55151,48057,24361,11745,26862,5911,2997,93366,70874 );
UPDATE cal_renal_gprd SET renal_gprd = '8' WHERE medcode IN ( 88494,30735,71271,72964,72962,19473,69679,30739 );



DROP TABLE IF EXISTS cal_crea_gprd;
CREATE TABLE cal_crea_gprd AS
SELECT
   t.anonpatid,
   t.eventdate,
   t.data2 AS crea_gprd
FROM
   test t,
   patient p
WHERE
   t.medcode IN ( 5, 3927, 13736, 26903, 27095, 31277, 35545, 42345, 45096, 62062 )
AND
   t.enttype IN ( 165, 288 )
AND
   t.data1 = 3
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   crea_gprd > 0
ORDER BY 
   anonpatid;
-- Generated: 2013-02-18 11:38:49

DROP TABLE IF EXISTS cal_egfr_ckdepi_gprd;

CREATE TABLE cal_egfr_ckdepi_gprd AS
SELECT
   t.anonpatid,
   t.eventdate,
   t.data2  AS crea_gprd,
   p.gender AS gender,
   CONCAT(1800 + p.yob,'-01-01') AS dob,
   -- http://www.caliberresearch.org/portal/show/ethnic_hes
   CASE
   WHEN
      (h.ethnos = 'Bl_Afric' 
      OR 
      h.ethnos = 'Bl_Carib'
      OR
      h.ethnos = 'Bl_Other') THEN 1
   ELSE 0 
   END is_black
FROM
   test t,
   patient p,
   hes_patient h
WHERE
   t.medcode IN ( 5, 3927, 13736, 26903, 27095, 31277, 35545, 42345, 45096, 62062 )
AND
   t.enttype IN ( 165, 288 )
AND
   t.data1 = 3
AND
   t.anonpatid = p.anonpatid
AND
   t.anonpatid = h.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   crea_gprd >= 30
ORDER BY 
   anonpatid;

ALTER TABLE cal_egfr_ckdepi_gprd 
   ADD COLUMN age DECIMAL (7,4),
   ADD COLUMN egfr_ckdepi_gprd DECIMAL (10,5);

UPDATE cal_egfr_ckdepi_gprd 
   SET age = ROUND( DATEDIFF( eventdate, dob ) / 365, 4 );
   
-- Black, Female

UPDATE cal_egfr_ckdepi_gprd 
SET egfr_ckdepi_gprd = 141 * POWER(LEAST(crea_gprd * 0.010746 / 0.7, 1), -0.329)
    * POWER(GREATEST(crea_gprd * 0.010746 / 0.7, 1), -1.209)
    * POWER(0.993, age) * 1.018 * 1.159
WHERE is_black = 1 
AND gender     = 2;

-- Black, male

UPDATE cal_egfr_ckdepi_gprd
SET egfr_ckdepi_gprd = 141 * POWER(LEAST(crea_gprd * 0.010746 / 0.9, 1), -0.411)
    * POWER(GREATEST(crea_gprd * 0.010746 / 0.9, 1), -1.209)
    * POWER(0.993, age) * 1.159
WHERE is_black = 1 
AND gender     = 1;

-- Not black, female

UPDATE cal_egfr_ckdepi_gprd
SET egfr_ckdepi_gprd = 141 * POWER(LEAST(crea_gprd * 0.010746 / 0.7, 1), -0.329)
    * POWER(GREATEST(crea_gprd * 0.010746 / 0.7, 1), -1.209)
    * POWER(0.993, age) * 1.018
WHERE is_black = 0 
AND gender     = 2;

-- Not black, male

UPDATE cal_egfr_ckdepi_gprd 
SET egfr_ckdepi_gprd = 141 * POWER(LEAST(crea_gprd * 0.010746 / 0.9, 1), -0.411)
    * POWER(GREATEST(crea_gprd * 0.010746 / 0.9, 1), -1.209)
    * POWER(0.993, age)
WHERE is_black = 0 
AND gender     = 1;

-- Generated: 2013-02-18 11:38:49

DROP TABLE IF EXISTS cal_egfr_mdrd_gprd;

CREATE TABLE cal_egfr_mdrd_gprd AS
SELECT
   t.anonpatid,
   t.eventdate,
   t.data2  AS crea_gprd,
   p.gender AS gender,
   CONCAT(1800 + p.yob,'-01-01') AS dob,
   -- http://www.caliberresearch.org/portal/show/ethnic_hes
   WHEN
      h.ethnos = 'Bl_Afric' 
      OR 
      h.ethnos = 'Bl_Carib'
      OR
      h.ethnos = 'Bl_Other',
      1,
      0 ) AS is_black
FROM
   test t,
   patient p,
   hes_patient h
WHERE
   t.medcode IN ( 5, 3927, 13736, 26903, 27095, 31277, 35545, 42345, 45096, 62062 )
AND
   t.enttype IN ( 165, 288 )
AND
   t.data1 = 3
AND
   t.anonpatid = p.anonpatid
AND
   t.anonpatid = h.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   crea_gprd >= 30
ORDER BY 
   anonpatid;

ALTER TABLE cal_egfr_mdrd_gprd 
   ADD COLUMN age DECIMAL (7,4),
   ADD COLUMN egfr_mdrd_gprd DECIMAL (10,5);

UPDATE cal_egfr_mdrd_gprd 
   SET age = ROUND( DATEDIFF( eventdate, dob ) / 365, 4 );

UPDATE cal_egfr_mdrd_gprd 
   SET egfr_mdrd_gprd =  ROUND( 175 * POW(crea_gprd, -1.154) * POW(age, -0.203), 5);

-- Black modifier

UPDATE cal_egfr_mdrd_gprd 
   SET egfr_mdrd_gprd = egfr_mdrd_gprd * 1.212 WHERE is_black = 1;

-- Female modifier

UPDATE cal_egfr_mdrd_gprd
   SET egfr_mdrd_gprd = egfr_mdrd_gprd * 0.742 WHERE gender = 2;

DROP TABLE IF EXISTS cal_birthyear;
CREATE TABLE cal_birthyear AS
SELECT 
   anonpatid,
   ( yob+1800 ) AS birthyear
FROM 
   patient
WHERE 
   accept = 1;

 
DROP TABLE IF EXISTS cal_depriv_gprd;

CREATE TABLE cal_depriv_gprd AS
SELECT 
   s.anonpatid,
   s.imd_score,
   s.imd_rank,
   s.townsend_score,
   s.townsend_quintile
FROM 
   patient p,
   ses s
WHERE
   p.anonpatid = s.anonpatid
AND
   p.gender IN (1,2)
;-- Generated: 2013-05-01 10:55:44
   DROP TABLE IF EXISTS cal_ethnic_gprd;

   CREATE TABLE cal_ethnic_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 12446,26467,26310,98111,12352,12436,12681,28887,24837,24270,47601,12532,98213,42294,55223,12444,45947,45955,47949,32066,32126,32069,12633,45008,96789,71425,12421,32778,12355,12769,12746,32413,12412,55113,42290,12467,12433,28973,26341,25422,46956,28866,47074,28936,12591,22467,35459,40102,26391,12402,28900,32425,32443,12742,12437,32401,12638,47965,57753,57763,48005,35350,32165,38097,12795,49940,32399,12696,32420,12873,12706,47005,32408,25623,47401,40110,12482,39696,12414,26392,24690,12460,64133,24740,28888,46818,26379,12668,12513,47077,12653,46056,28935,12632,57435,47950,47997,32100,54593,57094,57075,93144,12432,12778,35412,47969,12350,12443,32886,24339,12452,41329,46812,57752,50286,26312,25676,32136,32389,40097,40096,46047,24272,12468,30280,32110,57764,24962,47285,25082,41214,25411,12757,46752,12608,12760,12887,12434,12719,12473,12420,12730,63872,56127,46063,47091,49658,46059,47028,28909,46964,25937,45964,25451,26246,12756,32382,26455,93749,10196,12429,24340,45199,23955,12435,12351,12459 );

   -- CREATE INDEX anonpatid ON cal_ethnic_gprd( anonpatid );

   ALTER TABLE cal_ethnic_gprd ADD COLUMN ethnic_gprd INT DEFAULT NULL;

   UPDATE cal_ethnic_gprd SET ethnic_gprd = '1' WHERE medcode IN ( 98111,12446,28887,12352,26467,26310,12436,12681 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '2' WHERE medcode IN ( 47601,24837,24270,42294,12532,55223,98213 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '3' WHERE medcode IN ( 45008,12591,32778,25422,42290,32413,71425,12746,12769,32066,12355,12633,28973,12444,26341,28866,12433,32126,45947,45955,47074,47949,28936,12421,12467,32069,12412,46956,96789,55113 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '4' WHERE medcode IN ( 26391,40102,28900,35459,22467,12402 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '5' WHERE medcode IN ( 32425,12437,12742,32443 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '6' WHERE medcode IN ( 32401,12638 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '7' WHERE medcode IN ( 47965,32399,48005,32165,49940,35350,57753,12795,57763,38097 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '8' WHERE medcode IN ( 12706,12696,47005,12873,32420,32408 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '9' WHERE medcode IN ( 25623,47401,40110 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '10' WHERE medcode IN ( 26392,39696,12414,12482 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '11' WHERE medcode IN ( 12460,24690,64133 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '12' WHERE medcode IN ( 28888,24740 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '13' WHERE medcode IN ( 28935,12513,46056,46818,47077,12653,12668,26379 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '15' WHERE medcode IN ( 57435,54593,12432,47950,12632,47997,93144,57075,32100,57094 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '16' WHERE medcode IN ( 32886,12350,47969,35412,12443,12778 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '17' WHERE medcode IN ( 50286,26312,46047,40096,41329,12452,46812,25676,32136,57752,40097,32389,24339 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '19' WHERE medcode IN ( 24272,12468 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '20' WHERE medcode IN ( 12760,30280,12887,45964,12434,46964,25451,49658,25411,12730,47091,47028,12719,46059,32110,25082,12608,24962,41214,12473,12757,28909,12420,12756,32382,57764,47285,46063,26455,56127,25937,46752,63872,26246 );
UPDATE cal_ethnic_gprd SET ethnic_gprd = '21' WHERE medcode IN ( 12435,24340,12459,12351,93749,10196,12429,45199,23955 );
DROP TABLE IF EXISTS cal_ethnic_hes;
CREATE TABLE cal_ethnic_hes AS
SELECT
   h.anonpatid,
   h.ethnos as ethnic_hes
FROM
   hes_patient h,
   patient p
WHERE
   p.anonpatid = h.anonpatid
;
DROP TABLE IF EXISTS cal_sex_gprd;
CREATE TABLE cal_sex_gprd AS
SELECT
   anonpatid,
   gender AS sex_gprd
FROM
   patient
WHERE
   gender IN ( 1,2 )
AND
   accept = 1;DROP TABLE IF EXISTS cal_clinical_contact;
CREATE TABLE cal_clinical_contact AS 
SELECT
   c.anonpatid,
   eventdate,
   constype,
   1 AS consult
FROM
   clinical c, 
   patient p
WHERE 
   c.anonpatid = p.anonpatid

AND
   eventdate IS NOT NULL
AND
   c.constype IN (  1,2,3,4,6,7,8,9,11,18,20,23,24,27,28,30,31,32,33,34,36,37,38,40,48,50 );

-- CREATE INDEX anonpatid ON cal_clinical_contact( anonpatid );DROP TABLE IF EXISTS cal_consult;
CREATE TABLE cal_consult AS 
SELECT
   c.anonpatid,
   eventdate,
   constype,
   1 AS consult
FROM
   clinical c, 
   patient p
WHERE 
   c.anonpatid = p.anonpatid

AND
   eventdate IS NOT NULL
AND
   c.constype IN (  1, 2, 3, 4, 6, 7, 8, 9, 11, 18, 21, 27, 28, 30, 31, 32, 33, 34,
35, 36, 37, 50, 55 );

-- CREATE INDEX anonpatid ON cal_consult( anonpatid );DROP TABLE IF EXISTS cal_smoking_status_composite;
CREATE TABLE cal_smoking_status_composite AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.smoking_status 
FROM
   cal_smoking_status c
WHERE
    c.smoking_status IN (1,2,3,4)

UNION

SELECT
   c.anonpatid,
   c.eventdate,
   4 AS smoking_status 
FROM
   cal_drugs_4_10_2 c;
DROP TABLE IF EXISTS cal_smoking_status;
CREATE TABLE cal_smoking_status AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   c.data1 AS entdata,
   WHEN
      c.medcode IN ( 60,33,98177,52503,11788 ),
      1,
      WHEN
         c.medcode IN ( 90,12961,72706,97210,12955,12878,12956,12959,776,26470,12946,12957,98447,19488 ),
         2, 
         WHEN
            c.medcode IN (  16717,72700 ),
            3,
            WHEN
               c.medcode IN ( 25106,40417,98245,12947,12942,12945,12958,11527,46321,63717,12954,98493,38112,30423,10558,34374,12965,12951,6359,12944,19485,63666,93,10184,12240,60720,66409,57639,9045,42722,49418,95610,32687,98347,41979,40418,12967,56144,28886,94958,67178,85247,53101,68658,91708,61905,3568,10211,28834,63299,12953,12963,24529,63901,21637,7622,31114,89464,11356,90522,1878,10898,97643,59866,35055,91513,7130,12964,41405,32572,96992,81440,10742,32083,34126,85975,41042,58597,47273,34127,12943,70746,98137,62686,12941,74907,18573,66387,12960,30762,98154,1822,1823,12966,9833,12952 ),
               4,
               9 ) ) ) ) AS smoking_status
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   smoking_status != 9;

-- IF data1 = 0 or missing / NULL, smoking_status = category from smoking_status_gprd codelist

-- IF data1 = 1 (Yes):
-- IF medcode in smoking_status_gprd and category = 1 (Non), smoking_status = 6
-- ELSE IF medcode in smoking_status_gprd and category = 2 (Ex), smoking_status = 5
-- ELSE smoking_status = 4

UPDATE cal_smoking_status
SET smoking_status = 
WHEN
   smoking_status = 1,
   6,
   WHEN
      smoking_status = 2,
      5,
      4 ) ) 
WHERE enttype = 4 
AND entdata = 1;

-- IF data1 = 3 (Ex):
-- IF medcode in smoking_status_gprd and category = 4 (Current), smoking_status = 5
-- ELSE smoking_status = 2

UPDATE cal_smoking_status
SET smoking_status = 
WHEN
   smoking_status = 4,
   5,
   2 ) 
WHERE enttype = 4 
AND entdata = 3;


-- IF data1 = 2 (No):
-- IF medcode in smoking_status_gprd and category = 4 (Current), smoking_status = 6
-- ELSE IF medcode in smoking_status_gprd and category In (2, 3) (Ex or Ever), smoking_status = 2
-- ELSE smoking_status = 1

UPDATE cal_smoking_status
SET smoking_status = 
WHEN
   smoking_status = 4,
   6,
   WHEN
      smoking_status IN (2,3),
      2,
      1 ) ) 
WHERE enttype = 4 
AND entdata = 2;
DROP TABLE IF EXISTS cal_smoking_status_hes;
CREATE TABLE cal_smoking_status_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'Z716%' OR icd LIKE 'Z720%' ),
        2, 
        9 ) AS smoking_status_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    smoking_status_hes != 9;

UPDATE
    cal_smoking_status_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_smoking_status_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_smoking_status_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_aaa_ons;
CREATE TABLE cal_aaa_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS aaa_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( 
      o.cod LIKE 'I719%'
      OR o.cod LIKE 'I714%'
      OR o.cod LIKE 'I718%'
      OR o.cod LIKE 'I716%'
      OR o.cod LIKE 'I715%'
      OR o.cod LIKE 'I713%'
    )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_aaa_ons( anonpatid );
DROP TABLE IF EXISTS cal_any_death_ons;
CREATE TABLE cal_any_death_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS any_death_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_any_death_ons( anonpatid );
DROP TABLE IF EXISTS cal_arrest_ons;
CREATE TABLE cal_arrest_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS arrest_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'I472%' OR o.cod LIKE 'I46%' OR o.cod LIKE 'I470%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_arrest_ons( anonpatid );
DROP TABLE IF EXISTS cal_arterial_ons;
CREATE TABLE cal_arterial_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    WHEN
      o.cod LIKE 'I719%'
      OR o.cod LIKE 'I714%'
      OR o.cod LIKE 'I718%'
      OR o.cod LIKE 'I716%'
      OR o.cod LIKE 'I715%'
      OR o.cod LIKE 'I713',
      4,
      WHEN
        o.cod LIKE 'I739%'
        OR o.cod LIKE 'I73X%'
        OR o.cod LIKE 'I738%'
        OR o.cod LIKE 'I73%',
        7,
        WHEN
          o.cod LIKE 'I744%'
          OR o.cod LIKE 'I745%'
          OR o.cod LIKE 'I743%',
          8,
          9 ) ) ) AS arterial_ons        
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid

AND 
   p.gender IN (1,2)
HAVING arterial_ons != 9;

-- CREATE INDEX anonpatid ON cal_arterial_ons( anonpatid );
  
## HES categories 4,7,8
DROP TABLE IF EXISTS cal_cerebral_stroke_ons;
CREATE TABLE cal_cerebral_stroke_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS cerebral_stroke_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    o.cod LIKE 'I61%'

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_cerebral_stroke_ons( anonpatid );

DROP TABLE IF EXISTS cal_chd_death_gprd;
CREATE TABLE cal_chd_death_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   CASE
   WHEN c.data1 = '0' THEN 5
   WHEN c.data1 = '1' THEN 1
   WHEN c.data1 = '2' THEN 2
   WHEN c.data1 = '3' THEN 3
   WHEN c.data1 = '4' THEN 4
   ELSE 9 
   END chd_death_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 7696,54535,8568,36854,57062,13185,28554,15373,18125,14782,6336,15349,29902,19542,26863,39546,24540,12986,12804,9555,1414,45960,1430,11048,20095,25842, 54251,34328,29300,4656,66388,19655,1431,7347,17307,36523,39449,39655,9276,18118, 27951,10963,28138,70160,47637,20416,8516,15754,19067,35713,95550,37991,46565,240,68401,1490,19164,25814,35373,59687,34329,39500,34488,68979,67087,36193,46664,52517,54007,24783,18135,48981,27484,10260,59193,29421,13187,22383,72925,5413,19250,23078,11648,42659,6331,1676,9413,35277,19298,3468,21844,13250,27977,1792,17681,47798,18150,19185,38379,10662,34633,18889,1537,41032,30171,55137,37990,30027,19744,32666,39693,37908,11798,42669,1344,10910,1811,18218,26044,34207,45476,10127,41179,11038,32526,23098,41677,10109,2155,61072, 12229, 10562, 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,35674,15661,30421,9555,59189,36423,38609,50372,29553,13566,5387,16408,14658,14898,62626,40429,37657,72562,8935,17464,3704,9507,23579,61670,96838,68357,29758,4017,69474,34803,28736,18842,1678,23892,40399,14897,32272,46166,17689,46112 )
AND
   c.enttype = 149

UNION

SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   6 AS chd_death_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 7696,54535,8568,36854,57062,13185,28554,15373,18125,14782,6336,15349,29902,19542,26863,39546,24540,12986,12804,9555,1414,45960,1430,11048,20095,25842, 54251,34328,29300,4656,66388,19655,1431,7347,17307,36523,39449,39655,9276,18118, 27951,10963,28138,70160,47637,20416,8516,15754,19067,35713,95550,37991,46565,240,68401,1490,19164,25814,35373,59687,34329,39500,34488,68979,67087,36193,46664,52517,54007,24783,18135,48981,27484,10260,59193,29421,13187,22383,72925,5413,19250,23078,11648,42659,6331,1676,9413,35277,19298,3468,21844,13250,27977,1792,17681,47798,18150,19185,38379,10662,34633,18889,1537,41032,30171,55137,37990,30027,19744,32666,39693,37908,11798,42669,1344,10910,1811,18218,26044,34207,45476,10127,41179,11038,32526,23098,41677,10109,2155,61072, 12229, 10562, 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,35674,15661,30421,9555,59189,36423,38609,50372,29553,13566,5387,16408,14658,14898,62626,40429,37657,72562,8935,17464,3704,9507,23579,61670,96838,68357,29758,4017,69474,34803,28736,18842,1678,23892,40399,14897,32272,46166,17689,46112 )
AND
   c.enttype = 148
AND
   c.data1 != '0'

ORDER BY anonpatid;

DELETE FROM cal_chd_death_gprd WHERE chd_death_gprd = 9;

-- 
-- 
-- +------+------------------+
-- | code | label            |
-- +------+------------------+
-- |    0 | Data Not Entered |  5
-- |    1 | Category Ia      |  1 
-- |    2 | Category Ib      |  2
-- |    3 | Category Ic      |  3
-- |    4 | Category II      |  4  
-- +------+------------------+

-- CHD NOS: 27951,10963,28138,70160,47637,20416,8516,15754,19067,35713,95550,37991,46565,240,68401,1490,19164,25814,35373,59687,34329,39500,34488,68979,67087,36193,46664,52517,54007,24783,18135,48981,27484,10260,59193,29421,13187,22383,72925,5413,19250,23078,11648,42659,6331,1676,9413,35277,19298,3468,21844,13250,27977,1792,17681,47798,18150,19185,38379,10662,34633,18889,1537,41032,30171,55137,37990,30027,19744,32666,39693,37908,11798,42669,1344,10910,1811,18218,26044,34207,45476,10127,41179,11038,32526,23098,41677,10109,2155,61072
-- Unstable angina: 54251,34328,29300,4656,66388,19655,1431,7347,17307,36523,39449,39655,9276,18118
-- Stable angina: 7696,54535,8568,36854,57062,13185,28554,15373,18125,14782,6336,15349,29902,19542,26863,39546,24540,12986,12804,9555,1414,45960,1430,11048,20095,25842
-- STEMI: 12229
-- NSTEMI: 10562_hes

-- MI NOS: 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,35674,15661,30421,9555,59189,36423,38609,50372,29553,13566,5387,16408,14658,14898,62626,40429,37657,72562,8935,17464,3704,9507,23579,61670,96838,68357,29758,4017,69474,34803,28736,18842,1678,23892,40399,14897,32272,46166,17689,46112

DROP TABLE IF EXISTS cal_chd_death_ons;
CREATE TABLE cal_chd_death_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS chd_death_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    (    o.cod LIKE 'I20%' 
      OR o.cod LIKE 'I21%'
      OR o.cod LIKE 'I22%'
      OR o.cod LIKE 'I23%'
      OR o.cod LIKE 'I24%' 
      OR o.cod LIKE 'I25%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_chd_death_ons( anonpatid );
DROP TABLE IF EXISTS cal_death_gprd;
CREATE TABLE cal_death_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS death_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 28927,13549,23077,67519,28801,43009,98237,61220,23888,48491,23074,27505,11374,18169,32129,15986,30333,23073,46304,26812,39311,58563,50388,21195,46108,6855,41065,56960,33249,35909,40882,7962,71596,39580,18447,30400,28645,30357,15858,23830,1448,50144,73170,27899,13556,73130,48986,46606,13555,93203,69264,48438,13550,28879,8706,1868,28378,58043,66176,1127,13551,20540,28687,65328,6811,6576,30500,66966,13553,51482,19628,46616,15337,6897,44361,56106,23075,62863,49947,6991,31121,35520,9059,30327,7847,94234,46349,17680 );

-- CREATE INDEX anonpatid ON cal_death_gprd( anonpatid );DROP TABLE IF EXISTS cal_haem_stroke_ons;
CREATE TABLE cal_haem_stroke_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS haem_stroke_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'I61%' OR o.cod LIKE 'I629%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_haem_stroke_ons( anonpatid );
DROP TABLE IF EXISTS cal_hf_ons;
CREATE TABLE cal_hf_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS hf_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( 
      o.cod LIKE 'I130%' 
      OR o.cod LIKE 'I132%' 
      OR o.cod LIKE 'I110%' 
      OR o.cod LIKE 'I50%'  
    )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_hf_ons( anonpatid );
DROP TABLE IF EXISTS cal_isch_stroke_ons;
CREATE TABLE cal_isch_stroke_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS isch_stroke_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'I63%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_isch_stroke_ons( anonpatid );

DROP TABLE IF EXISTS cal_mi_death_gprd;
CREATE TABLE cal_mi_death_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   CASE
   WHEN c.data1 = '0' THEN 5
   WHEN c.data1 = '1' THEN 1
   WHEN c.data1 = '2' THEN 2
   WHEN c.data1 = '3' THEN 3
   WHEN c.data1 = '4' THEN 4
   ELSE 9 
   END mi_death_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 12229, 10562, 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,35674,15661,30421,9555,59189,36423,38609,50372,29553,13566,5387,16408,14658,14898,62626,40429,37657,72562,8935,17464,3704,9507,23579,61670,96838,68357,29758,4017,69474,34803,28736,18842,1678,23892,40399,14897,32272,46166,17689,46112 )
AND
   c.enttype = 149

UNION

SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   6 AS mi_death_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 12229, 10562, 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,35674,15661,30421,9555,59189,36423,38609,50372,29553,13566,5387,16408,14658,14898,62626,40429,37657,72562,8935,17464,3704,9507,23579,61670,96838,68357,29758,4017,69474,34803,28736,18842,1678,23892,40399,14897,32272,46166,17689,46112 )
AND
   c.enttype = 148
AND
   c.data1 != '0'

ORDER BY anonpatid;

DELETE FROM cal_mi_death_gprd WHERE mi_death_gprd = 9;

-- 
-- 
-- +------+------------------+
-- | code | label            |
-- +------+------------------+
-- |    0 | Data Not Entered |  5
-- |    1 | Category Ia      |  1 
-- |    2 | Category Ib      |  2
-- |    3 | Category Ic      |  3
-- |    4 | Category II      |  4  
-- +------+------------------+




-- STEMI: 12229
-- NSTEMI: 10562
-- MI NOS: 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,35674,15661,30421,9555,59189,36423,38609,50372,29553,13566,5387,16408,14658,14898,62626,40429,37657,72562,8935,17464,3704,9507,23579,61670,96838,68357,29758,4017,69474,34803,28736,18842,1678,23892,40399,14897,32272,46166,17689,46112

DROP TABLE IF EXISTS cal_mi_ons;
CREATE TABLE cal_mi_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS mi_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'I21%' OR o.cod LIKE 'I22%' OR o.cod LIKE 'I23%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_mi_ons( anonpatid );
DROP TABLE IF EXISTS cal_ons;
CREATE TABLE cal_ons AS
SELECT
   o.anonpatid,
   o.dod,
   o.cod,
   o.cod_1,
   o.cod_2,
   o.cod_3,
   o.cod_4,
   o.cod_5,
   o.cod_6,
   o.cod_7,
   o.cod_8,
   o.cod_9,
   o.cod_10,
   o.cod_11,
   o.cod_12,
   o.cod_13,
   o.cod_14,
   o.cod_15
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_ons( anonpatid );

DROP TABLE IF EXISTS cal_stroke_nos_ons;
CREATE TABLE cal_stroke_nos_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS stroke_nos_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( 
      o.cod LIKE 'I64%' 
      OR
      o.cod LIKE 'I679%'
      OR
      o.cod LIKE 'I672%'
     )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_stroke_nos_ons( anonpatid );

DROP TABLE IF EXISTS cal_subarachnoid_stroke_ons;
CREATE TABLE cal_subarachnoid_stroke_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS subarachnoid_stroke_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'I60%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_subarachnoid_stroke_ons( anonpatid );
DROP TABLE IF EXISTS cal_sudden_death_gprd;
CREATE TABLE cal_sudden_death_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN c.medcode IN ( 56106,30500,67519,32129,15986,35520,30327,7962,15337,17680,58563 ) THEN 1
   WHEN c.medcode IN ( 61220,93203,23075,73130,23830,6811 ) THEN 2
   WHEN c.medcode = 21195 THEN 3
   ELSE 9 
   END sudden_death_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_sudden_death_gprd WHERE sudden_death_gprd = 9;


-- cat 1 : 56106,30500,67519,32129,15986,35520,30327,7962,15337,17680,58563
-- cat 2 : 61220,93203,23075,73130,23830,6811
-- cat 3 : 21195
-- all   : 56106,30500,67519,32129,15986,35520,30327,7962,15337,17680,58563,61220,93203,23075,73130,23830,6811,21195


DROP TABLE IF EXISTS cal_sudden_death_hes;
CREATE TABLE cal_sudden_death_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN (icd LIKE 'R98%'  OR icd LIKE 'R99%') THEN 1
    WHEN (icd LIKE 'R961%' OR icd LIKE 'R960%' OR icd LIKE 'R96%') THEN 2
    WHEN (icd LIKE 'I461%') THEN 3
    ELSE 9 
    END sudden_death_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_sudden_death_hes WHERE sudden_death_hes = 9;

UPDATE
    cal_sudden_death_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_sudden_death_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_sudden_death_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_sudden_death_ons;
CREATE TABLE cal_sudden_death_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS sudden_death_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'I461%' OR o.cod LIKE 'R96%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_sudden_death_ons( anonpatid );
DROP TABLE IF EXISTS cal_cancer_ons;
CREATE TABLE cal_cancer_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS cancer_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'C%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_cancer_ons( anonpatid );DROP TABLE IF EXISTS cal_copd_ons;
CREATE TABLE cal_copd_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS copd_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'J40%' OR o.cod LIKE 'J41%' OR o.cod LIKE 'J42%' 
      OR o.cod LIKE 'J43%' OR o.cod LIKE 'J44%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_copd_ons( anonpatid );DROP TABLE IF EXISTS cal_liver_disease_ons;
CREATE TABLE cal_liver_disease_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS liver_disease_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
AND
    ( o.cod LIKE 'K70%' OR o.cod LIKE 'K72%' OR o.cod LIKE 'K73%' 
      OR o.cod LIKE 'K74%' OR o.cod LIKE 'K75%' OR o.cod LIKE 'K76%' )

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_liver_disease_ons( anonpatid );DROP TABLE IF EXISTS cal_otherdeath_ons;
CREATE TABLE cal_otherdeath_ons AS
SELECT
    o.anonpatid,
    o.dod,
    o.cod,
    1 AS otherdeath_ons
FROM
   ons o,
   patient p
WHERE
   p.anonpatid = o.anonpatid
    AND o.cod NOT LIKE 'J40%' 
    AND o.cod NOT LIKE 'J41%' 
    AND o.cod NOT LIKE 'J42%' 
    AND o.cod NOT LIKE 'J43%' 
    AND o.cod NOT LIKE 'J44%'
    AND o.cod NOT LIKE 'K70%' 
    AND o.cod NOT LIKE 'K72%' 
    AND o.cod NOT LIKE 'K73%' 
    AND o.cod NOT LIKE 'K74%' 
    AND o.cod NOT LIKE 'K75%' 
    AND o.cod NOT LIKE 'K76%'
    AND o.cod NOT LIKE 'C%'
    AND o.cod NOT LIKE 'G45%'
    AND o.cod NOT LIKE 'I01%'
    AND o.cod NOT LIKE 'I03%'
    AND o.cod NOT LIKE 'I04%'
    AND o.cod NOT LIKE 'I05%'
    AND o.cod NOT LIKE 'I06%'
    AND o.cod NOT LIKE 'I07%'
    AND o.cod NOT LIKE 'I08%'
    AND o.cod NOT LIKE 'I09%'
    AND o.cod NOT LIKE 'I1%'
    AND o.cod NOT LIKE 'I2%'
    AND o.cod NOT LIKE 'I3%'
    AND o.cod NOT LIKE 'I4%'
    AND o.cod NOT LIKE 'I5%'
    AND o.cod NOT LIKE 'I6%'
    AND o.cod NOT LIKE 'I7%'
    AND o.cod NOT LIKE 'I80%'
    AND o.cod NOT LIKE 'I81%'
    AND o.cod NOT LIKE 'I82%'
    AND o.cod NOT LIKE 'I87%'
    AND o.cod NOT LIKE 'I9%'
    AND o.cod NOT LIKE 'Q2%'
    AND o.cod NOT LIKE 'R96%' 

AND 
   p.gender IN (1,2);

-- CREATE INDEX anonpatid ON cal_otherdeath_ons( anonpatid );
DROP TABLE IF EXISTS cal_chronicanaemia_gprd;
CREATE TABLE cal_chronicanaemia_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN (2743,83476,39324,27270,96959,44527,35783,8364,96960,62073,35504,10597,13416,7918,70616,12863,49388,37654,56208,9044,23004,13303,4526,33303,32225,15731,45929,87223,6577,23003,22033,92968,19901,54530,11759,48982,46353,65355,14242,97180 ),
      0,
      WHEN
         c.medcode IN ( 31214,54738,24953,5833,21370,21335 ),
         1, 
         WHEN
            c.medcode IN ( 16052,58695,57298,4839,44420,19383,882,34934,94528,25394,12176,739,15936,40750,41699,4670,16109,30637,1702,48145,10817,60186,31040,25876,35160,51169,3981,33278,72276,66137,19951,53422,28768,71840,6816,94921,23875,47225,31550,19130,16929,56756,94387,22890,797,15358,3265,539,57954,43330,31205 ),
            3,
            WHEN
                c.medcode IN ( 2054,33708,21119,29601,1668,15633,33634,1771 ),
                4,
                WHEN
                    c.medcode IN ( 44913,61462,27939,72252,69379,37320,682,31248,683,47438,72973,34754,53052,69027,7225,15495,69061,19574,64625,40094,13299,70762 ),
                    5,
                    WHEN
                        c.medcode IN ( 3616,23519,57397,11874,32937,8119,31306,31370,69964,93872,48295 ),
                        6,
                        WHEN
                            c.medcode IN ( 8866,31075,57144,32943,4666,54429,1171,45151,37808,27761,21643,9864,1174,46733,12235,31405,73946 ),
                            7,
                            WHEN
                                c.medcode IN ( 43825,15422,71965,32715,37539,57859,57114,68087,31774,16108,43166,69269,40244,15658,65351,21723,72104,70128,65502,66239,34953,30994,41142 ),
                                8,
                                WHEN
                                    c.medcode IN ( 39456,43367,18631,57575,67088,29933,39944,3818,3326,35612,57897,71808,94214,29323,49182,7237,31107,27771,63936,31734,14698,38327,50495,55561,22531,44381,39967,72721,49451,39876,15314 ),
                                    9,
                                    WHEN
                                        c.medcode IN ( 92106,10506,26327,795,55370,55481,32953,7841,8054,24870,9537,62637,11961,29486,33420,48338,64601,4858,4080,2482,70835,4475,51489,53846,98709,53783,22715,56973,15439,57274,56348,21127,18137,53799,2813,47952,69275,27726,59103,36634,42117,58136,37082,2464,5271,6028,56114,31270,2452,35092,62257 ),
                                        10,
                                        999 ) ) ) ) ) ) ) ) ) ) AS chronicanaemia_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   chronicanaemia_gprd != 999;

-- CREATE INDEX anonpatid ON cal_chronicanaemia_gprd( anonpatid );
DROP TABLE IF EXISTS cal_chronicanaemia_hes;
CREATE TABLE cal_chronicanaemia_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
           icd LIKE 'D63%'
        OR icd LIKE 'D461%'
        OR icd LIKE 'D55%'
        OR icd LIKE 'D465%'
        OR icd LIKE 'D464%'
        OR icd LIKE 'D460%'
        OR icd LIKE 'D64%'
        OR icd LIKE 'D462%',
        3,
        WHEN
            icd LIKE 'O990%',
            4,
            WHEN
                   icd LIKE 'P613%'
                OR icd LIKE 'P589%'
                OR icd LIKE 'P588%'
                OR icd LIKE 'P612%'
                OR icd LIKE 'P569%'
                OR icd LIKE 'P558%'
                OR icd LIKE 'P559%'
                OR icd LIKE 'P614%',
                5,
                WHEN
                    icd LIKE 'D57%',
                    6,
                    WHEN
                        icd LIKE 'D562%'
                        OR icd LIKE 'D561%'
                        OR icd LIKE 'D563%'
                        OR icd LIKE 'D560%'
                        OR icd LIKE 'D569%'
                        OR icd LIKE 'D568%',
                        7,
                        WHEN
                            icd LIKE 'D61%' 
                            OR icd LIKE 'D60%',
                            8,
                            WHEN
                                icd LIKE 'D58%' 
                                OR icd LIKE 'D59%',
                                9,
                                WHEN
                                    icd LIKE 'D53%'
                                    OR icd LIKE 'D50%'
                                    OR icd LIKE 'D52%'
                                    OR icd LIKE 'D51%',
                                    10,
                                    999 ) ) ) ) ) ) ) ) AS chronicanaemia_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    chronicanaemia_hes != 999;

UPDATE
    cal_chronicanaemia_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_chronicanaemia_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_chronicanaemia_hes DROP COLUMN spno;

-- CREATE INDEX anonpatid ON cal_chronicanaemia_hes( anonpatid );
-- Generated: 2013-07-11 16:35:41
   DROP TABLE IF EXISTS cal_myelodysplasia_gprd;

   CREATE TABLE cal_myelodysplasia_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 14927,22890,10817,23875,44420,45285,4561,19130,56756,60186,94921,45143,16052 );

   -- CREATE INDEX anonpatid ON cal_myelodysplasia_gprd( anonpatid );

   ALTER TABLE cal_myelodysplasia_gprd ADD COLUMN myelodysplasia_gprd INT DEFAULT NULL;

   UPDATE cal_myelodysplasia_gprd SET myelodysplasia_gprd = '1' WHERE medcode IN ( 16052,94921,60186,23875,44420,19130,56756,22890,4561,45143,14927,10817,45285 );



-- Generated: 2013-07-11 16:36:01
    DROP TABLE IF EXISTS cal_myelodysplasia_hes;

    CREATE TABLE cal_myelodysplasia_hes AS
    SELECT
        anonpatid,
        admidate   AS date_admission,
        discharged AS date_discharge,
        spno,
        icd,
        0 AS epi_primary,
        0 AS hosp_primary
    FROM
        hes_diag_hosp h
    WHERE
        (   ( icd LIKE 'D46%' )  );

    -- CREATE INDEX anonpatid ON cal_myelodysplasia_hes( anonpatid );

    UPDATE
        cal_myelodysplasia_hes c,
        hes_diag_epi h
    SET
        c.epi_primary = 1 
    WHERE
        c.anonpatid = h.anonpatid
    AND
        c.spno = h.spno
    AND
        c.icd = h.icd
    AND
        h.`primary` = 1;

     UPDATE
         cal_myelodysplasia_hes c,
         hes_primary_diag_hosp h
     SET
         c.hosp_primary = 1 
     WHERE
         c.anonpatid = h.anonpatid
     AND
         c.spno = h.spno
     AND
         c.icd = h.primary_icd;

     ALTER TABLE cal_myelodysplasia_hes ADD COLUMN myelodysplasia_hes INT DEFAULT NULL;

    UPDATE cal_myelodysplasia_hes SET myelodysplasia_hes = '1' WHERE (  ( icd LIKE 'D46%' ) );
ALTER TABLE cal_myelodysplasia_hes DROP COLUMN spno;



DROP TABLE IF EXISTS cal_basophils_gprd;
CREATE TABLE cal_basophils_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS basophils_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 25, 27147, 53404, 27148, 27146 )
AND
    t.data2 < 10
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 313;

-- CREATE INDEX anonpatid ON cal_basophils_gprd( anonpatid );DROP TABLE IF EXISTS cal_eosinophils_gprd;
CREATE TABLE cal_eosinophils_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS eosinophils_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 22, 26906, 18531, 26905 )
AND
    t.data2 < 10
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 168;

-- CREATE INDEX anonpatid ON cal_eosinophils_gprd( anonpatid );

DROP TABLE IF EXISTS cal_haemoglobin_gprd;
CREATE TABLE cal_haemoglobin_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS haemoglobin_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 4, 10404, 35749, 3942, 26910, 26909, 26272, 26913, 41531, 26908, 26912, 13, 13596, 23817, 16387, 13860 )
AND
    t.data3 IN (56, 57, 0)
AND
    t.enttype = 173
AND
    ( ( t.data2 > 3 AND t.data2 < 25 ) OR ( t.data2 > 30 AND t.data2 < 250 ) );

-- CREATE INDEX anonpatid ON cal_haemoglobin_gprd( anonpatid );

UPDATE cal_haemoglobin_gprd 
SET haemoglobin_gprd = haemoglobin_gprd / 10 
WHERE haemoglobin_gprd >30 
AND haemoglobin_gprd < 250;








DROP TABLE IF EXISTS cal_lymphocytes_gprd;
CREATE TABLE cal_lymphocytes_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS lymphocytes_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 19, 23120, 23121, 37677, 42346, 26950, 34551, 26949, 3189, 11240 )
AND
    t.data2 < 50
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 208;

-- CREATE INDEX anonpatid ON cal_lymphocytes_gprd( anonpatid );







DROP TABLE IF EXISTS cal_monocytes_gprd;
CREATE TABLE cal_monocytes_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS monocytes_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 21, 26924, 26925, 72849, 26923, 44189, 13776, 9248 )
AND
    t.data2 < 10
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 183;

-- CREATE INDEX anonpatid ON cal_monocytes_gprd( anonpatid );






DROP TABLE IF EXISTS cal_neutrophils_gprd;
CREATE TABLE cal_neutrophils_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS neutrophils_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 18, 23112, 4463, 15725, 31382, 13777 )
AND
    t.data2 < 50
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 184;

-- CREATE INDEX anonpatid ON cal_neutrophils_gprd( anonpatid );










DROP TABLE IF EXISTS cal_platelets_gprd;
CREATE TABLE cal_platelets_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS platelets_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 7, 26927, 4006, 3320, 4415, 26926 )
AND
    t.data2 < 1500
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 189;

-- CREATE INDEX anonpatid ON cal_platelets_gprd( anonpatid );





DROP TABLE IF EXISTS cal_total_wbc_gprd;
CREATE TABLE cal_total_wbc_gprd AS

SELECT 
    t.anonpatid,
    t.eventdate,
    t.data2 AS total_wbc_gprd,
    t.data3 AS units
FROM
    test t,
    patient p
WHERE
    t.anonpatid = p.anonpatid

AND
    t.medcode IN ( 15, 13817, 13818, 26948, 26325, 1955, 22293, 18516, 4996, 26947, 48015, 26946, 3372, 53865, 92372, 4760 )
AND
    t.data2 < 50
AND
    t.data3 IN (37, 153, 17)
AND
    t.enttype = 207;

-- CREATE INDEX anonpatid ON cal_total_wbc_gprd( anonpatid );




DROP TABLE IF EXISTS cal_diabcomp_gprd;
CREATE TABLE cal_diabcomp_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 13104,13100 ),
      0,
      WHEN
         c.medcode IN ( 18390,16502,2475,66872,61344,46963,2471,18209,24836,59365,13279,45499,18777,30294,93922,35107,30323,12640,50225,57278,57621,21983,52303,35105,64571,26054,11848,10418,85991,60796,47582 ),
         1, 
         WHEN
            c.medcode IN ( 2340,40962,55842,22573,95351,37315,61829,39317,67853,41716,47816,59903,35385,66965,7795,16491,72320,18425,61523,54008,5002,17067,98616,47409,34268,48078,24694,46301,35785,44033,24571,39809,42831,27891,39420,52283,55239,67905,50527,16230,18230,17247,11663,68105,50813,60208,49146,63690,45919,2342,91943,31790,62674,45467 ),
            2,
            WHEN
                c.medcode IN (                  47649,17545,98071,10659,93727,44260,50429,34283,48192,44982,47377,33254,59725,69278,44779,47321,41389,70316,49276,49554,69748 ),
                3,
                WHEN
                    c.medcode IN (18496,6509,11626,22967,49655,95343,93875,58604,17262,18387,41049,38161,42762,1323  ),
                    4,
                    WHEN
                        c.medcode IN ( 7069,11129,11433 ),
                        5,
                        WHEN
                            c.medcode IN (13099,65463,10755,13103,47584,2986 ),
                            6,
                            WHEN
                                c.medcode IN ( 30477,13101,3286,52630,13097 ),
                                7,
                                WHEN
                                    c.medcode IN ( 1599,47328,52041 ), 
                                    8,
                                    WHEN
                                        c.medcode IN ( 22871,13108,9835,10099,25591,97894,13102,3837 ),
                                        9,
                                        10 ) ) ) ) ) ) ) ) ) ) AS diabcomp_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   diabcomp_gprd != 10;DROP TABLE IF EXISTS cal_diabcomp_hes;
CREATE TABLE cal_diabcomp_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        (    icd LIKE 'E142%'
          OR icd LIKE 'N083%' 
          OR icd LIKE 'E122%'
          OR icd LIKE 'E112%'
          OR icd LIKE 'E132%'
          OR icd LIKE 'E102%' ),
        1,
        WHEN
            (      icd LIKE 'E134%'
                OR icd LIKE 'E114%'
                OR icd LIKE 'G590%'
                OR icd LIKE 'G632%'
                OR icd LIKE 'E124%'
                OR icd LIKE 'E104%'
                OR icd LIKE 'E144%' ),
            2,
            WHEN
                ( 
                 icd like 'E113?%'
                 OR icd LIKE 'E133%'
                 OR icd LIKE 'E123%'
                 OR icd LIKE 'E103%'
                 OR icd LIKE 'E143%' ),
                3,
                WHEN 
                    icd LIKE 'H360%', 
                    4,
                    9 ) ) ) ) AS diabcomp_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    diabcomp_hes != 9;

UPDATE
    cal_diabcomp_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_diabcomp_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_diabcomp_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_diabdiag_gprd;

CREATE TABLE cal_diabdiag_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 17545,95992,91942,66872,69676,61829,61344,18642,93878,66145,62613,18387,51957,70766,54008,18683,95343,39070,17858,40837,49554,41049,46301,49949,35288,47582,62352,97446,47649,60107,42831,46850,47650,22871,62209,55239,97894,38161,63017,93468,97474,18230,1549,30294,68105,12455,30323,40682,45914,49146,60208,21983,96235,24423,42729,10692,91943,69993,10418,43921,68390 ),
      3,
      WHEN
         c.medcode IN ( 62107,93727,61071,18278,46150,59253,47816,44779,91646,34450,57278,18219,34268,26054,54899,24458,18264,51756,59725,50527,53392,18777,50225,50813,63690,49655,64571,56268,65704,49074,65267,17859,95351,44982,22884,24836,47315,42762,43227,66965,47321,35385,18425,12640,70316,758,25627,47409,98616,60699,25591,45913,64668,1407,32627,18390,98723,48192,47954,58604,18209,67905,18143,37806,49869,12736,18496,46917,36633,45919,55075,85991,60796,62674 ),
         4, 
         9 ) ) AS diabdiag_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   diabdiag_gprd != 9;

DROP TABLE IF EXISTS cal_diabetes_meds;
CREATE TABLE cal_diabetes_meds AS
SELECT
   d1.anonpatid,
   1 AS diabetes_meds
FROM
   cal_drugs_6_1_1 d1
WHERE
   anonpatid NOT IN ( SELECT anonpatid FROM cal_drugs_6_1_2 )

UNION 

SELECT
   d2.anonpatid,
   2 AS diabetes_meds
FROM
   cal_drugs_6_1_2 d2
WHERE
   anonpatid NOT IN ( SELECT anonpatid FROM cal_drugs_6_1_1 )

UNION

SELECT
   d61.anonpatid,
   3 AS diabetes_meds
FROM 
   cal_drugs_6_1_1 d61, 
   cal_drugs_6_1_2 d62 
where 
   d61.anonpatid = d62.anonpatid 
AND 
   d61.eventdate = d62.eventdate;
   

DROP TABLE IF EXISTS cal_dm;
CREATE TABLE cal_dm AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 6813,7045,18766,54846,28622,17236 ),
      1, # H/O
      WHEN
         c.medcode IN ( 11094,31141,31241,97281,42217,66475,12030,32619,46533,57389,95813,9974,94956,13192,94699,93529,68818,32739,18747,46521,13057,17478,9145,13070,95093,54601,45250,22130,47032,13197,50937,95159,97824,12507,34528,28574,31240,47011,67664,11348,93390,95553,38103,8618,93631,3550,93704,94186,13195,93491,2379,30648,57723,94011,12247,13067,17886,61470,47058,91164,26605,10824,68546,38130,95094,38129,63412,47341,93657,97809,11930,55140,17846,20900,6430,58133,12682,93854,11041,9897,13194,608,94955,93870,12703,19381,26603 ),
         2, # Possible diabetes
         WHEN
            c.medcode IN ( 6791,98071,44260,91942,64446,18642,46963,66145,62613,53200,51957,42567,97849,32359,54008,60499,18683,44440,49554,24694,52104,46301,49949,62352,18505,69043,47650,46850,98704,31310,63017,93468,1549,56448,12455,30323,40682,54600,57621,21983,96235,42729,93875,10692,10418,43921,98392,95992,17545,66872,69676,61344,61829,93878,67853,41716,18387,69124,70766,72702,6509,95343,26855,39070,17858,40837,70448,85660,41049,51261,69748,35288,47582,97446,47649,60107,1038,39809,42831,40023,68792,22871,62209,55239,97894,52283,38161,44443,97474,18230,43493,38076,30294,65616,68105,93922,45276,1647,45914,49146,60208,24423,50960,24490,91943,69993,49276,68390 ),
            3, # T1 DM
            WHEN
               c.medcode IN ( 62107,55842,93727,61071,18278,46150,39317,59253,47816,69278,14889,44779,91646,62146,34450,57278,18219,50609,34268,26054,54899,24458,18264,37648,51756,54856,43139,5884,59725,43785,50527,53392,36695,29979,14803,18777,50813,50225,41389,63690,49655,63371,64571,33807,56268,40962,49074,65704,65267,4513,17859,50429,25041,44982,95351,22884,68843,506,24836,47315,46624,59365,43227,42762,35385,47321,66965,72320,12640,18425,25627,758,70316,98616,52303,47409,60699,83532,25591,64668,45913,1407,32627,18390,98723,48192,59991,47954,95636,8403,63762,18209,58604,67905,18143,37806,56803,49869,46917,18496,12736,36633,45919,24693,55075,35105,63357,54212,17262,40401,34912,85991,60796,62674,45467 ),
               4, # T2 DM
               WHEN 
                  c.medcode IN ( 67212,95539,94383,26108,93380,11551,51697,61122,32193,96506,22487 ),
                  5, # Secondary
                  WHEN
                     c.medcode IN ( 62384,34283,95994,47377,83485,49640,10755,13108,2471,17095,16491,13279,8414,26664,5002,17067,23479,52630,2986,18056,43857,34152,31171,47370,17817,18311,32556,11433,72345,33254,39420,16490,50175,65684,10977,69152,31053,35383,50972,25636,7563,13099,64142,18662,21482,22823,12506,13103,47144,22967,9013,47328,24363,7059,13071,6125,12307,7795,52041,3286,61021,49884,61523,38986,35321,96010,10642,48078,44033,65025,1684,35316,17869,61670,66675,35107,35399,59288,12483,11129,53634,45491,41686,21689,11677,28873,2478,16881,2340,55123,65463,13074,22573,21472,11626,2475,37315,11599,15690,24327,55431,11018,52212,58159,9881,43453,1682,52236,38617,31172,35785,90301,28856,16502,7069,70073,64357,43951,33343,42505,16230,17247,13078,68928,11663,64449,12213,35116,38078,2378,19739,46290,20696,57333,31790,26667,10098,46577,10659,10099,17313,18142,11471,9835,26666,12262,31156,31157,13102,70821,59903,13097,53238,27921,32403,66274,47584,11848,3837,1323,24571,64283,18824,27891,7328,13101,8836,12675,29041,30477,26604,33969,28769,52237,22023,8842,58639,65062,13069,2342,61210,36798,711,18167,13196 ),
                     6, # NOS
                     WHEN
                        c.medcode = 19203,
                        7, # Excluded
                        9 ) ) ) ) ) ) ) AS dm
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   dm != 9
ORDER BY
   anonpatid;
   
INSERT INTO cal_dm
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.enttype IN ( 18, 22 ),
      5, # Secondary diabetes
      WHEN
         c.enttype = 26 AND c.data1 IN ( 1,2,3 ),
         5, # Secondary diabetes
         WHEN
            c.enttype = 26 AND c.data1 = 6,
            8, # Diabetes resolved
            9 ) ) ) AS dm
FROM
   clinical c,
   patient p
WHERE
   c.eventdate IS NOT NULL
AND
   c.medcode IN ( 6813,7045,18766,54846,28622,17236,11094,31141,31241,97281,42217,66475,12030,32619,46533,57389,95813,9974,94956,13192,94699,93529,68818,32739,18747,46521,13057,17478,9145,13070,95093,54601,45250,22130,47032,13197,50937,95159,97824,12507,34528,28574,31240,47011,67664,11348,93390,95553,38103,8618,93631,3550,93704,94186,13195,93491,2379,30648,57723,94011,12247,13067,17886,61470,47058,91164,26605,10824,68546,38130,95094,38129,63412,47341,93657,97809,11930,55140,17846,20900,6430,58133,12682,93854,11041,9897,13194,608,94955,93870,12703,19381,26603,6791,98071,44260,91942,64446,18642,46963,66145,62613,53200,51957,42567,97849,32359,54008,60499,18683,44440,49554,24694,52104,46301,49949,62352,18505,69043,47650,46850,98704,31310,63017,93468,1549,56448,12455,30323,40682,54600,57621,21983,96235,42729,93875,10692,10418,43921,98392,95992,17545,66872,69676,61344,61829,93878,67853,41716,18387,69124,70766,72702,6509,95343,26855,39070,17858,40837,70448,85660,41049,51261,69748,35288,47582,97446,47649,60107,1038,39809,42831,40023,68792,22871,62209,55239,97894,52283,38161,44443,97474,18230,43493,38076,30294,65616,68105,93922,45276,1647,45914,49146,60208,24423,50960,24490,91943,69993,49276,68390,62107,55842,93727,61071,18278,46150,39317,59253,47816,69278,14889,44779,91646,62146,34450,57278,18219,50609,34268,26054,54899,24458,18264,37648,51756,54856,43139,5884,59725,43785,50527,53392,36695,29979,14803,18777,50813,50225,41389,63690,49655,63371,64571,33807,56268,40962,49074,65704,65267,4513,17859,50429,25041,44982,95351,22884,68843,506,24836,47315,46624,59365,43227,42762,35385,47321,66965,72320,12640,18425,25627,758,70316,98616,52303,47409,60699,83532,25591,64668,45913,1407,32627,18390,98723,48192,59991,47954,95636,8403,63762,18209,58604,67905,18143,37806,56803,49869,46917,18496,12736,36633,45919,24693,55075,35105,63357,54212,17262,40401,34912,85991,60796,62674,45467,67212,95539,94383,26108,93380,11551,51697,61122,32193,96506,22487,62384,34283,95994,47377,83485,49640,10755,13108,2471,17095,16491,13279,8414,26664,5002,17067,23479,52630,2986,18056,43857,34152,31171,47370,17817,18311,32556,11433,72345,33254,39420,16490,50175,65684,10977,69152,31053,35383,50972,25636,7563,13099,64142,18662,21482,22823,12506,13103,47144,22967,9013,47328,24363,7059,13071,6125,12307,7795,52041,3286,61021,49884,61523,38986,35321,96010,10642,48078,44033,65025,1684,35316,17869,61670,66675,35107,35399,59288,12483,11129,53634,45491,41686,21689,11677,28873,2478,16881,2340,55123,65463,13074,22573,21472,11626,2475,37315,11599,15690,24327,55431,11018,52212,58159,9881,43453,1682,52236,38617,31172,35785,90301,28856,16502,7069,70073,64357,43951,33343,42505,16230,17247,13078,68928,11663,64449,12213,35116,38078,2378,19739,46290,20696,57333,31790,26667,10098,46577,10659,10099,17313,18142,11471,9835,26666,12262,31156,31157,13102,70821,59903,13097,53238,27921,32403,66274,47584,11848,3837,1323,24571,64283,18824,27891,7328,13101,8836,12675,29041,30477,26604,33969,28769,52237,22023,8842,58639,65062,13069,2342,61210,36798,711,18167,13196,19203 )
AND
   c.anonpatid = p.anonpatid

AND
   p.gender IN (1,2)
HAVING 
   dm != 9
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_dm_hes;
CREATE TABLE cal_dm_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'E103%'
          OR icd LIKE 'E107%'
          OR icd LIKE 'E100%'
          OR icd LIKE 'E10%'
          OR icd LIKE 'E101%'
          OR icd LIKE 'E105%'
          OR icd LIKE 'E106%'
          OR icd LIKE 'E108%'
          OR icd LIKE 'E104%'
          OR icd LIKE 'E109%'
          OR icd LIKE 'E102%' ),
        3,
        WHEN
            ( icd LIKE 'E114%'
              OR icd LIKE 'E111%'
              OR icd LIKE 'E118%'
              OR icd LIKE 'E117%'
              OR icd LIKE 'E115%'
              OR icd LIKE 'E110%'
              OR icd LIKE 'E113%'
              OR icd LIKE 'E116%'
              OR icd LIKE 'E112%'
              OR icd LIKE 'E119%'
              OR icd LIKE 'E11%' ),
            4,
            WHEN
                ( icd LIKE 'E12%'
                  OR icd LIKE 'E124%'
                  OR icd LIKE 'E129%'
                  OR icd LIKE 'E127%'
                  OR icd LIKE 'E125%'
                  OR icd LIKE 'E122%'
                  OR icd LIKE 'E120%'
                  OR icd LIKE 'O242%'
                  OR icd LIKE 'E121%'
                  OR icd LIKE 'E128%'
                  OR icd LIKE 'E126%'
                  OR icd LIKE 'E123%' ),
                5,
                WHEN
                    ( icd LIKE 'O243%'
                      OR icd LIKE 'E145%'
                      OR icd LIKE 'E133%'
                      OR icd LIKE 'E140%'
                      OR icd LIKE 'E13%'
                      OR icd LIKE 'E148%'
                      OR icd LIKE 'E146%'
                      OR icd LIKE 'E14%'
                      OR icd LIKE 'G590A%'
                      OR icd LIKE 'H360A%'
                      OR icd LIKE 'N083A%'
                      OR icd LIKE 'E141%'
                      OR icd LIKE 'E132%'
                      OR icd LIKE 'O241%'
                      OR icd LIKE 'O240%'
                      OR icd LIKE 'E138%'
                      OR icd LIKE 'E137%'
                      OR icd LIKE 'E136%'
                      OR icd LIKE 'E135%'
                      OR icd LIKE 'E149%'
                      OR icd LIKE 'E130%'
                      OR icd LIKE 'E143%'
                      OR icd LIKE 'H280A%'
                      OR icd LIKE 'E134%'
                      OR icd LIKE 'E131%'
                      OR icd LIKE 'E142%'
                      OR icd LIKE 'E147%'
                      OR icd LIKE 'G632A%'
                      OR icd LIKE 'E144%'
                      OR icd LIKE 'M142A%'
                      OR icd LIKE 'E139%' ),
                    6,
                    9 ) ) ) ) AS dm_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    dm_hes != 9;

UPDATE
    cal_dm_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_dm_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_dm_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_dyslipid;
CREATE TABLE cal_dyslipid AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 16085,
      1,
      WHEN
         c.medcode IN ( 50923,9936,30335,36806,6243,10783,93761,39147,97166,10899,51023,2091,8762,71747,340,32244 ),
         2, 
         WHEN
            c.medcode IN ( 67948,34224,59564,53091,97989,95952,18708,55855,16306,637,68741,42765,339,59095,33694,97890,16290,26019,5791,70793,3484,37273,7447,16534,34825,54499,66240,52992,3386,13228,39783,12569,34146,12439 ),
            3,
            9 ) ) ) AS dyslipid
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   dyslipid != 9
ORDER BY
   anonpatid;
   DROP TABLE IF EXISTS cal_dyslipid_hes;
CREATE TABLE cal_dyslipid_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'E788%'
          OR icd LIKE 'E784%'
          OR icd LIKE 'E781%'
          OR icd LIKE 'E786%'
          OR icd LIKE 'E785%'
          OR icd LIKE 'E780%'
          OR icd LIKE 'E78%'
          OR icd LIKE 'E783%'
          OR icd LIKE 'E789%'
          OR icd LIKE 'E782%' ),
        3, 
        9 ) AS dyslipid_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    dyslipid_hes != 9;

UPDATE
    cal_dyslipid_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_dyslipid_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_dyslipid_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_hdl_ldl_ratio;
CREATE TABLE cal_hdl_ldl_ratio AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   data2 AS hdl_ldl_ratio,
   data3 AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 338, 288 )
AND
   t.medcode = 14369
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 1, 151, 161 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   hdl_ldl_ratio > 0
AND
   hdl_ldl_ratio <= 0.99999
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_HDL_plasma;
CREATE TABLE cal_HDL_plasma AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS HDL_plasma,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
  t.enttype IN ( 175, 288 )
AND
   t.medcode IN ( 26915,34548, 13762 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   HDL_plasma > 0
AND
   HDL_plasma <= 50
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_HDL_serum;
CREATE TABLE cal_HDL_serum AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS HDL_serum,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.medcode IN ( 44,13761,13760 )
AND
   t.data1 = 3
AND
  t.enttype IN ( 175, 163, 288 )
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   HDL_serum > 0
AND
   HDL_serum <= 50
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_LDL_plasma;
CREATE TABLE cal_LDL_plasma AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS LDL_plasma,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 177, 288 )
AND
   t.medcode IN ( 33304,19764, 29699 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   LDL_plasma > 0
AND
   LDL_plasma <= 50
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_LDL_serum;
CREATE TABLE cal_LDL_serum AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS LDL_serum,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 177, 163, 288 )
AND
   t.medcode IN ( 65, 64, 46224, 13766, 13765)
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   LDL_serum > 0
AND
   LDL_serum <= 50
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_lipid_plasma_nos;
CREATE TABLE cal_lipid_plasma_nos AS
SELECT 
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS lipid_plasma_nos,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.enttype = 288
AND 
   t.medcode IN ( 57391,23884,55059,46225 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   lipid_plasma_nos > 0
AND
   lipid_plasma_nos <= 50
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_lipid_serum_nos;
CREATE TABLE cal_lipid_serum_nos AS
SELECT 
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS lipid_serum_nos,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 163, 288 )
AND 
   t.medcode IN ( 15195,14781,53539,7205,6363,23125,94177,23124,856,858,53538,62,67195,23244 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 92, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   lipid_serum_nos > 0
AND
   lipid_serum_nos <= 50
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_total_chol_plasma;
CREATE TABLE cal_total_chol_plasma AS
SELECT 
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2) , data2) ) AS total_chol_plasma,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.medcode = 18040
AND
   t.enttype = 288 
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   total_chol_plasma > 0
AND
   total_chol_plasma <= 50
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_total_chol_serum;
CREATE TABLE cal_total_chol_serum AS
SELECT 
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/38.61,2), data2) ) AS total_chol_serum,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units   
FROM
   test t,
   patient p
WHERE
   t.medcode IN ( 10940,26902,29202,18147,13733,12,622,35720,37206,18443,2493,12821 )
AND
   t.enttype IN ( 163, 288 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   total_chol_serum > 0
AND
   total_chol_serum <= 50
ORDER BY
   anonpatid;
   
DROP TABLE IF EXISTS cal_total_hdl_ratio;
CREATE TABLE cal_total_hdl_ratio AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   data2 AS total_hdl_ratio,
   data3 AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 163, 288, 338 )
AND
   t.medcode IN ( 14371,14105,40935,14372 ) 
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 1, 151, 161 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   total_hdl_ratio > 0
AND
   total_hdl_ratio <= 0.99999
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_TRI_plasma;
CREATE TABLE cal_TRI_plasma AS
SELECT
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/88.5,2), data2) ) AS TRI_plasma,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 202, 288 )
AND
   t.medcode IN ( 17416,63627,13834,13809 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   TRI_plasma > 0
AND
   TRI_plasma <= 50
ORDER BY
   anonpatid ;
DROP TABLE IF EXISTS cal_TRI_serum;
CREATE TABLE cal_TRI_serum AS
SELECT 
   DISTINCT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHENdata3=96, data2, WHENdata3=82, TRUNCATE(data2/88.5,2), data2) ) AS TRI_serum,
   WHENdata3=96, 1, WHENdata3=82, 2, 0) ) AS units
FROM
   test t,
   patient p
WHERE
   t.enttype IN ( 202, 288 )
AND 
   t.medcode IN ( 41074,26941,29559,26940,66037,38273,37,30870,13808 )
AND
   t.data1 = 3
AND
   t.data3 IN ( 0, 96, 82 )
AND
   t.anonpatid = p.anonpatid

AND
   t.eventdate IS NOT NULL
HAVING
   TRI_serum > 0
AND
   TRI_serum <= 50
ORDER BY
   anonpatid;-- Generated: 2013-02-18 12:12:26
   DROP TABLE IF EXISTS cal_hyperthyroid_gprd;

   CREATE TABLE cal_hyperthyroid_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 8038,6245,26362,48167,20035,64656,1472,1567,3194,677,26869,53981,57011,47695,26699,34220,68512,51273,44405,15565,49508,53280,46985,49361,11426,15790,26701,5257,49334,61498,72690,26702,10760,56270,23315,43136,48010,53667,65907,61026,1346,29296,95335,26833,11947,4898,70773,70244,65444,67972,3857,30799,21747,42323,20909,64856,58138 );

   -- CREATE INDEX anonpatid ON cal_hyperthyroid_gprd( anonpatid );

   ALTER TABLE cal_hyperthyroid_gprd ADD COLUMN hyperthyroid_gprd INT DEFAULT NULL;

   UPDATE cal_hyperthyroid_gprd SET hyperthyroid_gprd = '1' WHERE medcode IN ( 8038,6245,26362 );
UPDATE cal_hyperthyroid_gprd SET hyperthyroid_gprd = '3' WHERE medcode IN ( 48167,20035,64656,1472,1567,3194,677,26869,53981,57011,47695,26699,34220,68512,51273,44405,15565,49508,53280,46985,49361,11426,15790,26701,5257,49334,61498,72690,26702,10760,56270,23315,43136 );
UPDATE cal_hyperthyroid_gprd SET hyperthyroid_gprd = '4' WHERE medcode IN ( 48010 );
UPDATE cal_hyperthyroid_gprd SET hyperthyroid_gprd = '5' WHERE medcode IN ( 53667,65907,61026,1346,29296,95335,26833,11947,4898,70773,70244,65444,67972,3857,30799,21747,42323,20909 );
UPDATE cal_hyperthyroid_gprd SET hyperthyroid_gprd = '6' WHERE medcode IN ( 64856,58138 );
-- Generated: 2013-02-18 16:42:39
DROP TABLE IF EXISTS cal_hyperthyroid_hes;

CREATE TABLE cal_hyperthyroid_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    (   ( icd LIKE 'E051%' )  OR ( icd LIKE 'E059%' )  OR ( icd LIKE 'E052%' )  OR ( icd LIKE 'E055%' )  OR ( icd LIKE 'E050%' )  OR ( icd LIKE 'E053%' )  OR ( icd LIKE 'E058%' )  OR ( icd LIKE 'P721%' )  OR ( icd LIKE 'O905%' )  OR ( icd LIKE 'E06%' )  OR ( icd LIKE 'E054%' )  );

-- CREATE INDEX anonpatid ON cal_hyperthyroid_hes( anonpatid );

UPDATE
    cal_hyperthyroid_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

 UPDATE
     cal_hyperthyroid_hes c,
     hes_primary_diag_hosp h
 SET
     c.hosp_primary = 1 
 WHERE
     c.anonpatid = h.anonpatid
 AND
     c.spno = h.spno
 AND
     c.icd = h.primary_icd;

 ALTER TABLE cal_hyperthyroid_hes ADD COLUMN hyperthyroid_hes INT DEFAULT NULL;

UPDATE cal_hyperthyroid_hes SET hyperthyroid_hes = '3' WHERE (  ( icd LIKE 'E051%' ) OR  ( icd LIKE 'E059%' ) OR  ( icd LIKE 'E052%' ) OR  ( icd LIKE 'E055%' ) OR  ( icd LIKE 'E050%' ) OR  ( icd LIKE 'E053%' ) OR  ( icd LIKE 'E058%' ) );
UPDATE cal_hyperthyroid_hes SET hyperthyroid_hes = '4' WHERE (  ( icd LIKE 'P721%' ) );
UPDATE cal_hyperthyroid_hes SET hyperthyroid_hes = '5' WHERE (  ( icd LIKE 'O905%' ) OR  ( icd LIKE 'E06%' ) );
UPDATE cal_hyperthyroid_hes SET hyperthyroid_hes = '6' WHERE (  ( icd LIKE 'E054%' ) );

ALTER TABLE cal_hyperthyroid_hes DROP COLUMN spno;-- Generated: 2013-07-09 14:05:20
   DROP TABLE IF EXISTS cal_hypothyroid_gprd;

   CREATE TABLE cal_hypothyroid_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 3611,28735,46057,46630,46640,19367,85661,95885,85955,10097,69290,31612,93159,51481,93323,3290,1619,14704,273,28852,47521,50275,11322,51706,34221,25913,15743,97090,94915,38976,50860,31971,95830,24748,3941,20310,23014,18282,56722,59702,3436,39166,718,11146,73107,47658,61069,51416,58833 );

   -- CREATE INDEX anonpatid ON cal_hypothyroid_gprd( anonpatid );

   ALTER TABLE cal_hypothyroid_gprd ADD COLUMN hypothyroid_gprd INT DEFAULT NULL;

   UPDATE cal_hypothyroid_gprd SET hypothyroid_gprd = '1' WHERE medcode IN ( 3611 );
UPDATE cal_hypothyroid_gprd SET hypothyroid_gprd = '2' WHERE medcode IN ( 19367,28735,85661,46057,46640,46630 );
UPDATE cal_hypothyroid_gprd SET hypothyroid_gprd = '3' WHERE medcode IN ( 47658,18282,69290,20310,1619,31612,39166,38976,11146,28852,95830,273,51416,3290,56722,61069,24748,10097,51706,85955,718,73107,58833,97090,31971,15743,50860,93323,3436,11322,3941,23014,34221,14704,94915,95885,51481,47521,93159,59702,50275,25913 );



DROP TABLE IF EXISTS cal_alcoholism;
CREATE TABLE cal_alcoholism AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 24485,59574,7123,8430 ),
      1,
      WHEN
         c.medcode IN ( 18156 ),
         2, 
         WHEN
            c.medcode IN ( 32927,37605,20407,36296,2082,5758,26106,24064,6169,43193,16225,21624,56947,25110,64101,1476,20514,57939,9508,57714,40530,5740,2081,31443,17259,33635,2084,22277,28780 ),
            3,
            9 ) ) ) AS alcoholism
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   alcoholism != 9
ORDER BY
   anonpatid;

-- CREATE INDEX anonpatid ON cal_alcoholism( alcoholism );DROP TABLE IF EXISTS cal_alcohol_harm;
CREATE TABLE cal_alcohol_harm AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 65754 ),
      1,
      WHEN
         c.medcode IN ( 12353,16237,30162,67651,6467,39799,5611,54505,62000,65932,30404,20762,38061,68111,64389,45169,4500,44299,26323,17607,11106,27342,11670,18636,21879,41920,33670 ),
         2, 
         WHEN
            c.medcode IN ( 47555,37946,2925,33839,36748,37691,30604 ),
            3,
            WHEN
               c.medcode IN ( 4915,31742 ), 
               4,
               WHEN
                  c.medcode IN ( 4743,7602,10691,21713,24984,3216,7943,8363,17330,4506,7885 ),
                  5, 
                  9 ) ) ) ) ) AS cal_alcohol_harm
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   cal_alcohol_harm != 9
ORDER BY
   anonpatid;
   DROP TABLE IF EXISTS cal_alcohol_mgmt;
CREATE TABLE cal_alcohol_mgmt AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 97163,54209,18711,11740,97261,11491,32964,64409,12442,7692,37264,96053,63529,97309,11140 ),
      1,
      WHEN
         c.medcode IN ( 35330,95181,8030,61383,9489,96054,47123,96993,97680,30460,94553,9849,12554 )
         OR
         c.enttype = 7,
         2, 
         WHEN
            c.medcode IN ( 21412,48241,41983,46677,29691,8388,21650,2083,73876 ),
            3,
            9 ) ) ) AS alcohol_mgmt
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   alcohol_mgmt != 9
   
UNION

SELECT
   r.anonpatid,
   r.eventdate,
   r.medcode,
   WHEN
      r.medcode IN ( 12949,12970,4447,12979,967,22933,26471,19495,19493,12983,385,749,12971,2689,12968,12969,956,26472,12980,12985,44783,24735,10161,12271,27518,17777,3782,9169,23978,12982,8999,12984,19494,30695,94670,84218,1399,7746,669,23610,31569,28150,16587,19401,12974,27,12978,93415,97126,12981,95944,96259,21829,7545,12976,19291,16862, 12442,32964,11491,18711,7692,97309,37264,97261,11740,63529,96053,64409,97163,54209,11140,9849,12554,94553,96993,97680,9489,35330,47123,96054,61383,95181,30460,8030,2083,29691,21650,21412,73876,48241,41983,46677,8388 ),
      2,
      9 ) AS alcohol_mgmt
FROM
   referral r,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   r.anonpatid = p.anonpatid

HAVING
   alcohol_mgmt != 9
   
ORDER BY
   anonpatid;
   

DROP TABLE IF EXISTS cal_anxiety;
CREATE TABLE cal_anxiety AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 56026,61430,31522,35619,35594,3407,29907 ),
      1,
      WHEN
         c.medcode IN ( 9125,7999,22159,18815,26295,62935 ),
         2,
         WHEN
             c.medcode IN ( 10344,962,4659,1758,4634 ),
             3,
             WHEN
                 c.medcode IN ( 15220,11913,655,7749 ),
                 4,
                 WHEN
                     c.medcode IN ( 4081,462,8205,6408,11940,4069 ),
                     5,
                     WHEN
                         c.medcode IN ( 18967,63259,15292,44269,1510 ),
                         6,
                         WHEN
                             c.medcode IN ( 4534,5385,35825,636,6939,28167,23838,44321,5274,15811,24066,50191,28381,25638,23808),
                             7,
                             9 ) ) ) ) ) ) ) AS anxiety
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   anxiety != 9;
DROP TABLE IF EXISTS cal_anxiety_phobia_hes;
CREATE TABLE cal_anxiety_phobia_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'F40%' OR icd LIKE 'F41%' ),
        1, 
        9 ) AS anxiety_phobia_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    anxiety_phobia_hes != 9;

UPDATE
    cal_anxiety_phobia_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_anxiety_phobia_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_anxiety_phobia_hes DROP COLUMN spno;DROP TABLE IF EXISTS cal_anxiety_phobia_symp;
CREATE TABLE cal_anxiety_phobia_symp AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 13124,10723,131,20163,29608,2509,28408,3586,514,93401,19000,11890,2524,5902,8725,20375,24448,3328,20089 ),
      1,
      WHEN
         c.medcode IN ( 5347,31672,10390,28129,9915,53067,26331,4167,38155 ),
         2, 
         9 ) ) AS anxiety_phobia_symp
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   anxiety_phobia_symp != 9;

DROP TABLE IF EXISTS cal_bipolar;
CREATE TABLE cal_bipolar AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 27584,37178,22080,23963,24230,55064,85102,11548 ),
      1,
      WHEN
         c.medcode IN ( 19345 ),
         2,
         WHEN
             c.medcode IN ( 36126,57605,16347,63784,46434,26299,28277,59011,16808,55829,17385,3702,35738 ),
             3,
             WHEN
                 c.medcode IN ( 15923,37296,16562,27890,4677,4732,29451,23713,57465,63701,12831,28677,35734,35607,72026 ),
                 4,
                 WHEN
                     c.medcode IN ( 70399,63583,63651,44693,31535,31316,24689,63150,63284,54195 ),
                     5,
                     WHEN
                         c.medcode IN ( 27739,49763,70721,68326,19967,63698,70925,11596,68647,26227,66153,6710,51032,33751,73924,46425,32295,73423,53840,6874,8567,58863,33426,27986,14784,1531,60178,65811,46415 ),
                         6,
                         WHEN
                             c.medcode IN (  18909,2741 ),
                             7,
                             WHEN
                                 c.medcode IN ( 44513,37070,4678,12173,43093,13024,50218,26161,24640,37102,70000,20110,32088,36611,21065,48632,14728 ),
                                 8,
                                 9 ) ) ) ) ) ) ) ) AS bipolar
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   bipolar != 9;
DROP TABLE IF EXISTS cal_bipolar_hes;
CREATE TABLE cal_bipolar_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'F30%' OR icd LIKE 'F11%' ),
        1, 
        9 ) AS bipolar_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    bipolar_hes != 9;

UPDATE
    cal_bipolar_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_bipolar_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_bipolar_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_bipolar_symp;
CREATE TABLE cal_bipolar_symp AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS bipolar_symp
   
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
    c.medcode IN ( 18575, 22713, 30282 );DROP TABLE IF EXISTS cal_dementia_gprd;
CREATE TABLE cal_dementia_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 83576,55023,40805,30641,44341,65235,85853,89037,6542,12710,49674,89036 ),
      1,
      WHEN
         c.medcode IN ( 6578,42279,31016,11175,19393,19477,55838,43089,55467,46488,43292,8934,9565,56912,8634,55313 ),
         3, 
         WHEN
            c.medcode IN ( 9509,37014,54505,26323,25386,27342,62132,28402,26270,54106,64267,41185,12621 ),
            4,
            WHEN
            	c.medcode IN ( 55222,7323,27677,1350,5931,44674,1916,53446,15165,27759,37015,21887,34944,49513,38438,48501,30032,4693,41089,42602,18386,4357 ),
            	5,
            	9 ) ) ) ) AS dementia_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   dementia_gprd != 9;
DROP TABLE IF EXISTS cal_dementia_hes;
CREATE TABLE cal_dementia_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        icd LIKE 'F009%'
            OR icd LIKE 'F002%'
            OR icd LIKE 'F00X%'
            OR icd LIKE 'F001%'
            OR icd LIKE 'F000%',
            2,
            WHEN
                icd LIKE 'F012%'
                OR icd LIKE 'F018%'
                OR icd LIKE 'F013%'
                OR icd LIKE 'F010%'
                OR icd LIKE 'F01X%'
                OR icd LIKE 'F019%'
                OR icd LIKE 'F011%',
                3,
                WHEN
                    icd LIKE 'F021%'
                    OR icd LIKE 'F028%'
                    OR icd LIKE 'F023%'
                    OR icd LIKE 'F024%'
                    OR icd LIKE 'F020%'
                    OR icd LIKE 'F02X%'
                    OR icd LIKE 'F022%',
                    4,
                    WHEN 
                        icd LIKE 'F03X%' OR icd LIKE 'F051%',
                        5,
                        9 ) ) ) ) AS dementia_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    dementia_hes != 9;

UPDATE
    cal_dementia_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_dementia_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_dementia_hes DROP COLUMN spno;
DROP TABLE IF EXISTS tmp_dementia_meds;

CREATE TEMPORARY TABLE tmp_dementia_meds AS
SELECT 
	anonpatid,
	eventdate
FROM
	cal_drugs_4_11
GROUP BY anonpatid,eventdate
HAVING COUNT(*) > 2;

DROP TABLE IF EXISTS cal_dementia_meds;
CREATE TABLE cal_dementia_meds AS
SELECT
	anonpatid,
	MIN(eventdate) AS eventdate,
	1 AS dementia_meds
FROM
	tmp_dementia_meds
GROUP BY
	anonpatid;
DROP TABLE IF EXISTS cal_depression_diag;
CREATE TABLE cal_depression_diag AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 9211,10667,98346,16506,15155,11717,98252 ),
      1,
      WHEN
         c.medcode IN (15219,98414 ),
         2,
         WHEN
            c.medcode IN ( 24117,17770,28863,23731,24112,52678,8478,2560,98417,32159 ),
            3,
            WHEN
               c.medcode IN ( 4639,34390,543,7011,324,43324,7737,5987,10610,56609,28248,2970,9183,22806,27491,6854,59386,3291,10720,8584,36616,9055,18510,7604,1131 ),
               4,
               WHEN
                  c.medcode IN ( 595,6950,11329,6546 ),
                  5,
                  WHEN
                     c.medcode IN ( 41989,1055,5879 ),
                     6,
                     WHEN
                        c.medcode IN ( 10455,7953,10290 ),
                        7,
                        WHEN
                           c.medcode = 4323,
                           8,
                           WHEN
                              c.medcode IN ( 29520,14709,29342,29784 ),
                              9,
                              WHEN
                                 c.medcode IN ( 33469,25697 ),
                                 10,
                                 WHEN
                                    c.medcode IN ( 37764,16861,31757,32941,24171,47009 ),
                                    11,
                                    WHEN
                                       c.medcode IN ( 3292,8902,55384,11252,28756,10825,8826,35671,25563,6932,56273,19696,44300,15099,8851,19054,47731,22116,6482,73991 ),
                                       12,
                                       WHEN
                                          c.medcode IN ( 2923,29527,13307,2972,2639,4979 ),
                                          13,
                                          9 ) ) ) ) ) ) ) ) ) ) ) ) ) AS depression_diag  
FROM
   clinical c,
   patient p
WHERE
   p.anonpatid = c.anonpatid

AND
   p.gender IN (1,2)
AND
   c.eventdate IS NOT NULL
HAVING
   depression_diag != 9;DROP TABLE IF EXISTS cal_depression_hes;
CREATE TABLE cal_depression_hes AS
SELECT
    h.anonpatid,
    h.spno,
    h.admidate   AS date_admission,
    h.discharged AS date_discharge,
    h.icd,
    2 AS depression_hes
FROM
    hes_diag_hosp h,
    patient p
WHERE
    p.anonpatid = h.anonpatid
AND ( 
    h.icd LIKE 'F32%'
    OR
    h.icd LIKE 'F341%'
    OR
    h.icd LIKE 'F330%'
    OR
    h.icd LIKE 'F331%'
    OR
    h.icd LIKE 'F332%'
    OR
    h.icd LIKE 'F333%'
    OR
    h.icd LIKE 'F334%'
    OR
    h.icd LIKE 'F338%'
    OR
    h.icd LIKE 'F339%' )

AND
    p.gender IN (1,2)
AND
    h.discharged != 0
AND
    h.admidate != 0;
    
-- CREATE INDEX anonpatid ON cal_depression_hes( anonpatid );

-- Mark primary diagnosis codes across a hospitalization in the distributable file.
    
UPDATE cal_depression_hes h, hes_primary_diag_hosp p 
SET h.depression_hes = 1 
WHERE h.anonpatid = p.anonpatid AND h.spno = p.spno 
AND h.icd = p.primary_icd AND h.date_admission = p.admidate
AND h.date_discharge = p.discharged;

ALTER TABLE cal_depression_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_depression_history;
CREATE TABLE cal_depression_history AS
SELECT
   DISTINCT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 19439,2716,57409 ),
      1,
      WHEN
         c.medcode IN ( 71009,1908,43239,59235,22401,11750,31213,12399,50921,42931,51388,96995,44848,22530,11774,72752,65435,91105,30583 ),
         2,
         9 ) ) AS depression_history
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   depression_history != 9
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_depression_referral;
CREATE TABLE cal_depression_referral AS
SELECT
   DISTINCT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS depression_referral
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 6627,71384,30574,11958,51055,5338,10308,36728,97420,40894,11071,84212,27640,28985,10002,34791,13680,7052,12365,12285,94200,9868,34532,23099,24504,1690,41071,97570,10026,10486,12053,34538,42932,9129,24502,10828,2189,93630,12447,10967,13677,10236,10044,26178,11270,10669,11449,94698,32841,18872,95936,44910,41040,13703,18956 )
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_depression_symptoms;
CREATE TABLE cal_depression_symptoms AS
SELECT
   DISTINCT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS depression_symptoms
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 9796,25435,10438,10015,4824,53148,8928,59869,1996,30740 )
ORDER BY
   anonpatid;


DROP TABLE IF EXISTS drug_temp;
CREATE TEMPORARY TABLE drug_temp AS
SELECT
    anonpatid,
    COUNT(*) AS num_prescriptions 
FROM 
    cal_drugs_4_3_2
GROUP BY
    anonpatid
HAVING 
    num_prescriptions > 2 ;

-- CREATE INDEX anonpatid ON drug_temp( anonpatid );

DROP TABLE IF EXISTS cal_depress_drugs_maoi;
CREATE TABLE cal_depress_drugs_maoi AS
SELECT 
    c.anonpatid,
    1 AS depress_drugs_tca,
    MIN(eventdate) AS first_rx
FROM
    cal_drugs_4_3_2 c,
    drug_temp d
WHERE
    c.anonpatid = d.anonpatid
GROUP BY 
    anonpatid;

DROP TABLE IF EXISTS drug_temp;
CREATE TEMPORARY TABLE drug_temp AS
SELECT
    anonpatid,
    COUNT(*) AS num_prescriptions 
FROM 
    cal_drugs_4_3_4
GROUP BY
    anonpatid
HAVING 
    num_prescriptions > 2 ;

-- CREATE INDEX anonpatid ON drug_temp( anonpatid );

DROP TABLE IF EXISTS cal_depress_drugs_other;
CREATE TABLE cal_depress_drugs_other AS
SELECT 
    c.anonpatid,
    1 AS depress_drugs_tca,
    MIN(eventdate) AS first_rx
FROM
    cal_drugs_4_3_4 c,
    drug_temp d
WHERE
    c.anonpatid = d.anonpatid
GROUP BY 
    anonpatid;

DROP TABLE IF EXISTS drug_temp;
CREATE TEMPORARY TABLE drug_temp AS
SELECT
    anonpatid,
    COUNT(*) AS num_prescriptions 
FROM 
    cal_drugs_4_3_3
GROUP BY
    anonpatid
HAVING 
    num_prescriptions > 2 ;

-- CREATE INDEX anonpatid ON drug_temp( anonpatid );

DROP TABLE IF EXISTS cal_depress_drugs_ssri;
CREATE TABLE cal_depress_drugs_ssri AS
SELECT 
    c.anonpatid,
    1 AS depress_drugs_tca,
    MIN(eventdate) AS first_rx
FROM
    cal_drugs_4_3_3 c,
    drug_temp d
WHERE
    c.anonpatid = d.anonpatid
GROUP BY 
    anonpatid;

DROP TABLE IF EXISTS drug_temp;
CREATE TEMPORARY TABLE drug_temp AS
SELECT
    anonpatid,
    COUNT(*) AS num_prescriptions 
FROM 
    cal_drugs_4_3_1
GROUP BY
    anonpatid
HAVING 
    num_prescriptions > 2 ;

-- CREATE INDEX anonpatid ON drug_temp( anonpatid );

DROP TABLE IF EXISTS cal_depress_drugs_tca;
CREATE TABLE cal_depress_drugs_tca AS
SELECT 
    c.anonpatid,
    1 AS depress_drugs_tca,
    MIN(eventdate) AS first_rx
FROM
    cal_drugs_4_3_1 c,
    drug_temp d
WHERE
    c.anonpatid = d.anonpatid
GROUP BY 
    anonpatid;
    
DROP TABLE IF EXISTS cal_phq9;
CREATE TABLE cal_phq9 AS

-- test table, all scores coded as entity 288 and result is in data2

SELECT
   t.anonpatid,
   t.eventdate,
   t.data2 AS phq9
FROM
   test t,
   patient p
WHERE
   t.anonpatid = p.anonpatid
AND
   p.gender IN (1,2)

AND
   t.eventdate IS NOT NULL
AND
   t.medcode = 13583

UNION DISTINCT

SELECT
   c.anonpatid,
   c.eventdate,
   c.data1 AS phq9
FROM
   clinical c,
   patient p   
WHERE
   c.anonpatid = p.anonpatid
AND
   p.gender IN (1,2)

AND
   c.eventdate !=0
AND
   (  c.medcode = 13583 AND c.enttype = 372  
      OR
      c.enttype = 372  AND c.data2 = 13583 
      OR
      c.enttype = 372  AND c.data3 IN (1,4,7,8,9) 
   )

HAVING
   phq9 BETWEEN 0 AND 27
AND
   phq9 != ""
AND
   CEIL(phq9) = phq9

ORDER BY anonpatid;

DELETE FROM cal_phq9 WHERE ( phq9 NOT BETWEEN 0 AND 27 ) OR ( CEIL(phq9) != phq9 );

DROP TABLE IF EXISTS cal_eating_disorders_gprd;
CREATE TABLE cal_eating_disorders_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 8027,
      1,
      WHEN
         c.medcode IN ( 30570,34929,2135 ),
         3, 
         WHEN
            c.medcode IN ( 605,3422,2871,4377,9581,6583,33863,6796,16622 ),
            4,
            WHEN
                c.medcode IN ( 39383,17439,26518 ),
                5,
                WHEN
                    c.medcode IN ( 6159,95883,12201,61236,4835,11612,32892,44544,36946,17203,11608,34995,67510,49601,22820,7743 ),
                    6,
                    9 ) ) ) ) ) AS eating_disorders_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   eating_disorders_gprd != 9;
DROP TABLE IF EXISTS cal_eating_disorders_hes;
CREATE TABLE cal_eating_disorders_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        icd LIKE 'F501%' OR icd LIKE 'F500%' ,
        3,
        WHEN
            icd LIKE 'F503%' OR icd LIKE 'F505%' OR icd LIKE 'F502%' ,
            4,
            WHEN
                icd LIKE 'F504%',
                5,
                WHEN
                    icd LIKE 'F50%' OR icd LIKE 'F508%' OR icd LIKE 'F509%',
                    6,
                    9 ) ) ) ) AS eating_disorders_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    eating_disorders_hes != 9;

UPDATE
    cal_eating_disorders_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_eating_disorders_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_eating_disorders_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_phobia;
CREATE TABLE cal_phobia AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 24351,11764 ),
      1,
      WHEN
         c.medcode IN ( 63521,25749 ),
         2,
         WHEN
             c.medcode IN ( 14890,2571,3076 ),
             3,
             WHEN
                 c.medcode IN ( 16729,12838 ),
                 4,
                 WHEN
                     c.medcode IN ( 16199,16638,18603,11602,31957,42788 ),
                     5,
                     WHEN
                         c.medcode IN ( 28938,12635,18248,1723,28106,67965,2366,9785,12508,20802,11280 ),
                         6,
                         WHEN
                             c.medcode IN ( 34064,1907,67898,14729,9944,7222,2300,9386,27685 ),
                             7,
                             9 ) ) ) ) ) ) ) AS phobia
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   phobia != 9;

DROP TABLE IF EXISTS cal_psychosis;
CREATE TABLE cal_psychosis AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 85972,19345,12777 ),
      1,
      WHEN
         c.medcode IN ( 17281,19071 ),
         2,
         WHEN
             c.medcode IN ( 66077,34389,40981,62680,55221,28562,66766,50868,49223,51302,55236 ), 
             3,
             WHEN
                 c.medcode IN ( 31707,3636,15053,44307,94604,11778,50023,59096,29937,34168,44503,16333,68058,70884,21455,27770,23538,93167,26119,26143,11973,24345,22117,29651,20228,21595,36720,25019 ), 
                 4,
                WHEN
                    c.medcode IN ( 31738,47947,31455,62405,16537,2113,14965,4261,50248,22188,11172,694,12771,31589,11244,3890,15958,65127,31984,14971,30985,98821,4843,14743 ), 
                    5,
                    9 ) ) ) ) ) AS psychosis
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
    psychosis != 9;
    
DROP TABLE IF EXISTS cal_psychosis_hes;
CREATE TABLE cal_psychosis_hes AS
SELECT
    h.anonpatid,
    h.spno,
    h.admidate   AS date_admission,
    h.discharged AS date_discharge,
    h.icd,
    2 AS psychosis_hes
FROM
    hes_diag_hosp h,
    patient p
WHERE
    p.anonpatid = h.anonpatid
AND ( h.icd LIKE 'F22%'
    OR
    h.icd LIKE 'F24%'
    OR
    h.icd LIKE 'F23%'
    OR
    h.icd LIKE 'F28%'
    OR
    h.icd LIKE 'F29%' )

AND
    p.gender IN (1,2)
AND
    h.discharged != 0
AND
    h.admidate != 0;
    
-- CREATE INDEX anonpatid ON cal_psychosis_hes( anonpatid );

-- Mark primary diagnosis codes across a hospitalization in the distributable file.
    
UPDATE cal_psychosis_hes h, hes_primary_diag_hosp p 
SET h.psychosis_hes = 1 
WHERE h.anonpatid = p.anonpatid AND h.spno = p.spno 
AND h.icd = p.primary_icd AND h.date_admission = p.admidate
AND h.date_discharge = p.discharged;

ALTER TABLE cal_psychosis_hes DROP COLUMN spno;

-- Generated: 2013-05-15 11:13:17
   DROP TABLE IF EXISTS cal_acute_stress_gprd;

   CREATE TABLE cal_acute_stress_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 9134,35808,58610,63249,51349,96504,35648,56220,96503,57856,37248,70751,11376,276,43550,11940,42737,15551,23869,26138,11607,36374,10535,70779,21559,7813,32387,4171,32182,38640,20245,24847,29707,11098,21753,31515 );

   -- CREATE INDEX anonpatid ON cal_acute_stress_gprd( anonpatid );

   ALTER TABLE cal_acute_stress_gprd ADD COLUMN acute_stress_gprd INT DEFAULT NULL;

   UPDATE cal_acute_stress_gprd SET acute_stress_gprd = '1' WHERE medcode IN ( 9134,96503,96504,51349,57856,35648,70751,35808,63249,56220,58610,11376,37248 );
UPDATE cal_acute_stress_gprd SET acute_stress_gprd = '2' WHERE medcode IN ( 21559,26138,276,42737,43550,36374,15551,11607,10535,23869,7813,70779,11940 );
UPDATE cal_acute_stress_gprd SET acute_stress_gprd = '3' WHERE medcode IN ( 4171,32387,32182 );
UPDATE cal_acute_stress_gprd SET acute_stress_gprd = '4' WHERE medcode IN ( 21753,11098,29707,20245,24847,31515,38640 );
DROP TABLE IF EXISTS cal_schizophrenia;
CREATE TABLE cal_schizophrenia AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 67130,38371,20785,14747,3369 ),
      0,
      WHEN
         c.medcode IN ( 22104,19345,88275,6325 ),
         1,
         WHEN
             c.medcode IN ( 67943 ), 
             2,
             WHEN
                 c.medcode IN ( 36172,53032,1494,33383,16764,51322,9281,50060,31362 ), 
                 3,
                WHEN
                    c.medcode IN ( 67768,43405,97919,53985,30619,48054,66506 ), 
                    4,
                    WHEN
                        c.medcode IN ( 20572,64533,63867,61501,25546,31493,58716,35877 ),
                        5,
                        WHEN
                            c.medcode IN ( 91547,32222,39062,34236,24107,64264,576,35848,60013,94001,44498,15733,38063,854,49761,23616,49420,58687,3984,34966,18053,57666,8407,92994,53625,73295,33338 ),
                            6,
                            WHEN
                                c.medcode IN ( 71250,40386,66410,96883,17281,39316,91511,54387,94299,61969,49852,62449,26859,64993 ),
                                7,
                                WHEN
                                    c.medcode IN ( 51903,37580,63478,2117,9422,33693,33410,11055,58866,56438,35274,43800,10575,16905,33847,58862,58532,37681,61098,41022 ),
                                    8,
                                    9 ) ) ) ) ) ) ) ) ) AS schizophrenia
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
    schizophrenia != 9;
   DROP TABLE IF EXISTS cal_schizophrenia_hes;
CREATE TABLE cal_schizophrenia_hes AS
SELECT
    h.anonpatid,
    h.spno,
    h.admidate   AS date_admission,
    h.discharged AS date_discharge,
    h.icd,
    2 AS schizophrenia_hes
FROM
    hes_diag_hosp h,
    patient p
WHERE
    p.anonpatid = h.anonpatid
AND ( h.icd LIKE 'F20%'
    OR
    h.icd LIKE 'F21%'
    OR
    h.icd LIKE 'F25%' )

AND
    p.gender IN (1,2)
AND
    h.discharged != 0
AND
    h.admidate != 0;
    
-- CREATE INDEX anonpatid ON cal_schizophrenia_hes( anonpatid );

-- Mark primary diagnosis codes across a hospitalization in the distributable file.
    
UPDATE cal_schizophrenia_hes h, hes_primary_diag_hosp p 
SET h.schizophrenia_hes = 1 
WHERE h.anonpatid = p.anonpatid AND h.spno = p.spno 
AND h.icd = p.primary_icd AND h.date_admission = p.admidate
AND h.date_discharge = p.discharged;

ALTER TABLE cal_schizophrenia_hes DROP COLUMN spno;


DROP TABLE IF EXISTS cal_tia_gprd;
CREATE TABLE cal_tia_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 13567,
      1,
      WHEN
         c.medcode IN ( 16507,55247 ),
         2, 
         WHEN
            c.medcode IN ( 1433,1895,19354,63746,15788,504 ),
            3,
            9 ) ) ) AS tia_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   tia_gprd != 9;
DROP TABLE IF EXISTS cal_tia_hes;
CREATE TABLE cal_tia_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'G458%'
          OR icd LIKE 'G459%' ),
        3, 
        9 ) AS tia_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    tia_hes != 9;

UPDATE
    cal_tia_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_tia_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_tia_hes DROP COLUMN spno;
-- Generated: 2013-02-18 11:38:49

DROP TABLE IF EXISTS cal_af_gprd;
CREATE TABLE cal_af_gprd AS
SELECT 
   c.anonpatid,
   c.eventdate,
   c.medcode 
FROM 
   clinical c, 
   patient p
WHERE 
   c.anonpatid = p.anonpatid

AND 
   c.eventdate IS NOT NULL
AND 
   c.medcode IN ( 6345,93460,28994,90190,90188,90191,90187,90189,45773,39114,18746,63350,57832,1268,96277,96076,1664,3757,35127,23437,2212,1757,6771 );

---- CREATE INDEX anonpatid ON cal_af_gprd( anonpatid );

ALTER TABLE cal_af_gprd ADD COLUMN af_gprd INT DEFAULT NULL;

UPDATE cal_af_gprd SET af_gprd = '1' WHERE medcode IN ( 6345,93460,28994 );
UPDATE cal_af_gprd SET af_gprd = '2' WHERE medcode IN ( 90190,90188,90191,90187,90189,45773,39114,18746,63350,57832 );
UPDATE cal_af_gprd SET af_gprd = '3' WHERE medcode IN ( 1268 );
UPDATE cal_af_gprd SET af_gprd = '4' WHERE medcode IN ( 96277,96076 );
UPDATE cal_af_gprd SET af_gprd = '5' WHERE medcode IN ( 1664,3757,35127 );
UPDATE cal_af_gprd SET af_gprd = '6' WHERE medcode IN ( 23437,2212 );
UPDATE cal_af_gprd SET af_gprd = '7' WHERE medcode IN ( 1757,6771 );
-- Generated: 2013-02-18 11:38:49

   DROP TABLE IF EXISTS cal_af_drugs_gprd;

   CREATE TABLE cal_af_drugs_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 15730,21763,9410,13499,18950,8987,26255,35062,8673,34741,26248,3827,1050,14030,10688,32658,34125,34094,38433,29180,34868,7049,13027,36261,38370,38634,517,33085,19182,220,21885,26922,27964,1836,19200,26252,40167,3588,34449,34890,14058,13075,19178,32114,34695,2453,37118,9016,30636,1597,23233,1333,15221,23326,18287,33602,34365,3087,21773,12104,17425,37725,30400,8807,34581,22619,42152,8707,31708,41555,34492,5054,34821,34185,26674,1448,10777,17406,11223,17586,14808,2592,26229,4983,9569,19440,31490,34378,20468,34824,939,13302,739,38066,17322,16038,32552,9783,3342,21873,29427,3344,36664,7398,13394,2587,1748,24,1298,20093,29398,14552,27685,29998,17666,2414,27719,3370,594,32094,8642,29763,21795,19202,30242,2361,41827,26267,11777,34265,26460,3061,4429,11973,20579,34925,30770,5194,1048,33092,31711,940,35778,39009,8147,5,3748,9374,34949,1788,23872,9185,17462,34430,38882,8524,34407,39233,19325,2811,13410,1289,26741,18223,536,34882,1130,41635,9273,1747,34188,5234,34963,26228,33836,8558,8978,9178,34501,817,4025,27295,41591,28996,31934,28949,33376,24191,25644,16850,11972,8975,21778,19172,31676,13033,29762,3343,11711,19437,29368,8884,21145,14892,19690,34475,27401,26270,10267,34377,18834,5478,13871,12495,7543,22826,23587,35696,13251,21966,4852,581,8071,2432,5968,9240,29637,35729,34443,30462,37774,33659,3676,30197,34575,40405,16328,15288,31833,14502,8369,28048,24195,4542,36603,15117,28128,2775,472,4725,31470,21918,18403,33839,25059,8945,23505,40240,2528,31489,38964,22208,33850,12392,11793,38865,9919,27136,13856,34092,31536,599,39646,14117,13127,5296,822,13526,2663,27357,8331,753,8759,20082,19858,21905,18852,700,22912,30541,36583,16677,16786,24218,769,707,12639,34899,24280,33471,197,39171,4796,26211,10832,32836,16645,31776,18975,11922,13240,1295,5713,32089,34208,28788,38632,19457,34867,29230,32630,18830,32590,18379,1995,4635,18874,34177,41693,33079,38831,22793,7553,14146,8068,33909,4408,6309,23733,19175,2780,1684,27486,13965,38991,10892,2629,3943,26269,19068,33184,13926,19998,1006,34584,18743,34754,2590,636,3005,25359,26759,1118,2686,21839,1288,24094,10294,34012,18414,41586,21838,4771,33657,5721,26,4923,3526,5326,1120,24461,8290,41679,17783,5513,297,7474,34509,34854,39298,1334,35938,34034,18606,32870,19055,31214,18404,3167,1290,34959,27135,31737,4308,11770,20502,10627,33650,21866,6066,28844,33569,34740,19426,27700,41489,28177,17615,1538,5348,28843,24083,26309,17149,20728,10429,7429,15488,33644,34214,1574,33374,4808,34171,2888,20642,793,34976,9723,9708,15619,1124,26463,4732,23131,3474,32135,12054,36576,4410,21133,20890,32162,17082,34945,7091,38855,41572,3118,25777,34884,34585,7066,29676,17599,34804,18185,19459,219,39846,34825,10191,38545,34783,19853,17492,25367,1686,26895,32262,3057,39819,38818,37837,3516,19191,6510,38876,40241,15176,12705,34088,833,38041,36099,1781,34416,34864,39444,34095,17965,8466,40143,34576,61,39119,39755,31937,39503,13348,34517,34418,6262,30202,30203,31511,39866,34526,33711,38044,39639,34087,34918,34086,34691,34417,34019,34758,8467,45,23078,34299,13549,34690,9522,14856,34948,35517,31209,13051,11380,41551,805,3181,29024,7465,3705,786,27727,8749,34520,15042,34759,20844,34851,34024,12322,33274,16366,5441,41530,30047,32109,35710,38498,5858,34017,34751,32164,29456,25238,1572,34515,15313,8061,27523,20944,792,29282,763,9292,4004,24635,33080,34519,188,1573,34640,27161,39423,33391,1119,3286,33675,31079,1291,41735,34023,8832,32553,40055,34371,33578,10687,33612,9188,13487,2511,27193,40245,12456,34600,34574,7445,10871,3058,13434,30990,34328,36,2302,94,17119,34327,8060,6751,35520,17679,3691,33119 );

   -- CREATE INDEX anonpatid ON cal_af_drugs_gprd( anonpatid );

   ALTER TABLE cal_af_drugs_gprd ADD COLUMN af_drugs_gprd INT DEFAULT NULL;

   UPDATE cal_af_drugs_gprd SET af_drugs_gprd = '2' WHERE prodcode IN ( 15730,21763,9410,13499,18950,8987,26255,35062,8673,34741,26248,3827,1050,14030,10688,32658,34125,34094,38433,29180,34868,7049,13027,36261,38370,38634,517,33085,19182,220,21885,26922,27964,1836,19200,26252,40167,3588,34449,34890,14058,13075,19178,32114,34695,2453,37118,9016,30636,1597,23233,1333,15221,23326,18287,33602,34365,3087,21773,12104,17425,37725,30400,8807,34581,22619,42152,8707,31708,41555,34492,5054,34821,34185,26674,1448,10777,17406,11223,17586,14808,2592,26229,4983,9569,19440,31490,34378,20468,34824,939,13302,739,38066,17322,16038,32552,9783,3342,21873,29427,3344,36664,7398,13394,2587,1748,24,1298,20093,29398,14552,27685,29998,17666,2414,27719,3370,594,32094,8642,29763,21795,19202,30242,2361,41827,26267,11777,34265,26460,3061,4429,11973,20579,34925,30770,5194,1048,33092,31711,940,35778,39009,8147,5,3748,9374,34949,1788,23872,9185,17462,34430,38882,8524,34407,39233,19325,2811,13410,1289,26741,18223,536,34882,1130,41635,9273,1747,34188,5234,34963,26228,33836,8558,8978,9178,34501,817,4025,27295,41591,28996,31934,28949,33376,24191,25644,16850,11972,8975,21778,19172,31676,13033,29762,3343,11711,19437,29368,8884,21145,14892,19690,34475,27401,26270,10267,34377,18834,5478,13871,12495,7543,22826,23587,35696,13251,21966,4852,581,8071,2432,5968,9240,29637,35729,34443,30462,37774,33659,3676,30197,34575,40405,16328,15288,31833,14502,8369,28048,24195,4542,36603,15117,28128,2775,472,4725,31470,21918,18403,33839,25059,8945,23505,40240,2528,31489,38964,22208,33850,12392,11793,38865,9919,27136,13856,34092,31536,599,39646,14117,13127,5296,822,13526,2663,27357,8331,753,8759,20082,19858,21905,18852,700,22912,30541,36583,16677,16786,24218,769,707,12639,34899,24280,33471,197,39171,4796,26211,10832,32836,16645,31776,18975,11922,13240,1295,5713,32089,34208,28788,38632,19457,34867,29230,32630,18830,32590,18379,1995,4635,18874,34177,41693,33079,38831,22793,7553,14146,8068,33909,4408,6309,23733,19175,2780,1684,27486,13965,38991,10892,2629,3943,26269,19068,33184,13926,19998,1006,34584,18743,34754,2590,636,3005,25359,26759,1118,2686,21839,1288,24094,10294,34012,18414,41586,21838,4771,33657,5721,26,4923,3526,5326,1120,24461,8290,41679,17783,5513,297,7474,34509,34854,39298,1334,35938,34034,18606,32870,19055,31214,18404,3167,1290,34959,27135,31737,4308,11770,20502,10627,33650,21866,6066,28844,33569,34740,19426,27700,41489,28177,17615,1538,5348,28843,24083,26309,17149,20728,10429,7429,15488,33644,34214,1574,33374,4808,34171,2888,20642,793,34976,9723,9708,15619,1124,26463,4732,23131,3474,32135,12054,36576,4410,21133,20890,32162,17082,34945,7091,38855,41572,3118,25777,34884,34585,7066,29676,17599,34804,18185,19459,219,39846,34825,10191,38545,34783,19853,17492,25367,1686,26895,32262,3057,39819,38818,37837,3516,19191,6510,38876,40241,15176,12705 );
UPDATE cal_af_drugs_gprd SET af_drugs_gprd = '3' WHERE prodcode IN ( 34088,833,38041,36099,1781,34416,34864,39444,34095,17965,8466,40143,34576,61,39119,39755,31937,39503,13348,34517,34418,6262,30202,30203,31511,39866,34526,33711,38044,39639,34087,34918,34086,34691,34417,34019,34758,8467,45,23078,34299 );
UPDATE cal_af_drugs_gprd SET af_drugs_gprd = '4' WHERE prodcode IN ( 13549,34690,9522,14856,34948,35517,31209,13051,11380,41551,805,3181,29024,7465,3705,786,27727,8749,34520,15042,34759,20844,34851,34024,12322,33274,16366,5441,41530,30047,32109,35710,38498,5858,34017,34751,32164,29456,25238,1572,34515,15313,8061,27523,20944,792,29282,763,9292,4004,24635,33080,34519,188,1573,34640,27161,39423,33391,1119,3286,33675,31079,1291,41735,34023,8832,32553,40055,34371,33578,10687,33612,9188,13487,2511,27193,40245,12456,34600,34574,7445,10871,3058,13434,30990,34328,36,2302,94,17119,34327,8060,6751,35520,17679,3691,33119 );
-- Generated: 2013-02-18 11:38:49

DROP TABLE IF EXISTS cal_af_hes;
CREATE TABLE cal_af_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    6 AS af_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    icd LIKE 'I48%';

-- CREATE INDEX anonpatid ON cal_af_hes( anonpatid );

UPDATE
    cal_af_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_af_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_af_hes DROP COLUMN spno;-- Generated: 2013-02-18 11:38:49

DROP TABLE IF EXISTS cal_af_proc_gprd;

CREATE TABLE cal_af_proc_gprd AS
SELECT 
   c.anonpatid,
   c.eventdate,
   c.medcode 
FROM 
   clinical c, 
   patient p
WHERE 
   c.anonpatid = p.anonpatid

AND 
   c.eventdate IS NOT NULL
AND 
   c.medcode IN ( 37611,3232,7189,93543,1656,96516,42230,38534,31077,41512,12664,98235,86416,83530,84152,89357,92361,28933,7388,29167,43860,87338,9479 );

-- CREATE INDEX anonpatid ON cal_af_proc_gprd( anonpatid );

ALTER TABLE cal_af_proc_gprd ADD COLUMN af_proc_gprd INT DEFAULT NULL;

UPDATE cal_af_proc_gprd SET af_proc_gprd = '1' WHERE medcode IN ( 37611,3232,7189,93543,1656,96516,42230,38534,31077,41512,12664,98235 );
UPDATE cal_af_proc_gprd SET af_proc_gprd = '2' WHERE medcode IN ( 86416,83530,84152,89357,92361,28933,7388,29167,43860,87338,9479 );
-- Generated: 2013-02-18 11:38:49

   DROP TABLE IF EXISTS cal_af_proc_opcs;

   CREATE TABLE cal_af_proc_opcs AS
   SELECT 
      c.anonpatid,
      c.admidate   AS date_admission,
      c.evdate     AS date_procedure,
      c.discharged AS date_discharge,
      c.opcs
   FROM 
      hes_procedure c
   WHERE
      c.opcs IN ( 'X504','K62','X502','X501','K624','K575','K521','K623','K571','K622','K621' );

   -- CREATE INDEX anonpatid ON cal_af_proc_opcs( anonpatid );

   ALTER TABLE cal_af_proc_opcs ADD COLUMN af_proc_opcs INT DEFAULT NULL;

   UPDATE cal_af_proc_opcs SET af_proc_opcs = '1' WHERE opcs IN ( 'X504','K62','X502','X501' );
UPDATE cal_af_proc_opcs SET af_proc_opcs = '2' WHERE opcs IN ( 'K624','K575','K521','K623','K571','K622','K621' );
-- Generated: 2013-02-18 11:38:49

   DROP TABLE IF EXISTS cal_af_warfarin_digoxin;

   CREATE TABLE cal_af_warfarin_digoxin AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 34088,833,38041,36099,1781,34416,34864,34095,17965,8466,40143,34576,61,31937,13348,34517,34418,6262,30202,30203,31511,39866,34526,33711,38044,34087,34918,34086,34417,34691,34019,34758,8467,45,23078,34299,33274,29282,16366,33080,9522,34519,2511,40245,34948,3181,34328,34017,3705,25238,33675,3286,36,94,2302,34327,34023,20844,20944,27523,34024,792,33612 );

   -- CREATE INDEX anonpatid ON cal_af_warfarin_digoxin( anonpatid );

   ALTER TABLE cal_af_warfarin_digoxin ADD COLUMN af_warfarin_digoxin INT DEFAULT NULL;

   UPDATE cal_af_warfarin_digoxin SET af_warfarin_digoxin = '3' WHERE prodcode IN ( 34088,833,38041,36099,1781,34416,34864,34095,17965,8466,40143,34576,61,31937,13348,34517,34418,6262,30202,30203,31511,39866,34526,33711,38044,34087,34918,34086,34417,34691,34019,34758,8467,45,23078,34299 );
UPDATE cal_af_warfarin_digoxin SET af_warfarin_digoxin = '4' WHERE prodcode IN ( 33274,29282,16366,33080,9522,34519,2511,40245,34948,3181,34328,34017,3705,25238,33675,3286,36,94,2302,34327,34023,20844,20944,27523,34024,792,33612 );
-- Generated: 2013-06-25 08:46:19
   DROP TABLE IF EXISTS cal_cardiac_surgery_associated_with_af_gprd;

   CREATE TABLE cal_cardiac_surgery_associated_with_af_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 3140,6557,39810,250,53626,61073,4438,242,72939,58529,70105,93844,69734,41495,5477,12844,16538,73029,70857,88842,88479,65401,19956,6945,31085,37987,89968,62470,69021,69200,58886,28355,33909,64470,38411,28943,94475,56741,73820,32163,73476,57102,39884,95755,73817,42181,48331,39885,57270,38436,34902,88772,31101,94191,43926,52287,28367,70424,67299,16191,36575,91892,39803,50626,96130,67483,45358,95578,98273,57271,3864,30340,86763,42090,59012,28006,38828,50310,36989,68073,31084,36967,67045,93264,41085,66308,49625,28470,44665,10916,37452,47885,94040,40062,41093,86374,64509,59664,31721,59765,28105,70042,64869,56572,73818,67783,62685,39029,44117,42782,66366,73602,72279,60681,37244,48485,12743,65040,87114,41553,58708,90605,95106,89231,98443,97058,91455,96637,97825,89257,84407,91693,89355,87869,93408,90112,93961,30173,7894,36638,3911,93158,51658,19390,30567,57318,49592,73904,3731,22582,85856,60957,41168,9498,34958,1756,43778,39763,35812,15133,53164,92070,40086,53804,26168,47014,93924,98580,98783,66201,32930,96199,72523,72417,46836,30014,38894,43923,89936,63601,60533,50649,95799,73967,94345,61108,29887,72761,69189,7276,46135,36734,5643,50398,96247,95817,15910,41169,17257,45256,61427,39972,63499,49413,16636,17812,17141,67931,29732,63493,62361,16544,67659,29481,19246,42748,38607,51940,20221,4900,9396,26153,53413,30705,62095,96316,95784,44690,49379,45283,52608,22413,20940,62293,67570,31512,54275,93485,91468,91467,72891,98388,85252,70353,91004,71668,95532,94683,93968,92226,89459,48333,3169,5904,737,18249,8312,8679,7634,7442,11610,7137,51515,9414,7134,44561,19413,10209,42708,61310,7609,31556,32651,70111,57241,45886,45370,59423,48767,19402,36011,92419,66664,66236,67761,19193,33461,52938,67554,31540,63153,97953,57634,37682,28837,33718,48822,92233,31519,44723,68139,37719,56990,96804,62608,67591,60753,72780,47788,18903,19164,61592,48206,51702,5744,95382,41757,33620,22020,94783,93432,69247,44585,55598,55092,93828,70755,34963,3159,33471,31571,10603,55482,29167,54722,51918,44656,43685,62425,97652,70609,43492,64723,34904,53652,45234,56193,97560,93182,94824,96563,2818,65756,63188,91886,72769,42518,28933,5746,57700,88476,89357,62247,57654,72414,15090,71731,72264,65369,48207,54078,38384,15769,91737,93516,97443,90933,90934,84152,30993,22733,7388,3827,23084,8000,5971,8796,12244,11865,30342,46342,67100,71508,29988,53709,63390,17088,6631,17334,36101,9384,18780,28871,18643,40264,5030,5674,36960 );

   -- CREATE INDEX anonpatid ON cal_cardiac_surgery_associated_with_af_gprd( anonpatid );

   ALTER TABLE cal_cardiac_surgery_associated_with_af_gprd ADD COLUMN cardiac_surgery_associated_with_af_gprd INT DEFAULT NULL;

   UPDATE cal_cardiac_surgery_associated_with_af_gprd SET cardiac_surgery_associated_with_af_gprd = '1' WHERE medcode IN ( 67761,31085,57318,57700,5744,5477,42181,3827,2818,737,16191,62247,44656,26153,62470,30342,28105,89231,94683,84152,73967,93828,89355,64509,43492,60753,63153,53804,67299,8000,64723,98273,51940,63499,30993,55482,70111,57271,28837,45234,19390,39885,32651,51515,17141,38384,22582,90605,59765,52938,8312,72414,62095,37719,6557,7388,33620,70353,7134,92226,32163,57634,7137,48333,31512,49625,47014,43926,96637,48206,72891,44690,9414,29732,95578,72939,87114,57654,55092,34904,72769,30567,66201,98443,63390,71731,30705,73817,42708,89459,9498,67100,40086,72279,28367,91455,31571,47885,94040,65756,10916,23084,91467,97443,10603,93961,22020,26168,86763,12743,67045,90933,93182,53709,57241,8796,31721,62361,97825,96316,50626,60533,62685,39763,4438,29887,65040,93158,38894,73602,69734,28355,68073,34963,18249,11610,88772,93432,69247,35812,66366,19413,53652,31540,20940,39029,58708,67931,3911,84407,59423,56193,61427,44561,38607,93844,66236,48767,1756,89257,49413,67591,95755,9396,30014,36989,18903,89357,85252,41168,51658,87869,70609,91468,93516,42518,52287,51918,72264,90112,36575,50398,62425,58529,70105,54078,37987,96199,66664,5746,64869,59012,12244,3159,39972,11865,54275,88479,71508,65369,19193,3169,42090,53413,34958,98783,90934,33461,59664,92070,5904,89936,61073,56990,37682,46342,20221,94824,41757,19164,3731,5971,56572,36967,70755,48822,85856,62293,97652,53626,49592,65401,93485,70857,91892,43685,93408,91004,63493,72761,37244,17257,33471,91693,41169,7634,54722,33718,58886,48207,38828,15769,92233,70042,15910,4900,52608,60957,8679,31084,95799,63601,16544,15133,31556,31101,6945,93968,45886,73476,16636,36638,15090,28470,38436,44665,22413,33909,41085,42782,39810,60681,95817,69200,62608,7609,67783,45283,51702,45370,28943,29167,45256,95382,97560,53164,73820,19956,40062,30340,41553,61310,44585,28933,46135,19402,37452,7442,70424,64470,86374,17812,88476,61592,43923,29988,73904,72523,36011,95106,69021,73029,67659,67554,45358,47788,67483,96130,92419,96804,56741,12844,41093,41495,93924,63188,88842,98580,69189,91737,28006,29481,30173,50310,43778,61108,57270,94475,97058,94191,22733,68139,31519,39884,44723,48485,44117,7276,67570,48331,89968,96563,96247,3140,49379,97953,250,10209,3864,91886,72417,57102,72780,93264,46836,94783,32930,95784,55598,39803,98388,34902,94345,7894,42748,36734,5643,19246,95532,71668,73818,66308,38411,16538,242,50649 );
UPDATE cal_cardiac_surgery_associated_with_af_gprd SET cardiac_surgery_associated_with_af_gprd = '2' WHERE medcode IN ( 18780,36101,5030,6631,17334,17088,36960,28871,9384,40264,5674,18643 );
-- Generated: 2013-06-25 08:47:37
   DROP TABLE IF EXISTS cal_cardiac_surgery_associated_with_af_opcs;

   CREATE TABLE cal_cardiac_surgery_associated_with_af_opcs AS
   SELECT 
      c.anonpatid,
      c.admidate   AS date_admission,
      c.evdate     AS date_procedure,
      c.discharged AS date_discharge,
      c.opcs
   FROM 
      hes_procedure c
   WHERE
      c.opcs IN ( 'K01','K011','K012','K018','K019','K02','K021','K022','K023','K024','K025','K026','K028','K029','K04','K041','K042','K043','K044','K045','K046','K048','K049','K05','K051','K052','K058','K059','K06','K061','K062','K063','K064','K068','K069','K07','K071','K072','K073','K078','K079','K08','K081','K082','K083','K084','K088','K089','K09','K091','K092','K093','K094','K095','K096','K098','K099','K10','K101','K102','K103','K104','K105','K108','K109','K11','K111','K112','K113','K114','K115','K116','K117','K118','K119','K12','K121','K122','K123','K124','K125','K128','K129','K14','K141','K142','K143','K144','K145','K148','K149','K15','K151','K152','K158','K159','K17','K171','K172','K173','K174','K175','K176','K177','K178','K179','K18','K181','K182','K183','K184','K185','K186','K187','K188','K189','K19','K191','K192','K193','K194','K195','K196','K198','K199','K20','K201','K202','K203','K204','K208','K209','K22','K221','K222','K228','K229','K23','K231','K232','K233','K234','K235','K236','K238','K239','K24','K241','K242','K243','K244','K245','K246','K247','K248','K249','K25','K251','K252','K253','K254','K255','K258','K259','K26','K261','K262','K263','K264','K265','K268','K269','K27','K271','K272','K273','K274','K275','K276','K278','K279','K28','K281','K282','K283','K284','K285','K288','K289','K29','K291','K292','K293','K294','K295','K296','K297','K298','K299','K30','K301','K302','K303','K304','K305','K308','K309','K31','K311','K312','K313','K314','K315','K318','K319','K32','K321','K322','K323','K324','K328','K329','K33','K331','K332','K333','K334','K335','K336','K338','K339','K34','K341','K342','K343','K344','K345','K346','K348','K349','K36','K361','K362','K368','K369','K37','K371','K372','K373','K374','K375','K376','K378','K379','K38','K381','K382','K383','K384','K385','K386','K388','K389','K40','K401','K402','K403','K404','K408','K409','K41','K411','K412','K413','K414','K418','K419','K42','K421','K422','K423','K424','K428','K429','K43','K431','K432','K433','K434','K438','K439','K44','K441','K442','K448','K449','K45','K451','K452','K453','K454','K455','K456','K458','K459','K46','K461','K462','K463','K464','K465','K468','K469','K47','K471','K472','K473','K474','K475','K478','K479','K48','K481','K482','K483','K484','K488','K489','K52','K521','K522','K523','K524','K525','K526','K528','K529','K53','K531','K532','K538','K539','K54','K541','K542','K548','K549','K55','K551','K552','K553','K554','K555','K556','K558','K559','K56','K561','K562','K563','K564','K568','K569','K57','K571','K572','K573','K574','K575','K576','K577','K578','K579','K66','K661','K668','K669','K67','K671','K678','K679','K76','K761','K768','K769' );

   -- CREATE INDEX anonpatid ON cal_cardiac_surgery_associated_with_af_opcs( anonpatid );

   ALTER TABLE cal_cardiac_surgery_associated_with_af_opcs ADD COLUMN cardiac_surgery_associated_with_af_opcs INT DEFAULT NULL;

   UPDATE cal_cardiac_surgery_associated_with_af_opcs SET cardiac_surgery_associated_with_af_opcs = '1' WHERE opcs IN ( 'K53','K433','K121','K183','K082','K362','K382','K05','K541','K252','K042','K314','K041','K41','K111','K36','K309','K303','K073','K313','K268','K255','K465','K554','K371','K25','K571','K46','K401','K28','K454','K04','K563','K428','K142','K186','K251','K29','K235','K189','K342','K068','K452','K043','K539','K234','K199','K402','K102','K062','K222','K372','K01','K198','K228','K349','K194','K15','K023','K045','K573','K249','K384','K253','K244','K196','K152','K526','K472','K345','K231','K528','K288','K412','K409','K299','K029','K06','K098','K439','K178','K293','K285','K208','K479','K373','K386','K144','K27','K301','K549','K341','K245','K538','K564','K429','K34','K312','K269','K109','K279','K374','K577','K523','K172','K461','K678','K379','K241','K422','K264','K259','K294','K278','K323','K338','K083','K388','K274','K221','K559','K101','K284','K431','K449','K442','K232','K024','K473','K459','K12','K521','K181','K37','K145','K383','K048','K028','K14','K671','K55','K361','K117','K336','K263','K33','K061','K179','K122','K112','K464','K283','K175','K768','K246','K247','K529','K555','K185','K66','K575','K378','K046','K471','K448','K099','K463','K064','K424','K092','K679','K47','K125','K242','K071','K151','K308','K177','K123','K11','K769','K542','K339','K289','K187','K258','K368','K158','K484','K089','K058','K296','K149','K275','K761','K203','K572','K129','K468','K025','K171','K474','K021','K462','K389','K012','K143','K54','K369','K302','K018','K456','K262','K188','K321','K174','K332','K458','K569','K176','K09','K328','K184','K08','K052','K298','K31','K272','K141','K116','K119','K525','K57','K561','K403','K10','K113','K182','K248','K348','K324','K229','K43','K091','K096','K108','K103','K291','K335','K532','K578','K67','K07','K343','K453','K553','K469','K318','K38','K292','K081','K418','K488','K419','K273','K432','K115','K193','K201','K411','K434','K478','K451','K315','K261','K243','K059','K329','K475','K22','K346','K105','K282','K24','K281','K548','K551','K524','K072','K026','K334','K556','K104','K195','K56','K049','K438','K522','K414','K319','K095','K20','K118','K381','K44','K011','K40','K094','K114','K238','K423','K482','K18','K30','K552','K441','K239','K574','K17','K078','K265','K019','K044','K531','K375','K455','K159','K069','K192','K088','K295','K331','K271','K022','K209','K76','K45','K079','K669','K483','K236','K576','K558','K311','K344','K385','K148','K254','K568','K02','K26','K124','K297','K661','K233','K52','K408','K481','K093','K376','K191','K128','K32','K562','K413','K322','K063','K305','K202','K42','K489','K051','K084','K173','K421','K333','K48','K404','K668','K276','K579','K19','K304','K23','K204' );
-- Generated: 2013-02-18 11:38:49

DROP TABLE IF EXISTS cal_heartvalve_gprd;

CREATE TABLE cal_heartvalve_gprd AS
SELECT 
   c.anonpatid,
   c.eventdate,
   c.medcode 
FROM 
   clinical c, 
   patient p
WHERE 
   c.anonpatid = p.anonpatid

AND 
   c.eventdate IS NOT NULL
AND 
   c.medcode IN ( 18780,62633,7276,69189,6631,73754,63562,36734,49338,5643,17334,46135,28871,40264,29887,72761 );

-- CREATE INDEX anonpatid ON cal_heartvalve_gprd( anonpatid );

ALTER TABLE cal_heartvalve_gprd ADD COLUMN heartvalve_gprd INT DEFAULT NULL;

UPDATE cal_heartvalve_gprd SET heartvalve_gprd = '1' WHERE medcode IN ( 18780,62633,7276,69189,6631,73754,63562,36734,49338,5643,17334,46135,28871,40264,29887,72761 );
-- Generated: 2013-02-18 11:38:49

   DROP TABLE IF EXISTS cal_heartvalve_opcs;

   CREATE TABLE cal_heartvalve_opcs AS
   SELECT 
      c.anonpatid,
      c.admidate   AS date_admission,
      c.evdate     AS date_procedure,
      c.discharged AS date_discharge,
      c.opcs
   FROM 
      hes_procedure c
   WHERE
      c.opcs IN ( 'K291','K294','K293','K292' );

   -- CREATE INDEX anonpatid ON cal_heartvalve_opcs( anonpatid );

   ALTER TABLE cal_heartvalve_opcs ADD COLUMN heartvalve_opcs INT DEFAULT NULL;

   UPDATE cal_heartvalve_opcs SET heartvalve_opcs = '1' WHERE opcs IN ( 'K291','K294','K293','K292' );
-- Generated: 2013-04-30 14:10:49
   DROP TABLE IF EXISTS cal_cardiacvalve_gprd;

   CREATE TABLE cal_cardiacvalve_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 30173,7894,36638,3911,93158,51658,19390,30567,57318,49592,73904,3731,22582,60957,41168,9498,34958,1756,43778,39763,35812,15133,53164,40086,53804,26168,47014,93924,98580,98783,66201,32930,72523,72417,46836,30014,38894,43923,89936,63601,60533,50649,73967,94345,61108,29887,72761,69189,7276,46135,36734,5643,50398,95817,15910,41169,17257,45256,61427,39972,63499,16636,17812,17141,67931,29732,16544,29481,19246,42748,38607,9396,39996,53696,39828,36795,60265,20940,62293,68807,1267,16545,1885,32435,51879,21807,22837,44488,50983,44328,28662,57633,30443,18100,9391,32211,43347,7963,63960,50809,10078,8274,49355,61250,17596,33262,31759,33907,31727,94872,11878,70698,29158,16373,31505,60266,21980,42239,93114,93113,62186,56029,42128,34869,9286,72306,49551,72613,44167,62207,54088,36768,28850,2977,40949,9450,1294,561,5058,34240,31839,39916,24557,4548,14998,47887,10187,999,1007,58810,1005,2343,10964,9591,30610,19019,2817,1779,97738,35372,35724,52271,98538,43855,12312,23608,15640,15496,14723,46736,38299,6077,2669,61878,34932,19957,40239,40582,19699,18475,57338,39671,22003,89579,10111,5743,53756,94521,98560,49272,53959,71004,22778,33919,12752,69169,23709,6886,8636,58734,3300,6843,57091,90551,61651,46825,50529,16539,9401,49279,53964 );

   -- CREATE INDEX anonpatid ON cal_cardiacvalve_gprd( anonpatid );

   ALTER TABLE cal_cardiacvalve_gprd ADD COLUMN cardiacvalve_gprd INT DEFAULT NULL;

   UPDATE cal_cardiacvalve_gprd SET cardiacvalve_gprd = '3' WHERE medcode IN ( 43347,43855,34958,57318,98783,89936,89579,1007,18100,73967,6843,2343,69169,3731,50983,33919,97738,19699,62293,16539,53804,49592,21807,63499,29158,11878,63960,61651,47887,72761,19390,53756,18475,14998,17141,17257,41169,22582,30610,15910,40582,60957,34240,93114,46825,3300,35372,40239,6077,12312,47014,16544,63601,15133,10964,9450,44167,51879,9401,90551,53959,60265,36795,29732,16636,94521,61250,44328,36638,30567,49272,66201,61878,50809,5058,9286,95817,33907,39828,9498,40086,68807,45256,53164,4548,8274,62186,561,46135,40949,36768,57091,26168,10078,58810,72613,17812,39671,43923,31759,50529,62207,33262,73904,72523,22837,52271,49279,28850,6886,38299,1885,999,60533,56029,54088,39763,42128,71004,57338,1267,93924,29887,2817,93158,17596,34869,9591,38894,98580,69189,7963,29481,46736,30173,94872,16373,43778,70698,10187,61108,35812,5743,98538,14723,31505,35724,23608,20940,53696,98560,93113,3911,67931,19019,61427,7276,38607,9391,42239,23709,22778,1756,30014,9396,1005,41168,51658,57633,34932,44488,24557,19957,72417,58734,46836,39996,1779,32930,28662,32211,50398,30443,49355,1294,15640,49551,2977,32435,94345,16545,7894,42748,53964,21980,36734,22003,5643,19246,60266,10111,31727,15496,8636,39972,2669,39916,31839,72306,12752,50649 );
-- Generated: 2013-02-25 10:29:24
DROP TABLE IF EXISTS cal_cardiacvalve_hes;

CREATE TABLE cal_cardiacvalve_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    (   ( icd LIKE 'I34%' )  OR ( icd LIKE 'I05%' )  OR ( icd LIKE 'Q224%' )  OR ( icd LIKE 'Q225%' )  OR ( icd LIKE 'Q221%' )  OR ( icd LIKE 'Q222%' )  OR ( icd LIKE 'Q233%' )  OR ( icd LIKE 'Q229%' )  OR ( icd LIKE 'Q239%' )  OR ( icd LIKE 'Q232%' )  OR ( icd LIKE 'I36%' )  OR ( icd LIKE 'Q231%' )  OR ( icd LIKE 'Q238%' )  OR ( icd LIKE 'Q230%' )  OR ( icd LIKE 'I06%' )  OR ( icd LIKE 'I07%' )  OR ( icd LIKE 'Q223%' )  OR ( icd LIKE 'I08%' )  OR ( icd LIKE 'I37%' )  OR ( icd LIKE 'I35%' )  OR ( icd LIKE 'Q228%' )  );

-- CREATE INDEX anonpatid ON cal_cardiacvalve_hes( anonpatid );

UPDATE
    cal_cardiacvalve_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

 UPDATE
     cal_cardiacvalve_hes c,
     hes_primary_diag_hosp h
 SET
     c.hosp_primary = 1 
 WHERE
     c.anonpatid = h.anonpatid
 AND
     c.spno = h.spno
 AND
     c.icd = h.primary_icd;

 ALTER TABLE cal_cardiacvalve_hes ADD COLUMN cal_cardiacvalve_hesardiacvalve_hes INT DEFAULT NULL;

UPDATE cal_cardiacvalve_hes SET cardiacvalve_hes = '3' WHERE (  ( icd LIKE 'I34%' ) OR  ( icd LIKE 'I05%' ) OR  ( icd LIKE 'Q224%' ) OR  ( icd LIKE 'Q225%' ) OR  ( icd LIKE 'Q221%' ) OR  ( icd LIKE 'Q222%' ) OR  ( icd LIKE 'Q233%' ) OR  ( icd LIKE 'Q229%' ) OR  ( icd LIKE 'Q239%' ) OR  ( icd LIKE 'Q232%' ) OR  ( icd LIKE 'I36%' ) OR  ( icd LIKE 'Q231%' ) OR  ( icd LIKE 'Q238%' ) OR  ( icd LIKE 'Q230%' ) OR  ( icd LIKE 'I06%' ) OR  ( icd LIKE 'I07%' ) OR  ( icd LIKE 'Q223%' ) OR  ( icd LIKE 'I08%' ) OR  ( icd LIKE 'I37%' ) OR  ( icd LIKE 'I35%' ) OR  ( icd LIKE 'Q228%' ) );
ALTER TABLE cal_cardiacvalve_hes DROP COLUMN spno;
-- Generated: 2013-06-25 11:07:15
   DROP TABLE IF EXISTS cal_anticoagulants_and_protamine_gprdprod;

   CREATE TABLE cal_anticoagulants_and_protamine_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 45,61,833,1781,4446,5305,6262,8466,8467,13348,13501,13502,13503,13504,13505,13644,15006,15376,17965,23078,30202,30203,31511,31937,33711,34019,34086,34087,34088,34095,34299,34416,34417,34418,34517,34526,34576,34691,34758,34864,34918,36099,38041,38044,39119,39444,39503,39639,39755,39866,40143,2675,2676,2677,3744,3895,4888,4995,5046,5526,5747,5998,6478,6695,6860,7154,7199,7307,7371,8664,9140,9593,9605,9610,9640,10002,10004,10044,10072,10170,10194,10240,10469,10532,10533,11117,11372,12681,12813,12974,13058,13097,13210,13270,13568,13663,13716,14099,14110,14138,14212,14308,14341,14788,14794,14851,14891,15293,15709,16061,16476,16530,17004,17007,17049,17484,17592,17664,17791,18209,18732,18771,19280,19337,19486,19989,20010,20024,20028,20029,20153,20154,20411,21233,21316,21365,21490,21518,22428,23570,23573,23579,24896,25155,25195,25287,25691,26023,26146,27035,27325,28506,28593,29043,29207,29317,29318,30108,30396,31148,31541,32511,32575,32577,32645,33307,33309,33558,35033,35941,35955,36142,36172,36196,36617,36911,36989,37086,37131,37613,37616,37678,37704,38327,38536,38839,40715 );

   -- CREATE INDEX anonpatid ON cal_anticoagulants_and_protamine_gprdprod( anonpatid );

   ALTER TABLE cal_anticoagulants_and_protamine_gprdprod ADD COLUMN anticoagulants_and_protamine_gprdprod INT DEFAULT NULL;

   UPDATE cal_anticoagulants_and_protamine_gprdprod SET anticoagulants_and_protamine_gprdprod = '1' WHERE prodcode IN ( 34088,833,38041,36099,1781,34416,34864,13503,39444,13501,34095,5305,13504,17965,8466,40143,34576,4446,61,13502,39119,15006,39755,31937,39503,13348,34517,34418,6262,30202,30203,31511,39866,34526,13644,33711,38044,13505,39639,34087,34918,34086,34691,34417,15376,34019,34758,8467,45,23078,34299 );
UPDATE cal_anticoagulants_and_protamine_gprdprod SET anticoagulants_and_protamine_gprdprod = '2' WHERE prodcode IN ( 36172,21518,14308,13058,20029,21233,25195,5998,14851,37616,18771,17592,19280,32575,17007,9140,10469,7199,10044,35955,26146,4995,12813,10532,37678,28593,7154,21490,17791,13210,20153,33307,24896,13663,22428,29207,17049,38839,19337,36911,31541,9640,20024,20010,37613,9593,21316,10072,23579,21365,18209,25155,38327,2677,6478,29043,29318,32645,20411,8664,10004,2676,7371,30396,5526,29317,17664,3895,14212,37131,3744,10002,15293,11117,27325,10240,13568,15709,17004,35941,4888,17484,16530,28506,14891,19989,36196,20028,14788,30108,25287,12974,10170,7307,10533,14110,14341,33558,2675,13716,37704,13270,23570,37086,38536,18732,6695,26023,40715,36989,20154,19486,13097,16476,14099,32577,36617,27035,9610,23573,5046,10194,33309,14138,14794,5747,35033,12681,32511,25691,11372,9605,6860,16061,31148,36142 );



-- Generated: 2013-06-25 11:16:15
   DROP TABLE IF EXISTS cal_antiplatelet_drugs_gprdprod;

   CREATE TABLE cal_antiplatelet_drugs_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 3,16,34,254,377,393,434,489,572,657,689,714,771,836,1049,1137,1814,1902,2105,2106,2607,2628,3832,4679,5882,6006,6007,6666,6696,7516,8185,8186,8645,9144,9301,9939,10031,10305,11977,13882,16597,17130,17449,17704,17920,18030,18217,18329,19189,21019,21380,21382,21921,21989,22138,22232,22618,23488,23593,23878,23932,24025,24960,25232,25284,25335,25718,28810,29759,29848,30554,30920,30975,30976,31192,31210,31211,31858,31870,31938,31953,31954,31956,32036,32210,32992,33293,33320,33656,33662,33668,33676,33877,34309,34385,34386,34434,34485,34611,34666,34709,34762,34796,34797,34942,35108,35809,36521,36543,37541,38349,38998,39738,39932,40114,40144,40381,40591,40913,41229,41512,41569,41594,41766 );

   -- CREATE INDEX anonpatid ON cal_antiplatelet_drugs_gprdprod( anonpatid );

   ALTER TABLE cal_antiplatelet_drugs_gprdprod ADD COLUMN antiplatelet_drugs_gprdprod INT DEFAULT NULL;

   UPDATE cal_antiplatelet_drugs_gprdprod SET antiplatelet_drugs_gprdprod = '1' WHERE prodcode IN ( 2105,21380,1049,836,21921,41766,34386,6006,41594,29848,25232,34385,9939,36543,10031,35809,24025,33656,31953,41569,2106,16,35108,23932,1902,31938,34762,33662,31858,33293,7516,714,377,30975,34611,25335,18030,5882,30920,32036,22618,16597,2628,31954,23488,34797,18217,33320,38998,21989,34666,9301,25284,40114,434,40591,572,6666,19189,40913,23878,18329,9144,17130,689,657,25718,393,34709,33676,22232,32992,31211,40381,34485,489,33877,31870,771,36521,6007,34434,30554,8186,31956,24960,31192,6696,17920,21382,34309,33668,8645,1814,39738,40144,28810,254,37541,8185,41229,21019,11977,32210,30976,23593,41512,10305,3832,17704,13882,29759,17449,3,1137,39932,34796,31210,34,22138,38349,2607,34942,4679 );



-- Generated: 2013-06-25 11:02:11
   DROP TABLE IF EXISTS cal_anti_arrhythmic_drugs_gprdprod;

   CREATE TABLE cal_anti_arrhythmic_drugs_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 312,15606,17109,18610,22628,26090,28916,31320,31803,32928,33442,35908,36906,220,297,700,707,940,1048,1050,1118,1120,1298,1574,1747,1748,2414,3057,3087,3167,3342,3343,3827,3943,5478,6510,8331,8524,8759,8884,8945,8975,9185,9569,10294,10688,10832,11711,11777,11972,12104,12392,12495,13251,13856,13965,14552,16328,16677,17082,17599,18615,19175,19325,19457,19459,21838,21839,21866,22826,23872,24218,25059,26171,26252,26674,26895,27295,27486,27700,27964,28048,28843,28844,29637,29763,30462,31214,31490,31711,31776,31833,32590,33471,33644,33836,34214,34378,34783,34804,34868,34959,35729,36576,38433,39009,39898,40405,41555,41586,41679,41693,188,763,786,805,1119,1291,1572,1573,2716,2717,3058,4004,4026,5441,5858,6751,7445,7465,7482,7727,8060,8632,8749,8760,8832,9188,9292,9713,10553,10687,10871,11380,12322,13051,13326,13434,13487,13549,14856,15313,17119,17679,18277,18764,24635,25482,27161,27193,27321,27727,28315,29024,29456,30047,30433,30990,31079,31209,32109,32164,32553,33119,33391,33578,34371,34515,34520,34574,34600,34640,34690,34751,34759,34851,35517,35520,35710,38498,39423,40055,41530,41551,41614,41735,608,10400,11960,12280,13140,15459,20539,21983,24708,24709,25838,25969,28155,32613,36415,40451,40910 );

   -- CREATE INDEX anonpatid ON cal_anti_arrhythmic_drugs_gprdprod( anonpatid );

   ALTER TABLE cal_anti_arrhythmic_drugs_gprdprod ADD COLUMN anti_arrhythmic_drugs_gprdprod INT DEFAULT NULL;

   UPDATE cal_anti_arrhythmic_drugs_gprdprod SET anti_arrhythmic_drugs_gprdprod = '1' WHERE prodcode IN ( 31320,22628,36906,35908,32928,26090,18610,31803,15606,28916,17109,312,33442 );
UPDATE cal_anti_arrhythmic_drugs_gprdprod SET anti_arrhythmic_drugs_gprdprod = '2' WHERE prodcode IN ( 41586,23872,21838,18615,9185,3827,8524,1050,12392,10688,1120,13856,41679,19325,297,38433,34868,26171,220,27964,26252,8331,31214,8759,3167,34959,700,1747,16677,33836,24218,707,21866,33471,28844,3087,27700,27295,12104,28843,10832,41555,26674,33644,11972,8975,34214,31776,1574,3343,11711,9569,34378,31490,8884,19457,5478,32590,12495,22826,41693,13251,3342,36576,1748,1298,29637,14552,17082,39898,35729,19175,30462,27486,2414,13965,29763,40405,34804,3943,17599,16328,19459,31833,28048,11777,34783,26895,3057,1048,6510,1118,21839,31711,940,39009,10294,8945,25059 );
UPDATE cal_anti_arrhythmic_drugs_gprdprod SET anti_arrhythmic_drugs_gprdprod = '3' WHERE prodcode IN ( 13549,34690,14856,35517,31209,13051,41551,11380,7482,805,29024,7465,30433,786,27727,8749,34520,34759,27321,34851,12322,5441,41530,30047,13326,10553,28315,32109,35710,38498,34751,32164,29456,5858,1572,34515,15313,2717,4026,763,4004,8760,9292,24635,188,1573,34640,27161,39423,33391,1119,25482,31079,41735,1291,8832,40055,32553,34371,10687,33578,9188,13487,18277,27193,34600,34574,9713,10871,7445,3058,7727,13434,30990,17119,8632,41614,8060,35520,2716,6751,18764,17679,33119 );
UPDATE cal_anti_arrhythmic_drugs_gprdprod SET anti_arrhythmic_drugs_gprdprod = '4' WHERE prodcode IN ( 12280,40451,15459,40910,24708,36415,25969,28155,11960,20539,10400,21983,32613,608,25838,13140,24709 );
-- Generated: 2013-06-25 11:16:31
   DROP TABLE IF EXISTS cal_beta_adrenoceptor_blocking_drugs_gprdprod;

   CREATE TABLE cal_beta_adrenoceptor_blocking_drugs_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 5,24,26,197,220,297,472,581,594,599,707,739,751,753,769,786,817,822,940,1006,1048,1050,1124,1288,1290,1295,1333,1334,1448,1572,1597,1684,1788,2361,2414,2432,2499,2587,2590,2629,2775,2780,3005,3087,3167,3344,3474,3516,3526,3588,3691,3748,3827,4004,4025,4265,4410,4429,4542,4588,4605,4725,4771,4796,4983,5284,5330,5478,5713,5721,5858,5968,6066,6751,7049,7066,7091,7429,7474,7528,7543,7553,7620,7852,7853,7974,8023,8061,8068,8071,8113,8147,8172,8189,8262,8290,8331,8369,8555,8623,8642,8673,8707,8807,8935,8978,8987,9016,9143,9178,9185,9273,9292,9783,10191,10294,10429,10627,10716,10777,10892,11338,11380,11711,11793,12037,12054,12141,12296,12456,12495,12517,12519,12651,13051,13394,13415,13487,13499,13526,13871,14030,14057,14058,14117,14126,14146,14438,14502,14552,14673,14808,15042,15117,15176,15488,15619,15730,16645,16776,16786,17082,17149,17322,17462,17615,17679,17783,18185,18287,18414,18743,18950,19055,19068,19142,19172,19178,19182,19191,19200,19202,19437,19853,19858,19998,20012,20082,20093,20169,20468,20502,20728,21025,21133,21182,21838,21839,21866,21873,21885,21905,21966,22208,22793,22912,23131,23134,23326,23587,24083,24094,24191,24195,24218,24280,24461,24635,24832,25359,25363,25367,25462,25644,25730,26211,26228,26229,26248,26255,26529,26741,26895,26922,27357,27486,27700,27719,27727,27946,27964,28048,28128,28177,28700,28788,28996,29180,29230,29368,29398,29427,29610,29762,29763,29827,29998,30400,30519,30541,30636,30770,31214,31470,31536,31708,31776,31833,31934,32094,32114,32135,32162,32552,32630,32787,32836,33079,33085,33092,33184,33374,33376,33569,33578,33602,33644,33650,33657,33659,33836,33839,33850,33909,34012,34034,34092,34094,34125,34171,34177,34185,34188,34208,34214,34265,34365,34371,34378,34407,34430,34443,34449,34492,34501,34509,34520,34575,34584,34585,34600,34640,34690,34695,34740,34741,34754,34783,34804,34821,34825,34854,34867,34868,34882,34884,34890,34899,34925,34945,34949,34963,34976,35054,35062,35695,35710,35778,35938,35940,36261,36576,36603,37118,37725,37837,38370,38433,38498,38991,39233,39423,39646,39819,39846,40167,40240,40241,40761,41555,41572,41591,41740 );

   -- CREATE INDEX anonpatid ON cal_beta_adrenoceptor_blocking_drugs_gprdprod( anonpatid );

   ALTER TABLE cal_beta_adrenoceptor_blocking_drugs_gprdprod ADD COLUMN beta_adrenoceptor_blocking_drugs_gprdprod INT DEFAULT NULL;

   UPDATE cal_beta_adrenoceptor_blocking_drugs_gprdprod SET beta_adrenoceptor_blocking_drugs_gprdprod = '1' WHERE prodcode IN ( 15730,18950,13499,12141,8987,26255,35062,34741,8673,26248,3827,14030,1050,5284,34125,4265,34094,38433,29180,34868,7049,36261,38370,33085,27727,19182,220,26922,21885,15042,27964,19200,40167,3588,34449,34890,14058,19178,11338,34695,32114,37118,30636,9016,1597,1333,23326,18287,33602,34365,38498,3087,37725,12296,30400,8807,31708,8707,41555,34492,1572,34821,34185,1448,10777,14808,4588,26229,4983,34378,29827,20468,739,17322,32787,32552,8023,9783,21873,29427,3344,13394,27946,2587,24,20093,29398,14552,29998,12517,32094,27719,594,2414,8642,29763,4605,19202,2361,14057,34265,4429,34925,30770,10716,1048,33092,7528,35778,940,8147,5,3748,34949,1788,9185,17462,34430,34407,39233,7620,25462,13051,11380,786,26741,23134,9143,34882,9273,34188,34963,26228,33836,8978,9178,34501,817,4025,41591,31934,28996,33376,24191,25644,41740,19172,29762,8172,14673,19437,11711,29368,13871,5478,12495,7543,23587,21966,581,2432,5968,8071,34371,34443,33659,34575,31833,28700,14502,8369,28048,24195,4542,36603,13415,15117,28128,26529,2775,472,17679,4725,31470,35054,33839,25363,40240,30519,22208,12519,25730,33850,14126,11793,34092,31536,599,39646,14117,822,13526,27357,8331,753,20082,8935,19858,21905,30541,22912,16786,24218,769,707,34899,24280,35710,197,5858,4796,26211,751,32836,8061,16645,31776,4004,34640,39423,1295,5713,16776,34208,28788,34867,32630,29230,34177,33079,7553,14146,22793,8068,24832,33909,5330,2780,1684,12651,27486,38991,2629,10892,34600,33184,19068,19998,1006,34754,34584,18743,2590,3005,25359,6751,1288,21839,24094,29610,34012,10294,34690,18414,33657,4771,21838,5721,26,3526,21025,24461,8290,17783,34509,7474,297,34854,19142,8555,1334,34520,12037,2499,35938,34034,19055,31214,35695,3167,1290,14438,20502,33650,10627,8623,21866,6066,34740,33569,7974,27700,28177,17615,24083,17149,20728,10429,7429,15488,33644,8262,34214,33374,21182,34171,9292,24635,40761,7853,34976,20012,1124,15619,23131,32135,3474,12054,36576,4410,21133,20169,32162,33578,17082,34945,7091,41572,34884,13487,34585,8113,7066,12456,34804,18185,39846,8189,34825,10191,34783,7852,19853,25367,26895,39819,37837,3516,19191,3691,40241,15176,35940 );



-- Generated: 2013-06-25 11:16:45
   DROP TABLE IF EXISTS cal_diuretics_gprdprod;

   CREATE TABLE cal_diuretics_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 2284,2551,3263,3265,5893,5954,8817,15347,20855,25138,26962,29497,34206,35399,1211,1213,1776,2979,6160,7582,7734,8102,10781,17561,17960,18983,20426,20431,22839,36519,6,55,562,814,2788,3248,3287,4182,4258,4705,5218,5249,5728,5868,6118,7606,7709,7799,7806,8052,9680,10066,10392,10422,11268,11487,12226,12294,12318,12354,12367,14761,14837,15341,16206,18096,18650,18716,19056,19192,19194,19258,19300,20538,21849,22658,24832,24835,25334,25717,26292,26529,27447,27690,27696,27926,29780,30625,30875,30913,31548,31932,32002,32091,32277,32896,32918,34006,34374,34557,34613,34934,35162,36190,36767,39602,40190,40247,40738,40898,41292,41405,56,193,211,1301,1369,2493,2495,2772,2961,3050,3793,4211,4661,4873,5220,7441,9431,9456,11265,13435,14587,15874,18332,18497,21938,25965,28129,30773,31773,33527,33658,34280,34622,38901,39807,41533,41719,692,708,787,1060,2142,2179,2389,4068,4161,4960,6815,7952,7991,9935,10214,10251,11156,11519,12946,13264,13352,14109,14144,15052,16531,17902,17950,19195,21911,23091,24893,25494,26217,29397,29694,31219,31375,31529,32837,33837,34296,34324,34347,34750,34908,35789,41074,41592,41630,41660,41706,2,58,542,581,605,764,1021,1124,1125,1170,1209,1288,1520,1788,2046,2612,2833,2982,3054,3056,3203,3517,3548,3997,4044,4332,4334,4429,4540,4796,5112,5189,5330,5721,6359,6437,6468,6786,6794,6816,6877,7066,7351,7618,7641,7698,8147,8189,8303,8369,8464,8526,8602,8623,8673,8836,8891,8987,9178,9764,9783,10316,10323,10627,10902,11133,11338,11351,11448,11469,11526,11561,11641,11864,12054,12110,12360,12440,12517,12651,12926,13246,13363,13525,13526,13871,14126,14228,14283,14438,14738,14870,15031,15108,15135,15457,15488,16060,16161,16632,16786,17143,17252,17655,17689,17720,18200,18202,18263,18267,18287,18606,18743,18903,18973,19055,19142,19352,20057,20093,21025,21231,21423,21803,21867,21873,22912,23131,23134,23427,23456,23505,24189,24190,24268,24280,24484,24632,25363,25382,26248,26256,26275,26741,27256,27520,27689,27946,27957,29427,29634,29991,31470,31670,31708,31820,32094,32166,33083,33353,33415,33651,33659,33724,34012,34034,34059,34124,34449,34551,34602,34803,34825,34899,35196,35380,35481,37650,37710,37725,37747,37908,37978,38367,38459,38889,38995,39021,39137,39147,39227,39242,39447,40149,40886,40907,41517,41572,348,923,924,1251,1297,1721,2001,2002,2255,3293,3526,3701,4034,4605,4983,5416,5727,7136,7543,7740,7961,8058,8521,8897,9223,11384,12546,12547,15127,15811,16498,18361,18726,18733,19890,20066,21182,22923,24008,25500,25505,25730,26219,26220,28157,28177,29529,30272,30519,31131,31150,34367,37294,41556 );

   -- CREATE INDEX anonpatid ON cal_diuretics_gprdprod( anonpatid );

   ALTER TABLE cal_diuretics_gprdprod ADD COLUMN diuretics_gprdprod INT DEFAULT NULL;

   UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '1' WHERE prodcode IN ( 29497,5954,34206,35399,2284,15347,2551,20855,8817,5893,26962,3263,3265,25138 );
UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '2' WHERE prodcode IN ( 17561,10781,17960,6160,1213,22839,1776,36519,1211,18983,7734,8102,20431,20426,2979,7582 );
UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '3' WHERE prodcode IN ( 19056,18650,11487,4182,18096,10066,12226,4258,35162,21849,30625,12294,5218,55,40898,40190,14761,19194,19300,9680,26292,4705,7606,12318,34374,7709,41292,12367,19258,2788,12354,24835,5868,31932,30913,27926,5249,27447,39602,3248,20538,7806,27696,27690,7799,8052,18716,31548,32002,14837,814,34934,34557,32918,3287,11268,22658,36190,6118,15341,5728,36767,32896,24832,32277,41405,25334,10422,16206,32091,40247,30875,6,562,29780,34006,10392,26529,34613,40738,25717,19192 );
UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '4' WHERE prodcode IN ( 38901,4873,193,39807,14587,28129,2495,41719,1301,21938,15874,31773,30773,34622,9456,2961,9431,41533,25965,3050,4661,4211,13435,33527,18332,11265,2772,18497,34280,2493,3793,5220,33658,7441,211,56,1369 );
UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '8' WHERE prodcode IN ( 34908,31375,34324,16531,11156,32837,6815,13264,34296,708,25494,4960,23091,17902,787,41706,41630,17950,29397,4068,2179,29694,15052,2142,11519,34750,14109,4161,7952,2389,1060,26217,9935,692,41592,12946,24893,31529,19195,10251,7991,41074,14144,33837,34347,21911,31219,10214,35789,13352,41660 );
UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '9' WHERE prodcode IN ( 24189,11864,21867,15135,8987,3056,8673,26248,14126,23456,39021,12360,1125,12110,38995,6786,39147,15108,21803,21423,7698,33415,21231,13526,34449,24632,16632,1021,11338,16161,6468,3997,34602,22912,18267,16786,27957,18287,15031,764,6437,38367,34899,24280,5189,35481,6816,11526,4796,37725,14738,11351,58,4044,31708,6794,16060,5112,39227,12926,3517,14228,2,40149,39242,29634,40886,11133,17143,11448,9783,21873,34551,29427,7641,27946,5330,27256,20093,2046,15457,12651,41517,12517,32094,38889,12440,10316,18200,3548,34803,37710,18743,33353,18973,542,17252,4429,18202,4540,17655,3203,2982,1288,37650,17720,34012,17689,8147,24484,1788,5721,7351,14870,21025,8303,27689,13525,29991,2612,10902,19142,13363,26741,11641,23134,34034,26275,18606,33083,19055,3054,1209,6877,6359,18263,14438,20057,8623,10627,9178,39137,34124,10323,38459,8891,31670,15488,23427,19352,11561,2833,34059,24268,13871,18903,35380,1124,1520,23131,581,37747,12054,27520,41572,33724,26256,605,33659,7066,31820,37908,8836,39447,8369,8189,4332,13246,34825,8526,1170,32166,8464,24190,7618,35196,8602,37978,9764,11469,33651,25382,14283,31470,4334,25363,40907,23505 );
UPDATE cal_diuretics_gprdprod SET diuretics_gprdprod = '10' WHERE prodcode IN ( 30519,21182,15127,24008,2255,34367,25730,31150,4983,3526,924,26219,8521,7543,1721,3293,20066,25505,923,1251,2001,26220,348,1297,29529,18726,8058,7136,28157,16498,31131,4605,12546,25500,5727,7961,12547,15811,2002,18361,22923,8897,28177,18733,7740,5416,37294,19890,41556,9223,3701,30272,4034,11384 );



-- Generated: 2013-06-25 11:16:59
   DROP TABLE IF EXISTS cal_fibrinolytic_drugs_gprdprod;

   CREATE TABLE cal_fibrinolytic_drugs_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 750,7511,18617,18687,22221,24609,26400,26651,29713,31993,32466,32944,35294,35385,37909,40135 );

   -- CREATE INDEX anonpatid ON cal_fibrinolytic_drugs_gprdprod( anonpatid );

   ALTER TABLE cal_fibrinolytic_drugs_gprdprod ADD COLUMN fibrinolytic_drugs_gprdprod INT DEFAULT NULL;

   UPDATE cal_fibrinolytic_drugs_gprdprod SET fibrinolytic_drugs_gprdprod = '1' WHERE prodcode IN ( 29713,31993,32466,22221,26651,40135,37909,32944,7511,750,18617,26400,35294,35385,18687,24609 );



-- Generated: 2013-06-25 11:17:22
   DROP TABLE IF EXISTS cal_hypertension_and_heart_failure_gprdprod;

   CREATE TABLE cal_hypertension_and_heart_failure_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 4374,4375,7911,7922,7923,8342,10879,13379,14442,17291,18247,28676,29443,30127,31080,40421,119,445,493,582,591,726,755,1292,1294,1455,2117,2345,2346,2347,2348,2816,3470,3715,3923,3924,4111,4449,4637,4694,4802,4875,5183,5337,5496,5618,5815,7547,7549,7759,8076,8077,8086,8198,8863,8942,9019,10088,11394,12518,12545,13610,16198,16201,19193,19216,19823,20369,22454,23010,23459,25047,25487,25551,26237,26238,26693,33094,33788,34342,34553,34601,34625,34715,35272,35603,36023,36649,36740,36780,37243,37428,38461,40256,40678,40810,40891,41543,41651,41652,41721,65,69,78,80,82,97,147,196,277,448,593,633,654,709,756,761,1021,1121,1143,1144,1299,1520,1807,1904,2982,3069,3203,3310,3720,3839,3929,4103,4571,5047,5159,5189,5275,5612,5735,5800,5861,6078,6200,6261,6288,6314,6359,6362,6364,6408,6468,6765,6786,6794,6806,6807,7314,7419,8025,8026,8105,8106,8268,8800,8830,9646,9693,9731,9764,9915,9948,10882,10902,11133,11197,11351,11561,11567,11641,11937,11965,11983,11987,12313,12411,12412,12574,12815,12858,13026,13589,13755,14228,14387,14477,14478,14960,15031,15085,15096,15108,15121,15135,15605,15958,16196,16197,16212,16701,16708,16710,16924,17006,17120,17474,17624,17633,17655,18219,18223,18263,18269,18325,19198,19204,19208,19223,19690,20188,20579,20849,20975,21053,21162,21231,21943,22439,22708,23252,23478,23642,24041,24482,25998,26995,27871,28127,28438,28486,28586,28724,28725,28820,28902,29130,29530,29627,30039,30921,31307,31587,31716,31810,32048,32166,32241,32514,32560,32597,32857,32934,33057,33078,33095,33336,33353,33646,33811,33894,33977,34357,34382,34390,34400,34412,34429,34431,34432,34453,34471,34490,34505,34528,34539,34540,34544,34562,34567,34583,34589,34651,34652,34657,34696,34698,34710,34712,34719,34732,34768,34798,34799,34877,34893,34936,34937,34943,34952,34953,35007,35302,35731,35794,36742,36753,37080,37087,37655,37710,37778,37908,37930,37964,37965,37971,37978,38026,38034,38285,38308,38510,38854,38899,38995,39137,39147,39227,39242,39355,39421,39512,40355,40384,41417,41522,41532,41538,41573,41617,41633,41694,41743,41746,520,529,531,575,624,764,828,1293,1780,2971,3222,4155,4226,4540,4645,4685,4741,4818,5013,5117,5723,5988,6217,6243,6285,6351,6437,6518,6877,6939,7043,7338,9196,9745,10316,10323,11251,11252,11348,11448,11469,11526,11864,12836,12874,13123,13821,14283,14738,14870,14943,14965,14983,16060,16161,16285,16371,17545,17686,17689,18200,18202,18903,18910,20117,21423,23456,24268,24359,24484,24632,25382,27520,29634,31072,35096,35173,35174,35189,35196,35304,35317,35329,35343,35380,35481,35697,36939,37573,37650,37747,38367,38395,38459,38889,39021,39199,39786,39944,39984,40316,40571,40639,40668,40711,41203,41205,41232,338,1707,2104,2630,2878,3049,3070,4215,4406,4993,5289,6694,7174,7416,7626,7642,8033,8296,9225,9749,9876,10253,10713,10714,11177,14390,15493,16248,18252,19892,20656,20690,21346,21502,22853,23345,23380,23761,24196,25275,25289,25393,25645,26919,28738,29187,29570,29696,30129,30293,32913,33093,33322,40310,41661,29757,36629,36878,36879,36909,504,573,1296,2362,2680,2967,2968,2970,9463,9697,13317,14495,18861,31220,32267,36612,41639 );

   -- CREATE INDEX anonpatid ON cal_hypertension_and_heart_failure_gprdprod( anonpatid );

   ALTER TABLE cal_hypertension_and_heart_failure_gprdprod ADD COLUMN hypertension_and_heart_failure_gprdprod INT DEFAULT NULL;

   UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '1' WHERE prodcode IN ( 7923,17291,4374,18247,40421,28676,7911,8342,14442,7922,31080,4375,30127,13379,10879,29443 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '2' WHERE prodcode IN ( 13610,23010,37243,26693,25551,8076,16201,4449,25047,12518,119,445,8198,41652,5815,4875,36740,2816,582,10088,4637,34601,26238,41721,19823,8077,36649,1292,16198,726,38461,2348,36780,34715,33788,4111,34342,35603,3470,41543,8942,5496,3923,4694,7549,35272,8086,33094,3715,37428,5183,9019,26237,34625,11394,19216,40810,5618,2345,25487,41651,2347,1455,12545,2117,755,20369,1294,36023,7759,40891,23459,34553,7547,40678,2346,4802,40256,591,22454,5337,3924,8863,19193,493 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '3' WHERE prodcode IN ( 41573,10882,33078,11197,31810,25998,15135,6261,41743,37930,8268,6786,39147,18219,17624,15108,1021,6765,34390,21162,15031,33057,5735,34429,6807,26995,12411,34528,32514,17633,11351,28127,18269,3929,33095,5047,32560,34567,15605,36753,34382,28820,9731,31716,15958,40384,6200,15085,33977,20975,11965,8105,34431,9948,20849,28438,11983,37710,33353,3069,8830,20579,41532,34698,5800,34540,18325,37655,34696,34651,32934,14478,10902,7419,11987,18223,28586,24482,21053,28486,37971,8800,23642,38034,37778,19223,5861,34798,39421,24041,17474,34799,39137,97,19198,12412,40355,41522,593,1144,37965,19690,35731,34583,33646,19208,761,39512,22708,1121,35007,11937,34719,29627,7314,38026,16701,28725,9693,1807,41417,32241,23252,34400,34539,32166,21943,41633,5275,38510,34471,34505,34877,6362,34544,1143,3720,30921,13589,34589,33336,33811,16212,37087,34357,28902,38995,39355,29130,31587,14477,633,9915,21231,5159,12313,6468,16197,34732,78,65,16708,3310,5189,12574,6794,8025,8106,41538,4103,34652,39227,14228,29530,39242,16924,11133,82,147,69,9646,15096,32597,756,17120,6408,4571,34562,34943,27871,6314,34953,30039,448,19204,17655,3203,2982,34657,36742,80,6806,6288,34952,23478,34412,34710,11641,5612,277,6078,32048,34432,31307,34768,34936,12858,18263,6359,37964,38285,14960,34453,16710,11567,15121,3839,34937,13026,12815,34490,20188,38854,41746,8026,1299,11561,34712,41617,22439,38308,14387,654,41694,33894,709,17006,1520,1904,35794,6364,28724,37908,13755,34893,16196,35302,32857,37978,37080,9764,38899,196 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '4' WHERE prodcode IN ( 11864,828,39944,24484,9196,39984,12836,6243,35329,14870,7338,5013,520,23456,4226,39021,24359,35096,4741,6217,16285,6518,21423,529,24632,5988,4645,16161,4155,6877,41232,39786,31072,6939,764,6437,38367,14965,35174,35481,5117,11526,4685,14738,14943,11348,40711,37573,10323,40571,38459,624,5723,41203,17545,16060,11252,9745,2971,29634,575,35173,1780,24268,40639,1293,13123,18903,35380,35697,11448,38395,40316,531,6351,7043,37747,11251,27520,41205,40668,38889,35317,12874,39199,10316,16371,6285,18200,35304,35189,14983,20117,35343,17686,18910,36939,35196,3222,4818,18202,4540,11469,25382,14283,37650,13821,17689 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '5' WHERE prodcode IN ( 20690,2878,16248,18252,10713,25289,9876,338,23761,8296,30293,21346,4993,9225,7626,25275,7642,28738,8033,24196,10253,25393,4215,25645,23380,20656,29187,22853,4406,5289,1707,32913,21502,2104,26919,29696,9749,7416,40310,10714,41661,3049,19892,11177,3070,2630,29570,30129,7174,15493,23345,6694,14390,33322,33093 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '6' WHERE prodcode IN ( 29757 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '7' WHERE prodcode IN ( 36878,36879,36909,36629 );
UPDATE cal_hypertension_and_heart_failure_gprdprod SET hypertension_and_heart_failure_gprdprod = '8' WHERE prodcode IN ( 2967,36612,1296,14495,31220,18861,2362,9463,2970,9697,2680,32267,2968,41639,13317,573,504 );



-- Generated: 2013-06-25 11:17:34
   DROP TABLE IF EXISTS cal_lipid_regulating_drugs_gprdprod;

   CREATE TABLE cal_lipid_regulating_drugs_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 644,1212,1716,1764,5564,6155,6365,11785,18081,19938,24084,32110,34201,37266,37953,653,6120,184,602,1214,1215,1217,1322,1324,1477,2215,2435,3089,3159,3318,4062,4920,4928,5216,5390,7540,8082,8706,9491,9639,9716,14379,17614,23153,29213,29328,31221,31783,33603,33944,34181,34277,39420,39576,41396,3092,4053,8851,9056,12271,17810,40729,40885,4067,7544,7551,8104,10094,11976,12211,14963,17813,17824,18098,18126,24583,2662,3204,6024,6572,14037,14209,23956,8366,8834,25,28,42,51,75,379,420,490,713,730,745,802,818,1219,1221,1223,2137,2718,2955,3411,3690,4961,5009,5148,5251,5278,5775,5985,6168,6213,7196,7347,7374,7554,8380,9153,9315,9316,9897,9920,9930,11627,13041,15252,17683,17688,18442,22579,31658,31930,32909,32921,33082,34312,34316,34353,34366,34376,34381,34476,34481,34502,34535,34545,34560,34746,34814,34820,34879,34891,34907,34955,34969,36377,37434,39060,39652,39675,39870,40340,40382,40601,41657,7552,10172,10183,10206,11815,14219,16186,17059,21020 );

   -- CREATE INDEX anonpatid ON cal_lipid_regulating_drugs_gprdprod( anonpatid );

   ALTER TABLE cal_lipid_regulating_drugs_gprdprod ADD COLUMN lipid_regulating_drugs_gprdprod INT DEFAULT NULL;

   UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '1' WHERE prodcode IN ( 37266,34201,19938,5564,1764,18081,11785,37953,6155,24084,644,1212,1716,6365,32110 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '2' WHERE prodcode IN ( 6120,653 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '3' WHERE prodcode IN ( 2435,1214,17614,41396,8082,3318,31783,31221,29213,9491,34181,8706,1322,23153,7540,5216,184,34277,9716,602,5390,1477,4920,39576,9639,1324,3089,33603,39420,2215,4928,14379,1215,33944,1217,3159,4062,29328 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '4' WHERE prodcode IN ( 40885,9056,17810,3092,4053,40729,8851,12271 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '5' WHERE prodcode IN ( 18098,18126,12211,8104,14963,11976,17813,7544,4067,7551,24583,17824,10094 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '6' WHERE prodcode IN ( 6024,3204,14037,23956,2662,6572,14209 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '7' WHERE prodcode IN ( 8834,8366 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '8' WHERE prodcode IN ( 5251,15252,5009,6213,34502,33082,9315,8380,31658,34316,9920,730,1221,34481,713,39060,34891,40340,3690,36377,6168,379,37434,13041,34376,2137,40382,9316,2955,34381,34955,17683,1219,4961,5148,7554,11627,39870,32921,2718,34560,34969,3411,17688,34353,9930,39652,25,28,75,34476,39675,5278,34907,34879,34312,34366,34820,34535,818,490,18442,7196,420,22579,1223,42,7347,34545,40601,5985,32909,51,41657,34746,7374,5775,802,745,9897,9153,31930,34814 );
UPDATE cal_lipid_regulating_drugs_gprdprod SET lipid_regulating_drugs_gprdprod = '9' WHERE prodcode IN ( 10172,7552,17059,10206,11815,21020,10183,14219,16186 );



-- Generated: 2013-06-25 11:17:46
   DROP TABLE IF EXISTS cal_nitr_calcium_chann_block_other_antianginal_gprdprod;

   CREATE TABLE cal_nitr_calcium_chann_block_other_antianginal_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 29,71,219,269,410,452,491,501,517,536,541,568,636,662,700,729,737,749,793,939,1118,1120,1130,1262,1289,1298,1300,1449,1529,1538,1574,1684,1686,1747,1748,1836,1854,1995,2280,2343,2453,2521,2528,2592,2605,2663,2686,2746,2811,2888,2926,3057,3061,3118,3221,3302,3342,3343,3370,3676,3711,3712,3917,3930,3931,3943,4227,4239,4308,4408,4542,4635,4732,4808,4852,4856,4923,4939,5054,5158,5162,5181,5194,5234,5277,5296,5326,5348,5477,5513,5570,5593,5806,5914,6309,6477,6510,6856,7280,7398,7541,7562,7681,8201,8213,8257,8310,8524,8558,8642,8759,8884,8945,8975,9240,9269,9334,9374,9386,9410,9437,9485,9553,9569,9573,9670,9708,9723,9750,10135,10136,10153,10246,10267,10595,10688,10832,11223,11512,11547,11567,11769,11770,11777,11922,11943,11965,11966,11972,11973,12104,12392,12606,12613,12639,12705,12875,13027,13033,13075,13127,13139,13240,13243,13251,13302,13410,13672,13699,13856,13926,13965,14300,14305,14861,15117,15221,15288,15652,15715,16038,16073,16162,16328,16677,16850,17006,17325,17338,17342,17406,17425,17448,17474,17492,17557,17566,17586,17599,17640,17666,18038,18223,18379,18403,18404,18606,18830,18834,18852,18874,18975,19013,19129,19170,19175,19325,19426,19440,19457,19459,19690,20257,20311,20459,20579,20591,20642,20878,20890,21145,21162,21216,21245,21763,21773,21778,21795,21872,21886,21918,22019,22142,22217,22241,22619,22696,22826,23233,23505,23733,23736,23805,23823,23872,24228,24365,24366,25059,25132,25572,25646,25777,25919,26252,26265,26267,26269,26270,26309,26337,26460,26463,26674,26759,26774,27135,27136,27295,27401,27685,28438,28688,28721,28843,28844,28949,29044,29145,29637,29676,30197,30199,30242,30462,30473,30557,30758,30915,30991,31336,31337,31489,31490,31676,31711,31737,31761,32089,32262,32590,32595,32658,32870,32917,32922,33025,33091,33471,33932,34093,34101,34115,34146,34187,34247,34377,34475,34522,34581,34607,34824,34959,34975,35084,35096,35173,35174,35189,35304,35317,35329,35343,35592,35646,35696,35697,35729,36202,36583,36620,36664,37025,37184,37530,37726,37774,37897,38066,38107,38434,38545,38632,38634,38818,38831,38855,38865,38876,38882,38964,39009,39171,39298,39357,39800,39804,39914,39984,40074,40316,40405,40633,40639,40668,41203,41205,41489,41586,41635,41679,41693,15487,15604,20741,23311,91,521,621,632,776,779,1145,1184,1260,1539,1685,1753,1754,1793,1994,2144,2145,2619,2631,2632,2633,2695,2933,2991,3091,3645,3646,3909,4508,4529,4609,4626,4677,4772,4785,4787,4843,4887,5004,5638,5894,6099,6110,6111,6159,6239,6336,6343,6821,7317,7327,7433,7559,7702,7746,7760,7761,7762,7767,7795,8037,8095,8289,8324,8330,8367,8428,8539,8573,8601,8651,8790,8793,8804,8902,8940,9088,9282,9295,9308,9323,9335,9492,9497,9523,9622,9660,9703,9719,9744,9908,10147,10459,10587,10607,10700,11189,11585,11596,11616,11957,11969,11978,12017,12063,12151,12284,12804,12968,13090,13446,13530,13534,13553,13882,14679,14685,14731,14734,14896,15034,15069,15083,15581,15582,15746,15998,16256,16630,16940,17179,17256,17571,17867,17883,18030,18655,18787,18889,18964,19839,19856,20322,20500,20530,20879,20915,21066,21380,21382,21764,22358,22427,22726,22752,22876,23011,23772,24557,24651,24671,24683,25100,25175,25276,25795,25878,26043,26221,26222,26246,26251,26253,26260,26266,26271,26279,26583,26853,27485,28030,28719,28803,29000,29072,29777,30409,31247,31475,32059,32253,32442,32841,33148,33354,33534,33660,33661,33991,33992,34196,34318,34426,34547,34558,34582,34835,34951,36181,36724,37028,37242,38883,38946,39035,39052,39130,39135,39265,39552,40388,41014,41060,41421,41676,41687,41688,41737,567,1687,11928,11981,13795,13796,18194,25379,29116,37111,39712,39713,39990,41037,41073,41378,1740,2996,3092,3995,3996,4053,4159,4573,7557,7963,8365,8851,9056,9893,10426,10672,10776,12048,12147,12251,12253,12271,12328,13223,15349,16512,17172,17810,20832,21924,22394,22875,25610,26869,29954,30635,30765,40615 );

   -- CREATE INDEX anonpatid ON cal_nitr_calcium_chann_block_other_antianginal_gprdprod( anonpatid );

   ALTER TABLE cal_nitr_calcium_chann_block_other_antianginal_gprdprod 
   ADD COLUMN nitrates_calcium_channel_blockers_other_antianginal INT DEFAULT NULL;

   UPDATE cal_nitr_calcium_chann_block_other_antianginal_gprdprod SET nitrates_calcium_channel_blockers_other_antianginal = '1' WHERE prodcode IN ( 25919,21763,9410,71,5477,11512,13139,2746,10688,737,32658,4227,13027,38634,517,17640,34607,35646,1836,26252,13075,2453,37184,23233,21162,15221,29,13243,21773,12104,17425,34581,22619,5054,32595,26674,17406,11223,22241,17586,33025,2592,34975,19440,9569,3711,31490,34824,31336,939,13302,38066,3302,2280,16038,662,40316,28688,3342,38107,36664,7398,9573,1748,23823,1298,20878,27685,11965,25132,17666,3370,40668,8642,21795,28438,30242,26267,11777,3931,26460,3061,28721,20459,9553,11973,20579,5194,36202,31711,39009,9374,23872,19170,21216,38882,21886,8524,19325,16073,410,4856,2811,6477,13410,1854,2926,1289,18223,536,25572,13699,1130,1529,8201,41635,452,1747,5234,21245,8558,35174,13672,541,17474,26337,27295,23805,28949,2521,16850,11972,8975,21778,9670,31676,30557,13033,10136,3343,9334,21145,8884,34475,27401,26270,19690,10267,34377,18834,22826,20311,35696,20591,13251,5806,4852,5593,33932,9240,29637,35729,34522,9269,37774,30462,41205,11966,3676,30197,40405,269,16328,35304,15288,4542,15117,35592,20257,568,3221,1449,21918,18403,25059,3712,8945,23505,31489,2528,17342,38964,22696,10246,35329,9437,17566,12392,38865,27136,13856,8257,2343,7681,10595,13127,5296,7541,2663,8759,18852,36583,700,16677,19013,12639,5162,24365,33471,11943,39171,4239,17325,10832,40074,1300,18975,35084,40633,8213,11922,13240,30473,26265,729,32089,38632,36620,19457,18830,32590,10135,18379,1995,4635,18874,35697,17448,41693,749,38831,37025,39804,5277,12606,4408,6309,23733,1684,19175,5181,13965,26269,3943,13926,34101,636,9750,34247,23736,34187,26759,37530,2686,1118,21872,24366,41586,39984,39914,22142,17338,4923,14300,5326,11547,1120,35096,34093,41679,26774,5513,19129,39298,18606,32870,34115,15715,5914,3917,1262,18404,37726,31761,38434,34959,16162,31337,31737,27135,4308,11770,11567,28844,19426,41489,1538,5348,28843,10153,30915,26309,2605,9485,5158,34146,5570,41203,33091,4808,1574,25646,7280,2888,20642,29044,793,37897,9723,35173,3930,40639,9386,9708,4939,17006,26463,4732,22217,11769,14305,501,30991,20890,29145,38855,25777,6856,3118,12875,12613,35317,29676,491,17599,15652,30758,19459,219,35189,24228,39357,30199,38545,7562,22019,35343,17492,39800,1686,32262,14861,3057,38818,32922,38876,6510,17557,18038,8310,32917,12705 );
UPDATE cal_nitr_calcium_chann_block_other_antianginal_gprdprod SET nitrates_calcium_channel_blockers_other_antianginal = '2' WHERE prodcode IN ( 15604,15487,20741,23311 );
UPDATE cal_nitr_calcium_chann_block_other_antianginal_gprdprod SET nitrates_calcium_channel_blockers_other_antianginal = '3' WHERE prodcode IN ( 22427,2632,7559,9323,33991,1539,33661,3646,5004,9719,17571,8428,3909,6821,31475,12804,25276,14734,9492,779,14896,10587,1754,39552,4772,1184,2144,6336,39130,15582,13446,18655,9622,22876,9282,1145,8793,22358,27485,7433,16630,9335,9703,41676,4787,4887,34558,15083,26853,12017,1753,17179,9744,20530,20322,34196,7762,34547,24671,2145,7702,32059,11596,2619,2933,24651,7795,21382,11189,36724,4609,12968,26222,776,41421,23772,26266,4785,9295,7760,8940,28030,6239,33534,8804,31247,8037,29072,13553,10147,36181,22752,15581,8289,18964,38883,26279,3091,9908,4626,21764,19839,18787,30409,28719,12151,2695,2631,4843,38946,34582,26253,21380,621,37242,7317,1793,34318,5894,8601,33992,25100,521,13530,17256,11616,12284,26583,6099,15746,33660,23011,8651,41687,11957,11969,18030,7746,13090,25175,20500,17867,6111,6159,39035,33354,4677,22726,632,91,21066,16256,9088,26251,34426,8324,34951,12063,24683,1994,32253,2633,10607,3645,14679,9497,19856,10700,14685,39052,4529,8902,13534,8367,6110,41060,15069,20879,6343,25878,17883,10459,41014,26271,26043,16940,37028,8095,29777,26221,24557,18889,26260,32442,15998,7327,33148,11978,8573,9660,40388,39135,9523,5638,1685,8539,29000,13882,9308,41688,8330,25795,4508,14731,41737,11585,7761,1260,32841,15034,7767,8790,39265,28803,26246,20915,2991,34835 );
UPDATE cal_nitr_calcium_chann_block_other_antianginal_gprdprod SET nitrates_calcium_channel_blockers_other_antianginal = '4' WHERE prodcode IN ( 25379,18194,37111,567,39712,39713,11928,1687,41037,13796,13795,41073,41378,11981,29116,39990 );
UPDATE cal_nitr_calcium_chann_block_other_antianginal_gprdprod SET nitrates_calcium_channel_blockers_other_antianginal = '5' WHERE prodcode IN ( 30635,12147,9056,17810,21924,20832,29954,26869,9893,7557,8365,3995,40615,3996,16512,10426,30765,12251,12253,22875,7963,17172,22394,3092,4573,25610,8851,12048,12271,15349,2996,13223,12328,4159,1740,4053,10776,10672 );



-- Generated: 2013-06-25 11:18:03
   DROP TABLE IF EXISTS cal_positive_inotropic_drugs_gprdprod;

   CREATE TABLE cal_positive_inotropic_drugs_gprdprod AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.prodcode,
      c.bnfcode,
      c.qty,
      c.ndd,
      c.numdays,
      c.numpacks,
      c.packtype,
      c.issueseq
 
   FROM 
      therapy c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.prodcode IN ( 36,94,333,792,2302,2511,3181,3286,3705,7864,7866,9522,12179,16366,17169,20844,20944,25238,27523,29282,33080,33274,33611,33612,33675,34017,34023,34024,34327,34328,34519,34948,40245 );

   -- CREATE INDEX anonpatid ON cal_positive_inotropic_drugs_gprdprod( anonpatid );

   ALTER TABLE cal_positive_inotropic_drugs_gprdprod ADD COLUMN positive_inotropic_drugs_gprdprod INT DEFAULT NULL;

   UPDATE cal_positive_inotropic_drugs_gprdprod SET positive_inotropic_drugs_gprdprod = '1' WHERE prodcode IN ( 33274,29282,33611,16366,33080,9522,34519,2511,40245,34948,12179,3181,34328,34017,25238,333,3705,33675,3286,36,7864,94,2302,34327,17169,34023,20844,27523,20944,34024,792,7866,33612 );



DROP TABLE IF EXISTS cal_carotid_angio_gprd;
CREATE TABLE cal_carotid_angio_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 20016,
      1,
      WHEN
         c.medcode = 41818,
         3, 
         WHEN
            c.medcode IN ( 19824,13985,2659,49693 ),
            4,
            9 ) ) ) AS carotid_angio_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   carotid_angio_gprd != 9

UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS carotid_angio_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND ( 
   (
      t.medcode IN ( 19824,13985,2659,49693,20016,41818 )
   AND
      t.enttype IN ( 251 ) 
   )
   OR
   t.enttype = 301   
   )

HAVING
   carotid_angio_gprd != 9
   
ORDER BY
   anonpatid;
   
-- code conflict resolution
-- 
-- normal medcode , potentially abnormal status

UPDATE cal_carotid_angio_gprd 
SET carotid_angio_gprd = 5 
WHERE medcode = 20016 AND carotid_angio_gprd = 2;

-- normal medcode, abnormal status

UPDATE cal_carotid_angio_gprd
SET cal_carotid_angio_gprd = 6
WHERE medcode = 20016 AND carotid_angio_gprd = 3;

UPDATE cal_carotid_angio_gprd
SET cal_carotid_angio_gprd = 6
WHERE medcode = 41818 AND cal_carotid_angio_gprd = 1;

-- abnormal medcode, potentially abnormal status

UPDATE cal_carotid_angio_gprd 
SET carotid_angio_gprd = 7
WHERE medcode = 41818 AND carotid_angio_gprd = 2;
DROP TABLE IF EXISTS cal_carotid_endarterectomy_gprd;
CREATE TABLE cal_carotid_endarterectomy_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 2654,12733,35916 ),
      3,
      WHEN
         c.medcode IN ( 29973,47580 ),
         4, 
         9 ) ) AS carotid_endarterectomy_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   carotid_endarterectomy_gprd != 9;
DROP TABLE IF EXISTS cal_carotid_endarterectomy_opcs;
CREATE TABLE cal_carotid_endarterectomy_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    WHEN
        opcs IN ( 'L294','L295' ),
        3,
        WHEN
            opcs IN ( 'L314','L311' ),
            4,
            9 ) ) AS carotid_endarterectomy_opcs
FROM
    hes_procedure h
HAVING carotid_endarterectomy_opcs != 9 ;
DROP TABLE IF EXISTS cal_carotid_us_gprd;
CREATE TABLE cal_carotid_us_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 13995,
      1,
      WHEN
         c.medcode = 12413,
         3, 
         WHEN
            c.medcode IN ( 51257,18366 ),
            4,
            9 ) ) ) AS carotid_us_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   carotid_us_gprd != 9

UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS carotid_us_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 51257,18366,12413, 13995 )
AND
   t.enttype IN ( 339, 251 ) 

HAVING
   carotid_us_gprd != 9
   
ORDER BY
   anonpatid;
   
-- code conflict resolution

-- normal medcode , potentially abnormal via entity code

UPDATE cal_carotid_us_gprd 
SET carotid_us_gprd = 5 
WHERE medcode = 13995  AND carotid_us_gprd = 2;

-- normal medcode, abnormal entity code

UPDATE cal_carotid_us_gprd 
SET cal_carotid_us_gprd = 6
WHERE medcode = 13995 AND cal_carotid_us_gprd = 3;

UPDATE cal_carotid_us_gprd
SET cal_carotid_us_gprd = 6
WHERE medcode = 12413 AND cal_carotid_us_gprd = 1 ;

-- abnormal medcode, potentially abnormal via entity code

UPDATE cal_carotid_us_gprd 
SET carotid_us_gprd = 7
WHERE medcode = 12413 AND carotid_us_gprd = 2;
   
DROP TABLE IF EXISTS cal_cerebral_ct_gprd;
CREATE TABLE cal_cerebral_ct_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 49118,27134,86417 ),
      4,
      9 ) AS cerebral_ct_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   cerebral_ct_gprd != 9

UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS cerebral_ct_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 49118,27134,86417 ) 
AND
     t.enttype IN ( 251, 299 )

HAVING
   cerebral_ct_gprd != 9
   
ORDER BY
   anonpatid;
   
-- Note: code conflict resolution not required, medcodes are neutral

DROP TABLE IF EXISTS cal_cerebral_haem;
CREATE TABLE cal_cerebral_haem AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
	WHEN c.medcode IN ( 43451,48149,28914 ) THEN 1
	WHEN c.medcode IN ( 53810,5051,18604,31595,30202,7912,28314,31060,6960,57315,46316,13564,19201,3535,96630,40338,30045 ) THEN 3
        WHEN c.medcode IN ( 17326,19412,56007 ) THEN 4
        WHEN c.medcode IN ( 7862,8181,4273,94351,53980,17734,4917,6569,96677,2883,18912 ) THEN 5
        WHEN c.medcode IN ( 43418,36178,73471,51504,4107,45421,18411,27661 ) THEN 6
        WHEN c.medcode IN ( 20284,31805 ) THEN 7
        WHEN c.medcode IN ( 5682,31941,42283,52968,46545,28077 ) THEN 8
        ELSE 9 
   END cerebral_haem
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_cerebral_haem WHERE cerebral_haem = 9;

DROP TABLE IF EXISTS cal_cerebral_procs_opcs;
CREATE TABLE cal_cerebral_procs_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    CASE
    WHEN opcs IN ( 'L31','L309','L308','L298','L318','L301','L291','L30','L319','L303','L313','L293','L299','L29','L292' ) THEN 2
    WHEN opcs IN ( 'L314','L372','L294','L311','L353','L296','L297','L295' ) THEN 3
    ELSE 9 
    END cerebral_procs_opcs
FROM
    hes_procedure h;

DELETE FROM cal_cerebral_procs_opcs WHERE cerebral_procs_opcs = 9;

DROP TABLE IF EXISTS cal_cerebral_stroke_hes;
CREATE TABLE cal_cerebral_stroke_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN icd LIKE 'I690%' THEN 1
    WHEN icd LIKE 'I61%' THEN 3
    WHEN icd LIKE 'I60%' THEN 4
    WHEN icd LIKE  'I620%' THEN 5
    WHEN icd LIKE 'I621%' THEN 6
    WHEN icd LIKE  'I629%' THEN 7
    ELSE 9 
    END cerebral_stroke_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_cerebral_stroke_hes WHERE cerebral_stroke_hes = 9;

UPDATE
    cal_cerebral_stroke_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_cerebral_stroke_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_cerebral_stroke_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_ischaem_cerebro_nec;
CREATE TABLE cal_ischaem_cerebro_nec AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN c.medcode = 41577 THEN 1
   WHEN c.medcode IN ( 33377,22008,50594,60102,50241,31876,21118,2752,44765,8692,91515,36390,8659,52241,23942,36579,2417,12634,98204,22447,5268,50678,10794,40098,96117,20510 )
   THEN 2 
   WHEN c.medcode IN ( 16517,4152,51759,31704,57495,18689,15252,37199,22677,4240,32447,10062,10504,8837,36717,2418,51138,15019,24446,43292,34117,65770,57527,9565,71274,27975,56912,23361,19280,9985,25615,55602,98642,42279,40847,19477,51326,73901,51311,98188,13577,9943,43089,45781,55467,71585,2652,37493,12555,63830,569,39344,19260,2156,24385,34758,23671,5602,26424,3149 )
   THEN 3
   ELSE 9 
   END ischaem_cerebro_nec
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_ischaem_cerebro_nec WHERE ischaem_cerebro_nec = 9;

DROP TABLE IF EXISTS cal_cerebro_ops_gprd;
CREATE TABLE cal_cerebro_ops_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN
   c.medcode IN ( 25910,68329,20672,40347,20811,43449,68069,17960,97003,52008,68366,62661,70235,73022,15007,39780,44023,41703 ) THEN 2
   WHEN
   c.medcode IN ( 93134,35916,47580,55074,68905,93770,2654,12733,29973,68906,89365,91775 ) THEN 3 
   ELSE 9 
   END cerebro_ops_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_cerebro_ops_gprd WHERE cerebro_ops_gprd = 9;
   
DROP TABLE IF EXISTS cal_cvd_minap;
CREATE TABLE cal_cvd_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    1 AS cvd_minap
FROM 
    minap
WHERE
    cvd = 1
AND
   anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;


DROP TABLE IF EXISTS cal_ischaem_stroke_gprd;
CREATE TABLE cal_ischaem_stroke_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN c.medcode = 39403 THEN 1
   WHEN c.medcode IN ( 40053,6155,40758,5363,91627,53745,90572,94482,92036,33543 ) THEN 3 
   ELSE 9 
   END ischaem_stroke_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_ischaem_stroke_gprd WHERE ischaem_stroke_gprd = 9;

DROP TABLE IF EXISTS cal_ischaem_cvd_hes;
CREATE TABLE cal_ischaem_cvd_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN ( icd LIKE 'I670%'
          OR icd LIKE 'I673%'
          OR icd LIKE 'I671%' ) THEN 2
    WHEN
            ( icd LIKE 'I653%'
              OR icd LIKE 'G468A%'
              OR icd LIKE 'G462A%'
              OR icd LIKE 'I68X%'
              OR icd LIKE 'I672%'
              OR icd LIKE 'I663%'
              OR icd LIKE 'I652%'
              OR icd LIKE 'I668%'
              OR icd LIKE 'G46X%'
              OR icd LIKE 'I65%'
              OR icd LIKE 'I651%'
              OR icd LIKE 'I664%'
              OR icd LIKE 'I66%'
              OR icd LIKE 'G461A%'
              OR icd LIKE 'I679%'
              OR icd LIKE 'I67X%'
              OR icd LIKE 'I659%'
              OR icd LIKE 'I662%'
              OR icd LIKE 'I660%'
              OR icd LIKE 'I658%'
              OR icd LIKE 'I678%'
              OR icd LIKE 'I669%'
              OR icd LIKE 'I661%'
              OR icd LIKE 'G460A%'
              OR icd LIKE 'I650%' ) THEN  3
    ELSE 9 
    END ischaem_cvd_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_ischaem_cvd_hes WHERE ischaem_cvd_hes = 9;

UPDATE
    cal_ischaem_cvd_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_ischaem_cvd_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_ischaem_cvd_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_ischaem_stroke_hes;
CREATE TABLE cal_ischaem_stroke_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN icd LIKE 'I693%' THEN 1
    WHEN icd LIKE 'I63%' THEN  3
    ELSE 9 
    END ischaem_stroke_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_ischaem_stroke_hes WHERE ischaem_stroke_hes = 9;

UPDATE
    cal_ischaem_stroke_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_ischaem_stroke_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_ischaem_stroke_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_stroke_nos_gprd;
CREATE TABLE cal_stroke_nos_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN c.medcode IN (  56458,5871,19348,7138,18686,51465,34375,28753,66873,6305,89913,34245,34135,31218,6228,55351 )
   THEN 1
   WHEN c.medcode IN ( 52246,32959,42248,11039,11074,10962,95347,70536,57183,10792,98145,18687 ) 
   THEN 2 
   WHEN c.medcode IN ( 17322,47642,51767,1469,33499,56279,8443,93459,47607,5185,6116,12833,1298,6253,7780 )
   THEN 3
   ELSE 9 
   END stroke_nos_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_stroke_nos_gprd WHERE stroke_nos_gprd = 9;

DROP TABLE IF EXISTS cal_stroke_nos_hes;
CREATE TABLE cal_stroke_nos_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN
        ( icd LIKE 'I691%'
          OR icd LIKE 'I692%'
          OR icd LIKE 'I698%'
          OR icd LIKE 'I69X%'
          OR icd LIKE 'I694%' )
    THEN 1
    WHEN
            ( icd LIKE 'I64X%'
              OR icd LIKE 'G466A%'
              OR icd LIKE 'G465A%'
              OR icd LIKE 'G464A%'
              OR icd LIKE 'G467A%'
              OR icd LIKE 'G463A%' )
    THEN 3
    ELSE 9 
    END stroke_nos_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_stroke_nos_hes WHERE stroke_nos_hes = 9;

UPDATE
    cal_stroke_nos_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_stroke_nos_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_stroke_nos_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_stroke_nos_opcs;
CREATE TABLE cal_stroke_nos_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    3 AS stroke_nos_opcs
FROM
    hes_procedure h
WHERE
    opcs = 'U543';
        
DROP TABLE IF EXISTS cal_any_mi_gprd;
CREATE TABLE cal_any_mi_gprd ( 
      anonpatid INT, 
      eventdate DATE, 
      any_mi_gprd CHAR(1) 
      DEFAULT 0 ); 

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_stemi_gprd WHERE stemi_gprd = 3;

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_nstemi_gprd WHERE nstemi_gprd IN (1,3);

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_mi_nos_gprd WHERE mi_nos_gprd IN (1,3);

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_recg_gprd WHERE recg_gprd IN (1,3);

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_troponins_gprd WHERE troponins_gprd IN (2,3);
   
INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_cardiac_markers_gprd WHERE cardiac_markers_gprd IN (2,3);

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_lysis_gprd WHERE lysis_gprd IN (2,3);

INSERT INTO cal_any_mi_gprd 
   SELECT anonpatid,eventdate,1 FROM cal_ckmb_gprd WHERE ckmb_gprd IN (2,3);
DROP TABLE IF EXISTS cal_cardiac_markers_gprd;
CREATE TABLE cal_cardiac_markers_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 19634 ,
      1,
      WHEN
         c.medcode IN ( 5221,60664 ),
         3, 
         WHEN
            c.medcode IN ( 27207,19849,61960, 2403 ),
            4,
            9 ) ) ) AS cardiac_markers_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   cardiac_markers_gprd != 9
   
UNION

-- entity type 332, lookup 1 is TQU

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS cardiac_markers_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 27207,19849,61960, 2403, 5221,60664, 19634 )
AND
   t.enttype = 332

HAVING
   cardiac_markers_gprd != 9
   
UNION

-- entity type 288, 176, 156, lookup 4 is TQU

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data4 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data4 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data4 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS cardiac_markers_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 27207,19849,61960, 2403, 5221,60664, 19634 )
AND
   t.enttype IN ( 288, 176, 156 )

HAVING
   cardiac_markers_gprd != 9

   
ORDER BY
   anonpatid;

-- medcode and entity code conflict resolution

-- medcode normal but entity code potentially abnormal

UPDATE cal_cardiac_markers_gprd
SET cardiac_markers_gprd = 5  
WHERE medcode = 19634 -- normal 
AND cardiac_markers_gprd = 2; -- potentially abnormal

-- code conflict normal - abnormal

UPDATE cal_cardiac_markers_gprd
SET cardiac_markers_gprd = 6 
WHERE  medcode = 19634 -- normal
AND cardiac_markers_gprd = 3; --  abnormal

UPDATE cal_cardiac_markers_gprd
SET cal_cardiac_markers_gprd = 6
WHERE medcode IN ( 5221,60664 ) -- abnormal
AND cal_cardiac_markers_gprd = 1;

-- code conflict - abnormal and potentially abnormal

UPDATE  cal_cardiac_markers_gprd
SET  cardiac_markers_gprd = 7
WHERE medcode IN ( 5221,60664 ) -- abnormal
AND cardiac_markers_gprd = 2; --  potentially abnormal

DROP TABLE IF EXISTS cal_ckmb_gprd;
CREATE TABLE cal_ckmb_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 14350,49201,43046 ),
      4,
      9 )  AS ckmb_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   ckmb_gprd != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS ckmb_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN (  14350,49201,43046 )
AND
   t.enttype = 332

HAVING
   ckmb_gprd != 9

UNION

-- entities 438 and 288, TQU is data4

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data4 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data4 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data4 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS ckmb_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 14350,49201,43046 )
AND
   t.enttype IN ( 438, 288 )

HAVING
   ckmb_gprd != 9
   
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_hist_mi_minap;
CREATE TABLE cal_hist_mi_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    history_ami,
    1 AS hist_mi_minap
FROM 
    minap
WHERE
    history_ami = 1
AND
   anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;

    DROP TABLE IF EXISTS cal_lysis_gprd;
CREATE TABLE cal_lysis_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 40996,33650 ),
      2,
      WHEN
         c.medcode IN ( 70440,94504 ),
         3, 
         WHEN
            c.medcode IN ( 18030,49423,84367 ),
            4,
			WHEN
				c.medcode IN ( 51157,72492,96361,90778,59689,44348,62238,45874,68469,41883,22892,47097 ),
				5,
				WHEN
					c.medcode IN ( 54922,66690),
					6,
					9 ) ) ) ) ) AS lysis_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   lysis_gprd != 9
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_lysis_minap;
CREATE TABLE cal_lysis_minap AS 
SELECT
    DISTINCT
    id_nhs_number,
    date_admission,
    1 AS lysis_minap
FROM 
    minap
WHERE
    id_nhs_number IS NOT NULL
AND
    ( 
        thrombolytic_drug BETWEEN 1 AND 4
    OR
        init_reperf_treatment = 1
    OR 
        additional_reperfusion_treatment = 3 
    OR 
        additional_reperfusion_treatment = 4 );
    DROP TABLE IF EXISTS cal_lysis_opcs;
CREATE TABLE cal_lysis_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    2 AS lysis_opcs
FROM
    hes_procedure h
WHERE
    opcs IN ( 'K503', 'K502' );

DROP TABLE IF EXISTS cal_mi_hes;
CREATE TABLE cal_mi_hes AS
SELECT
    diag.anonpatid,
    epi.admidate   AS date_admission,
    epi.discharged AS date_discharge,
    diag.spno      AS spell_id,
    diag.epikey    AS episode_id,
    epi.eorder     AS episode_order,
    icd,
    CASE
    WHEN
    icd LIKE 'I252%' THEN 1
    WHEN
            ( icd LIKE 'I214%'
            OR icd LIKE 'I210%'
            OR icd LIKE 'I213%'
            OR icd LIKE 'I219%'
            OR icd LIKE 'I212%'
            OR icd LIKE 'I21%'
            OR icd LIKE 'I211%' )
    THEN 3
    WHEN
                 ( icd LIKE 'I232%'
                OR icd LIKE 'I228%'
                OR icd LIKE 'I238%'
                OR icd LIKE 'I229%'
                OR icd LIKE 'I236%'
                OR icd LIKE 'I235%'
                OR icd LIKE 'I233%'
                OR icd LIKE 'I220%'
                OR icd LIKE 'I22%'
                OR icd LIKE 'I221%'
                OR icd LIKE 'I230%'
                OR icd LIKE 'I241%'
                OR icd LIKE 'I23%'
                OR icd LIKE 'I231%'
                OR icd LIKE 'I234%'  )
    THEN 4
    ELSE 9 
    END mi_hes,
    diag.primary_epi AS epi_primary,
    0            AS hosp_primary
FROM    
    hes_diag_epi diag,
    hes_episode epi
WHERE
    diag.anonpatid = epi.anonpatid
AND
    diag.spno = epi.spno;

DELETE FROM cal_mi_hes WHERE mi_hes = 9;

-- CREATE INDEX anonpatid_spno ON cal_mi_hes(anonpatid,spell_id);

UPDATE
    cal_mi_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spell_id = h.spno
AND
    c.icd = h.primary_icd;
DROP TABLE IF EXISTS cal_mi_minap;
CREATE TABLE cal_mi_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    discharge_diagnosis,
    cardiac_markers_raised,
    ecg_determ_treatment,
    0 AS mi_minap
FROM 
    minap
WHERE
   anonpatid IS NOT NULL
AND
  date_admission IS NOT NULL;

DELETE FROM cal_mi_minap WHERE discharge_diagnosis NOT IN ( 1,2,4,5,10 ) AND cardiac_markers_raised NOT IN (1,9);

UPDATE cal_mi_minap SET mi_minap = 1 WHERE discharge_diagnosis = 1 AND ecg_determ_treatment IN (1,2,9);
UPDATE cal_mi_minap SET mi_minap = 1 WHERE ecg_determ_treatment = 1;
UPDATE cal_mi_minap SET mi_minap = 2 WHERE mi_minap = 0;

ALTER TABLE cal_mi_minap 
DROP COLUMN discharge_diagnosis,
DROP COLUMN cardiac_markers_raised,
DROP COLUMN ecg_determ_treatment;
DROP TABLE IF EXISTS cal_mi_nos_gprd;
CREATE TABLE cal_mi_nos_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN
   c.medcode IN ( 9555,35674,4017,50372,17464,16408,23579,40399 ) THEN 1
   WHEN
         c.medcode IN ( 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,35119,41221,12139,13571,59940,15661,30421,59189,36423,38609,29553,13566,5387,14658,14898,62626,40429,37657,72562,8935,3704,9507,61670,96838,68357,29758,69474,34803,28736,18842,1678,23892,14897,32272,46166,17689,46112 )
   THEN 3
   ELSE 9 
   END mi_nos_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_mi_nos_gprd WHERE mi_nos_gprd = 9;
   
DROP TABLE IF EXISTS cal_mi_nos_referral_gprd;
CREATE TABLE cal_mi_nos_referral_gprd AS
SELECT
   r.anonpatid,
   r.eventdate,
   r.medcode,
   WHEN
      r.medcode IN ( 9555,35674,4017,50372,17464,16408,23579,40399 ),
      1,
      WHEN
         r.medcode IN ( 15661, 46276,46017,63467,1677,1204,30330,241,41835,68748,17133,2491,23708,29643,24126,32854,45809,17872,41221,12139,13571,59940,30421,59189,36423,38609,29553,13566,5387,14658,14898,62626,40429,37657,72562,8935,3704,9507,61670,96838,68357,29758,69474,34803,28736,18842,1678,23892,14897,32272,46166,17689,46112 ),
         3, 
         9 ) ) AS mi_nos_referral_gprd
FROM
   referral r,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   r.anonpatid = p.anonpatid

HAVING
   mi_nos_referral_gprd != 9
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_nstemi_gprd;

CREATE TABLE cal_nstemi_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN
      c.medcode = 10562 THEN 3
   ELSE   9 
   END nstemi_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_nstemi_gprd WHERE nstemi_gprd = 9;

DROP TABLE IF EXISTS cal_nstemi_referral_gprd;
CREATE TABLE cal_nstemi_referral_gprd AS
SELECT
   r.anonpatid,
   r.eventdate,
   r.medcode,
   WHEN
      r.medcode = 10562 ,
      3,
      9 ) AS nstemi_referral_gprd
FROM
   referral r,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   r.anonpatid = p.anonpatid

HAVING
   nstemi_referral_gprd != 9
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_ppci_minap;
CREATE TABLE cal_ppci_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    coronary_intervention,
    reason_reperf_not_given,
    init_reperf_treatment,
    additional_reperfusion_treatment,
    0 AS ppci_minap
FROM 
    minap
WHERE
   anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;

UPDATE cal_ppci_minap SET ppci_minap = 0 WHERE coronary_intervention = 8;
UPDATE cal_ppci_minap SET ppci_minap = 2 WHERE coronary_intervention = 2;
UPDATE cal_ppci_minap SET ppci_minap = 9 WHERE ( coronary_intervention = 9 OR coronary_intervention IS NULL );

UPDATE cal_ppci_minap SET ppci_minap = 1 WHERE ( coronary_intervention = 1 
    OR reason_reperf_not_given = 50 OR init_reperf_treatment = 2 
    OR additional_reperfusion_treatment IN (1,3) );

-- IF MINAP coronary_intervention = 8, MINAP_ppci = 0;

-- IF MINAP coronary_intervention = 1 or 50, MINAP_ppci = 1;
-- IF MINAP reason_reperf_not_given = 50, MINAP_ppci = 1;
-- IF MINAP init_reperf_treatment = 2 MINAP_ppci = 1;
-- IF MINAP additional_reperfusion_treatment = (1,3)  MINAP_ppci = 1

-- IF MINAP coronary_intervention = 2, MINAP_ppci = 2;
-- IF MINAP coronary_intervention = 9 or missing, MINAP_ppci = 9;

ALTER TABLE cal_ppci_minap DROP COLUMN coronary_intervention,
    DROP COLUMN reason_reperf_not_given, 
    DROP COLUMN init_reperf_treatment,
    DROP COLUMN additional_reperfusion_treatment;

DELETE FROM cal_ppci_minap WHERE ppci_minap = 0;

DROP TABLE IF EXISTS cal_stemi_gprd;
CREATE TABLE cal_stemi_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE 
   WHEN c.medcode = 12229 THEN 3
   ELSE 9 
   END stemi_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_stemi_gprd WHERE stemi_gprd = 9;

DROP TABLE IF EXISTS cal_stemi_referral_gprd;
CREATE TABLE cal_stemi_referral_gprd AS
SELECT
   r.anonpatid,
   r.eventdate,
   r.medcode,
   WHEN
      r.medcode = 12229,
      3,
      9 ) AS stemi_referral_gprd
FROM
   referral r,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   r.anonpatid = p.anonpatid

HAVING
   stemi_referral_gprd != 9
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_troponins_gprd;
CREATE TABLE cal_troponins_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 97137,
      1,
      WHEN
         c.medcode = 97001,
         3, 
         WHEN
            c.medcode IN ( 13806,13803,43984,13800 ),
            4,
            9 ) ) ) AS troponins_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   troponins_gprd != 9
   
UNION

-- entity code 201, data 4 is TQU

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal & negative
      t.data4 IN ( 9, 25, 39, 22, 29, 32 ),
      1,
      WHEN
         -- potentially abnormal
         t.data4 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal & positive
            t.data4 IN ( 12, 26, 44, 45, 21, 30, 31 ),
            3,
            9 ) ) ) AS troponins_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 13806,13803,43984,13800,97001, 97137 )
AND
   t.enttype = 201 

HAVING
   troponins_gprd != 9

UNION

-- entity code 288, lookup 3 is TQU

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal & negative
      t.data3 IN ( 9, 25, 39, 22, 29, 32 ),
      1,
      WHEN
         -- potentially abnormal
         t.data3 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal & positive
            t.data3 IN ( 12, 26, 44, 45, 21, 30, 31 ),
            3,
            9 ) ) ) AS troponins_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 13806,13803,43984,13800,97001, 97137 )
AND
   t.enttype = 288

HAVING
   troponins_gprd != 9
      
ORDER BY
   anonpatid;

--
-- medcode and entity code conflict resolution
--

-- medcode normal, entity code potentially abnormal

UPDATE cal_troponins_gprd SET troponins_gprd = 5
WHERE medcode = 97137 AND troponins_gprd = 2;

-- medcode potentially abnormal, entity code normal

-- nothing here, potentially abnormal medcodes do not exist

-- medcode normal, entity code abnormal

UPDATE cal_troponins_gprd SET troponins_gprd = 6 
WHERE medcode = 97137 AND troponins_gprd = 3; 

-- medcode abnormal, entity code normal

UPDATE cal_troponins_gprd SET troponins_gprd = 6
WHERE medcode = 97001 AND troponins_gprd = 1;

-- medcode potentially abnormal, entity code abnormal

-- nothing here, potentially abnormal medcodes donot exist

-- medcode abnormal and entity type potentially abnormal

UPDATE cal_troponins_gprd SET troponins_gprd = 7
WHERE  medcode = 97001 AND troponins_gprd = 2;
  DROP TABLE IF EXISTS cal_acute_ihd_hes;
CREATE TABLE cal_acute_ihd_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'I240%'
        OR icd LIKE 'I249%'
        OR icd LIKE 'I248%'
        OR icd LIKE 'I24X%' ),
        3, 
        9 ) AS acute_ihd_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    acute_ihd_hes != 9;

UPDATE
    cal_acute_ihd_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_acute_ihd_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_acute_ihd_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_arrest_gprd;
CREATE TABLE cal_arrest_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 30712 ,
      1,
      WHEN
         c.medcode = 22874 ,
         2, 
         WHEN
            c.medcode IN ( 34325,91776,97256,85084 ),
            3,
            WHEN
               c.medcode IN ( 7794,4924 ),
               4,
               WHEN
                  c.medcode IN ( 31077,25583,4374,41916,4827,31286 ),
                  5,
                  WHEN
                     c.medcode IN ( 90685,87226,88756,62141,10160,98214,91673 ),
                     6,
                     WHEN
                        c.medcode IN ( 7630,72435,33899,97560,49882,5925,41717,60367,72785,96801,28236,33402,25407,2099,72762,51140 ),
                        7,
                        9 ) ) ) ) ) ) ) AS arrest_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   arrest_gprd != 9;

DROP TABLE IF EXISTS cal_arrest_hes;
CREATE TABLE cal_arrest_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        icd LIKE 'I472%',
        4,
        WHEN
            ( icd LIKE 'I46X%' OR icd LIKE 'I460%' OR icd LIKE 'I469%' ),
            7,
            WHEN
                icd LIKE 'I470%',
                8,
                9 ) ) ) AS arrest_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    arrest_hes != 9;

UPDATE
    cal_arrest_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_arrest_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_arrest_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_arrest_opcs;
CREATE TABLE cal_arrest_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    WHEN
        opcs IN ( 'K594','K591','K598','K592','K593','K596','K599','K59','K595' ),
        6,
        WHEN
            opcs IN ( 'X509','X504','X508','X50','X501','X502',"X503" ),
            7,
            9 ) ) AS arrest_opcs
FROM
    hes_procedure h
HAVING 
    arrest_opcs != 9;

DROP TABLE IF EXISTS cal_chd_nos_gprd;
CREATE TABLE cal_chd_nos_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   WHEN
      c.medcode = 45476 OR c.enttype = 16,
      1,
      WHEN
         c.medcode IN ( 42659,6331,10963,70160,35277,8516,19298,3468,19067,37991,13250,46565,47798,17681,1490,19164,25814,18150,10662,38379,19185,35373,59687,30171,34329,41032,1537,19744,30027,37990,39500,34488,68979,67087,32666,36193,46664,54007,37908,48981,42669,11798,27484,59193,13187,18218,1811,10910,26044,34207,10127,41179,11038,23098,72925,32526,41677,10109,2155,19250 ),
         2, 
         WHEN
            c.medcode IN ( 27951,28138,1676,9413,47637,52517,20416,39693,24783,15754,18135,35713,95550,21844,1344,10260,29421,240,1792,27977,68401,22383,34633,7320,18889,55137,5413,61072,23078,11648 ),
            3,
            9 ) ) ) AS chd_nos_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   chd_nos_gprd != 9;


-- CREATE INDEX anonpatid ON cal_chd_nos_gprd( anonpatid );DROP TABLE IF EXISTS cal_chd_nos_hes;
CREATE TABLE cal_chd_nos_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'I258%'
        OR icd LIKE 'I253%'
        OR icd LIKE 'I259%'
        OR icd LIKE 'I25X%'
        OR icd LIKE 'I256%'
        OR icd LIKE 'I255%'
        OR icd LIKE 'I251%'
        OR icd LIKE 'I254%'
        OR icd LIKE 'I250%' ),
        3, 
        9 ) AS chd_nos_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    chd_nos_hes != 9;

UPDATE
    cal_chd_nos_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_chd_nos_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_chd_nos_hes DROP COLUMN spno;

DROP TABLE IF EXISTS cal_fam_hist_chd;
CREATE TABLE cal_fam_hist_chd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS fam_hist_chd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 26653,18661,42996,19127,13270,12709,40865,26637,12089,19560,39572,3198,10934,26636,12806,13222,43954,19128,7207,6324,9490,28347,13269,30789,11135,5970,52870,8223,2973 );
DROP TABLE IF EXISTS cal_other_coronary_surgery_opcs;
CREATE TABLE cal_other_coronary_surgery_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    2 AS other_coronary_surgery_opcs
FROM
    hes_procedure h
WHERE
    opcs IN ( 'L972', 'K483' );

DROP TABLE IF EXISTS cal_angina_hes;
CREATE TABLE cal_angina_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd  LIKE 'I209%'
          OR icd LIKE 'I208%'
          OR icd LIKE 'I20X%'
          OR icd LIKE 'I201%' ),
        4, 
        9 ) AS angina_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    angina_hes != 9;

UPDATE
    cal_angina_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_angina_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_angina_hes DROP COLUMN spno;

-- Pool all relevant chapters together

DROP TABLE IF EXISTS tmp_angina_meds_all;
CREATE TEMPORARY TABLE tmp_angina_meds_all AS
SELECT 
	d1.anonpatid,
	d1.eventdate
FROM
	cal_drugs_2_6_1 d1

UNION

SELECT 
    d3.anonpatid,
    d3.eventdate
FROM
    cal_drugs_2_6_3 d3;

-- keep patients with at least prescriptions of medication

DROP TABLE IF EXISTS tmp_angina_meds_at_least_two;
CREATE TEMPORARY TABLE tmp_angina_meds_at_least_two AS
SELECT
    t.anonpatid,
    t.eventdate
FROM 
    tmp_angina_meds_all t
GROUP BY anonpatid
HAVING COUNT(*) >= 2;

-- Create variable

DROP TABLE IF EXISTS cal_angina_meds;
CREATE TABLE cal_angina_meds AS
SELECT
	anonpatid,
	MIN(eventdate) AS eventdate,
	1 AS angina_meds
FROM
	tmp_angina_meds_at_least_two
GROUP BY
	anonpatid;

-- CREATE INDEX anonpatid ON cal_angina_meds( anonpatid );

DROP TABLE IF EXISTS tmp_angina_meds_all;
DROP TABLE IF EXISTS tmp_angina_meds_at_least_two;DROP TABLE IF EXISTS cal_angina_minap;
CREATE TABLE cal_angina_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    1 AS angina_minap
FROM 
    minap
WHERE
    history_angina = 1
AND
    anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;
DROP TABLE IF EXISTS cal_angio_anat_nos;
CREATE TABLE cal_angio_anat_nos AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   4 AS angio_anat_nos
FROM
   clinical c,
   patient p
WHERE
   c.eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 84219,30738,66911,1791,43267 )
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
    WHEN
      -- normal
      t.data4 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data4 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data4 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS angio_anat_nos   
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid

AND
   t.enttype IN ( 251, 302, 298, 288 )
AND
   t.medcode IN ( 84219,30738,66911,1791,43267 )
HAVING
   angio_anat_nos != 9
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_angio_mod_nos;
CREATE TABLE cal_angio_mod_nos AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 35557,
      1,
      WHEN
         c.medcode = 62779,
         2, 
         WHEN
            c.medcode = 35382,
            3,
            WHEN
               c.medcode IN ( 17645,37890,39610,63504,30306,13969,50207,36554,65046 ),
               4,
               9 ) ) ) ) AS angio_mod_nos
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   angio_mod_nos != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS angio_mod_nos
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 17645,37890,39610,63504,30306,13969,50207,36554,65046,35557,62779,35382 )
AND
t.enttype IN ( 251, 302, 298 ) 

HAVING
   angio_mod_nos != 9
      
ORDER BY
   anonpatid;

-- code conflict resolution

-- normal vs potentially abnormal

UPDATE cal_angio_mod_nos SET angio_mod_nos = 5  
WHERE medcode = 35557 AND angio_mod_nos = 2; 

-- potentially abnormal vs normal

UPDATE cal_angio_mod_nos SET angio_mod_nos = 5
WHERE medcode = 62779 AND angio_mod_nos = 1;

-- normal vs abnormal

UPDATE  cal_angio_mod_nos SET angio_mod_nos = 6 
WHERE  medcode = 35557 AND angio_mod_nos = 3;

-- abnormal vs normal
UPDATE  cal_angio_mod_nos SET angio_mod_nos = 6 
WHERE  medcode = 35382 AND angio_mod_nos = 1; 

-- abnormal vs potentially abnormal

UPDATE  cal_angio_mod_nos SET angio_mod_nos = 7 
WHERE medcode = 35382 AND  angio_mod_nos = 2;

-- potentially abnormal vs abnormal

UPDATE cal_angio_mod_nos SET angio_mod_nos = 7
WHERE medcode = 62779 AND angio_mod_nos = 3;
DROP TABLE IF EXISTS cal_angio_result;
CREATE TABLE cal_angio_result AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      -- abnormal single vessel disease
      c.medcode = 3999,
      2,
      WHEN
         -- abnormal double vessel disease
         c.medcode = 5254,
         3, 
         WHEN
            -- abnormal triple vessel disease
            c.medcode = 1655,
            4,
            9 ) ) ) AS angio_result
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   angio_result != 9
ORDER BY
   anonpatid;
   
DROP TABLE IF EXISTS cal_cabg_gprd;
CREATE TABLE cal_cabg_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 5030,5674,18913    ),
      1,
      WHEN
         c.medcode IN ( 22647, 68123, 69776,67761,7134,44561,66236,48767,7137,5744,57241,67591,8679,56990,37682,36011,737,31556,9414,93828,45886,92419,10209,55092,96804,70755,60753,51507,72780,62608,42708,7609,12734,55598,34963,18249,45370,70111,11610,28837,51515,32651,33471,61310,7634,19413,33718,8312,19402,66664,37719,68139,3159,31519,7442,19193,59423 ),
         2, 
         WHEN
            c.medcode IN ( 57634,97953,33461,52938,31540,67554 ),
            3,
            9 ) ) ) AS cabg_gprd   
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   cabg_gprd != 9
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_cabg_hes;
CREATE TABLE cal_cabg_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        icd LIKE 'Z955%',
        1, 
        9 ) AS cabg_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    cabg_hes != 9;

UPDATE
    cal_cabg_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_cabg_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_cabg_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_cabg_minap;
CREATE TABLE cal_cabg_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    1 AS cabg_minap
FROM 
    minap
WHERE
    history_cabg = 1
AND
   anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;DROP TABLE IF EXISTS cal_cabg_opcs;
CREATE TABLE cal_cabg_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    WHEN
        opcs IN ( 'K433','K422','K462','K448','K463','K453','K469','K44','K424','K418','K419','K40','K408','K432','K423','K41','K411','K441','K434','K413','K431','K409','K412','K451','K449','K439','K459','K458','K42','K455','K46','K401','K454','K421','K428','K404','K429','K403','K452','K464','K45','K402','K468','K461','K438','K414','K43' ),
        2,
        WHEN
            opcs IN ( 'K465','K456','K442' ),
            3,
            9 ) ) AS cabg_opcs
FROM
    hes_procedure h
HAVING cabg_opcs != 9 ;
DROP TABLE IF EXISTS cal_cp;
CREATE TABLE cal_cp AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 2584,9714,15528,9698,53806,24704,19199,1270,726,8349,7346,7878,1228,3796,50477,32612,374,14823,29490,21082,8264,20481,10370,12509,544,1865 ),
      1,
      WHEN
         c.medcode = 18134,
         2, 
         WHEN
            c.medcode IN ( 9340,3518,1283,2519,1059,20490,24761,14819,7844,18183 ),
            3,
            WHEN
               c.medcode = 32450,
               4, 
               9 ) ) ) ) AS cp
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   cp != 9
ORDER BY
   anonpatid;
 DROP TABLE IF EXISTS cal_ct_angio;
CREATE TABLE cal_ct_angio AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   4 AS ct_angio
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode = 47139
ORDER BY
   anonpatid;DROP TABLE IF EXISTS cal_eecg_gprd;
CREATE TABLE cal_eecg_gprd AS

-- clinical file, normal categories

SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   WHEN
      c.medcode IN ( 3148,1321,19826 ),
      1,
      WHEN
         c.medcode IN ( 5233,19827,1628 ),
         3, 
         WHEN
            c.medcode IN ( 2656,33519,58910,2850,98231,23143 ),
            4,
            9 ) ) ) AS eecg_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   eecg_gprd != 9
  
UNION 

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   t.enttype,
   WHEN 
        data1 IN ( 9, 25, 39 ),
        1,
        WHEN
            data1 IN ( 13, 27, 38 ),
            2,
            WHEN
                data1 IN ( 12, 26, 44, 45 ),
                3,
                9 ) ) ) AS eecg_gprd
FROM
   test t,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
    t.enttype = 304 
    OR
    ( t.enttype = 217 AND t.medcode IN ( 3148,1321,19826,5233,19827,1628,2656,33519,58910,2850,98231,23143 ) )

HAVING
   eecg_gprd != 9
ORDER BY
    anonpatid;

-- conflict resolution

-- normal medcode, potentially abnormal

UPDATE cal_eecg_gprd SET eecg_gprd = 5
WHERE medcode IN ( 3148,1321,19826  ) 
AND eecg_gprd = 2;

-- normal medcode, abnormal

UPDATE cal_eecg_gprd SET eecg_gprd = 6
WHERE medcode IN ( 3148,1321,19826  ) 
AND eecg_gprd = 3;

UPDATE cal_eecg_gprd SET eecg_gprd = 6
WHERE medcode IN ( 5233,19827,1628 )
AND eecg_gprd = 1;

-- potentially abnormal medcode, abnormal     
     
UPDATE cal_eecg_gprd SET eecg_gprd = 7
WHERE medcode IN ( 5233,19827,1628 )
AND eecg_gprd = 2;
DROP TABLE IF EXISTS cal_inv_angio;
CREATE TABLE cal_inv_angio AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      -- normal
      c.medcode = 1546,
      1,
      WHEN
         -- abnormal
         c.medcode = 1021,
         3, 
         WHEN
            -- results not recorded
            c.medcode IN ( 65396,19681,5897,5459,36196,43446,26206,4991,19465,4538,8423,30892 ),
            4,
            9 ) ) ) AS inv_angio
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   inv_angio != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS inv_angio
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 1021,1546,65396,19681,5897,5459,36196,43446,26206,4991,19465,4538,8423,30892 )
AND
t.enttype IN ( 251, 302, 298 ) 

HAVING
   inv_angio != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data4 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data4 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data4 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS inv_angio
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 1021,1546,65396,19681,5897,5459,36196,43446,26206,4991,19465,4538,8423,30892 )
AND
   t.enttype = 288

HAVING
   inv_angio != 9
   
ORDER BY
   anonpatid;
   
-- code conflict normal - potentially abnormal
   
UPDATE  cal_inv_angio
SET inv_angio = 5  
WHERE  medcode = 1546 -- normal 
AND inv_angio = 2; -- potentially abnormal

-- code conflict normal - abnormal

UPDATE  cal_inv_angio
SET inv_angio = 6 
WHERE medcode = 1546 -- normal
AND inv_angio = 3; --  abnormal

UPDATE cal_inv_angio
SET inv_angio = 6
WHERE medcode = 1021 -- abnormal
AND inv_angio = 1 ; -- normal

-- code conflict abnormal - potentially abnormal

UPDATE cal_inv_angio
SET inv_angio = 7 
WHERE medcode = 1021 -- abnormal
AND inv_angio = 2; -- potentially abnormal
      DROP TABLE IF EXISTS cal_mr_angio;
CREATE TABLE cal_mr_angio AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   4 AS mr_angio
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode = 83534
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_pci_gprd;
CREATE TABLE cal_pci_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 6980,18643 ),
      1,
      WHEN
         c.medcode IN ( 61208,60067,41547,5703,64923,93618,18670,86773,87849,42462,22828,19046,732,733,38813,8942,85947,33735,43939,22020,2901,70185,92927,20903,96537,42304,66921,86071 ),
         2, 
         9 ) ) AS pci_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   pci_gprd != 9
ORDER BY
   anonpatid;
   
DROP TABLE IF EXISTS cal_pci_minap;
CREATE TABLE cal_pci_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    1 AS pci_minap
FROM 
    minap
WHERE
    history_pci = 1
AND
   anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;DROP TABLE IF EXISTS cal_pci_opcs;
CREATE TABLE cal_pci_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    2 AS pci_opcs
FROM
    hes_procedure h
WHERE
    opcs IN ( 'K509','K494','K752','K471','K504','K751','K491','K492','K758','K50','K759','K498','K754','K499','K49','K75','K493','K501','K753','K508' );
DROP TABLE IF EXISTS cal_radio_scan;
CREATE TABLE cal_radio_scan AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      -- normal
      c.medcode = 40638,
      1,
      WHEN
         -- potentially abnormal
         c.medcode = 66179,
         2, 
         WHEN
            -- abnormal
            c.medcode = 58135,
            3,
            WHEN
               -- results not recorded
               c.medcode IN ( 51479,70706,39135,4418,98231,97108,28664,67282,95769,91082,11368,86324 ),
               4,
               9 ) ) ) ) AS radio_scan
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   radio_scan != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS radio_scan
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   t.medcode IN ( 51479,70706,39135,4418,98231,97108,28664,67282,95769,91082,11368,86324,58135,66179,40638 )
AND
   t.enttype IN ( 251, 298 )

HAVING
   radio_scan != 9
      
ORDER BY
   anonpatid;
   
--        
-- conflict resolution code
--

-- normal vs potentially abnormal

UPDATE cal_radio_scan SET radio_scan = 5
WHERE medcode = 40638 AND radio_scan = 2 ;

-- potentially abnormal vs normal

UPDATE cal_radio_scan SET radio_scan = 5
WHERE medcode = 66179 AND radio_scan = 1;

-- normal vs abnormal

UPDATE cal_radio_scan SET radio_scan = 6
WHERE medcode = 40638 AND radio_scan = 3;

-- abnormal vs normal

UPDATE cal_radio_scan SET radio_scan = 6
WHERE medcode = 58135 AND radio_scan = 1;

-- potentially abnormal vs abnormal

UPDATE cal_radio_scan SET radio_scan = 7
WHERE medcode = 66179 AND radio_scan = 3;

-- abnormal vs potentially abnormal

UPDATE cal_radio_scan SET radio_scan = 7
WHERE medcode = 58135 AND radio_scan = 2;


        
DROP TABLE IF EXISTS cal_recg_gprd;
CREATE TABLE cal_recg_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 71925,72758,57034,63538,287,17820,91740,29209,50707,92403,71096,64091,68255,59318,90581,26974,61780,31287,69875 ),
      1,
      WHEN
         c.medcode IN ( 26967,35287,46230,26965,42104,26973,8246 ),
         2, 
         WHEN
            c.medcode = 26966,
            3,
            WHEN
               c.medcode IN ( 55401,52705,26972,26975,59032,62270,46227,39904,7783 ), 
               4,
               WHEN
                  c.medcode IN ( 62063,6319,23142,59889,11794,13857,39379 ),
                  5,
                  WHEN
                     c.medcode IN ( 29371,52663,17597,4924,25723,18357,20953,6771,19707,17550,3757,5285,45098,31286 ),
                     6,
                     WHEN
                        c.medcode IN ( 70947,54366,43669,1292,19060,13854,69876,62269,4690,40118,46229,793,64090,45608,26976,26971,42148,35773,71095,68854,63748,57967,534,46226,40175,68856,52998,26970,93216,48092 ),
                        7,
                        WHEN
                           c.medcode IN ( 23145,54359,27762,93389,66285,55826,46228,93863,34952,66399,433,13856,63628,61953,44500,26964,19779,6518,26844,62271,26968,45097,57904,63725,66038,68855,66666,13855,4648,73384,3682,13853,54161,97932,71097,58180 ),
                           8,
                           9 ) ) ) ) ) ) ) ) AS recg_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   recg_gprd != 9
ORDER BY
   anonpatid;
   
DROP TABLE IF EXISTS cal_stangina_diag;
CREATE TABLE cal_stangina_diag AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   WHEN
      c.medcode IN ( 57062,6336 ),
      1,
      WHEN
         c.medcode IN ( 11048,36854,12986 ),
         2, 
         WHEN
            c.medcode IN ( 8568 ),
            3,
			WHEN
				c.medcode IN ( 7696,54535,13185,28554,15373,18125,14782,15349,29902,19542,26863,39546,24540,9555,12804,1430,45960,1414,20095,25842),
				4,
				WHEN
				    c.enttype = 57 AND data1 = 1,
				    5,
				    9 ) ) ) ) ) AS stangina_diag
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   stangina_diag != 9
ORDER BY
   anonpatid;
DROP TABLE IF EXISTS cal_stangina_referral;
CREATE TABLE cal_stangina_referral AS
SELECT
   r.anonpatid,
   r.eventdate,
   r.medcode,
   WHEN
      r.medcode IN ( 57062,6336 ),
      1,
      WHEN
         r.medcode IN ( 11048,36854,12986 ),
         2, 
         WHEN
            r.medcode = 8568,
            3,
    			WHEN
				   r.medcode IN ( 7696,54535,13185,28554,15373,18125,14782,15349,29902,19542,26863,39546,24540,9555,12804,1430,45960,1414,20095,25842),
				   4,
			      9 ) ) ) ) AS stangina_referral
FROM
   referral r,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   r.anonpatid = p.anonpatid

HAVING
   stangina_referral != 9
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_stress_echo;
CREATE TABLE cal_stress_echo AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   4 AS stress_echo 
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   medcode = 39134 

UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      data1 = 0,
      4,
      WHEN 
         data1 = 25,
         1,
         WHEN
            data1 = 26,
            3,
            WHEN
               data1 = 27,
               2, 
               9 ) ) ) ) AS stress_echo
FROM 
   test t,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid

AND
   t.enttype = 342 
AND
    medcode = 39134    
HAVING
   stress_echo != 9 
ORDER BY
   anonpatid;

DROP TABLE IF EXISTS cal_acs_gprd;
CREATE TABLE cal_acs_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN
   c.medcode = 11983 THEN 3
   ELSE 9
   END acs_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_acs_gprd WHERE acs_gprd = 9;

DROP TABLE IF EXISTS cal_minap_diag;
CREATE TABLE cal_minap_diag AS 
SELECT
    DISTINCT
    id_nhs_number,
    date_admission,
    discharge_diagnosis,
    WHEN
       discharge_diagnosis IN ( 3, 6, 7, 8 ),
       0,
       WHEN
          discharge_diagnosis IN ( 1, 50, 51, 5, 4), 
          1,
          9 ) ) AS minap_diag

FROM 
    minap
WHERE
   id_nhs_number IS NOT NULL;DROP TABLE IF EXISTS cal_minap_ecg;
CREATE TABLE cal_minap_ecg AS 
SELECT
    DISTINCT
    id_nhs_number,
    date_admission,
    ecg_determ_treatment,
    WHEN
        ecg_determ_treatment IN ( 1, 2, 3, 4, 5 ), 
        ecg_determ_treatment,
        WHEN
           ecg_determ_treatment = 6,
           0,
           9 ) ) AS minap_ecg
FROM 
    minap
WHERE
   id_nhs_number IS NOT NULL;DROP TABLE IF EXISTS cal_raised_markers_minap;
CREATE TABLE cal_raised_markers_minap AS 
SELECT
    DISTINCT
    id_nhs_number,
    date_admission,
    cardiac_markers_raised,
    WHEN
        cardiac_markers_raised = 1, 
        1,
        WHEN 
            cardiac_markers_raised = 0,
            0,
            9 ) ) as raised_markers_minap
FROM 
    minap
WHERE
   id_nhs_number IS NOT NULL;

DROP TABLE IF EXISTS cal_uangina_hes;
CREATE TABLE cal_uangina_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    1 AS uangina_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    icd LIKE 'I200%';

UPDATE
    cal_uangina_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_uangina_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_uangina_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_uangina_minap;
CREATE TABLE cal_uangina_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    discharge_diagnosis,
    cardiac_markers_raised,
    0 AS uangina_minap
FROM 
    minap
WHERE
   anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;

-- IF MINAP_diag = 1 AND MINAP_raised_markers = 0 THEN MINAP_UA= 1,
UPDATE cal_uangina_minap SET uangina_minap = 1 WHERE discharge_diagnosis IN ( 1,50,5,10 )
AND cardiac_markers_raised = 0;

-- If cardiac marker result is missing or unknown, label the event as unstable
-- angina if the discharge diagnosis states ACS with unknown or negative troponin
-- ELSE IF discharge_diagnosis = 5 or 10 AND
-- MINAP_raised_markers = 9 MINAP_UA = 1,

UPDATE cal_uangina_minap SET uangina_minap = 1 WHERE discharge_diagnosis IN ( 5,10 ) 
AND ( cardiac_markers_raised = 9 OR cardiac_markers_raised IS NULL );

-- minap diag
-- IF MINAP discharge_diagnosis = 3 (Threatened MI), 6 (chest pain uncertain
-- cause), 7 (MI unconfirmed), 8 (Other diagnosis), then MINAP_diag =
-- 0
-- IF MINAP discharge_diagnosis = 1 (ST elevation MI), 50 (non STEMI),
-- 4 (ACS troponin positive (nSTEMI)), 5 (troponin negative ACS), 10 (ACS
-- troponin unspecified) then MINAP_diag = 1
-- IF MINAP discharge_diagnosis = missing, then MINAP_diag = 9

-- MINAP RAISED MARKERS
-- IF MINAP cardiac_markers_raised = 0, THEN
-- MINAP_raised_markers = 0
-- IF MINAP cardiac_markers_raised = 1, THEN
-- MINAP_raised_markers = 1
-- IF MINAP cardiac_markers_raised = 9 or
-- cardiac_markers_raised = missing, THEN MINAP_raised_markers
-- = 9

ALTER TABLE cal_uangina_minap DROP COLUMN  discharge_diagnosis, 
DROP COLUMN cardiac_markers_raised;

DELETE FROM cal_uangina_minap WHERE uangina_minap = 0;

DROP TABLE IF EXISTS cal_unangina_gprd;
CREATE TABLE cal_unangina_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN c.medcode IN ( 34328,29300,18118 ) THEN 2
   WHEN c.medcode IN ( 54251,4656,66388,19655,1431,7347,17307,36523,39655,39449,9276 ) THEN 3
   ELSE 9 
   END unangina_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_unangina_gprd WHERE unangina_gprd = 9;

   -- Generated: 2013-05-15 10:50:54
   DROP TABLE IF EXISTS cal_endocarditis_gprd;

   CREATE TABLE cal_endocarditis_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 96668,24765,32699,61562,55918,92297,61436,33364,25617,4939,31308,5449,40569,45174,48340,62494,67780,27843,24695,60159,48578,69593,36886,15132,12775,38876,34290,48024,66121,31979,51472,46237,939 );

   -- CREATE INDEX anonpatid ON cal_endocarditis_gprd( anonpatid );

   ALTER TABLE cal_endocarditis_gprd ADD COLUMN endocarditis_gprd INT DEFAULT NULL;

   UPDATE cal_endocarditis_gprd SET endocarditis_gprd = '3' WHERE medcode IN ( 61436,5449,32699,27843,45174,92297,61562,24765,96668,62494,33364,4939,55918,40569,25617,31308,67780,48340 );
UPDATE cal_endocarditis_gprd SET endocarditis_gprd = '4' WHERE medcode IN ( 60159,24695 );
UPDATE cal_endocarditis_gprd SET endocarditis_gprd = '5' WHERE medcode IN ( 69593,48578 );
UPDATE cal_endocarditis_gprd SET endocarditis_gprd = '6' WHERE medcode IN ( 15132,36886,34290,46237,31979,12775,66121,939,38876,48024,51472 );
-- Generated: 2013-05-15 10:51:25
    DROP TABLE IF EXISTS cal_endocarditis_hes;

    CREATE TABLE cal_endocarditis_hes AS
    SELECT
        anonpatid,
        admidate   AS date_admission,
        discharged AS date_discharge,
        spno,
        icd,
        0 AS epi_primary,
        0 AS hosp_primary
    FROM
        hes_diag_hosp h
    WHERE
        (   ( icd LIKE 'I330%' )  OR ( icd LIKE 'B376%' )  OR ( icd LIKE 'I011%' )  OR ( icd LIKE 'I091%' )  OR ( icd LIKE 'I339%' )  OR ( icd LIKE 'I38%' )  );

    -- CREATE INDEX anonpatid ON cal_endocarditis_hes( anonpatid );

    UPDATE
        cal_endocarditis_hes c,
        hes_diag_epi h
    SET
        c.epi_primary = 1 
    WHERE
        c.anonpatid = h.anonpatid
    AND
        c.spno = h.spno
    AND
        c.icd = h.icd
    AND
        h.`primary` = 1;

     UPDATE
         cal_endocarditis_hes c,
         hes_primary_diag_hosp h
     SET
         c.hosp_primary = 1 
     WHERE
         c.anonpatid = h.anonpatid
     AND
         c.spno = h.spno
     AND
         c.icd = h.primary_icd;

     ALTER TABLE cal_endocarditis_hes ADD COLUMN endocarditis_hes INT DEFAULT NULL;

    UPDATE cal_endocarditis_hes SET endocarditis_hes = '3' WHERE (  ( icd LIKE 'I330%' ) );
UPDATE cal_endocarditis_hes SET endocarditis_hes = '4' WHERE (  ( icd LIKE 'B376%' ) );
UPDATE cal_endocarditis_hes SET endocarditis_hes = '6' WHERE (  ( icd LIKE 'I38%' ) OR  ( icd LIKE 'I339%' ) OR  ( icd LIKE 'I011%' ) OR  ( icd LIKE 'I091%' ) );
ALTER TABLE cal_endocarditis_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_echo;
CREATE TABLE cal_echo AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   c.data1,
   WHEN
      c.medcode IN ( 18508,1432,12314 ),
      1,
      WHEN
         c.medcode IN ( 30917 ),
         2, 
         WHEN
            c.medcode IN ( 11284,11351 ),
            3,
            WHEN
                c.medcode IN ( 40366,5245,10317 ),
                4,
                WHEN
                    c.medcode IN ( 26445,90493,23268,85952,94626,89353,1271,3919,27851,26449 ),
                    5,
                    9 ) ) ) ) ) AS echo
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   echo != 9;

UPDATE cal_echo e SET e.echo = 1 WHERE e.echo = 5 AND e.enttype = 342 AND e.data1 = 25;
UPDATE cal_echo e SET e.echo = 1 WHERE e.echo = 4 AND e.enttype = 342 AND e.data1 = 26;
UPDATE cal_echo e SET e.echo = 2 WHERE e.echo = 5 AND e.enttype = 342 AND e.data1 = 27;

ALTER TABLE cal_echo DROP COLUMN enttype, DROP COLUMN data1;

DROP TABLE IF EXISTS cal_hf_gprd;
CREATE TABLE cal_hf_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,
   CASE
   WHEN
   c.medcode IN ( 15058,46912 ) THEN 1
   WHEN (c.medcode IN ( 17851,60710,61229,69062,51214,32945,5155,46672,91288,90193,70619,19002,1585,95835,26242,89650,92305,72341,60721,32911,6434,90192,5293,7321,26082,12366,83481,18793,30214,96484,72965,72386,30749,71235,18853,19066,12627,558,95021,90935,12590,11613,28649,21235,43618,64062,34213,13189 )
        OR
        c.enttype = 96 AND data2 = '1')
   THEN 2 
   WHEN
            c.medcode IN ( 94870 )
   THEN 3
   WHEN
    c.medcode IN ( 67232,57987,50157,21837,62718,72668,52127,95334 )
   THEN 4
   WHEN
      c.medcode IN ( 22262 )
   THEN 5
   WHEN
     c.medcode IN ( 398,32898,12550,10154,5141,27884,10079,8966,5942,5695,1223,19380,68766,20324,9913,30779,24503,2062,23707,884,23481,8464,32671,11424,4024,5255,17278,83502,27964,2906,9524 )
   THEN 6
   WHEN
        c.medcode = 20822
   THEN 7
   ELSE 9
   END hf_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid;

DELETE FROM cal_hf_gprd WHERE hf_gprd = 9;

DROP TABLE IF EXISTS cal_hf_hes;
CREATE TABLE cal_hf_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    CASE
    WHEN
        ( icd LIKE 'I130%'
          OR icd LIKE 'I132%'
          OR icd LIKE 'I110%' )
    THEN 4
    WHEN
            ( icd LIKE 'I260%' )
    THEN 5
    WHEN
                ( icd LIKE 'I509%'
                  OR icd LIKE 'I50%'
                 OR icd LIKE 'I500%'
                  OR icd LIKE 'I501%' )
     THEN 6
     ELSE 9 
     END hf_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_hf_hes WHERE hf_hes = 9;

UPDATE
    cal_hf_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_hf_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;
    
ALTER TABLE cal_hf_hes DROP COLUMN spno;
    
DROP TABLE IF EXISTS cal_hf_minap;
CREATE TABLE cal_hf_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    CASE
    WHEN
       heart_failure = 0
    THEN  1
    WHEN
      heart_failure = 1
    THEN 2
    WHEN
      heart_failure IS NULL OR heart_failure = 9
    THEN 3
    ELSE 9 
    END hf_minap
FROM 
    minap
WHERE
   anonpatid IS NOT NULL
AND
  date_admission IS NOT NULL;

DELETE FROM cal_hf_minap WHERE hf_minap=9;

DROP TABLE IF EXISTS cal_lvrf_minap;
CREATE TABLE cal_lvrf_minap AS 
SELECT
	DISTINCT
	id_nhs_number,
	date_admission,
	leftventricularejectionfraction,
	CASE
	WHEN
		leftventricularejectionfraction = 1 
	THEN
		2
	WHEN
		leftventricularejectionfraction = 2
        THEN
		3
        WHEN
		leftventricularejectionfraction = 3
        THEN     
		4
        WHEN
                leftventricularejectionfraction IS NULL OR leftventricularejectionfraction = 9
        THEN
		5
	ELSE
                9 
        END AS lvrf_minap
FROM 
    minap
WHERE
   id_nhs_number IS NOT NULL;
   
DROP TABLE IF EXISTS cal_bp_cat;
CREATE TABLE cal_bp_cat AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   CASE
   WHEN
	c.medcode IN ( 31744 )
   THEN
	0
   WHEN
        c.medcode IN ( 5341,27274,859,101,6598 )
   THEN      
	1
   WHEN
        c.medcode IN ( 8574,3481 )
   THEN
        2
   WHEN
	c.medcode IN ( 29390,676,27534,5020,55411,43719,351,47932,14643 )
   THEN
	3
   WHEN
	c.medcode IN ( 23312,20049,14640,37242,102,37243,15126,43282,29261,10055,1,41445,27272,100,14452,18418,11726,34244,16288,57,38277,43547,48008,34186,103,8732,34231,27273,66589,16541,42280,41052,5760,37312,94807,14448,1956,803,14642,65990,14641,25553,22476,31305,34618,34187,27271,87862,38278,19905,22595,16478 )
   THEN
        4
   ELSE
        9 
   END BP_cat
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid
ORDER BY 
   anonpatid;

DROP TABLE IF EXISTS cal_bp;
CREATE TABLE cal_bp AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.consid,
   data1::numeric AS dias_bp,
   data2::numeric AS sys_bp,
   0     AS cat
FROM
   clinical c,
   patient p 
WHERE
   p.anonpatid = c.anonpatid

AND
   c.enttype = 1
AND 
   data1::numeric > 20 AND data1::numeric < 200
AND
   data2::numeric > 20 AND data2::numeric < 350
AND
   eventdate IS NOT NULL;

UPDATE cal_bp SET cat = 1 WHERE medcode IN ( 23312,20049,14640,37242,37243,15126,43282,10055,1,27274,859,43719,351,27272,14452,100,6598,18418,5341,34244,16288,57,676,5020,55411,34186,8732,34231,27273,16541,8574,14643,42280,5760,37312,47932,1956,803,14642,65990,14641,25553,29390,34187,27534,27271,22595,19905,101,3481,16478 );
UPDATE cal_bp SET cat = 2 WHERE medcode IN ( 22476,31305,94807,29261 );
UPDATE cal_bp SET cat = 3 WHERE medcode IN ( 41052,102,34618,38277,43547,48008,14448,103,38278,41445 );
UPDATE cal_bp SET cat = 4 WHERE medcode IN ( 51357,33330 );

----- Miqdad got here ---
DROP TABLE IF EXISTS tmp_bp_meds;
CREATE TEMPORARY TABLE tmp_bp_meds AS
SELECT 
    anonpatid,
    eventdate
FROM
    cal_drugs_2_2 c,
    patient p
WHERE
    ( c.bnfcode LIKE '02020100%' 
        OR c.bnfcode LIKE '%/02020100%' 
        OR c.bnfcode LIKE '02020300%'
        OR c.bnfcode LIKE '%/02020300%'
        OR c.bnfcode LIKE '02020400%'
        OR c.bnfcode LIKE '%/02020400%' )

UNION
SELECT 
    anonpatid,
    eventdate
FROM
    cal_drugs_2_4 c
UNION
SELECT 
    anonpatid,
    eventdate
FROM
    cal_drugs_2_5 c
UNION
SELECT 
    anonpatid,
    eventdate
FROM
    cal_drugs_2_6 c
WHERE
    ( c.bnfcode LIKE '02060200%'
    OR c.bnfcode LIKE '%/02060200%' 
);
        
DROP TABLE IF EXISTS tmp_bp_meds_count;
CREATE TEMPORARY TABLE tmp_bp_meds_count AS
SELECT
    anonpatid,
    eventdate
FROM
    tmp_bp_meds
GROUP BY anonpatid
HAVING COUNT(*) >= 2;

DROP TABLE IF EXISTS cal_bp_meds;
CREATE TABLE cal_bp_meds AS
SELECT
    anonpatid,
    MIN(eventdate) AS eventdate,
    1 AS bp_meds
FROM
    tmp_bp_meds_count
GROUP BY
    anonpatid;

ALTER TABLE cal_bp_meds CREATE INDEX(anonpatid);--
-- Find all patients who are hypertensive according fo the CALIBER definition
-- https://www.caliberresearch.org/portal/show/ht_comp

--
-- 1. Abnormal categorical bp measurements

-- Identify patients with at least 2 abnormal BP cat measurements 
-- irrespective of when.

DROP TABLE IF EXISTS tmp_bp_cat_abnormal;

CREATE TEMPORARY TABLE tmp_bp_cat_abnormal AS
    SELECT 
      anonpatid 
    FROM 
      cal_bp_cat 
    WHERE 
      BP_cat = 3 
    GROUP BY 
      anonpatid 
    HAVING 
      COUNT(*) >= 2;

-- CREATE INDEX anonpatid on tmp_bp_cat_abnormal( anonpatid );

-- Pool all abnormal BP cat measurements from the group of patients
-- that have had at least two abnormal readings.
-- The pool will be used for comparing the time between the readings.

DROP TABLE IF EXISTS tmp_bp_cat_pool;

CREATE TEMPORARY TABLE tmp_bp_cat_pool AS
    SELECT 
      c.anonpatid, 
      c.eventdate
    FROM 
      cal_bp_cat c, 
      tmp_bp_cat_abnormal ta 
    WHERE 
      c.anonpatid = ta.anonpatid
    AND 
      c.BP_cat = 3;

-- CREATE INDEX anonpatid ON tmp_bp_cat_pool( anonpatid );

-- Pairwise incremental comparison of dates between abnormal BP readings

DROP TABLE IF EXISTS tmp_bp_cat_pool_compare;

CREATE TEMPORARY TABLE tmp_bp_cat_pool_compare AS
SELECT a.anonpatid,
a.eventdate,
( 
  SELECT b.eventdate 
  FROM tmp_bp_cat_pool b 
  WHERE b.eventdate > a.eventdate 
  AND a.anonpatid = b.anonpatid 
  ORDER BY eventdate ASC 
  LIMIT 1 ) AS next_event_date,
ABS( 
  ROUND( 
    DATEDIFF (
      a.eventdate,
      ( 
        SELECT b.eventdate 
        FROM tmp_bp_cat_pool b 
        WHERE b.eventdate > a.eventdate 
        AND a.anonpatid = b.anonpatid 
        ORDER BY eventdate ASC LIMIT 1 )
    ) / 365, 5
  )
) AS days_diff
FROM tmp_bp_cat_pool a
HAVING ( next_event_date IS NOT NULL AND days_diff <= 1 )
ORDER BY a.anonpatid, a.eventdate;

-- Keep earliest date of abnormal categorical BP measurements

DROP TABLE IF EXISTS tmp_bp_cat_first_abnormal;
CREATE TEMPORARY TABLE tmp_bp_cat_first_abnormal AS
SELECT
  t.anonpatid,
  MIN(t.eventdate) AS eventdate
FROM
  tmp_bp_cat_pool_compare t
GROUP BY 
  t.anonpatid;

------------------------------------------------------------------------------------

--
-- 2. Abnormal continuous bp measurement

-- Identify patients with at least two abnormal BP measurements 
-- irrespective of when.

DROP TABLE IF EXISTS tmp_bp_abnormal;

CREATE TEMPORARY TABLE tmp_bp_abnormal AS
  SELECT 
    anonpatid
  FROM 
    cal_bp c
  WHERE 
    ( c.sys_bp >= 140 OR c.dias_bp >= 90 )
  GROUP BY 
    c.anonpatid
  HAVING 
    COUNT(*) >= 2;

-- Pool all abnormal BP measurements from the group of patients

DROP TABLE IF EXISTS tmp_bp_abnormal_pool;

CREATE TABLE tmp_bp_abnormal_pool AS
  SELECT 
    c.anonpatid, 
    c.eventdate
  FROM 
    cal_bp c, 
    tmp_bp_abnormal ta 
  WHERE 
    c.anonpatid = ta.anonpatid
  AND 
  ( c.sys_bp >= 140 OR c.dias_bp >= 90 );

-- CREATE INDEX anonpatid ON tmp_bp_abnormal_pool( anonpatid );

-- Pairwise incremental comparison of dates between abnormal BP readings

DROP TABLE IF EXISTS tmp_bp_pool_compare;

CREATE TEMPORARY TABLE tmp_bp_pool_compare AS
SELECT a.anonpatid,
a.eventdate,
( 
  SELECT 
    b.eventdate 
  FROM 
    tmp_bp_abnormal_pool b 
  WHERE 
    b.eventdate > a.eventdate 
  AND 
    a.anonpatid = b.anonpatid 
  ORDER BY 
    eventdate ASC 
  LIMIT 1 ) AS next_event_date,
ABS( 
  ROUND( 
    DATEDIFF (
      a.eventdate,
      ( 
        SELECT 
          b.eventdate 
        FROM 
          tmp_bp_abnormal_pool b 
        WHERE 
          b.eventdate > a.eventdate 
        AND 
          a.anonpatid = b.anonpatid 
        ORDER BY 
          eventdate ASC LIMIT 1 )
    ) / 365, 5
  )
) AS days_diff
FROM 
  tmp_bp_abnormal_pool a
HAVING ( next_event_date IS NOT NULL AND days_diff <= 1 )
ORDER BY 
  a.anonpatid, a.eventdate;

-- CREATE INDEX anonpatid ON tmp_bp_abnormal( anonpatid );

-- Keep earliest date of abnormal BP measurements

DROP TABLE IF EXISTS tmp_bp_first_abnormal;
CREATE TEMPORARY TABLE tmp_bp_first_abnormal AS
SELECT
  t.anonpatid,
  MIN(t.eventdate) AS eventdate
FROM
  tmp_bp_pool_compare t
GROUP BY t.anonpatid;

-- CREATE INDEX anonpatid on tmp_bp_first_abnormal( anonpatid );

--
-- 3. HT diagnosis

DROP TABLE IF EXISTS tmp_ht_diag;
CREATE TEMPORARY TABLE tmp_ht_diag AS
SELECT
  t.anonpatid,
  MIN(t.eventdate) AS eventdate
FROM
  cal_ht t  
WHERE
  t.ht = 3
GROUP BY t.anonpatid;

-- CREATE INDEX anonpatid ON tmp_ht_diag( anonpatid );

--
-- 4. Prescription of anti-hypertensive medication

-- Pool all relevant chapters into a single file

DROP TABLE IF EXISTS tmp_ht_drugs;
CREATE TEMPORARY TABLE tmp_ht_drugs AS
SELECT
  c.anonpatid,
  c.eventdate
FROM
  cal_drugs_2_2_1 c

UNION

SELECT
  c.anonpatid,
  c.eventdate
FROM
  cal_drugs_2_2_3 c

UNION 

SELECT
  c.anonpatid,
  c.eventdate
FROM
  cal_drugs_2_2_4 c
  
UNION

SELECT 
  c.anonpatid,
  c.eventdate
FROM
  cal_drugs_2_4 c

UNION

SELECT 
  c.anonpatid,
  c.eventdate
FROM
  cal_drugs_2_5 c
  
UNION

SELECT 
  c.anonpatid,
  c.eventdate
FROM
  cal_drugs_2_6_2 c;

-- CREATE INDEX anonpatid ON tmp_ht_drugs(anonpatid);
-- CREATE INDEX anonpatid_ev ON tmp_ht_drugs(anonpatid,eventdate);

-- Drop all patients that have had less than 2 prescriptions
-- irrespective of when they occurred.

DROP TABLE IF EXISTS tmp_ht_drugs_count;
CREATE TEMPORARY TABLE tmp_ht_drugs_count AS
SELECT
  c.anonpatid,
  COUNT(*) AS num_prescriptions
FROM
  tmp_ht_drugs c
GROUP BY c.anonpatid;
 
-- CREATE INDEX anonpatid ON tmp_ht_drugs_count( anonpatid );

DELETE FROM tmp_ht_drugs WHERE anonpatid NOT IN ( 
  SELECT anonpatid FROM tmp_ht_drugs_count WHERE num_prescriptions >= 2 
);

-- Pairwise incremental comparison of dates between prescriptions

DROP TABLE IF EXISTS tmp_ht_drugs_pool_compare;

CREATE TEMPORARY TABLE tmp_ht_drugs_pool_compare AS
SELECT a.anonpatid,
a.eventdate,
( 
  SELECT b.eventdate 
  FROM tmp_ht_drugs b 
  WHERE b.eventdate > a.eventdate 
  AND a.anonpatid = b.anonpatid 
  ORDER BY eventdate ASC 
  LIMIT 1 ) AS next_event_date,
ABS( 
  ROUND( 
    DATEDIFF (
      a.eventdate,
      ( 
        SELECT b.eventdate 
        FROM tmp_ht_drugs b 
        WHERE b.eventdate > a.eventdate 
        AND a.anonpatid = b.anonpatid 
        ORDER BY eventdate ASC LIMIT 1 )
    ) / 365, 5
  )
) AS days_diff
FROM tmp_ht_drugs a
HAVING ( next_event_date IS NOT NULL AND days_diff <= 1 )
ORDER BY a.anonpatid, a.eventdate;

-- CREATE INDEX anonpatid ON tmp_ht_drugs( anonpatid );

-- Keep date of earliest prescription 

DROP TABLE IF EXISTS tmp_ht_drugs_first;
CREATE TEMPORARY TABLE tmp_ht_drugs_first AS
SELECT
  t.anonpatid,
  MIN(t.eventdate) AS eventdate
FROM
  tmp_ht_drugs_pool_compare t
GROUP BY t.anonpatid;

-- CREATE INDEX anonpatid on tmp_ht_drugs_pool_compare( anonpatid );

--
-- 5. Pool all dates together for each patient and keep the earliest
-- date

DROP TABLE IF EXISTS cal_ht_composite;
CREATE TABLE cal_ht_composite AS
SELECT 
  c.anonpatid,
  c.eventdate,
  'diagnosis' AS type 
FROM
  tmp_ht_diag c

UNION

SELECT 
  c.anonpatid,
  c.eventdate,
  'abnormal_bp' AS type
FROM
  tmp_bp_first_abnormal c

UNION

SELECT 
  c.anonpatid,
  c.eventdate,
  'ht_drugs' AS type
FROM
  tmp_ht_drugs_first c

UNION

SELECT 
  c.anonpatid,
  c.eventdate,
  'abnormal_bp_cat' AS type
FROM
  tmp_bp_cat_first_abnormal c;

-- CREATE INDEX anonpatid ON cal_ht_composite( anonpatid );
DROP TABLE IF EXISTS cal_ht;
CREATE TABLE cal_ht AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.enttype,   
  CASE 
  WHEN
      c.medcode IN (  66645,2666,19342,3269 )
  THEN
      1
  WHEN
         c.medcode IN ( 10632,34281,12680,13186,4344,34192,36305,22356,41634,24127,28874,10961,27525,27634,45149,30776,31175,12948,43220,31117,4444,31127,34108,5215,28828,10976 )
  THEN         
	2
  WHEN
            c.medcode IN ( 39649,43935,18590,15106,85944,66567,61660,52427,6702,61166,69753,72030,60655,21837,50157,29310,4668,10818,22333,21826,31816,62718,21660,1894,62432,95359,73586,83473,63000,16292,95334,28684,43664,72668,67232,13188,96743,16565,57987,204,27511,37086,68659,3979,8296,7057,8732,3425,32423,19070,15377,18765,63164,8857,31464,799,18057,52621,18482,44350,16173,93055,20497,4372,44549,30770,63466,52127,3712,11056 )
            OR
            c.enttype = 15
  THEN
      3
  WHEN
           c.medcode IN ( 51635,31387,31341,59383,34744,16059,57288,31755,73293,32976,7329,42229,25371,97533 )
  THEN
      4
  ELSE
      9 
  END ht
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid
ORDER BY 
   anonpatid;

DELETE FROM cal_ht WHERE ht = 9;
   
DROP TABLE IF EXISTS cal_ht_hes;
CREATE TABLE cal_ht_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
CASE
    WHEN
        ( icd LIKE 'I129%'
        OR icd LIKE 'I11%'
        OR icd LIKE 'I120%'
        OR icd LIKE 'I12%'
        OR icd LIKE 'I132%'
        OR icd LIKE 'I110%'
        OR icd LIKE 'I119%'
        OR icd LIKE 'I131%'
        OR icd LIKE 'I130%'
        OR icd LIKE 'I10X%'
        OR icd LIKE 'I13%'
        OR icd LIKE 'I139%' ) 
     THEN
	3
     WHEN
            ( icd LIKE  'I152%'
            OR icd LIKE 'I15%'
            OR icd LIKE 'I159%'
            OR icd LIKE 'I158%'
            OR icd LIKE 'I151%'
            OR icd LIKE 'I150%' )
      THEN
            4
       ELSE
            9 
       END ht_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h;

DELETE FROM cal_ht_hes WHERE ht_hes = 9;

UPDATE
    cal_ht_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_ht_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_ht_hes DROP COLUMN spno;


DROP TABLE IF EXISTS cal_ht_opcs;
CREATE TABLE cal_ht_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    3 AS ht_opcs
FROM
    hes_procedure h
WHERE
    opcs IN ( 'X828','X829' );
    
DROP TABLE IF EXISTS cal_pulse_ldp_gprd;
CREATE TABLE cal_pulse_ldp_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.data1,
   CASE
   WHEN
      c.data1 IN (1,4) AND c.medcode NOT IN ( 13335, 13339, 13343 )
   THEN
      1
   WHEN
        c.data1 = 2 AND c.medcode NOT IN ( 13337, 13345, 13342, 13347 )
   THEN
         2
   WHEN
            c.data1 = 3 AND c.medcode NOT IN ( 13345 )
   THEN
         3
   WHEN
                c.data1 IN (0,5) AND c.medcode IN ( 13337, 13345, 13342, 13347 )
   THEN
        1
   WHEN
                    c.data1 IN (0,5) AND c.medcode IN ( 13335, 13339, 13343 )
   THEN
        2
   ELSE
                    9
    END pulse_ldp_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
    c.adid > 0
AND
    c.enttype = 118
AND
    c.data1 IS NOT NULL
HAVING
   pulse_ldp_gprd != 9;

DROP TABLE IF EXISTS cal_pulse_lpt_gprd;
CREATE TABLE cal_pulse_lpt_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.data2,
   WHEN
      c.data2 IN (1,4) AND c.medcode NOT IN ( 13335, 13340, 13341 ),
      1,
      WHEN
         c.data2 = 2 AND c.medcode NOT IN ( 13337, 13346, 13342, 19597 ),
         2, 
         WHEN
            c.data2 = 3 AND c.medcode NOT IN ( 13346 ),
            3,
            WHEN
                c.data2 IN (0,5) AND c.medcode IN ( 13337, 13346, 13342, 19597 ),
                1,
                WHEN
                    c.data2 IN (0,5) AND c.medcode IN ( 13335, 13340, 13341),
                    2,
                    9 ) ) ) ) ) AS pulse_lpt_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
    c.enttype = 118
AND
    c.adid > 0
AND
    c.data2 IS NOT NULL
HAVING
   pulse_lpt_gprd != 9;DROP TABLE IF EXISTS cal_pulse_pressure_gprd;
CREATE TABLE cal_pulse_pressure_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   ( sys_bp - dias_bp ) AS pulse_pressure
FROM
   cal_bp c
WHERE
   ( sys_bp - dias_bp ) > 0;

-- CREATE INDEX anonpatid OM cal_pulse_pressure_gprd( anonpatid );DROP TABLE IF EXISTS cal_pulse_rdp_gprd;
CREATE TABLE cal_pulse_rdp_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.data1,
   WHEN
      c.data1 IN (1,4) AND c.medcode NOT IN ( 13321, 13324, 13327 ),
      1,
      WHEN
         c.data2 = 2 AND c.medcode NOT IN ( 13323, 13331, 13329, 19594 ),
         2, 
         WHEN
            c.data1 = 3 AND c.medcode NOT IN ( 13331 ),
            3,
            WHEN
                c.data1 IN (0,5) AND c.medcode IN ( 13323, 13331, 13329, 19594 ),
                1,
                WHEN
                    c.data1 IN (0,5) AND c.medcode IN ( 13321, 13324, 13327), 
                    2,
                    9 ) ) ) ) ) AS pulse_rdp_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   enttype = 117
AND
    c.adid > 0
AND
    data1 IS NOT NULL
HAVING
   pulse_rdp_gprd != 9;DROP TABLE IF EXISTS cal_pulse_rpt_gprd;
CREATE TABLE cal_pulse_rpt_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   c.data2,
   WHEN
      c.data2 IN (1,4) AND c.medcode NOT IN ( 13321, 13326, 13325 ),
      1,
      WHEN
         c.data2 = 2 AND c.medcode NOT IN ( 13323, 13332, 13329, 19593 ),
         2, 
         WHEN
            c.data2 = 3 AND c.medcode NOT IN ( 13332 ),
            3,
            WHEN
                c.data2 IN (0,5) AND c.medcode IN ( 13323, 13332, 13329, 19593),
                1,
                WHEN
                    c.data2 IN (0,5) AND c.medcode IN ( 13321, 13326, 13325),
                    2,
                    9 ) ) ) ) ) AS pulse_rpt_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
    c.adid > 0
AND
    c.enttype = 117
AND
    c.data2 IS NOT NULL
HAVING
    pulse_rpt_gprd != 9;
DROP TABLE IF EXISTS cal_athero_nec_gprd;
CREATE TABLE cal_athero_nec_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 27741,41762,10444 ),
      1,
      WHEN
         c.medcode IN ( 15161,93400,22672,51510,48981,35501,12786,13259,60229,30778,46949,94203,62834,64876,19185,15736,48980,12302,30777,15592 ),
         2, 
         WHEN
            c.medcode IN ( 36609,41229,5640,56621,996,34455,5168,3995 ),
            3,
            9 ) ) ) AS athero_nec_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   athero_nec_gprd != 9;

DROP TABLE IF EXISTS cal_athero_nec_hes;
CREATE TABLE cal_athero_nec_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'I708%'
          OR icd LIKE 'I701%'
          OR icd LIKE 'I70X%'
          OR icd LIKE 'I709%'
          OR icd LIKE 'I700%'
          OR icd LIKE 'I702%' ),
        3, 
        9 ) AS athero_nec_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    athero_nec_hes != 9;

UPDATE
    cal_athero_nec_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_athero_nec_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_athero_nec_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_erfc_cvd_diag_hes;
CREATE TABLE cal_erfc_cvd_diag_hes AS
SELECT
    anonpatid,
    admidate     AS date_admission,
    discharged   AS date_discharge,
    primary_icd  AS icd,
    1            AS erfc_cvd_diag_hes
FROM
    hes_primary_diag_hosp h
WHERE (
       h.primary_icd LIKE 'G45%'
    OR h.primary_icd LIKE 'I01%'
    OR h.primary_icd LIKE 'I03%'
    OR h.primary_icd LIKE 'I04%'
    OR h.primary_icd LIKE 'I05%'
    OR h.primary_icd LIKE 'I06%'
    OR h.primary_icd LIKE 'I07%'
    OR h.primary_icd LIKE 'I08%'
    OR h.primary_icd LIKE 'I09%'
    OR h.primary_icd LIKE 'I1%'
    OR h.primary_icd LIKE 'I2%'
    OR h.primary_icd LIKE 'I3%'
    OR h.primary_icd LIKE 'I4%'
    OR h.primary_icd LIKE 'I5%'
    OR h.primary_icd LIKE 'I6%'
    OR h.primary_icd LIKE 'I7%'
    OR h.primary_icd LIKE 'I80%'
    OR h.primary_icd LIKE 'I81%'
    OR h.primary_icd LIKE 'I82%'
    OR h.primary_icd LIKE 'I87%'
    OR h.primary_icd LIKE 'I9%'
    OR h.primary_icd LIKE 'Q2%'
    OR h.primary_icd LIKE 'R96%' );

-- CREATE INDEX anonpatid ON cal_erfc_cvd_diag_hes( anonpatid );DROP TABLE IF EXISTS cal_fam_hist_hes;
CREATE TABLE cal_fam_hist_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'Z823%' OR icd LIKE 'Z824%' ),
        1, 
        9 ) AS fam_hist_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    fam_hist_hes != 9;

UPDATE
    cal_fam_hist_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_fam_hist_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_fam_hist_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_fam_hist;
CREATE TABLE cal_fam_hist AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   1 AS fam_hist
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

AND
   c.medcode IN ( 6323,18661,42996,29064,13270,12709,12089,10934,26636,95184,13222,43954,7207,18714,6324,9490,26639,13269,5970,2973,96212,26653,19127,8258,7765,13253,40865,19561,30256,26637,19560,39572,96596,3198,12806,18997,19128,13258,28347,30789,11135,52870,8223 );

DROP TABLE IF EXISTS cal_aaa_angio_gprd;
CREATE TABLE cal_aaa_angio_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 57297 ),
      1,
      WHEN
         c.medcode IN ( 55870 ),
         3, 
         WHEN
            c.medcode IN ( 18888,40028,60661,23805 ),
            4,
            9 ) ) ) AS aaa_angio_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   aaa_angio_gprd != 9
      
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS aaa_angio_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND (
      ( t.medcode IN ( 18888,40028,60661,23805,55870,57297  )  AND t.enttype = 251 ) 
      OR
      t.enttype = 457 
   )

HAVING
   aaa_angio_gprd != 9
   
ORDER BY
   anonpatid;
   
-- conflict resolution
   
-- normal medcode but potentially abnormal entity type

-- UPDATE cal_aaa_angio_gprd
-- SET aaa_angio_gprd = 5
-- WHERE medcode = 57297
-- AND aaa_angio_gprd = 2;
-- 
-- normal medcode but abnormal entity type
-- 
-- UPDATE cal_aaa_angio_gprd
-- SET aaa_angio_gprd = 6
-- WHERE medcode = 55870
-- AND aaa_angio_gprd = 3;
-- 
-- abnormal medcode but potentially abnormal entity type
-- 
-- UPDATE cal_aaa_angio_gprd
-- SET aaa_angio_gprd = 7
-- WHERE medcode = 55870
-- AND aaa_angio_gprd = 2;

-- cat 1 57297
-- cat 3 55870
-- cat 4 18888,40028,60661,23805
DROP TABLE IF EXISTS cal_aaa_gprd;
CREATE TABLE cal_aaa_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 16993,
      1,
      WHEN
         c.medcode IN ( 17345,9759,6872,11430,1735,45521,16034,1867,40787,13572,15304,63920,17767 ),
         3, 
         9 ) ) AS aaa_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   aaa_gprd != 9
ORDER BY
   anonpatid;


DROP TABLE IF EXISTS cal_aaa_hes;
CREATE TABLE cal_aaa_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        (    icd LIKE 'I713%'
          OR icd LIKE 'I714%'
          OR icd LIKE 'I718%'
          OR icd LIke 'I719%' ),
        3, 
        9 ) AS aaa_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    aaa_hes != 9;

UPDATE
    cal_aaa_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_aaa_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_aaa_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_aaa_ops_gprd;
CREATE TABLE cal_aaa_ops_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 66914,53891,36928,53163,50122,98211,25735,98082,57141,67839,87370,55319,37639,35023,86810,95721,49878,36008,17328,43179,42751,39962,30466,89198,86053,66316,96912,61978,48768,30296,97596,59518,65813,42142,24371,57539,5597,20078,52497,89731 ),
      2,
      WHEN
         c.medcode IN ( 95976,52358,62301,36651,26232,56510,54379,54192,63408,96654,92925,17220,94331,66761,51166,33430,94682,69922,66232,98565,90549,55445,45477,31822,56495,44553,90861,31613,19996,97030,1736,45474,97109,94069,43108,70446,38546,93627,83577,97217,98175,93959 ),
         3, 
         9 ) ) AS aaa_ops_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   aaa_ops_gprd != 9;
DROP TABLE IF EXISTS cal_aaa_procs_opcs;
CREATE TABLE cal_aaa_procs_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    WHEN
        opcs IN ( 'L235','L222','L224','L223' ),
        1,
        WHEN
            opcs IN ( 'L218','L259','L251','L168','L231','L232','L261','L267','L23','L263','L215','L219','L214','L233','L289','L16','L236','L21','L213','L266','L288','L268','L209','L169','L262','L252','L258','L269','L208','L265','L26','L25' ),
            2,
            WHEN
                opcs IN ( 'L254','L205','L279','L271','L188','L196','L206','L19','L194','L285','L276','L27','L198','L184','L272','L189','L282','L275','L18','L199','L286','L28','L185','L204','L193','L195','L203','L278','L281','L20' ),
                3,
                9 ) ) ) AS aaa_procs_opcs
FROM
    hes_procedure h
HAVING aaa_procs_opcs != 9 ;

DROP TABLE IF EXISTS cal_aaa_us_gprd;
CREATE TABLE cal_aaa_us_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 81450,16870 ),
      4,
      9 ) AS aaa_us_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   aaa_us_gprd != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS aaa_us_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   ( 
      ( t.medcode IN ( 81450,16870 ) AND t.enttype IN ( 339, 251 ) )
   OR
      t.enttype = 237 
   )

HAVING
   aaa_us_gprd != 9

ORDER BY
   anonpatid;

-- conflict resolution not required as medcodes are neutral
-- cat 4 81450,16870
DROP TABLE IF EXISTS cal_arterial_gprd;
CREATE TABLE cal_arterial_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 59534,16993 ),
      1,
      WHEN
         c.medcode IN ( 18499,7975,43001,98556 ),
         2, 
         WHEN
            c.medcode IN ( 5640,996,37199,16284,8511,56621,1318,5168,12888,3995 ),
            3,
            WHEN
                c.medcode IN ( 17345,9759,6872,11430,1735,45521,16034,1867,40787,13572,15304,63920,17767 ),
                4,
                WHEN
                    c.medcode IN ( 16521 ),
                    5,
                    WHEN
                        c.medcode IN ( 16366,23532,59492,52549,41171,18478,60879,45000,17560,59536,31876,69847,16800,67026,36390,95381,25438,6684,63059,30248,58794,35529,27563,12634,33613,72062,50678,31055,59671,16395,94408 ),
                        6,
                        WHEN
                            c.medcode IN ( 3715,34638,64446,67401,5414,68698,24327,73961,38907,69124,11624,9204,12735,6853,8801,3530,60699,30484,6308,23497,54899,70448,2760,10500,1517,65025,25954,1826,34152,19155,23871,14796,15302,72632,5702,16260,98174,5943,93468,37806,56803,31053,35399,6827,53634,9561,4317,15272,5650,63357,22834,14797,54212,4325 ),
                            7,
                            WHEN
                                c.medcode IN ( 27494,56919,32634,69232,71860,4539,44835,2065,54865 ),
                                8,
                                WHEN
                                    c.medcode IN ( 1002,39097,1231,5595 ),
                                    9,
                                    0 ) ) ) ) ) ) ) ) ) AS arterial_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   arterial_gprd != 0;
DROP TABLE IF EXISTS cal_arterial_hes;
CREATE TABLE cal_arterial_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        icd LIKE 'I70X%'
        OR icd LIKE 'I7020%'
        OR icd LIKE 'I702%'
        OR icd LIKE 'I7010%'
        OR icd LIKE 'I7080%'
        OR icd LIKE 'I709%'
        OR icd LIKE 'I701%'
        OR icd LIKE 'I708%'
        OR icd LIKE 'I7081%'
        OR icd LIKE 'I7011%'
        OR icd LIKE 'I7021%'
        OR icd LIKE 'I7001%'
        OR icd LIKE 'I700%'
        OR icd LIKE 'I7091%'
        OR icd LIKE 'I7000%'
        OR icd LIKE 'I7090%',
        3,
        WHEN
            icd lIKE 'I719%'
            OR icd LIKE 'I714%'
            OR icd LIKE 'I718%'
            OR icd LIKE 'I716%'
            OR icd LIKE 'I715%'
            OR icd LIKE 'I713%',
            4,
            WHEN
                ( icd LIKE 'I710%' OR icd LIKE 'I71X%' ),
                5,
                WHEN
                    icd LIKE 'I725%'
                    OR icd LIKE 'I721%'
                    OR icd LIKE 'I720%'
                    OR icd LIKE 'I712%'
                    OR icd LIKE 'I72X%'
                    OR icd LIKE 'I724%'
                    OR icd LIKE 'I728%'
                    OR icd LIKE 'I723%'
                    OR icd LIKE 'I729%'
                    OR icd LIKE 'I711%'
                    OR icd LIKE 'I722%',
                    6,
                    WHEN
                        icd LIKE 'I739%'
                        OR icd LIKE 'I73X%'
                        OR icd LIKE 'I738%'
                        OR icd LIKE 'I731%',
                        7,
                        WHEN
                            icd LIKE 'I744%'
                            OR icd LIKE 'I745%'
                            OR icd LIKE 'I743%',
                            8,
                            WHEN
                                icd LIKE 'I730%',
                                9,
                                0 ) ) ) ) ) ) ) AS arterial_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    arterial_hes != 0;

UPDATE
    cal_arterial_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_arterial_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_arterial_hes DROP COLUMN spno;
DROP TABLE IF EXISTS cal_pad_angio_gprd;
CREATE TABLE cal_pad_angio_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 63214,58102 ),
      1,
      WHEN
         c.medcode IN ( 41825,19825 ),
         3, 
         WHEN
            c.medcode IN ( 14223,49943,39443,37577,41844,9200,70635,11049,50390,24723,47179,13989 ),
            4,
            9 ) ) ) AS pad_angio_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   pad_angio_gprd != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS pad_angio_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND (
      ( t.medcode IN ( 14223,49943,39443,37577,41844,9200,70635,11049,50390,24723,47179,13989,41825,19825,63214,58102) 
      AND t.enttype = 251 )
      OR
   t.enttype = 303 
   )

HAVING
   pad_angio_gprd != 9
   
ORDER BY
   anonpatid;

-- conflict resolution

-- normal medcode but potentially abnormal entity type
-- 
-- UPDATE cal_pad_angio_gprd
-- SET pad_angio_gprd = 5
-- WHERE medcode IN ( 63214,58102 )
-- AND pad_angio_gprd = 2;
-- 
-- normal medcode but abnormal entity type
-- 
-- UPDATE cal_pad_angio_gprd
-- SET pad_angio_gprd = 6
-- WHERE medcode IN ( 63214,58102 )
-- AND pad_angio_gprd = 3;
-- 
-- abnormal medcode but potentially abnormal entity type
-- 
-- UPDATE cal_pad_angio_gprd
-- SET pad_angio_gprd = 7
-- WHERE medcode IN ( 41825,19825 )
-- AND pad_angio_gprd = 2;
--    DROP TABLE IF EXISTS cal_pad_gprd;
CREATE TABLE cal_pad_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode = 59534,
      1,
      WHEN
         c.medcode IN ( 48597,42611,3715,25954,4970,51204,14796,34638,37750,51634,72632,67401,11680,18499,5414,68698,9204,12735,7975,40068,4317,15272,43001,27349,22834,30484,23497,10500 ),
         2, 
         WHEN
            c.medcode IN ( 62107,64446,46150,24327,73961,38907,69124,60499,6853,3530,60699,32403,6308,54899,70448,2760,1517,65025,1826,34152,23871,32556,15302,5702,16260,98174,5943,93468,56803,37806,31053,35399,6827,12736,53634,9561,63357,33807,54212,69993,14797,40401,1318,4325 ),
            3,
            9 ) ) ) AS pad_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   pad_gprd != 9
ORDER BY
   anonpatid;
   
DROP TABLE IF EXISTS cal_pad_hes;
CREATE TABLE cal_pad_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    WHEN
        ( icd LIKE 'I73X%'
          OR icd LIKE 'I739%'
          OR icd LIKE 'I738%'
          OR icd LIKE 'I731%' ),
        3, 
        9 ) AS pad_hes,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
HAVING
    pad_hes != 9;

UPDATE
    cal_pad_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

UPDATE
    cal_pad_hes c,
    hes_primary_diag_hosp h
SET
    c.hosp_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.primary_icd;

ALTER TABLE cal_pad_hes DROP COLUMN spno;


DROP TABLE IF EXISTS cal_pad_ops_gprd;
CREATE TABLE cal_pad_ops_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 28651,48846,46168,44097,55324,52473,47538,57822,59187,16991,41583,63711,51720,17347,46465,52462 ),
      2,
      WHEN
         c.medcode IN ( 18816,38921,28166,6256,42645,15532,47562,60693,55554,48755,66930,64555,36952,28616,54071,41823,97606,32492,44430,73822,62775,81445,67982,64798,9119,16363,40397,28777,69519,2761,47835,42640,62866,10827,53580,6617,65669,24692,39039,28119,63238,60212,63396,39877,37787,43648,50894,11766,62818,28030,55402,48700,72448,40732,59602,41768,72491,49273,12331,39776,61256,53675,49319,6356,24677,24229,44250,65286,2066,70922,27580,18030,65692,14895,63368,40302,48939,29112,36136,36443,42465,31338,52695,52869,52357,23352,67083,68412,36065,66917,55877,20657,51211,66879,39437,71041,60465,42115,61974,63280,33555,43651,57793,30989,22016,63605,18060,66869,28125,20892,28894,45428,96809,21927,66820,52342,9099,95573,3778,67818,66437,55825,40619,17336,68320,66804,68141,96255,7111,52289,18038,61255,51331,24097,34037,34153 ),
         3, 
         9 ) ) AS pad_ops_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   pad_ops_gprd != 9;
DROP TABLE IF EXISTS cal_pad_procs_opcs;
CREATE TABLE cal_pad_procs_opcs AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    evdate     AS date_procedure,
    discharged AS date_discharge, 
    opcs,
    WHEN
        opcs IN ( 'L639','L538','L63','L54','L638','L539' ),
        2,
        WHEN
            opcs IN ( 'L531','L511','L601','L542','L503','L653','L651','L635','L632','L51','L599','L541','L589','L584','L622','L591','L595','L509','L609','L528','L515','L544','L592','L506','L519','L604','L549','L518','L596','L502','L50','L594','L631','L586','L59','L504','L593','L516','L587','L53','L597','L532','L513','L629','L602','L65','L58','L52','L603','L621','L62','L633','L501','L505','L652','L60','L522','L582','L514','L628','L581','L585','L508','L512','L608','L598','L588','L529','L521','L548','L583' ),
            3,
            9 ) ) AS pad_procs_opcs
FROM
    hes_procedure h
HAVING pad_procs_opcs != 9 ;

DROP TABLE IF EXISTS cal_pad_us_gprd;
CREATE TABLE cal_pad_us_gprd AS
SELECT
   c.anonpatid,
   c.eventdate,
   c.medcode,
   WHEN
      c.medcode IN ( 44008,44007,88894,42676,12822,42675 ),
      4,
      9 ) AS pad_us_gprd
FROM
   clinical c,
   patient p
WHERE
   eventdate IS NOT NULL
AND
   c.anonpatid = p.anonpatid

HAVING
   pad_us_gprd != 9
   
UNION

SELECT
   t.anonpatid,
   t.eventdate,
   t.medcode,
   WHEN
      -- normal
      t.data1 IN ( 9, 25, 39 ),
      1,
      WHEN
         -- potentially abnormal
         t.data1 IN ( 13, 27, 38 ),
         2, 
         WHEN
            -- abnormal
            t.data1 IN ( 12, 26, 44, 45 ),
            3,
            9 ) ) ) AS pad_us_gprd
FROM
   test t,
   patient p
WHERE
   t.eventdate IS NOT NULL
AND
   t.anonpatid = p.anonpatid
AND
   ( 
      ( t.medcode IN ( 44008,44007,88894,42676,12822,42675 ) AND t.enttype IN ( 339, 251 ) )
      OR
      t.enttype = 367 
   )

HAVING
   pad_us_gprd != 9
   
ORDER BY
   anonpatid;

-- conflict resolution code not required, medcodes are neutral
DROP TABLE IF EXISTS cal_pvd_minap;
CREATE TABLE cal_pvd_minap AS 
SELECT
    anonpatid,
    DATE(date_admission) AS date_admission,
    WHEN
       peripheral_vd IN ( 0, 1 ),
       peripheral_vd,
       9 ) AS pvd_minap
FROM 
    minap
WHERE
    anonpatid IS NOT NULL
AND
    date_admission IS NOT NULL;-- Generated: 2013-02-18 16:58:14
   DROP TABLE IF EXISTS cal_dvt_gprd;

   CREATE TABLE cal_dvt_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 31149,11405,94664,93649,49423,73179,13275,17847,5614,19562,94163,94552,42506,27284,32002,3576,48920,15382,55661,25478,98526,31390,70455,41180,55883,49715,61366,37947,65855,94405,26873,58166,65725,97853,23667,22038,61204,54205,94496,43555,3392,18830,4607,97808,824,70467,91282,1224,61203,57100,20676,8769,69921,58023,38099,23588 );

   -- CREATE INDEX anonpatid ON cal_dvt_gprd( anonpatid );

   ALTER TABLE cal_dvt_gprd ADD COLUMN dvt_gprd INT DEFAULT NULL;

UPDATE cal_dvt_gprd SET dvt_gprd = '0' WHERE medcode IN ( 31149,11405,94664,93649,49423,73179,13275 );
UPDATE cal_dvt_gprd SET dvt_gprd = '1' WHERE medcode IN ( 17847,5614,19562 );
UPDATE cal_dvt_gprd SET dvt_gprd = '2' WHERE medcode IN ( 94163,94552 );
UPDATE cal_dvt_gprd SET dvt_gprd = '3' WHERE medcode IN ( 42506,27284,32002,3576,48920,15382,55661,25478,98526 );
UPDATE cal_dvt_gprd SET dvt_gprd = '4' WHERE medcode IN ( 31390,70455,41180,55883,49715,61366,37947,65855 );
UPDATE cal_dvt_gprd SET dvt_gprd = '5' WHERE medcode IN ( 94405,26873,58166,65725,97853,23667,22038,61204,54205,94496,43555,3392,18830,4607,97808,824,70467,91282,1224,61203,57100,20676,8769,69921,58023,38099,23588 );
-- Generated: 2013-02-18 17:07:41
   DROP TABLE IF EXISTS cal_pe_gprd;

   CREATE TABLE cal_pe_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 35472,65359,16976,10280,26103,1266,31313,49269,68438,34687,65459,98639,73624,97367,45740,7174,67006,44192,44404,96209,9701,18121,73569 );

   -- CREATE INDEX anonpatid ON cal_pe_gprd( anonpatid );

   ALTER TABLE cal_pe_gprd ADD COLUMN pe_gprd INT DEFAULT NULL;

   UPDATE cal_pe_gprd SET pe_gprd = '0' WHERE medcode IN ( 35472,65359 );
UPDATE cal_pe_gprd SET pe_gprd = '1' WHERE medcode IN ( 16976,10280 );
UPDATE cal_pe_gprd SET pe_gprd = '2' WHERE medcode IN ( 26103 );
UPDATE cal_pe_gprd SET pe_gprd = '3' WHERE medcode IN ( 1266,31313,49269,68438,34687,65459,98639,73624,97367,45740,7174,67006,44192,44404,96209,9701,18121,73569 );
-- Generated: 2013-02-18 17:09:31
DROP TABLE IF EXISTS cal_pe_hes;

CREATE TABLE cal_pe_hes AS
SELECT
    anonpatid,
    admidate   AS date_admission,
    discharged AS date_discharge,
    spno,
    icd,
    0 AS epi_primary,
    0 AS hosp_primary
FROM
    hes_diag_hosp h
WHERE
    (   ( icd LIKE 'I26%' )  );

-- CREATE INDEX anonpatid ON cal_pe_hes( anonpatid );

UPDATE
    cal_pe_hes c,
    hes_diag_epi h
SET
    c.epi_primary = 1 
WHERE
    c.anonpatid = h.anonpatid
AND
    c.spno = h.spno
AND
    c.icd = h.icd
AND
    h.`primary` = 1;

 UPDATE
     cal_pe_hes c,
     hes_primary_diag_hosp h
 SET
     c.hosp_primary = 1 
 WHERE
     c.anonpatid = h.anonpatid
 AND
     c.spno = h.spno
 AND
     c.icd = h.primary_icd;

 ALTER TABLE cal_pe_hes ADD COLUMN pe_hes INT DEFAULT NULL;

UPDATE cal_pe_hes SET pe_hes = '3' WHERE (  ( icd LIKE 'I26%' ) );
ALTER TABLE cal_pe_hes DROP COLUMN spno;
-- Generated: 2013-07-09 10:58:08
   DROP TABLE IF EXISTS cal_bradycardia_gprd;

   CREATE TABLE cal_bradycardia_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 26717,13608,1352,26715,3849,18268,8061,3115,52423 );

   -- CREATE INDEX anonpatid ON cal_bradycardia_gprd( anonpatid );

   ALTER TABLE cal_bradycardia_gprd ADD COLUMN bradycardia_gprd INT DEFAULT NULL;

   UPDATE cal_bradycardia_gprd SET bradycardia_gprd = '1' WHERE medcode IN ( 26715,52423,3849,18268,1352,8061,26717,13608,3115 );



-- Generated: 2013-07-09 10:58:37
    DROP TABLE IF EXISTS cal_bradycardia_hes;

    CREATE TABLE cal_bradycardia_hes AS
    SELECT
        anonpatid,
        admidate   AS date_admission,
        discharged AS date_discharge,
        spno,
        icd,
        0 AS epi_primary,
        0 AS hosp_primary
    FROM
        hes_diag_hosp h
    WHERE
        (   ( icd LIKE 'R001%' )  );

    -- CREATE INDEX anonpatid ON cal_bradycardia_hes( anonpatid );

    UPDATE
        cal_bradycardia_hes c,
        hes_diag_epi h
    SET
        c.epi_primary = 1 
    WHERE
        c.anonpatid = h.anonpatid
    AND
        c.spno = h.spno
    AND
        c.icd = h.icd
    AND
        h.`primary` = 1;

     UPDATE
         cal_bradycardia_hes c,
         hes_primary_diag_hosp h
     SET
         c.hosp_primary = 1 
     WHERE
         c.anonpatid = h.anonpatid
     AND
         c.spno = h.spno
     AND
         c.icd = h.primary_icd;

     ALTER TABLE cal_bradycardia_hes ADD COLUMN bradycardia_hes INT DEFAULT NULL;

    UPDATE cal_bradycardia_hes SET bradycardia_hes = '1' WHERE (  ( icd LIKE 'R001%' ) );
ALTER TABLE cal_bradycardia_hes DROP COLUMN spno;



DROP TABLE IF EXISTS cal_pulse_rate;
CREATE TABLE cal_pulse_rate AS
SELECT
   DISTINCT
   c.anonpatid,
   c.eventdate,
   c.data1 AS pulse_rate
FROM 
   patient p,
   clinical c
WHERE 
   p.anonpatid = c.anonpatid

AND
   p.gender IN (1,2)
AND
   c.eventdate IS NOT NULL
AND
   c.enttype = 131
AND
   c.adid > 0
AND
    c.data1 BETWEEN 20 AND 350;-- Generated: 2013-07-09 10:58:58
   DROP TABLE IF EXISTS cal_tachycardia_gprd;

   CREATE TABLE cal_tachycardia_gprd AS
   SELECT 
      c.anonpatid,
      c.eventdate,
      c.medcode 
   FROM 
      clinical c, 
      patient p
   WHERE 
      c.anonpatid = p.anonpatid

   AND 
      c.eventdate IS NOT NULL
   AND 
      c.medcode IN ( 30712,12375,26716,7128,4924,4940,1297,23647,51845,29491,35124,3418,7794,25266,60047,1381,7005,1536,1501,93387 );

   -- CREATE INDEX anonpatid ON cal_tachycardia_gprd( anonpatid );

   ALTER TABLE cal_tachycardia_gprd ADD COLUMN tachycardia_gprd INT DEFAULT NULL;

   UPDATE cal_tachycardia_gprd SET tachycardia_gprd = '1' WHERE medcode IN ( 12375,30712 );
UPDATE cal_tachycardia_gprd SET tachycardia_gprd = '2' WHERE medcode IN ( 29491,7128,7794,26716,23647,3418,7005,25266,35124,4924,4940,1297,1381,93387,51845,1501,60047,1536 );



-- Generated: 2013-07-09 10:59:33
    DROP TABLE IF EXISTS cal_tachycardia_hes;

    CREATE TABLE cal_tachycardia_hes AS
    SELECT
        anonpatid,
        admidate   AS date_admission,
        discharged AS date_discharge,
        spno,
        icd,
        0 AS epi_primary,
        0 AS hosp_primary
    FROM
        hes_diag_hosp h
    WHERE
        (   ( icd LIKE 'I471%' )  OR ( icd LIKE 'I472%' )  OR ( icd LIKE 'I479%' )  OR ( icd LIKE 'R000%' )  );

    -- CREATE INDEX anonpatid ON cal_tachycardia_hes( anonpatid );

    UPDATE
        cal_tachycardia_hes c,
        hes_diag_epi h
    SET
        c.epi_primary = 1 
    WHERE
        c.anonpatid = h.anonpatid
    AND
        c.spno = h.spno
    AND
        c.icd = h.icd
    AND
        h.`primary` = 1;

     UPDATE
         cal_tachycardia_hes c,
         hes_primary_diag_hosp h
     SET
         c.hosp_primary = 1 
     WHERE
         c.anonpatid = h.anonpatid
     AND
         c.spno = h.spno
     AND
         c.icd = h.primary_icd;

     ALTER TABLE cal_tachycardia_hes ADD COLUMN tachycardia_hes INT DEFAULT NULL;

    UPDATE cal_tachycardia_hes SET tachycardia_hes = '2' WHERE (  ( icd LIKE 'I479%' ) OR  ( icd LIKE 'R000%' ) OR  ( icd LIKE 'I472%' ) OR  ( icd LIKE 'I471%' ) );
ALTER TABLE cal_tachycardia_hes DROP COLUMN spno;



