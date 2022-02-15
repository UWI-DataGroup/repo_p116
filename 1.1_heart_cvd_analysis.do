cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.1_heart_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY
    //  date first created:     26-Jan-2022
    //  date last modified:     26-Jan-2022
	//  analysis:               Heart 2020 dataset for Annual Report
    //  algorithm task          Performing Heart 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to calculate Age standardised and Age stratified Incidence Rate.
    //  methods:1:              Run analysis on cleaned 2009-2020 BNR-H data.
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
    local datapath "C:\Users\CVD 03\Desktop\BNR_data\DM\data_analysis\2020\heart\weeks01-52\versions\version01\data"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath C:\Users\CVD 03\Desktop\BNR_data\DM\data_analysis\2020\heart\weeks01-52\versions\version01\logfiles

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\1.1_heart_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Table 1.2 ASIR 2010-2020
 *              Table 1.2 ASMR 2010-202
 *              Figure 1.3 ASIR Graphs
************************************************************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2010-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2010 (mean) pop_wpp2010, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2010 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2010 pop_wpp2010 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2010 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2010 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2010 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****




clear
************************************** 2011 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2011-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2011 (mean) pop_wpp2011, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

				 
*************************************************
** 2011 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2011 pop_wpp2011 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2011 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2011 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2011 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****





clear
************************************** 2012 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2012-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2012 (mean) pop_wpp2012, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2012 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2012 pop_wpp2012 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2012 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2012 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2012 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****





clear
************************************** 2013 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2013-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2013 (mean) pop_wpp2013, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2013 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
distrate case2013 pop_wpp2013 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2013 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2013 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2013 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****




clear
************************************** 2014 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2014-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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

drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2014 (mean) pop_wpp2014, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2014 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2014 pop_wpp2014 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2014 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2014 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2014 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****






clear
************************************** 2015 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2015-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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

drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2015 (mean) pop_wpp2015, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2015 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************
distrate case2015 pop_wpp2015 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2015 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2015 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2015 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****




clear
************************************** 2016 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2016-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"



preserve
	drop if age_10==.

	collapse (sum) case2016 (mean) pop_wpp2016, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2016 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2016 pop_wpp2016 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex) mult(100000) format(%8.2f)
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

distrate case2016 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2016 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2016 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****





clear
************************************** 2017 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2017-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"


preserve
	drop if age_10==.

	collapse (sum) case2017 (mean) pop_wpp2017, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2017 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2017 pop_wpp2017 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2017 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2017 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2017 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****





clear
************************************** 2018 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2018-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"



preserve
	drop if age_10==.

	collapse (sum) case2018 (mean) pop_wpp2018, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2018 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2018 pop_wpp2018 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2018 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2018 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2018 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****




clear
************************************** 2019 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2019-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"



preserve
	drop if age_10==.

	collapse (sum) case2019 (mean) pop_wpp, by(pfu age_10 sex)

	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2019 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2019 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2019 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2019 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2019 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2019 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****


clear
************************************** 2020 *****************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

sort sex age_10

merge m:m sex age_10 using "`datapath'\population\pop_wpp_2020-10.dta"

** Young ages (10-19 female) have no acute MI cases and so merge with error (_merge==2)
** Zero cases in any age group/sex combination are set to ZERO from MISSING

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
label var case "Acute MI event / participant"


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


drop pfu
** If a full year, use pfu=1
gen pfu=1
label var pfu "Proportion of year in which acute MI cases occurred"

preserve
	drop if age_10==.

	collapse (sum) case2020 (mean) pop_wpp2020, by(pfu age_10 sex)
	
	** -distrate is a user written command.
	** type -search distrate,net- at the Stata prompt to find and install this command

sort age_10

distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)
*************************************************
** 2020 AGE-STANDARDIZED BY SEX TO UNWPP
** Using WHO World Standard Population
*****************************************************

distrate case2020 pop_wpp2020 using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
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

distrate case2020 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) mult(100000) format(%8.2f)

*************************************************
** 2020 AGE-STANDARDIZED MORTALITY BY SEX TO UN WPP
** Using WHO World Standard Population
*****************************************************

distrate case2020 pop_wpp using "`datapath'\population\who2000_10-2", 	///	
		         stand(age_10) popstand(pop) by(sex)mult(100000) format(%8.2f)
restore
*****



****************************************************************
*** 2018- Fig. 1.3: AGE- and SEX-STRATIFIED INCIDENCE RATE ***********
****************************************************************
** For this chart, we need the population dataset
use "`datapath'\2018_heart_dataset_popn.dta", clear
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

*************************************************************
****************************************************************
*** 2019 - Fig. 1.3: AGE- and SEX-STRATIFIED INCIDENCE RATE ***********
****************************************************************
** For this chart, we need the population dataset
use "`datapath'\2019_heart_dataset_popn.dta", clear
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


*************************************************************
****************************************************************
*** 2020 - Fig. 1.3: AGE- and SEX-STRATIFIED INCIDENCE RATE ***********
****************************************************************
** For this chart, we need the population dataset
use "`datapath'\2020_heart_dataset_popn.dta", clear
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