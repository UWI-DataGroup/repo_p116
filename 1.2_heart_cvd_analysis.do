cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.2_heart_cvd_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY
    //  date first created:     27-Jan-2022
    //  date last modified:     27-Jan-2022
	//  analysis:               Heart 2020 dataset for Annual Report
    //  algorithm task          Performing Heart 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to analyse Heart Symptoms and Risk Factors
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
    log using "`logpath'\1.2_heart_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Table 1.2 2020 Heart Symptoms
 *              Table 1.3 2020 Risk Factors
************************************************************************
** Load the dataset  
use "`datapath'\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022).dta"

count
**4794 seen 27-Jan-2022

*******************************************************
** TABLE 1.2 PRESENTING HEART STMPTOMS & SIGNS 
*******************************************************
tab1 symp_chpa if abstracted==1 & year==2020, miss
count if eligible==6
** 1 seen

** Count of hsymS (CORE data)
** Number with none, 1, >1
** None, 1, >1 hsym (ALIVE vs DEAD)
tab1 symp_sob symp_vom symp_dizzy symp_loc symp_palp symp_sweat if abstracted==1 & year==2020, miss


** tab1 ohsym*
tab1 ohsym if abstracted==1 & year==2020, miss //193/303
list org_id cstatus hosp ohsym ohsym1 ohsym2 if ohsym==. & abstracted==1 & year==2020 // all confirmed not abstracted cases.
sort ohsym1
replace ohsym1 = upper(rtrim(ltrim(itrim(ohsym1))))
replace ohsym2 = upper(rtrim(ltrim(itrim(ohsym2))))
replace ohsym3 = upper(rtrim(ltrim(itrim(ohsym3))))
list ohsym1 ohsym2 ohsym3 if org_id!=. &( ohsym1!="" | ohsym2!="" | ohsym3!="")
** trying to tabulate the most common of these "other" hsyms going from the table
**COUGH****
count if (regexm(ohsym1, "COUGH") | regexm(ohsym2, "COUGH") | regexm(ohsym3, "COUGH")) ///
                & abstracted==1 & year==2020 & (ohsym1!="" |ohsym2!="" | ohsym3!="") 
**************** // 19
dis 19/290
******************* NAUSEA ***********************
count if (regexm(ohsym1, "NAUSEA") | regexm(ohsym2, "NAUSEA") | regexm(ohsym3, "NAUSEA") | ///
               regexm(ohsym1, "MALAISE") | regexm(ohsym2, "MALAISE") | ///
			   regexm(ohsym3, "MALAISE") | regexm(ohsym1, "BAD FEEL") | ///
			   regexm(ohsym2, "BAD FEEL")| regexm(ohsym3, "BAD FEEL") | ///
			   regexm(ohsym1, "UNWELL") | regexm(ohsym2, "UNWELL") | ///
			   regexm(ohsym3, "UNWELL") | regexm(ohsym1, "FEELING BAD") | ///
			   regexm(ohsym2, "FEELING BAD") | regexm(ohsym3, "FEELING BAD") ///
			   | regexm(ohsym1, "NOT FEELING WELL") | regexm(ohsym2, "NOT FEELING WELL") ///
			   | regexm(ohsym3, "NOT FEELING WELL") ) & abstracted==1 & year==2020 & ///
			   ( ohsym1!="" |  ohsym2!=""| ohsym3!="")	
******* // 65	 
dis 65/290

*********** NAUSEA BY SEX
***** FEMALES
count if (regexm(ohsym1, "NAUSEA") | regexm(ohsym2, "NAUSEA") | regexm(ohsym3, "NAUSEA") | ///
               regexm(ohsym1, "MALAISE") | regexm(ohsym2, "MALAISE") | ///
			   regexm(ohsym3, "MALAISE") | regexm(ohsym1, "BAD FEEL") | ///
			   regexm(ohsym2, "BAD FEEL")| regexm(ohsym3, "BAD FEEL") | ///
			   regexm(ohsym1, "UNWELL") | regexm(ohsym2, "UNWELL") | ///
			   regexm(ohsym3, "UNWELL") | regexm(ohsym1, "FEELING BAD") | ///
			   regexm(ohsym2, "FEELING BAD") | regexm(ohsym3, "FEELING BAD") ///
			   | regexm(ohsym1, "NOT FEELING WELL") | regexm(ohsym2, "NOT FEELING WELL") ///
			   | regexm(ohsym3, "NOT FEELING WELL") ) & sex==1 & abstracted==1 & year==2020 & ///
			   ( ohsym1!="" |  ohsym2!=""| ohsym3!="")	
*****// 29
********MALES		   
count if (regexm(ohsym1, "NAUSEA") | regexm(ohsym2, "NAUSEA") | regexm(ohsym3, "NAUSEA") | ///
               regexm(ohsym1, "MALAISE") | regexm(ohsym2, "MALAISE") | ///
			   regexm(ohsym3, "MALAISE") | regexm(ohsym1, "BAD FEEL") | ///
			   regexm(ohsym2, "BAD FEEL")| regexm(ohsym3, "BAD FEEL") | ///
			   regexm(ohsym1, "UNWELL") | regexm(ohsym2, "UNWELL") | ///
			   regexm(ohsym3, "UNWELL") | regexm(ohsym1, "FEELING BAD") | ///
			   regexm(ohsym2, "FEELING BAD") | regexm(ohsym3, "FEELING BAD") ///
			   | regexm(ohsym1, "NOT FEELING WELL") | regexm(ohsym2, "NOT FEELING WELL") ///
			   | regexm(ohsym3, "NOT FEELING WELL") ) & sex==2 & abstracted==1 & year==2020 & ///
			   ( ohsym1!="" |  ohsym2!=""| ohsym3!="")	
********// 36

************ DIARRHEA		   
count if (regexm(ohsym1, "DIAR") |regexm(ohsym2, "DIAR") | regexm(ohsym3, "DIAR")) ///
          & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="") 
********// 2

*************** DECREASED RESPONSIVENESS**********************	  
count if (regexm(ohsym1, "DECREASED RESPO") | regexm(ohsym2, "DECREASED RESPO") | ///
         regexm(ohsym3, "DECREASED RESPO") ) & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ///
		 ohsym3!="")
***********// 8

************* HEADACHE ************************
count if (regexm(ohsym1, "HEADACHE") | regexm(ohsym2, "HEADACHE") | ///
         regexm(ohsym3, "HEADACHE")) & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ///
		 ohsym3!="")
*******// 13

****************** NUMBNESS ***********************
count if (regexm(ohsym1, "NUMBNESS") | regexm(ohsym1, "NUMBNESS") | ///
          regexm(ohsym1, "NUMBNESS")) & abstracted==1 & year==2020 & ( ohsym1!="" | ohsym2!="" | ohsym3!="") 
****// 2

*********WEAK******** 
count if (regexm(ohsym1, "WEAK") | regexm(ohsym2, "WEAK") | regexm(ohsym3, "WEAK")) ///
           & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="")
**********// 11

***************DECREASED APPETITE
count if (regexm(ohsym1, "DECR APPETITE") | regexm(ohsym2, "DECR APPETITE") | ///
         regexm(ohsym3, "DECR APPETITE") | regexm(ohsym1, "DECREASED APPETITE") | ///
		 regexm(ohsym2, "DECREASED APPETITE") | regexm(ohsym3, "DECREASED APPETITE") ///
		 | regexm(ohsym1, "REDUCED APPETITE") | regexm(ohsym2, "REDUCED APPETITE") | ///
		 regexm(ohsym3, "REDUCED APPETITE") ) & abstracted==1 & year==2020 & ( ohsym1!="" | ohsym2!=""| ///
		  ohsym3!="") 
******** //6
		 
*********************** ABDOMINAL PAIN ***********
count if (regexm(ohsym1, "ABDOMINAL PAIN") | regexm(ohsym2, "ABDOMINAL PAIN") | ///
         regexm(ohsym3, "ABDOMINAL PAIN") |regexm(ohsym1, "ABDOMINALPAIN") | ///
		 regexm(ohsym2, "ABDOMINALPAIN") | regexm(ohsym3, "ABDOMINALPAIN")) ///
		 & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="")
**********// 6

***************** BURPING / BELCHING * ******************
count if (regexm(ohsym1, "BURPING") | regexm(ohsym2, "BURPING") | regexm(ohsym3, "BURPING") | ///
         regexm(ohsym1, "BELCHING") | regexm(ohsym2, "BELCHING") | regexm(ohsym3, "BELCHING")) ///
           & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="") 
*******************// 5 

*********************** UNRESPONSIVENESS ********************
 count if (regexm(ohsym1, "UNRESPONSIVE") | regexm(ohsym2, "UNRESPONSIVE") | regexm(ohsym3, "UNRESPONSIVE")) ///
           & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="") 
*********// 12
** most common are nausea/bad feelings, cough and headache

** No of hsyms and signs by vital status
foreach var in symp_chpa symp_sob symp_vom symp_dizzy symp_loc symp_palp symp_sweat {
	recode `var' 2 99 = 0	
		}
	
egen chsym2020 = rsum(symp_chpa symp_sob symp_vom symp_dizzy symp_loc symp_palp symp_sweat)
label var chsym2020 "Number of hsyms"
tab chsym2020 if org_id!=. & abstracted==1
//tab chsym if org_id!=. & abstracted==1 & conf==2
tab chsym2020 if chsym2020!=0 & abstracted==1 & org_id!=.

** At least 2 symptoms

** Individual hsymS 
tab symp_chpa if abstracted==1  & year==2020  ,m
tab symp_sob if abstracted==1  & year==2020  ,m
tab symp_vom if abstracted==1  & year==2020 ,m
tab symp_dizzy if abstracted==1 & year==2020  ,m
tab symp_loc if abstracted==1  & year==2020 ,m
tab symp_palp if abstracted==1  & year==2020 ,m
tab symp_sweat if abstracted==1  & year==2020 ,m

** by sex
tab symp_chpa sex if abstracted==1  & year==2020  ,m
tab symp_sob sex if abstracted==1  & year==2020  ,m
tab symp_vom sex if abstracted==1  & year==2020 ,m
tab symp_dizzy sex if abstracted==1 & year==2020  ,m
tab symp_loc sex if abstracted==1  & year==2020 ,m
tab symp_palp sex if abstracted==1  & year==2020 ,m
tab symp_sweat sex if abstracted==1  & year==2020 ,m


*********************************************************
** TABLE 1.3 : RISK FACTORS *****************************
*********************************************************
preserve
drop if year!=2020
** Prior acute MI - define variable
** NOTE: assumption used here for all RFs is that if DA finds
** no documentation on RF then they don't have it, as one assumes
** that the doctor has had poor documentation rather than poor
** medical history-taking!!
** AH updated pr_ami coding this year as pami matching pr_ami
gen pr_ami = 1 if pami==1 
replace pr_ami=2 if pami==2
replace pr_ami=3 if pami==3
replace pr_ami=99 if pami==99
label var pr_ami "Prior AMI"
label define pr_ami_lab 1 "Yes,orig records" 2 "Yes, in notes" 3 "No" 99 "Not documented", modify
label values pr_ami pr_ami_lab

** AR to AH: pstroke is not a yes/no field - need to combine 1 and 2 as both mean "yes"
** updating coding so all years matching
** year 2018& 2019 had 3 options (1 Yes, 2 No, 3Nd )
** year 2016& 2017 had 4 options ( 1Yes, 2Yes , 3No,99Nd)
replace pstroke=99 if pstroke==3 & (year==2018 |year==2019)
replace pstroke=1 if pstroke<3 & (year==2016 | year==2017)
replace pstroke=2 if pstroke==3 & (year==2016 | year==2017)
codebook pstroke

tab pami if year==2020, miss
tab pr_ami if org_id!=. & year==2020, miss
** Next, the standard risk factors
local i=1
foreach var in pami pihd pstroke pcabg pcorangio htn hld diab smoker obese alco drugs {
	gen risk`i' = 1 if `var'==1
	replace risk`i' = 0 if `var'==2
	replace risk`i' = 0 if `var'==3
	label define risk`i'_lab 1 "yes" 0 "no", modify
	label values risk`i' risk`i'_lab	
	local i = `i'+1
	}

label var risk1 "prior AMI"
label var risk2 "prior IHD"
label var risk3 "prior stroke"
label var risk4 "prior CABG"
label var risk5 "prior coronary angio"
label var risk6 "hypertension"
label var risk7 "hyperliorg_idaemia"
label var risk8 "diabetes"
label var risk9 "smoking"
label var risk10 "obesity"
label var risk11 "alcohol use"
label var risk12 "drug use"



local i=1
foreach var in risk1 risk2 risk3 risk4 risk5 risk6 risk7 risk8 risk9 risk10 risk11 risk12 {
    replace risk1=pami if year==2020
	label values risk1 pstroke_lab
	tab risk`i' if abstracted==1 & year==2020 ,miss
	local i = `i'+1
	}
** Prior AMI 
** Prior IHD 
** Prior Stroke 
** Prior CABG
** Prior Coronary Angiograph 
** Hypertention 
** Hyperliorg_ida 
** Diabetes 
** Smoking 
** Obesity 
** Alcohol Use 
** Drug Use 


	egen crisk2020 = rsum(risk1 risk2 risk3 risk4 risk5 risk6 risk7 risk8 risk9 risk10 risk11 risk12 ) if year==2019
label var crisk2020 "Number of standard risk factors"
tab1 crisk2020


** Next, Family History risk factors
local i=13
foreach var in famami famstroke {
	gen risk`i' = 1 if `var'==1 & year==2020
	replace risk`i' = 0 if `var'==2 & year==2020
	replace risk`i' = 0 if `var'==99  & year==2020  
	local i = `i'+1
	}

egen crisk20202 = rsum(risk13 risk14) if  year==2020
label var crisk20202 "Number of family history risk factors"
tab1 crisk20202
drop risk*


** Family history in detail
list org_id mumami dadami sibami famami if (famami==1 |mumami==1|dadami==1| sibami==1) & year==2019 
replace famami=1 if mumami!=.| dadami!=. |sibami!=. & year==2020
count  if (famami==1 | mumami==1 | dadami==1) & year==2020 
count  if (sibami==1 | mumami==1 | dadami==1) & year==2020 

tab famami  if abstracted==1 & year==2020  ,miss
tab dadami  if abstracted==1 & year==2020  ,miss
tab mumami  if abstracted==1 & year==2020  ,miss
tab sibami if abstracted==1 & year==2020 , miss
tab famami if (dadami==1 | mumami==1) & year==2020
** Fam History 28/ (28+86)114
display 20/114

tab famstroke if org_id!=.  & year==2020  , miss
list mumstroke dadstroke sibstroke if famstroke==1  & year==2020

** for denominator info.
tab famami year ,miss
tab famstroke year ,miss

** Other Risk Factors
tab ovrf year ,m
sort ovrf*
list ovrf* if ovrf==1  & year==2020
list ovrf1 ovrf2 ovrf3 ovrf4 if ovrf1!=""  & year==2020

** Now count all risk factors together
gen risk2020 = crisk2020 + crisk20202 
label var risk2020 "2020 Number of all risk factors combined"
tab1 risk  ,miss
tab1 risk2020 if abstracted==1 & year==2020  ,miss
** No RF 10/ 257
restore 
