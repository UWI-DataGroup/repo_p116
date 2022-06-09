cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.3_stroke_cvd_analysis.do
    //  project:                BNR Stroke
    //  analysts:               Ashley HENRY
    //  date first created:     23-Feb-2022
    //  date last modified:     09-Jun-2022
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
    log using "`logpath'\1.3_stroke_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Secular Trends in Stroke Mortality
 *              Symptoms and Risk Factors 
 *              
************************************************************************
** Load the dataset  

use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean" ,clear

count
** 7649 as of 24-Feb-2022

************************************************
** Table 2.5  Mortality Statistics Stroke
************************************************


** CASE variable
*** The following wa done so that the seperate amounts for each year could be seen ******
** This also assist in being able to do analysis on one year, rather than a combination of all years *****
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

******************************************
**Number of cases:
tab case, miss

** Full Information:
tab case abstracted, miss


** IN-HOSPITAL OUTCOMES (With Information)
***************************************************
tab vstatus if hosp==1 & abstracted==1 & year==2020,m
dis 177/563  //32% In Hosp CFR with info

** IN-HOSPITAL OUTCOMES (All cases)
***************************************************
** overall CFR for stroke in 2020
tab prehosp_d year ,m
tab prehosp_d year if abstracted==1 ,m

tab prehosp_d if hosp==1 & year==2020 ,m 

tab hosp if year==2020 ,m
tab abstracted if hosp==1 & year==2020,m
tab vstatus if hosp==1 & abstracted==1 & year==2020,m
count if abstracted!=1 & hosp==1 & year==2020
display ((177+69)/632)*100 //39% In Hosp CFR all cases

** JC added the below on 12apr2022
tab vstatus abstracted if hosp==1 & year==2020 //JC added this 12apr2022 in light of above display command so the outputs will be: 
tab vstatus abstracted if hosp==1 & year==2019
//In-hospital CFR (all cases) = Total deceased/Total*100
//In-hospital CFR (of cases with full information) = abstracteddeceased/Total abstracted*100
tab case if vstatus!=. & abstracted!=. & hosp==1 & case>1 //gives the Total by year for the 'In-hospital CFR (all cases)'
tab case if vstatus==2 & abstracted!=. & hosp==1 & case>1 //gives the Total deceased by year for the 'In-hospital CFR (all cases)'


tab vstatus abstracted if hosp==1 & year==2019
tab case vstatus if abstracted==1 & hosp==1 & case>1 //gives the abstracteddeceased and Total abstracted by year for the 'In-hospital CFR (of cases with full information)'

count if hosp==1 & year==2020
count if hosp==1 & year==2019

tab year if hosp==1 //Number of hospitalized cases
** End of JC's additional code

**Case Fatality Rate at 28day
*****************************************************
tab f1vstatus if hosp==1 & abstracted==1 & year==2020,m
tab death if hosp==1 & year==2020 //46%

** JC added the below on 12apr2022
tab case death if hosp==1 & case>1 ,m //JC added this 12apr2022 in light of above display command so the output will be:
//Case fatality rates at 28 days = dead/Total per year*100
tab f1vstatus year if hosp==1

STOP
** JC update: Save these results as a dataset for reporting Table 2.5

preserve
save "`datapath'\version02\2-working\mort_stroke_ar" ,replace

contract case if case>1
rename _freq number
sort case
gen id=_n
order id case number
reshape wide number, i(id)  j(case)
fillmissing number*
gen mort_stroke_ar=1
rename number2 year_2010
rename number3 year_2011
rename number4 year_2012
rename number5 year_2013
rename number6 year_2014
rename number7 year_2015
rename number8 year_2016
rename number9 year_2017
rename number10 year_2018
rename number11 year_2019
rename number12 year_2020
drop if id>1
drop id
order mort_stroke_ar year*
save "`datapath'\version02\2-working\mort_stroke" ,replace
clear

use "`datapath'\version02\2-working\mort_stroke_ar" ,clear
tab case abstracted, miss
contract case abstracted if case>1
rename _freq number
drop if abstracted!=1
sort case
drop abstracted
gen id=_n
order id case number
reshape wide number , i(id)  j(case)
fillmissing number*
gen mort_stroke_ar=2
rename number2 year_2010
rename number3 year_2011
rename number4 year_2012
rename number5 year_2013
rename number6 year_2014
rename number7 year_2015
rename number8 year_2016
rename number9 year_2017
rename number10 year_2018
rename number11 year_2019
rename number12 year_2020
drop if id>1
drop id
order mort_stroke_ar year*
append using "`datapath'\version02\2-working\mort_stroke"
sort mort_stroke_ar
save "`datapath'\version02\2-working\mort_stroke" ,replace
clear

use "`datapath'\version02\2-working\mort_stroke_ar" ,clear
tab case vstatus if abstracted==1 & hosp==1 & case>1

tab case vstatus if abstracted==1 & hosp==1 & case>1 , matcell(foo)
mat li foo
svmat foo, names(case)
gen id=_n
drop if id>11
keep id case*
replace case=2 if id==1
replace case=3 if id==2
replace case=4 if id==3
replace case=5 if id==4
replace case=6 if id==5
replace case=7 if id==6
replace case=8 if id==7
replace case=9 if id==8
replace case=10 if id==9
replace case=11 if id==10
replace case=12 if id==11
gen total_fullcases=case1+case2
rename case2 deceased
gen percent=deceased/total_fullcases*100
drop case1 deceased total_fullcases

reshape wide percent , i(id)  j(case)
fillmissing percent*
gen mort_stroke_ar=3
rename percent2 year_2010
rename percent3 year_2011
rename percent4 year_2012
rename percent5 year_2013
rename percent6 year_2014
rename percent7 year_2015
rename percent8 year_2016
rename percent9 year_2017
rename percent10 year_2018
rename percent11 year_2019
rename percent12 year_2020
drop if id>1
drop id
order mort_stroke_ar year*
append using "`datapath'\version02\2-working\mort_stroke"
sort mort_stroke_ar
save "`datapath'\version02\2-working\mort_stroke" ,replace
clear

use "`datapath'\version02\2-working\mort_stroke_ar" ,clear
tab case if vstatus!=. & abstracted!=. & hosp==1 & case>1 //gives the Total by year for the 'In-hospital CFR (all cases)'
contract case if vstatus!=. & abstracted!=. & hosp==1 & case>1 //gives the Total by year for the 'In-hospital CFR (all cases)'

rename _freq total
order case total
save "`datapath'\version02\2-working\mort_stroke_temp" ,replace
clear

use "`datapath'\version02\2-working\mort_stroke_ar" ,clear
tab case if vstatus==2 & abstracted!=. & hosp==1 & case>1 //gives the Total deceased by year for the 'In-hospital CFR (all cases)'
contract case if vstatus==2 & abstracted!=. & hosp==1 & case>1

rename _freq number
order case number
merge 1:1 case using "`datapath'\version02\2-working\mort_stroke_temp"
drop _merge
gen percent=number/total*100
gen id=_n
drop number total

reshape wide percent , i(id)  j(case)
fillmissing percent*
gen mort_stroke_ar=4
rename percent2 year_2010
rename percent3 year_2011
rename percent4 year_2012
rename percent5 year_2013
rename percent6 year_2014
rename percent7 year_2015
rename percent8 year_2016
rename percent9 year_2017
rename percent10 year_2018
rename percent11 year_2019
rename percent12 year_2020
drop if id>1
drop id
order mort_stroke_ar year*
append using "`datapath'\version02\2-working\mort_stroke"
sort mort_stroke_ar
save "`datapath'\version02\2-working\mort_stroke" ,replace
clear


use "`datapath'\version02\2-working\mort_stroke_ar" ,clear
tab case death if hosp==1 & case>1 ,m //JC added this 12apr2022 in light of above display command so the output will be:
//Case fatality rates at 28 days = dead/Total per year*100
contract case death if hosp==1 & case>1
rename _freq number
drop if death!=1

merge 1:1 case using "`datapath'\version02\2-working\mort_stroke_temp"
drop death _merge

gen percent=number/total*100
gen id=_n
drop number total

reshape wide percent , i(id)  j(case)
fillmissing percent*
gen mort_stroke_ar=5
rename percent2 year_2010
rename percent3 year_2011
rename percent4 year_2012
rename percent5 year_2013
rename percent6 year_2014
rename percent7 year_2015
rename percent8 year_2016
rename percent9 year_2017
rename percent10 year_2018
rename percent11 year_2019
rename percent12 year_2020
drop if id>1
drop id
order mort_stroke_ar year*
append using "`datapath'\version02\2-working\mort_stroke"
sort mort_stroke_ar

replace year_2010=round(year_2010,1.0) if mort_stroke_ar>2
replace year_2011=round(year_2011,1.0) if mort_stroke_ar>2
replace year_2012=round(year_2012,1.0) if mort_stroke_ar>2
replace year_2013=round(year_2013,1.0) if mort_stroke_ar>2
replace year_2014=round(year_2014,1.0) if mort_stroke_ar>2
replace year_2015=round(year_2015,1.0) if mort_stroke_ar>2
replace year_2016=round(year_2016,1.0) if mort_stroke_ar>2
replace year_2017=round(year_2017,1.0) if mort_stroke_ar>2
replace year_2018=round(year_2018,1.0) if mort_stroke_ar>2
replace year_2019=round(year_2019,1.0) if mort_stroke_ar>2
replace year_2020=round(year_2020,1.0) if mort_stroke_ar>2

save "`datapath'\version02\2-working\outcomes_stroke" ,replace //for in-hosp outcomes flowchart need some of these stats

label define mort_stroke_ar_lab 1 "Cases" 2 "Cases with full information" 3 "In-hospital CFR (of cases with full information)" ///
							   4 "In-hospital CFR (all cases)" 5 "Case fatality rates at 28 days" ///
							   8 "CFR at 28 days(%)" ,modify
label values mort_stroke_ar mort_stroke_ar_lab
label var mort_stroke_ar "Moratlity Stats Category"

tostring year_2010 ,replace
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
replace year_2010=year_2010+"%" if mort_stroke_ar>2
replace year_2011=year_2011+"%" if mort_stroke_ar>2
replace year_2012=year_2012+"%" if mort_stroke_ar>2
replace year_2013=year_2013+"%" if mort_stroke_ar>2
replace year_2014=year_2014+"%" if mort_stroke_ar>2
replace year_2015=year_2015+"%" if mort_stroke_ar>2
replace year_2016=year_2016+"%" if mort_stroke_ar>2
replace year_2017=year_2017+"%" if mort_stroke_ar>2
replace year_2018=year_2018+"%" if mort_stroke_ar>2
replace year_2019=year_2019+"%" if mort_stroke_ar>2
replace year_2020=year_2020+"%" if mort_stroke_ar>2

drop year_2010

erase "`datapath'\version02\2-working\mort_stroke_ar.dta"
erase "`datapath'\version02\2-working\mort_stroke_temp.dta"
save "`datapath'\version02\2-working\mort_stroke" ,replace
restore


******************************
** INFO. FOR FINAL FLOWCHART *
******************************
count if hosp==1 & year==2020   //Admitted to qeh
tab hosp if year==2020
tab prehosp if year==2020
tab abstracted if hosp==1 & year==2020  //abstracted
tab abstracted if year==2020
tab prehosp_d if record_id!="" & year==2020 ,miss
tab prehosp_d if record_id=="" & year==2020 ,miss
tab prehosp vstatus if year==2020 
tab vstatus if hosp==1 & year==2020, miss //discharge results
tab f1vstatus if year==2020, miss
tab f1vstatus vstatus if year==2020 & abstracted==1, miss
tab f1vstatus if year==2020 & vstatus!=2 & abstracted==1, miss
tab f1vstatus if year==2020 & hosp==1 & np==1, miss
tab f1vstatus if year==2020 & hosp==1, miss

** **
tab certtype if  prehosp==2 & abstracted!=1 & year==2020
tab certtype abstracted if  prehosp==2 & year==2020

** JC update: Save these results as a dataset for reporting Figure 2.4 
preserve
save "`datapath'\version02\2-working\outcomes_stroke_ar" ,replace

tab case if hosp==1 & case>1
tab case abstracted if hosp==1 & case>1
//contract abstracted if hosp==1 & case==12

tab abstracted if hosp==1 & case==12 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
gen id=_n
keep foo id
gen outcomes_stroke_ar=2 if id==1
replace outcomes_stroke_ar=6 if id==2
rename foo year_2020
drop id
order outcomes_stroke_ar year_2020

save "`datapath'\version02\2-working\outcomes_stroke" ,replace

egen total=total(year_2020)
drop outcomes_stroke_ar year_2020
gen id=_n
gen outcomes_stroke_ar=1 if id==1
drop if id>1
rename total year_2020
keep outcomes_stroke_ar year_2020
sort outcomes_stroke_ar
order outcomes_stroke_ar year_2020

append using "`datapath'\version02\2-working\outcomes_stroke"
save "`datapath'\version02\2-working\outcomes_stroke" ,replace
clear


use "`datapath'\version02\2-working\outcomes_stroke_ar" ,clear 

tab vstatus if hosp==1 & year==2020 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
gen outcomes_stroke_ar=4 if id==1
replace outcomes_stroke_ar=3 if id==2
set obs `=_N+1'
replace outcomes_stroke_ar=5 if id==.
replace foo=0 if id==.
drop id
rename foo year_2020
sort outcomes_stroke_ar
order outcomes_stroke_ar year_2020

append using "`datapath'\version02\2-working\outcomes_stroke"
sort outcomes_stroke_ar
save "`datapath'\version02\2-working\outcomes_stroke" ,replace
clear

use "`datapath'\version02\2-working\outcomes_stroke_ar" ,clear
tab certtype if prehosp==2 & year==2020 & abstracted!=1
tab certtype if prehosp==2 & year==2020 & abstracted!=1 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
gen outcomes_stroke_ar=7 if id==2
egen year_2020=total(foo1) if id!=2
drop if id==3
replace outcomes_stroke_ar=8 if outcomes_stroke_ar==.
set obs `=_N+1'
replace outcomes_stroke_ar=9 if id==.
replace foo=0 if id==.
replace year_2020=foo1 if year_2020==.

keep outcomes_stroke_ar year_2020
order outcomes_stroke_ar year_2020

append using "`datapath'\version02\2-working\outcomes_stroke"
sort outcomes_stroke_ar

label define outcomes_stroke_ar_lab 1 "Admitted to QEH" 2 "Data abstracted by BNR team" 3 "Died in hospital" ///
							   4 "Discharged alive" 5 "Unknown Outcome" 6 "Death record only (place of death QEH)" 7 "Post mortem conducted" ///
							   8 "No Post Mortem" 9 "Unknown Outcome" ,modify
label values outcomes_stroke_ar outcomes_stroke_ar_lab
label var outcomes_stroke_ar "In-hospital Outcomes Stats Category"

erase "`datapath'\version02\2-working\outcomes_stroke_ar.dta"
save "`datapath'\version02\2-working\outcomes_stroke" ,replace
restore

STOP
** JC update: Save these results as a dataset for reporting PM1 & PM2
save "`datapath'\version02\2-working\pm1_stroke" ,replace
 ***PM1- reperfusion percentage
 tab reperf year if stype == 1, col 
 
 
 ***PM2 Antithrombotics warfarin, aspirin, plavix
  **codebook sdisdx fes warf* asp* pla*
 by year, sort: tab antithrom sex if stype == 1, col chi

** JC update: Formatting results for reporting PM2
tab antithrom sex if stype==1 & year==2018 ,col
contract antithrom sex if stype==1 & year==2018
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithrom==1
gen percent_m=number/total_m*100 if sex==2 & antithrom==1
drop if antithrom!=1
drop antithrom total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2018
order year female percent_female male percent_male
save "`datapath'\version02\2-working\pm2_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear

tab antithrom sex if stype==1 & year==2019 ,col
contract antithrom sex if stype==1 & year==2019
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithrom==1
gen percent_m=number/total_m*100 if sex==2 & antithrom==1
drop if antithrom!=1
drop antithrom total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2019
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm2_stroke"
save "`datapath'\version02\2-working\pm2_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear

tab antithrom sex if stype==1 & year==2020 ,col
contract antithrom sex if stype==1 & year==2020
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithrom==1
gen percent_m=number/total_m*100 if sex==2 & antithrom==1
drop if antithrom!=1
drop antithrom total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2020
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm2_stroke"

replace percent_female=round(percent_female,1.0)
replace percent_male=round(percent_male,1.0)
sort year
save "`datapath'\version02\2-working\pm2_stroke" ,replace
clear


use "`datapath'\version02\2-working\pm1_stroke" ,clear
 *****PM3-Vteact
 //by year, sort: tab vteact sex, col
 
 ** JC 12apr2022 this performance measure not included in 2019 annual report instead PM3 is derived from the calculations in PM4 of this dofile.
 
****Discharge performance measures
 **PM4 - Antithrombotics at discharge warfarin, aspirin plavix
 by year, sort: tab antithromdis sex if vstatus == 1 & stype == 1, col
 
***Statin at discharge 
 by year, sort: tab statdis sex if vstatus == 1 & stype == 1, col
  
 by year, sort: tab statdis sex if vstatus == 1 & stype == 1, col
 
 
/*
	JC 12apr2022:
	Stroke PM3 and PM4 seem unclear in 2019 annual report. 
	Table 2.6 is referenced in PM3 but I think it was typo and should read Table 2.7
	In the Word output, I've reported Anti-thrombotics and Statin at discharge into 
	separate tables to allow for accuracy and clarity in reporting PM3 and PM4.
*/
** JC update: Formatting results for reporting PM3 (Table 2.7)
tab antithromdis sex if vstatus == 1 & stype==1 & year==2016 ,col
contract antithromdis sex if vstatus == 1 & stype==1 & year==2016
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithromdis==1
gen percent_m=number/total_m*100 if sex==2 & antithromdis==1
drop if antithromdis!=1
drop antithromdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2016
order year female percent_female male percent_male
save "`datapath'\version02\2-working\pm3_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab antithromdis sex if vstatus == 1 & stype==1 & year==2017 ,col
contract antithromdis sex if vstatus == 1 & stype==1 & year==2017
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithromdis==1
gen percent_m=number/total_m*100 if sex==2 & antithromdis==1
drop if antithromdis!=1
drop antithromdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2017
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm3_stroke"
save "`datapath'\version02\2-working\pm3_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab antithromdis sex if vstatus == 1 & stype==1 & year==2018 ,col
contract antithromdis sex if vstatus == 1 & stype==1 & year==2018
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithromdis==1
gen percent_m=number/total_m*100 if sex==2 & antithromdis==1
drop if antithromdis!=1
drop antithromdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2018
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm3_stroke"
save "`datapath'\version02\2-working\pm3_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab antithromdis sex if vstatus == 1 & stype==1 & year==2019 ,col
contract antithromdis sex if vstatus == 1 & stype==1 & year==2019
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithromdis==1
gen percent_m=number/total_m*100 if sex==2 & antithromdis==1
drop if antithromdis!=1
drop antithromdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2019
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm3_stroke"
save "`datapath'\version02\2-working\pm3_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab antithromdis sex if vstatus == 1 & stype==1 & year==2020 ,col
contract antithromdis sex if vstatus == 1 & stype==1 & year==2020
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithromdis==1
gen percent_m=number/total_m*100 if sex==2 & antithromdis==1
drop if antithromdis!=1
drop antithromdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2020
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm3_stroke"

replace percent_female=round(percent_female,1.0)
replace percent_male=round(percent_male,1.0)
sort year
save "`datapath'\version02\2-working\pm3_stroke" ,replace
clear


** JC update: Formatting results for reporting pm4 (Table 2.7)
use "`datapath'\version02\2-working\pm1_stroke" ,clear

tab statdis sex if vstatus == 1 & stype==1 & year==2016 ,col
contract statdis sex if vstatus == 1 & stype==1 & year==2016
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & statdis==1
gen percent_m=number/total_m*100 if sex==2 & statdis==1
drop if statdis!=1
drop statdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2016
order year female percent_female male percent_male
save "`datapath'\version02\2-working\pm4_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab statdis sex if vstatus == 1 & stype==1 & year==2017 ,col
contract statdis sex if vstatus == 1 & stype==1 & year==2017
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & statdis==1
gen percent_m=number/total_m*100 if sex==2 & statdis==1
drop if statdis!=1
drop statdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2017
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm4_stroke"
save "`datapath'\version02\2-working\pm4_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab statdis sex if vstatus == 1 & stype==1 & year==2018 ,col
contract statdis sex if vstatus == 1 & stype==1 & year==2018
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & statdis==1
gen percent_m=number/total_m*100 if sex==2 & statdis==1
drop if statdis!=1
drop statdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2018
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm4_stroke"
save "`datapath'\version02\2-working\pm4_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab statdis sex if vstatus == 1 & stype==1 & year==2019 ,col
contract statdis sex if vstatus == 1 & stype==1 & year==2019
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & statdis==1
gen percent_m=number/total_m*100 if sex==2 & statdis==1
drop if statdis!=1
drop statdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2019
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm4_stroke"
save "`datapath'\version02\2-working\pm4_stroke" ,replace
clear

use "`datapath'\version02\2-working\pm1_stroke" ,clear
tab statdis sex if vstatus == 1 & stype==1 & year==2020 ,col
contract statdis sex if vstatus == 1 & stype==1 & year==2020
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & statdis==1
gen percent_m=number/total_m*100 if sex==2 & statdis==1
drop if statdis!=1
drop statdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2020
order year female percent_female male percent_male

append using "`datapath'\version02\2-working\pm4_stroke"

replace percent_female=round(percent_female,1.0)
replace percent_male=round(percent_male,1.0)
sort year
save "`datapath'\version02\2-working\pm4_stroke" ,replace
*/

**********************************************************************
**Additional Analyses: % CTs for those discharged alive
************************2***0*******2******0**************************
** Requested by SF via email on 20may2022

tab ct ,m
tab ct year
tab vstatus ct
tab ct year if vstatus==1
tab vstatus if abstracted==1
tab vstatus if abstracted==1 & year==2020
tab vstatus ct if abstracted==1 & year==2020

** JC update: Save these results as a dataset for reporting Figure 1.4 
preserve
tab year if ct==1 & vstatus==1 & abstracted==1 & year==2020 ,m matcell(foo)
mat li foo
svmat foo
egen total_alive=total(vstatus) if vstatus==1 & abstracted==1 & year==2020
fillmissing total_alive
drop if foo==.
keep foo total_alive

gen registry="stroke"
gen category=1
gen year=2020

rename foo ct

order registry category year ct total_alive
gen ct_percent=ct/total_alive*100
replace ct_percent=round(ct_percent,1.0)


label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

append using "`datapath'\version02\2-working\addanalyses_ct"
drop id

save "`datapath'\version02\2-working\addanalyses_ct" ,replace
restore


**********************************************************************
**Additional Analyses: % persons <70 with AMI
************************2***0*******2******0**************************
** Requested by SF via email on 20may2022
count if age<70 & year==2020 //all cases
count if age<70 & year==2020 & abstracted==1 //cases abstracted by BNR
count if year==2020
count if year==2020 & abstracted==1

preserve
egen totcases=count(year) if year==2020
egen totabs=count(year) if year==2020 & abstracted==1
egen totagecases=count(year) if age<70 & year==2020
egen totageabs=count(year) if age<70 & year==2020 & abstracted==1
fillmissing totcases totabs totagecases totageabs
gen id=_n
drop if id!=1

keep totcases totabs totagecases totageabs
gen totagecases_percent=totagecases/totcases*100
replace totagecases_percent=round(totagecases_percent,1.0)
gen totageabs_percent=totageabs/totabs*100
replace totageabs_percent=round(totageabs_percent,1.0)

gen registry="stroke"
gen category=2
gen year=2020

order registry category year totagecases totcases totagecases_percent totageabs totabs totageabs_percent

label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

append using "`datapath'\version02\2-working\addanalyses_age"
drop id

save "`datapath'\version02\2-working\addanalyses_age" ,replace
restore