cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.1_stroke_cvd_analysis.do
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
    version 16.0
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
label define case_lab 1 "No. of cases in 2009" 2"No. of cases in 2010" 3"No. of cases in 2011" 4"No. of cases in 2012" ///
                    5 "No. of cases in 2013" 6"No. of cases in 2014" 7"No. of cases in 2015" 8"No. of cases in 2016" ///
					9 "No. of cases in 2017" 10 "No. of cases in 2018" 11 "No. of cases in 2019" 12 "No. of cases in 2020" , modify
label values case case_lab

label var case "Stroke event / participant"


label define month_lab 1 "January" 2"February" 3"March" 4"April" ///
                          5"May" 6"June" 7"July" 8"August" ///
                         9"September" 10"October" 11"November" 12"December" , modify
label values month month_lab



/* MERGING POPULATION DATA */
merge m:m sex age_10 using "C:\Users\CVD 03\Desktop\BNR_data\DM\data_analysis\2019\stroke\weeks01-52\versions\version01\data\population\pop_wpp_2010-2020-10.dta"

** 6699 merged 253 not matched.


**************AGE-STANDARDIZED TO WHO WORLD POPULATION **********************************
**CHANGING..AGE_10 variable to match who_2000_10-2

replace age_10=9 if age_10==10
label define age_10_up_lab 1 "0-14"  2 "15-24"  		///
						3 "25-34" 4 "35-44"    	///
						5 "45-54" 6 "55-64"    	///
						7 "65-74" 8 "75-84"    	///
						9 "85&over" , modify
label values age_10 age_10_up_lab				 
label var age_10 "Age in 10-year bands from 15 years"


gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==.
*************************************************
** 2010 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
gen case2010= 1 if case==2
replace case2010 = 0 if case2010==.

preserve
	drop if age_10==.
	tab case2010
	tab pop_wpp2010
	collapse (sum) case2010 (mean) pop_wpp2010, by(pfu age_10 sex)
	tab pop_wpp2010
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2010 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore

*************************************************
** 2011 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
***************************************************** 
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==.
gen case2011= 1 if case==3
replace case2011 = 0 if case2011==.

preserve
	drop if age_10==.
	collapse (sum) case2011 (mean) pop_wpp2011, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2011 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore


*************************************************
** 2012 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2012= 1 if case==4
replace case2012 = 0 if case2012==.

preserve
	drop if age_10==.

	collapse (sum) case2012 (mean) pop_wpp2012, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2012 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore


*************************************************
** 2013 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2013= 1 if case==5
replace case2013 = 0 if case2013==.

preserve
	drop if age_10==.

	collapse (sum) case2013 (mean) pop_wpp2013, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2013 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore

*************************************************
** 2014 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2014= 1 if case==6
replace case2014 = 0 if case2014==.

preserve
	drop if age_10==.

	collapse (sum) case2014 (mean) pop_wpp2014, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2014 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore


*************************************************
** 2015 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2015= 1 if case==7
replace case2015 = 0 if case2015==.

preserve
	drop if age_10==.

	collapse (sum) case2015 (mean) pop_wpp2015, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2015 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore


*************************************************
** 2016 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2016= 1 if case==8
replace case2016 = 0 if case2016==.

preserve
	drop if age_10==.

	collapse (sum) case2016 (mean) pop_wpp2016, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2016 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore


****************************************************
** 2017 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2017= 1 if case==9
replace case2017 = 0 if case2017==.

preserve
	drop if age_10==.

	collapse (sum) case2017 (mean) pop_wpp2017, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2017 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore


**************************************************
** 2018 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2018= 1 if case==10
replace case2018 = 0 if case2018==.

preserve
	drop if age_10==.

	collapse (sum) case2018 (mean) pop_wpp2018, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2018 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore



**************************************************
** 2019 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2019= 1 if case==11
replace case2019 = 0 if case2019==.

preserve
	drop if age_10==.

	collapse (sum) case2019 (mean) pop_wpp2019, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2019 pop_wpp2019 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2019 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2019 pop_wpp2019 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore




**************************************************
** 2020 AGE-STANDARDIZED TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

replace case = 0 if case==. 
gen case2020= 1 if case==12
replace case2020 = 0 if case2020==.

preserve
	drop if age_10==.

	collapse (sum) case2020 (mean) pop_wpp2020, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2020 AGE-STANDARDIZED BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************

distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
restore




************************************************************ AGE STANDARDIZED MORTALITY ********************************


*** Only death cases beyond this point:
//drop if prehosp>2

drop pfu

gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"
*************************************************
** 2010 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
replace case = 0 if case==. 
//gen case2010= 1 if case==2
replace case2010 = 0 if case2010==.

preserve
	drop if age_10==.
	tab pop_wpp2010
	drop if prehosp>2 & case2010==1
    list pop_wpp2010 case2010 if pop_wpp2010==. & case2010!=0
	collapse (sum) case2010 (mean) pop_wpp2010, by(pfu age_10 sex)
	tab pop_wpp2010
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
tab pop_wpp2010

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2010 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	 drop if prehosp>2 & case2010==1
	tab sex if case==2
	drop if (sex==1 | sex==99) & case==2

	collapse (sum) case2010 (mean) pop_wpp2010, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2010==1
	tab sex if case==2
	drop if (sex==2 | sex==99) & case==2

	collapse (sum) case2010 (mean) pop_wpp2010, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore

*************************************************
** 2011 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2 & case2011==1

	collapse (sum) case2011 (mean) pop_wpp2011, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2011 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2011==1
	tab sex if case==3
	drop if (sex==1 | sex==99) & case==3

	collapse (sum) case2011 (mean) pop_wpp2011, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2011==1
	tab sex if case==3
	drop if (sex==2 | sex==99) & case==3

	collapse (sum) case2011 (mean) pop_wpp2011, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore

*************************************************
** 2012 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2 & case2012==1

	collapse (sum) case2012 (mean) pop_wpp2012, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2012 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2012==1
	tab sex if case==4
	drop if (sex==1 | sex==99) & case==4

	collapse (sum) case2012 (mean) pop_wpp2012, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2012==1
	tab sex if case==4
	drop if (sex==2 | sex==99) & case==4

	collapse (sum) case2012 (mean) pop_wpp2012, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore

*************************************************
** 2013 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2 & case2013==1

	collapse (sum) case2013 (mean) pop_wpp2013, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore


*************************************************
** 2013 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2013==1
	tab sex if case==5
	drop if (sex==1 | sex==99) & case==5

	collapse (sum) case2013 (mean) pop_wpp2013, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2013==1
	tab sex if case==5
	drop if (sex==2 | sex==99) & case==5

	collapse (sum) case2013 (mean) pop_wpp2013, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore


*************************************************
** 2014 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2  & case2014==1

	collapse (sum) case2014 (mean) pop_wpp2014, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", 	///	
             stand(age_10) popstand(pop) mult(100000) format(%8.2f)
******************by sex
distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2014 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2014==1
	tab sex if case==6
	drop if (sex==1 | sex==99) & case==6

	collapse (sum) case2014 (mean) pop_wpp2014, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2014==1
	tab sex if case==6
	drop if (sex==2 | sex==99) & case==6

	collapse (sum) case2014 (mean) pop_wpp2014, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore

*************************************************
** 2015 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2 & case2015==1

	collapse (sum) case2015 (mean) pop_wpp2015, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2015 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2015==1
	tab sex if case==7
	drop if (sex==1 | sex==99) & case==7

	collapse (sum) case2015 (mean) pop_wpp2015, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2015==1
	tab sex if case==7
	drop if (sex==2 | sex==99) & case==7

	collapse (sum) case2015 (mean) pop_wpp2015, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore

*************************************************
** 2016 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2 & case2016==1

	collapse (sum) case2016 (mean) pop_wpp2016, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore


*************************************************
** 2016 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2016==1
	tab sex if case==8
	drop if (sex==1 | sex==99) & case==8

	collapse (sum) case2016 (mean) pop_wpp2016, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2016==1
	tab sex if case==8
	drop if (sex==2 | sex==99) & case==8

	collapse (sum) case2016 (mean) pop_wpp2016, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore

*************************************************
** 2017 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2 & case2017==1

	collapse (sum) case2017 (mean) pop_wpp2017, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore


*************************************************
** 2017 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2017==1
	tab sex if case==9
	drop if (sex==1 | sex==99) & case==9

	collapse (sum) case2017 (mean) pop_wpp2017, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2017==1
	tab sex if case==9
	drop if (sex==2 | sex==99) & case==9

	collapse (sum) case2017 (mean) pop_wpp2017, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore 

*************************************************
** 2018 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
	drop if age_10==.
	drop if prehosp>2  & case2018==1

	collapse (sum) case2018 (mean) pop_wpp2018, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore


*************************************************
** 2018 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2 & case2018==1
	tab sex if case==10
	drop if (sex==1 | sex==99) & case==10

	collapse (sum) case2018 (mean) pop_wpp2018, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2018==1
	tab sex if case==10
	drop if (sex==2 | sex==99) & case==10

	collapse (sum) case2018 (mean) pop_wpp2018, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
*****

*************************************************
** 2019 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
tab case2019
	drop if age_10==.
	drop if prehosp>2 & case2019==1
	count if case2019==1
	collapse (sum) case2019 (mean) pop_wpp2019, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
tab age_10, miss
tab pop_wpp2019, miss
distrate case2019 pop_wpp2019 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2019 pop_wpp2019 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2019 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2019==1
	tab sex if case==11
	drop if (sex==1 | sex==99) & case==11

	collapse (sum) case2019 (mean) pop_wpp2019, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2019 pop_wpp2019 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2019==1
	tab sex if case==11
	drop if (sex==2 | sex==99) & case==11

	collapse (sum) case2019 (mean) pop_wpp2019, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2019 pop_wpp2019 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
*****


*************************************************
** 2020 AGE-STANDARDIZED MORTALITY TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
preserve
tab case2020
	drop if age_10==.
	drop if prehosp>2 & case2020==1
	count if case2020==1
	collapse (sum) case2020 (mean) pop_wpp2020, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10
tab age_10, miss
tab pop_wpp2020, miss
distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

******************by sex
distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore

*************************************************
** 2020 AGE-STANDARDIZED MORTALITY BY SEX TO WHO WORLD POPULATION
** Using WHO World Standard Population
*****************************************************
********MALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2020==1
	tab sex if case==12
	drop if (sex==1 | sex==99) & case==12

	collapse (sum) case2020 (mean) pop_wpp2020, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
**********FEMALES
preserve
	drop if age_10==.
	drop if prehosp>2  & case2020==1
	tab sex if case==12
	drop if (sex==2 | sex==99) & case==12

	collapse (sum) case2020 (mean) pop_wpp2020, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", ///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
restore
*****



*************************************************************
****************************************************************
*** 2020 - Fig. 2.3a: AGE- and SEX-STRATIFIED INCIDENCE RATE ***********
****************************************************************
** For this chart, we need the population dataset
//use "`datapath'\2019_updated_stroke_dataset_popn.dta", clear
drop pfu
gen pfu=1
label var pfu "Proportion of year in which stroke cases occurred"

preserve
drop if year!=2020
keep case2020 pop_wpp2020 pfu age_10 sex
collapse (sum) case2020 (mean) pop_wpp2020 , by(pfu age_10 sex)

** Weighting for incidence calculation IF period is NOT exactly one year
rename pop_wpp2020 fpop_wpp2020
gen pop_wpp2020 = fpop_wpp2020 * pfu

label var pop_wpp2020 "Barbados population"
gen asir = (case2020 / pop_wpp2020) * (10^5)
label var asir "Age-stratified Incidence Rate"

* Standard Error
gen se = ( (case2020^(1/2)) / pop_wpp2020) * (10^5)

* Lower 95% CI
gen lower = ( (0.5 * invchi2(2*case2020, (0.05/2))) / pop_wpp2020 ) * (10^5)
replace lower = 0 if asir==0
* Upper 95% CI
gen upper = ( (0.5 * invchi2(2*(case2020+1), (1-(0.05/2)))) / pop_wpp2020 ) * (10^5)

* Display the results
label var asir "IR"
label var se "SE"
label var lower "95% lo"
label var upper "95% hi"
foreach var in asir se lower upper {
		format `var' %8.2f
		}
sort sex age_10 
list sex age_10 case2020 pop_wpp2020 asir se lower upper , noobs table sum(case2020 pop_wpp2020)
logout, save(20220210_2019new) word replace: list sex age_10 case2020 pop_wpp2020 asir se lower upper , noobs table sum(case2020 pop_wpp2020)

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
graph twoway 	(bar case2020 ageg if sex==2, yaxis(1) col(blue*1.5) barw(0.5) )
				(bar case2020 ageg if sex==1, yaxis(1) col(orange)  barw(0.5) )
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
restore