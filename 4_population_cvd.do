** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			4_population_cvd.do
    //  project:				BNR-CVD
    //  analysts:				Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified	    01-NOV-2022
    //  algorithm task			Prep for external population for incidence and mortality analyses
    //  status                  Completed
    //  objective               To have one dataset with 2021 population data for 2021 cvd report.
    //  methods                 (1) World Standard Population based on SEER (https://seer.cancer.gov/stdpopulations/world.who.html)
	//							(2) 2008-2021 World Population Prospects (https://population.un.org/wpp/Download/Standard/Population/) checked previously-generated with ones on
	//								10-MAY-2022 to ensure they still match.

    ** DO FILE BASED ON
    * AMC Rose code for BNR Cancer 2008 annual report

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
    log using "`logpath'\4_population_cvd.smcl", replace
** HEADER -----------------------------------------------------


**********************************
** WHO WORLD STANDARD POPULATION
**********************************

** (2) Standard World population (WHO 2002 standard)
** REFERENCE
** Age-standardization of rates: A new WHO-standard, 2000
** Ahmad OB, Boschi-Pinto C, Lopez AD, Murray CJL, Lozano R, Inoue M.
** GPE Discussion paper Series No: 31
** EIP/GPE/EBD. World Health Organization

** An important practical reason for choosing the WHO world standard population over other standards 
** (eg. US Standard Population 2000) is that this is the only standard population to be offered
** in 21 categories - and so adequately covering the elderly in fine detail
** The US/European oldest age category = 85+
** The World population offers 85-89, 90-94, 95-99, 100+ 
** More appropriate for this elderly disease, perhaps?
		drop _all
		input age5 pop
		1	8860
		2	8690
		3	8600
		4	8470
		5	8220
		6	7930
		7	7610
		8	7150
		9	6590
		10	6040
		11	5370
		12	4550
		13	3720
		14	2960
		15	2210
		16	1520
		17	910
		18	635
		end

** International Standard dataset Number
gen intdn = 001
label var intdn "World Std Million (21 age groups)"

** NOTE THAT IN ORDER TO MERGE WITH BB POPN DATA AS OF 2010 CENSUS DATA
** We need to break these higher age groups down to one (18 total age-groups
** instead of 21)

** Age labelling
label define whoage5_lab  	1 "0-4"    2 "5-9"	  3 "10-14"	///
		            4 "15-19"  5 "20-24"  6 "25-29"	///
					7 "30-34"  8 "35-39"  9 "40-44"	///
		           10 "45-49" 11 "50-54" 12 "55-59"	///
				   13 "60-64" 14 "65-69" 15 "70-74"	///
		           16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 whoage5_lab
label var age5 "WHO standard 5-year age-grouping (18 groups)"

** TEN age groups in TEN-year bands. 
** This is the standard for all standard population distributions
gen age10 = recode(age5,2,4,6,8,10,12,14,16,17)
recode age10 2=1 4=2 6=3 8=4 10=5 12=6 14=7 16=8 17=9
label define age10_lab  1 "0-9"	   2 "10-19"  3 "20-29"	///
		            	4 "30-39"  5 "40-49"  6 "50-59"	///
						7 "60-69"  8 "70-79"  9 "80 & over" , modify
label values age10 age10_lab

** TEN age groups in TEN-year bands with <15 as first group. 
** This is another standard for population distributions
gen age_10 = recode(age5,3,5,7,9,11,13,15,17,18)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 18=9
label define age_10_lab 	1 "0-14"   2 "15-24"  3 "25-34"	///
				4 "35-44"  5 "45-54"  6 "55-64"	///
				7 "65-74"  8 "75-84"  9 "85 & over" , modify
label values age_10 age_10_lab

gen age45 = recode(age5,9,18)
recode age45 9=1 18=2
label define age45_lab  1 "0-44"   2 "45 & over" , modify
label values age45 age45_lab

gen age55 = recode(age5,11,18)
recode age55 11=1 18=2
label define age55_lab  1 "0-54"   2 "55 & over" , modify
label values age55 age55_lab

gen age60 = recode(age5,12,18)
recode age60 12=1 18=2
label define age60  1 "0-59"   2 "60 & over" , modify
label values age60 age60

gen age65 = recode(age5,13,18)
recode age65 13=1 18=2
label define age65 1 "0-64"  2 "65 & over" , modify
label values age65 age65

sort age5
label data "WHO world standard million: 5-year age bands"

save "`datapath'\version03\2-working\who2000_5", replace

preserve
collapse (sum) pop , by(age10 age60 intdn)
	label data "WHO world standard million: 10-year age bands1"
	sort age10
save "`datapath'\version03\2-working\who2000_10-1", replace

collapse (sum) pop , by(age60 intdn)
	label data "WHO world standard million: 2 age groups. <60 and 60+"
	sort age60
save "`datapath'\version03\2-working\who2000_60", replace
restore

collapse (sum) pop , by(age_10 age45 age55 age65 intdn)
	label data "WHO world standard million: 10-year age bands2"
	sort age_10
save "`datapath'\version03\2-working\who2000_10-2", replace

** JC: created the below pop dataset to be used in 4_section3.do
** as it was missing here
** Now realised it wasn't used for annual rpt so made this defunct
/*collapse (sum) pop , by(age_10 age45 age55 intdn)
	label data "WHO world standard million: 10-year age bands2"
	sort age_10
	drop if age_10>7
save "data\population\who2000_10-2_PC", replace
*/

collapse (sum) pop , by(age45 age55 age65 intdn)
	label data "WHO world standard million: 2 age groups. <45 and 45 & over"
	sort age45
save "`datapath'\version03\2-working\who2000_45", replace

collapse (sum) pop , by(age55 age65 intdn)
	label data "WHO world standard million: 2 age groups. <55 and 55 & over"
	sort age55
save "`datapath'\version03\2-working\who2000_55", replace

preserve
collapse (sum) pop , by(age65 intdn)
	drop if age65==2
	label data "WHO world standard million: 1 age group. <65"
	sort age65
save "`datapath'\version03\2-working\who2000_64", replace
restore

preserve
collapse (sum) pop , by(age65 intdn)
	drop if age65==1
	label data "WHO world standard million: 1 age group. 65 & over"
	sort age65
save "`datapath'\version03\2-working\who2000_65", replace
restore


***************************************
**		   UN WPP populations        **
** (World Population Prospects 2019) **
***************************************
** Written by JCampbell on 02-Dec-2019 as requested by NS for ASIRs comparisons with BSS vs UN WPP's populations
** Downloaded 2021 population totals by JCampbell on 24-Aug-2022 for calculating 2021 ASMRs

***************
** DATA IMPORT  
***************
** LOAD the 2019 WPP 2008,2013-2021 excel dataset, multiple sheets at once
import excel using "`datapath'\version03\1-input\WPP.xlsx" , describe
forvalues i=10(-1)1 {  
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
import excel using "`datapath'\version03\1-input\WPP.xlsx", ///
         sheet(Sheet`i') cellrange(A2:D37) clear
if `i'==10 {
    save "`datapath'\version03\2-working\pop_wpp", replace
  }
  else {
    append using "`datapath'\version03\2-working\pop_wpp.dta"
    save "`datapath'\version03\2-working\pop_wpp", replace
  }
  
}

** Formatting values
rename A sex 
rename B age5 
rename C pop_wpp
rename D year

label define age5_lab 	1 "0-4"	   2 "5-9"    3 "10-14"		///
						4 "15-19"  5 "20-24"  6 "25-29"		///
						7 "30-34"  8 "35-39"  9 "40-44"		///
						10 "45-49" 11 "50-54" 12 "55-59"	///
						13 "60-64" 14 "65-69" 15 "70-74"	///
						16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab

label define sex_lab 1 "female" 2 "male",modify
label values sex sex_lab
//labelling age and sex variables

** TEN age groups in TEN-year bands with <15 as first group. 
** This is another standard for population distributions
gen age_10 = recode(age5,3,5,7,9,11,13,15,17,18)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 18=9
label define age_10_lab 	1 "0-14"   2 "15-24"  3 "25-34"	///
				4 "35-44"  5 "45-54"  6 "55-64"	///
				7 "65-74"  8 "75-84"  9 "85 & over" , modify
label values age_10 age_10_lab


** Create datasets by year
preserve
drop if year!=2008
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2008: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2008-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2008
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2008: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2008-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2013
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2013: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2013-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2013
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2013: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2013-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2014
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2014: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2014-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2014
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2014: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2014-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2015
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2015: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2015-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2015
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2015: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2015-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2016
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2016: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2016-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2016
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2016: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2016-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2017
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2017: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2017-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2017
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2017: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2017-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2018
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2018: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2018-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2018
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2018: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2018-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2018
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2018: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2018-5" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2018
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2018: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2018-10" , replace
note: TS This dataset prepared using 2000-2018 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 27-Nov-2019.
restore

preserve
drop if year!=2019
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2019: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2019-5" , replace
note: TS This dataset prepared using 2000-2019 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 10-May-2022.
restore

preserve
drop if year!=2019
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2019: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2019-10" , replace
note: TS This dataset prepared using 2000-2019 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 10-May-2022.
restore

preserve
drop if year!=2020
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2020: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2020-5" , replace
note: TS This dataset prepared using 2000-2020 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 10-May-2022.
restore

preserve
drop if year!=2020
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2020: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2020-10" , replace
note: TS This dataset prepared using 2000-2020 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 10-May-2022.
restore

preserve
drop if year!=2021
drop year age_10
collapse (sum) pop_wpp, by(age5 sex)
label data "UN WPP Population data 2021: 5-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2021-5" , replace
note: TS This dataset prepared using 2000-2021 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 10-May-2022.
restore

preserve
drop if year!=2021
drop year age5
collapse (sum) pop_wpp, by(age_10 sex)
label data "UN WPP Population data 2021: 10-year age bands"
save "`datapath'\version03\2-working\pop_wpp_2021-10" , replace
note: TS This dataset prepared using 2000-2021 census & estimate populations generated from "https://population.un.org/wpp/Download/Standard/Population/" on 24-Aug-2022.
restore
