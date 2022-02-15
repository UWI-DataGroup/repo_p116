cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.3_heart_cvd_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY
    //  date first created:     26-Jan-2022
    //  date last modified:     26-Jan-2022
	//  analysis:               Heart 2020 dataset for Annual Report
    //  algorithm task          Performing Heart 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to Motality Statistics 
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
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
** 4794 as of 26-Jan-2022

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

**Case Fatality Rate at 28 day
** 79/291
tab f1vstatus year if hosp==1
tab abstracted year,miss
dis 79/291



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