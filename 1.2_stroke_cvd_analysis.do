cls
** -------------------------  HEADER ------------------------------ **
**  DO-FILE METADATA
    //  algorithm name          1.2_stroke_cvd_analysis.do
    //  project:                BNR Stroke
    //  analysts:               Ashley HENRY and Jacqueline CAMPBELL
    //  date first created:     23-Feb-2022
    //  date last modified:     05-Apr-2022
	//  analysis:               Stroke 2020 dataset for Annual Report
    //  algorithm task          Performing Stroke 2020 Data Analysis
    //  status:                 Pending
    //  objective:              To analyse data to calculate summary statistics and Crude Incidence Rates by year
    //  methods:1:              Run analysis on cleaned 2009-2020 BNR-S data.
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
    local logpath X:/The University of the West Indies/DataGroup - repo_data/data_p116

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\1.2_stroke_analysis.smcl", replace
** -------------------------  HEADER ------------------------------ 
     ******************************************************
 *              Stroke Category
 *              Symptoms and Risk Factors 
************************************************************************
** Load the dataset  

use "`datapath'\version02\3-output\stroke_2009-2020_v9_names_Stata_v16_clean" ,clear

count
** 7649 as of 24-Feb-2022

********   STROKE DATE OF CT    *********
tab dct year


****************************************************
** Table 2.2:STROKE CATEGORY
****************************************************
by year, sort: tab stype sex, column
bysort year: tab abstracted sex  //denominator
**Male Ischeamic Stroke:
dis 229/275
**Female Ischeamic Stroke:
dis 244/288

**********
** 2018 **
**********
preserve
contract stype sex if year==2018 & abstracted==1
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

drop if stype>2|stype==.
gen id=_n
order id

reshape wide stype number tot_f tot_m percent_isch_f percent_isch_m percent_intra_f percent_intra_m, i(id)  j(sex)
rename stype1 Stroke_Category

label var Stroke_Category "Stroke Category"
label define Stroke_Category_lab 1 "Ischaemic Stroke" 2 "Intracerebral Haemorrhage" , modify
label values Stroke_Category Stroke_Category_lab

drop stype2 *_f2 *_m1
fillmissing tot_*
replace number2=number2[_n+1] if number2==.
replace percent_isch_m2=percent_isch_m2[_n+1] if percent_isch_m2==.
replace percent_intra_m2=percent_intra_m2[_n+1] if percent_intra_m2==.
drop if id==2|id==4
gen total_abs_2018=tot_f+tot_m if Stroke_Category==1
drop tot_*
rename number1 num_f_2018
rename number2 num_m_2018
rename percent_isch_f1 percent_f_2018
rename percent_isch_m2 percent_m_2018
replace percent_f_2018=percent_intra_f1 if Stroke_Category==2
replace percent_m_2018=percent_intra_m2 if Stroke_Category==2
drop percent_intra*

save "`datapath'\version02\2-working\2018_subtypes_stroke" ,replace
restore

**********
** 2019 **
**********
preserve
contract stype sex if year==2019 & abstracted==1
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

drop if stype>2|stype==.
gen id=_n
order id

reshape wide stype number tot_f tot_m percent_isch_f percent_isch_m percent_intra_f percent_intra_m, i(id)  j(sex)
rename stype1 Stroke_Category

label var Stroke_Category "Stroke Category"
label define Stroke_Category_lab 1 "Ischaemic Stroke" 2 "Intracerebral Haemorrhage" , modify
label values Stroke_Category Stroke_Category_lab

drop stype2 *_f2 *_m1
fillmissing tot_*
replace number2=number2[_n+1] if number2==.
replace percent_isch_m2=percent_isch_m2[_n+1] if percent_isch_m2==.
replace percent_intra_m2=percent_intra_m2[_n+1] if percent_intra_m2==.
drop if id==2|id==4
gen total_abs_2019=tot_f+tot_m if Stroke_Category==1
drop tot_*
rename number1 num_f_2019
rename number2 num_m_2019
rename percent_isch_f1 percent_f_2019
rename percent_isch_m2 percent_m_2019
replace percent_f_2019=percent_intra_f1 if Stroke_Category==2
replace percent_m_2019=percent_intra_m2 if Stroke_Category==2
drop percent_intra*

save "`datapath'\version02\2-working\2019_subtypes_stroke" ,replace
restore


**********
** 2020 **
**********
preserve
contract stype sex if year==2020 & abstracted==1
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

drop if stype>2|stype==.
gen id=_n
order id

reshape wide stype number tot_f tot_m percent_isch_f percent_isch_m percent_intra_f percent_intra_m, i(id)  j(sex)
rename stype1 Stroke_Category

label var Stroke_Category "Stroke Category"
label define Stroke_Category_lab 1 "Ischaemic Stroke" 2 "Intracerebral Haemorrhage" , modify
label values Stroke_Category Stroke_Category_lab

drop stype2 *_f2 *_m1
fillmissing tot_*
replace number2=number2[_n+1] if number2==.
replace percent_isch_m2=percent_isch_m2[_n+1] if percent_isch_m2==.
replace percent_intra_m2=percent_intra_m2[_n+1] if percent_intra_m2==.
drop if id==2|id==4
gen total_abs_2020=tot_f+tot_m if Stroke_Category==1
drop tot_*
rename number1 num_f_2020
rename number2 num_m_2020
rename percent_isch_f1 percent_f_2020
rename percent_isch_m2 percent_m_2020
replace percent_f_2020=percent_intra_f1 if Stroke_Category==2
replace percent_m_2020=percent_intra_m2 if Stroke_Category==2
drop percent_intra*


merge 1:1 id using "`datapath'\version02\2-working\2018_subtypes_stroke"
drop _merge
merge 1:1 id using "`datapath'\version02\2-working\2019_subtypes_stroke"
drop _merge id

order Stroke_Category num_f_2018 percent_f_2018 num_m_2018 percent_m_2018 total_abs_2018 num_f_2019 percent_f_2019 num_m_2019 percent_m_2019 total_abs_2019 num_f_2020 percent_f_2020 num_m_2020 percent_m_2020 total_abs_2020

erase "`datapath'\version02\2-working\2018_subtypes_stroke.dta"
erase "`datapath'\version02\2-working\2019_subtypes_stroke.dta"
save "`datapath'\version02\2-working\subtypes_stroke" ,replace
restore
stop

******************************************
** TABLE 2.3: STROKE ssymS & SIGNS 2020 **
******************************************
tab symp_slur if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_coma if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_face if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_difswal if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_slur sex if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_coma sex if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_face sex if abstracted==1 & hosp==1 &  year==2020, miss

tab symp_difswal sex if abstracted==1 & hosp==1 &  year==2020, miss

tab ossym if abstracted==1 & hosp==1 &  year==2020, miss

tab sign_discon if abstracted==1 & hosp==1 &  year==2020, miss  

tab sign_weak if abstracted==1 & hosp==1 &  year==2020, miss  

tab sign_nospeak if abstracted==1 & hosp==1 &   year==2020, miss

** Count of SYMTOMS and SIGNS (CORE data)
** Number with none, 1, >1
foreach var in symp_slur symp_coma symp_face symp_difswal sign_discon sign_weak sign_nospeak {
	recode `var' 2 99 = 0	
	}
egen cssym = rsum(symp_slur symp_coma symp_face symp_difswal sign_discon sign_weak)
egen csign = rsum(sign_discon sign_weak sign_nospeak)
label var cssym "Number of ssyms"
label var csign "Number of signs"

tab1 cssym csign if year==2020 ,m


tab cssym if abstracted==1 & hosp==1 &  cssym!=0 & year==2020

tab cssym if abstracted==1 & hosp==1 &   year==2020

tab cssym sex if abstracted==1 & hosp==1 &   year==2020 
********************************** OTHER STROKE SYMPTOMS ************************************
** tab1 ossym*
tab1 ossym if abstracted!=2 & year==2020, miss //561/700
list hosp ossym1 ossym2 eligible if ossym==. & abstracted!=2 & year==2020 
// confirmed incomplete case.
sort ossym1
replace ossym1 = upper(rtrim(ltrim(itrim(ossym1))))
replace ossym2 = upper(rtrim(ltrim(itrim(ossym2))))
replace ossym3 = upper(rtrim(ltrim(itrim(ossym3))))
list ossym1 ossym2 ossym3 if abstracted!=2 &( ossym1!="" | ossym2!="" | ossym3!="")


** trying to tabulate the most common of these "other" hsyms going from the table
count if (regexm(ossym1, "VOMITING") | regexm(ossym2, "VOMITING") | regexm(ossym3, "VOMITING")) ///
                & abstracted!=2 & year==2020 & (ossym1!="" |ossym2!="" | ossym3!="") // 42
				
count if (regexm(ossym1, "VOMITING") | regexm(ossym2, "VOMITING") | regexm(ossym3, "VOMITING")) ///
                & sex==1 & abstracted!=2 & year==2020 & (ossym1!="" |ossym2!="" | ossym3!="") // 25
				
count if (regexm(ossym1, "VOMITING") | regexm(ossym2, "VOMITING") | regexm(ossym3, "VOMITING")) ///
                & sex==2 & abstracted!=2 & year==2020 & (ossym1!="" |ossym2!="" | ossym3!="") // 17
				
count if (regexm(ossym1, "FALL") | regexm(ossym2, "FALL") | regexm(ossym3, "FALL") | ///
               regexm(ossym1, "COLLAPSED") | regexm(ossym2, "COLLAPSED") | ///
			   regexm(ossym3, "COLLAPSED") | regexm(ossym1, "FELL") | ///
			   regexm(ossym2, "FELL")| regexm(ossym3, "FELL") ///
			   ) & abstracted!=2 & year==2020 & ///
			   ( ossym1!="" |  ossym2!=""| ossym3!="")	// 68	 
				
count if (regexm(ossym1, "FALL") | regexm(ossym2, "FALL") | regexm(ossym3, "FALL") | ///
               regexm(ossym1, "COLLAPSED") | regexm(ossym2, "COLLAPSED") | ///
			   regexm(ossym3, "COLLAPSED") | regexm(ossym1, "FELL") | ///
			   regexm(ossym2, "FELL")| regexm(ossym3, "FELL") ///
			   ) & sex==1 & abstracted!=2 & year==2020 & ///
			   ( ossym1!="" |  ossym2!=""| ossym3!="")	// 36
			   
count if (regexm(ossym1, "FALL") | regexm(ossym2, "FALL") | regexm(ossym3, "FALL") | ///
               regexm(ossym1, "COLLAPSED") | regexm(ossym2, "COLLAPSED") | ///
			   regexm(ossym3, "COLLAPSED") | regexm(ossym1, "FELL") | ///
			   regexm(ossym2, "FELL")| regexm(ossym3, "FELL") ///
			   ) & sex==2 & abstracted!=2 & year==2020 & ///
			   ( ossym1!="" |  ossym2!=""| ossym3!="")	// 32	 

count if (regexm(ossym1, "SEIZURE") |regexm(ossym2, "SEIZURE") | regexm(ossym3, "SEIZURE")) ///
          & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 15

count if (regexm(ossym1, "FEELING UNWELL") |regexm(ossym2, "FEELING UNWELL") | regexm(ossym3, "FEELING UNWELL")) ///
          & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 10
		  
count if (regexm(ossym1, "INCONTINENCE OF URINE") | regexm(ossym2, "INCONTINENCE OF URINE") | ///
         regexm(ossym3, "INCONTINENCE OF URINE")| regexm(ossym1, "URINARY INCONTINENCE") |  ///
			   regexm(ossym2, "URINARY INCONTINENCE") | regexm(ossym3, "URINARY INCONTINENCE") ///
			   ) & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 13
			   
count if (regexm(ossym1, "HEADACHE") | regexm(ossym2, "HEADACHE") | ///
         regexm(ossym3, "HEADACHE")) & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ///
		 ossym3!="") // 103
tab sex if year==2020
count if (regexm(ossym1, "HEADACHE") | regexm(ossym2, "HEADACHE") | ///
         regexm(ossym3, "HEADACHE")) & abstracted!=2 & year==2020 & sex==1 ///
		 & ( ossym1!="" |  ossym2!=""| ///
		 ossym3!="") // 59
		 
count if (regexm(ossym1, "HEADACHE") | regexm(ossym2, "HEADACHE") | ///
         regexm(ossym3, "HEADACHE")) & abstracted!=2 & year==2020 & sex==2 ///
		 & ( ossym1!="" |  ossym2!=""| ///
		 ossym3!="") // 44
		 
count if (regexm(ossym1, "NUMBNESS") | regexm(ossym1, "NUMBNESS") | ///
          regexm(ossym1, "NUMBNESS")) & abstracted!=2 & year==2020 & ( ossym1!="" | ossym2!=""| ///
		  ossym3!="") // 4
		  
count if (regexm(ossym1, "WEAK") | regexm(ossym2, "WEAK") | regexm(ossym3, "WEAK")) ///
           & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 27
		   
count if (regexm(ossym1, "UNABLE TO WALK") | regexm(ossym2, "UNABLE TO WALK") | ///
         regexm(ossym3, "UNABLE TO WALK") | regexm(ossym1, "UNABLE TO WEIGHT BEAR") | ///
		 regexm(ossym2, "UNABLE TO WEIGHT BEAR") | regexm(ossym3, "UNABLE TO WEIGHT BEAR") ///
		 | regexm(ossym1, "UNSTEADY GAIT") | regexm(ossym2, "UNSTEADY GAIT") | ///
		 regexm(ossym3, "UNSTEADY GAIT") | regexm(ossym1, "DIFFICULTY WALKING") | regexm(ossym2, "DIFFICULTY WALKING") | ///
		 regexm(ossym3, "DIFFICULTY WALKING")) & abstracted!=2 & year==2020 & ( ossym1!="" | ossym2!=""| ///
		  ossym3!="") //54
		  
count if (regexm(ossym1, "UNABLE TO WALK") | regexm(ossym2, "UNABLE TO WALK") | ///
         regexm(ossym3, "UNABLE TO WALK") | regexm(ossym1, "UNABLE TO WEIGHT BEAR") | ///
		 regexm(ossym2, "UNABLE TO WEIGHT BEAR") | regexm(ossym3, "UNABLE TO WEIGHT BEAR") ///
		 | regexm(ossym1, "UNSTEADY GAIT") | regexm(ossym2, "UNSTEADY GAIT") | ///
		 regexm(ossym3, "UNSTEADY GAIT") | regexm(ossym1, "DIFFICULTY WALKING") | regexm(ossym2, "DIFFICULTY WALKING") | ///
		 regexm(ossym3, "DIFFICULTY WALKING")) & sex==1 & abstracted!=2 & year==2020 & ( ossym1!="" | ossym2!=""| ///
		  ossym3!="") //25
		  
count if (regexm(ossym1, "UNABLE TO WALK") | regexm(ossym2, "UNABLE TO WALK") | ///
         regexm(ossym3, "UNABLE TO WALK") | regexm(ossym1, "UNABLE TO WEIGHT BEAR") | ///
		 regexm(ossym2, "UNABLE TO WEIGHT BEAR") | regexm(ossym3, "UNABLE TO WEIGHT BEAR") ///
		 | regexm(ossym1, "UNSTEADY GAIT") | regexm(ossym2, "UNSTEADY GAIT") | ///
		 regexm(ossym3, "UNSTEADY GAIT") | regexm(ossym1, "DIFFICULTY WALKING") | regexm(ossym2, "DIFFICULTY WALKING") | ///
		 regexm(ossym3, "DIFFICULTY WALKING")) & sex==2 & abstracted!=2 & year==2020 & ( ossym1!="" | ossym2!=""| ///
		  ossym3!="") //29
		  
count if (regexm(ossym1, "DISORIENTED") | regexm(ossym2, "DISORIENTED") | ///
         regexm(ossym3, "DISORIENTED") |regexm(ossym1, "CONFUSION") | ///
		 regexm(ossym2, "CONFUSION") | regexm(ossym3, "CONFUSION")| ///
		 regexm(ossym1, "CONFUSED") | regexm(ossym2, "CONFUSED")| regexm(ossym3, "CONFUSED")) ///
		 & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 45
		 
count if (regexm(ossym1, "DISORIENTED") | regexm(ossym2, "DISORIENTED") | ///
         regexm(ossym3, "DISORIENTED") |regexm(ossym1, "CONFUSION") | ///
		 regexm(ossym2, "CONFUSION") | regexm(ossym3, "CONFUSION")| ///
		 regexm(ossym1, "CONFUSED") | regexm(ossym2, "CONFUSED")| regexm(ossym3, "CONFUSED")) ///
		 & sex==1 & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 19
		 		 
count if (regexm(ossym1, "DISORIENTED") | regexm(ossym2, "DISORIENTED") | ///
         regexm(ossym3, "DISORIENTED") |regexm(ossym1, "CONFUSION") | ///
		 regexm(ossym2, "CONFUSION") | regexm(ossym3, "CONFUSION")| ///
		 regexm(ossym1, "CONFUSED") | regexm(ossym2, "CONFUSED")| regexm(ossym3, "CONFUSED")) ///
		 & sex==2 & abstracted!=2 & year==2020 & ( ossym1!="" |  ossym2!=""| ossym3!="") // 26
		 
		 
		 
***********************************************
** Table 2.4   RISK FACTOR PREVALENCE
**********************************************

** 3.5a Most common RFs - first look at each in turn

** VASCULAR RISK FACTORS
** First we have to convert all these vasc RF variables to numerics from string!
** Easiest way is to give them new variable names and replace them with appropriate values
** SAW:"vrf" variables are numeric so not sure if code needs to be changed from 1 to "Y"; 
** cont'd: 2 to "N" & 99 to "U".

** AR to AH - use preserve and restore so that you get the right denominators
preserve
drop if abstracted!=1

sort ovrf1 ovrf2 ovrf3 ovrf4
replace ovrf1 = upper(rtrim(ltrim(itrim(ovrf1))))
replace ovrf2 = upper(rtrim(ltrim(itrim(ovrf2))))
replace ovrf3 = upper(rtrim(ltrim(itrim(ovrf3))))
replace ovrf4 = upper(rtrim(ltrim(itrim(ovrf4))))
list ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  abstracted!=2 & (ovrf1!="" | ovrf2!="" | ovrf3!="" | ovrf4 !="")



replace obese=1 if year==2020 & ((regexm(ovrf1, "OBESE")) | (regexm(ovrf1, "OBESITY")) | (regexm(ovrf1, "OBGSE")) | (regexm(ovrf1, "NBESE")))
replace obese=1 if year==2020 & ((regexm(ovrf2, "OBESE")) | (regexm(ovrf2, "OBESITY")) | (regexm(ovrf2, "OBGSE")) | (regexm(ovrf2, "NBESE")))
replace obese=1 if year==2020 & ((regexm(ovrf3, "OBESE")) | (regexm(ovrf3, "OBESITY")) | (regexm(ovrf3, "OBGSE")) | (regexm(ovrf3, "NBESE")))
replace obese=1 if year==2020 & ((regexm(ovrf4, "OBESE")) | (regexm(ovrf4, "OBESITY")) | (regexm(ovrf4, "OBGSE")) | (regexm(ovrf4, "NBESE")))
label values obese risk_lab
label var obese "Whether patient is obese"
count if obese==1
codebook obese
tab obese
**

** Also may need to recode/update "prior MI" as there may be some in the "other" section as well
list pami ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  ((regexm(ovrf1, "ACUTE MI")) | ///
	 (regexm(ovrf2, "ACUTE MI")) | (regexm(ovrf3, "ACUTE MI")) | (regexm(ovrf4, "ACUTE MI")))
** No need for re-coding

** Combining caardiac RFs: CVD + IHD + PVD
list ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  ((regexm(ovrf1, "IHD")) | (regexm(ovrf1, "CVD")) | (regexm(ovrf1, "PVD")) | (regexm(ovrf1, "CARDIOVASC"))  | (regexm(ovrf1, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf2, "IHD")) | (regexm(ovrf2, "CVD")) | (regexm(ovrf2, "PVD")) | (regexm(ovrf2, "CARDIOVASC"))  | (regexm(ovrf2, "PERIPHERAL VASC")) | /// 
	 (regexm(ovrf3, "IHD")) | (regexm(ovrf3, "CVD")) | (regexm(ovrf3, "PVD")) | (regexm(ovrf3, "CARDIOVASC"))  | (regexm(ovrf3, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf4, "IHD")) | (regexm(ovrf4, "CVD")) | (regexm(ovrf4, "PVD")) | (regexm(ovrf4, "CARDIOVASC"))  | (regexm(ovrf4, "PERIPHERAL VASC")))
**

gen car_all=1 if year==2020 &  ((regexm(ovrf1, "IHD")) | (regexm(ovrf1, "CVD")) | (regexm(ovrf1, "PVD")) | (regexm(ovrf1, "CARDIOVASC")) | (regexm(ovrf1, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf2, "IHD")) | (regexm(ovrf2, "CVD")) | (regexm(ovrf2, "PVD"))  | (regexm(ovrf2, "CARDIOVASC")) | (regexm(ovrf2, "PERIPHERAL VASC")) | /// 
	 (regexm(ovrf3, "IHD")) | (regexm(ovrf3, "CVD")) | (regexm(ovrf3, "PVD"))  | (regexm(ovrf3, "CARDIOVASC")) | (regexm(ovrf3, "PERIPHERAL VASC")) | ///
	 (regexm(ovrf4, "IHD")) | (regexm(ovrf4, "CVD")) | (regexm(ovrf4, "PVD"))  | (regexm(ovrf4, "CARDIOVASC")) | (regexm(ovrf4, "PERIPHERAL VASC")))
label values car_all risk_lab
label var car_all "Whether patient had prior or current IHD, CVD or PVD"
**  do a tab to be sure it worked...
tab car_all ,m //12

** For alcohol use
list ovrf1 ovrf2 ovrf3 ovrf4 if year==2020 &  ( (regexm(ovrf1, "ALCOHOL")) | (regexm(ovrf1, "DRINKER")) | (regexm(ovrf1, "ETOH")) | ///
	 (regexm(ovrf2, "ALCOHOL")) | (regexm(ovrf2, "DRINKER")) | (regexm(ovrf2, "ETOH")) | /// 
	 (regexm(ovrf3, "ALCOHOL")) | (regexm(ovrf3, "DRINKER")) | (regexm(ovrf3, "ETOH")) | ///
	 (regexm(ovrf4, "ALCOHOL")) | (regexm(ovrf4, "DRINKER")) | (regexm(ovrf4, "ETOH")))

replace alco=1 if year==2020 &  ( (regexm(ovrf1, "ALCOHOL")) | (regexm(ovrf1, "DRINKER")) | (regexm(ovrf1, "ETOH")) | ///
	 (regexm(ovrf2, "ALCOHOL")) | (regexm(ovrf2, "DRINKER")) | (regexm(ovrf2, "ETOH")) | /// 
	 (regexm(ovrf3, "ALCOHOL")) | (regexm(ovrf3, "DRINKER")) | (regexm(ovrf3, "ETOH")) | ///
	 (regexm(ovrf4, "ALCOHOL")) | (regexm(ovrf4, "DRINKER")) | (regexm(ovrf4, "ETOH")))
label values alco risk_lab
label var alco "Whether patient used alcohol"

tab pami if abstracted==1 & year==2020 ,m 
tab car_all if abstracted==1 & year==2020 ,m
tab alco if abstracted==1 & year==2020 ,m

** for denominator
count if (ovrf1!="" | ovrf2!="" | ovrf3!="" | ovrf4!="") & year==2020  & abstracted==1


*************************************************
** NO PRIOR STROKE
** To avoid double-counting of prior stroke:
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CVA") | regexm(ovrf2, "CVA") | regexm(ovrf3, "CVA") | /// 
											 regexm(ovrf4, "CVA"))
**  No changes required
**replace np=0 if ovrf1=="CVA" & np==2

list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "STROKE") | regexm(ovrf2, "STROKE") | regexm(ovrf3, "STROKE") | /// 
											 regexm(ovrf4, "STROKE"))

** No changes required
** replace np=0 if vrf_11=="STROKE" & np==2
											 							 
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CEREBRO") | regexm(ovrf2, "CEREBRO") | regexm(ovrf3, "CEREBRO") | /// 
											 regexm(ovrf4, "CEREBRO"))
** No changes required											 
											 
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CEREBRAL") | regexm(ovrf2, "CEREBRAL") | regexm(ovrf3, "CEREBRAL") | /// 
											 regexm(ovrf4, "CEREBRAL"))
** No changes required												 
											 
list ovrf1 ovrf2 ovrf3 ovrf4 np if year==2020 & (regexm(ovrf1, "CRANIAL") | regexm(ovrf2, "CRANIAL") | regexm(ovrf3, "CRANIAL") | /// 
											 regexm(ovrf4, "CRANIAL"))
** No changes required											 

codebook np
codebook fes
tab fes if year==2020 ,m
tab np if year==2020,m


gen npnew=2 if np==1
replace npnew=0 if np==2
replace npnew=1 if np==0
label define newnp_lab 1"had prior stroke" 2"first ever stroke"
label values npnew newnp_lab
codebook np

tab af if year==2020 ,m

local i=1
foreach var in npnew af hcl smoker diab htn  drugs tia ccf dvt scd pami car_all alco {
	gen risk`i' = 1 if `var'==1 & year==2020
	replace risk`i' = 0 if `var'==2 & year==2020
	label define risk`i'_lab 1 "yes" 0 "no", modify
	label values risk`i' risk`i'_lab	
	local i = `i'+1
	}

label var risk1 "prior stroke"
label var risk2 "AF"
label var risk3 "high cholesterol"
label var risk4 "smoker"
label var risk5 "diabetes"
label var risk6 "hypertension"
label var risk7 "Drug abuse/misuse"
label var risk8 "TIA"
label var risk9 "CCF"
label var risk10 "DVT"
label var risk11 "SCD"
label var risk12 "prior acute MI"
label var risk13 "prior IHD, CVD or PVD"
label var risk14 "alcohol use"

local i=1
foreach var in risk1 risk2 risk3 risk4 risk5 risk6 risk7 risk8 risk9 risk10 risk11 risk12 risk13 risk14{
	tab risk`i' if abstracted==1 & year==2020 ,m
	local i = `i'+1
	}


	egen crisk1 = rsum(risk1 risk2 risk3 risk4 risk5 risk6 risk7 risk8 risk9 risk10 risk11 risk12 risk13 risk14)
label var crisk1 "Number of standard risk factors"

** denominators
*AF - 16+10=26
* high cholesterol - 20+51= 92
* smoker - 395+37= 432
* diabetes - 68 + 228 = 296
* hypertension - 410 + 46= 456
* drug abuse/ misuse = 25 + 108 = 133
* CCF - 16+10 =26
* DVT - none 
** CCF or DVT = 26
* SCD = none
* prior IHD, CVD or PVD 
* PRIOR AMI - 21 +295= 316
* prior IHD, CVD or PVD,PRIOR AMI = 12
* Alcohol use = 126 + 356 = 482
* Prior stroke/ TIA = 117+26  = 143 
** Prior Stroke Only - 264+117 = 381

** acute MI and IHD/CVD/PVD combined
tab risk12 risk13 if year==2020 ,m

***ccf/dvt
tab risk9 risk10 if year==2020, m

** number of prior stroke OR TIAs combined
tab tia np if abstracted!=2 & year==2020 ,m

** cumulative number of RFs
tab crisk1 if abstracted==1 & year==2020 ,m

** Next, Family History risk factors
** for denominator info.
tab famstroke if abstracted==1 & year==2020 ,miss
**34 yes

local i=15
foreach var in famstroke pami {
	gen risk`i' = 1 if `var'==1
	replace risk`i' = 0 if `var'==2
	replace risk`i' = 0 if `var'==3    
	local i = `i'+1
	}
	
egen crisk2 = rsum(risk15 risk16) if year==2020
label var crisk2 "Number of family history risk factors"
tab crisk2
drop risk*

** Family history in detail
list mumstroke dadstroke sibstroke if mumstroke!=. & dadstroke!=. & sibstroke!=.
count if (mumstroke==1 | dadstroke==1 | sibstroke==1) & year==2020
* 25
count if famstroke!=. & (mumstroke!=. | dadstroke!=. | sibstroke!=.) & year==2020
** 34

tab famstroke if abstracted==1 & year==2020, miss
** 34

** Now count all risk factors together
gen risk = crisk1 + crisk2 if year==2020
label var risk "Number of all risk factors combined"
tab1 risk if year==2020 ,miss
tab1 risk if abstracted==1 & year==2020 ,miss
restore

** denominator 622-31=591
