** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5h_analysis sym_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-MAR-2023
    // 	date last modified      16-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               To analyse data relating to presenting symptoms and signs
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
    log using "`logpath'\5h_analysis sym_heart.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467

******************************************************
** TABLE 1.3 MAIN PRESENTING HEART STMPTOMS & SIGNS **
******************************************************
** Check if other cases aside from full abstractions have symptoms documented
tab sd_absstatus ,m
/*
      Stata Derived: |
  Abstraction Status |      Freq.     Percent        Cum.
---------------------+-----------------------------------
    Full abstraction |        185       39.61       39.61
 Partial abstraction |         16        3.43       43.04
No abstraction (DCO) |        266       56.96      100.00
---------------------+-----------------------------------
               Total |        467      100.00
*/

tab eligible sd_absstatus ,m
/*
                      |    Stata Derived: Abstraction
 Incidence Data: Case |              Status
      Status-Eligible | Full abst  Partial a  No abstra |     Total
----------------------+---------------------------------+----------
Pending 28-day follow |         1          0          0 |         1 
Confirmed but NOT ful |         0         16          0 |        16 
            Completed |       184          0          0 |       184 
                    . |         0          0        266 |       266 
----------------------+---------------------------------+----------
                Total |       185         16        266 |       467
*/

tab sd_absstatus sex ,m
/*
      Stata Derived: |  Incidence Data: Sex
  Abstraction Status |    Female       Male |     Total
---------------------+----------------------+----------
    Full abstraction |        83        102 |       185 
 Partial abstraction |         6         10 |        16 
No abstraction (DCO) |       133        133 |       266 
---------------------+----------------------+----------
               Total |       222        245 |       467
*/

count if sd_absstatus==2 & (hsym1!=.|hsym2!=.|hsym3!=.|hsym4!=.|hsym5!=.|hsym6!=.|hsym7!=.|osym!=.) & (hsym1!=99999|hsym2!=99999|hsym3!=99999|hsym4!=99999|hsym5!=99999|hsym6!=99999|hsym7!=99999|osym!=99999) //1 - record 2920 has symptom info but will leave out as it is only partially abstracted and it'll skew cases with full info stat on other parts of the report

** Standardize other symptoms so it is easier to categorize them
replace osym1 = upper(rtrim(ltrim(itrim(osym1)))) //120 changes
replace osym2 = upper(rtrim(ltrim(itrim(osym2)))) //44 changes
replace osym3 = upper(rtrim(ltrim(itrim(osym3)))) //16 changes
replace osym4 = upper(rtrim(ltrim(itrim(osym4)))) //4 changes
replace osym5 = upper(rtrim(ltrim(itrim(osym5)))) //1 change
replace osym6 = upper(rtrim(ltrim(itrim(osym6)))) //0 changes

** Review other symptoms to determine most common of these other symptoms
count if sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 //119
//list osym1 osym2 osym3 osym4 osym5 osym6 if sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999

** Check which is the most common other symptom
***********
** COUGH **
***********
count if (regexm(osym1,"COUGH")|regexm(osym2,"COUGH")|regexm(osym3,"COUGH") ///
		 |regexm(osym4,"COUGH")|regexm(osym5,"COUGH")|regexm(osym6,"COUGH")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
// 11
dis 11/185

************
** NAUSEA **
************
count if ((regexm(osym1,"NAUSEA")|regexm(osym2,"NAUSEA")|regexm(osym3,"NAUSEA") ///  
		 |regexm(osym4,"NAUSEA")|regexm(osym5,"NAUSEA")|regexm(osym6,"NAUSEA") ///
         |regexm(osym1,"MALAISE")|regexm(osym2,"MALAISE")|regexm(osym3,"MALAISE") ///
		 |regexm(osym4,"MALAISE")|regexm(osym5,"MALAISE")|regexm(osym6,"MALAISE") ///
		 |regexm(osym1,"BAD FEEL")|regexm(osym2,"BAD FEEL")|regexm(osym3,"BAD FEEL") ///
		 |regexm(osym4,"BAD FEEL")|regexm(osym5,"BAD FEEL")|regexm(osym6,"BAD FEEL") ///
		 |regexm(osym1,"UNWELL")|regexm(osym2,"UNWELL")|regexm(osym3,"UNWELL") ///
		 |regexm(osym4,"UNWELL")|regexm(osym5,"UNWELL")|regexm(osym6,"UNWELL") ///
		 |regexm(osym1,"FEELING BAD")|regexm(osym2,"FEELING BAD")|regexm(osym3,"FEELING BAD") ///
		 |regexm(osym4,"FEELING BAD")|regexm(osym5,"FEELING BAD")|regexm(osym6,"FEELING BAD") ///
		 |regexm(osym1,"NOT FEELING WELL")|regexm(osym2,"NOT FEELING WELL")|regexm(osym3,"NOT FEELING WELL")) ///
		 |regexm(osym4,"NOT FEELING WELL")|regexm(osym5,"NOT FEELING WELL")|regexm(osym6,"NOT FEELING WELL")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999	
//59	 
dis 59/185

************
** NAUSEA **
************
** FEMALES
count if ((regexm(osym1,"NAUSEA")|regexm(osym2,"NAUSEA")|regexm(osym3,"NAUSEA") ///  
		 |regexm(osym4,"NAUSEA")|regexm(osym5,"NAUSEA")|regexm(osym6,"NAUSEA") ///
         |regexm(osym1,"MALAISE")|regexm(osym2,"MALAISE")|regexm(osym3,"MALAISE") ///
		 |regexm(osym4,"MALAISE")|regexm(osym5,"MALAISE")|regexm(osym6,"MALAISE") ///
		 |regexm(osym1,"BAD FEEL")|regexm(osym2,"BAD FEEL")|regexm(osym3,"BAD FEEL") ///
		 |regexm(osym4,"BAD FEEL")|regexm(osym5,"BAD FEEL")|regexm(osym6,"BAD FEEL") ///
		 |regexm(osym1,"UNWELL")|regexm(osym2,"UNWELL")|regexm(osym3,"UNWELL") ///
		 |regexm(osym4,"UNWELL")|regexm(osym5,"UNWELL")|regexm(osym6,"UNWELL") ///
		 |regexm(osym1,"FEELING BAD")|regexm(osym2,"FEELING BAD")|regexm(osym3,"FEELING BAD") ///
		 |regexm(osym4,"FEELING BAD")|regexm(osym5,"FEELING BAD")|regexm(osym6,"FEELING BAD") ///
		 |regexm(osym1,"NOT FEELING WELL")|regexm(osym2,"NOT FEELING WELL")|regexm(osym3,"NOT FEELING WELL")) ///
		 |regexm(osym4,"NOT FEELING WELL")|regexm(osym5,"NOT FEELING WELL")|regexm(osym6,"NOT FEELING WELL")) ///
         & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 & sex==1
//32
dis 32/83
** MALES
count if ((regexm(osym1,"NAUSEA")|regexm(osym2,"NAUSEA")|regexm(osym3,"NAUSEA") ///  
		 |regexm(osym4,"NAUSEA")|regexm(osym5,"NAUSEA")|regexm(osym6,"NAUSEA") ///
         |regexm(osym1,"MALAISE")|regexm(osym2,"MALAISE")|regexm(osym3,"MALAISE") ///
		 |regexm(osym4,"MALAISE")|regexm(osym5,"MALAISE")|regexm(osym6,"MALAISE") ///
		 |regexm(osym1,"BAD FEEL")|regexm(osym2,"BAD FEEL")|regexm(osym3,"BAD FEEL") ///
		 |regexm(osym4,"BAD FEEL")|regexm(osym5,"BAD FEEL")|regexm(osym6,"BAD FEEL") ///
		 |regexm(osym1,"UNWELL")|regexm(osym2,"UNWELL")|regexm(osym3,"UNWELL") ///
		 |regexm(osym4,"UNWELL")|regexm(osym5,"UNWELL")|regexm(osym6,"UNWELL") ///
		 |regexm(osym1,"FEELING BAD")|regexm(osym2,"FEELING BAD")|regexm(osym3,"FEELING BAD") ///
		 |regexm(osym4,"FEELING BAD")|regexm(osym5,"FEELING BAD")|regexm(osym6,"FEELING BAD") ///
		 |regexm(osym1,"NOT FEELING WELL")|regexm(osym2,"NOT FEELING WELL")|regexm(osym3,"NOT FEELING WELL")) ///
		 |regexm(osym4,"NOT FEELING WELL")|regexm(osym5,"NOT FEELING WELL")|regexm(osym6,"NOT FEELING WELL")) ///
         & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 & sex==2
//27
dis 27/102


**************
** DIARRHEA	**
**************
count if (regexm(osym1,"DIAR")|regexm(osym2,"DIAR")|regexm(osym3,"DIAR") ///
		 |regexm(osym4,"DIAR")|regexm(osym5,"DIAR")|regexm(osym6,"DIAR") ///
		 |regexm(osym1,"LOOSE STOOLS")|regexm(osym2,"LOOSE STOOLS")|regexm(osym3,"LOOSE STOOLS") ///
		 |regexm(osym4,"LOOSE STOOLS")|regexm(osym5,"LOOSE STOOLS")|regexm(osym6,"LOOSE STOOLS")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//5

******************************
** DECREASED RESPONSIVENESS **
******************************	  
count if (regexm(osym1,"DECREASED RESPO")|regexm(osym2,"DECREASED RESPO")|regexm(osym3,"DECREASED RESPO") ///
         |regexm(osym4,"DECREASED RESPO")|regexm(osym5,"DECREASED RESPO")|regexm(osym6,"DECREASED RESPO")) /// 
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//11

**************
** HEADACHE **
**************
count if (regexm(osym1,"HEADACHE")|regexm(osym2,"HEADACHE")|regexm(osym3,"HEADACHE") ///
		 |regexm(osym4,"HEADACHE")|regexm(osym5,"HEADACHE")|regexm(osym6,"HEADACHE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//11

**************
** NUMBNESS **
**************
count if (regexm(osym1,"NUMBNESS")|regexm(osym2,"NUMBNESS")|regexm(osym3,"NUMBNESS") ///
         |regexm(osym4,"NUMBNESS")|regexm(osym5,"NUMBNESS")|regexm(osym6,"NUMBNESS")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 
//0

**************
** WEAKNESS **
************** 
count if (regexm(osym1,"WEAK")|regexm(osym2,"WEAK")|regexm(osym3,"WEAK") ///
		 |regexm(osym4,"WEAK")|regexm(osym5,"WEAK")|regexm(osym6,"WEAK")) ///
           & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//16


************************
** DECREASED APPETITE **
************************
count if (regexm(osym1,"DECR APPETITE")|regexm(osym2,"DECR APPETITE")|regexm(osym3,"DECR APPETITE") ///
		 |regexm(osym4,"DECR APPETITE")|regexm(osym5,"DECR APPETITE")|regexm(osym6,"DECR APPETITE") ///
		 |regexm(osym1,"DECREASED APPETITE")|regexm(osym2,"DECREASED APPETITE")|regexm(osym3,"DECREASED APPETITE") ///
		 |regexm(osym4,"DECREASED APPETITE")|regexm(osym5,"DECREASED APPETITE")|regexm(osym6,"DECREASED APPETITE") ///
		 |regexm(osym1,"REDUCED APPETITE")|regexm(osym2,"REDUCED APPETITE")|regexm(osym3,"REDUCED APPETITE") ///
		 |regexm(osym4,"REDUCED APPETITE")|regexm(osym5,"REDUCED APPETITE")|regexm(osym6,"REDUCED APPETITE")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 
//6

********************
** ABDOMINAL PAIN **
********************
count if (regexm(osym1,"ABDOMINAL PAIN")|regexm(osym2,"ABDOMINAL PAIN")|regexm(osym3,"ABDOMINAL PAIN") ///
		 |regexm(osym4,"ABDOMINAL PAIN")|regexm(osym5,"ABDOMINAL PAIN")|regexm(osym6,"ABDOMINAL PAIN") ///
		 |regexm(osym1,"ABDOMINALPAIN")|regexm(osym2,"ABDOMINALPAIN")|regexm(osym3,"ABDOMINALPAIN") ///
		 |regexm(osym4,"ABDOMINALPAIN")|regexm(osym5,"ABDOMINALPAIN")|regexm(osym6,"ABDOMINALPAIN")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999
//7

************************
** BURPING / BELCHING **
************************
count if (regexm(osym1,"BURPING")|regexm(osym2,"BURPING")|regexm(osym3,"BURPING") ///
		 |regexm(osym4,"BURPING")|regexm(osym5,"BURPING")|regexm(osym6,"BURPING") ///
         |regexm(osym1,"BELCHING")|regexm(osym2,"BELCHING")|regexm(osym3,"BELCHING") ///
         |regexm(osym4,"BELCHING")|regexm(osym5,"BELCHING")|regexm(osym6,"BELCHING")) ///
         & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 
//1

**********************
** UNRESPONSIVENESS **
**********************
count if (regexm(osym1,"UNRESPONSIVE")|regexm(osym2,"UNRESPONSIVE")|regexm(osym3,"UNRESPONSIVE") ///
		 |regexm(osym4,"UNRESPONSIVE")|regexm(osym5,"UNRESPONSIVE")|regexm(osym6,"UNRESPONSIVE")) ///
         & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999 
//8
** most common are nausea/bad feelings, weakness, cough and headache

** Check totals for each symptom
tab hsym1 if sd_absstatus==1 ,m //yes=133 chest pain
tab hsym2 if sd_absstatus==1 ,m //yes=85 sob
tab hsym3 if sd_absstatus==1 ,m //yes=61 vomit
tab hsym4 if sd_absstatus==1 ,m //yes=36 dizzy
tab hsym5 if sd_absstatus==1 ,m //yes=20 loc
tab hsym6 if sd_absstatus==1 ,m //yes=32 palp
tab hsym7 if sd_absstatus==1 ,m //yes=72 sweat
 
** Create variable with total number of symptoms
foreach var in hsym1 hsym2 hsym3 hsym4 hsym5 hsym6 hsym7 {
	recode `var' 2 99 99999 = 0	
		}

egen symtot = rsum(hsym1 hsym2 hsym3 hsym4 hsym5 hsym6 hsym7)

** JC update: Save these results as a dataset for reporting Table 1.3
preserve
tab symtot if sd_absstatus==1
count if sd_absstatus==1 //185
tab sex if sd_absstatus==1
/*
  Incidence |
  Data: Sex |      Freq.     Percent        Cum.
------------+-----------------------------------
     Female |         83       44.86       44.86
       Male |        102       55.14      100.00
------------+-----------------------------------
      Total |        185      100.00
*/

** Create variable to capture the highest count of the other symptom variable
gen hsym_oth=1 if ((regexm(osym1,"NAUSEA")|regexm(osym2,"NAUSEA")|regexm(osym3,"NAUSEA") ///  
		 |regexm(osym4,"NAUSEA")|regexm(osym5,"NAUSEA")|regexm(osym6,"NAUSEA") ///
         |regexm(osym1,"MALAISE")|regexm(osym2,"MALAISE")|regexm(osym3,"MALAISE") ///
		 |regexm(osym4,"MALAISE")|regexm(osym5,"MALAISE")|regexm(osym6,"MALAISE") ///
		 |regexm(osym1,"BAD FEEL")|regexm(osym2,"BAD FEEL")|regexm(osym3,"BAD FEEL") ///
		 |regexm(osym4,"BAD FEEL")|regexm(osym5,"BAD FEEL")|regexm(osym6,"BAD FEEL") ///
		 |regexm(osym1,"UNWELL")|regexm(osym2,"UNWELL")|regexm(osym3,"UNWELL") ///
		 |regexm(osym4,"UNWELL")|regexm(osym5,"UNWELL")|regexm(osym6,"UNWELL") ///
		 |regexm(osym1,"FEELING BAD")|regexm(osym2,"FEELING BAD")|regexm(osym3,"FEELING BAD") ///
		 |regexm(osym4,"FEELING BAD")|regexm(osym5,"FEELING BAD")|regexm(osym6,"FEELING BAD") ///
		 |regexm(osym1,"NOT FEELING WELL")|regexm(osym2,"NOT FEELING WELL")|regexm(osym3,"NOT FEELING WELL")) ///
		 |regexm(osym4,"NOT FEELING WELL")|regexm(osym5,"NOT FEELING WELL")|regexm(osym6,"NOT FEELING WELL")) ///
		 & sd_absstatus==1 & osym!=. & osym!=7 & osym!=99 & osym!=99999


save "`datapath'\version03\2-working\symptoms_heart" ,replace

contract sex if sd_absstatus==1 & hsym1==1
gen hsym_ar=1
save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym2==1
gen hsym_ar=2

append using "`datapath'\version03\2-working\symptoms_heart_ar"

save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym7==1
gen hsym_ar=3

append using "`datapath'\version03\2-working\symptoms_heart_ar"

save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym3==1
gen hsym_ar=4

append using "`datapath'\version03\2-working\symptoms_heart_ar"

save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym_oth==1
gen hsym_ar=5

append using "`datapath'\version03\2-working\symptoms_heart_ar"

save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym4==1
gen hsym_ar=6

append using "`datapath'\version03\2-working\symptoms_heart_ar"

save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym6==1
gen hsym_ar=7

append using "`datapath'\version03\2-working\symptoms_heart_ar"

save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

use "`datapath'\version03\2-working\symptoms_heart" ,clear
contract sex if sd_absstatus==1 & hsym5==1
gen hsym_ar=8

append using "`datapath'\version03\2-working\symptoms_heart_ar"


save "`datapath'\version03\2-working\symptoms_heart_ar" ,replace

clear

** Create variables for totals for all patients (combined and separately for sex) with info for 2020
use "`datapath'\version03\2-working\symptoms_heart" ,clear
egen totsympts=count(sd_etype) if sd_absstatus==1
egen totsympts_f=count(sd_etype) if sd_absstatus==1 & sex==1
egen totsympts_m=count(sd_etype) if sd_absstatus==1 & sex==2
gen hsym_ar=9
collapse totsympts totsympts_f totsympts_m

append using "`datapath'\version03\2-working\symptoms_heart_ar"

replace hsym_ar=9 if hsym_ar==.
sort sex hsym_ar
gen id=_n
order id hsym_ar sex _freq totsympts
fillmissing totsympts totsympts_f totsympts_m
rename _freq number


label define hsym_lab 1 "Chest pain" 2 "Shortness of breath" 3 "Sweating" 4 "Sudden vomiting" 5 "Nausea/malaise" 6 "Sudden dizziness/vertigo" 7 "Palpitations" 8 "Loss of consciousness" 9 "Total Patients" ,modify
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
erase "`datapath'\version03\2-working\symptoms_heart_ar.dta"
save "`datapath'\version03\2-working\symptoms_heart" ,replace
restore
