** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          6_analysis report_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-MAR-2023
    // 	date last modified      15-MAR-2023
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

count //471

** POPULATION
gen poptot_2021=281207

** REGISTRATIONS (Number of registrations)
egen hregtot_2021=count(sd_etype) if sd_eyear==2021
gen hregtotper_2021=hregtot_2021/poptot_2021*100
format hregtotper_2021 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
//JC 15mar2023: per discussion with NS via WA, I will output both definitions used by BNR for hospital admission over the years
** A&E + Ward
egen hreghosptot_2021=count(sd_etype) if sd_admstatus!=3
gen hreghosptotper_2021=hreghosptot_2021/hregtot_2021*100
format hreghosptotper_2021 %02.0f
** A&E only
egen hreghosptot_ae_2021=count(sd_etype) if sd_admstatus==1
gen hreghosptotper_ae_2021=hreghosptot_ae_2021/hregtot_2021*100
format hreghosptotper_ae_2021 %02.0f

/*
** DECEASED AT 28-DAY (% Deceased at 28 day)
egen hregdeadtot_2021=count(anon_pid) if abstracted==1 & year==2020 & f1vstatus==2
gen hregdeadtotper_2021=hregdeadtot_2021/hreghosptot_2021*100
format hregdeadtotper_2021 %02.0f
*/

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

STOP
** Re-arrange dataset
gen id=_n
keep id hregtot_2021 hregtotper_2021 hreghosptot_2021 hreghosptotper_2021 hregdeadtot_2021 hregdeadtotper_2021 hdcotot_2021 hdcototper_2021 medianlos range_lower range_upper


gen title=1 if hregtot_2021!=. & id==1058
order id title

replace title=2 if hreghosptot_2021!=. & id==1059
replace title=3 if hreghosptotper_2021!=. & id==1061
replace title=4 if hregtotper_2021!=. & id==1070
replace title=5 if hregdeadtotper_2021!=. & id==1144
replace title=6 if hdcototper_2021!=. & id==1148
replace title=7 if hdcotot_2021!=. & id==1156
replace title=8 if medianlos!=. & id==4795

expand=2 in 4795, gen (medianlos_dup1)
replace id=4796 if medianlos_dup1==1
replace title=9 if medianlos_dup1==1
expand=2 in 4795, gen (medianlos_dup2)
replace id=4797 if medianlos_dup2==1
replace title=10 if medianlos_dup2==1

label define title_lab 1 "Number of registrations(1)" 2 "Hospital admissions (percentage admitted)(2)" 3 "percentage admitted" 4 "Rate per population(3)" 5 "% Deceased at 28 day(4)" 6 "% Cases who died" 7 "Death Certificate Only (DCO)(5)" 8 "Median (range) length of hospital stay (days)(6)" 9 "Range (lower) length of hospital stay (days)" 10 "Range (upper) length of hospital stay (days)" ,modify
label values title title_lab
label var title "Title"

*-------------------------------------------------------------------------------

tab title ,m
drop if title==. //4797 deleted
drop hregdeadtot_2021 medianlos_dup1 medianlos_dup2
sort title
drop id
gen id=_n
order id title hregtot_2021

//tostring poptot_2021 ,replace
tostring hregtot_2021 ,replace
tostring hreghosptot_2021 ,replace
gen hreghosptotper_2021_1=string(hreghosptotper_2021, "%02.0f")
drop hreghosptotper_2021
rename hreghosptotper_2021_1 hreghosptotper_2021
gen hregtotper_2021_1=string(hregtotper_2021, "%04.2f")
drop hregtotper_2021
rename hregtotper_2021_1 hregtotper_2021
gen hregdeadtotper_2021_1=string(hregdeadtotper_2021, "%02.0f")
drop hregdeadtotper_2021
rename hregdeadtotper_2021_1 hregdeadtotper_2021
gen hdcototper_2021_1=string(hdcototper_2021, "%02.0f")
drop hdcototper_2021
rename hdcototper_2021_1 hdcototper_2021
tostring hdcotot_2021 ,replace
tostring medianlos ,replace
tostring range_lower ,replace
tostring range_upper ,replace

replace hregtot_2021=hreghosptot_2021 if id==2
replace hregtot_2021=hreghosptotper_2021 if id==3
replace hregtot_2021=hregtotper_2021 if id==4
replace hregtot_2021=hregdeadtotper_2021 if id==5
replace hregtot_2021=hdcototper_2021 if id==6
replace hregtot_2021=hdcotot_2021 if id==7
replace hregtot_2021=medianlos if id==8
replace hregtot_2021=range_lower if id==9
replace hregtot_2021=range_upper if id==10

gen medianrange=medianlos+" "+"("+range_lower+" "+"-"+" "+range_upper+")"
replace hregtot_2021=medianrange if id==8

gen hospadmpercent=hreghosptot_2021+" "+"("+hreghosptotper_2021+"%"+")"
replace hregtot_2021=hospadmpercent if id==2
drop if id==3|id==9|id==10
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
** Load the stroke cleaned dataset AH used (and JC updated) in 1.0_stroke_cvd_analysis.do
use "`datapath'\version03\3-output\stroke_2009-2020_v9_names_Stata_v16_clean", clear

count //7649

** POPULATION
gen poptot_2021=287371

******************
** STROKE (ALL) **
******************

** REGISTRATIONS (Number of registrations)
egen sregtot_2021=count(anon_pid) if year==2020
gen sregtotper_2021=sregtot_2021/poptot_2021*100
format sregtotper_2021 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
egen sreghosptot_2021=count(anon_pid) if year==2020 & hosp==1
gen sreghosptotper_2021=sreghosptot_2021/sregtot_2021*100
format sreghosptotper_2021 %02.0f

** DECEASED AT 28-DAY (% Deceased at 28 day)
egen sregdeadtot_2021=count(anon_pid) if abstracted==1 & year==2020 & f1vstatus==2
gen sregdeadtotper_2021=sregdeadtot_2021/sreghosptot_2021*100
format sregdeadtotper_2021 %02.0f

** DCOs (% Cases who died + Death Certificate Only (DCO))
egen sdcotot_2021=count(anon_pid) if abstracted==2 & year==2020
gen sdcototper_2021=sdcotot_2021/sregtot_2021*100
format sdcototper_2021 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 1.0_stroke_cvd_analysis.do)
append using "`datapath'\version03\2-working\los_stroke_all"

** Re-arrange dataset
gen id=_n
keep id sregtot_2021 sregtotper_2021 sreghosptot_2021 sreghosptotper_2021 sregdeadtot_2021 sregdeadtotper_2021 sdcotot_2021 sdcototper_2021 medianlos_s range_lower_s range_upper_s

gen title=1 if sregtot_2021!=. & id==5510
order id title

replace title=2 if sreghosptot_2021!=. & id==5512
replace title=3 if sreghosptotper_2021!=. & id==5516
replace title=4 if sregtotper_2021!=. & id==5511
replace title=5 if sregdeadtotper_2021!=. & id==5521
replace title=6 if sdcototper_2021!=. & id==5540
replace title=7 if sdcotot_2021!=. & id==5541
replace title=8 if medianlos_s!=. & id==7650

expand=2 in 7650, gen (medianlos_s_dup1)
replace id=7650 if medianlos_s_dup1==1
replace title=9 if medianlos_s_dup1==1
expand=2 in 7650, gen (medianlos_s_dup2)
replace id=7650 if medianlos_s_dup2==1
replace title=10 if medianlos_s_dup2==1

label define title_lab 1 "Number of registrations(1)" 2 "Hospital admissions (percentage admitted)(2)" 3 "percentage admitted" 4 "Rate per population(3)" 5 "% Deceased at 28 day(4)" 6 "% Cases who died" 7 "Death Certificate Only (DCO)(5)" 8 "Median (range) length of hospital stay (days)(6)" 9 "Range (lower) length of hospital stay (days)" 10 "Range (upper) length of hospital stay (days)" ,modify
label values title title_lab
label var title "Title"

*-------------------------------------------------------------------------------

tab title ,m
drop if title==. //7642 deleted
drop sregdeadtot_2021 medianlos_s_dup1 medianlos_s_dup2
sort title
drop id
gen id=_n
order id title sregtot_2021

//tostring poptot_2021 ,replace
tostring sregtot_2021 ,replace
tostring sreghosptot_2021 ,replace
gen sreghosptotper_2021_1=string(sreghosptotper_2021, "%02.0f")
drop sreghosptotper_2021
rename sreghosptotper_2021_1 sreghosptotper_2021
gen sregtotper_2021_1=string(sregtotper_2021, "%04.2f")
drop sregtotper_2021
rename sregtotper_2021_1 sregtotper_2021
gen sregdeadtotper_2021_1=string(sregdeadtotper_2021, "%02.0f")
drop sregdeadtotper_2021
rename sregdeadtotper_2021_1 sregdeadtotper_2021
gen sdcototper_2021_1=string(sdcototper_2021, "%02.0f")
drop sdcototper_2021
rename sdcototper_2021_1 sdcototper_2021
tostring sdcotot_2021 ,replace
tostring medianlos_s ,replace
tostring range_lower_s ,replace
tostring range_upper_s ,replace

replace sregtot_2021=sreghosptot_2021 if id==2
replace sregtot_2021=sreghosptotper_2021 if id==3
replace sregtot_2021=sregtotper_2021 if id==4
replace sregtot_2021=sregdeadtotper_2021 if id==5
replace sregtot_2021=sdcototper_2021 if id==6
replace sregtot_2021=sdcotot_2021 if id==7
replace sregtot_2021=medianlos_s if id==8
replace sregtot_2021=range_lower_s if id==9
replace sregtot_2021=range_upper_s if id==10

gen medianrange_s=medianlos_s+" "+"("+range_lower_s+" "+"-"+" "+range_upper_s+")"
replace sregtot_2021=medianrange_s if id==8

gen hospadmpercent_s=sreghosptot_2021+" "+"("+sreghosptotper_2021+"%"+")"
replace sregtot_2021=hospadmpercent_s if id==2
drop if id==3|id==9|id==10
drop id
gen id=_n
order id title sregtot_2021

keep id title sregtot_2021
rename sregtot_2021 Stroke_all
rename title Title

** Create dataset with summary stats for stroke (all) (Table 1.1.)
save "`datapath'\version03\3-output\summstats_stroke_all", replace
clear

*************************
** STROKE (FIRST EVER) **
*************************
** Annual report: Table 1.1
** Load the stroke cleaned dataset AH used (and JC updated) in 1.0_stroke_cvd_analysis.do
use "`datapath'\version03\3-output\stroke_2009-2020_v9_names_Stata_v16_clean", clear

count //7649

** POPULATION
gen poptot_2021=287371

** REGISTRATIONS (Number of registrations)
egen fesregtot_2021=count(anon_pid) if year==2020 & np==1
gen fesregtotper_2021=fesregtot_2021/poptot_2021*100
format fesregtotper_2021 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
egen fesreghosptot_2021=count(anon_pid) if year==2020 & hosp==1 & np==1
gen fesreghosptotper_2021=fesreghosptot_2021/fesregtot_2021*100
format fesreghosptotper_2021 %02.0f

** DECEASED AT 28-DAY (% Deceased at 28 day)
egen fesregdeadtot_2021=count(anon_pid) if abstracted==1 & year==2020 & f1vstatus==2 & np==1
gen fesregdeadtotper_2021=fesregdeadtot_2021/fesreghosptot_2021*100
format fesregdeadtotper_2021 %02.0f

** DCOs (% Cases who died + Death Certificate Only (DCO))
egen fesdcotot_2021=count(anon_pid) if abstracted==2 & year==2020 & np==1
gen fesdcototper_2021=fesdcotot_2021/fesregtot_2021*100
format fesdcototper_2021 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 1.0_stroke_cvd_analysis.do)
append using "`datapath'\version03\2-working\los_stroke_fes"

** Re-arrange dataset
gen id=_n
keep id fesregtot_2021 fesregtotper_2021 fesreghosptot_2021 fesreghosptotper_2021 fesregdeadtot_2021 fesregdeadtotper_2021 fesdcotot_2021 fesdcototper_2021 medianlos_fes range_lower_fes range_upper_fes


gen title=1 if fesregtot_2021!=. & id==5510
order id title

replace title=2 if fesreghosptot_2021!=. & id==5516
replace title=3 if fesreghosptotper_2021!=. & id==5521
replace title=4 if fesregtotper_2021!=. & id==5535
replace title=5 if fesregdeadtotper_2021!=. & id==5550
//replace title=6 if fesdcototper_2021!=. & id==5536
replace title=6 if id==5560
//replace title=7 if fesdcotot_2021!=. & id==5566
replace title=7 if id==5564
replace title=8 if medianlos_fes!=. & id==7650

expand=2 in 7650, gen (medianlos_fes_dup1)
replace id=7650 if medianlos_fes_dup1==1
replace title=9 if medianlos_fes_dup1==1
expand=2 in 7650, gen (medianlos_fes_dup2)
replace id=7650 if medianlos_fes_dup2==1
replace title=10 if medianlos_fes_dup2==1

label define title_lab 1 "Number of registrations(1)" 2 "Hospital admissions (percentage admitted)(2)" 3 "percentage admitted" 4 "Rate per population(3)" 5 "% Deceased at 28 day(4)" 6 "% Cases who died" 7 "Death Certificate Only (DCO)(5)" 8 "Median (range) length of hospital stay (days)(6)" 9 "Range (lower) length of hospital stay (days)" 10 "Range (upper) length of hospital stay (days)" ,modify
label values title title_lab
label var title "Title"

*-------------------------------------------------------------------------------

tab title ,m
drop if title==. //7642 deleted
drop fesregdeadtot_2021 medianlos_fes_dup1 medianlos_fes_dup2
sort title
drop id
gen id=_n
order id title fesregtot_2021

//tostring poptot_2021 ,replace
tostring fesregtot_2021 ,replace
tostring fesreghosptot_2021 ,replace
gen fesreghosptotper_2021_1=string(fesreghosptotper_2021, "%02.0f")
drop fesreghosptotper_2021
rename fesreghosptotper_2021_1 fesreghosptotper_2021
gen fesregtotper_2021_1=string(fesregtotper_2021, "%04.2f")
drop fesregtotper_2021
rename fesregtotper_2021_1 fesregtotper_2021
gen fesregdeadtotper_2021_1=string(fesregdeadtotper_2021, "%02.0f")
drop fesregdeadtotper_2021
rename fesregdeadtotper_2021_1 fesregdeadtotper_2021
gen fesdcototper_2021_1=string(fesdcototper_2021, "%02.0f")
drop fesdcototper_2021
rename fesdcototper_2021_1 fesdcototper_2021
tostring fesdcotot_2021 ,replace
tostring medianlos_fes ,replace
tostring range_lower_fes ,replace
tostring range_upper_fes ,replace

replace fesregtot_2021=fesreghosptot_2021 if id==2
replace fesregtot_2021=fesreghosptotper_2021 if id==3
replace fesregtot_2021=fesregtotper_2021 if id==4
replace fesregtot_2021=fesregdeadtotper_2021 if id==5
replace fesregtot_2021=fesdcototper_2021 if id==6
replace fesregtot_2021=fesdcotot_2021 if id==7
replace fesregtot_2021=medianlos_fes if id==8
replace fesregtot_2021=range_lower_fes if id==9
replace fesregtot_2021=range_upper_fes if id==10

gen medianrange_fes=medianlos_fes+" "+"("+range_lower_fes+" "+"-"+" "+range_upper_fes+")"
replace fesregtot_2021=medianrange_fes if id==8

gen hospadmpercent_fes=fesreghosptot_2021+" "+"("+fesreghosptotper_2021+"%"+")"
replace fesregtot_2021=hospadmpercent_fes if id==2
drop if id==3|id==9|id==10
replace fesregtot_2021="n/a" if id==7
drop id
gen id=_n
order id title fesregtot_2021

keep id title fesregtot_2021
rename fesregtot_2021 Stroke_first_ever
rename title Title

** Create dataset with summary stats for stroke (first ever) (Table 1.1.)
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

** Create dataset with summary stats for stroke (first ever) (Table 1.1.)
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
putdocx text ("CVD 2020 Annual Report: Stata Results"), bold
putdocx textblock begin
Date First Prepared + Last Updated: 16-FEB-2022 + 21-JUN-2022, respectively
putdocx textblock end
putdocx textblock begin
Prepared by: JC using Stata 17.0
putdocx textblock end
putdocx textblock begin
Data source: REDCap's BNRCVD_CORE database
putdocx textblock end
putdocx textblock begin
Data release date: 29-Oct-2021
putdocx textblock end
putdocx textblock begin
Stata code file: 1.4_cvd_results report.do
putdocx textblock end
putdocx textblock begin
Dataset + dofile path: repo_data/data_p116/version03
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Methods"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Incidence dataset used for heart analyses: "p116\version03\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)" - Note: one record with unknown sex for 2018 case was corrected and other corrections to be done were noted but not performed in light of pending CVD DM re-engineer process.
putdocx textblock end
putdocx textblock begin
(2) Incidence dataset used for stroke analyses: "p116\version03\3-output\stroke_2009-2020_v9_names_Stata_v16_clean".
putdocx textblock end
putdocx textblock begin
(3) Population datasets used for heart and stroke analyses: WPP populations generated for each year from 2010-2020 (see: sync-stata-statadofiles-datareview-2019-pop_cmpile) + ("p116\version03\3-output\pop_wpp_yyyy-10") - JC 12may2022: unsure how population was generated as the pop totals in this path differ from those in the pop dataset.
putdocx textblock end
putdocx textblock begin
The above population datasets were used in conjunction with this WHO dataset when using distrate for ASIRs and ASMRs: "p116\version03\3-output\who2000_10-2".
putdocx textblock end
putdocx textblock begin
(4) Dofiles used for heart and stroke analyses: VS Code branch 2020AnnualReport for p116. Each dofile used in the below tables and outputs is listed below each title. 
putdocx textblock end


putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Summary Statistics (Dofile: 1.0_heart_cvd_analysis.do + 1.0_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.1 Summary Statistics for BNR-CVD, 2020 (Population=287,371)"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Title Myocardial_Infarction Stroke_all Stroke_first_ever), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

putdocx textblock begin
(1) Total numbers of persons who had events registered or entered into the BNR database; (2) Total number of hospital admissions as a proportion of registrations; (3) Total number of registrations as a proportion of the population; (4) Total number of patients as a proportion of hospital admission who were deceased 28 days after their event; (5) Total number of deaths collected from death registry as a proportion of registrations; (6) Median and range of length of hospital stay (in days).
putdocx textblock end

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", replace
putdocx clear

restore

clear

********************************************************* HEART *******************************************************************
preserve
use "`datapath'\version03\2-working\ASIRs_heart", clear
drop percent asir ui_range

append using "`datapath'\version03\2-working\CIRsASIRs_total_heart"
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
putdocx text ("AMI: Cases and Crude Incidence Rates (Dofile: 1.1_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.1 Number of men and women with acute MI by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


** JC 12may2022: SF uses excel to create CIR graphs so export this table to excel as well
preserve
use "`datapath'\version03\2-working\CIRs_heart", clear

gen cir1=string(cir, "%03.1f")
drop cir
rename cir1 cir


sort year sex

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel year sex number cir using "`datapath'\version03\3-output\2020AnnualReportCIR_`listdate'.xlsx", firstrow(variables) sheet(CIR_heart, replace) 

putexcel set "`datapath'\version03\3-output\2020AnnualReportCIR_`listdate'.xlsx", sheet(CIR_heart) modify
putexcel A1:D1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Sex"
putexcel C1 = "Number"
putexcel D1 = "CrudeIR"
putexcel save
restore

preserve
use "`datapath'\version03\2-working\CIRs_heart", clear

drop number
sort year sex

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Cases and Crude Incidence Rates (Dofile: 1.1_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.2 Crude incidence rate of men and women per 100,000 population with acute MI by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex cir), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version03\2-working\ASIRs_heart", clear
drop cir

append using "`datapath'\version03\2-working\CIRsASIRs_total_heart"

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
putdocx text ("AMI: Age-standardised Incidence + Mortality Rates (Dofile: 1.1_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.2 ASIRs (INCIDENCE) of men and women per 100,000 population with acute MI or sudden cardiac death by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number percent asir ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\ASMRs_heart", clear

append using "`datapath'\version03\2-working\ASMRs_total_heart"

replace sex=3 if sex==.

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Age-standardised Incidence + Mortality Rates (Dofile: 1.1_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.2 ASMRs (MORTALITY) of men and women per 100,000 population with acute MI or sudden cardiac death by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

preserve
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Age and Gender Stratified Incidence Rates (Dofile: 1.1_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.3a Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2020 (N=547)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2020_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 1.3b Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2019 (N=547)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2019_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 1.3c Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2018 (N=483)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2018_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("AMI: Symptoms (Dofile: 1.2_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
qui sum totsympts
local sum : display %3.0f `r(sum)'
putdocx text ("Table 1.3 Main presenting symptoms for acute MI patients in Barbados. Jan-Dec 2020 (N=`sum')"), bold font(Helvetica,10,"blue")

/*
rename number_female WomenNum
rename percent_female WomenPercent
rename number_male MenNum
rename percent_male MenPercent
rename number_total TotalNum
rename percent_total TotalPercent
putdocx table tbl1 = data(hsym_ar WomenNum WomenPercent MenNum MenPercent TotalNum TotalPercent), halign(center) varnames
*/
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("AMI: Risk Factors (Dofile: 1.2_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
//qui sum total
//local sum : display %3.0f `r(sum)'
//putdocx text ("Table 1.4 Prevalence of known risk factors among hospitalised acute MI patients, 2020 (N=`sum')"), bold font(Helvetica,10,"blue")
putdocx text ("Table 1.4 Prevalence of known risk factors among hospitalised acute MI patients, 2020"), bold font(Helvetica,10,"blue")

//drop if id==8
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("AMI: Secular trends in case fatality rates for AMI (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.5 Mortality statistics for acute MI patients in Barbados, 2020"), bold font(Helvetica,10,"blue")

rename mort_heart_ar category
rename year_* year__*
putdocx table tbl1 = data(category year__*), halign(center) varnames
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

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("AMI: Focus on acute MI in-hospital outcomes (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 1.4 Flow chart of vital status of acute MI patients admitted to the Queen Elizabeth Hospital in Barbados, 2020"), bold font(Helvetica,10,"blue")

rename outcomes_heart_ar category
//rename year_* year__*
putdocx table tbl1 = data(category year_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm1_asp24h_heart", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("AMI: Performance measures, 2020"), bold
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Performance measures for acute care (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("PM 1: Documented aspirin use within the first 24 hours"), bold font(Helvetica,10,"blue")

putdocx paragraph
qui sum percent_pm1heart_2021
local sum : display %3.0f `r(sum)'
putdocx text ("Typically, the AHA Get with the Guidelines Program (GWGT) recognises performance of 85% or greater compliance on each performance measure11. Standards of care suggest that patients with acute myocardial infarction receive aspirin within the first 24 hours of arrival at hospital or first onset of symptoms (see Appendix B- Descriptions) In Barbados, in 2020,`sum'%")
qui sum percent_pm1heart_2017
local sum : display %3.0f `r(sum)'
putdocx text (" of patients received aspirin within 24 hours, in comparison to`sum'%,")
qui sum percent_pm1heart_2018
local sum : display %3.0f `r(sum)'
putdocx text ("`sum'%")
qui sum percent_pm1heart_2019
local sum : display %3.0f `r(sum)'
putdocx text (" and`sum'% in 2017, 2018 and 2019 respectively. Poor documentation of medications prescribed at admission and during care is one possible reason for low rates described.")

use "`datapath'\version03\2-working\pm1_asp24h_heart_ar" ,clear
putdocx paragraph
putdocx text ("Below tables use the variable [aspact] - Possibility of using this variable for this PM instead of current method in analysis dofile, as per discussion with NS.")
putdocx paragraph, halign(center)
putdocx text ("2017"), bold font(Helvetica,10,"blue")
tab2docx aspact if year==2017
putdocx paragraph, halign(center)
putdocx text ("2018"), bold font(Helvetica,10,"blue")
tab2docx aspact if year==2018
putdocx paragraph, halign(center)
putdocx text ("2019"), bold font(Helvetica,10,"blue")
tab2docx aspact if year==2019
putdocx paragraph, halign(center)
putdocx text ("2020"), bold font(Helvetica,10,"blue")
tab2docx aspact if year==2020

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm2_stemi_heart", clear

sort year

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 2-Proportion of STEMI patients who received reperfusion via fibrinolysis (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.6. Number of STEMI cases and proportion reperfused by gender"), bold font(Helvetica,10,"blue")

//rename year_* year__*
putdocx table tbl1 = data(year female percent_female male percent_male total_number percent_total total_stemi), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)
putdocx table tbl1(1,8), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm2_stemi_heart_ar", clear

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 2-Proportion of STEMI patients who received reperfusion via fibrinolysis (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.6. Number of STEMI cases and proportion reperfused by gender"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("In '2020AnnualReportStatsV15_20220413.docx' NS requested to see the total number of MALE/FEMALE stemi.")

putdocx paragraph, halign(center)
putdocx text ("2018: Female"), bold font(Helvetica,10,"blue")
tab2docx ecgste if sex==1 & year==2018 & diagnosis==2
putdocx paragraph, halign(center)
putdocx text ("2018: Male"), bold font(Helvetica,10,"blue")
tab2docx ecgste if sex==2 & year==2018 & diagnosis==2
putdocx paragraph, halign(center)
putdocx text ("2019: Female"), bold font(Helvetica,10,"blue")
tab2docx ecgste if sex==1 & year==2019 & diagnosis==2
putdocx paragraph, halign(center)
putdocx text ("2019: Male"), bold font(Helvetica,10,"blue")
tab2docx ecgste if sex==2 & year==2019 & diagnosis==2
putdocx paragraph, halign(center)
putdocx text ("2020: Female"), bold font(Helvetica,10,"blue")
tab2docx ecgste if sex==1 & year==2020 & diagnosis==2
putdocx paragraph, halign(center)
putdocx text ("2020: Male"), bold font(Helvetica,10,"blue")
tab2docx ecgste if sex==2 & year==2020 & diagnosis==2

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm3_heart", clear

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 3-Median time to reperfusion for STEMI (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.7. 'Door to needle' times for hospitalised patients, 2018 - 2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(category median_2018 median_2019 median_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm4_ecg_heart", clear

//drop if year!=2020

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 4-Proportion of patients receiving an echocardiogram before discharge (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.8. Proportion of patients receiving echocardiogram, 2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Timing female_num female_percent male_num male_percent total_num total_percent), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

/* JC 14mar2022 Testing out below code using year drop code above + dataset: "`datapath'\version03\2-working\pm4_ecg_heart_ar"
tab2docx decho if sex==1 //female
tab2docx decho if sex==2 //male
tab2docx decho if sex==1 & (decho==1|decho==3)
tab2docx decho if sex==2 & (decho==1|decho==3)
tab2docx decho if (sex==1 | sex==2) & decho==1
*/


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\pm5_asp_heart", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 5-Documented aspirin prescribed at discharge (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Proportion of patients receiving aspirin at discharge, 2017-2020"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("2019 annual report for this PM states: 'Aspirin which is critical for secondary prevention was prescribed to 78% of patients in 2019. This is a reduction from previous years 2017 and 2018 of 85%.' This differs from the proportions in the 2020 heart dofile: 1.3_heart_cvd_analysis.do, as noted below. The proportion is calculated as 'Aspirin at discharge (of alive pts)/Total*100' according to comments by AH in this dofile.")

putdocx paragraph, halign(center)
putdocx text ("2017"), bold font(Helvetica,10,"blue")
tab2docx aspdis if vstatus==1 & year==2017
putdocx paragraph, halign(center)
putdocx text ("2018"), bold font(Helvetica,10,"blue")
tab2docx aspdis if vstatus==1 & year==2018
putdocx paragraph, halign(center)
putdocx text ("2019"), bold font(Helvetica,10,"blue")
tab2docx aspdis if vstatus==1 & year==2019
putdocx paragraph, halign(center)
putdocx text ("2020"), bold font(Helvetica,10,"blue")
tab2docx aspdis if vstatus==1 & year==2020

putdocx paragraph
putdocx text ("Below tables use the variable [aspdis] + [pladis] + [aspchr] to check for cases wherein [aspdis]!=yes/at discharge but antiplatelets [pladis]=yes/at discharge and same for aspirin used chronically [aspchr], as per discussion with NS.")
//putdocx pagebreak
putdocx paragraph, halign(center)
putdocx text ("2017-Antiplatelets"), bold font(Helvetica,10,"blue")
tab2docx pladis if year==2017 & (aspdis==99|aspdis==2)
putdocx paragraph, halign(center)
putdocx text ("2018-Antiplatelets"), bold font(Helvetica,10,"blue")
tab2docx pladis if year==2018 & (aspdis==99|aspdis==2)
putdocx paragraph, halign(center)
putdocx text ("2019-Antiplatelets"), bold font(Helvetica,10,"blue")
tab2docx pladis if year==2019 & (aspdis==99|aspdis==2)
putdocx paragraph, halign(center)
putdocx text ("2020-Antiplatelets"), bold font(Helvetica,10,"blue")
tab2docx pladis if year==2020 & (aspdis==99|aspdis==2)

putdocx paragraph, halign(center)
putdocx text ("2017-Chronic Aspirin"), bold font(Helvetica,10,"blue")
tab2docx aspchr if year==2017 & (aspdis==99|aspdis==2)
putdocx paragraph, halign(center)
putdocx text ("2018-Chronic Aspirin"), bold font(Helvetica,10,"blue")
tab2docx aspchr if year==2018 & (aspdis==99|aspdis==2)
putdocx paragraph, halign(center)
putdocx text ("2019-Chronic Aspirin"), bold font(Helvetica,10,"blue")
tab2docx aspchr if year==2019 & (aspdis==99|aspdis==2)
putdocx paragraph, halign(center)
putdocx text ("2020-Chronic Aspirin"), bold font(Helvetica,10,"blue")
tab2docx aspchr if year==2020 & (aspdis==99|aspdis==2)


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm5_asppla_heart", clear

putdocx clear
putdocx begin

//putdocx pagebreak

putdocx paragraph, halign(center)
putdocx text ("Proportion of patients receiving Aspirin/Antiplatelet Therapy at discharge, 2017-2020"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("Below tables created a variable called 'Aspirin/Antiplatelet therapy' using the variable [aspdis] + [pladis] + [aspchr] to check for cases wherein [aspdis]!=yes/at discharge but antiplatelets [pladis]=yes/at discharge and same for aspirin used chronically [aspchr], as per comment from NS in '2020AnnualReportStatsV15_20220413.docx'.")

rename asppla aspirin_antiplatelet
rename asppla_percent therapy_percent
putdocx table tbl1 = data(year aspchr pladis aspdis aspirin_antiplatelet total_alive therapy_percent), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)
putdocx table tbl1(1,7), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version03\2-working\pm6_statin_heart", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 6-Documented statins prescribed at discharge (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Proportion of patients receiving statins at discharge, 2019 & 2020"), bold font(Helvetica,10,"blue")
putdocx paragraph
putdocx text ("2019 annual report for this PM states: 'There were 71% of patients discharged home on a statin in 2019.' This matches the proportions in the 2020 heart dofile: 1.3_heart_cvd_analysis.do, as noted below. The proportion is calculated as 'Statins at discharge (of alive pts)/Total*100' according to comments by AH in this dofile.")

putdocx paragraph, halign(center)
putdocx text ("2019"), bold font(Helvetica,10,"blue")
tab2docx statdis if vstatus==1 & year==2019
putdocx paragraph, halign(center)
putdocx text ("2020"), bold font(Helvetica,10,"blue")
tab2docx statdis if vstatus==1 & year==2020

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

***************************************************** STROKE *************************************************************

preserve
use "`datapath'\version03\2-working\ASIRs_stroke", clear
drop percent asir ui_range

append using "`datapath'\version03\2-working\CIRsASIRs_total_stroke"
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
putdocx text ("Stroke: Cases and Crude Incidence Rates (Dofile: 1.1_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.1 Number of men and women with stroke by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear


** JC 12may2022: SF uses excel to create CIR graphs so export this table to excel as well
preserve
use "`datapath'\version03\2-working\CIRs_stroke", clear

gen cir1=string(cir, "%03.1f")
drop cir
rename cir1 cir


sort year sex

local listdate = string( d(`c(current_date)'), "%dCYND" )
export_excel year sex number cir using "`datapath'\version03\3-output\2020AnnualReportCIR_`listdate'.xlsx", firstrow(variables) sheet(CIR_stroke, replace) 

putexcel set "`datapath'\version03\3-output\2020AnnualReportCIR_`listdate'.xlsx", sheet(CIR_stroke) modify
putexcel A1:D1, bold
//putexcel D2:D4, rownames nformat(number_d1) - this causes an error when opening the excel workbook so reformatted cir variable above
putexcel A1 = "Year"
putexcel B1 = "Sex"
putexcel C1 = "Number"
putexcel D1 = "CrudeIR"
putexcel save
restore


preserve
use "`datapath'\version03\2-working\CIRs_stroke", clear

drop number
sort year sex

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Cases and Crude Incidence Rates (Dofile: 1.1_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.2 Crude incidence rate of men and women with stroke by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex cir), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version03\2-working\ASIRs_stroke", clear
drop cir

append using "`datapath'\version03\2-working\CIRsASIRs_total_stroke"

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
putdocx text ("Stroke: Age-standardised Incidence + Mortality Rates (Dofile: 1.1_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.1 ASIRs (INCIDENCE) of men and women per 100,000 population with stroke by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number percent asir ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\ASMRs_stroke", clear

append using "`datapath'\version03\2-working\ASMRs_total_stroke"

replace sex=3 if sex==.

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort sex year

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Age-standardised Incidence + Mortality Rates (Dofile: 1.1_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.1 ASMRs (MORTALITY) of men and women per 100,000 population with stroke by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

preserve
putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Age and Gender Stratified Incidence Rates (Dofile: 1.1_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.3a Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2020 (N=700)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2020_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 2.3b Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2019 (N=758)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2019_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 2.3c Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2018 (N=682)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version03\3-output\2018_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version03\2-working\subtypes_stroke", clear

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Category/Subtypes (Dofile: 1.2_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.2 Stroke subtypes in Barbados, 2018, 2019 & 2020 "), bold font(Helvetica,10,"blue")

qui sum total_abs_2018
local sum : display %3.0f `r(sum)'
putdocx text ("(N=`sum',"), bold font(Helvetica,10,"blue")
qui sum total_abs_2019
local sum : display %3.0f `r(sum)'
putdocx text (" N=`sum',"), bold font(Helvetica,10,"blue")
qui sum total_abs_2021
local sum : display %3.0f `r(sum)'
putdocx text (" N=`sum', respectively)"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Stroke_Category num_f_2018 percent_f_2018 num_m_2018 percent_m_2018 num_f_2019 percent_f_2019 num_m_2019 percent_m_2019 num_f_2021 percent_f_2021 num_m_2021 percent_m_2021), halign(center) varnames
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
putdocx table tbl1(1,12), bold shading(lightgray)
putdocx table tbl1(1,13), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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

putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Stroke: Symptoms and Risk Factors"), bold
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Symptoms (Dofile: 1.2_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
qui sum totsympts
local sum : display %3.0f `r(sum)'
putdocx text ("Table 2.3 Main presenting symptoms for stroke patients in Barbados. Jan-Dec 2020 (N=`sum')"), bold font(Helvetica,10,"blue")

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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("Stroke: Risk Factors (Dofile: 1.2_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
//qui sum total
//local sum : display %3.0f `r(sum)'
//putdocx text ("Table 2.4 Prevalence of known risk factors among hospitalised stroke patients, 2020 (N=`sum')"), bold font(Helvetica,10,"blue")
putdocx text ("Table 2.4 Prevalence of known risk factors among hospitalised stroke patients, 2020"), bold font(Helvetica,10,"blue")

//drop if id==8
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version03\2-working\riskfactors_stroketia", clear

putdocx clear
putdocx begin

//putdocx pagebreak
putdocx paragraph, halign(center)
//qui sum total
//local sum : display %3.0f `r(sum)'
//putdocx text ("Table 2.4 Prevalence of known risk factors among hospitalised stroke patients, 2020 (N=`sum')"), bold font(Helvetica,10,"blue")
putdocx text ("Table 2.4 CORRECTED Prior stroke or TIA, 2019 + 2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year numerator percent denominator), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

putdocx paragraph
putdocx text ("n1 = denominator (i.e. total number reporting information about that risk factor). NR = Numbers too small for adequate representation")

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("Stroke: Secular trends in Stroke Mortality (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.5 Mortality statistics for stroke patients in Barbados, 2020"), bold font(Helvetica,10,"blue")

rename mort_stroke_ar category
rename year_* year__*
putdocx table tbl1 = data(category year__*), halign(center) varnames
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

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx text ("Stroke: Focus on acute stroke in-hospital outcomes (Dofile: 1.3_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Figure 2.4 Flow chart of vital status of stroke patients admitted to the Queen Elizabeth Hospital in Barbados, 2020"), bold font(Helvetica,10,"blue")

rename outcomes_stroke_ar category
//rename year_* year__*
putdocx table tbl1 = data(category year_2021), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear

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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
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
putdocx save "`datapath'\version03\3-output\2020AnnualReportStatsV18_`listdate'.docx", append
putdocx clear
restore

clear