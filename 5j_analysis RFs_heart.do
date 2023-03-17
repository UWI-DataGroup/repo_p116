** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5j_analysis RFs_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-MAR-2023
    // 	date last modified      16-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               To analyse data relating to risk factors
    //  methods                 Reviewing and categorizing the other risk factor variables
	//							Saving results into a dataset for output to Word (6_analysis report_cvd.do)
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
    log using "`logpath'\5j_analysis RFs_heart.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467

** Check totals for prior AMI and prior stroke
tab pami if sd_absstatus==1 ,m //yes==36
tab pstroke if sd_absstatus==1 ,m //yes==17

tab sd_multievent pami ,m //1 as 2nd event but prior AMI=no
count if sd_multievent!=. & sd_multievent!=1 & pami!=1 //1

** pstroke and pami variables were updated in dofile 5a_analysis prep_cvd.do
tab sd_pami if sd_absstatus==1 ,m //yes==37
tab sd_pstroke if sd_absstatus==1 ,m //yes==17

** Check totals for HTN, DM, alcohol use and smoking
tab smoker if sd_absstatus==1 ,m //yes=19
tab htn if sd_absstatus==1 ,m //yes=135
tab diab if sd_absstatus==1 ,m //yes=88
tab alco if sd_absstatus==1 ,m //yes=33

** Check totals for family history (numbers are low so usually not included in annual report)
tab famami if sd_absstatus==1 ,m //yes=7
tab mumami if sd_absstatus==1 ,m //yes=2
tab dadami if sd_absstatus==1 ,m //yes=4
tab sibami if sd_absstatus==1 ,m //yes=2

** Guideline from Angie to Ashley on whether you count in if the risk factor = 99
/*
	NOTE: assumption used here for all RFs is that if DA finds no documentation 
	on RF then they don't have it, as one assumes that the doctor has had 
	poor documentation rather than poor medical history-taking!!
*/
** So will only exclude from the total reporting on risk factor those times wherein risk factor = 99999 as this indicates the question was not answered by the DA

** JC update: Save these results as a dataset for reporting Table 1.4
save "`datapath'\version03\2-working\riskfactors_heart_ar" ,replace

preserve
//Prior AMI
tab sd_pami if sd_absstatus==1 ,m
contract sd_pami if sd_absstatus==1 & sd_pami!=. & sd_pami!=99999
sort sd_pami
gen id=_n
gen rftype_ar=1
gen rf_ar=1
rename _freq number
egen denominator=total(number)
replace denominator=. if id!=3
replace denominator=denominator[_n+2] if denominator==.
drop if id!=1
gen rf_percent=number/denominator*100
save "`datapath'\version03\2-working\riskfactors_heart" ,replace

clear

//Prior stroke
use "`datapath'\version03\2-working\riskfactors_heart_ar" ,clear
tab sd_pstroke if sd_absstatus==1 ,m
contract sd_pstroke if sd_absstatus==1 & sd_pstroke!=. & sd_pstroke!=99999
gen id=_n
gen rftype_ar=1
gen rf_ar=2
rename _freq number
egen denominator=total(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=2
gen rf_percent=number/denominator*100
append using "`datapath'\version03\2-working\riskfactors_heart"
save "`datapath'\version03\2-working\riskfactors_heart" ,replace

clear

//Hypertension
use "`datapath'\version03\2-working\riskfactors_heart_ar" ,clear
tab htn if sd_absstatus==1 ,m
contract htn if sd_absstatus==1 & htn!=. & htn!=99999
gen id=_n
gen rftype_ar=2
gen rf_ar=3
rename _freq number
egen denominator=total(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=3
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_heart"
save "`datapath'\version03\2-working\riskfactors_heart" ,replace

clear

//Diabetes
use "`datapath'\version03\2-working\riskfactors_heart_ar" ,clear
tab diab if sd_absstatus==1 ,m
contract diab if sd_absstatus==1 & diab!=. & diab!=99999
gen id=_n
gen rftype_ar=2
gen rf_ar=4
rename _freq number
egen denominator=total(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=4
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_heart"
save "`datapath'\version03\2-working\riskfactors_heart" ,replace

clear

//Alcohol use
use "`datapath'\version03\2-working\riskfactors_heart_ar" ,clear
tab alco if sd_absstatus==1 ,m
contract alco if sd_absstatus==1 & alco!=. & alco!=99999
gen id=_n
gen rftype_ar=3
gen rf_ar=5
rename _freq number
egen denominator=total(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=5
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_heart"
save "`datapath'\version03\2-working\riskfactors_heart" ,replace

clear

//Smoking
use "`datapath'\version03\2-working\riskfactors_heart_ar" ,clear
tab smoker if sd_absstatus==1 ,m
contract smoker if sd_absstatus==1 & smoker!=. & smoker!=99999
gen id=_n
gen rftype_ar=3
gen rf_ar=6
rename _freq number
egen denominator=total(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=6
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_heart"
save "`datapath'\version03\2-working\riskfactors_heart" ,replace


** format
replace rf_percent=round(rf_percent,1.0)

order id rftype_ar rf_ar number rf_percent denominator

label define rftype_ar_lab 1 "Prior CVD event/disease" 2 "Current co-morbidity" 3 "Lifestyle-related" 4 "Family history of AMI" ,modify
label values rftype_ar rftype_ar_lab
label var rftype_ar "Risk factor type"

label define rf_ar_lab 1 "Prior acute MI" 2 "Prior stroke" 3 "Hypertension" 4 "Diabetes" 5 "Alcohol use" 6 "Smoking" 7 "Mother, father or sibling" ,modify
label values rf_ar rf_ar_lab
label var rf_ar "Risk factor"

drop smoker alco diab htn sd_pstroke sd_pami
sort rf_ar

** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\riskfactors_heart_ar.dta"
save "`datapath'\version03\2-working\riskfactors_heart" ,replace
restore 
