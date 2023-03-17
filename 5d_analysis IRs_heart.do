** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5d_analysis IRs_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-MAR-2023
    // 	date last modified      15-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               (1) To analyse data to calculate crude incidence rates
	//							(2) To analyse data to calculate age standardised incidence rates
	//							(3) To create graphs for age + sex stratified incidence rates
	//							(4) To save the results for outputting to MS Word 6a_analysis report_cvd.do
    //  methods                 Using Stata commands distrate + graph to analyse data + create graphs
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
    log using "`logpath'\5d_analysis IRs_heart.smcl", replace
** HEADER -----------------------------------------------------

********************************************************************** AGE 5 ******************************************************************************
** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467

tab sex ,m
/*
  Incidence |
  Data: Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |        222       47.54       47.54
       Male |        245       52.46      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

tab age5 ,m
/*
      Stata |
   Derived: |
 5-year age |
      bands |      Freq.     Percent        Cum.
------------+-----------------------------------
      25-29 |          1        0.21        0.21
      35-39 |          7        1.50        1.71
      40-44 |          6        1.28        3.00
      45-49 |         22        4.71        7.71
      50-54 |         20        4.28       11.99
      55-59 |         35        7.49       19.49
      60-64 |         47       10.06       29.55
      65-69 |         50       10.71       40.26
      70-74 |         54       11.56       51.82
      75-79 |         45        9.64       61.46
      80-84 |         68       14.56       76.02
  85 & over |        112       23.98      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

sort sex age5

merge m:m sex age5 using "`datapath'\version03\2-working\pop_wpp_2021-5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            13
        from master                         0  (_merge==1)
        from using                         13  (_merge==2)

    Matched                               467  (_merge==3)
    -----------------------------------------
*/
tab age5 ,m

** Young ages have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING


gen case=1 if sd_etype!=. //do not generate case for missing age groups as it skews case total

*********************NUMBER OF CASES BY YEAR***************
tab case sex

*************************************************
** 2021 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==.


** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

save "`datapath'\version03\2-working\2021_heart_dataset_popn" ,replace

preserve
	drop if age5==.

	collapse (sum) case (mean) pop_wpp, by(pfu age5 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age5
save "`datapath'\version03\2-working\tempdistrate_heart" ,replace

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) mult(100000) format(%8.2f)
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  467   281207   166.07     95.94    87.25   105.40     4.55 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting Figures 1.1 and 1.2
gen year=12
matrix list r(adj)
matrix totnumber = r(NDeath)
matrix cir = r(crude)
matrix asir = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat totnumber
svmat cir
svmat asir
svmat ui_lower
svmat ui_upper

collapse year totnumber cir asir ui_*
replace cir=round(cir,0.1)
replace asir=round(asir,0.1)
replace ui_lower=round(ui_lower,0.1)
replace ui_upper=round(ui_upper,0.1)
rename totnumber1 totnumber
rename cir1 cir
rename asir1 asir 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

gen percent=100

gen ui_lower1=string(ui_lower, "%02.1f")
gen ui_upper1=string(ui_upper, "%02.1f")
gen ui_range=ui_lower1+" "+"-"+" "+ui_upper1
drop ui_lower* ui_upper*

save "`datapath'\version03\2-working\CIRsASIRs_total_age5_heart" ,replace

clear

*************************************************
** 2021 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

use "`datapath'\version03\2-working\tempdistrate_heart" ,clear

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_5", 	///	
		         stand(age5) popstand(pop) by(sex)mult(100000) format(%8.2f)

/*
  +-----------------------------------------------------------------------------------------------+
  |    sex   case        N    crude   rateadj   lb_gam   ub_gam   se_gam    srr   lb_srr   ub_srr |
  |-----------------------------------------------------------------------------------------------|
  | Female    222   146370   151.67     79.73    69.25    91.68     5.58   1.00        .        . |
  |   Male    245   134837   181.70    120.94   106.09   137.52     7.86   1.52     1.25     1.84 |
  +-----------------------------------------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting Table 1.2
gen year=12
matrix list r(adj)
matrix number = r(NDeath)
matrix cir = r(crude)
matrix asir = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat number
svmat cir
svmat asir
svmat ui_lower
svmat ui_upper

fillmissing number* asir* ui_* cir*
drop if age5!=1
replace number1=number2 if sex==2
replace cir1=cir2 if sex==2
replace asir1=asir2 if sex==2
replace ui_lower1=ui_lower2 if sex==2
replace ui_upper1=ui_upper2 if sex==2
drop age5 pfu case pop_* *2

rename number1 number
rename cir1 cir
rename asir1 asir 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

replace cir=round(cir,0.1)
replace asir=round(asir,0.1)
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
order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version03\2-working\ASIRs_age5_heart" ,replace
** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\tempdistrate_heart.dta"
restore


**************************************************************
** 2021 - Fig. 1.4a: AGE- and SEX-STRATIFIED INCIDENCE RATE **
**************************************************************
** For this chart, we need the population dataset
use "`datapath'\version03\2-working\2021_heart_dataset_popn", clear

keep case pop_wpp pfu age5 sex
collapse (sum) case (mean) pop_wpp , by(pfu age5 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age5 
list sex age5 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age5
replace ageg = age5+0.25 if sex==2
label define ageg  1 "0-4"  2 "5-9"  3 "10-14" ///
				   4 "15-19"  5 "20-24"  6 "25-29" ///
				   7 "30-34"  8 "35-39"  9 "40-44" ///
				  10 "45-49" 11 "50-54" 12 "55-59" ///
				  13 "60-64" 14 "65-69" 15 "70-74" ///
				  16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values ageg ageg
label define age5  1 "0-4"  2 "5-9"  3 "10-14" ///
				   4 "15-19"  5 "20-24"  6 "25-29" ///
				   7 "30-34"  8 "35-39"  9 "40-44" ///
				  10 "45-49" 11 "50-54" 12 "55-59" ///
				  13 "60-64" 14 "65-69" 15 "70-74" ///
				  16 "75-79" 17 "80-84" 18 "85 & over" ,modify
label values age5 age5

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age5 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age5 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of events", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(1000)4000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of events (men)") 
			lab(2 "Number of events (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version03\3-output\2021_age-sex graph_age5_heart.png" ,replace

clear


********************************************************************** AGE 10 ******************************************************************************
** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467

tab sex ,m
/*
  Incidence |
  Data: Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |        222       47.54       47.54
       Male |        245       52.46      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

tab age_10 ,m
/*
      Stata |
   Derived: |
10-year age |
      bands |      Freq.     Percent        Cum.
------------+-----------------------------------
      25-34 |          1        0.21        0.21
      35-44 |         13        2.78        3.00
      45-54 |         42        8.99       11.99
      55-64 |         82       17.56       29.55
      65-74 |        104       22.27       51.82
      75-84 |        113       24.20       76.02
  85 & over |        112       23.98      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

sort sex age_10

merge m:m sex age_10 using "`datapath'\version03\2-working\pop_wpp_2021-10"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             5
        from master                         0  (_merge==1)
        from using                          5  (_merge==2)

    Matched                               467  (_merge==3)
    -----------------------------------------
*/
tab age_10 ,m

** Young ages have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

gen case=1 if sd_etype!=. //do not generate case for missing age groups as it skews case total

*********************NUMBER OF CASES BY YEAR***************
tab case sex

*************************************************
** 2021 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==.


** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

** Save this merged dataset for age-sex stratified incidence rate graphs below
save "`datapath'\version03\2-working\2021_heart_dataset_popn" ,replace

preserve
	drop if age_10==.

	collapse (sum) case (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version03\2-working\tempdistrate_heart" ,replace

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
/*
  +-------------------------------------------------------------+
  | case        N    crude   rateadj   lb_gam   ub_gam   se_gam |
  |-------------------------------------------------------------|
  |  467   281207   166.07     96.17    87.47   105.62     4.56 |
  +-------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting Figures 1.1 and 1.2
gen year=12
matrix list r(adj)
matrix totnumber = r(NDeath)
matrix cir = r(crude)
matrix asir = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat totnumber
svmat cir
svmat asir
svmat ui_lower
svmat ui_upper

collapse year totnumber cir asir ui_*
replace cir=round(cir,0.1)
replace asir=round(asir,0.1)
replace ui_lower=round(ui_lower,0.1)
replace ui_upper=round(ui_upper,0.1)
rename totnumber1 totnumber
rename cir1 cir
rename asir1 asir 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

gen percent=100

gen ui_lower1=string(ui_lower, "%02.1f")
gen ui_upper1=string(ui_upper, "%02.1f")
gen ui_range=ui_lower1+" "+"-"+" "+ui_upper1
drop ui_lower* ui_upper*

save "`datapath'\version03\2-working\CIRsASIRs_total_age10_heart" ,replace

clear

*************************************************
** 2021 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

use "`datapath'\version03\2-working\tempdistrate_heart" ,clear

distrate case pop_wpp using "`datapath'\version03\2-working\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

/*
  +-----------------------------------------------------------------------------------------------+
  |    sex   case        N    crude   rateadj   lb_gam   ub_gam   se_gam    srr   lb_srr   ub_srr |
  |-----------------------------------------------------------------------------------------------|
  | Female    222   146370   151.67     80.29    69.76    92.25     5.60   1.00        .        . |
  |   Male    245   134837   181.70    120.69   105.88   137.20     7.84   1.50     1.24     1.82 |
  +-----------------------------------------------------------------------------------------------+
*/
** JC update: Save these results as a dataset for reporting Table 1.2
gen year=12
matrix list r(adj)
matrix number = r(NDeath)
matrix cir = r(crude)
matrix asir = r(adj)
matrix ui_lower = r(lb_G)
matrix ui_upper = r(ub_G)
svmat number
svmat cir
svmat asir
svmat ui_lower
svmat ui_upper

fillmissing number* asir* ui_* cir*
drop if age_10!=1
replace number1=number2 if sex==2
replace cir1=cir2 if sex==2
replace asir1=asir2 if sex==2
replace ui_lower1=ui_lower2 if sex==2
replace ui_upper1=ui_upper2 if sex==2
drop age_10 pfu case pop_* *2

rename number1 number
rename cir1 cir
rename asir1 asir 
rename ui_lower1 ui_lower
rename ui_upper1 ui_upper

replace cir=round(cir,0.1)
replace asir=round(asir,0.1)
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
order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version03\2-working\ASIRs_age10_heart" ,replace
** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\tempdistrate_heart.dta"
restore


**************************************************************
** 2021 - Fig. 1.4a: AGE- and SEX-STRATIFIED INCIDENCE RATE **
**************************************************************
** For this chart, we need the population dataset
use "`datapath'\version03\2-working\2021_heart_dataset_popn", clear

keep case pop_wpp pfu age_10 sex
collapse (sum) case (mean) pop_wpp , by(pfu age_10 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp fpop_wpp
gen pop_wpp = fpop_wpp * pfu

label var pop_wpp "Barbados population"
gen asir = (case / pop_wpp) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age_10 
list sex age_10 case pop_wpp asir se lower upper , noobs table sum(case pop_wpp)

** New age variable with shifted columns for men
** Shift is one-half the width of the bars (which has been set at 0.5 in graph code)
gen ageg = age_10
replace ageg = age_10+0.25 if sex==2
label define ageg 1 "0-14" 2 "15-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65-74" /// 
				  8 "75-84" 9 "85 & over" ,modify
label values ageg ageg
label define age_10  1 "0-14" 2 "15-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65-74" /// 
				     8 "75-84" 9 "85 & over" ,modify
label values age_10 age_10

#delimit ;
graph twoway 	(bar case ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
				(line asir age_10 if sex==2, yaxis(2) clw(thick) clc(black) clp("-") cmiss(y))
				(line asir age_10 if sex==1, yaxis(2) clw(thick) clc(red) clp("-") cmiss(y))
				,
			/// Making background completely white
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			/// and insist on a long thin graphic
			ysize(2)
			
	       	xlabel(1 2 3 4 5 6 7 8 9, valuelabel
	       	labs(large) nogrid glc(gs12) angle(45))
	       	xtitle("Age-group (years)", size(large) margin(t=3)) 
			xscale(range(1(1)10))
			xmtick(1(1)10)

	       	/// axis1 = LSH y-axis
			/// axis2 = RHS y-axis
			ylab(0(10)80, axis(1) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Number of events", axis(1) size(large) margin(r=3)) 
			ymtick(0(5)65)
			
	       	ylab(0(1000)4000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
	       	ytitle("Incidence per 100,000 population", axis(2) size(large) margin(l=3))
			ymtick(0(250)2200, axis(2))
			
			/// Legend information
			legend(size(medlarge) nobox position(11) colf cols(2)
			region(color(gs16) ic(gs16) ilw(thin) lw(thin)) order(1 2 3 4)
			lab(1 "Number of events (men)") 
			lab(2 "Number of events (women)")
			lab(3 "Incidence per 100,000 (men)") 
			lab(4 "Incidence per 100,000 (women)")
			);
#delimit cr
graph export "`datapath'\version03\3-output\2021_age-sex graph_age10_heart.png" ,replace
