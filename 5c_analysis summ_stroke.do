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

count //691

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
count if sd_eyear==2021 //691

*************************
** Rate per population **
*************************
dis (691/281207) * 100 //.24572646

*************************
** Hospital Admissions **
**	  + proportions	   **
*************************
tab sd_admstatus ,m
/*
    Stata Derived: Hospital Admission |
                               Status |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
            Admitted to Hospital Ward |        429       62.08       62.08
                     Seen only in A&E |         99       14.33       76.41
Unknown if admitted to hospital (DCO) |        162       23.44       99.86
                       Community Case |          1        0.14      100.00
--------------------------------------+-----------------------------------
                                Total |        691      100.00
*/

** A&E + Ward
count if sd_admstatus!=3 & sd_admstatus!=4 //528
dis (528/691) * 100 //76.410999

** Ward admission only
count if sd_admstatus==1 //429
dis (429/691) * 100 //62.083936

*********************
** In-hospital CFR **
**  + proportions  **
*********************
tab sd_absstatus ,m
/*
      Stata Derived: |
  Abstraction Status |      Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction |        500       72.36       72.36
 Partial abstraction |         29        4.20       76.56
No abstraction (DCO) |        162       23.44      100.00
---------------------+-----------------------------------
               Total |        691      100.00
*/

tab vstatus ,m
/*
      Vital |
  Status at |
  discharge |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        349       50.51       50.51
   Deceased |        151       21.85       72.36
          . |        191       27.64      100.00
------------+-----------------------------------
      Total |        691      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 //500
count if vstatus==2 & sd_absstatus==1 //151
dis (151/500) * 100 //30.2

************************
** DCOs + proportions **
************************
count if sd_casetype==2 //162
dis (162/691) * 100 //23.444284



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
drop if sd_los_ae==. //188 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ae) stat(min sd_los_ae) stat(max sd_los_ae)
** med - 8 (1 - 208)
** Now save the p50, min and max for Table 1.1
sum sd_los_ae
sum sd_los_ae ,detail
gen medianlos_s_ae=r(p50)
gen range_lower_s_ae=r(min)
gen range_upper_s_ae=r(max)

collapse medianlos_s_ae range_lower_s_ae range_upper_s_ae
order medianlos_s_ae range_lower_s_ae range_upper_s_ae
save "`datapath'\version03\2-working\los_ae_stroke_all" ,replace
restore

**********
** Ward **
**********
preserve
replace sd_los_ward=1 if sd_los_ward==0 //4 changes
drop if sd_los_ward==. //262 deleted
gen k=1
drop if k!=1

table k, stat(q2 sd_los_ward) stat(min sd_los_ward) stat(max sd_los_ward)
** med - 9 (1 - 209)
** Now save the p50, min and max for Table 1.1
sum sd_los_ward
sum sd_los_ward ,detail
gen medianlos_s_ward=r(p50)
gen range_lower_s_ward=r(min)
gen range_upper_s_ward=r(max)

collapse medianlos_s_ward range_lower_s_ward range_upper_s_ward
order medianlos_s_ward range_lower_s_ward range_upper_s_ward
save "`datapath'\version03\2-working\los_ward_stroke_all" ,replace
restore



************************************************* FIRST EVER STROKES *******************************************
*****************************
** Number of Registrations **
*****************************
count if sd_fes==1 //248

*************************
** Rate per population **
*************************
dis (248/281207) * 100 //.08819126


*************************
** Hospital Admissions **
**	  + proportions	   **
*************************
tab sd_admstatus if sd_fes==1
/*
    Stata Derived: Hospital Admission |
                               Status |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
            Admitted to Hospital Ward |        208       83.87       83.87
                     Seen only in A&E |         40       16.13      100.00
--------------------------------------+-----------------------------------
                                Total |        248      100.00
*/

** A&E + Ward
count if sd_admstatus!=3 & sd_admstatus!=4 & sd_fes==1 //248
dis (248/248) * 100 //100

** Ward admission only
count if sd_admstatus==1 & sd_fes==1 //208
dis (208/248) * 100 //83.870968

*********************
** In-hospital CFR **
**  + proportions  **
*********************
tab sd_absstatus if sd_fes==1
/*
      Stata Derived: |
  Abstraction Status |      Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction |        248      100.00      100.00
---------------------+-----------------------------------
               Total |        248      100.00
*/
tab vstatus if sd_fes==1
/*
      Vital |
  Status at |
  discharge |      Freq.     Percent        Cum.
------------+-----------------------------------
      Alive |        136       54.84       54.84
   Deceased |        112       45.16      100.00
------------+-----------------------------------
      Total |        248      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 & sd_fes==1 //248
count if vstatus==2 & sd_absstatus==1 & sd_fes==1 //112
dis (112/248) * 100 //45.16129

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
gen medianlos_fes_ae=r(p50)
gen range_lower_fes_ae=r(min)
gen range_upper_fes_ae=r(max)

collapse medianlos_fes_ae range_lower_fes_ae range_upper_fes_ae
order medianlos_fes_ae range_lower_fes_ae range_upper_fes_ae
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
gen medianlos_fes_ward=r(p50)
gen range_lower_fes_ward=r(min)
gen range_upper_fes_ward=r(max)

collapse medianlos_fes_ward range_lower_fes_ward range_upper_fes_ward
order medianlos_fes_ward range_lower_fes_ward range_upper_fes_ward
save "`datapath'\version03\2-working\los_ward_stroke_fes" ,replace
restore
