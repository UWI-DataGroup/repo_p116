** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          2a_prep_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified      07-DEC-2022
    //  algorithm task          Removing non-annual report records; Copying stroke's repeating instrument data into one row of data
    //  status                  Completed
    //  objective               To have a prepared 2021 cvd incidence dataset ready for cleaning
    //  methods                 Using bysort loops to fill data into rows for each stroke REDCap repeating instrument
	//							Note: since REDCap's heart arm does not have repeating instruments the above method was only performed on the stroke arm's data
	//							Note: most of this dofile is based on the 2020 dofile called '1_strokeredcap_data_reformatting.do'
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
    log using "`logpath'\2a_prep_cvd.smcl", replace
** HEADER -----------------------------------------------------


** This dofile was prepared by ARP Henry on 30-May-20201, to attempt
** to reformat the redcap exports to have only one unique record_id per row of data.
** ensuring that all data for the same record_id is documented in one row.

use "`datapath'\version03\2-working\BNRCVDCORE_FormattedData", clear


**Creating Over-Arching variable for repeat instrument.
gen repinstrument = 1 if redcap_repeat_instrument=="casefinding"
replace repinstrument = 2 if redcap_repeat_instrument=="demographics" & repinstrument==.
replace repinstrument = 3 if redcap_repeat_instrument=="patient_management" & repinstrument==.
replace repinstrument = 4 if redcap_repeat_instrument=="event" & repinstrument==.
replace repinstrument = 5 if redcap_repeat_instrument=="history" & repinstrument==.
replace repinstrument = 6 if redcap_repeat_instrument=="tests" & repinstrument==.
replace repinstrument = 7 if redcap_repeat_instrument=="complications_dx" & repinstrument==.
replace repinstrument = 8 if redcap_repeat_instrument=="medications" & repinstrument==.
replace repinstrument = 9 if redcap_repeat_instrument=="discharge" & repinstrument==.
replace repinstrument = 10 if redcap_repeat_instrument=="day_fu" & repinstrument==.
label define rep_lab 1 "casefinding" 2 "demographics" 3 "patient_management" ///
4 "event" 5 "history" 6 "tests" 7 "complications_dx" 8 "medications" ///
9 "discharge" 10 "day_fu",modify
label values repinstrument rep_lab
tab repinstrument redcap_event_name,miss
tab redcap_event_name
** repeating instrument only used for stroke cases, so all heart cases are fine.

** Remove all variables not necessary for data cleaning/analysis
drop tf* //tracking form variables
drop otftype cfupdate recid absdone disdone totpile tracking_complete //JC 02nov2022: removing more tracking variables
drop rvpid rvpidcfabs rvcfadoa rvcfada rvflagd rvflag rvflag_old rvflag_new rvflagcorrect rvaction rvactiond rvactionda rvactionoda rvflagtot reviewing_complete //reviewing form variables
drop if regexm(record_id, "108-") //sop data
drop if redcap_event_name=="tracking_arm_3"|redcap_event_name=="dashboards_arm_5"
drop hcfr2020 hcfr2020_jan hcfr2020_feb hcfr2020_mar hcfr2020_apr hcfr2020_may hcfr2020_jun hcfr2020_jul hcfr2020_aug hcfr2020_sep hcfr2020_oct hcfr2020_nov hcfr2020_dec hcfr2021 hcfr2021_jan hcfr2021_feb hcfr2021_mar hcfr2021_apr hcfr2021_may hcfr2021_jun hcfr2021_jul hcfr2021_aug hcfr2021_sep hcfr2021_oct hcfr2021_nov hcfr2021_dec haspdash2020 haspdash2020_jan haspdash2020_feb haspdash2020_mar haspdash2020_apr haspdash2020_may haspdash2020_jun haspdash2020_jul haspdash2020_aug haspdash2020_sep haspdash2020_oct haspdash2020_nov haspdash2020_dec haspdash2021 haspdash2021_jan haspdash2021_feb haspdash2021_mar haspdash2021_apr haspdash2021_may haspdash2021_jun haspdash2021_jul haspdash2021_aug haspdash2021_sep haspdash2021_oct haspdash2021_nov haspdash2021_dec scfr2020 scfr2020_jan scfr2020_feb scfr2020_mar scfr2020_apr scfr2020_may scfr2020_jun scfr2020_jul scfr2020_aug scfr2020_sep scfr2020_oct scfr2020_nov scfr2020_dec scfr2021 scfr2021_jan scfr2021_feb scfr2021_mar scfr2021_apr scfr2021_may scfr2021_jun scfr2021_jul scfr2021_aug scfr2021_sep scfr2021_oct scfr2021_nov scfr2021_dec saspdash2020 saspdash2020_jan saspdash2020_feb saspdash2020_mar saspdash2020_apr saspdash2020_may saspdash2020_jun saspdash2020_jul saspdash2020_aug saspdash2020_sep saspdash2020_oct saspdash2020_nov saspdash2020_dec saspdash2021 saspdash2021_jan saspdash2021_feb saspdash2021_mar saspdash2021_apr saspdash2021_may saspdash2021_jun saspdash2021_jul saspdash2021_aug saspdash2021_sep saspdash2021_oct saspdash2021_nov saspdash2021_dec dashboards_complete


** Will make a unique var for identifiable purposes as currently record_id does not uniquely identify each row of data.
egen unique_id=concat(record_id repinstrument), p(-) 
replace unique_id=subinstr(unique_id,"-.","",.) if regexm(unique_id,"-.")
//tab unique_id, m
order unique_id

** For each loops to copy all contents of each row of each specific record_id across one row with the same record_id.
** This first loop will copy all string variables only across each row.
ds, has(type string)
local variables `r(varlist)' 
foreach v of varlist `variables' {
  bysort record_id (unique_id) : replace `v' = `v'[_n-1] if missing(`v')
    bysort record_id (unique_id) : replace `v' = `v'[_n+1] if missing(`v')
	bysort record_id (unique_id) : replace `v' = `v'[_N] if missing(`v')
}	
** This second loop will copy all integer variables only across each row.
ds record_id, not
ds, has(type int)
local variables `r(varlist)'
foreach v of varlist `variables' {
     bysort record_id (unique_id) : replace `v' = `v'[_n-1] if missing(`v')
    bysort record_id (unique_id) : replace `v' = `v'[_n+1] if missing(`v')
	bysort record_id (unique_id) : replace `v' = `v'[_N] if missing(`v')
}	
** This third loop will copy all byte variables only across each row.
ds record_id, not
ds, has(type byte)
local variables `r(varlist)'
foreach v of varlist `variables' {
     bysort record_id (unique_id) : replace `v' = `v'[_n-1] if missing(`v')
    bysort record_id (unique_id) : replace `v' = `v'[_n+1] if missing(`v')
	bysort record_id (unique_id) : replace `v' = `v'[_N] if missing(`v')
}
** This fourth loop will copy all double variables only across each row.
ds record_id, not
ds, has(type double)
local variables `r(varlist)'
foreach v of varlist `variables' {
    bysort record_id (unique_id) : replace `v' = `v'[_n-1] if missing(`v')
    bysort record_id (unique_id) : replace `v' = `v'[_n+1] if missing(`v')
	bysort record_id (unique_id) : replace `v' = `v'[_N] if missing(`v')
}

** This fifth loop will copy all float variables only across each row.
ds record_id, not
ds, has(type float)
local variables `r(varlist)'
foreach v of varlist `variables' {
    bysort record_id (unique_id) : replace `v' = `v'[_n-1] if missing(`v')
    bysort record_id (unique_id) : replace `v' = `v'[_n+1] if missing(`v')
	bysort record_id (unique_id) : replace `v' = `v'[_N] if missing(`v')
}
	
** Next will check id for duplicates
sort unique_id repinstrument
quietly by unique_id : gen dup = cond(_N==1, 0, _n)
sort unique_id repinstrument
list unique_id record_id repinstrument if dup>0 & unique_id!= unique_id[_n-1]
count if dup>0 & unique_id!= unique_id[_n-1]  //20
//20 seen - cases with more than one admission in one record


** JC 01nov2022: disabling below code as 2021 process will clean both heart and stroke data simultaneously (new code to identify 2 admissions included below)
/*
** giving duplicates a seperate addition to their ID to make them unique as well. We will know by this additions all cases with 2 admissions
replace unique_id=subinstr(unique_id, "-", "-02",.) if dup>1
drop dup

** Saving dataset before removing heart/ stroke data:
save "`datapath'\abstractions\raw_data\BNRCVDCORE_RowsCopied.dta", replace

**** SAVING HEART DATASET ****
preserve
keep if redcap_event_name=="heart_arm_2"
save "`datapath'\abstractions\raw_data\BNRCVDCORE_HeartRawData.dta", replace
restore


***** SAVING STROKE DATASET
preserve
//keep if redcap_event_name=="stroke_arm_1"
** reshaping the data to a wide dataset; this is only necessary for stroke data.
** this will be the last step after the row merging step has been completed.
//reshape wide redcap_repeat_instrument event, i(unique_id) j(repinstrument)


** keeping all first records and dropping all other now that all the information has been copied across.
sort unique_id
drop if regexm(unique_id,"-2") | regexm(unique_id,"-3") | regexm(unique_id,"-4") |  regexm(unique_id,"-5")|  regexm(unique_id,"-6")|  regexm(unique_id,"-7") |  regexm(unique_id,"-8") |  regexm(unique_id,"-9")
drop if regexm(unique_id,"-10")
save "`datapath'\abstractions\raw_data\BNRCVDCORE_StrokeRawData.dta", replace
restore
*/

** Create variable to identify multiple admissions seen from above duplicates check
sort record_id
count if dup>0 //40 - 20 records with a 2nd admission
list unique_id record_id repinstrument redcap_repeat_instance dup if dup>0
count if redcap_repeat_instance>1 //2356
count if redcap_repeat_instance>1 & dup>0 //20

gen sd_multiadm=1 if redcap_repeat_instance==1 & dup>0 //20 changes
replace sd_multiadm=2 if redcap_repeat_instance==2 & dup>0 //20 changes

** Prefix all Stata-derived variables with "sd_"
label var sd_multiadm "SD-Record with Multiple Admissions"
label define sd_multiadm_lab 1 "First Admission" 2 "Second Admission" , modify
label values sd_multiadm sd_multiadm_lab

tab sd_multiadm ,m
drop dup


** Remove data rows except the CF data row for stroke's repeating instruments 
drop if regexm(unique_id,"-2") | regexm(unique_id,"-3") | regexm(unique_id,"-4") |  regexm(unique_id,"-5")|  regexm(unique_id,"-6")|  regexm(unique_id,"-7") |  regexm(unique_id,"-8") |  regexm(unique_id,"-9")
drop if regexm(unique_id,"-10")


** Create data collection year variable and check against auto-populated year varibles from REDCap db
gen sd_dcyear = year(cfadmdate) if edate==.
replace sd_dcyear = year(edate) if sd_dcyear==. & edate!=.
tab sd_dcyear ,m //7 missing

replace sd_dcyear = year(cfdod) if sd_dcyear==. & cfdod!=. //3 changes (heart records 2830 + 5304 + 540)
drop if record_id=="2893" //blank heart record
replace sd_dcyear = year(dlc) if sd_dcyear==. & dlc!=. //1 change (stroke record 3907)
drop if record_id=="3908" //duplicate stroke record for 2022

tab sd_dcyear ,m
/*
01nov2022 export
     dcyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2020 |      1,887       35.96       35.96
       2021 |      1,834       34.95       70.90
       2022 |      1,527       29.10      100.00
------------+-----------------------------------
      Total |      5,248      100.00

07dec2022 export
  sd_dcyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2020 |      1,888       34.73       34.73
       2021 |      1,837       33.79       68.52
       2022 |      1,711       31.48      100.00
------------+-----------------------------------
      Total |      5,436      100.00
*/

** Remove non-2021 data
drop if sd_dcyear!=2021

label var sd_dcyear "SD-Data Collection Year"

** Create event type variable
gen sd_etype=1 if redcap_event_name=="stroke_arm_1"
replace sd_etype=2 if redcap_event_name=="heart_arm_2"

label var sd_etype "SD-Event Type"
label define sd_etype_lab 1 "Stroke" 2 "Heart" 3 "Both" 4 "Not CVD" , modify
label values sd_etype sd_etype_lab

** Create a unique ID to use for linking frames in flags dofile (2b_prep flags_cvd.do)
sort unique_id 
quietly by unique_id : gen dup = cond(_N==1,0,_n)
sort unique_id record_id
count if dup>0 //10

gen link_id = unique_id
replace link_id = subinstr(link_id,"-1","-2",.) if dup>0 & redcap_repeat_instance==2

order link_id
drop dup

** JC 26jan2023: Create an identifier for the death dataset in prep for the death-incidence matching/merging process
** This variable has been created in the death dataset also
gen sd_casetype=1
label define sd_casetype_lab 1 "Database" 2 "Death Data", modify
label values sd_casetype sd_casetype_lab
label var sd_casetype "Case from CVDdb or death data?"

count //1834; 1837

** Create prepared dataset
save "`datapath'\version03\2-working\BNRCVDCORE_PreparedData", replace