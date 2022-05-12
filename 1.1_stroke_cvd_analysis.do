cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.1_stroke_cvd_analysis.do
    //  project:                BNR Stroke
    //  analysts:               Ashley HENRY and Jacqueline CAMPBELL
    //  date first created:     23-Feb-2022
    //  date last modified:     12-May-2022
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
    local logpath X:/The University of the West Indies/DataGroup - repo_data/data_p116

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\1.1_stroke_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Age Standardised Incidence & Mortality Rates
 *              Crude Mortality Rates 
 *              Age & Sex Stratified Incidence
************************************************************************
** Load the dataset  

use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean" ,clear

count
** 7649, 23-Feb-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2010-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


*********************NUMBER OF CASES BY YEAR***************
tab case sex
tab case sex if year>2009

****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

*************************************************
** 2010 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2010= 1 if case==2
replace case2010 = 0 if case2010==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2010 (mean) pop_wpp2010, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2010 pop_wpp2010 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
/*

*/
** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=1
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

save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2010 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2010 pop_wpp2010 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

/*

*/
** JC update: Save these results as a dataset for reporting Table 2.1
gen year=1
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
drop age_10 pfu case2010 pop_* *2

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

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2010 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2010 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2010 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=1
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

save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2010 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2010 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)				 
/*

*/
** JC update: Save these results as a dataset for reporting Table 2.1
gen year=1
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
drop age_10 pfu case2010 pop_* *2

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

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace

restore
*****




clear
************************************** 2011 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2011-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

*************************************************
** 2011 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2011= 1 if case==3
replace case2011 = 0 if case2011==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2011 (mean) pop_wpp2011, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2011 pop_wpp2011 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=2
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear
		 
*************************************************
** 2011 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2011 pop_wpp2011 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

/*

*/
** JC update: Save these results as a dataset for reporting Table 2.1
gen year=2
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
drop age_10 pfu case2011 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace

restore


**************************************************
** 2011 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2011 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2011 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=2
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2011 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2011 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=2
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
drop age_10 pfu case2011 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace

restore
*****





clear
************************************** 2012 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2012-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

*************************************************
** 2012 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2012= 1 if case==4
replace case2012 = 0 if case2012==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2012 (mean) pop_wpp2012, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2012 pop_wpp2012 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=3
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2012 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2012 pop_wpp2012 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=3
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
drop age_10 pfu case2012 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2012 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2012 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2012 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=3
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2012 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2012 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=3
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
drop age_10 pfu case2012 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****





clear
************************************** 2013 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2013-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

*************************************************
** 2013 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2013= 1 if case==5
replace case2013 = 0 if case2013==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2013 (mean) pop_wpp2013, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2013 pop_wpp2013 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=4
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2013 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2013 pop_wpp2013 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=4
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
drop age_10 pfu case2013 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2013 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2013 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2013 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=4
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2013 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2013 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=4
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
drop age_10 pfu case2013 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****




clear
************************************** 2014 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2014-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

*************************************************
** 2014 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2014= 1 if case==6
replace case2014 = 0 if case2014==.

//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2014 (mean) pop_wpp2014, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2014 pop_wpp2014 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=5
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2014 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2014 pop_wpp2014 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=5
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
drop age_10 pfu case2014 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2014 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2014 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2014 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=5
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2014 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2014 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=5
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
drop age_10 pfu case2014 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****






clear
************************************** 2015 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2015-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

*************************************************
** 2015 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2015= 1 if case==7
replace case2015 = 0 if case2015==.

//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2015 (mean) pop_wpp2015, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2015 pop_wpp2015 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=6
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2015 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2015 pop_wpp2015 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=6
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
drop age_10 pfu case2015 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2015 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2015 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2015 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=6
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2015 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2015 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=6
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
drop age_10 pfu case2015 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****




clear
************************************** 2016 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2016-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"


*************************************************
** 2016 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2016= 1 if case==8
replace case2016 = 0 if case2016==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"



preserve
	drop if age_10==.

	collapse (sum) case2016 (mean) pop_wpp2016, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2016 pop_wpp2016 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=7
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2016 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2016 pop_wpp2016 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=7
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
drop age_10 pfu case2016 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2016 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2016 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2016 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=7
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2016 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2016 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=7
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
drop age_10 pfu case2016 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****





clear
************************************** 2017 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2017-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

**************************************************
** 2017 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2017= 1 if case==9
replace case2017 = 0 if case2017==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2017 (mean) pop_wpp2017, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2017 pop_wpp2017 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=8
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2017 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2017 pop_wpp2017 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=8
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
drop age_10 pfu case2017 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2017 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2017 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2017 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=8
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2017 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2017 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=8
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
drop age_10 pfu case2017 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****





clear
************************************** 2018 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2018-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

**************************************************
** 2018 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2018= 1 if case==10
replace case2018 = 0 if case2018==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"



preserve
	drop if age_10==.

	collapse (sum) case2018 (mean) pop_wpp2018, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2018 pop_wpp2018 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=9
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2018 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2018 pop_wpp2018 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=9
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
drop age_10 pfu case2018 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2018 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2018 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2018 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=9
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2018 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2018 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=9
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
drop age_10 pfu case2018 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****




clear
************************************** 2019 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2019-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"


****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

**************************************************
** 2019 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2019= 1 if case==11
replace case2019 = 0 if case2019==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"



preserve
	drop if age_10==.

	collapse (sum) case2019 (mean) pop_wpp, by(pfu age_10 sex)

	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2019 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=10
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2019 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2019 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=10
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
drop age_10 pfu case2019 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

order year sex number percent asir ui_range cir
sort sex year
save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
restore


**************************************************
** 2019 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2019 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2019 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=10
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2019 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2019 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=10
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
drop age_10 pfu case2019 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
restore
*****


clear
************************************** 2020 *****************************
** Load the dataset  
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\version02\3-output\pop_wpp_2020-10"

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
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11"No. of cases in 2019"  12 "No. of cases in 2020" , modify
label values case case_lab
label var case "Stroke event / participant"

tab case ,m
tab sex if case==12
tab age_10 if case==12 ,m

****************************FIGURE 1.2********************************
************** AGE-STANDARDIZED TO UNWPP ******************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-25"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"

**************************************************
** 2020 AGE-STANDARDIZED TO UNWPP
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
gen case2020= 1 if case==12
replace case2020 = 0 if case2020==.


//drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2020 (mean) pop_wpp2020, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_stroke" ,replace

distrate case2020 pop_wpp2020 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=11
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

append using "`datapath'\version02\2-working\CIRsASIRs_total_stroke" 
save "`datapath'\version02\2-working\CIRsASIRs_total_stroke" ,replace

clear

*************************************************
** 2020 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_stroke" ,clear

distrate case2020 pop_wpp2020 using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=11
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
drop age_10 pfu case2020 pop_* *2

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

append using "`datapath'\version02\2-working\ASIRs_stroke" 

label define year_lab 1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015" 7 "2016" 8 "2017" 9 "2018" 10 "2019" 11 "2020" ,modify
label values year year_lab
order year sex number percent asir ui_range cir
sort sex year

save "`datapath'\version02\2-working\ASIRs_stroke" ,replace
** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version02\2-working\tempdistrate_stroke.dta"
restore


**************************************************
** 2020 AGE-STANDARDIZED MORTALITY TO UN WPP
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2

	collapse (sum) case2020 (mean) pop_wpp, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
save "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,replace

distrate case2020 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Figures 2.1 and 2.2
gen year=11
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

append using "`datapath'\version02\2-working\ASMRs_total_stroke"
save "`datapath'\version02\2-working\ASMRs_total_stroke" ,replace

clear

*************************************************
** 2020 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************
use "`datapath'\version02\2-working\tempdistrate_mort_stroke" ,clear

distrate case2020 pop_wpp using "`datapath'\version02\3-output\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)

** JC update: Save these results as a dataset for reporting Table 2.1
gen year=11
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
drop age_10 pfu case2020 pop_* *2

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

append using "`datapath'\version02\2-working\ASMRs_stroke"

label define year_lab 1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015" 7 "2016" 8 "2017" 9 "2018" 10 "2019" 11 "2020" ,modify
label values year year_lab
order year sex number percent asmr ui_range
sort sex year
save "`datapath'\version02\2-working\ASMRs_stroke" ,replace
** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version02\2-working\tempdistrate_mort_stroke.dta"
restore
*****


*************************************************************
****************************************************************
*** 2018-2020 - Fig. 2.3a: AGE- and SEX-STRATIFIED INCIDENCE RATE ***********
****************************************************************
/*
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"
*/
** JC 05apr2022 added 2018 and 2019 graphs
**********
** 2018 **
**********
** For this chart, we need the population dataset (below added by JC on 04apr2022)
use "`datapath'\version02\3-output\2018_updated_stroke_dataset_popn", clear
//drop if year!=2018
keep case pop_bb pfu age_10 sex
collapse (sum) case (mean) pop_bb , by(pfu age_10 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_bb fpop_bb
gen pop_bb = fpop_bb * pfu

label var pop_bb "Barbados population"
gen asir = (case / pop_bb) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_bb) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age_10 
list sex age_10 case pop_bb asir se lower upper , noobs table sum(case pop_bb)

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
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
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
graph export "`datapath'\version02\3-output\2018_age-sex graph_stroke.png" ,replace


**********
** 2019 **
**********
** For this chart, we need the population dataset (below added by JC on 04apr2022)
use "`datapath'\version02\3-output\2019_updated_stroke_dataset_popn", clear
//drop if year!=2019
keep case pop_bb pfu age_10 sex
collapse (sum) case (mean) pop_bb , by(pfu age_10 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_bb fpop_bb
gen pop_bb = fpop_bb * pfu

label var pop_bb "Barbados population"
gen asir = (case / pop_bb) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_bb) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_bb ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_bb ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age_10 
list sex age_10 case pop_bb asir se lower upper , noobs table sum(case pop_bb)

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
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
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
graph export "`datapath'\version02\3-output\2019_age-sex graph_stroke.png" ,replace


**********
** 2020 **
**********
** For this chart, we need the population dataset (below added by JC on 04apr2022)
use "`datapath'\version02\3-output\2020_updated_stroke_dataset_popn", clear
//drop if year!=2020
keep case pop_wpp2020 pfu age_10 sex
collapse (sum) case (mean) pop_wpp2020 , by(pfu age_10 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp2020 fpop_wpp2020
gen pop_wpp2020 = fpop_wpp2020 * pfu

label var pop_wpp2020 "Barbados population"
gen asir = (case / pop_wpp2020) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case^(1/2)) / pop_wpp2020) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case, (0.05/2))) / pop_wpp2020 ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case+1), (1-(0.05/2)))) / pop_wpp2020 ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age_10 
list sex age_10 case pop_wpp2020 asir se lower upper , noobs table sum(case pop_wpp2020)
//logout, save(20220210_2019new) word replace: list sex age_10 case pop_wpp2020 asir se lower upper , noobs table sum(case pop_wpp2020)

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
			
	       	ylab(0(500)2000, axis(2) labs(large) nogrid glc(gs12) angle(0) format(%9.0f))
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
graph export "`datapath'\version02\3-output\2020_age-sex graph_stroke.png" ,replace
