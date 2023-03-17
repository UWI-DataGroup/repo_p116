** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5i_analysis sym_stroke.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-MAR-2023
    // 	date last modified      16-MAR-2023
    //  algorithm task          Performing analysis on 2021 stroke data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               To analyse data relating to sub-type and presenting symptoms and signs
    //  methods                 Reviewing and categorizing the other symptoms variables
	//							Saving results into a dataset for output to Word (6_analysis report_cvd.do)
	//							Using analysis variables created in 5a_analysis prep_cvd.do
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
    log using "`logpath'\5i_analysis sym_stroke.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified STROKE 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //691

********************************
** Table 2.2: STROKE SUB-TYPE **
********************************
by sd_eyear, sort: tab stype sex, column
/*
  What type of stroke| Incidence Data: Sex
       was diagnosed?|   Female       Male|    Total
----------------------+----------------------+----------
     Ischaemic Stroke|      212        231|      443 
                     |    80.61      86.84|    83.74 
----------------------+----------------------+----------
Intracerebral Haemorr|       35         27|       62 
                     |    13.31      10.15|    11.72 
----------------------+----------------------+----------
Subarachnoid Haemorrh|       14          6|       20 
                     |     5.32       2.26|     3.78 
----------------------+----------------------+----------
    Unclassified Type|        2          2|        4 
                     |     0.76       0.75|     0.76 
----------------------+----------------------+----------
                Total|      263        266|      529 
                     |   100.00     100.00|   100.00
*/

by sd_eyear, sort: tab stype sex if sd_absstatus==1, column //numerator
/*
  What type of stroke| Incidence Data: Sex
       was diagnosed?|   Female       Male|    Total
----------------------+----------------------+----------
     Ischaemic Stroke|      203        216|      419 
                     |    80.88      86.75|    83.80 
----------------------+----------------------+----------
Intracerebral Haemorr|       35         25|       60 
                     |    13.94      10.04|    12.00 
----------------------+----------------------+----------
Subarachnoid Haemorrh|       11          6|       17 
                     |     4.38       2.41|     3.40 
----------------------+----------------------+----------
    Unclassified Type|        2          2|        4 
                     |     0.80       0.80|     0.80 
----------------------+----------------------+----------
                Total|      251        249|      500 
                     |   100.00     100.00|   100.00
*/

bysort sd_eyear: tab sd_absstatus sex  //denominator
/*
      Stata Derived:| Incidence Data: Sex
  Abstraction Status|   Female       Male|    Total
---------------------+----------------------+----------
    Full abstraction|      251        249|      500 
 Partial abstraction|       12         17|       29 
No abstraction (DCO)|       68         94|      162 
---------------------+----------------------+----------
               Total|      331        360|      691
*/

**********
** 2021 **
**********
preserve
contract stype sex if sd_absstatus==1
rename _freq number
egen tot_f=total(number) if sex==1
egen tot_m=total(number) if sex==2
gen percent_isch_f=number/tot_f*100 if stype==1 & sex==1
replace percent_isch_f=round(percent_isch_f,1.0)
gen percent_isch_m=number/tot_m*100 if stype==1 & sex==2
replace percent_isch_m=round(percent_isch_m,1.0)

gen percent_intra_f=number/tot_f*100 if stype==2 & sex==1
replace percent_intra_f=round(percent_intra_f,1.0)
gen percent_intra_m=number/tot_m*100 if stype==2 & sex==2
replace percent_intra_m=round(percent_intra_m,1.0)

gen percent_sah_f=number/tot_f*100 if stype==3 & sex==1
replace percent_sah_f=round(percent_sah_f,1.0)
gen percent_sah_m=number/tot_m*100 if stype==3 & sex==2
replace percent_sah_m=round(percent_sah_m,1.0)

drop if stype>3|stype==.
gen id=_n
order id

reshape wide stype number tot_f tot_m percent_isch_f percent_isch_m percent_intra_f percent_intra_m percent_sah_f percent_sah_m, i(id)  j(sex)
rename stype1 Stroke_Category

label var Stroke_Category "Stroke Category"
label define Stroke_Category_lab 1 "Ischaemic Stroke" 2 "Intracerebral Haemorrhage" 3 "Subarachnoid Haemorrhage" , modify
label values Stroke_Category Stroke_Category_lab

drop stype2 *_f2 *_m1
fillmissing tot_*
replace number2=number2[_n+1] if number2==.
replace percent_isch_m2=percent_isch_m2[_n+1] if percent_isch_m2==.
replace percent_intra_m2=percent_intra_m2[_n+1] if percent_intra_m2==.
replace percent_sah_m2=percent_sah_m2[_n+1] if percent_sah_m2==.
drop if id==2|id==4|id==6
gen total_abs_2021=tot_f+tot_m if Stroke_Category==1
drop tot_*
rename number1 num_f_2021
rename number2 num_m_2021
rename percent_isch_f1 percent_f_2021
rename percent_isch_m2 percent_m_2021
replace percent_f_2021=percent_intra_f1 if Stroke_Category==2
replace percent_m_2021=percent_intra_m2 if Stroke_Category==2
replace percent_f_2021=percent_sah_f1 if Stroke_Category==3
replace percent_m_2021=percent_sah_m2 if Stroke_Category==3
drop percent_intra* percent_sah*

order Stroke_Category num_f_2021 percent_f_2021 num_m_2021 percent_m_2021 total_abs_2021

save "`datapath'\version03\2-working\subtypes_stroke" ,replace
restore


*******************************************************
** TABLE 1.3 MAIN PRESENTING STROKE STMPTOMS & SIGNS **
*******************************************************
** Check if other cases aside from full abstractions have symptoms documented
tab sd_absstatus ,m
/*
      Stata Derived: |
  Abstraction Status|     Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction|       500       72.36       72.36
 Partial abstraction|        29        4.20       76.56
No abstraction (DCO)|       162       23.44      100.00
---------------------+-----------------------------------
               Total|       691      100.00
*/

tab eligible sd_absstatus ,m
/*
                     |   Stata Derived: Abstraction
 Incidence Data: Case|             Status
      Status-Eligible|Full abst  Partial a  No abstra|    Total
----------------------+---------------------------------+----------
Pending 28-day follow|        9          0          0|        9 
Confirmed but NOT ful|        0         29          0|       29 
            Completed|      491          0          0|      491 
                    .|        0          0        162|      162 
----------------------+---------------------------------+----------
                Total|      500         29        162|      691
*/

tab sd_absstatus sex ,m
/*
      Stata Derived:| Incidence Data: Sex
  Abstraction Status|   Female       Male|    Total
---------------------+----------------------+----------
    Full abstraction|      251        249|      500 
 Partial abstraction|       12         17|       29 
No abstraction (DCO)|       68         94|      162 
---------------------+----------------------+----------
               Total|      331        360|      691
*/

count if sd_absstatus==2 & (ssym1!=.|ssym2!=.|ssym3!=.|ssym4!=.|osym!=.) & (ssym1!=99999|ssym2!=99999|ssym3!=99999|ssym4!=99999|osym!=99999) //0

** Standardize other symptoms so it is easier to categorize them
replace osym1 = upper(rtrim(ltrim(itrim(osym1)))) //376 changes
replace osym2 = upper(rtrim(ltrim(itrim(osym2)))) //223 changes
replace osym3 = upper(rtrim(ltrim(itrim(osym3)))) //117 changes
replace osym4 = upper(rtrim(ltrim(itrim(osym4)))) //48 changes
replace osym5 = upper(rtrim(ltrim(itrim(osym5)))) //20 changes
replace osym6 = upper(rtrim(ltrim(itrim(osym6)))) //5 changes

** Review other symptoms to determine most common of these other symptoms
count if sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 //376
//list osym1 osym2 osym3 osym4 osym5 osym6 if sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999

** Check which is the most common other symptom
***********
** VOMIT **
***********
count if (regexm(osym1,"VOMIT")|regexm(osym2,"VOMIT")|regexm(osym3,"VOMIT")) ///
                & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//57

**********
** FALL **
**********
count if (regexm(osym1,"FALL")|regexm(osym2,"FALL")|regexm(osym3,"FALL") ///
		 |regexm(osym4,"FALL")|regexm(osym5,"FALL")|regexm(osym6,"FALL") ///
		 |regexm(osym1,"COLLAPSED")|regexm(osym2,"COLLAPSED")|regexm(osym3,"COLLAPSED") ///
		 |regexm(osym4,"COLLAPSED")|regexm(osym5,"COLLAPSED")|regexm(osym6,"COLLAPSED") ///
		 |regexm(osym1,"FELL")|regexm(osym2,"FELL")| regexm(osym3,"FELL") ///
		 |regexm(osym4,"FELL")|regexm(osym5,"FELL")| regexm(osym6,"FELL")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//68	 

*************
** SEIZURE **
*************				
count if (regexm(osym1,"SEIZURE") |regexm(osym2,"SEIZURE")|regexm(osym3,"SEIZURE") ///
		 |regexm(osym4,"SEIZURE") |regexm(osym5,"SEIZURE")|regexm(osym6,"SEIZURE")) ///
          & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//15

************
** UNWELL **
************
count if (regexm(osym1,"FEELING UNWELL") |regexm(osym2,"FEELING UNWELL")|regexm(osym3,"FEELING UNWELL") ///
		 |regexm(osym4,"FEELING UNWELL") |regexm(osym5,"FEELING UNWELL")|regexm(osym6,"FEELING UNWELL")) ///
          & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//9

******************
** INCONTINENCE **
******************	  
count if (regexm(osym1,"INCONTINENCE OF URINE")|regexm(osym2,"INCONTINENCE OF URINE")|regexm(osym3,"INCONTINENCE OF URINE") ///
		 |regexm(osym4,"INCONTINENCE OF URINE")|regexm(osym5,"INCONTINENCE OF URINE")|regexm(osym6,"INCONTINENCE OF URINE") ///
		 |regexm(osym1,"INCONTINENT OF URINE")|regexm(osym2,"INCONTINENT OF URINE")|regexm(osym3,"INCONTINENT OF URINE") ///
		 |regexm(osym4,"INCONTINENT OF URINE")|regexm(osym5,"INCONTINENT OF URINE")|regexm(osym6,"INCONTINENT OF URINE") ///
		 |regexm(osym1,"URINARY INCONTINENCE")|regexm(osym2,"URINARY INCONTINENCE")|regexm(osym3,"URINARY INCONTINENCE") ///
		 |regexm(osym4,"URINARY INCONTINENCE")|regexm(osym5,"URINARY INCONTINENCE")|regexm(osym6,"URINARY INCONTINENCE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//39

**************
** HEADACHE **
**************
count if (regexm(osym1,"HEADACHE")|regexm(osym2,"HEADACHE")|regexm(osym3,"HEADACHE") ///
		 |regexm(osym4,"HEADACHE")|regexm(osym5,"HEADACHE")|regexm(osym6,"HEADACHE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//89

** FEMALES  
count if (regexm(osym1,"HEADACHE")|regexm(osym2,"HEADACHE")|regexm(osym3,"HEADACHE") ///
		 |regexm(osym4,"HEADACHE")|regexm(osym5,"HEADACHE")|regexm(osym6,"HEADACHE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 & sex==1
//42

** MALES  
count if (regexm(osym1,"HEADACHE")|regexm(osym2,"HEADACHE")|regexm(osym3,"HEADACHE") ///
		 |regexm(osym4,"HEADACHE")|regexm(osym5,"HEADACHE")|regexm(osym6,"HEADACHE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 & sex==2
//47

**************
** NUMBNESS **
************** 
count if (regexm(osym1,"NUMB")|regexm(osym2,"NUMB")|regexm(osym3,"NUMB") ///
		 |regexm(osym4,"NUMB")|regexm(osym5,"NUMB")|regexm(osym6,"NUMB")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//3

**************
** WEAKNESS **
**************
count if (regexm(osym1,"WEAK")|regexm(osym2,"WEAK")|regexm(osym3,"WEAK") ///
		 |regexm(osym4,"WEAK")|regexm(osym5,"WEAK")|regexm(osym6,"WEAK")) ///
           & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//13

**********
** GAIT **
**********
count if (regexm(osym1,"UNABLE TO WALK")|regexm(osym2,"UNABLE TO WALK")|regexm(osym3,"UNABLE TO WALK") ///
		 |regexm(osym4,"UNABLE TO WALK")|regexm(osym5,"UNABLE TO WALK")|regexm(osym6,"UNABLE TO WALK") ///
         |regexm(osym1,"UNABLE TO WEIGHT BEAR")|regexm(osym2,"UNABLE TO WEIGHT BEAR")|regexm(osym3,"UNABLE TO WEIGHT BEAR") ///
         |regexm(osym4,"UNABLE TO WEIGHT BEAR")|regexm(osym5,"UNABLE TO WEIGHT BEAR")|regexm(osym6,"UNABLE TO WEIGHT BEAR") ///
		 |regexm(osym1,"UNSTEADY GAIT")|regexm(osym2,"UNSTEADY GAIT")|regexm(osym3,"UNSTEADY GAIT") ///
		 |regexm(osym4,"UNSTEADY GAIT")|regexm(osym5,"UNSTEADY GAIT")|regexm(osym6,"UNSTEADY GAIT") ///
		 |regexm(osym1,"DIFFICULTY WALKING")|regexm(osym2,"DIFFICULTY WALKING")|regexm(osym3,"DIFFICULTY WALKING") ///
		 |regexm(osym4,"DIFFICULTY WALKING")|regexm(osym5,"DIFFICULTY WALKING")|regexm(osym6,"DIFFICULTY WALKING")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//56

***************
** CONFUSION **
***************
count if (regexm(osym1,"DISORIENTED")|regexm(osym2,"DISORIENTED")|regexm(osym3,"DISORIENTED") ///
		 |regexm(osym4,"DISORIENTED")|regexm(osym5,"DISORIENTED")|regexm(osym6,"DISORIENTED") ///
		 |regexm(osym1,"CONFUSION")|regexm(osym2,"CONFUSION")|regexm(osym3,"CONFUSION") ///
		 |regexm(osym4,"CONFUSED")|regexm(osym5,"CONFUSED")| regexm(osym6,"CONFUSED")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//18
** most common are headache, fall, vomit and unsteady gait


** Check totals for each symptom
tab ssym1 if sd_absstatus==1 ,m //yes=317 speech
tab ssym2 if sd_absstatus==1 ,m //yes=160 response
tab ssym3 if sd_absstatus==1 ,m //yes=361 weakness
tab ssym4 if sd_absstatus==1 ,m //yes=18 swallow
 
** Create variable with total number of symptoms
foreach var in ssym1 ssym2 ssym3 ssym4 {
	recode `var' 2 99 99999 = 0	
		}

egen symtot = rsum(ssym1 ssym2 ssym3 ssym4)

** JC update: Save these results as a dataset for reporting Table 2.3
preserve
tab symtot if sd_absstatus==1
count if sd_absstatus==1 //500
tab sex if sd_absstatus==1
/*
  Incidence |
  Data: Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |        251       50.20       50.20
       Male |        249       49.80      100.00
------------+-----------------------------------
      Total |        500      100.00
*/

** Create variable to capture the highest count of the other symptom variable
gen ssym_oth=1 if (regexm(osym1,"HEADACHE")|regexm(osym2,"HEADACHE")|regexm(osym3,"HEADACHE") ///
		 |regexm(osym4,"HEADACHE")|regexm(osym5,"HEADACHE")|regexm(osym6,"HEADACHE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//89

save "`datapath'\version03\2-working\symptoms_stroke" ,replace

contract sex if sd_absstatus==1 & ssym1==1
gen ssym_ar=1
save "`datapath'\version03\2-working\symptoms_stroke_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_stroke" ,clear
contract sex if sd_absstatus==1 & ssym3==1
gen ssym_ar=2

append using "`datapath'\version03\2-working\symptoms_stroke_ar"

save "`datapath'\version03\2-working\symptoms_stroke_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_stroke" ,clear
contract sex if sd_absstatus==1 & ssym2==1
gen ssym_ar=3

append using "`datapath'\version03\2-working\symptoms_stroke_ar"

save "`datapath'\version03\2-working\symptoms_stroke_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_stroke" ,clear
contract sex if sd_absstatus==1 & ssym_oth==1
gen ssym_ar=4

append using "`datapath'\version03\2-working\symptoms_stroke_ar"

save "`datapath'\version03\2-working\symptoms_stroke_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_stroke" ,clear
contract sex if sd_absstatus==1 & ssym4==1
gen ssym_ar=5

append using "`datapath'\version03\2-working\symptoms_stroke_ar"

save "`datapath'\version03\2-working\symptoms_stroke_ar" ,replace

clear

** Create variables for totals for all patients (combined and separately for sex) with info for 2020
use "`datapath'\version03\2-working\symptoms_stroke" ,clear
egen totsympts=count(sd_etype) if sd_absstatus==1
egen totsympts_f=count(sd_etype) if sd_absstatus==1 & sex==1
egen totsympts_m=count(sd_etype) if sd_absstatus==1 & sex==2
gen ssym_ar=6
collapse totsympts totsympts_f totsympts_m

append using "`datapath'\version03\2-working\symptoms_stroke_ar"

replace ssym_ar=6 if ssym_ar==.
sort sex ssym_ar
gen id=_n
order id ssym_ar sex _freq totsympts
fillmissing totsympts totsympts_f totsympts_m
rename _freq number


label define ssym_lab 1 "Difficulty speaking" 2 "Unilateral Weakness" 3 "Diminished responsiveness" 4 "Headache" 5 "Difficulty or inability to swallow" 6 "Total Patients" ,modify
label values ssym_ar ssym_lab
label var ssym_ar "Symptom"

** Create variables for totals for each symptom
gen number_total=sum(number) if ssym_ar==1
replace number_total=sum(number) if ssym_ar==2
replace number_total=sum(number) if ssym_ar==3
replace number_total=sum(number) if ssym_ar==4
replace number_total=sum(number) if ssym_ar==5
replace number_total=. if sex==1

** Create variables for % of totals for each symptom
gen percent_total=number_tot/totsympts*100 if ssym_ar==1 & number_total!=.
replace percent_total=number_tot/totsympts*100 if ssym_ar==2 & number_total!=.
replace percent_total=number_tot/totsympts*100 if ssym_ar==3 & number_total!=.
replace percent_total=number_tot/totsympts*100 if ssym_ar==4 & number_total!=.
replace percent_total=number_tot/totsympts*100 if ssym_ar==5 & number_total!=.
replace percent_total=round(percent_total,1.0)

** Create variables for % of totals for each symptom by sex
gen percent_female=number/totsympts_f*100 if sex==1
replace percent_female=round(percent_female,1.0)

gen percent_male=number/totsympts_m*100 if sex==2
replace percent_male=round(percent_male,1.0)

** Organize dataset to mirror layout of Table 1.3 of annual report
order id ssym_ar sex number percent_female percent_male number_total percent_total totsympts totsympts_f totsympts_m 
replace percent_female=percent_male if percent_female==. & ssym_ar!=6
drop percent_male
rename percent_female percent
drop if ssym_ar==6
replace number_total=number_total[_n+5] if number_total==.
replace percent_total=percent_total[_n+5] if percent_total==.

reshape wide ssym_ar number percent, i(id)  j(sex)
rename ssym_ar1 ssym_ar
rename number1 number_female
rename percent1 percent_female
rename number2 number_male
rename percent2 percent_male
replace number_male=number_male[_n+5] if number_male==.
replace percent_male=percent_male[_n+5] if percent_male==.
drop if id>5
drop ssym_ar2

label var number_female "Women #"
label var percent_female "Women %"
label var number_male "Men #"
label var percent_male "Men %"
label var number_total "Total #"
label var percent_total "Total %"

** Remove the temp database created above to reduce space used on SharePoint
erase "`datapath'\version03\2-working\symptoms_stroke_ar.dta"
save "`datapath'\version03\2-working\symptoms_stroke" ,replace
restore

