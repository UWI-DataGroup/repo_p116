** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5m_analysis CFRs_stroke.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-MAR-2023
    // 	date last modified      17-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               (1) To analyse data relating to case fatality rates at discharge and 28 days
	//							(2) To analyse data relating to in-hospital outcomes
    //  methods                 Reviewing and categorizing variables needed for the above rates and stats
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
    log using "`logpath'\5m_analysis CFRs_stroke.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified STROKE 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //691


*****************************
** Number of Registrations **
*****************************
count if sd_eyear==2021 //691
//Since this dofile only contains 2021 data I reuse the code from 5c_analysis summ_stroke.do but if previous sd_eyears was in dataset then I would reuse the method from 2020 annual report dofile (1.3_stroke_cvd_analysis.do) which is the disabled code below each category
/*
** Number of BNR Regsitrations by sd_eyear
** 691 BNR Reg for 2021
bysort sd_eyear :tab sd_etype
*/

*************************
** Hospital Admissions **
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

** Ward admission only
count if sd_admstatus==1 //429

/*
** Number of hospital cases
** 528 for 2021
tab sd_admstatus sd_eyear
*/

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

** Fully abstracted cases
count if sd_absstatus==1 //500
count if vstatus==2 & sd_absstatus==1 //151
dis (151/500) * 100 //30.2

/*
** Number of cases with Full information
** 500 abstatracted cases
tab sd_absstatus sd_eyear, m
*/

/*
** In hospital Case Fatality Rate
** 151 died in hospital in 2021
** 151/500
tab vstatus sd_eyear if sd_absstatus==1 ,m
dis 151/500
*/


***************************
** Total hospital deaths **
**     + proportions  	 **
***************************
** A&E + Ward (hospital admissions)
count if sd_admstatus!=3 & sd_admstatus!=4 //528
** A&E + Ward (hospital deaths)
count if sd_admstatus!=3 & sd_admstatus!=4 & vstatus==2 //151
dis (151/528) * 100 //28.598485

** Ward admission only (hospital admissions)
count if sd_admstatus==1 //429
** Ward admission only (hospital deaths)
count if sd_admstatus==1 & vstatus==2 //122
dis (122/429) * 100 //28.438228

/*
**Total hospital Deaths
**151 for 2021 (A&E + Ward)
**122 for 2021 (Ward)
tab vstatus if sd_admstatus!=3 & sd_admstatus!=4 & sd_eyear==2021 ,m
tab vstatus sd_eyear if sd_admstatus!=3 & sd_admstatus!=4 (A&E + Ward)
tab vstatus sd_eyear if sd_admstatus==1 (Ward)
bysort sd_eyear :tab sd_admstatus
bysort sd_eyear :tab sd_admstatus vstatus
*/


**********************
**  CFR at 28 days  **
**  + proportions   **
**********************
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

** Fully abstracted cases
count if sd_absstatus==1 //500
count if f1vstatus==2 & sd_absstatus==1 //142
dis (142/500) * 100 //28.4

/*
**Case Fatality Rate at 28 day
** 142/500
tab f1vstatus sd_eyear if sd_absstatus==1
tab sd_absstatus sd_eyear,miss
dis 142/500
*/

** Save these results as a dataset for reporting Table 1.5
preserve
** Registrations + Hospital Admissions
save "`datapath'\version03\2-working\mort_stroke_ar" ,replace
contract sd_admstatus sd_eyear
rename _freq number
egen number_total=total(number) if sd_eyear==2021
drop if sd_admstatus==3|sd_admstatus==4
egen number_total_aeward=total(number)
gen number_total_ward=number if sd_admstatus==1
replace number_total=. if sd_admstatus==1
replace number_total_aeward=. if sd_admstatus==2
replace number_total_ward=. if sd_admstatus==2
drop number sd_admstatus sd_eyear
sort number_total
gen id=_n
expand=2 if id==2, gen (dupobs)
replace id=3 if dupobs==1
drop dupobs
replace number_total_aeward=. if id==3
replace number_total_ward=. if id==2
order id number_total number_total_aeward number_total_ward
gen mort_stroke_ar=1
replace mort_stroke_ar=2 if id==2
replace mort_stroke_ar=3 if id==3
drop id
order mort_stroke_ar

save "`datapath'\version03\2-working\mort_stroke" ,replace
clear

use "`datapath'\version03\2-working\mort_stroke_ar" ,clear

** Cases with full information
contract sd_absstatus
rename _freq number
drop if sd_absstatus!=1
drop sd_absstatus
gen mort_stroke_ar=4
order mort_stroke_ar
append using "`datapath'\version03\2-working\mort_stroke"
sort mort_stroke_ar
save "`datapath'\version03\2-working\mort_stroke" ,replace
clear

use "`datapath'\version03\2-working\mort_stroke_ar" ,clear

** In-hospital CFR with %
contract vstatus if sd_absstatus==1
rename _freq number
egen number_total=total(number)
drop if vstatus!=2
drop vstatus
gen cfr_percent=number/number_total*100
replace cfr_percent=round(cfr_percent,1.0)
drop number_total
gen mort_stroke_ar=5
order mort_stroke_ar
append using "`datapath'\version03\2-working\mort_stroke"
sort mort_stroke_ar
save "`datapath'\version03\2-working\mort_stroke" ,replace

clear

use "`datapath'\version03\2-working\mort_stroke_ar" ,clear

** Hospital deaths with %
contract vstatus sd_admstatus if sd_admstatus!=3 & sd_admstatus!=4
rename _freq number
egen number_total_aeward=total(number)
egen number_total_ward=total(number) if sd_admstatus==1
drop if vstatus!=2
replace number_total_aeward=. if sd_admstatus==1
egen number_aeward=total(number)
replace number_aeward=. if sd_admstatus==1
replace number=. if sd_admstatus==2
rename number number_ward
drop vstatus sd_admstatus
order number_aeward number_total_aeward number_ward number_total_ward
gen mort_percent_ward=number_ward/number_total_ward*100
gen mort_percent_aeward=number_aeward/number_total_aeward*100
replace mort_percent_ward=round(mort_percent_ward,1.0)
replace mort_percent_aeward=round(mort_percent_aeward,1.0)
order number_aeward number_total_aeward mort_percent_aeward number_ward number_total_ward mort_percent_ward
gsort -number_aeward
gen id=_n
gen mort_stroke_ar=6 if id==1
replace mort_stroke_ar=7 if id==2
order mort_stroke_ar
drop id
append using "`datapath'\version03\2-working\mort_stroke"
sort mort_stroke_ar

save "`datapath'\version03\2-working\mort_stroke" ,replace

clear

use "`datapath'\version03\2-working\mort_stroke_ar" ,clear

tab f1vstatus sd_eyear if sd_eyear==1

** 28-day CFR (%)
contract f1vstatus if sd_absstatus==1
rename _freq number
egen number_total=total(number)
drop if f1vstatus!=2
drop f1vstatus
gen cfr_28d_percent=number/number_total*100
replace cfr_28d_percent=round(cfr_28d_percent,1.0)
drop number_total
gen mort_stroke_ar=8
order mort_stroke_ar
append using "`datapath'\version03\2-working\mort_stroke"
sort mort_stroke_ar

save "`datapath'\version03\2-working\outcomes_stroke" ,replace //for in-hospital outcomes flowchart need some of these stats

tostring number ,replace
tostring number_total ,replace
replace number=number_total if mort_stroke_ar==1
tostring number_total_aeward ,replace
replace number=number_total_aeward if mort_stroke_ar==2
tostring number_total_ward ,replace
replace number=number_total_ward if mort_stroke_ar==3
tostring cfr_percent ,replace
replace number=number+" "+"("+cfr_percent+"%)" if mort_stroke_ar==5
tostring number_aeward ,replace
tostring mort_percent_aeward ,replace
replace number=number_aeward+" "+"("+mort_percent_aeward+"%)" if mort_stroke_ar==6
tostring number_ward ,replace
tostring mort_percent_ward ,replace
replace number=number_ward+" "+"("+mort_percent_ward+"%)" if mort_stroke_ar==7
tostring cfr_28d_percent ,replace
replace number=cfr_28d_percent+"%" if mort_stroke_ar==8

keep mort_stroke_ar number
sort mort_stroke_ar


label define mort_stroke_ar_lab 1 "Number of BNR Registrations" 2 "Number of hospitalised cases (A&E + WARD)" 3 "Number of hospitalised cases (WARD)" ///
							   4 "Number of cases with full information" 5 "In-hospital CFR (Clinical),n(%)" ///
							   6 "Total hospitalised deaths (A&E + WARD),n(%)" 7 "Total hospitalised deaths (WARD),n(%)" ///
							   8 "CFR at 28 days(%)" ,modify
label values mort_stroke_ar mort_stroke_ar_lab
label var mort_stroke_ar "Moratlity Stats Category"

save "`datapath'\version03\2-working\mort_stroke" ,replace
restore



*************************************
** FIGURE 1.5 MI OUTCOME FLOWCHART **
*************************************
** Check for all cases admitted to QEH 
** I'll use A&E + WARD amount as most likely NS will ultimately use that for the annual report as it's more comparable with other years
tab sd_admstatus ,m //528

** Check for cases that were fully abstracted
tab sd_absstatus ,m //500

** Check for vital status at discharge of the cases that were fully abstracted
tab vstatus if sd_absstatus==1 ,m //349 alive; 151 died in hospital; none with unk outcome

** Check for DCOs wherein place of death was QEH
tab dd_pod if sd_casetype==2 ,m //56 QEH deaths

** Check for whether the DCOs with place of death as QEH had a post mortem
tab dd_certtype if sd_casetype==2 & dd_pod==1 ,m //56 no PM; 0 had PM


** Save these results as a dataset for reporting Figure 1.5
preserve
** Hospital admissions + Full abstractions
use "`datapath'\version03\2-working\outcomes_stroke" ,clear
keep if mort_stroke_ar==2|mort_stroke_ar==4
replace number=number_total_aeward if mort_stroke_ar==2
keep mort_stroke_ar number
rename mort_stroke_ar outcomes_stroke_ar
gen id=_n
drop outcomes_stroke_ar
order id number

save "`datapath'\version03\2-working\outcomes_stroke" ,replace
clear

** Vital Status at discharge of full abstractions
use "`datapath'\version03\2-working\mort_stroke_ar" ,clear 
tab vstatus if sd_absstatus==1 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
replace id=3 if id==1
replace id=4 if id==2
rename foo number
order id number

append using "`datapath'\version03\2-working\outcomes_stroke"
sort id
save "`datapath'\version03\2-working\outcomes_stroke" ,replace
clear


** Post mortem status
use "`datapath'\version03\2-working\mort_stroke_ar" ,clear

tab dd_certtype if sd_casetype==2 & dd_pod==1 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
egen tot=total(foo)
egen nopm=total(foo)
gen number=0
drop foo
order id tot number nopm
expand=2 if id==2, gen (dupobs)
replace id=3 if dupobs==1
drop dupobs
replace number=. if id==1
replace nopm=. if id==1
replace tot=. if id==2
replace nopm=. if id==2
replace tot=. if id==3
replace number=. if id==3
replace id=5 if id==1
replace id=6 if id==2
replace id=7 if id==3

append using "`datapath'\version03\2-working\outcomes_stroke"
sort id
rename id outcomes_stroke_ar

replace number=tot if outcomes_stroke_ar==5
replace number=nopm if outcomes_stroke_ar==7

keep outcomes_stroke_ar number

label define outcomes_stroke_ar_lab 1 "Admitted to QEH" 2 "Data abstracted by BNR team" 3 "Died in hospital" ///
								    4 "Discharged alive"5 "Death record only (place of death QEH)" 6 "Post mortem conducted" ///
								    7 "No Post Mortem" ,modify
label values outcomes_stroke_ar outcomes_stroke_ar_lab
label var outcomes_stroke_ar "In-hospital Outcomes Stats Category"

erase "`datapath'\version03\2-working\mort_stroke_ar.dta"
save "`datapath'\version03\2-working\outcomes_stroke" ,replace

restore

