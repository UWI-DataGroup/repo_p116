** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1.4_cvd_results report.do
    //  project:                BNR-Heart
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-FEB-2022
    // 	date last modified      05-APR-2022
    //  algorithm task          Creating MS Word document with statistical + figure outputs for 2020 annual report
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
    log using "`logpath'\heart_results report.smcl", replace
** HEADER -----------------------------------------------------


*********************************
**  SUMMARY STATISTICS - HEART **
*********************************
** Annual report: Table 1.1
** Load the heart cleaned dataset AH used in 1.0_heart_cvd_analysis.do
use "`datapath'\version02\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)", clear

count //4794

** POPULATION
gen poptot_2020=277814

** REGISTRATIONS (Number of registrations)
egen hregtot_2020=count(anon_pid) if year==2020
gen hregtotper_2020=hregtot_2020/poptot_2020*100
format hregtotper_2020 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
egen hreghosptot_2020=count(anon_pid) if year==2020 & hosp==1
gen hreghosptotper_2020=hreghosptot_2020/hregtot_2020*100
format hreghosptotper_2020 %02.0f

** DECEASED AT 28-DAY (% Deceased at 28 day)
egen hregdeadtot_2020=count(anon_pid) if abstracted==1 & year==2020 & f1vstatus==2
gen hregdeadtotper_2020=hregdeadtot_2020/hreghosptot_2020*100
format hregdeadtotper_2020 %02.0f

** DCOs (% Cases who died + Death Certificate Only (DCO))
egen hdcotot_2020=count(anon_pid) if abstracted==2 & year==2020
gen hdcototper_2020=hdcotot_2020/hregtot_2020*100
format hdcototper_2020 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 1.0_heart_cvd_analysis.do)
append using "`datapath'\version02\2-working\los_heart"

** Re-arrange dataset
gen id=_n
keep id hregtot_2020 hregtotper_2020 hreghosptot_2020 hreghosptotper_2020 hregdeadtot_2020 hregdeadtotper_2020 hdcotot_2020 hdcototper_2020 medianlos range_lower range_upper


gen title=1 if hregtot_2020!=. & id==1058
order id title

replace title=2 if hreghosptot_2020!=. & id==1059
replace title=3 if hreghosptotper_2020!=. & id==1061
replace title=4 if hregtotper_2020!=. & id==1070
replace title=5 if hregdeadtotper_2020!=. & id==1144
replace title=6 if hdcototper_2020!=. & id==1148
replace title=7 if hdcotot_2020!=. & id==1156
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
drop hregdeadtot_2020 medianlos_dup1 medianlos_dup2
sort title
drop id
gen id=_n
order id title hregtot_2020

//tostring poptot_2020 ,replace
tostring hregtot_2020 ,replace
tostring hreghosptot_2020 ,replace
gen hreghosptotper_2020_1=string(hreghosptotper_2020, "%02.0f")
drop hreghosptotper_2020
rename hreghosptotper_2020_1 hreghosptotper_2020
gen hregtotper_2020_1=string(hregtotper_2020, "%04.2f")
drop hregtotper_2020
rename hregtotper_2020_1 hregtotper_2020
gen hregdeadtotper_2020_1=string(hregdeadtotper_2020, "%02.0f")
drop hregdeadtotper_2020
rename hregdeadtotper_2020_1 hregdeadtotper_2020
gen hdcototper_2020_1=string(hdcototper_2020, "%02.0f")
drop hdcototper_2020
rename hdcototper_2020_1 hdcototper_2020
tostring hdcotot_2020 ,replace
tostring medianlos ,replace
tostring range_lower ,replace
tostring range_upper ,replace

replace hregtot_2020=hreghosptot_2020 if id==2
replace hregtot_2020=hreghosptotper_2020 if id==3
replace hregtot_2020=hregtotper_2020 if id==4
replace hregtot_2020=hregdeadtotper_2020 if id==5
replace hregtot_2020=hdcototper_2020 if id==6
replace hregtot_2020=hdcotot_2020 if id==7
replace hregtot_2020=medianlos if id==8
replace hregtot_2020=range_lower if id==9
replace hregtot_2020=range_upper if id==10

gen medianrange=medianlos+" "+"("+range_lower+" "+"-"+" "+range_upper+")"
replace hregtot_2020=medianrange if id==8

gen hospadmpercent=hreghosptot_2020+" "+"("+hreghosptotper_2020+"%"+")"
replace hregtot_2020=hospadmpercent if id==2
drop if id==3|id==9|id==10
drop id
gen id=_n
order id title hregtot_2020

keep id title hregtot_2020
rename hregtot_2020 Myocardial_Infarction
rename title Title
 
** Create dataset with summary stats for heart (Table 1.1.)
save "`datapath'\version02\3-output\summstats_heart", replace

clear


**********************************
**  SUMMARY STATISTICS - STROKE **
**********************************
** Annual report: Table 1.1
** Load the stroke cleaned dataset AH used (and JC updated) in 1.0_stroke_cvd_analysis.do
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean", clear

count //7649

** POPULATION
gen poptot_2020=277814

******************
** STROKE (ALL) **
******************

** REGISTRATIONS (Number of registrations)
egen sregtot_2020=count(anon_pid) if year==2020
gen sregtotper_2020=sregtot_2020/poptot_2020*100
format sregtotper_2020 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
egen sreghosptot_2020=count(anon_pid) if year==2020 & hosp==1
gen sreghosptotper_2020=sreghosptot_2020/sregtot_2020*100
format sreghosptotper_2020 %02.0f

** DECEASED AT 28-DAY (% Deceased at 28 day)
egen sregdeadtot_2020=count(anon_pid) if abstracted==1 & year==2020 & f1vstatus==2
gen sregdeadtotper_2020=sregdeadtot_2020/sreghosptot_2020*100
format sregdeadtotper_2020 %02.0f

** DCOs (% Cases who died + Death Certificate Only (DCO))
egen sdcotot_2020=count(anon_pid) if abstracted==2 & year==2020
gen sdcototper_2020=sdcotot_2020/sregtot_2020*100
format sdcototper_2020 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 1.0_stroke_cvd_analysis.do)
append using "`datapath'\version02\2-working\los_stroke_all"

** Re-arrange dataset
gen id=_n
keep id sregtot_2020 sregtotper_2020 sreghosptot_2020 sreghosptotper_2020 sregdeadtot_2020 sregdeadtotper_2020 sdcotot_2020 sdcototper_2020 medianlos_s range_lower_s range_upper_s

gen title=1 if sregtot_2020!=. & id==5510
order id title

replace title=2 if sreghosptot_2020!=. & id==5512
replace title=3 if sreghosptotper_2020!=. & id==5516
replace title=4 if sregtotper_2020!=. & id==5511
replace title=5 if sregdeadtotper_2020!=. & id==5521
replace title=6 if sdcototper_2020!=. & id==5540
replace title=7 if sdcotot_2020!=. & id==5541
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
drop sregdeadtot_2020 medianlos_s_dup1 medianlos_s_dup2
sort title
drop id
gen id=_n
order id title sregtot_2020

//tostring poptot_2020 ,replace
tostring sregtot_2020 ,replace
tostring sreghosptot_2020 ,replace
gen sreghosptotper_2020_1=string(sreghosptotper_2020, "%02.0f")
drop sreghosptotper_2020
rename sreghosptotper_2020_1 sreghosptotper_2020
gen sregtotper_2020_1=string(sregtotper_2020, "%04.2f")
drop sregtotper_2020
rename sregtotper_2020_1 sregtotper_2020
gen sregdeadtotper_2020_1=string(sregdeadtotper_2020, "%02.0f")
drop sregdeadtotper_2020
rename sregdeadtotper_2020_1 sregdeadtotper_2020
gen sdcototper_2020_1=string(sdcototper_2020, "%02.0f")
drop sdcototper_2020
rename sdcototper_2020_1 sdcototper_2020
tostring sdcotot_2020 ,replace
tostring medianlos_s ,replace
tostring range_lower_s ,replace
tostring range_upper_s ,replace

replace sregtot_2020=sreghosptot_2020 if id==2
replace sregtot_2020=sreghosptotper_2020 if id==3
replace sregtot_2020=sregtotper_2020 if id==4
replace sregtot_2020=sregdeadtotper_2020 if id==5
replace sregtot_2020=sdcototper_2020 if id==6
replace sregtot_2020=sdcotot_2020 if id==7
replace sregtot_2020=medianlos_s if id==8
replace sregtot_2020=range_lower_s if id==9
replace sregtot_2020=range_upper_s if id==10

gen medianrange_s=medianlos_s+" "+"("+range_lower_s+" "+"-"+" "+range_upper_s+")"
replace sregtot_2020=medianrange_s if id==8

gen hospadmpercent_s=sreghosptot_2020+" "+"("+sreghosptotper_2020+"%"+")"
replace sregtot_2020=hospadmpercent_s if id==2
drop if id==3|id==9|id==10
drop id
gen id=_n
order id title sregtot_2020

keep id title sregtot_2020
rename sregtot_2020 Stroke_all
rename title Title

** Create dataset with summary stats for stroke (all) (Table 1.1.)
save "`datapath'\version02\3-output\summstats_stroke_all", replace
clear

*************************
** STROKE (FIRST EVER) **
*************************
** Annual report: Table 1.1
** Load the stroke cleaned dataset AH used (and JC updated) in 1.0_stroke_cvd_analysis.do
use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean", clear

count //7649

** POPULATION
gen poptot_2020=277814

** REGISTRATIONS (Number of registrations)
egen fesregtot_2020=count(anon_pid) if year==2020 & np==1
gen fesregtotper_2020=fesregtot_2020/poptot_2020*100
format fesregtotper_2020 %04.2f

** HOSPITAL ADMISSIONS (Hospital admissions (percentage admitted))
egen fesreghosptot_2020=count(anon_pid) if year==2020 & hosp==1 & np==1
gen fesreghosptotper_2020=fesreghosptot_2020/fesregtot_2020*100
format fesreghosptotper_2020 %02.0f

** DECEASED AT 28-DAY (% Deceased at 28 day)
egen fesregdeadtot_2020=count(anon_pid) if abstracted==1 & year==2020 & f1vstatus==2 & np==1
gen fesregdeadtotper_2020=fesregdeadtot_2020/fesreghosptot_2020*100
format fesregdeadtotper_2020 %02.0f

** DCOs (% Cases who died + Death Certificate Only (DCO))
egen fesdcotot_2020=count(anon_pid) if abstracted==2 & year==2020 & np==1
gen fesdcototper_2020=fesdcotot_2020/fesregtot_2020*100
format fesdcototper_2020 %02.0f

** LOS (Median (range) length of hospital stay (days))
**Median Legthn of stay in hospital (analysis performed in 1.0_stroke_cvd_analysis.do)
append using "`datapath'\version02\2-working\los_stroke_fes"

** Re-arrange dataset
gen id=_n
keep id fesregtot_2020 fesregtotper_2020 fesreghosptot_2020 fesreghosptotper_2020 fesregdeadtot_2020 fesregdeadtotper_2020 fesdcotot_2020 fesdcototper_2020 medianlos_fes range_lower_fes range_upper_fes


gen title=1 if fesregtot_2020!=. & id==5510
order id title

replace title=2 if fesreghosptot_2020!=. & id==5516
replace title=3 if fesreghosptotper_2020!=. & id==5521
replace title=4 if fesregtotper_2020!=. & id==5535
replace title=5 if fesregdeadtotper_2020!=. & id==5550
//replace title=6 if fesdcototper_2020!=. & id==5536
replace title=6 if id==5560
//replace title=7 if fesdcotot_2020!=. & id==5566
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
drop fesregdeadtot_2020 medianlos_fes_dup1 medianlos_fes_dup2
sort title
drop id
gen id=_n
order id title fesregtot_2020

//tostring poptot_2020 ,replace
tostring fesregtot_2020 ,replace
tostring fesreghosptot_2020 ,replace
gen fesreghosptotper_2020_1=string(fesreghosptotper_2020, "%02.0f")
drop fesreghosptotper_2020
rename fesreghosptotper_2020_1 fesreghosptotper_2020
gen fesregtotper_2020_1=string(fesregtotper_2020, "%04.2f")
drop fesregtotper_2020
rename fesregtotper_2020_1 fesregtotper_2020
gen fesregdeadtotper_2020_1=string(fesregdeadtotper_2020, "%02.0f")
drop fesregdeadtotper_2020
rename fesregdeadtotper_2020_1 fesregdeadtotper_2020
gen fesdcototper_2020_1=string(fesdcototper_2020, "%02.0f")
drop fesdcototper_2020
rename fesdcototper_2020_1 fesdcototper_2020
tostring fesdcotot_2020 ,replace
tostring medianlos_fes ,replace
tostring range_lower_fes ,replace
tostring range_upper_fes ,replace

replace fesregtot_2020=fesreghosptot_2020 if id==2
replace fesregtot_2020=fesreghosptotper_2020 if id==3
replace fesregtot_2020=fesregtotper_2020 if id==4
replace fesregtot_2020=fesregdeadtotper_2020 if id==5
replace fesregtot_2020=fesdcototper_2020 if id==6
replace fesregtot_2020=fesdcotot_2020 if id==7
replace fesregtot_2020=medianlos_fes if id==8
replace fesregtot_2020=range_lower_fes if id==9
replace fesregtot_2020=range_upper_fes if id==10

gen medianrange_fes=medianlos_fes+" "+"("+range_lower_fes+" "+"-"+" "+range_upper_fes+")"
replace fesregtot_2020=medianrange_fes if id==8

gen hospadmpercent_fes=fesreghosptot_2020+" "+"("+fesreghosptotper_2020+"%"+")"
replace fesregtot_2020=hospadmpercent_fes if id==2
drop if id==3|id==9|id==10
replace fesregtot_2020="n/a" if id==7
drop id
gen id=_n
order id title fesregtot_2020

keep id title fesregtot_2020
rename fesregtot_2020 Stroke_first_ever
rename title Title

** Create dataset with summary stats for stroke (first ever) (Table 1.1.)
save "`datapath'\version02\3-output\summstats_stroke_fes", replace

merge 1:1 id using "`datapath'\version02\3-output\summstats_heart"
drop _merge
merge 1:1 id using "`datapath'\version02\3-output\summstats_stroke_all"
drop _merge id
order Title Myocardial_Infarction Stroke_all Stroke_first_ever

** Remove datasets to save on SharePoint storage space
erase "`datapath'\version02\3-output\summstats_heart.dta"
erase "`datapath'\version02\3-output\summstats_stroke_all.dta"
erase "`datapath'\version02\3-output\summstats_stroke_fes.dta"

** Create dataset with summary stats for stroke (first ever) (Table 1.1.)
save "`datapath'\version02\2-working\summstats", replace

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
Date Prepared: 16-FEB-2022
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
Dataset + dofile path: repo_data/data_p116/version02
putdocx textblock end
putdocx paragraph, halign(center)
putdocx text ("Methods"), bold font(Helvetica,10,"blue")
putdocx textblock begin
(1) Incidence dataset used for heart analyses: "p116\version02\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)" - Note: one record with unknown sex for 2018 case was corrected and other corrections to be done were noted but not performed in light of pending CVD DM re-engineer process.
putdocx textblock end
putdocx textblock begin
(2) Incidence dataset used for stroke analyses: "p116\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean".
putdocx textblock end
putdocx textblock begin
(3) Population datasets used for heart and stroke analyses: WPP populations generated for each year from 2010-2020 (see: sync-stata-statadofiles-datareview-2019-pop_cmpile) + ("p116\version02\3-output\pop_wpp_yyyy-10")
putdocx textblock end
putdocx textblock begin
The above population datasets were used in conjunction with this WHO dataset when using distrate for ASIRs and ASMRs: "p116\version02\3-output\who2000_10-2".
putdocx textblock end
putdocx textblock begin
(4) Dofiles used for heart and stroke analyses: VS Code branch 2020AnnualReport for p116. Each dofile used in the below tables and outputs is listed below each title. 
putdocx textblock end


putdocx pagebreak
putdocx paragraph, style(Heading1)
putdocx text ("Summary Statistics (Dofile: 1.0_heart_cvd_analysis.do + 1.0_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.1 Summary Statistics for BNR-CVD, 2020 (Population=277,814)"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Title Myocardial_Infarction Stroke_all Stroke_first_ever), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

putdocx textblock begin
(1) Total numbers of persons who had events registered or entered into the BNR database; (2) Total number of hospital admissions as a proportion of registrations; (3) Total number of registrations as a proportion of the population; (4) Total number of patients as a proportion of hospital admission who were deceased 28 days after their event; (5) Total number of deaths collected from death registry as a proportion of registrations; (6) Median and range of length of hospital stay (in days).
putdocx textblock end

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", replace
putdocx clear

restore

clear

********************************************************* HEART *******************************************************************
preserve
use "`datapath'\version02\2-working\ASIRs_heart", clear
drop percent asir ui_range

append using "`datapath'\version02\2-working\CIRs_total_heart"

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort year sex
save "`datapath'\version02\2-working\CIRs_heart", replace
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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version02\2-working\CIRs_heart", clear

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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version02\2-working\ASIRs_heart", clear
drop cir


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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version02\2-working\ASMRs_heart", clear

sort sex year

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Age-standardised Incidence + Mortality Rates (Dofile: 1.1_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.2 ASMRs (MORATLITY) of men and women per 100,000 population with acute MI or sudden cardiac death by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
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

putdocx image "`datapath'\version02\3-output\2020_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 1.3b Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2019 (N=547)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version02\3-output\2019_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 1.3c Age and gender stratified incidence rate per 100,000 population of AMI, Barbados, 2018 (N=483)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version02\3-output\2018_age-sex graph_heart.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version02\2-working\symptoms_heart", clear
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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\riskfactors_heart", clear

sort rf_ar

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("AMI: Risk Factors (Dofile: 1.2_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.4 Prevalence of known risk factors among hospitalised acute MI patients, 2020"), bold font(Helvetica,10,"blue")

rename rftype_ar rf_category
rename rf_ar risk_factor
putdocx table tbl1 = data(rf_category risk_factor number rf_percent denominator), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version02\2-working\mort_heart", clear

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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\outcomes_heart", clear

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
putdocx table tbl1 = data(category year_2020), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\pm1_asp24h_heart", clear

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
qui sum percent_pm1heart_2020
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

use "`datapath'\version02\2-working\pm1_asp24h_heart_ar" ,clear
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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\pm2_stemi_heart", clear

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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\pm3_door2needle_heart", clear

putdocx clear
putdocx begin

putdocx paragraph, style(Heading2)
putdocx text ("AMI: PM 3-Median time to reperfusion for STEMI (Dofile: 1.3_heart_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 1.7. 'Door to needle' times for hospitalised patients, 2018 - 2020"), bold font(Helvetica,10,"blue")

rename pm3_category category
rename median_door2needle_2018 median_2018
rename median_door2needle_2019 median_2019
rename median_door2needle_2020 median_2020
putdocx table tbl1 = data(category median_2018 median_2019 median_2020), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\pm4_ecg_heart", clear

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

/* JC 14mar2022 Testing out below code using year drop code above + dataset: "`datapath'\version02\2-working\pm4_ecg_heart_ar"
tab2docx decho if sex==1 //female
tab2docx decho if sex==2 //male
tab2docx decho if sex==1 & (decho==1|decho==3)
tab2docx decho if sex==2 & (decho==1|decho==3)
tab2docx decho if (sex==1 | sex==2) & decho==1
*/


local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version02\2-working\pm5_asp_heart", clear

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
putdocx pagebreak
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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear


preserve
use "`datapath'\version02\2-working\pm6_statin_heart", clear

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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

***************************************************** STROKE *************************************************************

preserve
use "`datapath'\version02\2-working\ASIRs_stroke", clear
drop percent asir ui_range

append using "`datapath'\version02\2-working\CIRs_total_stroke"

replace sex=3 if sex==.
replace number=totnumber if number==.
drop totnumber

label drop sex_
label define sex_lab 1 "Female" 2 "Male" 3 "Total"
label values sex sex_lab

sort year sex
save "`datapath'\version02\2-working\CIRs_stroke", replace
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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version02\2-working\CIRs_stroke", clear

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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version02\2-working\ASIRs_stroke", clear
drop cir


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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
use "`datapath'\version02\2-working\ASMRs_stroke", clear

sort sex year

putdocx clear
putdocx begin

putdocx pagebreak
putdocx paragraph, style(Heading2)
putdocx text ("Stroke: Age-standardised Incidence + Mortality Rates (Dofile: 1.1_stroke_cvd_analysis.do)"), bold
putdocx paragraph, halign(center)
putdocx text ("Table 2.1 ASMRs (MORATLITY) of men and women per 100,000 population with stroke by year in Barbados. 2010-2020"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(year sex number percent asmr ui_range), halign(center) varnames
putdocx table tbl1(1,1), bold shading(lightgray)
putdocx table tbl1(1,2), bold shading(lightgray)
putdocx table tbl1(1,3), bold shading(lightgray)
putdocx table tbl1(1,4), bold shading(lightgray)
putdocx table tbl1(1,5), bold shading(lightgray)
putdocx table tbl1(1,6), bold shading(lightgray)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
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

putdocx image "`datapath'\version02\3-output\2020_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

clear

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 2.3b Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2019 (N=758)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version02\3-output\2019_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

preserve
putdocx clear
putdocx begin

putdocx paragraph, halign(center)
putdocx text ("Figure 2.3c Age and gender stratified incidence rate per 100,000 population of stroke, Barbados, 2018 (N=682)"), bold font(Helvetica,10,"blue")
putdocx paragraph

putdocx image "`datapath'\version02\3-output\2018_age-sex graph_stroke.png", width(5.5) height(2.0)

local listdate = string( d(`c(current_date)'), "%dCYND" )
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore


preserve
use "`datapath'\version02\2-working\subtypes_stroke", clear

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
qui sum total_abs_2020
local sum : display %3.0f `r(sum)'
putdocx text (" N=`sum', respectively)"), bold font(Helvetica,10,"blue")

putdocx table tbl1 = data(Stroke_Category num_f_2018 percent_f_2018 num_m_2018 percent_m_2018 num_f_2019 percent_f_2019 num_m_2019 percent_m_2019 num_f_2020 percent_f_2020 num_m_2020 percent_m_2020), halign(center) varnames
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
putdocx save "`datapath'\version02\3-output\2020AnnualReportStatsV11_`listdate'.docx", append
putdocx clear
restore

stop
save "`datapath'\version02\2-working\2020_cvd_results" ,replace
label data "BNR-CVD 2020 Analysis Outputs to MS Word"
notes _dta :These data prepared for Natasha Sobers and Shelly-Ann Forde - 2020 annual report