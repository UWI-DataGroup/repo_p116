cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.3_heart_cvd_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY and Jacqueline CAMPBELL
    //  date first created:     26-Jan-2022
    //  date last modified:     03-Mar-2022
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


** JC update: Save these results as a dataset for reporting Performance Measure 1 (Aspirin within 1st 24h)
preserve
save "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,replace
contract aspach if year==2020
rename _freq number
gen id=_n
drop if id!=1
drop aspach
order id number

save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace
clear

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear
contract aspacs if year==2020
rename _freq number
gen id=_n
drop if id!=1
replace id=2
drop aspacs
order id number

append using "`datapath'\version02\2-working\pm1_asp24h_heart"
sort id

save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace
clear

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear
contract aspach aspacs if year==2020
rename _freq number
gen id=_n
drop if id!=1
replace id=3
keep id number
order id number

append using "`datapath'\version02\2-working\pm1_asp24h_heart"
sort id
save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace
clear

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear
contract aspact if year==2020
rename _freq number
gen id=_n
drop if id==3
gen totasp=sum(number)
drop if id==1
replace id=4
keep id totasp
order id totasp

append using "`datapath'\version02\2-working\pm1_asp24h_heart"
sort id

gen percent_pm1_heart=(number[1]+number[2]-number[3])/totasp*100
replace percent_pm1_heart=round(percent_pm1_heart,1.0)
drop if id!=4
keep percent*

erase "`datapath'\version02\2-working\pm1_asp24h_heart_ar.dta"
save "`datapath'\version02\2-working\pm1_asp24h_heart" ,replace

restore
*/
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
stop

**********************************************************************
**PM3: STEMI pts door2needle time for those who were thrombolysed
************************2***0*******2******0****************************
tab reperf if year==2020,m
** 51 pts had reperf
preserve

drop if  record_id=="20202380" | record_id=="202096" // case missing daetae - case ecg before admission.

list reperfdt if year==2020 & reperfdt !=. 
list record_id frmscnt doh toh daetae reperfdt if year==2020 & reperfdt !=.
** This shows that only 41 had times recorded for BOTH hosp arrival and TPA
** So we calculate door-to-needle time for 31 patients
gen mins_door2needle=round(minutes(round(reperfdt-daetae))) if year==2020 & (daetae!=. & reperfdt!=.)  
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2020 & (frmscnt_dtime!=. & daetae==. & reperfdt!=.)   

gen hrs_door2needle=(mins_door2needle/60)
label var mins_door2needle "Total minutes from arrival at hospital to thrombolysis (door-to-needle)"
label var hrs_door2needle "Total hours from arrival at hospital to thrombolysis (door-to-needle)"

tab mins_door2needle 
tab hrs_door2needle 
list record_id gidcf reperfdt daetae daetae mins_door2needle hrs_door2needle if mins_door2needle<0

list record_id if year==2020 & hrs_door2needle<0
list record_id frmscnt doh toh daetae reperfdt mins_door2needle hrs_door2needle if year==2020 & hrs_door2needle<0

gen k=1

table k, c(p50 mins_door2needle p25 mins_door2needle p75 mins_door2needle min mins_door2needle max mins_door2needle)
table k, c(p50 hrs_door2needle p25 hrs_door2needle p75 hrs_door2needle min hrs_door2needle max hrs_door2needle)

ameans mins_door2needle
ameans hrs_door2needle

table k, c(p50 hrs_door2needle p25 hrs_door2needle p75 hrs_door2needle min hrs_door2needle max hrs_door2needle)
** 1.7 hours seen - 1 hr 42 mins
restore

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