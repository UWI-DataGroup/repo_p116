** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3b_clean dups_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      13-DEC-2022
    // 	date last modified      30-JAN-2023
    //  algorithm task          Identifying, reviewing and removing duplicates
    //  status                  Completed
    //  objective               To have a cleaned 2021 cvd incidence dataset ready for analysis
    //  methods                 Using Stata command quietly sort to:
	//							(1) identify and remove duplicate admissions (i.e. same patient with same admissions entered in different records)
	//							(2) identify multiple events (i.e. same patient with another event >28 days after first event)
	//							(3) identify and update re-admission + stroke-in-evolution info (i.e. same patient with different admissions for same event)
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
/* 
	JC 30jan2023: Based on feedback at CVD team meeting on 23jan2023, definition of multiple events differ for heart and stroke:
	- HEART multiple event definition: time period between heart events DOES NOT apply, each event is seen as a new event.
	- STROKE multiple event definition: if the subsequent stroke occurs more than 28 days after the first stroke then this is considered a multiple event; 
									    if the subsequent stroke occurs on/before 28 days after first stroke then this is considered a stroke-in-evolution.
*/
gen sd_multievent=.
label var sd_multievent "SD-Record with Multiple Events of Stroke or AMI"
label define sd_multievent_lab 1 "First Event" 2 "Second Event" 3 "Third Event", modify
label values sd_multievent sd_multievent_lab
replace sd_multievent=1 if record_id=="2514"|record_id=="2432"|record_id=="1899"|record_id=="2060"|record_id=="1722" ///
						  |record_id=="2071"|record_id=="1839"|record_id=="1862"|record_id=="2137"|record_id=="2836" ///
						  |record_id=="2008"|record_id=="1871"|record_id=="1956"|record_id=="3362"|record_id=="2494" ///
						  |record_id=="3030"|record_id=="2071"|record_id=="1839"|record_id=="1862"|record_id=="2954" ///
						  |record_id=="2137"|record_id=="2836"|record_id=="3654"|record_id=="4046"|record_id=="2142" ///
						  |record_id=="3362"
replace sd_multievent=2 if record_id=="2806"|record_id=="2812"|record_id=="3774"|record_id=="2059"|record_id=="3305" ///
						  |record_id=="2535"|record_id=="2075"|record_id=="2420"|record_id=="2623"|record_id=="3005" ///
						  |record_id=="3163"|record_id=="2989"|record_id=="3847"|record_id=="3272"|record_id=="3350" ///
						  |record_id=="4106"|record_id=="2535"|record_id=="2075"|record_id=="2420"|record_id=="3031" ///
						  |record_id=="2623"|record_id=="3005"|record_id=="3292"|record_id=="3735"|record_id=="3026" ///
						  |record_id=="3272"
replace sd_multievent=3 if record_id=="3203"|record_id=="3203"

** Incidental corrections from above duplicates checks
replace flag51=sd_natregno if record_id=="3362"|record_id=="2865"
replace sd_natregno=subinstr(sd_natregno,"3","2",.) if record_id=="3362"
replace sd_natregno=subinstr(sd_natregno,"49","46",.) if record_id=="2865"
gen nrn=sd_natregno
destring nrn ,replace
replace natregno=nrn if record_id=="3362"|record_id=="2865"
drop nrn
replace flag976=sd_natregno if record_id=="3362"|record_id=="2865"


replace flag45=dob if record_id=="2865"|record_id=="1833"
replace sd_dob=subinstr(sd_dob,"90","60",.) if record_id=="2865"
gen dob2=dob if record_id=="1833"
fillmissing dob2
replace dob=dob2 if record_id=="2865"
gen cfage2=cfage if record_id=="1833"
fillmissing cfage2
replace cfage=cfage2 if record_id=="2865"
drop dob2 cfage2
replace age=cfage if record_id=="2865"
replace flag970=dob if record_id=="2865"|record_id=="1833"


preserve
clear
import excel using "`datapath'\version03\2-working\MissingNRN_20230130.xlsx" , firstrow case(lower)
tostring record_id, replace
destring elec_natregno, replace
tostring elec_sd_natregno, replace
save "`datapath'\version03\2-working\missing_nrn" ,replace
restore

merge m:1 record_id using "`datapath'\version03\2-working\missing_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           735
        from master                       734  (_merge==1)
        from using                          1  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------
*/
replace natregno=elec_natregno if _merge==3 //2 changes
replace flag51=sd_natregno if _merge==3
replace sd_natregno=elec_sd_natregno if _merge==3
replace flag976=sd_natregno if _merge==3
replace flag45=dob if _merge==3
replace dob=elec_dob if _merge==3
replace flag970=dob if _merge==3
replace cfage=elec_cfage if _merge==3
replace flag42=mname if _merge==3
replace mname=elec_mname if _merge==3
replace flag967=mname if _merge==3
drop elec_* _merge
erase "`datapath'\version03\2-working\missing_nrn.dta"


***************************
** 	  POPULATING DATA 	 **
** (Stroke-in-evolution) **
***************************
** Populate data from 2nd admission for the stroke-in-evolution into the record for the 1st admission loosely based on AH's method in 2020 cleaning dofile called '2_clean_stroke_Abs.do'

** Stroke-in-evolution #1
** Populating data from 2nd admission (2728) into 1st admission (3654) based on manually reviewing both records in CVDdb + Stata's Data (Browse) Editor window
preserve
drop if record!="2728" & record!="3654"
local list_of_vars mname mstatus hometel celltel fnamekin lnamekin cellkin relation ssym2 osym osym1 ssym2d osymd nihss pstroke pami smoker alco ovrf assess assess1 assess2 assess3 assess4 assess7 assess8 assess9 assess10 assess12 assess14 dieany dct decg dmri dcerangio dcarangio dcarus decho dctcorang dstress odie ct doct stime ctfeat ctinfarct ctsubhaem ctinthaem hcomp fu1oday fu1sicf fu1con fu1how f1vstatus fu1sit fu1osit fu1readm fu1los furesident ethnicity oethnic education mainwork employ prevemploy pstrsit pstrosit rankin rankin1 rankin2 rankin3 rankin4 rankin5 rankin6 famhxs famhxa mahxs dahxs sibhxs mahxa dahxa sibhxa smoke stopsmoke stopsmkday stopsmkmonth stopsmkyear stopsmokeage smokeage cig pipe cigar otobacco tobacmari marijuana cignum tobgram cigarnum spliffnum alcohol stopalc stopalcday stopalcmonth stopalcyear stopalcage alcage beernumnd spiritnumnd winenumnd beernum spiritnum winenum f1rankin f1rankin1 f1rankin2 f1rankin3 f1rankin4 f1rankin5 f1rankin6
foreach var of local list_of_vars {
    replace `var' = `var'[_n-1] if mi(`var') | !mi(`var'[_n-1]) & record_id=="3654"
    replace `var' = `var'[_n+1] if mi(`var') | !mi(`var'[_n+1]) & record_id=="3654"
}
drop if record_id=="2728"
save "`datapath'\version03\2-working\populating", replace
restore

count //735
drop if record_id=="3654"|record_id=="2728"
count //733
append using "`datapath'\version03\2-working\populating"
count //734
erase "`datapath'\version03\2-working\populating.dta"

** Populate re-admission data using dates from 2nd admission in CVDdb (record_id 2728)
replace readmit=1 if record_id=="3654"
replace readmitadm=d(08jul2021) if record_id=="3654"
replace readmitdis=d(17jul2021) if record_id=="3654"
replace readmitdays=readmitdis-readmitadm if record_id=="3654"


** Stroke-in-evolution #2
** Populating data from 2nd admission (4331) into 1st admission (3136) based on manually reviewing both records in CVDdb + Stata's Data (Browse) Editor window
preserve
drop if record!="3136" & record!="4331"
local list_of_vars ssym2 ssym2d sign4 swalldate cardmon alco
foreach var of local list_of_vars {
    replace `var' = `var'[_n-1] if mi(`var') | !mi(`var'[_n-1]) & record_id=="3136"
    replace `var' = `var'[_n+1] if mi(`var') | !mi(`var'[_n+1]) & record_id=="3136"
}
drop if record_id=="4331"
save "`datapath'\version03\2-working\populating", replace
restore

count //734
drop if record_id=="3136"|record_id=="4331"
count //732
append using "`datapath'\version03\2-working\populating"
count //733
erase "`datapath'\version03\2-working\populating.dta"

** Populate re-admission data using dates from 2nd admission in CVDdb (record_id 4331)
replace readmit=1 if record_id=="3136"
replace readmitadm=d(14nov2021) if record_id=="3136"
replace readmitdis=d(15nov2021) if record_id=="3136"
replace readmitdays=readmitdis-readmitadm if record_id=="3136"



/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flag45 flag970 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag42 flag45 flag51 if ///
		flag42!="" | flag45!=. | flag51!="" ///
using "`datapath'\version03\3-output\CVDCleaning2021_CF3_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag967 flag970 flag976 if ///
		 flag967!="" | flag970!=. | flag976!="" ///
using "`datapath'\version03\3-output\CVDCleaning2021_CF3_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


** Create cleaned non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_cf", replace

** Create dataset for merging with death dataset using NRN
** Remove records with blank NRNs as the incidence and death datasets will not correctly merge using NRN but save the blanks so they can be added back into the ds after the merge in dofile 3c_death match_cvd.do
preserve
count //733
count if sd_natregno==""|sd_natregno=="99" //34
drop if sd_natregno==""|sd_natregno=="99" //34 deleted
save "`datapath'\version03\2-working\nomissNRNs_incidence" ,replace
restore

preserve
count //733
count if sd_natregno==""|sd_natregno=="99" //34
drop if sd_natregno!="" & sd_natregno!="99" //699 deleted
save "`datapath'\version03\2-working\missNRNs_incidence" ,replace
restore
