cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.0_heart_cvd_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY
    //  date first created:     26-Jan-2022
    //  date last modified:     22-Feb-2022
	//  analysis:               Heart 2020 dataset for Annual Report
    //  algorithm task          Performing Heart 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to calculate summary statistics and Crude Incidence Rates by year
    //  methods:1:              Run analysis on cleaned 2009-2020 BNR-H data.
	//  version:                Version01 for weeks 01-52
	//  support:                Natasha Sobers, Jacqueline Campbell and Ian R Hambleton  

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
    log using "`logpath'\1.0_heart_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              1a: Numbers (registration & events & patients)
 *              1b: Rate per populate
 *              1c: Crude Incidence Rates by Sex
 *              1d: Crude Mortality Rates 
 *              1e: In Hospital Outcome - Case Fatality Rates
 *              1f: Case Fatality Rate -Abstracted Cases Only.
************************************************************************
** Load the dataset  
use "`datapath'\version02\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)"

count
** 4794 as of 26-Jan-2022

** JC 17feb2022: Sex updated for 2018 pid that has sex=99 using MedData
replace sex=1 if anon_pid==596 & record_id=="20181197" //1 change

*****************************************************************************Table 1.1 AR: # of - Registrations; Hosp Admissions; DCOs; Rate per pop
**************************************************************************
**Number of registrations:
count if year==2020

**Number of hospital admissions:
tab hosp if year==2020
**338 seen
dis (547/277814) * 100

**% deceased @ 28day
tab f1vstatus if abstracted==1 & year==2020
**27%

**% who died
tab abstracted if year==2020
**47%
tab prehosp if year==2020

** DCO Cases
tab abstracted if year==2020
**256

**Median Legthn of stay in hospital
*****************************************************************
** Median stay for formal "time to event" analyses (ie. survival analyses)
** We present:
** Median (p50)
** Interquartile Range (IQR) (p25 - p75)
** Range (min - max)
** FIRST COMBINE los AND add_los!!
*******************************************************************
replace los=los+add_los if add_los!=.

tab los if record_id!="" & abstracted==1 ,miss
list record_id if los==. & abstracted==1

** Below code runs in Stata 16 (used by AH) but not in Stata 17 (used by JC)
/*
preserve 
drop if year!=2020
gen k=1

table k, c(p50 los p25 los p75 los min los max los)
** med - 5 ( 1 - 145)

** Mean stay for calculation of costs (Arithmetic Mean with 95% CI)
** NOTE: this outoput also reports the "geometric mean". This is useful
** as the antilog of log(los). A reasonable alternative to median.
ameans los if los!=.

restore
*/
preserve 
drop if year!=2020
gen k=1
drop if k!=1

table k, stat(q2 los) stat(min los) stat(max los)
** med - 5 ( 1 - 145)
** Now save the p50, min and max for Table 1.1
sum los
sum los ,detail
gen medianlos=r(p50)
gen range_lower=r(min)
gen range_upper=r(max)

collapse medianlos range_lower range_upper
order medianlos range_lower range_upper
save "`datapath'\version02\2-working\los_heart" ,replace

** Mean stay for calculation of costs (Arithmetic Mean with 95% CI)
** NOTE: this outoput also reports the "geometric mean". This is useful
** as the antilog of log(los). A reasonable alternative to median.
//ameans los if los!=.
restore

*********************NUMBER OF CASES BY YEAR***************
** Figures 1.1 + 1.2 in AR:
***********************************************************
************************************* MERGING POPULATION TO DATASET *************************************
merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2010-2020-10"
** 4147 matches; 100 not matched.


******************************************* Recreate Case ************************************************
** Creating a new case variable to seperate the number of cases by each year.
drop case
** case variable
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
					9 "No. of cases in 2017" 10"No. of cases in 2018" 11"No. of cases in 2019" 12 "No. of cases in 2020" , modify
label values case case_lab

label var case "Acute MI event / participant"



************************************************************************************************************* Figure 1.1 Crude Incidence Rate by Sex
**
******************** 2010 CRUDE INCIDENCE RATE by sex ****************************
** If a full year, use pfu=1

label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2010= 1 if case==2
replace case2010 = 0 if case2010==.

**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2010 (mean) pop_wpp2010 , by(pfu heart age_10 sex)
	collapse (sum) case2010 pop_wpp2010 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2010 fpop_wpp2010
	gen pop_wpp2010 = fpop_wpp2010 * pfu
	
	gen ir = (case2010 / pop_wpp2010) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2010^(1/2)) / pop_wpp2010) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2010, (0.05/2))) / pop_wpp2010 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2010+1), (1-(0.05/2)))) / pop_wpp2010 ) * (10^5)

	* Display the results
	label var pop_wpp2010 "P-Y"
	label var case2010 "case2010s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2010 pop_wpp2010 ir se lower upper , noobs table

** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2010==.|case2010==0 //3 deleted
gen year=1
keep year sex case2010 ir
rename case2010 number
rename ir hir
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

label define year_lab 1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015" 7 "2016" 8 "2017" 9 "2018" 10 "2019" 11 "2020" ,modify
label values year year_lab
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	

restore


******************** 2011 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2011= 1 if case==3
replace case2011 = 0 if case2011==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2011 (mean) pop_wpp2011 , by(pfu heart age_10 sex)
	collapse (sum) case2011 pop_wpp2011 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2011 fpop_wpp2011
	gen pop_wpp2011 = fpop_wpp2011 * pfu
	
	gen ir = (case2011 / pop_wpp2011) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2011^(1/2)) / pop_wpp2011) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2011, (0.05/2))) / pop_wpp2011 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2011+1), (1-(0.05/2)))) / pop_wpp2011 ) * (10^5)

	* Display the results
	label var pop_wpp2011 "P-Y"
	label var case2011 "case2011s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2011 pop_wpp2011 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2011==.|case2011==0 // deleted
keep sex case2011 ir
rename case2011 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=2 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore


******************** 2012 CRUDE INCIDENCE RATE by sex ****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2012= 1 if case==4
replace case2012 = 0 if case2012==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2012 (mean) pop_wpp2012 , by(pfu heart age_10 sex)
	collapse (sum) case2012 pop_wpp2012 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2012 fpop_wpp2012
	gen pop_wpp2012 = fpop_wpp2012 * pfu
	
	gen ir = (case2012 / pop_wpp2012) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2012^(1/2)) / pop_wpp2012) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2012, (0.05/2))) / pop_wpp2012 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2012+1), (1-(0.05/2)))) / pop_wpp2012 ) * (10^5)

	* Display the results
	label var pop_wpp2012 "P-Y"
	label var case2012 "case2012s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2012 pop_wpp2012 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2012==.|case2012==0 // deleted
keep sex case2012 ir
rename case2012 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=3 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore

******************** 2013 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2013= 1 if case==5
replace case2013 = 0 if case2013==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2013 (mean) pop_wpp2013 , by(pfu heart age_10 sex)
	collapse (sum) case2013 pop_wpp2013 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2013 fpop_wpp2013
	gen pop_wpp2013 = fpop_wpp2013 * pfu
	
	gen ir = (case2013 / pop_wpp2013) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2013^(1/2)) / pop_wpp2013) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2013, (0.05/2))) / pop_wpp2013 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2013+1), (1-(0.05/2)))) / pop_wpp2013 ) * (10^5)

	* Display the results
	label var pop_wpp2013 "P-Y"
	label var case2013 "case2013s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2013 pop_wpp2013 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2013==.|case2013==0 // deleted
keep sex case2013 ir
rename case2013 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=4 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore

******************** 2014 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2014= 1 if case==6
replace case2014 = 0 if case2014==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2014 (mean) pop_wpp2014 , by(pfu heart age_10 sex)
	collapse (sum) case2014 pop_wpp2014 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2014 fpop_wpp2014
	gen pop_wpp2014 = fpop_wpp2014 * pfu
	
	gen ir = (case2014 / pop_wpp2014) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2014^(1/2)) / pop_wpp2014) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2014, (0.05/2))) / pop_wpp2014 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2014+1), (1-(0.05/2)))) / pop_wpp2014 ) * (10^5)

	* Display the results
	label var pop_wpp2014 "P-Y"
	label var case2014 "case2014s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2014 pop_wpp2014 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2014==.|case2014==0 // deleted
keep sex case2014 ir
rename case2014 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=5 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace
	
restore

******************** 2015 CRUDE INCIDENCE RATE by sex ****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2015= 1 if case==7
replace case2015 = 0 if case2015==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2015 (mean) pop_wpp2015 , by(pfu heart age_10 sex)
	collapse (sum) case2015 pop_wpp2015 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2015 fpop_wpp2015
	gen pop_wpp2015 = fpop_wpp2015 * pfu
	
	gen ir = (case2015 / pop_wpp2015) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2015^(1/2)) / pop_wpp2015) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2015, (0.05/2))) / pop_wpp2015 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2015+1), (1-(0.05/2)))) / pop_wpp2015 ) * (10^5)

	* Display the results
	label var pop_wpp2015 "P-Y"
	label var case2015 "case2015s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2015 pop_wpp2015 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2015==.|case2015==0 // deleted
keep sex case2015 ir
rename case2015 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=6 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace
restore


******************** 2016 CRUDE INCIDENCE RATE by sex ****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2016= 1 if case==8
replace case2016 = 0 if case2016==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2016 (mean) pop_wpp2016 , by(pfu heart age_10 sex)
	collapse (sum) case2016 pop_wpp2016 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2016 fpop_wpp2016
	gen pop_wpp2016 = fpop_wpp2016 * pfu
	
	gen ir = (case2016 / pop_wpp2016) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2016^(1/2)) / pop_wpp2016) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2016, (0.05/2))) / pop_wpp2016 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2016+1), (1-(0.05/2)))) / pop_wpp2016 ) * (10^5)

	* Display the results
	label var pop_wpp2016 "P-Y"
	label var case2016 "case2016s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2016 pop_wpp2016 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2016==.|case2016==0 // deleted
keep sex case2016 ir
rename case2016 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=7 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore

******************** 2017 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2017= 1 if case==9
replace case2017 = 0 if case2017==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2017 (mean) pop_wpp2017 , by(pfu heart age_10 sex)
	collapse (sum) case2017 pop_wpp2017 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2017 fpop_wpp2017
	gen pop_wpp2017 = fpop_wpp2017 * pfu
	
	gen ir = (case2017 / pop_wpp2017) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2017^(1/2)) / pop_wpp2017) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2017, (0.05/2))) / pop_wpp2017 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2017+1), (1-(0.05/2)))) / pop_wpp2017 ) * (10^5)

	* Display the results
	label var pop_wpp2017 "P-Y"
	label var case2017 "case2017s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2017 pop_wpp2017 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2017==.|case2017==0 // deleted
keep sex case2017 ir
rename case2017 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=8 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore

******************** 2018 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2018= 1 if case==10
replace case2018 = 0 if case2018==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2018 (mean) pop_wpp2018 , by(pfu heart age_10 sex)
	collapse (sum) case2018 pop_wpp2018 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2018 fpop_wpp2018
	gen pop_wpp2018 = fpop_wpp2018 * pfu
	
	gen ir = (case2018 / pop_wpp2018) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2018^(1/2)) / pop_wpp2018) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2018, (0.05/2))) / pop_wpp2018 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2018+1), (1-(0.05/2)))) / pop_wpp2018 ) * (10^5)

	* Display the results
	label var pop_wpp2018 "P-Y"
	label var case2018 "case2018s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2018 pop_wpp2018 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2018==.|case2018==0 // deleted
keep sex case2018 ir
rename case2018 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=9 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore


******************** 2019 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2019= 1 if case==11
replace case2019 = 0 if case2019==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2019 (mean) pop_wpp2019 , by(pfu heart age_10 sex)
	collapse (sum) case2019 pop_wpp2019 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2019 fpop_wpp2019
	gen pop_wpp2019 = fpop_wpp2019 * pfu
	
	gen ir = (case2019 / pop_wpp2019) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2019^(1/2)) / pop_wpp2019) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2019, (0.05/2))) / pop_wpp2019 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2019+1), (1-(0.05/2)))) / pop_wpp2019 ) * (10^5)

	* Display the results
	label var pop_wpp2019 "P-Y"
	label var case2019 "case2019s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2019 pop_wpp2019 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2019==.|case2019==0 // deleted
keep sex case2019 ir
rename case2019 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=10 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace	
restore


******************** 2020 CRUDE INCIDENCE RATE by sex****************************
drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

replace case = 0 if case==. 
gen case2020= 1 if case==12
replace case2020 = 0 if case2020==.
**     With SE and 95% Confidence Interval
preserve
	* crude rate: point estimate
	gen heart = 1
	label define crude 1 "acute MI events" ,modify
	label values heart crude

	collapse (sum) case2020 (mean) pop_wpp2020 , by(pfu heart age_10 sex)
	collapse (sum) case2020 pop_wpp2020 , by(pfu heart sex)
	
	** Weighting for incidence calculation IF period is NOT exactly one year
	** (where it is 1 year, pfu=1)
	rename pop_wpp2020 fpop_wpp2020
	gen pop_wpp2020 = fpop_wpp2020 * pfu
	
	gen ir = (case2020 / pop_wpp2020) * (10^5)
	label var ir "Crude Incidence Rate"

	* Standard Error
	gen se = ( (case2020^(1/2)) / pop_wpp2020) * (10^5)

	* Lower 95% CI
	gen lower = ( (0.5 * invchi2(2*case2020, (0.05/2))) / pop_wpp2020 ) * (10^5)
	* Upper 95% CI
	gen upper = ( (0.5 * invchi2(2*(case2020+1), (1-(0.05/2)))) / pop_wpp2020 ) * (10^5)

	* Display the results
	label var pop_wpp2020 "P-Y"
	label var case2020 "case2020s"
	label var ir "IR"
	label var se "SE"
	label var lower "95% lo"
	label var upper "95% hi"
	foreach var in ir se lower upper {
			format `var' %8.2f
			}
	list sex case2020 pop_wpp2020 ir se lower upper , noobs table
	
** JC update: Save these results as a dataset for reporting figures 1.1. and 1.2
drop if case2020==.|case2020==0 // deleted
keep sex case2020 ir
rename case2020 number
rename ir hir 
expand=2 in 2, gen (dup)
replace sex=3 if dup==1
replace number=0 if dup==1
egen totnum=total(number)
replace number=totnum if dup==1
egen tothir=total(hir)
replace hir=tothir if dup==1
replace hir=round(hir,0.1)
replace tothir=round(tothir,0.1)

drop dup totnum tothir

append using "`datapath'\version02\2-working\NumIRs_heart" 
replace year=11 if year==.
label drop sex_
label define sex_ 1 "Female" 2 "Male" 3 "Total"
order year sex number hir
sort year sex
save "`datapath'\version02\2-working\NumIRs_heart" ,replace
	
restore
