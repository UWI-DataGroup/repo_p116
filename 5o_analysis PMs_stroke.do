** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5o_analysis PMs_stroke.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      20-MAR-2023
    // 	date last modified      20-MAR-2023
    //  algorithm task          Performing analysis on 2021 stroke data for 2021 CVD Annual Report
    //  status                  Completed
    //  objective               To analyse data relating to performance measures
	//							(1) Aspirin use within first 24 hours
	//							(2) Proportion of STEMI receiving reperfusion vs fibrinolysis
	//							(3) Median time to reperfusion for STEMI
	//							(4) Proportion of patients receiving ECHO before discharge
	//							(5) Aspirin prescribed at discharge
	//							(6) Statins prescribed at discharge
    //  methods                 Reviewing and categorizing variables needed for the above rates and stats
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
    log using "`logpath'\5o_analysis PMs_stroke.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified STROKE 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke", clear

count //691

*******************************************************
** PM1: Porportion of patients receiving reperfusion **
*******************************************************

** Save these results as a dataset for reporting PM1
preserve
drop if sd_absstatus!=1 //191 deleted
tab reperf if stype == 1 ,m
tab reperf sex if stype == 1, m
 
save "`datapath'\version03\2-working\pm1_stroke" ,replace
restore 

*******************************************************
** PM2: Porportion of patients with ischaemic stroke **
**		receiving antithrombotic therapy while		 **
**		in hospital									 **
*******************************************************
** PM2 Antithrombotics warfarin, aspirin, plavix  (aspirin/warfarin/clopidogrel)
preserve
drop if sd_absstatus!=1 //191 deleted
** Create variable to group warfarin, aspirin and plavix into one variable
tab asp___1 ,m //291
tab warf___1 ,m //0
tab pla___1 ,m //30

tab warf___2 ,m //11 on warfarin chronically
tab warf___3 ,m //0 contraindications for warfarin

tab stype ,m
/*
  What type of stroke was |
               diagnosed? |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
         Ischaemic Stroke |        419       83.80       83.80
Intracerebral Haemorrhage |         60       12.00       95.80
 Subarachnoid Haemorrhage |         17        3.40       99.20
        Unclassified Type |          4        0.80      100.00
--------------------------+-----------------------------------
                    Total |        500      100.00
*/

tab asp___1 if stype==1 ,m //289
tab warf___1 if stype==1 ,m //0
tab pla___1 if stype==1 ,m //29

tab warf___2 if stype==1 ,m //7 on warfarin chronically
tab warf___3 if stype==1 ,m //0 contraindications for warfarin


gen antithrom=1 if asp___1==1|warf___1==1|pla___1==1
replace antithrom=2 if (asp___1==0|asp___1==99) & (warf___1==0|warf___1==99) & (pla___1==0|pla___1==99)

label define antithrom_lab 1 "Yes" 2 "No" ,modify
label values antithrom antithrom_lab
label var antithrom "Stata Derived: Did patients receive anthrombotics while in hospital?"


tab antithrom ,m //295 yes; 205 no
tab antithrom if stype==1 ,m //292 yes; 127 no

by sd_eyear, sort: tab antithrom sex if stype == 1, col chi
/*
     Stata |
  Derived: |
       Did |
  patients |
   receive |
anthrombot |
       ics |
(aspirin/w |
arfarin/cl |  Incidence Data: Sex
opidogrel? |    Female       Male |     Total
-----------+----------------------+----------
       Yes |       139        153 |       292 
           |     68.47      70.83 |     69.69 
-----------+----------------------+----------
        No |        64         63 |       127 
           |     31.53      29.17 |     30.31 
-----------+----------------------+----------
     Total |       203        216 |       419 
           |    100.00     100.00 |    100.00 

          Pearson chi2(1) =   0.2760   Pr = 0.599
*/

** Save these results as a dataset for reporting PM2 in Table 2.6
tab antithrom sex if stype==1 ,col
contract antithrom sex if stype==1
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithrom==1
gen percent_m=number/total_m*100 if sex==2 & antithrom==1
drop if antithrom!=1
drop antithrom total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2021
order year female percent_female male percent_male

replace percent_female=round(percent_female,1.0)
replace percent_male=round(percent_male,1.0)
sort year
save "`datapath'\version03\2-working\pm2_stroke" ,replace
clear
restore



***********************************************************
** PM3+PM4: Porportion of patients with ischaemic stroke **
**			prescribed antithrombotic therapy			 **
**			at discharge								 **
***********************************************************
** PM3+PM4 Antithrombotics warfarin, aspirin, plavix (aspirin/warfarin/clopidogrel)
preserve
drop if sd_absstatus!=1 //191 deleted
** Create variable to group warfarin, aspirin and plavix into one variable
tab aspdis ,m //232
tab warfdis ,m //10
tab pladis ,m //25

tab stype ,m
/*
  What type of stroke was |
               diagnosed? |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
         Ischaemic Stroke |        419       83.80       83.80
Intracerebral Haemorrhage |         60       12.00       95.80
 Subarachnoid Haemorrhage |         17        3.40       99.20
        Unclassified Type |          4        0.80      100.00
--------------------------+-----------------------------------
                    Total |        500      100.00
*/

tab aspdis if stype==1 ,m //230
tab warfdis if stype==1 ,m //10
tab pladis if stype==1 ,m //25

gen antithromdis=1 if aspdis==1|warfdis==1|pladis==1
replace antithromdis=2 if aspdis==99 & warfdis==99 & pladis==99

label define antithromdis_lab 1 "Yes" 2 "No" ,modify
label values antithromdis antithromdis_lab
label var antithromdis "Stata Derived: Did patients receive anthrombotics at discharge?"


tab antithromdis ,m //246 yes; 103 no
tab antithromdis if stype==1 ,m //244 yes; 64 no


by sd_eyear, sort: tab antithromdis sex if vstatus == 1 & stype == 1, col
/*
     Stata |
  Derived: |
       Did |
  patients |
   receive |
anthrombot |
    ics at |  Incidence Data: Sex
discharge? |    Female       Male |     Total
-----------+----------------------+----------
       Yes |       111        133 |       244 
           |     76.55      81.60 |     79.22 
-----------+----------------------+----------
        No |        34         30 |        64 
           |     23.45      18.40 |     20.78 
-----------+----------------------+----------
     Total |       145        163 |       308 
           |    100.00     100.00 |    100.00
*/
 

** Save these results as a dataset for reporting PM3 + PM4 (Table 2.7)
tab antithromdis sex if vstatus == 1 & stype==1 ,col
contract antithromdis sex if vstatus == 1 & stype==1
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & antithromdis==1
gen percent_m=number/total_m*100 if sex==2 & antithromdis==1
drop if antithromdis!=1
drop antithromdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2021
order year female percent_female male percent_male

replace percent_female=round(percent_female,1.0)
replace percent_male=round(percent_male,1.0)
sort year

save "`datapath'\version03\2-working\pm3_stroke" ,replace
restore


*******************************************************
** PM4: Porportion of patients with ischaemic stroke **
**		prescribed Statins at discharge				 **
*******************************************************
** PM4: Statin at discharge 
** Save these results as a dataset for reporting PM4 in Table 2.7
preserve
drop if sd_absstatus!=1 //191 deleted
by sd_eyear, sort: tab statdis sex if vstatus == 1 & stype == 1, col
/*
      Statin |
  prescribed |  Incidence Data: Sex
at discharge |    Female       Male |     Total
-------------+----------------------+----------
at discharge |       108        126 |       234 
             |     74.48      77.30 |     75.97 
-------------+----------------------+----------
          99 |        37         37 |        74 
             |     25.52      22.70 |     24.03 
-------------+----------------------+----------
       Total |       145        163 |       308 
             |    100.00     100.00 |    100.00
*/
tab statdis sex if vstatus == 1 & stype==1 ,col
contract statdis sex if vstatus == 1 & stype==1
rename _freq number
egen total_f=total(number) if sex==1
egen total_m=total(number) if sex==2
gen percent_f=number/total_f*100 if sex==1 & statdis==1
gen percent_m=number/total_m*100 if sex==2 & statdis==1
drop if statdis!=1
drop statdis total*
gen id=_n

reshape wide number percent* ,i(id) j(sex)

collapse number1 number2 percent_f1 percent_m2
rename number1 female
rename number2 male
rename percent_f1 percent_female
rename percent_m2 percent_male
gen year=2021
order year female percent_female male percent_male

replace percent_female=round(percent_female,1.0)
replace percent_male=round(percent_male,1.0)
sort year

save "`datapath'\version03\2-working\pm4_stroke" ,replace
restore


***********************************************************
** Additional Analyses: % CTs for those discharged alive **
***********************************************************
** Requested by SF via email on 20may2022

tab ct ,m
tab ct sd_eyear
tab vstatus ct
tab ct sd_eyear if vstatus==1
tab vstatus if sd_absstatus==1
tab vstatus if sd_absstatus==1
tab vstatus ct if sd_absstatus==1

** JC update: Save these results as a dataset for reporting Figure 1.4 
preserve
tab sd_eyear if ct==1 & vstatus==1 & sd_absstatus==1 ,m matcell(foo)
mat li foo
svmat foo
egen total_alive=total(vstatus) if vstatus==1 & sd_absstatus==1
fillmissing total_alive
drop if foo==.
keep foo total_alive

gen registry="stroke"
gen category=1
gen year=2021

rename foo ct

order registry category year ct total_alive
gen ct_percent=ct/total_alive*100
replace ct_percent=round(ct_percent,1.0)

label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

save "`datapath'\version03\2-working\addanalyses_ct" ,replace
restore


****************************************************
** Additional Analyses: % persons <70 with STROKE **
****************************************************
** Requested by SF via email on 20may2022
count if age<70 //289 all cases
count if age<70 & sd_absstatus==1 //247 cases abstracted by BNR
count if sd_eyear==2021 //691
count if sd_eyear==2021 & sd_absstatus==1 //500

preserve
egen totcases=count(sd_eyear) if sd_eyear==2021
egen totabs=count(sd_eyear) if sd_eyear==2021 & sd_absstatus==1
egen totagecases=count(sd_eyear) if age<70 & sd_eyear==2021
egen totageabs=count(sd_eyear) if age<70 & sd_eyear==2021 & sd_absstatus==1
fillmissing totcases totabs totagecases totageabs
gen id=_n
drop if id!=1

keep totcases totabs totagecases totageabs
gen totagecases_percent=totagecases/totcases*100
replace totagecases_percent=round(totagecases_percent,1.0)
gen totageabs_percent=totageabs/totabs*100
replace totageabs_percent=round(totageabs_percent,1.0)

gen registry="stroke"
gen category=2
gen year=2021

order registry category year totagecases totcases totagecases_percent totageabs totabs totageabs_percent

label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

append using "`datapath'\version03\2-working\addanalyses_age"
drop id

save "`datapath'\version03\2-working\addanalyses_age" ,replace
restore