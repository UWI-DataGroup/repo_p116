cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.3_heart_cvd_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY and Jacqueline CAMPBELL
    //  date first created:     26-Jan-2022
    //  date last modified:     17-Mar-2022
	//  analysis:               Heart 2020 dataset for Annual Report
    //  algorithm task          Performing Heart 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to Motality Statistics 
    //  methods:1:              Run analysis on cleaned 2009-2020 BNR-H data.
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
    log using "`logpath'\1.3_heart_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Number of BNR registration
 *              Number of hospital cases
 *              Number of cases with full infomation
 *              In hospital Case Fatality Rate
 *              Total hospital deaths
 *              Case Fatality Rate at 28 day -Abstracted Cases Only.
 *              Figure 1.4 Flow Chat MI Outcomes
 *              Figure 1.5 ASMR 2010-2020
 *              Performance Measures 1 - 5
************************************************************************
** Load the dataset  
use "`datapath'\version02\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

** JC 17feb2022: Sex updated for 2018 pid that has sex=99 using MedData
replace sex=1 if anon_pid==596 & record_id=="20181197" //1 change
/*
** Number of BNR Regsitrations by year
** 547 BNR Reg for year 2020
bysort year :tab abstracted hosp

** Number of Hospital cases
** 338 for year 2020
tab hosp year

** Number of cases with Full information
** 291 abstatracted cases
tab abstracted year, m

** In Hospital Case Fatality Rate
** 68 died in hospital in 2020
** 68/291
tab prehosp_d year if abstracted==1 ,m
dis 68/291

**Total Hospital Deaths
**115 for year 2020
tab prehosp_d if hosp==1 & year==2020 ,m
tab prehosp_d year if hosp==1

**Case Fatality Rate at 28 day
** 79/291
tab f1vstatus year if hosp==1
tab abstracted year,miss
dis 79/291

** JC update: Save these results as a dataset for reporting Table 1.5

preserve
save "`datapath'\version02\2-working\mort_heart_ar" ,replace
/* Another option for doing this - for 2021 annual report need to find way to save tabulate totals as a dataset (bysort year :tab abstracted hosp)
tab hosp year , matcell(foo)
mat li foo
svmat foo, names(year)
gen id=_n
keep id year*

drop year year_ami year1 year2
drop if id>3
rename year3 year_2011
rename year4 year_2012
rename year5 year_2013
rename year6 year_2014
rename year7 year_2015
rename year8 year_2016
rename year9 year_2017
rename year10 year_2018
rename year11 year_2019
rename year12 year_2020
egen number_total_2011=sum(year_2011)
egen number_total_2012=sum(year_2012)
egen number_total_2013=sum(year_2013)
egen number_total_2014=sum(year_2014)
egen number_total_2015=sum(year_2015)
egen number_total_2016=sum(year_2016)
egen number_total_2017=sum(year_2017)
egen number_total_2018=sum(year_2018)
egen number_total_2019=sum(year_2019)
egen number_total_2020=sum(year_2020)
replace year_2011=number_total_2011 if id==3
replace year_2012=number_total_2012 if id==3
replace year_2013=number_total_2013 if id==3
replace year_2014=number_total_2014 if id==3
replace year_2015=number_total_2015 if id==3
replace year_2016=number_total_2016 if id==3
replace year_2017=number_total_2017 if id==3
replace year_2018=number_total_2018 if id==3
replace year_2019=number_total_2019 if id==3
replace year_2020=number_total_2020 if id==3

drop number_total*
drop if id==2
gen mort_heart_ar=1 if id==3
replace mort_heart_ar=2 if id==1
drop id
sort mort_heart_ar
order mort_heart_ar year*
*/
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
save "`datapath'\version02\2-working\mort_heart" ,replace
clear

use "`datapath'\version02\2-working\mort_heart_ar" ,clear

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
append using "`datapath'\version02\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version02\2-working\mort_heart" ,replace
clear

use "`datapath'\version02\2-working\mort_heart_ar" ,clear
/*
tab prehosp_d year if abstracted==1 , matcell(foo)
mat li foo
svmat foo, names(year)
gen id=_n
keep id year*
drop if id>1
drop year year_ami year1 year2
rename year3 year_2011
rename year4 year_2012
rename year5 year_2013
rename year6 year_2014
rename year7 year_2015
rename year8 year_2016
rename year9 year_2017
rename year10 year_2018
rename year11 year_2019
rename year12 year_2020
drop id
gen mort_heart_ar=4
order mort_heart_ar year*
*/

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
append using "`datapath'\version02\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version02\2-working\mort_heart" ,replace

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

append using "`datapath'\version02\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version02\2-working\mort_heart" ,replace

clear

use "`datapath'\version02\2-working\mort_heart_ar" ,clear

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
append using "`datapath'\version02\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version02\2-working\mort_heart" ,replace

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

append using "`datapath'\version02\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version02\2-working\mort_heart" ,replace
clear

use "`datapath'\version02\2-working\mort_heart_ar" ,clear

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
append using "`datapath'\version02\2-working\mort_heart"
sort mort_heart_ar
save "`datapath'\version02\2-working\mort_heart" ,replace

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

append using "`datapath'\version02\2-working\mort_heart"
drop if mort_heart_ar==8
replace mort_heart_ar=8 if mort_heart_ar==9
sort mort_heart_ar

save "`datapath'\version02\2-working\outcomes_heart" ,replace //for in-hosp outcomes flowchart need some of these stats

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

save "`datapath'\version02\2-working\mort_heart" ,replace
restore

***********************************
**FIGURE 1.4 MI OUTCOME FLOWCHART *
***********************************
list numid cstatus org_id disd vstatus f1vstatus deathdate prehosp if vstatus==2 & year==2020 & prehosp==4
** none seen

count if hosp==1 & year==2020
tab hosp if year==2020
tab prehosp if year==2020
tab abstracted if hosp==1 & year==2020
** So, for QEH abstrach acsed events:
tab prehosp_d if abstracted==1 & year==2020 ,miss
tab prehosp vstatus if year==2020 
** will make correction before

** Updating variable **
tab certtype if  prehosp==2 & year==2020 & abstracted!=1

** FOCUS ON HEART IN-HOSPITAL OUTCOMES
***************************************************
** overall CFR for stroke in 2020
tab prehosp_d year ,m
tab prehosp_d year if abstracted==1 ,m

tab prehosp_d if hosp==1 & year==2020 ,m

tab hosp if year==2020 ,m
tab abstracted if hosp==1 & year==2020,m
tab vstatus if hosp==1 & abstracted==1 & year==2020  ,m
count if abstracted!=1 & hosp==1 & year==2020
display ((68+47)/338)*100 //34% In Hosp CFR
display (68+6)/(291+6) // NS new CF calculation


** JC update: Save these results as a dataset for reporting Figure 1.4 
preserve
use "`datapath'\version02\2-working\outcomes_heart" ,clear 
keep mort_heart_ar year_2020
rename mort_heart_ar outcomes_heart_ar
drop if outcomes_heart_ar<2 | outcomes_heart_ar>4
gen id=_n
drop outcomes_heart_ar
order id year_2020

save "`datapath'\version02\2-working\outcomes_heart" ,replace
clear

use "`datapath'\version02\2-working\mort_heart_ar" ,clear 
tab vstatus if hosp==1 & abstracted==1 & year==2020 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
drop if id==2
replace id=4 if id==1
replace id=5 if id==3
rename foo year_2020
order id year_2020

append using "`datapath'\version02\2-working\outcomes_heart"
sort id
save "`datapath'\version02\2-working\outcomes_heart" ,replace
clear

use "`datapath'\version02\2-working\mort_heart_ar" ,clear
tab certtype if prehosp==2 & year==2020 & abstracted!=1 ,m matcell(foo)
mat li foo
svmat foo
drop if foo==.
keep foo
gen id=_n
gen tot=sum(foo)
replace foo=sum(foo) if id!=2
replace tot=. if id!=3
fillmissing tot
replace foo=tot if id==1
rename foo year_2020
drop tot
replace id=6 if id==1
replace id=7 if id==2
replace id=8 if id==3
order id year_2020

append using "`datapath'\version02\2-working\outcomes_heart"
sort id
rename id outcomes_heart_ar


label define outcomes_heart_ar_lab 1 "Admitted to QEH" 2 "Data abstracted by BNR team" 3 "Died in hospital" ///
							   4 "Discharged alive" 5 "Unknown Outcome" 6 "Death record only (place of death QEH)" 7 "Post mortem conducted" ///
							   8 "No Post Mortem" ,modify
label values outcomes_heart_ar outcomes_heart_ar_lab
label var outcomes_heart_ar "In-hospital Outcomes Stats Category"

erase "`datapath'\version02\2-working\mort_heart_ar.dta"
save "`datapath'\version02\2-working\outcomes_heart" ,replace

restore

************************** PERFORMANCE MEASURES *********************
 
**************************
**PM1: Aspirin in 24 hrs
***************************
replace aspact=0 if aspact==2
tab aspach year
tab aspact year
tab aspact sex if year==2011
tab aspact sex if year==2012
tab aspact sex if year==2013
tab aspact sex if year==2014
tab aspact sex if year==2015
tab aspact sex if year==2016
tab aspact sex if year==2017
tab aspact sex if year==2018
tab aspact sex if year==2019
tab aspact sex if year==2020
tab aspact if year==2020
tab aspacs if year==2020
tab aspach if year==2020
tab aspach aspacs if year==2020, miss
** Of those with information on Aspirin given acutely to hosp admission/ symptom (291), 161 had either received aspirin acute of symptoms/ acute of hospital arrival.
dis ((144+114)-97)/291   //55%


tab aspach aspacs if year==2019, miss
tab aspach aspacs if year==2018, miss
tab aspach aspacs if year==2017, miss

tab aspach year if year>2016
tab aspacs year if year>2016
bysort year :tab aspach aspacs if  year>2016
tab aspact year if  year>2016

** JC update: Save these results as a dataset for reporting Performance Measure 1 (Aspirin within 1st 24h)
preserve
save "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,replace
contract aspach year if year>2016
rename _freq number_aspach
gen id=_n
drop if id>4
drop aspach
order id year number_aspach

save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace
clear

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear

contract aspacs year if year>2016
rename _freq number_aspacs
gen id=_n
drop if id>4
drop aspacs id
order year number_aspacs

append using "`datapath'\version02\2-working\pm1_asp24h_heart"
drop id
gen id=_n

save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace
clear

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear
contract aspach aspacs year if  year>2016
rename _freq number_aspachacs
gen id=_n
drop if id>4
keep id year number_aspachacs
order id year number_aspachacs

append using "`datapath'\version02\2-working\pm1_asp24h_heart"
drop id
gen id=_n

save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace
clear

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear
contract aspact year if  year>2016
rename _freq number_aspact
gen id=_n
drop if aspact==.
gen totasp_2017=sum(number_aspact) if year==2017
gen totasp_2018=sum(number_aspact) if year==2018
gen totasp_2019=sum(number_aspact) if year==2019
gen totasp_2020=sum(number_aspact) if year==2020
drop if id<5
keep year totasp*
order year totasp*

append using "`datapath'\version02\2-working\pm1_asp24h_heart"
drop id

replace number_aspachacs=number_aspachacs[_n+4] if number_aspachacs==.
replace number_aspacs=number_aspacs[_n+8] if number_aspacs==.
replace number_aspach=number_aspach[_n+12] if number_aspach==.
gen percent_pm1heart_2017=(number_aspacs+number_aspach-number_aspachacs)/totasp_2017*100 if year==2017
gen percent_pm1heart_2018=(number_aspacs+number_aspach-number_aspachacs)/totasp_2018*100 if year==2018
gen percent_pm1heart_2019=(number_aspacs+number_aspach-number_aspachacs)/totasp_2019*100 if year==2019
gen percent_pm1heart_2020=(number_aspacs+number_aspach-number_aspachacs)/totasp_2020*100 if year==2020
replace percent_pm1heart_2017=round(percent_pm1heart_2017,1.0)
replace percent_pm1heart_2018=round(percent_pm1heart_2018,1.0)
replace percent_pm1heart_2019=round(percent_pm1heart_2019,1.0)
replace percent_pm1heart_2020=round(percent_pm1heart_2020,1.0)
keep percent*
collapse percent*
order percent_pm1heart_2020 percent_pm1heart_2017 percent_pm1heart_2018 percent_pm1heart_2019

//erase "`datapath'\version02\2-working\pm1_asp24h_heart_ar.dta"
save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace

restore

**********************************
**PM2: STEMI pts with Reperfusion
**********************************
** How many STEMIs were thrombolysed - and how many who were thrombolysed were STEMIs?
tab reperf if year==2020 , miss
tab reperf sex if year==2020 , miss
tab reperf ecgste if year==2020 ,miss 
list record_id if year==2020 & ecgste ==. & abstracted==1 & reperf==1
tab ecgste reperf if year==2020 & diagnosis==2 ,m 
tab ecgste sex if year==2020 & diagnosis==2 ,m  
** 48/51 reperfusions were STEMI 
** 48/103 STEMIs by ecg result were reperfused

tab repertype if year==2020

** JC update: Save these results as a dataset for reporting Table 1.6
preserve
tab reperf ecgste if year==2020
tab ecgste if year==2020
tab diagnosis if year==2020
tab diagnosis ecgste if year==2020
tab diagnosis ecgste if year==2020 & abstracted==1
tab repertype if year==2020 ,m
tab repertype ecgste if year==2020

save "`datapath'\version02\2-working\pm2_stemi_heart_ar" ,replace
tab ecgste reperf if year==2020 & diagnosis==2 ,m 
contract ecgste reperf if year==2020 & diagnosis==2
rename _freq number
egen totstemi=total(number) if ecgste==1
gen id=_n
drop if id!=1
keep id number totstemi

gen percent_pm2_stemi=(number)/totstemi*100
replace percent_pm2_stemi=round(percent_pm2_stemi,1.0)
order id number totstemi percent*
save "`datapath'\version02\2-working\pm2_stemi_heart" ,replace
clear

use "`datapath'\version02\2-working\pm2_stemi_heart_ar" ,clear
tab ecgste sex if year==2020 & diagnosis==2 & reperf==1 ,m 
contract ecgste sex if year==2020 & diagnosis==2 & reperf==1
drop if ecgste!=1
gen id=_n
rename _freq number
drop ecgste
reshape wide number , i(id)  j(sex)
collapse number1 number2
rename number1 female
rename number2 male
gen totstemi=female+male
gen percent_pm2_female=female/totstemi*100
replace percent_pm2_female=round(percent_pm2_female,1.0)
gen percent_pm2_male=male/totstemi*100
replace percent_pm2_male=round(percent_pm2_male,1.0)
gen id=1
drop totstemi
order id female male percent_pm2_female percent_pm2_male

merge 1:1 id using "`datapath'\version02\2-working\pm2_stemi_heart"
drop _merge
order id female percent_pm2_female male percent_pm2_male number percent_pm2_stemi totstemi

save "`datapath'\version02\2-working\pm2_stemi_heart" ,replace
clear

use "`datapath'\version02\2-working\pm2_stemi_heart_ar" ,clear
tab ecgste reperf if year==2019 & diagnosis==2 ,m 
contract ecgste reperf if year==2019 & diagnosis==2
rename _freq number
egen totstemi=total(number) if ecgste==1
gen id=_n
drop if id!=1
keep id number totstemi

gen percent_pm2_stemi=(number)/totstemi*100
replace percent_pm2_stemi=round(percent_pm2_stemi,1.0)
replace id=2
order id number totstemi percent*

append using "`datapath'\version02\2-working\pm2_stemi_heart"
save "`datapath'\version02\2-working\pm2_stemi_heart" ,replace
clear

use "`datapath'\version02\2-working\pm2_stemi_heart_ar" ,clear
tab ecgste sex if year==2019 & diagnosis==2 & reperf==1 ,m 
contract ecgste sex if year==2019 & diagnosis==2 & reperf==1
drop if ecgste!=1
gen id=_n
rename _freq number
drop ecgste
reshape wide number , i(id)  j(sex)
collapse number1 number2
rename number1 female
rename number2 male
gen totstemi=female+male
gen percent_pm2_female=female/totstemi*100
replace percent_pm2_female=round(percent_pm2_female,1.0)
gen percent_pm2_male=male/totstemi*100
replace percent_pm2_male=round(percent_pm2_male,1.0)
gen id=2
drop totstemi
order id female male percent_pm2_female percent_pm2_male

merge 1:1 id using "`datapath'\version02\2-working\pm2_stemi_heart"
drop _merge
order id female percent_pm2_female male percent_pm2_male number percent_pm2_stemi totstemi

save "`datapath'\version02\2-working\pm2_stemi_heart" ,replace
clear

use "`datapath'\version02\2-working\pm2_stemi_heart_ar" ,clear
tab ecgste reperf if year==2018 & diagnosis==2 ,m 
contract ecgste reperf if year==2018 & diagnosis==2
rename _freq number
egen totstemi=total(number) if ecgste==1
gen id=_n
drop if id!=1
keep id number totstemi
gen percent_pm2_stemi=(number)/totstemi*100
replace percent_pm2_stemi=round(percent_pm2_stemi,1.0)
replace id=3
order id number totstemi percent*

append using "`datapath'\version02\2-working\pm2_stemi_heart"
save "`datapath'\version02\2-working\pm2_stemi_heart" ,replace
clear

use "`datapath'\version02\2-working\pm2_stemi_heart_ar" ,clear
tab ecgste sex if year==2018 & diagnosis==2 & reperf==1 ,m 
contract ecgste sex if year==2018 & diagnosis==2 & reperf==1
drop if ecgste!=1
gen id=_n
rename _freq number
drop ecgste
reshape wide number , i(id)  j(sex)
collapse number1 number2
rename number1 female
rename number2 male
gen totstemi=female+male
gen percent_pm2_female=female/totstemi*100
replace percent_pm2_female=round(percent_pm2_female,1.0)
gen percent_pm2_male=male/totstemi*100
replace percent_pm2_male=round(percent_pm2_male,1.0)
gen id=3
drop totstemi
order id female male percent_pm2_female percent_pm2_male

merge 1:1 id using "`datapath'\version02\2-working\pm2_stemi_heart"
drop _merge
order id female percent_pm2_female male percent_pm2_male number percent_pm2_stemi totstemi

rename number total_number
rename totstemi total_stemi
rename percent_pm2_female percent_female
rename percent_pm2_male percent_male
rename percent_pm2_stemi percent_total
rename id year
replace year=2020 if year==1
replace year=2019 if year==2
replace year=2018 if year==3
erase "`datapath'\version02\2-working\pm2_stemi_heart_ar.dta"
save "`datapath'\version02\2-working\pm2_stemi_heart" ,replace

restore

*/

/* 
	JC 17mar2022: PM3 was missing code in 2020 analysis dofile so code for below Table 1.7 Timings 
	was taken from 2019 analysis dofile: 1_heart_cvd_median_times.do, adjusted for 2017-2019 and written for 2020.
	
	- Median time from scene to arrival at A&E
	- Median time from admission to first ECG
	- Median time from onset to fibrinolysis
*/


****************************************
**PM3: Time from scene to arrival at A&E  
************************2***0****2***0**

*************************************************
** 2017 PICK-UP  from scene to Hospital Arrival
*************************************************
/* 
	JC 17mar2022 made some changes to how this is calculated as AH was using time variable 
	to generate minutes for this PM3 timing but more accurate to use datetime variable 
	since cases where from scene was before midnight of one day and 
	admission was after midnight the next day would be incorrectly calculated.
*/
//preserve
** Remove non-2017 cases
drop if year!=2017 //4327 deleted

** Check for and remove cases wherein AMI occurred after admission to hospital
count if year==2017 & dom>doh //8
list record_id doh dom locami olocami initdiag oadmhdx* ambulance if year==2017 & dom>doh
list record_id if year==2017 & dom>doh
drop if (record_id=="20171089" | record_id=="20171658" | record_id=="20171888" | record_id=="20172102" | record_id=="2017871" | record_id=="2017890" | record_id=="2017893" | record_id=="2017981") //8 deleted

** Check for and remove cases that were not abstracted
count if year==2017 & abstracted!=1 //189
drop if year==2017 & abstracted!=1 //189 deleted

** Create variable to assess timing (AH's code)
/*
gen mins_ambhosp=round(minutes(round(t_hosp-frmscnt))) if year==2017 & (t_hosp!=. & frmscnt!=.)
replace mins_ambhosp=31 if pid==1922
replace mins_ambhosp=13 if pid==519 (JC 17mar2022: this should be 35 mins not 13)
gen hrs_ambhosp=(mins_ambhosp/60)
label var mins_ambhosp "Total minutes from patient pickup to hospital" 
label var hrs_ambhosp "Total hours from patient pickup to hospital"

tab mins_ambhosp if year==2017 & ambulance==1 ,miss
tab hrs_ambhosp if year==2017 & ambulance==1,miss
** 2 cases with negative information documented
list pid mins_ambhosp hrs_ambhosp pid doh t_hosp frmscnd frmscnt if mins_ambhosp<1
** will make corrections above.

gen k=1

table k, c(p50 mins_ambhosp p25 mins_ambhosp p75 mins_ambhosp min mins_ambhosp max mins_ambhosp)

table k, c(p50 hrs_ambhosp p25 hrs_ambhosp p75 hrs_ambhosp min hrs_ambhosp max hrs_ambhosp)

ameans hrs_ambhosp 
ameans mins_ambhosp 

list pid frmscnt t_hosp if year==2017 & (hrs_ambhosp==0 & mins_ambhosp==0)
** none seen
*/


** JC 17mar2022 using a different method from AH for this as it's best to use datetime variable instead of time variable only when calculating timing
** JC 17mar2022 cleaning check for if admission date after at scene or from scene dates as error noted from below minutes variable
count if doh<frmscnd & doh!=. & frmscnd!=. //1
count if doh<d_amb_atscn & doh!=. & d_amb_atscn!=. //1
replace doh=frmscnd if record_id=="2017446" //1 change

** First check if datetime variables for 'from scene' and 'admission' are not missing
count if dohtoh==. & doh!=. & toh!=. //5
list record_id doh toh dohtoh if dohtoh==. & doh!=. & toh!=.
gen double dohtoh_pm3 = dhms(doh,hh(toh),mm(toh),ss(toh))
format dohtoh_pm3 %tcNN/DD/CCYY_HH:MM:SS
//format dohtoh_pm3 %tCDDmonCCYY_HH:MM:SS - when using this is changes the mm:ss part of the time
//list record_id dohtoh_pm3 doh toh if dohtoh_pm3!=.

count if frmscnt_dtime==. & frmscnd!=. & frmscnt!=. //0
gen double frmscndt_pm3 = dhms(frmscnd,hh(frmscnt),mm(frmscnt),ss(frmscnt))
format frmscndt_pm3 %tcNN/DD/CCYY_HH:MM:SS
//list record_id frmscndt_pm3 frmscnd frmscnt if frmscndt_pm3!=.

count if dohtoh_pm3==. //12
count if frmscndt_pm3==. //120

gen mins_ambhosp=round(minutes(round(dohtoh_pm3-frmscndt_pm3))) if (dohtoh_pm3!=. & frmscndt_pm3!=.)
replace mins_ambhosp=round(minutes(round(t_hosp-frmscnt))) if mins_ambhosp==. & (t_hosp!=. & frmscnt!=.) //0 changes
count if mins_ambhosp<0 //0 - checking to ensure this has been correctly generated
count if mins_ambhosp==. //120 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
stop
gen hrs_ambhosp=(mins_ambhosp/60)
label var mins_ambhosp "Total minutes from patient pickup to hospital" 
label var hrs_ambhosp "Total hours from patient pickup to hospital"

gen k=1

** Below code runs in Stata 16 (used by AH) but not in Stata 17 (used by JC)
//table k, c(p50 mins_door2needle p25 mins_door2needle p75 mins_door2needle min mins_door2needle max mins_door2needle)
//table k, c(p50 hrs_door2needle p25 hrs_door2needle p75 hrs_door2needle min hrs_door2needle max hrs_door2needle)

ameans mins_ambhosp
ameans hrs_ambhosp

//table k, c(p50 hrs_door2needle p25 hrs_door2needle p75 hrs_door2needle min hrs_door2needle max hrs_door2needle)
** 1.7 hours seen - 1 hr 42 mins

** This code will run in Stata 17
table k, stat(q2 mins_ambhosp) stat(q1 mins_ambhosp) stat(q3 mins_ambhosp) stat(min mins_ambhosp) stat(max mins_ambhosp)
table k, stat(q2 hrs_ambhosp) stat(q1 hrs_ambhosp) stat(q3 hrs_ambhosp) stat(min hrs_ambhosp) stat(max hrs_ambhosp)


restore

*************************************************
** 2018 PICK-UP  from scene to Hospital Arrival
*************************************************
list pid doh dom locami olocami initdiag oadmhdx* ambulance if year==2018 & dom>doh
preserve
drop if (pid==1000| pid==1868)
drop if year==2018 & abstracted!=1

gen mins_ambhosp=round(minutes(round(t_hosp-frmscnt))) if year==2018 & (t_hosp!=. & frmscnt!=.) 
replace mins_ambhosp=18 if pid==174
replace mins_ambhosp=11 if pid==2081
gen hrs_ambhosp=(mins_ambhosp/60)
label var mins_ambhosp "Total minutes from patient pickup to hospital" 
label var hrs_ambhosp "Total hours from patient pickup to hospital"

tab mins_ambhosp if year==2018 & ambulance==1 ,miss
tab hrs_ambhosp if year==2018 & ambulance==1,miss
** 2 cases with negative information documented
list pid mins_ambhosp hrs_ambhosp pid doh t_hosp frmscnd frmscnt if mins_ambhosp<1
** 4  seen; 174 corrected above.
**PID 1000 seems from scenen timing incorrect, timing after even some meds given timing but unsure what should be correct value, will drop
** PID 1868 case has same time documented for from scene and arrival at hospital. so will drop.

gen k=1

table k, c(p50 mins_ambhosp p25 mins_ambhosp p75 mins_ambhosp min mins_ambhosp max mins_ambhosp)

table k, c(p50 hrs_ambhosp p25 hrs_ambhosp p75 hrs_ambhosp min hrs_ambhosp max hrs_ambhosp)

ameans hrs_ambhosp 
ameans mins_ambhosp 

list pid frmscnt t_hosp if year==2018 & (hrs_ambhosp==0 & mins_ambhosp==0)
** none seen
restore

*************************************************
** 2019 PICK-UP  from scene to Hospital Arrival
*************************************************
list pid doh dom locami olocami initdiag oadmhdx* ambulance if year==2019 & dom>doh
preserve
drop if ( pid==89| pid==1737 | pid==1674 | pid==1224 )
drop if year==2019 & abstracted!=1

gen mins_ambhosp=round(minutes(round(t_hosp-frmscnt))) if year==2019 & (t_hosp!=. & frmscnt!=.) 
replace mins_ambhosp=18 if pid==174
replace mins_ambhosp=11 if pid==2081
gen hrs_ambhosp=(mins_ambhosp/60)
label var mins_ambhosp "Total minutes from patient pickup to hospital" 
label var hrs_ambhosp "Total hours from patient pickup to hospital"

tab mins_ambhosp if year==2019 & ambulance==1 ,miss
tab hrs_ambhosp if year==2019 & ambulance==1,miss
** 2 cases with negative information documented
list pid gidcf mins_ambhosp hrs_ambhosp pid doh t_hosp frmscnd frmscnt if mins_ambhosp<1
** 4  seen; 1224, 1674, 1737, 89 corrected above.
**PID 1000 seems from scenen timing incorrect, timing after even some meds given timing but unsure what should be correct value, will drop
** PID 1868 case has same time documented for from scene and arrival at hospital. so will drop.

gen k=1

table k, c(p50 mins_ambhosp p25 mins_ambhosp p75 mins_ambhosp min mins_ambhosp max mins_ambhosp)

table k, c(p50 hrs_ambhosp p25 hrs_ambhosp p75 hrs_ambhosp min hrs_ambhosp max hrs_ambhosp)

ameans hrs_ambhosp 
ameans mins_ambhosp 

list pid frmscnt t_hosp if year==2019 & (hrs_ambhosp==0 & mins_ambhosp==0)
** none seen
restore

***************************************
**PM3: Time from admission to first ECG  
************************2***0****2***0*



******************************************************************
**PM3: STEMI pts onset2needle time for those who were thrombolysed
************************2***0*******2******0**********************





stop
** JC 17mar2022: Below was the only code for PM3 in the 2020 analysis dofile

**********************************************************************
**PM3: STEMI pts door2needle time for those who were thrombolysed
************************2***0*******2******0****************************
tab reperf if year==2017,m // 40 pts had reperf
tab reperf if year==2018,m // 42 pts had reperf
tab reperf if year==2019,m // 44 pts had reperf
tab reperf if year==2020,m // 51 pts had reperf

preserve

drop if  record_id=="20202380" | record_id=="202096" // case missing daetae - case ecg before admission.

*******************************************************************************************************
** Added by JC 10mar2022 - totals differ from AH's comments below (maybe a copy and paste error?)
count if year==2020 & reperfdt !=. //47
list record_id frmscnt dohtoh daetae reperfdt if year==2020 & reperfdt !=.
count if year==2020 & daetae!=. & reperfdt !=. //44
********************************************************************************************************

list reperfdt if year==2020 & reperfdt !=.
list record_id frmscnt doh toh daetae reperfdt if year==2020 & reperfdt !=.
** This shows that only 41 had times recorded for BOTH hosp arrival and TPA
** So we calculate door-to-needle time for 31 patients
gen mins_door2needle=round(minutes(round(reperfdt-daetae))) if year==2020 & (daetae!=. & reperfdt!=.) //44 changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2020 & (frmscnt_dtime!=. & daetae==. & reperfdt!=.) //2 changes

gen hrs_door2needle=(mins_door2needle/60) //46 changes
label var mins_door2needle "Total minutes from arrival at hospital to thrombolysis (door-to-needle)"
label var hrs_door2needle "Total hours from arrival at hospital to thrombolysis (door-to-needle)"

tab mins_door2needle 
tab hrs_door2needle 
list record_id gidcf reperfdt daetae daetae mins_door2needle hrs_door2needle if mins_door2needle<0

list record_id if year==2020 & hrs_door2needle<0
list record_id frmscnt doh toh daetae reperfdt mins_door2needle hrs_door2needle if year==2020 & hrs_door2needle<0

gen k=1

** Below code runs in Stata 16 (used by AH) but not in Stata 17 (used by JC)
//table k, c(p50 mins_door2needle p25 mins_door2needle p75 mins_door2needle min mins_door2needle max mins_door2needle)
//table k, c(p50 hrs_door2needle p25 hrs_door2needle p75 hrs_door2needle min hrs_door2needle max hrs_door2needle)

ameans mins_door2needle
ameans hrs_door2needle

//table k, c(p50 hrs_door2needle p25 hrs_door2needle p75 hrs_door2needle min hrs_door2needle max hrs_door2needle)
** 1.7 hours seen - 1 hr 42 mins

** This code will run in Stata 17
table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle)
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle)

restore


** JC update: Save these 'p50' results as a dataset for reporting Table 1.7
preserve

drop if  record_id=="20202380" | record_id=="202096" // case missing daetae - case ecg before admission.

count if year==2018 & reperfdt !=. //40
list record_id frmscnt dohtoh daetae reperfdt if year==2018 & reperfdt !=.
count if year==2018 & dohtoh!=. & reperfdt !=. //37

count if year==2019 & reperfdt !=. //41
list record_id frmscnt dohtoh daetae reperfdt if year==2019 & reperfdt !=.
count if year==2019 & dohtoh!=. & reperfdt !=. //39

count if year==2020 & reperfdt !=. //47
list record_id frmscnt dohtoh daetae reperfdt if year==2020 & reperfdt !=.
count if year==2020 & daetae!=. & reperfdt !=. //44

gen mins_door2needle=round(minutes(round(reperfdt-daetae))) if year==2020 & (daetae!=. & reperfdt!=.) //44 changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2020 & (frmscnt_dtime!=. & daetae==. & reperfdt!=.) //2 changes

replace mins_door2needle=round(minutes(round(reperfdt-dohtoh))) if year==2019 & (dohtoh!=. & reperfdt!=.) // changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2019 & (frmscnt_dtime!=. & dohtoh==. & reperfdt!=.) // changes

replace mins_door2needle=round(minutes(round(reperfdt-dohtoh))) if year==2018 & (dohtoh!=. & reperfdt!=.) // changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2018 & (frmscnt_dtime!=. & dohtoh==. & reperfdt!=.) // changes

gen hrs_door2needle=(mins_door2needle/60) //46 changes
label var mins_door2needle "Total minutes from arrival at hospital to thrombolysis (door-to-needle)"
label var hrs_door2needle "Total hours from arrival at hospital to thrombolysis (door-to-needle)"

gen k=1

table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle), if year==2020
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle), if year==2020

table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle), if year==2019
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle), if year==2019

table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle), if year==2018
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle), if year==2018

drop if year<2018
drop if k!=1

save "`datapath'\version02\2-working\pm3_door2needle_heart_ar" ,replace

sum mins_door2needle if year==2020
sum mins_door2needle ,detail, if year==2020
gen mins_door2needle_2020=r(p50) if year==2020

tostring mins_door2needle_2020 ,replace
replace mins_door2needle_2020=mins_door2needle_2020+" "+"minutes"


sum mins_door2needle if year==2019
sum mins_door2needle ,detail, if year==2019
gen mins_door2needle_2019=r(p50) if year==2019

tostring mins_door2needle_2019 ,replace
replace mins_door2needle_2019=mins_door2needle_2019+" "+"minutes"


sum mins_door2needle if year==2018
sum mins_door2needle ,detail, if year==2018
gen mins_door2needle_2018=r(p50) if year==2018

tostring mins_door2needle_2018 ,replace
replace mins_door2needle_2018=mins_door2needle_2018+" "+"minutes"

replace mins_door2needle_2018="" if mins_door2needle_2018==". minutes"
replace mins_door2needle_2019="" if mins_door2needle_2019==". minutes"
replace mins_door2needle_2020="" if mins_door2needle_2020==". minutes"
fillmissing mins_door2needle_2018 mins_door2needle_2019 mins_door2needle_2020

keep mins_door2needle_2018 mins_door2needle_2019 mins_door2needle_2020
order mins_door2needle_2018 mins_door2needle_2019 mins_door2needle_2020
save "`datapath'\version02\2-working\pm3_door2needle_heart" ,replace

use "`datapath'\version02\2-working\pm3_door2needle_heart_ar" ,clear

sum hrs_door2needle if year==2020
sum hrs_door2needle ,detail, if year==2020
gen hours_2020=r(p50) if year==2020

sum hrs_door2needle if year==2019
sum hrs_door2needle ,detail, if year==2019
gen hours_2019=r(p50) if year==2019

sum hrs_door2needle if year==2018
sum hrs_door2needle ,detail, if year==2018
gen hours_2018=r(p50) if year==2018

collapse hours_2018 hours_2019 hours_2020

gen double fullhour_2018=int(hours_2018)
gen double fraction_2018=hours_2018-fullhour_2018
gen minutes_2018=round(fraction_2018*60,1)

tostring fullhour_2018 ,replace
tostring minutes_2018 ,replace
replace fullhour_2018=fullhour_2018+" "+"hour"+" "+minutes_2018+" "+"minutes"
rename fullhour_2018 hrs_door2needle_2018


gen double fullhour_2019=int(hours_2019)
gen double fraction_2019=hours_2019-fullhour_2019
gen minutes_2019=round(fraction_2019*60,1)

tostring fullhour_2019 ,replace
tostring minutes_2019 ,replace
replace fullhour_2019=fullhour_2019+" "+"hour"+" "+minutes_2019+" "+"minutes"
rename fullhour_2019 hrs_door2needle_2019


gen double fullhour_2020=int(hours_2020)
gen double fraction_2020=hours_2020-fullhour_2020
gen minutes_2020=round(fraction_2020*60,1)

tostring fullhour_2020 ,replace
tostring minutes_2020 ,replace
replace fullhour_2020=fullhour_2020+" "+"hour"+" "+minutes_2020+" "+"minutes"
rename fullhour_2020 hrs_door2needle_2020

keep hrs_door2needle_2018 hrs_door2needle_2019 hrs_door2needle_2020

append using "`datapath'\version02\2-working\pm3_door2needle_heart"

fillmissing mins_door2needle*
gen id=_n
drop if id>1 
drop id
gen median_door2needle_2018=mins_door2needle_2018+" "+"or"+" "+hrs_door2needle_2018
gen median_door2needle_2019=mins_door2needle_2019+" "+"or"+" "+hrs_door2needle_2019
gen median_door2needle_2020=mins_door2needle_2020+" "+"or"+" "+hrs_door2needle_2020
keep median_door2needle_2018 median_door2needle_2019 median_door2needle_2020
gen pm3_category=3

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_door2needle_2018 median_door2needle_2019 median_door2needle_2020
erase "`datapath'\version02\2-working\pm3_door2needle_heart_ar.dta"
save "`datapath'\version02\2-working\pm3_door2needle_heart" ,replace

restore

stop
**********************************************************************
**PM4: PTs who received ECHO before discharge
************************2***0*******2******0**************************
tab decho year
tab decho sex if year==2011
tab decho sex if year==2012
tab decho sex if year==2013
tab decho sex if year==2014
tab decho sex if year==2015
tab decho sex if year==2016
tab decho sex if year==2017
tab decho sex if year==2018
tab decho sex if year==2019
tab decho sex if year==2020
tab decho if year==2019
tab decho if year==2020


** JC update: Save these results as a dataset for reporting Table 1.8
preserve
save "`datapath'\version02\2-working\pm4_ecg_heart_ar" ,replace

drop if year!=2020

/* JC 14mar2022: testing out below code to output to Word using asdoc command
cd "`datapath'\version02\3-output"
asdoc tabulate decho sex , nokey row column replace
*/

contract decho sex
drop if decho==.
rename _freq number
egen disecho=total(number) if decho==1
egen refecho=total(number) if decho==3
egen totecho=total(number)
gen percent_disecho_f=number/disecho*100 if sex==1 & disecho!=.
gen percent_disecho_m=number/disecho*100 if sex==2 & disecho!=.
gen percent_refecho_f=number/refecho*100 if sex==1 & refecho!=.
gen percent_refecho_m=number/refecho*100 if sex==2 & refecho!=.
gen percent_disecho_tot=disecho/totecho*100
gen percent_refecho_tot=refecho/totecho*100

drop if decho!=1 & decho!=3
gen id=_n

order id

reshape wide decho number disecho refecho totecho percent_disecho_f percent_disecho_m percent_refecho_f percent_refecho_m percent_disecho_tot percent_refecho_tot, i(id)  j(sex)

rename decho1 Timing

label var Timing "Timing"
label define Timing_lab 1 "Before discharge" 3 "Referred to receive after discharge" , modify
label values Timing Timing_lab

drop decho2
fillmissing disecho* refecho* totecho* percent_disecho_f* percent_disecho_m* percent_refecho_f* percent_refecho_m* percent_disecho_tot* percent_refecho_tot*
replace number2=number2[_n+1] if number2==.
drop if id==2|id==4

rename number1 female_num
rename number2 male_num
rename percent_disecho_f1 female_percent
replace female_percent=percent_refecho_f1 if id==3
rename percent_disecho_m2 male_percent
replace male_percent=percent_refecho_m2 if id==3
rename disecho1 total_num
replace total_num=refecho1 if id==3
rename percent_disecho_tot1 total_percent
replace total_percent=percent_refecho_tot1 if id==3

order id Timing female_num female_percent male_num male_percent total_num total_percent
keep Timing female_num female_percent male_num male_percent total_num total_percent

replace female_percent=round(female_percent,1.0)
replace male_percent=round(male_percent,1.0)
replace total_percent=round(total_percent,1.0)

save "`datapath'\version02\2-working\pm4_ecg_heart" ,replace
erase "`datapath'\version02\2-working\pm4_ecg_heart_ar.dta"
restore

**********************************************************************
**PM5: PTs prescribed Aspirin at discharge
************************2***0*******2******0**************************
tab aspdis year
tab aspdis sex if year==2011
tab aspdis sex if year==2012
tab aspdis sex if year==2013
tab aspdis sex if year==2014
tab aspdis sex if year==2015
tab aspdis sex if year==2016
tab aspdis sex if year==2017
tab aspdis sex if year==2018
tab aspdis sex if year==2019
tab aspdis sex if year==2020
tab aspdis if year==2020
tab vstatus if  abstracted==1 & year==2020
** Of those discharged( 222), 184 had aspirin at discharge.
dis 184/222  //83%

** JC 17mar2022: per discussion with NS, check for cases wherein [aspdis]!=yes/at discharge but antiplatelets [pladis]=yes/at discharge and same for aspirin used chronically [aspchr]
tab pladis if year==2020 & (aspdis==99|aspdis==2)
tab aspchr if year==2020 & (aspdis==99|aspdis==2)
bysort year :tab pladis if aspdis==99|aspdis==2
bysort year :tab aspchr if aspdis==99|aspdis==2
bysort year :tab aspdis pladis
bysort year :tab aspdis aspchr

** JC update: Save these results as a dataset for reporting PM5 "Documented aspirin prescribed at discharge"
preserve
tab vstatus aspdis if abstracted==1 & year==2020
save "`datapath'\version02\2-working\pm5_asp_heart" ,replace
restore

**********************************************************************
**PM6: PTs prescribed Statin at discharge
************************2***0*******2******0**************************
tab statdis year
tab statdis sex if year==2011
tab statdis sex if year==2012
tab statdis sex if year==2013
tab statdis sex if year==2014
tab statdis sex if year==2015
tab statdis sex if year==2016
tab statdis sex if year==2017
tab statdis sex if year==2018
tab statdis sex if year==2019
tab statdis sex if year==2020
tab statdis if year==2020
tab vstatus if abstracted==1 & year==2020
** Of those discharged( 222), 181 had statin at discharge.
dis 181/222  //82%

** JC update: Save these results as a dataset for reporting PM6 "Documented statins prescribed at discharge"
preserve
tab vstatus statdis if abstracted==1 & year==2020
save "`datapath'\version02\2-working\pm6_statin_heart" ,replace
restore
