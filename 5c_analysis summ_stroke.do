** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5c_analysis summ_stroke.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-MAR-2023
    // 	date last modified      15-MAR-2023
    //  algorithm task          Performing analysis on 2021 stroke data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               (1) To analyse data to calculate summary statistics 
	//							(2) To save the results for outputting to MS Word 6a_analysis report_cvd.do
    //  methods                 Using Stata commands table + statistics to analyse data
	//							Using analysis variables created in 5a_analysis prep_cvd.do
	//  support:                Natasha Sobers and Ian R Hambleton

    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p116"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p116

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\5c_analysis summ_stroke.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //694

******************************
** Summary Statistics Table **
******************************
/*
	Note: the below statistics (excluding length of stay) are included here as a visual reference; 
		  these are ultimately generated and saved in the 6a_analysis report_cvd.do
*/

************************************************* ALL STROKES *******************************************
*****************************
** Number of Registrations **
*****************************
count if sd_eyear==2021 //694

*************************
** Rate per population **
*************************
dis (694/281207) * 100 //.24679329


*************************
** Hospital Admissions **
**	  + proportions	   **
*************************
tab sd_admstatus ,m
/*
  Stata Derived: Hospital |
         Admission Status |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
Admitted to Hospital Ward |        433       62.39       62.39
         Seen only in A&E |         99       14.27       76.66
 Not admitted to hospital |        162       23.34      100.00
--------------------------+-----------------------------------
                    Total |        694      100.00
*/

** Ward admission only
count if sd_admstatus==1 //433
dis (433/694) * 100 //62.391931

** A&E + Ward
count if sd_admstatus!=3 //532
dis (532/694) * 100 //76.657061

*********************
** In-hospital CFR **
**  + proportions  **
*********************
tab sd_absstatus ,m
/*
      Stata Derived: |
  Abstraction Status |      Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction |        504       72.62       72.62
 Partial abstraction |         29        4.18       76.80
No abstraction (DCO) |        161       23.20      100.00
---------------------+-----------------------------------
               Total |        694      100.00
*/

tab vstatus ,m
/*
      Vital |
  Status at |
  discharge |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        349       50.29       50.29
   Deceased |        155       22.33       72.62
          . |        190       27.38      100.00
------------+-----------------------------------
      Total |        694      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 //504
count if vstatus==2 //155
dis (155/504) * 100 //30.753968

************************
** DCOs + proportions **
************************
count if sd_casetype==2 //162
dis (162/694) * 100 //23.342939



********************************
** Length of stay in hospital **
********************************
** Since stroke readmissions maybe the same event in evolution, the readmission within 28 days variable on the Discharge form maybe applicable, so need to review the readmission days to see if they are a stroke-in-evolution and then we can use the length of stay variables and add the readmission days
** For updated calculation of readmission days for stroke cases, see dofile 5a_analysis prep_cvd.do
tab readmitdays if readmit==1
/*
  Number of |
    days in |
   hospital |
   for this |
 subsequent |
re-admissio |
          n |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          2       28.57       28.57
          3 |          1       14.29       42.86
          4 |          1       14.29       57.14
          6 |          1       14.29       71.43
          9 |          1       14.29       85.71
         20 |          1       14.29      100.00
------------+-----------------------------------
      Total |          7      100.00
*/
//list record_id readmit readmitadm readmitdis readmitdays sd_readmitdays_ward sd_los_ae sd_los_ward if readmit==1
replace sd_los_ae=sd_los_ae+readmitdays if readmit==1 //7 changes
replace sd_los_ward=sd_los_ward+sd_readmitdays_ward if readmit==1 //5 changes

** Per discussion with NS, calculate length of stay (1) from A&E to discharge/death AND (2) from Ward to discharge/death
*********
** A&E **
*********
preserve
replace sd_los_ae=1 if sd_los_ae==0 //17 changes 
drop if sd_los_ae==. //187 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ae) stat(min sd_los_ae) stat(max sd_los_ae)
** med - 8 (1 - 208)
** Now save the p50, min and max for Table 1.1
sum sd_los_ae
sum sd_los_ae ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version03\2-working\los_ae_stroke_all" ,replace
restore

**********
** Ward **
**********
preserve
replace sd_los_ward=1 if sd_los_ward==0 //4 changes
drop if sd_los_ward==. //261 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ward) stat(min sd_los_ward) stat(max sd_los_ward)
** med - 9 (1 - 209)
** Now save the p50, min and max for Table 1.1
sum sd_los_ward
sum sd_los_ward ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version03\2-working\los_ward_stroke_all" ,replace
restore



************************************************* FIRST EVER STROKES *******************************************
*****************************
** Number of Registrations **
*****************************
count if sd_fes==1 //251

*************************
** Rate per population **
*************************
dis (251/281207) * 100 //.08925809


*************************
** Hospital Admissions **
**	  + proportions	   **
*************************
tab sd_admstatus if sd_fes==1
/*
  Stata Derived: Hospital |
         Admission Status |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
Admitted to Hospital Ward |        211       84.06       84.06
         Seen only in A&E |         40       15.94      100.00
--------------------------+-----------------------------------
                    Total |        251      100.00
*/

** Ward admission only
count if sd_admstatus==1 & sd_fes==1 //211
dis (211/251) * 100 //84.063745

** A&E + Ward
count if sd_admstatus!=3 & sd_fes==1 //251
dis (251/251) * 100 //100

*********************
** In-hospital CFR **
**  + proportions  **
*********************
tab sd_absstatus if sd_fes==1
/*
      Stata Derived: |
  Abstraction Status |      Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction |        251      100.00      100.00
---------------------+-----------------------------------
               Total |        251      100.00
*/
tab vstatus if sd_fes==1
/*
      Vital |
  Status at |
  discharge |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        136       54.18       54.18
   Deceased |        115       45.82      100.00
------------+-----------------------------------
      Total |        251      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 & sd_fes==1 //251
count if vstatus==2 & sd_fes==1 //115
dis (115/251) * 100 //45.816733

************************
** DCOs + proportions **
************************
//This is not applicable since only abstracted cases would have info on whether pt had a previous stroke or not



********************************
** Length of stay in hospital **
********************************
** Since stroke readmissions maybe the same event in evolution, the readmission within 28 days variable on the Discharge form maybe applicable, so need to review the readmission days to see if they are a stroke-in-evolution and then we can use the length of stay variables and add the readmission days
** For updated calculation of readmission days for stroke cases, see dofile 5a_analysis prep_cvd.do
tab readmitdays if readmit==1
/*
  Number of |
    days in |
   hospital |
   for this |
 subsequent |
re-admissio |
          n |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          2       28.57       28.57
          3 |          1       14.29       42.86
          4 |          1       14.29       57.14
          6 |          1       14.29       71.43
          9 |          1       14.29       85.71
         20 |          1       14.29      100.00
------------+-----------------------------------
      Total |          7      100.00
*/
//list record_id readmit readmitadm readmitdis readmitdays sd_readmitdays_ward sd_los_ae sd_los_ward if readmit==1
replace sd_los_ae=sd_los_ae+readmitdays if readmit==1 //7 changes
replace sd_los_ward=sd_los_ward+sd_readmitdays_ward if readmit==1 //5 changes

** Per discussion with NS, calculate length of stay (1) from A&E to discharge/death AND (2) from Ward to discharge/death
*********
** A&E **
*********
preserve
drop if sd_fes!=1 //443 deleted
replace sd_los_ae=1 if sd_los_ae==0 //6 changes 
drop if sd_los_ae==. //0 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ae) stat(min sd_los_ae) stat(max sd_los_ae)
** med - 7 (1 - 208)
** Now save the p50, min and max for Table 1.1
sum sd_los_ae
sum sd_los_ae ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version03\2-working\los_ae_stroke_fes" ,replace
restore

**********
** Ward **
**********
preserve
drop if sd_fes!=1 //443 deleted
replace sd_los_ward=1 if sd_los_ward==0 //2 changes
drop if sd_los_ward==. //40 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ward) stat(min sd_los_ward) stat(max sd_los_ward)
** med - 8 (1 - 206)
** Now save the p50, min and max for Table 1.1
sum sd_los_ward
sum sd_los_ward ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version03\2-working\los_ward_stroke_fes" ,replace
restore
