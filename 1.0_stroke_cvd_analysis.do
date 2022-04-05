cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.0_stroke_cvd_analysis.do
    //  project:                BNR Stroke
    //  analysts:               Ashley HENRY and Jacqueline CAMPBELL
    //  date first created:     23-Feb-2022
    //  date last modified:     05-Apr-2022
	//  analysis:               Stroke 2020 dataset for Annual Report
    //  algorithm task          Performing Stroke 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to calculate summary statistics and Crude Incidence Rates by year
    //  methods:1:              Run analysis on cleaned 2009-2020 BNR-S data.
	//  version:                Version01 for weeks 01-52
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
    log using "`logpath'\1.0_stroke_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              1a: Numbers (registration & events & patients)
 *              1b: Rate per populate
 *              1c: Crude Incidence Rates by Sex
************************************************************************
** Load the dataset  

use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean" ,clear

count
** 7649 as of 23-Feb-2022

** JC added sex check below on 04apr2022 as heart had a case missing sex
tab sex ,m //none missing

** JC added age check below on 05apr2022 as age+gender stratified graphs showed 692 cases for 2020 instead of 700
tab age ,m //12 missing - 2 from 2016; 2 from 2017 and 8 from 2020.
//no first or last names for 2016 and 2017 cases but will correct 2020 cases as these have names
//Corrected missing age and age_10 variables for 2020 cases using the field in CF form [Age at CF (DA to enter)] from BNRCVD_CORE REDCap db - these were missing DOB
replace age=69 if anon_pid==5589
replace age=87 if anon_pid==5703
replace age=61 if anon_pid==6266
replace age=60 if anon_pid==6331
replace age=52 if anon_pid==6556
replace age=79 if anon_pid==6892
replace age=54 if anon_pid==6981
replace age=65 if anon_pid==7535

replace age_10=7 if anon_pid==5589
replace age_10=9 if anon_pid==5703
replace age_10=6 if anon_pid==6266
replace age_10=6 if anon_pid==6331
replace age_10=5 if anon_pid==6556
replace age_10=8 if anon_pid==6892
replace age_10=5 if anon_pid==6981
replace age_10=7 if anon_pid==7535

** JC 04apr2022: This stroke dataset is missing PID variable [anon_pid] in 2,140 cases so need to create it.
sort anon_pid
order anon_pid
replace anon_pid=_n if anon_pid==.
save "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean", replace

***************************************************************************
** Table 1.1 AR: # of - Registrations; Hosp Admissions; DCOs; Rate per pop
**************************************************************************
**Number of registrations:
count if year==2020
**700
tab sex if year==2020
** F- 365 M-335

**Number of hospital admissions:
tab hosp if year==2020
**632 seen

**% deceased @ 28day
tab f1vstatus if abstracted==1 & year==2020
**35.7%

**% who died
tab abstracted if year==2020
**19.6%
tab prehosp if year==2020

** DCO Cases
tab abstracted if year==2020
**137

****************************
** Table 1.1 : LENGTH OF STAY (los) 
****************************
** AVERAGE number of days in hospital
** los = date of discharge - date of admission (already defined)
label var los "Length of hospital stay"
** Median stay for formal "time to event" analyses (ie. survival analyses)
** Interquartile Range (IQR) (p25 - p75)
** Range (min - max)
replace los=1 if los==0

** Mean stay for calculation of costs (Arithmetic Mean with 95% CI)
** NOTE: this outoput also reports the "geometric mean". This is useful
** as the antilog of log(los). A reasonable alternative to median.
ameans los if (dos!=. & doh!=. & los!=.)& year==2019
ameans los if (dos!=. & doh!=. & los!=.)& year==2020

** Below code runs in Stata 16 (used by AH) but not in Stata 17 (used by JC)
/*
**2020
preserve
gen k=1
drop if year!=2020
 //drop if (dos>doh)
drop if abstracted!=1
drop if dos==. 
drop if doh==.
drop if los==.
drop if los>200

count
table k, c(p50 los p25 los p75 los min los max los) 
** Med Los - 9 ( 1 - 148)
restore
*/

preserve
gen k=1
drop if year!=2020
 //drop if (dos>doh)
drop if abstracted!=1
drop if dos==. 
drop if doh==.
drop if los==.
drop if los>200 //1 deleted

count //404

table k, stat(q2 los) stat(min los) stat(max los)
** Med Los - 9 ( 1 - 148)
** Now save the p50, min and max for Table 1.1
sum los
sum los ,detail
gen medianlos_s=r(p50)
gen range_lower_s=r(min)
gen range_upper_s=r(max)

collapse medianlos_s range_lower_s range_upper_s
order medianlos_s range_lower_s range_upper_s
save "`datapath'\version02\2-working\los_stroke_all" ,replace
restore


********* FES los*****************
** Below code runs in Stata 16 (used by AH) but not in Stata 17 (used by JC)
/*
**2020
preserve
drop if year!=2020
count if np==1 // 226
drop if np!=1
drop if dos>doh
drop if los>200

gen k=1
table k, c(p50 los p25 los p75 los min los max los)
** 7 day median
** min of 1-148 

ameans los if los!=.

restore 

**2019
preserve
drop if year!=2019
count if np==1 // 195
drop if np!=1
drop if dos>doh
drop if los>200
gen k=1
table k, c(p50 los p25 los p75 los min los max los)
** 9 day median
** min of 1-149 

ameans los if los!=.

restore 
*/

preserve
drop if year!=2020
count if np==1 // 226
** JC 04apr2022 above count = 264
drop if np!=1
drop if dos>doh
drop if los>200 //3 deleted

ameans los if los!=.

count //256

gen k=1
table k, stat(q2 los) stat(min los) stat(max los)
** 7 day median
** min of 1-148 
** Now save the p50, min and max for Table 1.1
sum los
sum los ,detail
gen medianlos_fes=r(p50)
gen range_lower_fes=r(min)
gen range_upper_fes=r(max)

collapse medianlos_fes range_lower_fes range_upper_fes
order medianlos_fes range_lower_fes range_upper_fes
save "`datapath'\version02\2-working\los_stroke_fes" ,replace
restore

** JC 04apr2022 - below code not used in 1.4_cvd_results report.do as the results from below repeated in 1.1_stroke_cvd_analaysis.do
stop
*********************** Recreating case variable ****************************
*** The following wa done so that the seperate amounts for each year could be seen ******
** This also assis in being able to do analysis on one year, rather than a combination of all years *****
drop case
** CASE variable
gen case=1 if year==2009
replace case=2 if year==2010
replace case=3 if year==2011
replace case=4 if year==2012
replace case=5 if year==2013
replace case=6 if year==2014
replace case=7 if year==2015
replace case=8 if year==2016
replace case=9 if year==2017
replace case=10 if year==2018
replace case=11 if year==2019
replace case=12 if year==2020

label defin case_lab 1 "No. of cases in 2009" 2"No. of cases in 2010" 3"No. of cases in 2011" 4"No. of cases in 2012" ///
                    5 "No. of cases in 2013" 6"No. of cases in 2014" 7"No. of cases in 2015" 8"No. of cases in 2016" ///
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11 "No. of cases in 2019" 12 "No. of cases in 2020" , modify
label values case case_lab

label var case "Stroke event / participant"


label define month_lab 1 "January" 2"February" 3"March" 4"April" ///
                          5"May" 6"June" 7"July" 8"August" ///
                         9"September" 10"October" 11"November" 12"December" , modify
label values month month_lab



**********************
* INCIDENCE RATES*
**********************

** First, merge dataset with Barbados population file - present age stratification in 10-year age bands MATCHING THOSE OF UNWPP

merge m:m sex age_10 using "C:\Users\CVD 03\Desktop\BNR_data\DM\data_analysis\2019\stroke\weeks01-52\versions\version01\data\population\pop_wpp_2010-2020-10.dta"

** 7336 matched 313 not matched

*************************************************
*  Crude IR, all strokes with
*  SE and 95% Confidence Interval
*************************************************

******************** 2010 CRUDE INCIDENCE RATE  by SEX****************************
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2010= 1 if case==2
replace case2010 = 0 if case2010==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2010 (mean) pop_wpp2010 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2010 pop_wpp2010 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2010 fpop_wpp2010
	gen pop_wpp2010 = fpop_wpp2010 * pfu
	
	gen ir = (case2010 / pop_wpp2010) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2010^(1/2)) / pop_wpp2010) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2010, (0.05/2))) / pop_wpp2010 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2010+1), (1-(0.05/2)))) / pop_wpp2010 ) * (10^5)

	* Display the results
	label var pop_wpp2010 "P-Y"
	label var case2010 "Cases2010"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2010 pop_wpp2010 ir se lower upper , noobs table
	
restore


******************** 2011 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2011= 1 if case==3
replace case2011 = 0 if case2011==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2011 (mean) pop_wpp2011 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2011 pop_wpp2011 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2011 fpop_wpp2011
	gen pop_wpp2011 = fpop_wpp2011 * pfu
	
	gen ir = (case2011 / pop_wpp2011) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2011^(1/2)) / pop_wpp2011) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2011, (0.05/2))) / pop_wpp2011 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2011+1), (1-(0.05/2)))) / pop_wpp2011 ) * (10^5)

	* Display the results
	label var pop_wpp2011 "P-Y"
	label var case2011 "Cases2011"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2011 pop_wpp2011 ir se lower upper , noobs table
	
restore

******************** 2012 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2012= 1 if case==4
replace case2012 = 0 if case2012==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2012 (mean) pop_wpp2012 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2012 pop_wpp2012 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2012 fpop_wpp2012
	gen pop_wpp2012 = fpop_wpp2012 * pfu
	
	gen ir = (case2012 / pop_wpp2012) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2012^(1/2)) / pop_wpp2012) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2012, (0.05/2))) / pop_wpp2012 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2012+1), (1-(0.05/2)))) / pop_wpp2012 ) * (10^5)

	* Display the results
	label var pop_wpp2012 "P-Y"
	label var case2012 "Cases2012"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2012 pop_wpp2012 ir se lower upper , noobs table
	
restore

******************** 2013 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2013= 1 if case==5
replace case2013 = 0 if case2013==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2013 (mean) pop_wpp2013 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2013 pop_wpp2013 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2013 fpop_wpp2013
	gen pop_wpp2013 = fpop_wpp2013 * pfu
	
	gen ir = (case2013 / pop_wpp2013) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2013^(1/2)) / pop_wpp2013) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2013, (0.05/2))) / pop_wpp2013 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2013+1), (1-(0.05/2)))) / pop_wpp2013 ) * (10^5)

	* Display the results
	label var pop_wpp2013 "P-Y"
	label var case2013 "Cases2013"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2013 pop_wpp2013 ir se lower upper , noobs table
	
restore


******************** 2014 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2014= 1 if case==6
replace case2014 = 0 if case2014==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2014 (mean) pop_wpp2014 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2014 pop_wpp2014 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2014 fpop_wpp2014
	gen pop_wpp2014 = fpop_wpp2014 * pfu
	
	gen ir = (case2014 / pop_wpp2014) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2014^(1/2)) / pop_wpp2014) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2014, (0.05/2))) / pop_wpp2014 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2014+1), (1-(0.05/2)))) / pop_wpp2014 ) * (10^5)

	* Display the results
	label var pop_wpp2014 "P-Y"
	label var case2014 "Cases2014"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2014 pop_wpp2014 ir se lower upper , noobs table
	
restore

******************** 2015 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2015= 1 if case==7
replace case2015 = 0 if case2015==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2015 (mean) pop_wpp2015 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2015 pop_wpp2015 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2015 fpop_wpp2015
	gen pop_wpp2015 = fpop_wpp2015 * pfu
	
	gen ir = (case2015 / pop_wpp2015) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2015^(1/2)) / pop_wpp2015) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2015, (0.05/2))) / pop_wpp2015 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2015+1), (1-(0.05/2)))) / pop_wpp2015 ) * (10^5)

	* Display the results
	label var pop_wpp2015 "P-Y"
	label var case2015 "Cases2015"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2015 pop_wpp2015 ir se lower upper , noobs table
	
restore


******************** 2016 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2016= 1 if case==8
replace case2016 = 0 if case2016==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2016 (mean) pop_wpp2016 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2016 pop_wpp2016 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2016 fpop_wpp2016
	gen pop_wpp2016 = fpop_wpp2016 * pfu
	
	gen ir = (case2016 / pop_wpp2016) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2016^(1/2)) / pop_wpp2016) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2016, (0.05/2))) / pop_wpp2016 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2016+1), (1-(0.05/2)))) / pop_wpp2016 ) * (10^5)

	* Display the results
	label var pop_wpp2016 "P-Y"
	label var case2016 "Cases2016"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2016 pop_wpp2016 ir se lower upper , noobs table
	
restore

******************** 2017 CRUDE INCIDENCE RATE  by SEX****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2017= 1 if case==9
replace case2017 = 0 if case2017==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2017 (mean) pop_wpp2017 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2017 pop_wpp2017 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2017 fpop_wpp2017
	gen pop_wpp2017 = fpop_wpp2017 * pfu
	
	gen ir = (case2017 / pop_wpp2017) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2017^(1/2)) / pop_wpp2017) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2017, (0.05/2))) / pop_wpp2017 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2017+1), (1-(0.05/2)))) / pop_wpp2017 ) * (10^5)

	* Display the results
	label var pop_wpp2017 "P-Y"
	label var case2017 "Cases2017"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2017 pop_wpp2017 ir se lower upper , noobs table
	
restore

******************** 2018 CRUDE INCIDENCE RATE ****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2018= 1 if case==10
replace case2018 = 0 if case2018==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2018 (mean) pop_wpp2018 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2018 pop_wpp2018 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2018 fpop_wpp2018
	gen pop_wpp2018 = fpop_wpp2018 * pfu
	
	gen ir = (case2018 / pop_wpp2018) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2018^(1/2)) / pop_wpp2018) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2018, (0.05/2))) / pop_wpp2018 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2018+1), (1-(0.05/2)))) / pop_wpp2018 ) * (10^5)

	* Display the results
	label var pop_wpp2018 "P-Y"
	label var case2018 "Cases2018"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2018 pop_wpp2018 ir se lower upper , noobs table
	
restore


******************** 2019 CRUDE INCIDENCE RATE ****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2019= 1 if case==11
replace case2019 = 0 if case2019==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2019 (mean) pop_wpp2019 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2019 pop_wpp2019 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2019 fpop_wpp2019
	gen pop_wpp2019 = fpop_wpp2019 * pfu
	
	gen ir = (case2019 / pop_wpp2019) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2019^(1/2)) / pop_wpp2019) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2019, (0.05/2))) / pop_wpp2019 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2019+1), (1-(0.05/2)))) / pop_wpp2019 ) * (10^5)

	* Display the results
	label var pop_wpp2019 "P-Y"
	label var case2019 "Cases2019"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2019 pop_wpp2019 ir se lower upper , noobs table
	restore
	
	

******************** 2020 CRUDE INCIDENCE RATE ****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2020= 1 if case==12
replace case2020 = 0 if case2020==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen stroke = 1
	label define crude 1 "stroke events" ,modify
	label values stroke crude

	collapse (sum) case2020 (mean) pop_wpp2020 , by(pfu stroke sex age_10 sex)
	collapse (sum) case2020 pop_wpp2020 , by(pfu stroke sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2020 fpop_wpp2020
	gen pop_wpp2020 = fpop_wpp2020 * pfu
	
	gen ir = (case2020 / pop_wpp2020) * (10^5)
	label var ir "CRUDE INCIDENCE RATE "

	* Standard Error
	gen se = ( (case2020^(1/2)) / pop_wpp2020) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2020, (0.05/2))) / pop_wpp2020 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2020+1), (1-(0.05/2)))) / pop_wpp2020 ) * (10^5)

	* Display the results
	label var pop_wpp2020 "P-Y"
	label var case2020 "Cases2020"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2020 pop_wpp2020 ir se lower upper , noobs table
	
	restore