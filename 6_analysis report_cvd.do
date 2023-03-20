** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          6_analysis report_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-MAR-2023
    // 	date last modified      19-MAR-2023
    //  algorithm task          Creating MS Word document with 2021 statistical + figure outputs for 2021 annual report
    //  status                  Pending
    //  objective               To have methods, tables, figures and text in an easy-to-use format for the report writer
    //  methods                 Use putdocx, tabout and Stata memory commands to export results to MS Word
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
    log using "`logpath'\6_analysis report_cvd.smcl", replace
** HEADER -----------------------------------------------------


*********************************
**  SUMMARY STATISTICS - HEART **
*********************************
** Annual report: Table 1.1
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467

** POPULATION
gen poptot_2021=281207

** REGISTRATIONS (Number of registrations) + RATE per population
egen hregtot_2021=count(sd_etype) if sd_eyear==2021
gen hregtotper_2021=hregtot_2021/poptot_2021*100
format hregtotper_2021 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
//JC 15mar2023: per discussion with NS via WA, I will output both definitions used by BNR for hospital admission over the years
** A&E + Ward
egen hreghosptot_2021=count(sd_etype) if sd_admstatus!=3 & sd_admstatus!=4
gen hreghosptotper_2021=hreghosptot_2021/hregtot_2021*100
format hreghosptotper_2021 %02.0f
** WARD only
egen hreghosptot_ward_2021=count(sd_etype) if sd_admstatus==1
gen hreghosptotper_ward_2021=hreghosptot_ward_2021/hregtot_2021*100
format hreghosptotper_ward_2021 %02.0f


** In-hospital CFR (Case Fatality Rate for fully abstracted cases)
egen fabstot_2021=count(sd_etype) if sd_absstatus==1
egen hcfrtot_2021=count(sd_etype) if sd_absstatus==1 & vstatus==2
gen hcfrtotper_2021=hcfrtot_2021/fabstot_2021*100
format hcfrtotper_2021 %02.0f

** DCOs (Death Certificate Only)
egen hdcotot_2021=count(sd_etype) if sd_casetype==2
gen hdcototper_2021=hdcotot_2021/hregtot_2021*100
format hdcototper_2021 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 5b_analysis summ_heart.do)
** A&E
append using "`datapath'\version03\2-working\los_ae_heart"
** Ward
append using "`datapath'\version03\2-working\los_ward_heart"


** Re-arrange dataset
gen id=_n
keep id hregtot_2021 hregtotper_2021 hreghosptot_2021 hreghosptotper_2021 hreghosptot_ward_2021 hreghosptotper_ward_2021 hcfrtot_2021 hcfrtotper_2021 hdcotot_2021 hdcototper_2021 medianlos_ae range_lower_ae range_upper_ae medianlos_ward range_lower_ward range_upper_ward

order id
fillmissing hregtot_2021 hregtotper_2021 hreghosptot_2021 hreghosptotper_2021 hreghosptot_ward_2021 hreghosptotper_ward_2021 hcfrtot_2021 hcfrtotper_2021 hdcotot_2021 hdcototper_2021 medianlos_ae range_lower_ae range_upper_ae medianlos_ward range_lower_ward range_upper_ward

gen title=1 if hregtot_2021!=. & id==1
order id title

replace title=2 if hregtotper_2021!=. & id==2
replace title=3 if hreghosptot_2021!=. & id==3
replace title=4 if hreghosptotper_2021!=. & id==4
replace title=5 if hreghosptot_ward_2021!=. & id==5
replace title=6 if hreghosptotper_ward_2021!=. & id==6
replace title=7 if hcfrtot_2021!=. & id==7
replace title=8 if hcfrtotper_2021!=. & id==8
replace title=9 if hdcotot_2021!=. & id==9
replace title=10 if hdcototper_2021!=. & id==10
replace title=11 if medianlos_ae!=. & id==11
replace title=12 if range_lower_ae!=. & id==12
replace title=13 if range_upper_ae!=. & id==13
replace title=14 if medianlos_ward!=. & id==14
replace title=15 if range_lower_ward!=. & id==15
replace title=16 if range_upper_ward!=. & id==16


label define title_lab 1 "Number of registrations(1)" 2 "Rate per population(2)" 3 "Hospital admissions A&E + WARD (percentage admitted)(3)" 4 "percentage admitted A&E + WARD" 5 "Hospital admissions WARD (percentage admitted)(3)" 6 "percentage admitted WARD" 7 "In-hospital case fatality rate (cases with full information),n(%)(4)" 8 "CFR(percentage)" 9 "Death Certificate Only (DCO)(5)" 10 "DCO percentage" 11 "Median (range) length of hospital stay A&E (days)(6)" 12 "Range (lower) length of hospital stay A&E (days)" 13 "Range (upper) length of hospital stay A&E (days)" 14 "Median (range) length of hospital stay WARD (days)(6)" 15 "Range (lower) length of hospital stay WARD (days)" 16 "Range (upper) length of hospital stay WARD (days)" ,modify
label values title title_lab
label var title "Title"

*-------------------------------------------------------------------------------

tab title ,m
drop if title==. // deleted
sort title
drop id
gen id=_n
order id title hregtot_2021

** Convert the stats into string allowing for placing percentages next to totals
tostring hregtot_2021 ,replace
gen hregtotper_2021_1=string(hregtotper_2021, "%04.2f")
drop hregtotper_2021
rename hregtotper_2021_1 hregtotper_2021

tostring hreghosptot_2021 ,replace
gen hreghosptotper_2021_1=string(hreghosptotper_2021, "%02.0f")
drop hreghosptotper_2021
rename hreghosptotper_2021_1 hreghosptotper_2021

tostring hreghosptot_ward_2021 ,replace
gen hreghosptotper_ward_2021_1=string(hreghosptotper_ward_2021, "%02.0f")
drop hreghosptotper_ward_2021
rename hreghosptotper_ward_2021_1 hreghosptotper_ward_2021

gen hcfrtotper_2021_1=string(hcfrtotper_2021, "%02.0f")
drop hcfrtotper_2021
rename hcfrtotper_2021_1 hcfrtotper_2021

tostring hcfrtot_2021 ,replace
gen hdcototper_2021_1=string(hdcototper_2021, "%02.0f")
drop hdcototper_2021
rename hdcototper_2021_1 hdcototper_2021
tostring hdcotot_2021 ,replace

tostring medianlos_ae ,replace
tostring range_lower_ae ,replace
tostring range_upper_ae ,replace

tostring medianlos_ward ,replace
tostring range_lower_ward ,replace
tostring range_upper_ward ,replace

replace hregtot_2021=hregtotper_2021 if id==2
replace hregtot_2021=hreghosptot_2021 if id==3
replace hregtot_2021=hreghosptotper_2021 if id==4
replace hregtot_2021=hreghosptot_ward_2021 if id==5
replace hregtot_2021=hreghosptotper_ward_2021 if id==6
replace hregtot_2021=hcfrtot_2021 if id==7
replace hregtot_2021=hcfrtotper_2021 if id==8
replace hregtot_2021=hdcotot_2021 if id==9
replace hregtot_2021=hdcototper_2021 if id==10
replace hregtot_2021=medianlos_ae if id==11
replace hregtot_2021=range_lower_ae if id==12
replace hregtot_2021=range_upper_ae if id==13
replace hregtot_2021=medianlos_ward if id==14
replace hregtot_2021=range_lower_ward if id==15
replace hregtot_2021=range_upper_ward if id==16

gen hospadmpercent=hreghosptot_2021+" "+"("+hreghosptotper_2021+"%"+")"
replace hregtot_2021=hospadmpercent if id==3

gen hospadmpercent_ward=hreghosptot_ward_2021+" "+"("+hreghosptotper_ward_2021+"%"+")"
replace hregtot_2021=hospadmpercent_ward if id==5

gen cfrpercent=hcfrtot_2021+" "+"("+hcfrtotper_2021+"%"+")"
replace hregtot_2021=cfrpercent if id==7

gen dcopercent=hdcotot_2021+" "+"("+hdcototper_2021+"%"+")"
replace hregtot_2021=dcopercent if id==9

gen medianrange_ae=medianlos_ae+" "+"("+range_lower_ae+" "+"-"+" "+range_upper_ae+")"
replace hregtot_2021=medianrange_ae if id==11

gen medianrange_ward=medianlos_ward+" "+"("+range_lower_ward+" "+"-"+" "+range_upper_ward+")"
replace hregtot_2021=medianrange_ward if id==14


drop if id==4|id==6|id==8|id==10|id==12|id==13|id==15|id==16
drop id
gen id=_n
order id title hregtot_2021

keep id title hregtot_2021
rename hregtot_2021 Myocardial_Infarction
rename title Title
 
** Create dataset with summary stats for heart (Table 1.1.)
save "`datapath'\version03\3-output\summstats_heart", replace

clear


**********************************
**  SUMMARY STATISTICS - STROKE **
**********************************
** Annual report: Table 1.1
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //691

** POPULATION
gen poptot_2021=281207

******************
** STROKE (ALL) **
******************

** REGISTRATIONS (Number of registrations) + RATE per population
egen sregtot_2021=count(sd_etype) if sd_eyear==2021
gen sregtotper_2021=sregtot_2021/poptot_2021*100
format sregtotper_2021 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
//JC 15mar2023: per discussion with NS via WA, I will output both definitions used by BNR for hospital admission over the years
** A&E + Ward
egen sreghosptot_2021=count(sd_etype) if sd_admstatus!=3 & sd_admstatus!=4
gen sreghosptotper_2021=sreghosptot_2021/sregtot_2021*100
format sreghosptotper_2021 %02.0f
** WARD only
egen sreghosptot_ward_2021=count(sd_etype) if sd_admstatus==1
gen sreghosptotper_ward_2021=sreghosptot_ward_2021/sregtot_2021*100
format sreghosptotper_ward_2021 %02.0f


** In-hospital CFR (Case Fatality Rate for fully abstracted cases)
egen fabstot_2021=count(sd_etype) if sd_absstatus==1
egen scfrtot_2021=count(sd_etype) if sd_absstatus==1 & vstatus==2
gen scfrtotper_2021=scfrtot_2021/fabstot_2021*100
format scfrtotper_2021 %02.0f

** DCOs (Death Certificate Only)
egen sdcotot_2021=count(sd_etype) if sd_casetype==2
gen sdcototper_2021=sdcotot_2021/sregtot_2021*100
format sdcototper_2021 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 5c_analysis summ_stroke.do)
** A&E
append using "`datapath'\version03\2-working\los_ae_stroke_all"
** Ward
append using "`datapath'\version03\2-working\los_ward_stroke_all"


** Re-arrange dataset
gen id=_n
keep id sregtot_2021 sregtotper_2021 sreghosptot_2021 sreghosptotper_2021 sreghosptot_ward_2021 sreghosptotper_ward_2021 scfrtot_2021 scfrtotper_2021 sdcotot_2021 sdcototper_2021 medianlos_s_ae range_lower_s_ae range_upper_s_ae medianlos_s_ward range_lower_s_ward range_upper_s_ward

order id
fillmissing sregtot_2021 sregtotper_2021 sreghosptot_2021 sreghosptotper_2021 sreghosptot_ward_2021 sreghosptotper_ward_2021 scfrtot_2021 scfrtotper_2021 sdcotot_2021 sdcototper_2021 medianlos_s_ae range_lower_s_ae range_upper_s_ae medianlos_s_ward range_lower_s_ward range_upper_s_ward

gen title=1 if sregtot_2021!=. & id==1
order id title

replace title=2 if sregtotper_2021!=. & id==2
replace title=3 if sreghosptot_2021!=. & id==3
replace title=4 if sreghosptotper_2021!=. & id==4
replace title=5 if sreghosptot_ward_2021!=. & id==5
replace title=6 if sreghosptotper_ward_2021!=. & id==6
replace title=7 if scfrtot_2021!=. & id==7
replace title=8 if scfrtotper_2021!=. & id==8
replace title=9 if sdcotot_2021!=. & id==9
replace title=10 if sdcototper_2021!=. & id==10
replace title=11 if medianlos_s_ae!=. & id==11
replace title=12 if range_lower_s_ae!=. & id==12
replace title=13 if range_upper_s_ae!=. & id==13
replace title=14 if medianlos_s_ward!=. & id==14
replace title=15 if range_lower_s_ward!=. & id==15
replace title=16 if range_upper_s_ward!=. & id==16


label define title_lab 1 "Number of registrations(1)" 2 "Rate per population(2)" 3 "Hospital admissions A&E + WARD (percentage admitted)(3)" 4 "percentage admitted A&E + WARD" 5 "Hospital admissions WARD (percentage admitted)(3)" 6 "percentage admitted WARD" 7 "In-hospital case fatality rate (cases with full information),n(%)(4)" 8 "CFR(percentage)" 9 "Death Certificate Only (DCO)(5)" 10 "DCO percentage" 11 "Median (range) length of hospital stay A&E (days)(6)" 12 "Range (lower) length of hospital stay A&E (days)" 13 "Range (upper) length of hospital stay A&E (days)" 14 "Median (range) length of hospital stay WARD (days)(6)" 15 "Range (lower) length of hospital stay WARD (days)" 16 "Range (upper) length of hospital stay WARD (days)" ,modify
label values title title_lab
label var title "Title"

*-------------------------------------------------------------------------------

tab title ,m
drop if title==. // deleted
sort title
drop id
gen id=_n
order id title sregtot_2021

** Convert the stats into string allowing for placing percentages next to totals
tostring sregtot_2021 ,replace
gen sregtotper_2021_1=string(sregtotper_2021, "%04.2f")
drop sregtotper_2021
rename sregtotper_2021_1 sregtotper_2021

tostring sreghosptot_2021 ,replace
gen sreghosptotper_2021_1=string(sreghosptotper_2021, "%02.0f")
drop sreghosptotper_2021
rename sreghosptotper_2021_1 sreghosptotper_2021

tostring sreghosptot_ward_2021 ,replace
gen sreghosptotper_ward_2021_1=string(sreghosptotper_ward_2021, "%02.0f")
drop sreghosptotper_ward_2021
rename sreghosptotper_ward_2021_1 sreghosptotper_ward_2021

gen scfrtotper_2021_1=string(scfrtotper_2021, "%02.0f")
drop scfrtotper_2021
rename scfrtotper_2021_1 scfrtotper_2021

tostring scfrtot_2021 ,replace
gen sdcototper_2021_1=string(sdcototper_2021, "%02.0f")
drop sdcototper_2021
rename sdcototper_2021_1 sdcototper_2021
tostring sdcotot_2021 ,replace

tostring medianlos_s_ae ,replace
tostring range_lower_s_ae ,replace
tostring range_upper_s_ae ,replace

tostring medianlos_s_ward ,replace
tostring range_lower_s_ward ,replace
tostring range_upper_s_ward ,replace

replace sregtot_2021=sregtotper_2021 if id==2
replace sregtot_2021=sreghosptot_2021 if id==3
replace sregtot_2021=sreghosptotper_2021 if id==4
replace sregtot_2021=sreghosptot_ward_2021 if id==5
replace sregtot_2021=sreghosptotper_ward_2021 if id==6
replace sregtot_2021=scfrtot_2021 if id==7
replace sregtot_2021=scfrtotper_2021 if id==8
replace sregtot_2021=sdcotot_2021 if id==9
replace sregtot_2021=sdcototper_2021 if id==10
replace sregtot_2021=medianlos_s_ae if id==11
replace sregtot_2021=range_lower_s_ae if id==12
replace sregtot_2021=range_upper_s_ae if id==13
replace sregtot_2021=medianlos_s_ward if id==14
replace sregtot_2021=range_lower_s_ward if id==15
replace sregtot_2021=range_upper_s_ward if id==16

gen hospadmpercent_s=sreghosptot_2021+" "+"("+sreghosptotper_2021+"%"+")"
replace sregtot_2021=hospadmpercent_s if id==3

gen hospadmpercent_s_ward=sreghosptot_ward_2021+" "+"("+sreghosptotper_ward_2021+"%"+")"
replace sregtot_2021=hospadmpercent_s_ward if id==5

gen cfrpercent_s=scfrtot_2021+" "+"("+scfrtotper_2021+"%"+")"
replace sregtot_2021=cfrpercent_s if id==7

gen dcopercent_s=sdcotot_2021+" "+"("+sdcototper_2021+"%"+")"
replace sregtot_2021=dcopercent_s if id==9

gen medianrange_s_ae=medianlos_s_ae+" "+"("+range_lower_s_ae+" "+"-"+" "+range_upper_s_ae+")"
replace sregtot_2021=medianrange_s_ae if id==11

gen medianrange_s_ward=medianlos_s_ward+" "+"("+range_lower_s_ward+" "+"-"+" "+range_upper_s_ward+")"
replace sregtot_2021=medianrange_s_ward if id==14


drop if id==4|id==6|id==8|id==10|id==12|id==13|id==15|id==16
drop id
gen id=_n
order id title sregtot_2021

keep id title sregtot_2021
rename sregtot_2021 Stroke_all
rename title Title
 
** Create dataset with summary stats for all strokes (Table 1.1.)
save "`datapath'\version03\3-output\summstats_stroke_all", replace

clear


*************************
** STROKE (FIRST EVER) **
*************************
** Annual report: Table 1.1
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //248

** POPULATION
gen poptot_2021=281207

** REGISTRATIONS (Number of registrations) + RATE per population
egen fesregtot_2021=count(sd_etype) if sd_fes==1
gen fesregtotper_2021=fesregtot_2021/poptot_2021*100
format fesregtotper_2021 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
//JC 15mar2023: per discussion with NS via WA, I will output both definitions used by BNR for hospital admission over the years
** A&E + Ward
egen fesreghosptot_2021=count(sd_etype) if sd_admstatus!=3 & sd_admstatus!=4 & sd_fes==1
gen fesreghosptotper_2021=fesreghosptot_2021/fesregtot_2021*100
format fesreghosptotper_2021 %02.0f
** WARD only
egen fesreghosptot_ward_2021=count(sd_etype) if sd_admstatus==1 & sd_fes==1
gen fesreghosptotper_ward_2021=fesreghosptot_ward_2021/fesregtot_2021*100
format fesreghosptotper_ward_2021 %02.0f


** In-hospital CFR (Case Fatality Rate for fully abstracted cases)
egen fabstot_2021=count(sd_etype) if sd_absstatus==1 & sd_fes==1
egen fescfrtot_2021=count(sd_etype) if sd_absstatus==1 & vstatus==2 & sd_fes==1
gen fescfrtotper_2021=fescfrtot_2021/fabstot_2021*100
format fescfrtotper_2021 %02.0f

** DCOs (Death Certificate Only)
egen fesdcotot_2021=count(sd_etype) if sd_casetype==2 & sd_fes==1
gen fesdcototper_2021=fesdcotot_2021/fesregtot_2021*100
format fesdcototper_2021 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 5c_analysis summ_stroke.do)
** A&E
append using "`datapath'\version03\2-working\los_ae_stroke_fes"
** Ward
append using "`datapath'\version03\2-working\los_ward_stroke_fes"


** Re-arrange dataset
gen id=_n
keep id fesregtot_2021 fesregtotper_2021 fesreghosptot_2021 fesreghosptotper_2021 fesreghosptot_ward_2021 fesreghosptotper_ward_2021 fescfrtot_2021 fescfrtotper_2021 fesdcotot_2021 fesdcototper_2021 medianlos_fes_ae range_lower_fes_ae range_upper_fes_ae medianlos_fes_ward range_lower_fes_ward range_upper_fes_ward

order id
fillmissing fesregtot_2021 fesregtotper_2021 fesreghosptot_2021 fesreghosptotper_2021 fesreghosptot_ward_2021 fesreghosptotper_ward_2021 fescfrtot_2021 fescfrtotper_2021 fesdcotot_2021 fesdcototper_2021 medianlos_fes_ae range_lower_fes_ae range_upper_fes_ae medianlos_fes_ward range_lower_fes_ward range_upper_fes_ward

gen title=1 if fesregtot_2021!=. & id==1
order id title

replace title=2 if fesregtotper_2021!=. & id==2
replace title=3 if fesreghosptot_2021!=. & id==3
replace title=4 if fesreghosptotper_2021!=. & id==4
replace title=5 if fesreghosptot_ward_2021!=. & id==5
replace title=6 if fesreghosptotper_ward_2021!=. & id==6
replace title=7 if fescfrtot_2021!=. & id==7
replace title=8 if fescfrtotper_2021!=. & id==8
replace title=9 if fesdcotot_2021!=. & id==9
replace title=10 if fesdcototper_2021!=. & id==10
replace title=11 if medianlos_fes_ae!=. & id==11
replace title=12 if range_lower_fes_ae!=. & id==12
replace title=13 if range_upper_fes_ae!=. & id==13
replace title=14 if medianlos_fes_ward!=. & id==14
replace title=15 if range_lower_fes_ward!=. & id==15
replace title=16 if range_upper_fes_ward!=. & id==16


label define title_lab 1 "Number of registrations(1)" 2 "Rate per population(2)" 3 "Hospital admissions A&E + WARD (percentage admitted)(3)" 4 "percentage admitted A&E + WARD" 5 "Hospital admissions WARD (percentage admitted)(3)" 6 "percentage admitted WARD" 7 "In-hospital case fatality rate (cases with full information),n(%)(4)" 8 "CFR(percentage)" 9 "Death Certificate Only (DCO)(5)" 10 "DCO percentage" 11 "Median (range) length of hospital stay A&E (days)(6)" 12 "Range (lower) length of hospital stay A&E (days)" 13 "Range (upper) length of hospital stay A&E (days)" 14 "Median (range) length of hospital stay WARD (days)(6)" 15 "Range (lower) length of hospital stay WARD (days)" 16 "Range (upper) length of hospital stay WARD (days)" ,modify
label values title title_lab
label var title "Title"

*-------------------------------------------------------------------------------

tab title ,m
drop if title==. // deleted
sort title
drop id
gen id=_n
order id title fesregtot_2021

** Convert the stats into string allowing for placing percentages next to totals
tostring fesregtot_2021 ,replace
gen fesregtotper_2021_1=string(fesregtotper_2021, "%04.2f")
drop fesregtotper_2021
rename fesregtotper_2021_1 fesregtotper_2021

tostring fesreghosptot_2021 ,replace
gen fesreghosptotper_2021_1=string(fesreghosptotper_2021, "%02.0f")
drop fesreghosptotper_2021
rename fesreghosptotper_2021_1 fesreghosptotper_2021

tostring fesreghosptot_ward_2021 ,replace
gen fesreghosptotper_ward_2021_1=string(fesreghosptotper_ward_2021, "%02.0f")
drop fesreghosptotper_ward_2021
rename fesreghosptotper_ward_2021_1 fesreghosptotper_ward_2021

gen fescfrtotper_2021_1=string(fescfrtotper_2021, "%02.0f")
drop fescfrtotper_2021
rename fescfrtotper_2021_1 fescfrtotper_2021

tostring fescfrtot_2021 ,replace
gen fesdcototper_2021_1=string(fesdcototper_2021, "%02.0f")
drop fesdcototper_2021
rename fesdcototper_2021_1 fesdcototper_2021
tostring fesdcotot_2021 ,replace

tostring medianlos_fes_ae ,replace
tostring range_lower_fes_ae ,replace
tostring range_upper_fes_ae ,replace

tostring medianlos_fes_ward ,replace
tostring range_lower_fes_ward ,replace
tostring range_upper_fes_ward ,replace

replace fesregtot_2021=fesregtotper_2021 if id==2
replace fesregtot_2021=fesreghosptot_2021 if id==3
replace fesregtot_2021=fesreghosptotper_2021 if id==4
replace fesregtot_2021=fesreghosptot_ward_2021 if id==5
replace fesregtot_2021=fesreghosptotper_ward_2021 if id==6
replace fesregtot_2021=fescfrtot_2021 if id==7
replace fesregtot_2021=fescfrtotper_2021 if id==8
replace fesregtot_2021=fesdcotot_2021 if id==9
replace fesregtot_2021=fesdcototper_2021 if id==10
replace fesregtot_2021=medianlos_fes_ae if id==11
replace fesregtot_2021=range_lower_fes_ae if id==12
replace fesregtot_2021=range_upper_fes_ae if id==13
replace fesregtot_2021=medianlos_fes_ward if id==14
replace fesregtot_2021=range_lower_fes_ward if id==15
replace fesregtot_2021=range_upper_fes_ward if id==16

gen hospadmpercent_fes=fesreghosptot_2021+" "+"("+fesreghosptotper_2021+"%"+")"
replace fesregtot_2021=hospadmpercent_fes if id==3

gen hospadmpercent_fes_ward=fesreghosptot_ward_2021+" "+"("+fesreghosptotper_ward_2021+"%"+")"
replace fesregtot_2021=hospadmpercent_fes_ward if id==5

gen cfrpercent_fes=fescfrtot_2021+" "+"("+fescfrtotper_2021+"%"+")"
replace fesregtot_2021=cfrpercent_fes if id==7

//gen dcopercent_fes=fesdcotot_2021+" "+"("+fesdcototper_2021+"%"+")"
//replace fesregtot_2021=dcopercent_s if id==9

gen dcopercent_fes="n/a"
replace fesregtot_2021=dcopercent_fes if id==9

gen medianrange_fes_ae=medianlos_fes_ae+" "+"("+range_lower_fes_ae+" "+"-"+" "+range_upper_fes_ae+")"
replace fesregtot_2021=medianrange_fes_ae if id==11

gen medianrange_fes_ward=medianlos_fes_ward+" "+"("+range_lower_fes_ward+" "+"-"+" "+range_upper_fes_ward+")"
replace fesregtot_2021=medianrange_fes_ward if id==14


drop if id==4|id==6|id==8|id==10|id==12|id==13|id==15|id==16
drop id
gen id=_n
order id title fesregtot_2021

keep id title fesregtot_2021
rename fesregtot_2021 Stroke_first_ever
rename title Title
 
** Create dataset with summary stats for first ever strokes (Table 1.1.)
save "`datapath'\version03\3-output\summstats_stroke_fes", replace


merge 1:1 id using "`datapath'\version03\3-output\summstats_heart"
drop _merge
merge 1:1 id using "`datapath'\version03\3-output\summstats_stroke_all"
drop _merge id

order Title Myocardial_Infarction Stroke_all Stroke_first_ever

** Remove datasets to save on SharePoint storage space
erase "`datapath'\version03\3-output\summstats_heart.dta"
erase "`datapath'\version03\3-output\summstats_stroke_all.dta"
erase "`datapath'\version03\3-output\summstats_stroke_fes.dta"

** Create dataset with summary stats for heart, all strokes + first ever strokes (Table 1.1.)
save "`datapath'\version03\2-working\summstats", replace

preserve
				****************************
				*	   MS WORD REPORT      *
				* ANNUAL REPORT STATISTICS *
				****************************
putdocx clear
putdocx begin, footer(foot1)
putdocx paragraph, tofooter(foot1)
putdocx text ("Page ")
putdocx pagenumber
putdocx paragraph, style(Title)
putdocx text ("CVD 2021 Annual Report: Stata Results"), bold
putdocx textblock begin
Date First Prepared + Last Updated: 16-MAR-2023 + 20-MAR-2023, respectively
putdocx textblock end
putdocx textblock begin
Prepared by: JC using Stata 17.0
putdocx textblock end
putdocx textblock begin
Data source: REDCap's BNRCVD_CORE database
putdocx textblock end
putdocx textblock begin
Data release date: 07-Dec-2022
putdocx textblock end
putdocx textblock begin
Stata code file: 6_analysis results_cvd.do
putdocx textblock end
putdocx textblock begin
Dataset path: repo_data/data_p116/version03
putdocx textblock end
putdocx textblock begin
Dofile path (VS Code branch): repo_p116/2021AnnualReport
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Methods"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Incidence dataset used for heart analyses: "p116\version03\3-output\2021_prep analysis_deidentified_heart"
putdocx textblock end
putdocx textblock begin
(2) Incidence dataset used for stroke analyses: "p116\version03\3-output\2021_prep analysis_deidentified_stroke".
putdocx textblock end
putdocx textblock begin
(3) Population datasets used for heart and stroke analyses: WPP populations generated for 2021 (see: 4_population_cvd.do) + ("p116\version03\2-working\pop_wpp_yyyy-5") + ("p116\version03\2-working\pop_wpp_yyyy-10")
putdocx textblock end
putdocx textblock begin
The above population datasets were used in conjunction with this WHO dataset when using distrate for ASIRs and ASMRs: "p116\version03\3-output\who2000_5" and "p116\version03\3-output\who2000_10-2".
putdocx textblock end
putdocx textblock begin
(4) Dofiles used for heart and stroke analyses: VS Code branch 2021AnnualReport for repo_p116. Each dofile used in the below tables and outputs is listed below each title. 
putdocx textblock end
putdocx textblock begin
(5) Dofile labelled '0_dofile descriptions.do' has a summary of all the cleaning and analysis dofiles in addition to some notes which are listed below. 
putdocx textblock end
putdocx textblock begin
NOTE1: to differentiate between data missing from patient notes (i.e. 99, 999 or 9999) VS data missing from database, code 99999 has been used to signify data missing in CVDdb
putdocx textblock end
putdocx textblock begin
NOTE2: variable names prefixed with 'sd_' mean these are Stata derived variables (only age5 and age_10 variables are missing this prefix)
putdocx textblock end
putdocx textblock begin
NOTE3: variable names prefixed with 'dd_' mean these are Death Data derived variables
putdocx textblock end
putdocx textblock begin
NOTE4: there are several vital status variables as each document vital status at different points during the event: 
slc = last known/contact vital status; 
vstatus = vital status at discharge from hospital; 
f1vstatus = vital status at day 28 post event
putdocx textblock end
putdocx textblock begin
NOTE5: labels prefixed with 'Death Data:' mean these are Death Data derived variables
putdocx textblock end
putdocx textblock begin
NOTE6: labels prefixed with 'Incidence Data:' mean these are Incidence Data/REDCap BNRCVD_CORE database variables. All incidence variable labels are NOT prefixed with 'Incidence Data:' due to large number of variables. All death data and Stata derived labels are prefixed so any labels that are missing a prefix are from the incidence database.
putdocx textblock end
putdocx textblock begin
NOTE7: both the cleaning and analysis dofiles are in sequential order so they should be executed in the order in which they appear
putdocx textblock end
putdocx textblock begin
NOTE8: 2021: the y-axis for age-sex stratified incidence rate graphs are distributed by 1000 with a range of 0 to 4000; 
2020: the y-axis for age-sex stratified incidence rate graphs are distributed by 500 with a range of 0 to 2000; 
This applies to the HEART graphs as the graphs looked skewed for 2021.
putdocx textblock end
putdocx textblock begin
NOTE9: 2021: the y-axis for age-sex stratified incidence rate graphs are distributed by 1500 with a range of 0 to 6000; 
2020: the y-axis for age-sex stratified incidence rate graphs are distributed by 500 with a range of 0 to 2000; 
This applies to the STROKE graphs as the graphs looked skewed for 2021.
putdocx textblock end
putdocx textblock begin
NOTE10: there is one case wherein sourcetype = Community (in the stroke dataset)
putdocx textblock end
putdocx textblock begin
NOTE11: 2021 ASMRs will most likely not be comparable with ASMRs from previous years as previous years used deaths from the incidence dataset vs 2021 that used deaths from the death dataset.
putdocx textblock end
putdocx textblock begin
NOTE12: 2021 population number is lower than previous years as UN-WPP may have adjusted estiamtes due to COVID-19.
putdocx textblock end


putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Summary Statistics (Dofile: 5b_analysis summ_heart.do + 5c_analysis summ_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.1 Summary Statistics for BNR-CVD, 2021 (Population=281,207)"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Title Myocardial_Infarction Stroke_all Stroke_first_ever), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)

putdocx textblock begin
(1) Total number of events registered or entered into the BNR CVD and Death databases; (2) Total number of registrations as a proportion of the population; (3) Total number of hospital admissions as a proportion of registrations - hospital admission defined in 2 ways: (a) A&E + WARD are those patients who were seen ONLY in A&E + those admitted to hospital ward (b) WARD are those patients admitted to hospital ward i.e. patients seen ONLY in A&E but not admitted to ward are excluded; (4) Case fatality rate in hospital for hospitalised patients as a proportion of cases that were fully abstracted; (5) Total number of deaths collected from death registry that were not abstracted as a proportion of registrations; (6) Median and range of length of hospital stay (in days) - defined in 2 ways: (a) from date seen in A&E to discharge/death (b) from date admitted to WARD to discharge/death.
putdocx textblock end

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", replace
putdocx clear

restore

clear

********************************************************* HEART *******************************************************************
preserve
use "`datapath'\version03\2-working\ASIRs_age10_heart", clear
drop percent asir ui_range

append using "`datapath'\version03\2-working\CIRsASIRs_total_age10_heart"
drop percent asir ui_*

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort year sex
save "`datapath'\version03\2-working\CIRs_heart", replace
drop cir

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("AMI: Burden"), bold
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Cases and Crude Incidence Rates (Dofile: 5d_analysis IRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.1 Number of men and women with acute MI by year in Barbados. 2021"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


***********
** AGE10 **
***********
** JC 12may2022: SF uses excel to create CIR graphs so export this table to excel as well
preserve
use "`datapath'\version03\2-working\CIRs_heart", clear

gen cir1=string(cir, "%03.1f")
drop cir
rename cir1 cir


sort year sex

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel year sex number cir using "`datapath'\version03\3-output\2021AnnualReportCIR_`listdate'.xlsx", firstrow(variables) sheet(CIR_heart, replace) 

putexcel set "`datapath'\version03\3-output\2021AnnualReportCIR_`listdate'.xlsx", sheet(CIR_heart) modify
putexcel A1:D1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Sex"
putexcel C1 = "Number"
putexcel D1 = "CrudeIR(AGE10)"
putexcel save
restore


***********
** AGE10 **
***********
preserve
use "`datapath'\version03\2-working\CIRs_heart", clear

drop number
sort year sex

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Cases and Crude Incidence Rates (Dofile: 5d_analysis IRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.2 Crude incidence rate of men and women per 100,000 population with acute MI by year in Barbados. 2021"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex cir), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore


**********
** AGE5 **
**********
preserve
use "`datapath'\version03\2-working\ASIRs_age5_heart", clear
drop cir

append using "`datapath'\version03\2-working\CIRsASIRs_total_age5_heart"

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year
//gsort -sex -year

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Age-standardised Incidence + Mortality Rates (5-yr + 10yr bands) (Dofile: 5d_analysis IRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.2 ASIRs (INCIDENCE) of men and women per 100,000 population with acute MI or sudden cardiac death by year in Barbados. 2021"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE5"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asir ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


***********
** AGE10 **
***********
preserve
use "`datapath'\version03\2-working\ASIRs_age10_heart", clear
drop cir

append using "`datapath'\version03\2-working\CIRsASIRs_total_age10_heart"

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year
//gsort -sex -year

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asir ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

**********
** AGE5 **
**********
preserve
use "`datapath'\version03\2-working\ASMRs_age5_heart", clear

append using "`datapath'\version03\2-working\ASMRs_total_age5_heart"

replace sex=3 if sex==.

label drop sex_lab
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Age-standardised Incidence + Mortality Rates (5-yr + 10yr bands) (Dofile: 5f_analysis MRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.2 ASMRs (MORTALITY) of men and women per 100,000 population with acute MI or sudden cardiac death by year in Barbados. 2021"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE5"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

***********
** AGE10 **
***********
preserve
use "`datapath'\version03\2-working\ASMRs_age10_heart", clear

append using "`datapath'\version03\2-working\ASMRs_total_age10_heart"

replace sex=3 if sex==.

label drop sex_lab
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

**********
** AGE5 **
**********
preserve
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Age (5-yr + 10yr bands) and Gender Stratified Incidence Rates (Dofile: 1.1_heart_cvd_analysis.do + 5d_analysis IRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.3a Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2021 (N=467)"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE5"), bold font(Helvetica,10,"red")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2021_age-sex graph_age5_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

***********
** AGE10 **
***********
preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2021_age-sex graph_age10_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

***********
** AGE10 **
***********
preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 1.3b Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2020 (N=547)"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2020_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore



preserve
use "`datapath'\version03\2-working\symptoms_heart", clear
replace totsympts=0 if id!=1
replace totsympts_f=0 if id!=1
replace totsympts_m=0 if id!=1

sort hsym_ar

putdocx clear
putdocx begin

putdocx paragraph, style(Heading1)
putdocx text ("AMI: Symptoms and Risk Factors"), bold
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Symptoms (Dofile: 5h_analysis sym_heart.do)"), bold
putdocx paragraph, halign(center)
qui sum totsympts
local sum : display %3.0f `r(sum)'
putdocx text ("Table 1.3 Main presenting symptoms for acute MI patients in Barbados. Jan-Dec 2021 (N=`sum')"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(hsym_ar number_female percent_female number_male percent_male number_total percent_total), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

putdocx paragraph
qui sum totsympts_f
local sum : display %3.0f `r(sum)'
putdocx text ("Women - The number and percentage of women with a given symptom as a % of the number of women (N=`sum') with information for a specific year.")

putdocx paragraph
qui sum totsympts_m
local sum : display %3.0f `r(sum)'
putdocx text ("Men - The number and percentage of men with a given symptom as a % of the number of men (N=`sum') with information for a specific year.")

putdocx paragraph
qui sum totsympts
local sum : display %3.0f `r(sum)'
putdocx text ("Totals –The total number and percentage of patients (men & women) with a given symptom as a % of all patients (N=`sum') with information for a specific year.")


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\riskfactors_heart", clear

sort rf_ar

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Risk Factors (Dofile: 5j_analysis RFs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.4 Prevalence of known risk factors among hospitalised acute MI patients, 2021 (N=201)"), bold font(Helvetica,10,"blue")

rename rftype_ar rf_category
rename rf_ar risk_factor
putdocx table tbl1 = data(rf_category risk_factor number rf_percent denominator), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

putdocx paragraph
putdocx text ("n1 = denominator (i.e. total number reporting information about that risk factor). NR = Numbers too small for adequate representation")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\mort_heart", clear

sort mort_heart_ar

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("AMI: Mortality"), bold
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Secular trends in case fatality rates for AMI (Dofile: 5l_analysis CFRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.5 Mortality statistics for acute MI patients in Barbados, 2021"), bold font(Helvetica,10,"blue")

rename mort_heart_ar category
rename number year_2021
putdocx table tbl1 = data(category year_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)

putdocx textblock begin
(1) Total number of events registered or entered into the BNR CVD and Death databases; (2+3) Total number of hospital admissions as a proportion of registrations - hospital admission defined in 2 ways: (a) A&E + WARD are those patients who were seen ONLY in A&E + those admitted to hospital ward (b) WARD are those patients admitted to hospital ward i.e. patients seen ONLY in A&E but not admitted to ward are excluded; (4) Number of cases that were fully abstracted (5) Case fatality rate in hospital for hospitalised patients as a proportion of cases that were fully abstracted; (6+7) Total hospitalised deaths as a proportion of hospitalised cases as defined in the 2 ways above; (8) Case fatality rate at day 28 for cases that were fully abstracted;
putdocx textblock end

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\outcomes_heart", clear

sort outcomes_heart_ar

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Focus on acute MI in-hospital outcomes (Dofile: 5l_analysis CFRs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.5 Flow chart of vital status of acute MI patients admitted to the Queen Elizabeth Hospital in Barbados, 2021"), bold font(Helvetica,10,"blue")

rename outcomes_heart_ar category
rename number year_2021
putdocx table tbl1 = data(category year_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm1_asp24h_heart", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("AMI: Performance measures, 2021"), bold
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Performance measures for acute care (Dofile: 5n_analysis PMs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("PM 1: Documented aspirin use within the first 24 hours"), bold font(Helvetica,10,"blue")

putdocx paragraph
qui sum number_total
local sum : display %3.0f `r(sum)'
putdocx text ("Typically, the AHA Get with the Guidelines Program (GWGT) recognises performance of 85% or greater compliance on each performance measure11. Standards of care suggest that patients with acute myocardial infarction receive aspirin within the first 24 hours of arrival at hospital or first onset of symptoms (see Appendix B- Descriptions) In Barbados, in 2021, of the 185 cases that were fully abstracted, `sum'% were documented as having received aspirin. Of these `sum'%,")
qui sum adm2asp_percent
local sum : display %3.0f `r(sum)'
putdocx text (" `sum'% of patients received aspirin within 24 hours of arrival at hospital and")
qui sum onset2asp_percent
local sum : display %3.0f `r(sum)'
putdocx text (" `sum'% of patients received aspirin within 24 hours of first onset of symptoms.")

putdocx paragraph
putdocx text ("These results were assessed using the variable [asp___1] of the cases that were fully abstracted. Whether aspirin was given within 24 hrs was assessed using A&E admission date [dae] and Event date [edate] in comparison with Aspirin date [aspd]. I dropped any wherein aspirin date preceded admission or event date. I didn't use date and times in this output but the dofile where these were calculated has the date and times results but they did not differ greatly so I excluded them here in the interest of deadline to complete analysis.")

rename number_total aspirin_total
rename onset2asp onset2asp_total
rename adm2asp adm2asp_total
putdocx table tbl1 = data(asp___1 onset2asp_total onset2asp_percent adm2asp_total adm2asp_percent aspirin_total), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm2_stemi_heart", clear

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 2-Proportion of STEMI patients who received reperfusion via fibrinolysis (Dofile: 5n_analysis PMs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.6. Number of STEMI cases and proportion reperfused by gender"), bold font(Helvetica,10,"blue")

putdocx paragraph
qui sum number_total
local sum : display %3.0f `r(sum)'
putdocx text ("Of the `sum' hospitalised cases with full information in 2021,")
qui sum stemi_total
local sum : display %3.0f `r(sum)'
putdocx text ("`sum' persons were diagnosed with a STEMI.")

putdocx table tbl1 = data(reperfused_female stemi_female reperfused_male stemi_male reperfused_total stemi_total), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear



preserve
use "`datapath'\version03\2-working\pm3_heart", clear

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 3-Median time to reperfusion for STEMI (Dofile: 5n_analysis PMs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.7. 'Door to needle' times for hospitalised patients, 2021"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(category median_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm4_ecg_heart", clear


putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 4-Proportion of patients receiving an echocardiogram before discharge (Dofile: 5n_analysis PMs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.8. Proportion of patients receiving echocardiogram, 2021"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Timing female_num female_percent male_num male_percent total_num total_percent), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm5_asppla_heart", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 5-Documented aspirin prescribed at discharge (Dofile: 5n_analysis PMs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Proportion of patients receiving Aspirin/Antiplatelet Therapy at discharge, 2021"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below tables created a variable called 'Aspirin/Antiplatelet therapy' using the variable [aspdis] + [pladis] + [asp___2] to check for cases wherein [aspdis]!=yes/at discharge but antiplatelets [pladis]=yes/at discharge and same for aspirin used chronically [asp___2].")

rename asppla aspirin_antiplatelet
rename asppla_percent therapy_percent
putdocx table tbl1 = data(year aspdis aspirin_antiplatelet total_alive therapy_percent), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm6_statin_heart", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 6-Documented statins prescribed at discharge (Dofile: 5n_analysis PMs_heart.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Proportion of patients receiving statins at discharge, 2021"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("The 'Statins at discharge (of alive pts)'.")

putdocx paragraph, halign(center)
putdocx text ("2021"), bold font(Helvetica,10,"blue")
tab2docx statdis if vstatus==1

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

STOP
***************************************************** STROKE *************************************************************

preserve
use "`datapath'\version03\2-working\ASIRs_age10_stroke", clear
drop percent asir ui_range

append using "`datapath'\version03\2-working\CIRsASIRs_total_age10_stroke"
drop percent asir ui_*

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort year sex
save "`datapath'\version03\2-working\CIRs_stroke", replace
drop cir

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Stroke: Burden"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Cases and Crude Incidence Rates (Dofile: 5e_analysis IRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.1 Number of men and women with stroke by year in Barbados. 2021"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


***********
** AGE5 **
***********
** JC 12may2022: SF uses excel to create CIR graphs so export this table to excel as well
preserve
use "`datapath'\version03\2-working\CIRs_stroke", clear

gen cir1=string(cir, "%03.1f")
drop cir
rename cir1 cir

sort year sex

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel year sex number cir using "`datapath'\version03\3-output\2021AnnualReportCIR_`listdate'.xlsx", firstrow(variables) sheet(CIR_stroke, replace) 

putexcel set "`datapath'\version03\3-output\2021AnnualReportCIR_`listdate'.xlsx", sheet(CIR_stroke) modify
putexcel A1:D1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Sex"
putexcel C1 = "Number"
putexcel D1 = "CrudeIR(AGE5)"
putexcel save
restore


***********
** AGE10 **
***********
preserve
use "`datapath'\version03\2-working\CIRs_stroke", clear

drop number
sort year sex

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Cases and Crude Incidence Rates (Dofile: 5e_analysis IRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.2 Crude incidence rate of men and women with stroke by year in Barbados. 2021"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex cir), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

***********
** AGE5 **
***********
preserve
use "`datapath'\version03\2-working\ASIRs_age5_stroke", clear
drop cir

append using "`datapath'\version03\2-working\CIRsASIRs_total_age5_stroke"

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year
//gsort -sex -year

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Age-standardised Incidence + Mortality Rates (5-yr + 10yr bands) (Dofile: 5e_analysis IRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.1 ASIRs (INCIDENCE) of men and women per 100,000 population with stroke by year in Barbados. 2021"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE5"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asir ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

***********
** AGE10 **
***********
preserve
use "`datapath'\version03\2-working\ASIRs_age10_stroke", clear
drop cir

append using "`datapath'\version03\2-working\CIRsASIRs_total_age10_stroke"

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year
//gsort -sex -year

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asir ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

***********
** AGE5 **
***********
preserve
use "`datapath'\version03\2-working\ASMRs_age5_stroke", clear

append using "`datapath'\version03\2-working\ASMRs_total_age5_stroke"

replace sex=3 if sex==.

label drop sex_lab
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Age-standardised Incidence + Mortality Rates (5-yr + 10yr bands) (Dofile: 5g_analysis MRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.1 ASMRs (MORTALITY) of men and women per 100,000 population with stroke by year in Barbados. 2021"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE5"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

***********
** AGE10 **
***********
preserve
use "`datapath'\version03\2-working\ASMRs_age10_stroke", clear

append using "`datapath'\version03\2-working\ASMRs_total_age10_stroke"

replace sex=3 if sex==.

label drop sex_lab
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

**********
** AGE5 **
**********
preserve
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Age (5-yr + 10yr bands) and Gender Stratified Incidence Rates (Dofile: 1.1_stroke_cvd_analysis.do + 5e_analysis IRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.3a Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2021 (N=691)"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE5"), bold font(Helvetica,10,"red")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2021_age-sex graph_age5_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

***********
** AGE10 **
***********
preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2021_age-sex graph_age10_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

***********
** AGE10 **
***********
preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 2.3b Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2020 (N=700)"), bold font(Helvetica,10,"blue")
putdocx paragraph, halign(center)
putdocx text ("AGE10"), bold font(Helvetica,10,"red")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2020_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version03\2-working\subtypes_stroke", clear

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Category/Subtypes (Dofile: 5i_analysis sym_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.2 Stroke subtypes in Barbados, 2021"), bold font(Helvetica,10,"blue")

qui sum total_abs_2021
local sum : display %3.0f `r(sum)'
putdocx text (" N=`sum')"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Stroke_Category num_f_2021 percent_f_2021 num_m_2021 percent_m_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version03\2-working\symptoms_stroke", clear
replace totsympts=0 if id!=1
replace totsympts_f=0 if id!=1
replace totsympts_m=0 if id!=1

sort ssym_ar

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Stroke: Symptoms and Risk Factors"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Symptoms (Dofile: 5i_analysis sym_stroke.do)"), bold
putdocx paragraph, halign(center)
qui sum totsympts
local sum : display %3.0f `r(sum)'
putdocx text ("Table 2.3 Main presenting symptoms for stroke patients in Barbados. Jan-Dec 2021 (N=`sum')"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(ssym_ar number_female percent_female number_male percent_male number_total percent_total), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

putdocx paragraph
qui sum totsympts_f
local sum : display %3.0f `r(sum)'
putdocx text ("Women - The number and percentage of women with a given symptom as a % of the number of women (N=`sum') with information for a specific year.")

putdocx paragraph
qui sum totsympts_m
local sum : display %3.0f `r(sum)'
putdocx text ("Men - The number and percentage of men with a given symptom as a % of the number of men (N=`sum') with information for a specific year.")

putdocx paragraph
qui sum totsympts
local sum : display %3.0f `r(sum)'
putdocx text ("Totals –The total number and percentage of patients (men & women) with a given symptom as a % of all patients (N=`sum') with information for a specific year.")


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\riskfactors_stroke", clear

sort rf_ar

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Risk Factors (Dofile: 5k_analysis RFs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.4 Prevalence of known risk factors among hospitalised stroke patients, 2021 (N=528)"), bold font(Helvetica,10,"blue")

rename rftype_ar rf_category
rename rf_ar risk_factor
putdocx table tbl1 = data(rf_category risk_factor number rf_percent denominator), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

putdocx paragraph
putdocx text ("n1 = denominator (i.e. total number reporting information about that risk factor). NR = Numbers too small for adequate representation")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear



preserve
use "`datapath'\version03\2-working\mort_stroke", clear

sort mort_stroke_ar

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Stroke: Mortality"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Secular trends in Stroke Mortality (Dofile: 5m_analysis CFRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.5 Mortality statistics for stroke patients in Barbados, 2021"), bold font(Helvetica,10,"blue")

rename mort_stroke_ar category
rename number year_2021
putdocx table tbl1 = data(category year_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)
putdocx table tbl1(1,9), bold shading(lightgray)
putdocx table tbl1(1,10), bold shading(lightgray)
putdocx table tbl1(1,11), bold shading(lightgray)
//putdocx table tbl1(1,12), bold shading(lightgray)

putdocx textblock begin
(1) Total number of events registered or entered into the BNR CVD and Death databases; (2+3) Total number of hospital admissions as a proportion of registrations - hospital admission defined in 2 ways: (a) A&E + WARD are those patients who were seen ONLY in A&E + those admitted to hospital ward (b) WARD are those patients admitted to hospital ward i.e. patients seen ONLY in A&E but not admitted to ward are excluded; (4) Number of cases that were fully abstracted (5) Case fatality rate in hospital for hospitalised patients as a proportion of cases that were fully abstracted; (6+7) Total hospitalised deaths as a proportion of hospitalised cases as defined in the 2 ways above; (8) Case fatality rate at day 28 for cases that were fully abstracted;
putdocx textblock end

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\outcomes_stroke", clear

sort outcomes_stroke_ar

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Focus on acute stroke in-hospital outcomes (Dofile: 5m_analysis CFRs_stroke.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.5 Flow chart of vital status of stroke patients admitted to the Queen Elizabeth Hospital in Barbados, 2021"), bold font(Helvetica,10,"blue")

rename outcomes_stroke_ar category
rename number year_2021
putdocx table tbl1 = data(category year_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

/*
preserve
use "`datapath'\version03\2-working\pm1_stroke", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Stroke: Performance measures, 2020"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Performance measures for acute care (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("PM 1: Proportion of patients receiving reperfusion"), bold font(Helvetica,10,"blue")

putdocx paragraph
putdocx text ("With the opening of the Stroke Unit in 2015, the Queen Elizabeth Hospital was able to offer IV TPA (a 'clot busting' drug – see Appendix B) to patients arriving within 2 hours of onset of symptoms.")
putdocx paragraph
putdocx text ("Below tables use the syntax: tab reperf year if stype == 1, col")
putdocx paragraph, halign(center)
putdocx text ("2017"), bold font(Helvetica,10,"blue")
tab2docx reperf if stype==1 & year==2017
putdocx paragraph, halign(center)
putdocx text ("2018"), bold font(Helvetica,10,"blue")
tab2docx reperf if stype==1 & year==2018
putdocx paragraph, halign(center)
putdocx text ("2019"), bold font(Helvetica,10,"blue")
tab2docx reperf if stype==1 & year==2019
putdocx paragraph, halign(center)
putdocx text ("2020"), bold font(Helvetica,10,"blue")
tab2docx reperf if stype==1 & year==2020

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm2_stroke", clear

sort year

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("Stroke: PM 2-Proportion of patients with ischaemic stroke who receive anti-thrombotic therapy by the end of hospital stay (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.6. Proportion of persons with acute ischaemic events receiving anti- thrombotic therapy by year"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year female percent_female male percent_male), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm3_stroke", clear

sort year

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("Stroke: PM 3-Percent of patients with an ischaemic stroke prescribed anti-thrombotic therapy at discharge (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.7. Proportion of ischaemic stroke cases receiving appropriate medications (Anti-thrombotics) at discharge"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year female percent_female male percent_male), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm4_stroke", clear

sort year

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("Stroke: PM 4-Statin Prescribed at Discharge: Percent of ischaemic stroke who are discharged on Statin medication (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.7. Proportion of ischaemic stroke cases receiving appropriate medications (Statins) at discharge"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year female percent_female male percent_male), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

****************************************************************** Heart + Stroke ***********************************************************************************************
preserve
use "`datapath'\version03\2-working\addanalyses_ct", clear

sort registry

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("AMI & Stroke: Additional Analyses"), bold
putdocx paragraph, style(Heading2)
putdocx text ("AMI & Stroke: % CTs for those discharged alive + % persons <70 with AMI and Stroke (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table: % CTs for those discharged alive, AMI and Stroke, Barbados, 2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(registry category year ct total_alive ct_percent), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\addanalyses_age", clear

sort registry

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI & Stroke: % CTs for those discharged alive + % persons <70 with AMI and Stroke (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table: % persons <70 with AMI and Stroke, Barbados, 2020"), bold font(Helvetica,10,"blue")

rename totagecases under70_cases
rename totcases total_cases
rename totagecases_percent under70_cases_percent
rename totageabs under70_abscases
rename totabs total_abscases
rename totageabs_percent under70_abscases_percent
putdocx table tbl1 = data(registry category year under70_cases total_cases under70_cases_percent under70_abscases total_abscases under70_abscases_percent), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)
putdocx table tbl1(1,9), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2021AnnualReportStatsV1_`listdate'.docx", append
putdocx clear
restore

clear