** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5k_analysis RFs_stroke.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-MAR-2023
    // 	date last modified      16-MAR-2023
    //  algorithm task          Performing analysis on 2021 stroke data for 2021 CVD Annual Report
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
    log using "`logpath'\5k_analysis RFs_stroke.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified STROKE 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //691

** pstroke and pami variables were updated in dofile 5a_analysis prep_cvd.do
tab sd_pami if sd_absstatus==1 ,m //yes=12
tab sd_pstroke if sd_absstatus==1 ,m //yes=110
tab tia if sd_absstatus==1 ,m //yes=12
tab sd_pstroke tia if sd_absstatus==1 ,m //yes=110

/*
gen tot_pstia=1 if sd_pstroke!=. & sd_pstroke!=99999
replace tot_pstia=1 if tia!=. & tia!=99999 & tot_pstia==.
tab sd_absstatus tot_pstia ,m
tab tot_pstia ,m

gen pstia=1 if sd_pstroke==1 //110
tab sd_absstatus pstia ,m
replace pstia=1 if tia==1 //6 - one is a partial abstraction
tab sd_absstatus pstia ,m
stop
*/

** Check totals for HTN, DM, alcohol use and smoking
tab smoker if sd_absstatus==1 ,m //yes=29
tab htn if sd_absstatus==1 ,m //yes=372
tab diab if sd_absstatus==1 ,m //yes=218
tab alco if sd_absstatus==1 ,m //yes=76

** Check totals for family history (numbers are low so usually not included in annual report)
tab famstroke if sd_absstatus==1 ,m //yes=20
tab mumstroke if sd_absstatus==1 ,m //yes=10
tab dadstroke if sd_absstatus==1 ,m //yes=4
tab sibstroke if sd_absstatus==1 ,m //yes=8


** For prior/current IHD/CVD/PVD/AMI, check the other risk factor variables

** Standardize other symptoms so it is easier to categorize them
replace ovrf1 = upper(rtrim(ltrim(itrim(ovrf1)))) //376 changes
replace ovrf2 = upper(rtrim(ltrim(itrim(ovrf2)))) //223 changes
replace ovrf3 = upper(rtrim(ltrim(itrim(ovrf3)))) //117 changes
replace ovrf4 = upper(rtrim(ltrim(itrim(ovrf4)))) //48 changes

** Review other symptoms to determine most common of these other symptoms
count if sd_absstatus==1 & ovrf!=. & ovrf!=5 & ovrf!=99 & ovrf!=99999 //72
//list ovrf1 ovrf2 ovrf3 ovrf4 if sd_absstatus==1 & ovrf!=. & ovrf!=5 & ovrf!=99 & ovrf!=99999

** Also may need to recode/update "prior MI" as there may be some in the "other" section as well
list pami ovrf1 ovrf2 ovrf3 ovrf4 if (regexm(ovrf1, "ACUTE MI"))|(regexm(ovrf2, "ACUTE MI"))|(regexm(ovrf3, "ACUTE MI"))|(regexm(ovrf4, "ACUTE MI"))
** No need for re-coding

** Combining caardiac RFs: CVD + IHD + PVD
list ovrf1 ovrf2 ovrf3 ovrf4 if ///
	((regexm(ovrf1, "IHD"))|(regexm(ovrf1, "CVD"))|(regexm(ovrf1, "PVD"))|(regexm(ovrf1, "CARDIOVASC"))|(regexm(ovrf1, "PERIPHERAL VASC"))| ///
	 (regexm(ovrf2, "IHD"))|(regexm(ovrf2, "CVD"))|(regexm(ovrf2, "PVD"))|(regexm(ovrf2, "CARDIOVASC"))|(regexm(ovrf2, "PERIPHERAL VASC"))| /// 
	 (regexm(ovrf3, "IHD"))|(regexm(ovrf3, "CVD"))|(regexm(ovrf3, "PVD"))|(regexm(ovrf3, "CARDIOVASC"))|(regexm(ovrf3, "PERIPHERAL VASC"))| ///
	 (regexm(ovrf4, "IHD"))|(regexm(ovrf4, "CVD"))|(regexm(ovrf4, "PVD"))|(regexm(ovrf4, "CARDIOVASC"))|(regexm(ovrf4, "PERIPHERAL VASC")))
** 4 to re-code

gen car_all=1 if  ///
	((regexm(ovrf1, "IHD"))|(regexm(ovrf1, "CVD"))|(regexm(ovrf1, "PVD"))|(regexm(ovrf1, "CARDIOVASC"))|(regexm(ovrf1, "PERIPHERAL VASC"))| ///
	 (regexm(ovrf2, "IHD"))|(regexm(ovrf2, "CVD"))|(regexm(ovrf2, "PVD"))|(regexm(ovrf2, "CARDIOVASC"))|(regexm(ovrf2, "PERIPHERAL VASC"))| /// 
	 (regexm(ovrf3, "IHD"))|(regexm(ovrf3, "CVD"))|(regexm(ovrf3, "PVD"))|(regexm(ovrf3, "CARDIOVASC"))|(regexm(ovrf3, "PERIPHERAL VASC"))| ///
	 (regexm(ovrf4, "IHD"))|(regexm(ovrf4, "CVD"))|(regexm(ovrf4, "PVD"))|(regexm(ovrf4, "CARDIOVASC"))|(regexm(ovrf4, "PERIPHERAL VASC")))
label values car_all pami_
tab car_all ,m //4
tab sd_absstatus car_all ,m //4
tab sd_absstatus sd_pami ,m //12
tab sd_pami car_all ,m
/*     Stata |
  Derived: |
       Any |
  definite |
  previous |        car_all
      AMI? |       Yes          . |     Total
-----------+----------------------+----------
       Yes |         1         11 |        12 
        No |         3        291 |       294 
        99 |         0        194 |       194 
         . |         0        191 |       191 
-----------+----------------------+----------
     Total |         4        687 |       691

*/


** Guideline from Angie to Ashley on whether you count in if the risk factor = 99
/*
	NOTE: assumption used here for all RFs is that if DA finds no documentation 
	on RF then they don't have it, as one assumes that the doctor has had 
	poor documentation rather than poor medical history-taking!!
*/
** So will only exclude from the total reporting on risk factor those times wherein risk factor = 99999 as this indicates the question was not answered by the DA


** JC update: Save these results as a dataset for reporting Table 2.4
save "`datapath'\version03\2-working\riskfactors_stroke_ar" ,replace

preserve
//Prior stroke or TIA
tab tia if sd_absstatus==1 ,m
tab sd_pstroke tia if sd_absstatus==1 ,m
contract sd_pstroke tia if sd_absstatus==1 & (sd_pstroke!=. & sd_pstroke!=99999) | sd_absstatus==1 & (tia!=. & tia!=99999)
sort sd_pstroke tia
gen id=_n
gen rftype_ar=1
gen rf_ar=1
rename _freq number
egen denominator=total(number)
fillmissing denominator
egen tot_pstroke=total(number) if sd_pstroke==1
egen tot_tia=total(number) if tia==1 & sd_pstroke!=1
fillmissing tot_*
gen tot_pstia=tot_pstroke + tot_tia
drop if id!=1
keep id rftype_ar rf_ar tot_pstia denominator
rename tot_pstia number
gen rf_percent=number/denominator*100

save "`datapath'\version03\2-working\riskfactors_stroke" ,replace

clear

//Prior/current IHD/CVD/PVD/AMI
use "`datapath'\version03\2-working\riskfactors_stroke_ar" ,clear
tab sd_pami car_all if sd_absstatus==1 ,m
contract sd_pami car_all if sd_absstatus==1 & (sd_pami!=. & sd_pami!=99999) | sd_absstatus==1 & (car_all!=. & car_all!=99999)
gen id=_n
gen rftype_ar=1
gen rf_ar=2
rename _freq number
egen denominator=total(number)
fillmissing denominator
egen tot_pami=total(number) if sd_pami==1
egen tot_pihd=total(number) if car_all==1 & sd_pami!=1
fillmissing tot_*
gen tot_pamipihd=tot_pami + tot_pihd
drop if id!=1
replace id=2
keep id rftype_ar rf_ar tot_pamipihd denominator
rename tot_pamipihd number
gen rf_percent=number/denominator*100
append using "`datapath'\version03\2-working\riskfactors_stroke"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace

clear

//Hypertension
use "`datapath'\version03\2-working\riskfactors_stroke_ar" ,clear
tab htn if sd_absstatus==1 ,m
contract htn if sd_absstatus==1 & htn!=. & htn!=99999
gen id=_n
gen rftype_ar=2
gen rf_ar=3
rename _freq number
egen denominator=total(number)
drop if htn!=1
drop htn
replace id=3
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_stroke"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace

clear

//Diabetes
use "`datapath'\version03\2-working\riskfactors_stroke_ar" ,clear
tab diab if sd_absstatus==1 ,m
contract diab if sd_absstatus==1 & diab!=. & diab!=99999
gen id=_n
gen rftype_ar=2
gen rf_ar=4
rename _freq number
egen denominator=total(number)
drop if diab!=1
drop diab
replace id=4
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_stroke"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace

clear


//Alcohol use
use "`datapath'\version03\2-working\riskfactors_stroke_ar" ,clear
tab alco if sd_absstatus==1 ,m
contract alco if sd_absstatus==1 & alco!=. & alco!=99999
gen id=_n
gen rftype_ar=3
gen rf_ar=5
rename _freq number
egen denominator=total(number)
drop if alco!=1
drop alco
replace id=5
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_stroke"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace

clear

//Smoking
use "`datapath'\version03\2-working\riskfactors_stroke_ar" ,clear
tab smoker if sd_absstatus==1 ,m
contract smoker if sd_absstatus==1 & smoker!=. & smoker!=99999
gen id=_n
gen rftype_ar=3
gen rf_ar=6
rename _freq number
egen denominator=total(number)
drop if smoker!=1
drop smoker
replace id=6
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_stroke"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace

clear

//Family history
use "`datapath'\version03\2-working\riskfactors_stroke_ar" ,clear
tab famstroke if sd_absstatus==1 ,m
contract famstroke if sd_absstatus==1 & famstroke!=. & famstroke!=99999
gen id=_n
gen rftype_ar=4
gen rf_ar=7
rename _freq number
egen denominator=total(number)
drop if famstroke!=1
drop famstroke
replace id=7
gen rf_percent=number/denominator*100

append using "`datapath'\version03\2-working\riskfactors_stroke"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace


** format
replace rf_percent=round(rf_percent,1.0)

order id rftype_ar rf_ar number rf_percent denominator

label define rftype_ar_lab 1 "Prior CVD event/disease" 2 "Current co-morbidity" 3 "Lifestyle-related" 4 "Family history of stroke" ,modify
label values rftype_ar rftype_ar_lab
label var rftype_ar "Risk factor type"

label define rf_ar_lab 1 "Prior stroke or TIA" 2 "Prior/current IHD/CVD/PVD/acute MI" 3 "Hypertension" 4 "Diabetes" 5 "Alcohol use" 6 "Smoking" 7 "Mother, father or sibling" ,modify
label values rf_ar rf_ar_lab
label var rf_ar "Risk factor"

sort rf_ar

** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\riskfactors_stroke_ar.dta"
save "`datapath'\version03\2-working\riskfactors_stroke" ,replace
restore
