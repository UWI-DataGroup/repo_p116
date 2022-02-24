cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.2_heart_cvd_analysis.do
    //  project:                BNR Heart
    //  analysts:               Ashley HENRY and Jacqueline CAMPBELL
    //  date first created:     27-Jan-2022
    //  date last modified:     24-Feb-2022
	//  analysis:               Heart 2020 dataset for Annual Report
    //  algorithm task          Performing Heart 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to analyse Heart Symptoms and Risk Factors
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
    log using "`logpath'\1.2_heart_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Table 1.2 2020 Heart Symptoms
 *              Table 1.3 2020 Risk Factors
************************************************************************
** Load the dataset  
use "`datapath'\version02\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)"

count
**4794 seen 27-Jan-2022

** JC 17feb2022: Sex updated for 2018 pid that has sex=99 using MedData
replace sex=1 if anon_pid==596 & record_id=="20181197" //1 change


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
// 19
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
// 65	 
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
// 29
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
// 36

************ DIARRHEA		   
count if (regexm(ohsym1, "DIAR") |regexm(ohsym2, "DIAR") | regexm(ohsym3, "DIAR")) ///
          & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="") 
// 2

*************** DECREASED RESPONSIVENESS**********************	  
count if (regexm(ohsym1, "DECREASED RESPO") | regexm(ohsym2, "DECREASED RESPO") | ///
         regexm(ohsym3, "DECREASED RESPO") ) & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ///
		 ohsym3!="")
// 8

************* HEADACHE ************************
count if (regexm(ohsym1, "HEADACHE") | regexm(ohsym2, "HEADACHE") | ///
         regexm(ohsym3, "HEADACHE")) & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ///
		 ohsym3!="")
// 13

****************** NUMBNESS ***********************
count if (regexm(ohsym1, "NUMBNESS") | regexm(ohsym1, "NUMBNESS") | ///
          regexm(ohsym1, "NUMBNESS")) & abstracted==1 & year==2020 & ( ohsym1!="" | ohsym2!="" | ohsym3!="") 
// 2

*********WEAK******** 
count if (regexm(ohsym1, "WEAK") | regexm(ohsym2, "WEAK") | regexm(ohsym3, "WEAK")) ///
           & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="")
// 11

***************DECREASED APPETITE
count if (regexm(ohsym1, "DECR APPETITE") | regexm(ohsym2, "DECR APPETITE") | ///
         regexm(ohsym3, "DECR APPETITE") | regexm(ohsym1, "DECREASED APPETITE") | ///
		 regexm(ohsym2, "DECREASED APPETITE") | regexm(ohsym3, "DECREASED APPETITE") ///
		 | regexm(ohsym1, "REDUCED APPETITE") | regexm(ohsym2, "REDUCED APPETITE") | ///
		 regexm(ohsym3, "REDUCED APPETITE") ) & abstracted==1 & year==2020 & ( ohsym1!="" | ohsym2!=""| ///
		  ohsym3!="") 
//6
		 
*********************** ABDOMINAL PAIN ***********
count if (regexm(ohsym1, "ABDOMINAL PAIN") | regexm(ohsym2, "ABDOMINAL PAIN") | ///
         regexm(ohsym3, "ABDOMINAL PAIN") |regexm(ohsym1, "ABDOMINALPAIN") | ///
		 regexm(ohsym2, "ABDOMINALPAIN") | regexm(ohsym3, "ABDOMINALPAIN")) ///
		 & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="")
// 6

***************** BURPING / BELCHING * ******************
count if (regexm(ohsym1, "BURPING") | regexm(ohsym2, "BURPING") | regexm(ohsym3, "BURPING") | ///
         regexm(ohsym1, "BELCHING") | regexm(ohsym2, "BELCHING") | regexm(ohsym3, "BELCHING")) ///
           & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="") 
// 5 

*********************** UNRESPONSIVENESS ********************
 count if (regexm(ohsym1, "UNRESPONSIVE") | regexm(ohsym2, "UNRESPONSIVE") | regexm(ohsym3, "UNRESPONSIVE")) ///
           & abstracted==1 & year==2020 & ( ohsym1!="" |  ohsym2!=""| ohsym3!="") 
// 12
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

** JC update: Save these results as a dataset for reporting Table 1.3
preserve
tab chsym2020 if year==2020 & abstracted==1
count if abstracted==1 & year==2020 //291
tab sex if abstracted==1 & year==2020
/*
        Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |        125       42.96       42.96
       Male |        166       57.04      100.00
------------+-----------------------------------
      Total |        291      100.00
*/

** Create variable to capture the highest count of the other symptom variable
gen symp_oth=1 if (regexm(ohsym1, "NAUSEA") | regexm(ohsym2, "NAUSEA") | regexm(ohsym3, "NAUSEA") | ///
               regexm(ohsym1, "MALAISE") | regexm(ohsym2, "MALAISE") | ///
			   regexm(ohsym3, "MALAISE") | regexm(ohsym1, "BAD FEEL") | ///
			   regexm(ohsym2, "BAD FEEL")| regexm(ohsym3, "BAD FEEL") | ///
			   regexm(ohsym1, "UNWELL") | regexm(ohsym2, "UNWELL") | ///
			   regexm(ohsym3, "UNWELL") | regexm(ohsym1, "FEELING BAD") | ///
			   regexm(ohsym2, "FEELING BAD") | regexm(ohsym3, "FEELING BAD") ///
			   | regexm(ohsym1, "NOT FEELING WELL") | regexm(ohsym2, "NOT FEELING WELL") ///
			   | regexm(ohsym3, "NOT FEELING WELL") ) & abstracted==1 & year==2020 & ///
			   ( ohsym1!="" |  ohsym2!=""| ohsym3!="")


save "`datapath'\version02\2-working\symptoms_heart" ,replace

contract sex if abstracted==1 & year==2020 & symp_chpa==1
gen hsym_ar=1
save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_sob==1
gen hsym_ar=2

append using "`datapath'\version02\2-working\symptoms_heart_ar"

save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_sweat==1
gen hsym_ar=3

append using "`datapath'\version02\2-working\symptoms_heart_ar"

save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_vom==1
gen hsym_ar=4

append using "`datapath'\version02\2-working\symptoms_heart_ar"

save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_oth==1
gen hsym_ar=5

append using "`datapath'\version02\2-working\symptoms_heart_ar"

save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_palp==1
gen hsym_ar=6

append using "`datapath'\version02\2-working\symptoms_heart_ar"

save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_dizzy==1
gen hsym_ar=7

append using "`datapath'\version02\2-working\symptoms_heart_ar"

save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version02\2-working\symptoms_heart" ,clear
contract sex if abstracted==1 & year==2020 & symp_loc==1
gen hsym_ar=8

append using "`datapath'\version02\2-working\symptoms_heart_ar"


save "`datapath'\version02\2-working\symptoms_heart_ar" ,replace

clear

** Create variables for totals for all patients (combined and separately for sex) with info for 2020
use "`datapath'\version02\2-working\symptoms_heart" ,clear
egen totsympts=count(anon_pid) if abstracted==1 & year==2020
egen totsympts_f=count(anon_pid) if abstracted==1 & year==2020 & sex==1
egen totsympts_m=count(anon_pid) if abstracted==1 & year==2020 & sex==2
gen hsym_ar=9
collapse totsympts totsympts_f totsympts_m

append using "`datapath'\version02\2-working\symptoms_heart_ar"

replace hsym_ar=9 if hsym_ar==.
sort sex hsym_ar
gen id=_n
order id hsym_ar sex _freq totsympts
fillmissing totsympts totsympts_f totsympts_m
rename _freq number


label define hsym_lab 1 "Chest pain" 2 "Shortness of breath" 3 "Sweating" 4 "Sudden vomiting" 5 "Light-headness, nausea/malaise" 6 "Palpitations" 7 "Sudden dizziness/vertigo" 8 "Loss of consciousness" 9 "Total Patients" ,modify
label values hsym_ar hsym_lab
label var hsym_ar "Symptom"

** Create variables for totals for each symptom
gen number_total=sum(number) if hsym_ar==1
replace number_total=sum(number) if hsym_ar==2
replace number_total=sum(number) if hsym_ar==3
replace number_total=sum(number) if hsym_ar==4
replace number_total=sum(number) if hsym_ar==5
replace number_total=sum(number) if hsym_ar==6
replace number_total=sum(number) if hsym_ar==7
replace number_total=sum(number) if hsym_ar==8
replace number_total=. if sex==1

** Create variables for % of totals for each symptom
gen percent_total=number_tot/totsympts*100 if hsym_ar==1 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==2 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==3 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==4 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==5 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==6 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==7 & number_total!=.
replace percent_total=number_tot/totsympts*100 if hsym_ar==8 & number_total!=.
replace percent_total=round(percent_total,1.0)

** Create variables for % of totals for each symptom by sex
gen percent_female=number/totsympts_f*100 if sex==1
replace percent_female=round(percent_female,1.0)

gen percent_male=number/totsympts_m*100 if sex==2
replace percent_male=round(percent_male,1.0)

** Organize dataset to mirror layout of Table 1.3 of annual report
order id hsym_ar sex number percent_female percent_male number_total percent_total totsympts totsympts_f totsympts_m 
replace percent_female=percent_male if percent_female==. & hsym_ar!=9
drop percent_male
rename percent_female percent
drop if id==17
replace number_total=number_total[_n+8] if number_total==.
replace percent_total=percent_total[_n+8] if percent_total==.

reshape wide hsym_ar number percent, i(id)  j(sex)
rename hsym_ar1 hsym_ar
rename number1 number_female
rename percent1 percent_female
rename number2 number_male
rename percent2 percent_male
replace number_male=number_male[_n+8] if number_male==.
replace percent_male=percent_male[_n+8] if percent_male==.
drop if id>8
drop hsym_ar2

label var number_female "Women #"
label var percent_female "Women %"
label var number_male "Men #"
label var percent_male "Men %"
label var number_total "Total #"
label var percent_total "Total %"

** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version02\2-working\symptoms_heart_ar.dta"
save "`datapath'\version02\2-working\symptoms_heart" ,replace
restore


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

** JC 24feb2022: Not sure I understand purpose of below code since all previous years are removed above

** AR to AH: pstroke is not a yes/no field - need to combine 1 and 2 as both mean "yes"
** updating coding so all years matching
** year 2018& 2019 had 3 options (1 Yes, 2 No, 3Nd )
** year 2016& 2017 had 4 options ( 1Yes, 2Yes , 3No,99Nd)
replace pstroke=99 if pstroke==3 & (year==2018 |year==2019)
replace pstroke=1 if pstroke<3 & (year==2016 | year==2017)
replace pstroke=2 if pstroke==3 & (year==2016 | year==2017)
codebook pstroke

/* JC 24feb2022: 257 missing from pstroke so checked this using below code
tab event abstracted if pstroke==. //all are DCOs
*/
** JC 24feb2022: NS indicated that we shouldn't report anything under 50% of the total cases with info
tab pami if year==2020, miss
tab pr_ami if org_id!=. & year==2020, miss
** Next, the standard risk factors
local i=1
foreach var in pami pihd pstroke pcabg pcorangio htn hld diab smoker obese alco drugs {
	gen risk`i' = 1 if `var'==1
	replace risk`i' = 2 if `var'==2
	replace risk`i' = 2 if `var'==3
	label define risk`i'_lab 1 "yes" 2 "no", modify //JC 24feb2022 changed to match other yes/no labels
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

** JC update: Save these results as a dataset for reporting Table 1.4
save "`datapath'\version02\2-working\riskfactors_heart_ar" ,replace

** JC 24feb2022: 

//Prior AMI
tab risk1 if year==2020 & abstracted==1 ,m
contract risk1 if year==2020 & abstracted==1 & risk1!=.
sort risk*
gen id=_n
gen rftype_ar=1
gen rf_ar=1
rename _freq number
gen denominator=sum(number)
replace denominator=. if id!=3
replace denominator=denominator[_n+2] if denominator==.
drop if id!=1
gen rf_percent=number/denominator*100
save "`datapath'\version02\2-working\riskfactors_heart" ,replace

clear

//Prior stroke
use "`datapath'\version02\2-working\riskfactors_heart_ar" ,clear
tab risk3 if year==2020 & abstracted==1 ,m
contract risk3 if year==2020 & abstracted==1 & risk3!=.
gen id=_n
gen rftype_ar=1
gen rf_ar=2
rename _freq number
gen denominator=sum(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=2
gen rf_percent=number/denominator*100
append using "`datapath'\version02\2-working\riskfactors_heart"
save "`datapath'\version02\2-working\riskfactors_heart" ,replace

clear

//Hypertension
use "`datapath'\version02\2-working\riskfactors_heart_ar" ,clear
tab risk6 if year==2020 & abstracted==1 ,m
contract risk6 if year==2020 & abstracted==1 & risk6!=.
gen id=_n
gen rftype_ar=2
gen rf_ar=3
rename _freq number
gen denominator=sum(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=3
gen rf_percent=number/denominator*100

append using "`datapath'\version02\2-working\riskfactors_heart"
save "`datapath'\version02\2-working\riskfactors_heart" ,replace

clear

//Diabetes
use "`datapath'\version02\2-working\riskfactors_heart_ar" ,clear
tab risk8 if year==2020 & abstracted==1 ,m
contract risk8 if year==2020 & abstracted==1 & risk8!=.
gen id=_n
gen rftype_ar=2
gen rf_ar=4
rename _freq number
gen denominator=sum(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=4
gen rf_percent=number/denominator*100

append using "`datapath'\version02\2-working\riskfactors_heart"
save "`datapath'\version02\2-working\riskfactors_heart" ,replace

clear

//Obesity - JC 24feb2022: NS indciated that after discussion during re-engineer process this should be collected as an enhanced var since it's poorly collected so can exclude in 2020 annual rpt
/*
** Create variable with combined risk factors from the other risk factor fields
replace ovrf1 = upper(rtrim(ltrim(itrim(ovrf1)))) //51 changes
replace ovrf2 = upper(rtrim(ltrim(itrim(ovrf2)))) //13 changes
replace ovrf3 = upper(rtrim(ltrim(itrim(ovrf3)))) //3 changes
replace ovrf4 = upper(rtrim(ltrim(itrim(ovrf4)))) //1 changes
gen risk_oth=ovrf1+" "+ovrf2+" "+ovrf3+" "+ovrf4 if ovrf!=99 & ovrf!=5 & ovrf!=. //85

** Create variable to capture the highest count of the other symptom variable
count if (regexm(risk_oth, "OBES") | regexm(risk_oth, "OBESITY") | regexm(risk_oth, "OBESE") | ///
          regexm(risk_oth, "OVERW")) & abstracted==1 & year==2020 & ///
		 (risk_oth!=""|risk_oth!=""|risk_oth!="") //5
*/

//Alcohol use
use "`datapath'\version02\2-working\riskfactors_heart_ar" ,clear
tab risk11 if year==2020 & abstracted==1 ,m
contract risk11 if year==2020 & abstracted==1 & risk11!=.
gen id=_n
gen rftype_ar=3
gen rf_ar=5
rename _freq number
gen denominator=sum(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=5
gen rf_percent=number/denominator*100

append using "`datapath'\version02\2-working\riskfactors_heart"
save "`datapath'\version02\2-working\riskfactors_heart" ,replace

clear

//Smoking
use "`datapath'\version02\2-working\riskfactors_heart_ar" ,clear
tab risk9 if year==2020 & abstracted==1 ,m
contract risk9 if year==2020 & abstracted==1 & risk9!=.
gen id=_n
gen rftype_ar=3
gen rf_ar=6
rename _freq number
gen denominator=sum(number)
replace denominator=. if id!=2
replace denominator=denominator[_n+1] if denominator==.
drop if id!=1
replace id=6
gen rf_percent=number/denominator*100

append using "`datapath'\version02\2-working\riskfactors_heart"


** format
replace rf_percent=round(rf_percent,1.0)

order id rftype_ar rf_ar number rf_percent denominator

label define rftype_ar_lab 1 "Prior CVD event/disease" 2 "Current co-morbidity" 3 "Lifestyle-related" ,modify
label values rftype_ar rftype_ar_lab
label var rftype_ar "Risk factor type"

label define rf_ar_lab 1 "Prior acute MI" 2 "Prior stroke" 3 "Hypertension" 4 "Diabetes" 5 "Alcohol use" 6 "Smoking" ,modify
label values rf_ar rf_ar_lab
label var rf_ar "Risk factor"

drop risk*
sort rf_ar

** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version02\2-working\riskfactors_heart_ar.dta"
save "`datapath'\version02\2-working\riskfactors_heart" ,replace

/*
** JC 24feb2022: NS indicated this can be commented out as not currently used
** JC 24feb2022: changed below year from 2019 to 2020 and added abstracted==1
egen crisk2020 = rsum(risk1 risk2 risk3 risk4 risk5 risk6 risk7 risk8 risk9 risk10 risk11 risk12 ) if year==2020 & abstracted==1
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


** JC 24feb2022: changed below year from 2019 to 2020
** Family history in detail
list org_id mumami dadami sibami famami if (famami==1 |mumami==1|dadami==1| sibami==1) & year==2020
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
//JC 24feb2022: unsure where the above figures came from as not seeing these in the outputs; Now checked 2019 analysis dofile and found the above display figures pertain to 2019 outputs not 2020.

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
*/
restore 
