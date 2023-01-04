** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3b_clean dups_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      13-DEC-2022
    // 	date last modified      04-JAN-2023
    //  algorithm task          Identifying, reviewing and removing duplicates
    //  status                  Pending
    //  objective               To have a cleaned 2021 cvd incidence dataset ready for analysis
    //  methods                 Using Stata command quietly sort to:
	//							(1) identify and remove duplicate admissions (i.e. same patient with same admissions entered in different records)
	//							(2) identify multiple events (i.e. same patient with another event >28 days after first event)
	//							(3) identify and update re-admission info (i.e. same patient with different admissions for same event)
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
    log using "`logpath'\3b_clean dups_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load prepared 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_cf", clear


*********
** NRN **
*********
** Identify possible duplicates using NRN
preserve
drop if sd_natregno=="88"|sd_natregno=="99" //36 deleted - remove blank/missing NRNs as these will be flagged as duplicates of each other
sort sd_natregno 
quietly by sd_natregno : gen dup = cond(_N==1,0,_n)
sort sd_natregno record_id lname fname
count if dup>0 //54
order record_id sd_etype fname lname sd_natregno cfadmdate finaldx cfcods cstatus edate
restore

*********
** DOB **
*********
** Create string variable for DOB
gen BIRTHYR=year(dob)
tostring BIRTHYR, replace
gen BIRTHMONTH=month(dob)
gen str2 BIRTHMM = string(BIRTHMONTH, "%02.0f")
gen BIRTHDAY=day(dob)
gen str2 BIRTHDD = string(BIRTHDAY, "%02.0f")
gen BIRTHD=BIRTHYR+BIRTHMM+BIRTHDD
replace BIRTHD="" if BIRTHD=="..." //108 changes
drop BIRTHDAY BIRTHMONTH BIRTHYR BIRTHMM BIRTHDD
rename BIRTHD sd_dob

** Identify possible duplicates using DOB
preserve
drop if sd_dob=="" | sd_dob=="99999999" //26 deleted - remove blank/missing DOBs as these will be flagged as duplicates of each other
sort sd_dob 
quietly by sd_dob : gen dup = cond(_N==1,0,_n)
sort sd_dob record_id lname fname
count if dup>0 //83
order record_id sd_etype fname lname sd_dob sd_natregno cfadmdate finaldx cfcods cstatus edate
restore


***********
** Hosp# **
***********
** Identify possible duplicates using Hosp#
preserve
drop if recnum=="" | recnum=="99" //45 deleted - remove blank/missing Hosp#s as these will be flagged as duplicates of each other
sort recnum 
quietly by recnum : gen dup = cond(_N==1,0,_n)
sort recnum record_id lname fname
count if dup>0 //44
order record_id sd_etype fname lname recnum sd_natregno sd_dob cfadmdate finaldx cfcods cstatus edate
restore


***********
** NAMES **
***********
** Identify possible duplicates using NAMES
preserve
drop if lname=="" | lname=="99" //0 deleted - remove blank/missing LASTNAMES as these will be flagged as duplicates of each other
sort lname fname 
quietly by lname fname : gen dup = cond(_N==1,0,_n)
sort lname fname record_id
count if dup>0 //63
order record_id sd_etype fname lname recnum sd_natregno sd_dob cfadmdate finaldx cfcods cstatus edate
restore


** Create a variable to identify patients with both a stroke and AMI in 2021
gen sd_bothevent=.
label var sd_bothevent "SD-Patient with Both Stroke + AMI"
label define sd_bothevent_lab 1 "First Event" 2 "Second Event" , modify
label values sd_bothevent sd_bothevent_lab

replace sd_bothevent=1 if record_id=="2999"|record_id=="2138"|record_id=="1830"|record_id=="2282"|record_id=="1975" ///
						 |record_id=="3227"|record_id=="3318"|record_id=="1833"
replace sd_bothevent=2 if record_id=="3641"|record_id=="3290"|record_id=="2682"|record_id=="3281"|record_id=="2121" ///
						|record_id=="4088"|record_id=="2322"|record_id=="2865"

** Update info from re-admission record into main record that will be kept
//replace ovrf=1 if record_id=="2514"
//gen sd_ovrf1=ovrf1 if record_id=="2806"
//fillmissing sd_ovrf1
//replace ovrf1=sd_ovrf1 if record_id=="2514"
//drop sd_ovrf1

** Create a variable to identify patients with multiple events in 2021
gen sd_multievent=.
label var sd_multievent "SD-Record with Multiple Events of Stroke or AMI"
label define sd_multievent_lab 1 "First Event" 2 "Second Event" 3 "Third Event", modify
label values sd_multievent sd_multievent_lab
replace sd_multievent=1 if record_id=="2514"|record_id=="2432"|record_id=="1899"|record_id=="2060"|record_id=="1722" ///
						  |record_id=="2071"|record_id=="1839"|record_id=="1862"|record_id=="2137"|record_id=="2836" ///
						  |record_id=="2008"|record_id=="1871"|record_id=="1956"|record_id=="3362"
replace sd_multievent=2 if record_id=="2806"|record_id=="2812"|record_id=="3774"|record_id=="2059"|record_id=="3305" ///
						  |record_id=="2535"|record_id=="2075"|record_id=="2420"|record_id=="2623"|record_id=="3005" ///
						  |record_id=="3163"|record_id=="2989"|record_id=="3847"|record_id=="3272"
replace sd_multievent=3 if record_id=="3203"

** Incidental corrections from above duplicates checks
replace sd_natregno=subinstr(sd_natregno,"3","2",.) if record_id=="3362"
replace sd_natregno=subinstr(sd_natregno,"49","46",.) if record_id=="2865"
gen nrn=sd_natregno
destring nrn ,replace
replace natregno=nrn if record_id=="3362"|record_id=="2865"
drop nrn

replace sd_dob=subinstr(sd_dob,"90","60",.) if record_id=="2865"
gen dob2=dob if record_id=="1833"
fillmissing dob2
replace dob=dob2 if record_id=="2865"
gen cfage2=cfage if record_id=="1833"
fillmissing cfage2
replace cfage=cfage2 if record_id=="2865"
drop dob2 cfage2
replace age=cfage if record_id=="2865"

STOP

Awaiting team's feedback on heart:
- 3030 + 4106: merge into one record VS register as 2 different events
- 2954 + 3031: merge into one record VS register as 2 different events
- 4046 + 3735: merge into one record VS register as 2 different events

Awaiting team's feedback on stroke:
- 3654, 2728 + 3292: merge 3654 + 2728 into one record and register 3292 as different event VS register as 3 different events
- 2142 + 3026: merge into one record VS register as 2 different events
- 3577 + 1985: unsure if this is the same pt - check MedData later as password expired and nodal srv down.
- 3136 + 4331: merge into one record VS register as 2 different events


** Create cleaned non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_cf", replace