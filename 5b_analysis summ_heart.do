** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5b_analysis summ_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-MAR-2023
    // 	date last modified      15-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
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
    log using "`logpath'\5b_analysis summ_heart.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //471

******************************
** Summary Statistics Table **
******************************
/*
	Note: the below statistics (excluding length of stay) are included here as a visual reference; 
		  these are ultimately generated and saved in the 6a_analysis report_cvd.do
*/

*****************************
** Number of Registrations **
*****************************
count if sd_eyear==2021 //471

*************************
** Rate per population **
*************************
dis (471/281207) * 100 //.16749227

*************************
** Hospital Admissions **
**	  + proportions	   **
*************************
tab sd_admstatus ,m
/*
  Stata Derived: Hospital |
         Admission Status |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
Admitted to Hospital Ward |        166       35.24       35.24
         Seen only in A&E |         42        8.92       44.16
 Not admitted to hospital |        263       55.84      100.00
--------------------------+-----------------------------------
                    Total |        471      100.00
*/

** Ward admission only
count if sd_admstatus==1 //166
dis (166/471) * 100 //35.244161

** A&E + Ward
count if sd_admstatus!=3 //208
dis (208/471) * 100 //44.161359

*********************
** In-hospital CFR **
**  + proportions  **
*********************
tab sd_absstatus ,m
/*
      Stata Derived: |
  Abstraction Status |      Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction |        192       40.76       40.76
 Partial abstraction |         16        3.40       44.16
No abstraction (DCO) |        263       55.84      100.00
---------------------+-----------------------------------
               Total |        471      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 //192
count if vstatus==2 //64
dis (64/192) * 100 //33.333333

************************
** DCOs + proportions **
************************
count if sd_casetype==2 //264
dis (264/471) * 100 //56.050955

********************************
** Length of stay in hospital **
********************************
** Since heart readmissions are NOT the same event in evolution, the readmission within 28 days variable on the Discharge form is not applicable as it would be with stroke, we can use the length of stay variables without adding the readmission days
tab readmitdays if readmit==1 // record 2064 does not have any diagnoses in MedData but record 3144 shows pt admitted for different complaints so don't include in length of stay calculation
/*
  Number of |
    days in |
   hospital |
   for this |
 subsequent |
re-admissio |
          n |      Freq.     Percent        Cum.
------------+-----------------------------------
          7 |          1       50.00       50.00
         24 |          1       50.00      100.00
------------+-----------------------------------
      Total |          2      100.00
*/

** Per discussion with NS, calculate length of stay (1) from A&E to discharge/death AND (2) from Ward to discharge/death
*********
** A&E **
*********
preserve
replace sd_los_ae=1 if sd_los_ae==0 //26 changes 
drop if sd_los_ae==. //279 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ae) stat(min sd_los_ae) stat(max sd_los_ae)
** med - 5 (1 - 78)
** Now save the p50, min and max for Table 1.1
sum sd_los_ae
sum sd_los_ae ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version03\2-working\los_ae_heart" ,replace
restore

**********
** Ward **
**********
preserve
replace sd_los_ward=1 if sd_los_ward==0 //5 changes
drop if sd_los_ward==. //305 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ward) stat(min sd_los_ward) stat(max sd_los_ward)
** med - 4 (1 - 77)
** Now save the p50, min and max for Table 1.1
sum sd_los_ward
sum sd_los_ward ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version03\2-working\los_ward_heart" ,replace
restore
