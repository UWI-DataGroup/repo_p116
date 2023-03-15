** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5f_analysis MRs_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-MAR-2023
    // 	date last modified      15-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               (1) To analyse data to calculate age standardised mortality rates
	//							(3) To save the results for outputting to MS Word 6a_analysis report_cvd.do
    //  methods                 Using Stata command distrate to analyse data
	//							Using 5-year and 10-year age groups
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
    log using "`logpath'\5f_analysis MRs_heart.smcl", replace
** HEADER -----------------------------------------------------

********************************************************************** AGE 5 ******************************************************************************
** Load cleaned de-identified HEART 2021 MORTALITY dataset
use "`datapath'\version03\3-output\2021_prep mort_deidentified_heart", clear

count //335

tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |        167       49.85       49.85
     Female |        168       50.15      100.00
------------+-----------------------------------
      Total |        335      100.00
*/

tab age5 ,m
/*
 5-year age |
      bands |      Freq.     Percent        Cum.
------------+-----------------------------------
      25-29 |          1        0.30        0.30
      35-39 |          1        0.30        0.60
      40-44 |          2        0.60        1.19
      45-49 |          6        1.79        2.99
      50-54 |          8        2.39        5.37
      55-59 |         17        5.07       10.45
      60-64 |         27        8.06       18.51
      65-69 |         33        9.85       28.36
      70-74 |         44       13.13       41.49
      75-79 |         37       11.04       52.54
      80-84 |         57       17.01       69.55
  85 & over |        102       30.45      100.00
------------+-----------------------------------
      Total |        335      100.00
*/

sort sex age5

merge m:m sex age5 using "`datapath'\version03\2-working\pop_wpp_2021-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            15
        from master                         0  (_merge==1)
        from using                         15  (_merge==2)

    Matched                               335  (_merge==3)
    -----------------------------------------
*/
tab age5 ,m

** Young ages have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING


gen case=1 if deathid!=. //do not generate case for missing age groups as it skews case total

*********************NUMBER OF DEATHS BY YEAR***************
tab case sex

*************************************************
** 2021 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==.


** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI deaths occurred"

**************************************************
** 2021 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age5==.

	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
save "`datapath'\version03\2-working\tempdistrate_mort_heart" ,replace

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
/*
 +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  335   281207   119.13     65.54    58.63    73.20     3.64 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset for reporting Figures 1.1 and 1.2
gen year=12
matrix list r(adj)
matrix totnumber = r(NDeath)
matrix asmr = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat totnumber
svmat asmr
svmat ui_lower
svmat ui_upper

collapse year totnumber asmr ui_*
replace asmr=round(asmr,0.1)
replace ui_lower=round(ui_lower,0.1)
replace ui_upper=round(ui_upper,0.1)
rename totnumber1 totnumber
rename asmr1 asmr 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

gen ui_lower1=string(ui_lower, "%02.1f")
gen ui_upper1=string(ui_upper, "%02.1f")
gen ui_range=ui_lower1+" "+"-"+" "+ui_upper1
drop ui_lower* ui_upper*

gen sex=3
gen percent=100

order year sex totnumber asmr ui_range
sort sex year
rename totnumber number

save "`datapath'\version03\2-working\ASMRs_total_age5_heart" ,replace

clear

*************************************************
** 2021 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version03\2-working\tempdistrate_mort_heart" ,clear

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) by(sex)mult(100000) format(%8.2f)

/*
  +-----------------------------------------------------------------------------------------------+
  |    sex   case        N    crude   rateadj   lb_gam   ub_gam   se_gam    srr   lb_srr   ub_srr |
  |-----------------------------------------------------------------------------------------------|
  |   Male    167   146370   114.09     57.90    49.27    67.98     4.64   1.00        .        . |
  | Female    168   134837   124.59     81.80    69.81    95.53     6.41   1.41     1.12     1.77 |
  +-----------------------------------------------------------------------------------------------+
*/
				 
** JC update: Save these results as a dataset for reporting Table 1.2
gen year=12
matrix list r(adj)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat number
svmat asmr
svmat ui_lower
svmat ui_upper

fillmissing number* asmr* ui_*
drop if age5!=1
replace number1=number2 if sex==2
replace asmr1=asmr2 if sex==2
replace ui_lower1=ui_lower2 if sex==2
replace ui_upper1=ui_upper2 if sex==2
drop age5 pfu case pop_* *2

rename number1 number
rename asmr1 asmr 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

replace asmr=round(asmr,0.1)
replace ui_lower=round(ui_lower,0.1)
replace ui_upper=round(ui_upper,0.1)

egen totnum=total(number)
gen percent=number/totnum*100
replace percent=round(percent,0.1)

gen ui_lower1=string(ui_lower, "%02.1f")
gen ui_upper1=string(ui_upper, "%02.1f")
gen ui_range=ui_lower1+" "+"-"+" "+ui_upper1
drop totnum ui_lower* ui_upper*


label define year_lab 12 "2021" ,modify
label values year year_lab
order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version03\2-working\ASMRs_age5_heart" ,replace
** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\tempdistrate_mort_heart.dta"
restore

clear


********************************************************************** AGE 10 ******************************************************************************
** Load cleaned de-identified HEART 2021 MORTALITY dataset
use "`datapath'\version03\3-output\2021_prep mort_deidentified_heart", clear

count //335

tab sex ,m
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
       Male |        167       49.85       49.85
     Female |        168       50.15      100.00
------------+-----------------------------------
      Total |        335      100.00
*/

tab age_10 ,m
/*
10-year age |
      bands |      Freq.     Percent        Cum.
------------+-----------------------------------
      25-34 |          1        0.30        0.30
      35-44 |          3        0.90        1.19
      45-54 |         14        4.18        5.37
      55-64 |         44       13.13       18.51
      65-74 |         77       22.99       41.49
      75-84 |         94       28.06       69.55
  85 & over |        102       30.45      100.00
------------+-----------------------------------
      Total |        335      100.00
*/

sort sex age_10

merge m:m sex age_10 using "`datapath'\version03\2-working\pop_wpp_2021-10"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             6
        from master                         0  (_merge==1)
        from using                          6  (_merge==2)

    Matched                               335  (_merge==3)
    -----------------------------------------
*/
tab age_10 ,m

** Young ages have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING


gen case=1 if deathid!=. //do not generate case for missing age groups as it skews case total

*********************NUMBER OF CASES BY YEAR***************
tab case sex

*************************************************
** 2021 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==.


** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI deaths occurred"

**************************************************
** 2021 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.

	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version03\2-working\tempdistrate_mort_heart" ,replace

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  335   281207   119.13     65.79    58.85    73.46     3.65 |
  +-------------------------------------------------------------+
*/

** JC update: Save these results as a dataset for reporting Figures 1.1 and 1.2
gen year=12
matrix list r(adj)
matrix totnumber = r(NDeath)
matrix asmr = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat totnumber
svmat asmr
svmat ui_lower
svmat ui_upper

collapse year totnumber asmr ui_*
replace asmr=round(asmr,0.1)
replace ui_lower=round(ui_lower,0.1)
replace ui_upper=round(ui_upper,0.1)
rename totnumber1 totnumber
rename asmr1 asmr 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

gen ui_lower1=string(ui_lower, "%02.1f")
gen ui_upper1=string(ui_upper, "%02.1f")
gen ui_range=ui_lower1+" "+"-"+" "+ui_upper1
drop ui_lower* ui_upper*

gen sex=3
gen percent=100

order year sex totnumber asmr ui_range
sort sex year
rename totnumber number

save "`datapath'\version03\2-working\ASMRs_total_age10_heart" ,replace

clear

*************************************************
** 2021 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version03\2-working\tempdistrate_mort_heart" ,clear

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

/*
  +-----------------------------------------------------------------------------------------------+
  |    sex   case        N    crude   rateadj   lb_gam   ub_gam   se_gam    srr   lb_srr   ub_srr |
  |-----------------------------------------------------------------------------------------------|
  |   Male    167   146370   114.09     58.20    49.53    68.26     4.65   1.00        .        . |
  | Female    168   134837   124.59     81.77    69.78    95.45     6.40   1.41     1.12     1.76 |
  +-----------------------------------------------------------------------------------------------+
*/
				 
** JC update: Save these results as a dataset for reporting Table 1.2
gen year=12
matrix list r(adj)
matrix number = r(NDeath)
matrix asmr = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat number
svmat asmr
svmat ui_lower
svmat ui_upper

fillmissing number* asmr* ui_*
drop if age_10!=1
replace number1=number2 if sex==2
replace asmr1=asmr2 if sex==2
replace ui_lower1=ui_lower2 if sex==2
replace ui_upper1=ui_upper2 if sex==2
drop age_10 pfu case pop_* *2

rename number1 number
rename asmr1 asmr 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

replace asmr=round(asmr,0.1)
replace ui_lower=round(ui_lower,0.1)
replace ui_upper=round(ui_upper,0.1)

egen totnum=total(number)
gen percent=number/totnum*100
replace percent=round(percent,0.1)

gen ui_lower1=string(ui_lower, "%02.1f")
gen ui_upper1=string(ui_upper, "%02.1f")
gen ui_range=ui_lower1+" "+"-"+" "+ui_upper1
drop totnum ui_lower* ui_upper*


label define year_lab 12 "2021" ,modify
label values year year_lab
order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version03\2-working\ASMRs_age10_heart" ,replace
** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\tempdistrate_mort_heart.dta"
restore