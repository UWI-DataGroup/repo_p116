** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5l_analysis CFRs_heart.do
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
    log using "`logpath'\5l_analysis CFRs_heart.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467


*****************************
** Number of Registrations **
*****************************
count if sd_eyear==2021 //467
//Since this dofile only contains 2021 data I reuse the code from 5b_analysis summ_heart.do but if previous sd_eyears was in dataset then I would reuse the method from 2020 annual report dofile (1.3_heart_cvd_analysis.do) which is the disabled code below each category
/*
** Number of BNR Regsitrations by sd_eyear
** 467 BNR Reg for 2021
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
            Admitted to hospital Ward |        159       34.05       34.05
                     Seen only in A&E |         42        8.99       43.04
Unknown if admitted to hospital (DCO) |        266       56.96      100.00
--------------------------------------+-----------------------------------
                                Total |        467      100.00
*/

** A&E + Ward
count if sd_admstatus!=3 & sd_admstatus!=4 //201

** Ward admission only
count if sd_admstatus==1 //159

/*
** Number of hospital cases
** 201 for 2021
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
    Full abstraction |        185       39.61       39.61
 Partial abstraction |         16        3.43       43.04
No abstraction (DCO) |        266       56.96      100.00
---------------------+-----------------------------------
               Total |        467      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 //185
count if vstatus==2 & sd_absstatus==1 //62
dis (62/185) * 100 //33.513514

/*
** Number of cases with Full information
** 185 abstatracted cases
tab sd_absstatus sd_eyear, m
*/

/*
** In hospital Case Fatality Rate
** 62 died in hospital in 2021
** 62/185
tab vstatus sd_eyear if sd_absstatus==1 ,m
dis 62/185
*/


***************************
** Total hospital deaths **
**     + proportions  	 **
***************************
** A&E + Ward (hospital admissions)
count if sd_admstatus!=3 & sd_admstatus!=4 //201
** A&E + Ward (hospital deaths)
count if sd_admstatus!=3 & sd_admstatus!=4 & vstatus==2 //62
dis (62/201) * 100 //30.845771

** Ward admission only (hospital admissions)
count if sd_admstatus==1 //159
** Ward admission only (hospital deaths)
count if sd_admstatus==1 & vstatus==2 //27
dis (27/159) * 100 //16.981132

/*
**Total hospital Deaths
**62 for 2021 (A&E + Ward)
**27 for 2021 (Ward)
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
    Full abstraction |        185       39.61       39.61
 Partial abstraction |         16        3.43       43.04
No abstraction (DCO) |        266       56.96      100.00
---------------------+-----------------------------------
               Total |        467      100.00
*/

** Fully abstracted cases
count if sd_absstatus==1 //185
count if f1vstatus==2 & sd_absstatus==1 //66
dis (66/185) * 100 //35.675676

/*
**Case Fatality Rate at 28 day
** 66/185
tab f1vstatus sd_eyear if sd_absstatus==1
tab sd_absstatus sd_eyear,miss
dis 66/185
*/

** Save these results as a dataset for reporting Table 1.5
preserve
** Registrations + Hospital Admissions
save "`datapath'\version03\2-working\mort_heart_ar" ,replace
contract sd_admstatus sd_eyear
rename _freq number
egen number_total=total(number) if sd_eyear==2021
drop if sd_admstatus==3
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
gen mort_heart_ar=1
replace mort_heart_ar=2 if id==2
replace mort_heart_ar=3 if id==3
drop id
order mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace
clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

** Cases with full information
contract sd_absstatus
rename _freq number
drop if sd_absstatus!=1
drop sd_absstatus
gen mort_heart_ar=4
order mort_heart_ar
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace
clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

** In-hospital CFR with %
contract vstatus if sd_absstatus==1
rename _freq number
egen number_total=total(number)
drop if vstatus!=2
drop vstatus
gen cfr_percent=number/number_total*100
replace cfr_percent=round(cfr_percent,1.0)
drop number_total
gen mort_heart_ar=5
order mort_heart_ar
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace

clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

** Hospital deaths with %
contract vstatus sd_admstatus if sd_admstatus!=3
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
gen mort_heart_ar=6 if id==1
replace mort_heart_ar=7 if id==2
order mort_heart_ar
drop id
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar

save "`datapath'\version03\2-working\mort_heart" ,replace

clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

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
gen mort_heart_ar=8
order mort_heart_ar
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar

save "`datapath'\version03\2-working\outcomes_heart" ,replace //for in-hospital outcomes flowchart need some of these stats

tostring number ,replace
tostring number_total ,replace
replace number=number_total if mort_heart_ar==1
tostring number_total_aeward ,replace
replace number=number_total_aeward if mort_heart_ar==2
tostring number_total_ward ,replace
replace number=number_total_ward if mort_heart_ar==3
tostring cfr_percent ,replace
replace number=number+" "+"("+cfr_percent+"%)" if mort_heart_ar==5
tostring number_aeward ,replace
tostring mort_percent_aeward ,replace
replace number=number_aeward+" "+"("+mort_percent_aeward+"%)" if mort_heart_ar==6
tostring number_ward ,replace
tostring mort_percent_ward ,replace
replace number=number_ward+" "+"("+mort_percent_ward+"%)" if mort_heart_ar==7
tostring cfr_28d_percent ,replace
replace number=cfr_28d_percent+"%" if mort_heart_ar==8

keep mort_heart_ar number
sort mort_heart_ar


label define mort_heart_ar_lab 1 "Number of BNR Registrations" 2 "Number of hospitalised cases (A&E + WARD)" 3 "Number of hospitalised cases (WARD)" ///
							   4 "Number of cases with full information" 5 "In-hospital CFR (Clinical),n(%)" ///
							   6 "Total hospitalised deaths (A&E + WARD),n(%)" 7 "Total hospitalised deaths (WARD),n(%)" ///
							   8 "CFR at 28 days(%)" ,modify
label values mort_heart_ar mort_heart_ar_lab
label var mort_heart_ar "Moratlity Stats Category"

save "`datapath'\version03\2-working\mort_heart" ,replace
restore



*************************************
** FIGURE 1.5 MI OUTCOME FLOWCHART **
*************************************
** Check for all cases admitted to QEH 
** I'll use A&E + WARD amount as most likely NS will ultimately use that for the annual report as it's more comparable with other years
tab sd_admstatus ,m //201

** Check for cases that were fully abstracted
tab sd_absstatus ,m //185

** Check for vital status at discharge of the cases that were fully abstracted
tab vstatus if sd_absstatus==1 ,m //123 alive; 62 died in hospital; none with unk outcome

** Check for DCOs wherein place of death was QEH
tab dd_pod if sd_casetype==2 ,m //32 QEH deaths

** Check for whether the DCOs with place of death as QEH had a post mortem
tab dd_certtype if sd_casetype==2 & dd_pod==1 ,m //31 no PM; 1 had PM


** Save these results as a dataset for reporting Figure 1.5
preserve
** Hospital admissions + Full abstractions
use "`datapath'\version03\2-working\outcomes_heart" ,clear
keep if mort_heart_ar==2|mort_heart_ar==4
replace number=number_total_aeward if mort_heart_ar==2
keep mort_heart_ar number
rename mort_heart_ar outcomes_heart_ar
gen id=_n
drop outcomes_heart_ar
order id number

save "`datapath'\version03\2-working\outcomes_heart" ,replace
clear

** Vital Status at discharge of full abstractions
use "`datapath'\version03\2-working\mort_heart_ar" ,clear 
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

append using "`datapath'\version03\2-working\outcomes_heart"
sort id
save "`datapath'\version03\2-working\outcomes_heart" ,replace
clear


** Post mortem status
use "`datapath'\version03\2-working\mort_heart_ar" ,clear

tab dd_certtype if sd_casetype==2 & dd_pod==1 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
egen tot=total(foo)
egen nopm=total(foo) if id==1|id==3
fillmissing nopm
rename foo number
order id tot number nopm
replace number=. if id==1
replace nopm=. if id==1
replace tot=. if id==2
replace nopm=. if id==2
replace tot=. if id==3
replace number=. if id==3
replace id=5 if id==1
replace id=6 if id==2
replace id=7 if id==3

append using "`datapath'\version03\2-working\outcomes_heart"
sort id
rename id outcomes_heart_ar

replace number=tot if outcomes_heart_ar==5
replace number=nopm if outcomes_heart_ar==7

keep outcomes_heart_ar number

label define outcomes_heart_ar_lab 1 "Admitted to QEH" 2 "Data abstracted by BNR team" 3 "Died in hospital" ///
								   4 "Discharged alive"5 "Death record only (place of death QEH)" 6 "Post mortem conducted" ///
								   7 "No Post Mortem" ,modify
label values outcomes_heart_ar outcomes_heart_ar_lab
label var outcomes_heart_ar "In-hospital Outcomes Stats Category"

erase "`datapath'\version03\2-working\mort_heart_ar.dta"
save "`datapath'\version03\2-working\outcomes_heart" ,replace

restore


** Since this dofile only contains 2021 data I reused the code from 5b_analysis summ_heart.do but if previous years were in dataset then I would reuse the method from 2020 annual report dofile (1.3_heart_cvd_analysis.do) which is the disabled code below. I've kept it in for reference if other years are to be added in
/*
** JC update: Save these results as a dataset for reporting Table 1.5
preserve
save "`datapath'\version03\2-working\mort_heart_ar" ,replace

contract hosp year if year>2010
rename _freq number
gsort -hosp
gen number_total=sum(number) if year==2011
replace number_total=sum(number) if year==2012
replace number_total=sum(number) if year==2013
replace number_total=sum(number) if year==2014
replace number_total=sum(number) if year==2015
replace number_total=sum(number) if year==2016
replace number_total=sum(number) if year==2017
replace number_total=sum(number) if year==2018
replace number_total=sum(number) if year==2019
replace number_total=sum(number) if year==2020
drop if hosp!=1
drop hosp
sort year
gen id=_n
order id year number number_total
reshape wide number number_total, i(id)  j(year)
fillmissing number*
gen mort_heart_ar=1
rename number2011 year_2011
rename number2012 year_2012
rename number2013 year_2013
rename number2014 year_2014
rename number2015 year_2015
rename number2016 year_2016
rename number2017 year_2017
rename number2018 year_2018
rename number2019 year_2019
rename number2020 year_2020
replace year_2011=number_total2011 if id==1
replace year_2012=number_total2012 if id==1
replace year_2013=number_total2013 if id==1
replace year_2014=number_total2014 if id==1
replace year_2015=number_total2015 if id==1
replace year_2016=number_total2016 if id==1
replace year_2017=number_total2017 if id==1
replace year_2018=number_total2018 if id==1
replace year_2019=number_total2019 if id==1
replace year_2020=number_total2020 if id==1
drop number_total*
drop if id>2
replace mort_heart_ar=2 if id==2
drop id
order mort_heart_ar year*
save "`datapath'\version03\2-working\mort_heart" ,replace
clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

contract abstracted year if year>2010
rename _freq number
drop if abstracted!=1
sort year
drop abstracted
gen id=_n
reshape wide number , i(id)  j(year)
collapse number*
rename number2011 year_2011
rename number2012 year_2012
rename number2013 year_2013
rename number2014 year_2014
rename number2015 year_2015
rename number2016 year_2016
rename number2017 year_2017
rename number2018 year_2018
rename number2019 year_2019
rename number2020 year_2020
gen mort_heart_ar=3
order mort_heart_ar year*
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace
clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

contract prehosp_d year if abstracted==1
drop if prehosp_d!=2
drop if year<2011
gen id=_n
rename _freq number
reshape wide number , i(id)  j(year)
collapse number*
gen id=_n
rename number2011 year_2011
rename number2012 year_2012
rename number2013 year_2013
rename number2014 year_2014
rename number2015 year_2015
rename number2016 year_2016
rename number2017 year_2017
rename number2018 year_2018
rename number2019 year_2019
rename number2020 year_2020
gen mort_heart_ar=4
drop id
order mort_heart_ar year*
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace

gen cfr_percent_2011=year_2011[4]/year_2011[3]*100
replace cfr_percent_2011=round(cfr_percent_2011,1.0)
gen cfr_percent_2012=year_2012[4]/year_2012[3]*100
replace cfr_percent_2012=round(cfr_percent_2012,1.0)
gen cfr_percent_2013=year_2013[4]/year_2013[3]*100
replace cfr_percent_2013=round(cfr_percent_2013,1.0)
gen cfr_percent_2014=year_2014[4]/year_2014[3]*100
replace cfr_percent_2014=round(cfr_percent_2014,1.0)
gen cfr_percent_2015=year_2015[4]/year_2015[3]*100
replace cfr_percent_2015=round(cfr_percent_2015,1.0)
gen cfr_percent_2016=year_2016[4]/year_2016[3]*100
replace cfr_percent_2016=round(cfr_percent_2016,1.0)
gen cfr_percent_2017=year_2017[4]/year_2017[3]*100
replace cfr_percent_2017=round(cfr_percent_2017,1.0)
gen cfr_percent_2018=year_2018[4]/year_2018[3]*100
replace cfr_percent_2018=round(cfr_percent_2018,1.0)
gen cfr_percent_2019=year_2019[4]/year_2019[3]*100
replace cfr_percent_2019=round(cfr_percent_2019,1.0)
gen cfr_percent_2020=year_2020[4]/year_2020[3]*100
replace cfr_percent_2020=round(cfr_percent_2020,1.0)

drop year_*
collapse mort_heart_ar cfr*
replace mort_heart_ar=5
rename cfr_percent_2011 year_2011
rename cfr_percent_2012 year_2012
rename cfr_percent_2013 year_2013
rename cfr_percent_2014 year_2014
rename cfr_percent_2015 year_2015
rename cfr_percent_2016 year_2016
rename cfr_percent_2017 year_2017
rename cfr_percent_2018 year_2018
rename cfr_percent_2019 year_2019
rename cfr_percent_2020 year_2020

append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace

clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

tab prehosp_d year if hosp==1

contract prehosp_d year if hosp==1 & year>2010
rename _freq number
drop if prehosp_d!=2
sort year
drop prehosp_d
gen id=_n
reshape wide number , i(id)  j(year)
collapse number*
rename number2011 year_2011
rename number2012 year_2012
rename number2013 year_2013
rename number2014 year_2014
rename number2015 year_2015
rename number2016 year_2016
rename number2017 year_2017
rename number2018 year_2018
rename number2019 year_2019
rename number2020 year_2020
gen mort_heart_ar=6
order mort_heart_ar year*
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace

gen mort_percent_2011=year_2011[6]/year_2011[2]*100
replace mort_percent_2011=round(mort_percent_2011,1.0)
gen mort_percent_2012=year_2012[6]/year_2012[2]*100
replace mort_percent_2012=round(mort_percent_2012,1.0)
gen mort_percent_2013=year_2013[6]/year_2013[2]*100
replace mort_percent_2013=round(mort_percent_2013,1.0)
gen mort_percent_2014=year_2014[6]/year_2014[2]*100
replace mort_percent_2014=round(mort_percent_2014,1.0)
gen mort_percent_2015=year_2015[6]/year_2015[2]*100
replace mort_percent_2015=round(mort_percent_2015,1.0)
gen mort_percent_2016=year_2016[6]/year_2016[2]*100
replace mort_percent_2016=round(mort_percent_2016,1.0)
gen mort_percent_2017=year_2017[6]/year_2017[2]*100
replace mort_percent_2017=round(mort_percent_2017,1.0)
gen mort_percent_2018=year_2018[6]/year_2018[2]*100
replace mort_percent_2018=round(mort_percent_2018,1.0)
gen mort_percent_2019=year_2019[6]/year_2019[2]*100
replace mort_percent_2019=round(mort_percent_2019,1.0)
gen mort_percent_2020=year_2020[6]/year_2020[2]*100
replace mort_percent_2020=round(mort_percent_2020,1.0)

drop year_*
collapse mort*

replace mort_heart_ar=7
rename mort_percent_2011 year_2011
rename mort_percent_2012 year_2012
rename mort_percent_2013 year_2013
rename mort_percent_2014 year_2014
rename mort_percent_2015 year_2015
rename mort_percent_2016 year_2016
rename mort_percent_2017 year_2017
rename mort_percent_2018 year_2018
rename mort_percent_2019 year_2019
rename mort_percent_2020 year_2020

append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace
clear

use "`datapath'\version03\2-working\mort_heart_ar" ,clear

tab f1vstatus year if hosp==1

contract f1vstatus year if hosp==1 & f1vstatus==2 & year>2010

rename _freq number
sort year
drop f1vstatus
gen id=_n
reshape wide number , i(id)  j(year)
collapse number*
rename number2011 year_2011
rename number2012 year_2012
rename number2013 year_2013
rename number2014 year_2014
rename number2015 year_2015
rename number2016 year_2016
rename number2017 year_2017
rename number2018 year_2018
rename number2019 year_2019
rename number2020 year_2020
gen mort_heart_ar=8
order mort_heart_ar year*
append using "`datapath'\version03\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version03\2-working\mort_heart" ,replace

gen cfr_28d_percent_2011=year_2011[8]/year_2011[3]*100
replace cfr_28d_percent_2011=round(cfr_28d_percent_2011,1.0)
gen cfr_28d_percent_2012=year_2012[8]/year_2012[3]*100
replace cfr_28d_percent_2012=round(cfr_28d_percent_2012,1.0)
gen cfr_28d_percent_2013=year_2013[8]/year_2013[3]*100
replace cfr_28d_percent_2013=round(cfr_28d_percent_2013,1.0)
gen cfr_28d_percent_2014=year_2014[8]/year_2014[3]*100
replace cfr_28d_percent_2014=round(cfr_28d_percent_2014,1.0)
gen cfr_28d_percent_2015=year_2015[8]/year_2015[3]*100
replace cfr_28d_percent_2015=round(cfr_28d_percent_2015,1.0)
gen cfr_28d_percent_2016=year_2016[8]/year_2016[3]*100
replace cfr_28d_percent_2016=round(cfr_28d_percent_2016,1.0)
gen cfr_28d_percent_2017=year_2017[8]/year_2017[3]*100
replace cfr_28d_percent_2017=round(cfr_28d_percent_2017,1.0)
gen cfr_28d_percent_2018=year_2018[8]/year_2018[3]*100
replace cfr_28d_percent_2018=round(cfr_28d_percent_2018,1.0)
gen cfr_28d_percent_2019=year_2019[8]/year_2019[3]*100
replace cfr_28d_percent_2019=round(cfr_28d_percent_2019,1.0)
gen cfr_28d_percent_2020=year_2020[8]/year_2020[3]*100
replace cfr_28d_percent_2020=round(cfr_28d_percent_2020,1.0)

drop year_*
collapse mort* cfr*

replace mort_heart_ar=9
rename cfr_28d_percent_2011 year_2011
rename cfr_28d_percent_2012 year_2012
rename cfr_28d_percent_2013 year_2013
rename cfr_28d_percent_2014 year_2014
rename cfr_28d_percent_2015 year_2015
rename cfr_28d_percent_2016 year_2016
rename cfr_28d_percent_2017 year_2017
rename cfr_28d_percent_2018 year_2018
rename cfr_28d_percent_2019 year_2019
rename cfr_28d_percent_2020 year_2020

append using "`datapath'\version03\2-working\mort_heart"
drop if mort_heart_ar==8
replace mort_heart_ar=8 if mort_heart_ar==9
sort mort_heart_ar

save "`datapath'\version03\2-working\outcomes_heart" ,replace //for in-hosp outcomes flowchart need some of these stats

label define mort_heart_ar_lab 1 "Number of BNR Registrations" 2 "Number of hospitalised cases" 3 "Number of cases with full information" ///
							   4 "In-hospital CFR (Clinical)" 5 "In-hospital CFR(%)" 6 "Total hospitalised deaths" 7 "Total hospitalised deaths(%)" ///
							   8 "CFR at 28 days(%)" ,modify
label values mort_heart_ar mort_heart_ar_lab
label var mort_heart_ar "Moratlity Stats Category"

tostring year_2011 ,replace
tostring year_2012 ,replace
tostring year_2013 ,replace
tostring year_2014 ,replace
tostring year_2015 ,replace
tostring year_2016 ,replace
tostring year_2017 ,replace
tostring year_2018 ,replace
tostring year_2019 ,replace
tostring year_2020 ,replace
replace year_2011=year_2011+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2012=year_2012+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2013=year_2013+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2014=year_2014+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2015=year_2015+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2016=year_2016+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2017=year_2017+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2018=year_2018+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2019=year_2019+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8
replace year_2020=year_2020+"%" if mort_heart_ar==5|mort_heart_ar==7|mort_heart_ar==8

save "`datapath'\version03\2-working\mort_heart" ,replace
restore
*/
