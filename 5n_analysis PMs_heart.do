** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5n_analysis PMs_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-MAR-2023
    // 	date last modified      19-MAR-2023
    //  algorithm task          Performing analysis on 2021 heart data for 2021 CVD Annual Report
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
    log using "`logpath'\5n_analysis PMs_heart.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned de-identified HEART 2021 INCIDENCE dataset
use "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart", clear

count //467

****************************
** PM1: Aspirin in 24 hrs **
****************************
** Check if Aspirin was given acutely
tab asp___1 ,m //123 given aspirin
/*
    Aspirin |
(Acute use) |      Freq.     Percent        Cum.
------------+-----------------------------------
  Unchecked |         78       16.70       16.70
    Checked |        123       26.34       43.04
          . |        266       56.96      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

** Check if Aspirin was given acutely for cases that were fully abstracted
tab asp___1 sd_absstatus ,m //123 given aspirin
/*
   Aspirin |    Stata Derived: Abstraction
    (Acute |              Status
      use) | Full abst  Partial a  No abstra |     Total
-----------+---------------------------------+----------
 Unchecked |        62         16          0 |        78 
   Checked |       123          0          0 |       123 
         . |         0          0        266 |       266 
-----------+---------------------------------+----------
     Total |       185         16        266 |       467
*/

** Check if Aspirin was undocumented at time of abstraction
tab asp___99 ,m //48 had aspirin = no record of use
/*
Aspirin (No |
  record of |
       use) |      Freq.     Percent        Cum.
------------+-----------------------------------
  Unchecked |        153       32.76       32.76
    Checked |         48       10.28       43.04
          . |        266       56.96      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

** Check if Aspirin had contraindications at time of abstraction
tab asp___3 ,m //2 had contraindications with aspirin so they were not given aspirin
/*
    Aspirin |
(Contraindi |
   cations) |      Freq.     Percent        Cum.
------------+-----------------------------------
  Unchecked |        199       42.61       42.61
    Checked |          2        0.43       43.04
          . |        266       56.96      100.00
------------+-----------------------------------
      Total |        467      100.00
*/

** Check if Aspirin date is missing
tab aspd if asp___1==1 ,m //1 missing aspirin date

** Of the 123 given aspirin acutely, check which had event datetime, admission datetime and aspirin datetime documented
count if sd_eventdt!=. & asp___1==1 //85 had event date and time documented
count if sd_daetae!=. & asp___1==1 //117 had event date and time documented (A&E)
count if sd_dohtoh!=. & asp___1==1 //111 had event date and time documented (WARD)
count if sd_aspdt!=. & asp___1==1 //101 had event date and time documented

** Of the 123 given aspirin acutely, check which had both event date, admission date and aspirin date documented
count if edate!=. & asp___1==1 //123 had event date and time documented
count if dae!=. & asp___1==1 //123 had event date and time documented (A&E)
count if doh!=. & asp___1==1 //111 had event date and time documented (WARD)
count if aspd!=. & asp___1==1 //123 had event date and time documented

** Of the 123 given aspirin acutely, check which had aspirin datetime erroneously documented as before event datetime and admission datetime
count if sd_eventdt!=. & sd_aspdt!=. & asp___1==1 & sd_aspdt<sd_eventdt //0
count if sd_daetae!=. & sd_aspdt!=. & asp___1==1 & sd_aspdt<sd_daetae //6 - aspirin given after onset but before admission (all within 24hrs)
//list record_id fmc sd_fmcdatetime sd_daetae sd_eventdt sd_aspdt if sd_daetae!=. & sd_aspdt!=. & asp___1==1 & sd_aspdt<sd_daetae


** Using datetimes, check if aspirin given was truly within first 24 hrs of (1) arrival to hospital or (2) onset of symptoms
** Admission to Aspirin
preserve
drop if sd_daetae!=. & sd_aspdt!=. & asp___1==1 & sd_aspdt<sd_daetae //0 deleted
gen diff_adm=sd_aspdt-sd_daetae if sd_aspdt!=. & sd_daetae!=. & asp___1==1
gen adm2asp_hours = mod(diff_adm, msofhours(24))/msofhours(1)
replace adm2asp_hours=round(adm2asp_hours,1.0)
tab adm2asp_hours if asp___1==1 ,m //27 missing; 2 with 0 hours so given in minutes
restore

** Onset to Aspirin
preserve
drop if sd_eventdt!=. & sd_aspdt!=. & asp___1==1 & sd_aspdt<sd_eventdt //0 deleted
gen diff_onset=sd_aspdt-sd_eventdt if sd_aspdt!=. & sd_eventdt!=. & asp___1==1
gen onset2asp_hours = mod(diff_onset, msofhours(24))/msofhours(1)
replace onset2asp_hours=round(onset2asp_hours,1.0)
tab onset2asp_hours if asp___1==1 ,m //49 missing; 2 with 0 hours so given in minutes
restore

** First save the total number of patients given aspirin whose cases were fully abstracted
preserve
tab asp___1 sd_absstatus ,m
contract asp___1 if sd_absstatus==1
rename _freq number_total
drop if asp___1!=1
save "`datapath'\version03\2-working\pm1_asp24h_heart" ,replace
restore

** Using dates, check if aspirin given was truly within first 24 hrs of (1) arrival to hospital or (2) onset of symptoms
** Admission to Aspirin
preserve
drop if aspd!=. & dae!=. & aspd<dae //1 deleted
gen diff_adm=aspd-dae if aspd!=. & dae!=. & asp___1==1
gen adm2asp_days = floor(diff_adm/msofhours(24))
replace adm2asp_days=round(adm2asp_days,1.0)
tab adm2asp_days if asp___1==1 & sd_absstatus==1 ,m //121 had 0 days; 1 missing
label define adm2asp_days_lab 0 "less than 1 day" 1 "1 day" , modify
label values adm2asp_days adm2asp_days_lab

contract adm2asp_days if asp___1==1 & sd_absstatus==1
rename _freq adm2asp
drop if adm2asp_days==.
drop adm2asp_days

append using "`datapath'\version03\2-working\pm1_asp24h_heart"

order asp___1 adm2asp number_total
save "`datapath'\version03\2-working\pm1_asp24h_heart" ,replace
restore

** Onset to Aspirin
preserve
drop if aspd!=. & edate!=. & aspd<edate //0 deleted
gen diff_onset=aspd-edate if aspd!=. & edate!=. & asp___1==1
gen onset2asp_days = floor(diff_onset/msofhours(24))
replace onset2asp_days=round(onset2asp_days,1.0)
tab onset2asp_days if asp___1==1 ,m //122 had 0 days; 1 missing
label define onset2asp_days_lab 0 "less than 1 day" 1 "1 day" , modify
label values onset2asp_days onset2asp_days_lab

contract onset2asp_days if asp___1==1 & sd_absstatus==1
rename _freq onset2asp
drop if onset2asp_days==.
drop onset2asp_days

append using "`datapath'\version03\2-working\pm1_asp24h_heart"

fillmissing asp* onset* adm* num*
gen onset2asp_percent=onset2asp/number_total*100
replace onset2asp_percent=round(onset2asp_percent,1.0)

gen adm2asp_percent=adm2asp/number_total*100
replace adm2asp_percent=round(adm2asp_percent,1.0)

order asp___1 onset2asp* adm2asp* number_total
gen id=_n
drop if id>1
drop id

save "`datapath'\version03\2-working\pm1_asp24h_heart" ,replace
restore


*************************************
** PM2: STEMI pts with Reperfusion **
*************************************
** Instead of using ST elevation on the ECG as the determination if STEMI or otherwise as was done for 2020 annual report, I used the variable htype as this had been cleaned (see CVD DM Re-engineer OneNote bk for discussion on this under points #105 + #106 on the page '2021 cases for NS (CVD) to review')

** Check how many received reperfusion
tab reperf , m
tab reperf sex , m
tab reperf sex if sd_absstatus==1 , m //of the cases that were fully abstracted
/*
       Was |
reperfusio |
         n |
 treatment |  Incidence Data: Sex
attempted? |    Female       Male |     Total
-----------+----------------------+----------
       Yes |         7         22 |        29 
        No |         3          8 |        11 
        99 |        73         72 |       145 
-----------+----------------------+----------
     Total |        83        102 |       185
*/

tab reperf ecgste  ,m //28 STEMI according to ECG were reperfused
tab reperf htype  ,m //29 STEMI were reperfused

tab htype sd_absstatus ,m

** 29/29 reperfusions were STEMI

tab reperf sex if sd_absstatus==1 & htype==1 , m //STEMIs of the cases that were fully abstracted
/*
       Was |
reperfusio |
         n |
 treatment |  Incidence Data: Sex
attempted? |    Female       Male |     Total
-----------+----------------------+----------
       Yes |         7         22 |        29 
        No |         2          5 |         7 
        99 |        18         20 |        38 
-----------+----------------------+----------
     Total |        27         47 |        74
*/

by sex,sort:tab reperf htype if sd_absstatus==1 , m row col //by sex
/*
-> sex = Female

+-------------------+
| Key               |
|-------------------|
|     frequency     |
|  row percentage   |
| column percentage |
+-------------------+

       Was |
reperfusio |
         n |
 treatment |    What type of acute MI was diagnosed?
attempted? |     STEMI     NSTEMI  AMI (defi  Sudden ca |     Total
-----------+--------------------------------------------+----------
       Yes |         7          0          0          0 |         7 
           |    100.00       0.00       0.00       0.00 |    100.00 
           |     25.93       0.00       0.00       0.00 |      8.43 
-----------+--------------------------------------------+----------
        No |         2          1          0          0 |         3 
           |     66.67      33.33       0.00       0.00 |    100.00 
           |      7.41       2.78       0.00       0.00 |      3.61 
-----------+--------------------------------------------+----------
        99 |        18         35         18          2 |        73 
           |     24.66      47.95      24.66       2.74 |    100.00 
           |     66.67      97.22     100.00     100.00 |     87.95 
-----------+--------------------------------------------+----------
     Total |        27         36         18          2 |        83 
           |     32.53      43.37      21.69       2.41 |    100.00 
           |    100.00     100.00     100.00     100.00 |    100.00 

*/
/*
-> sex = Male

+-------------------+
| Key               |
|-------------------|
|     frequency     |
|  row percentage   |
| column percentage |
+-------------------+

       Was |
reperfusio |
         n |
 treatment |    What type of acute MI was diagnosed?
attempted? |     STEMI     NSTEMI  AMI (defi  Sudden ca |     Total
-----------+--------------------------------------------+----------
       Yes |        22          0          0          0 |        22 
           |    100.00       0.00       0.00       0.00 |    100.00 
           |     46.81       0.00       0.00       0.00 |     21.57 
-----------+--------------------------------------------+----------
        No |         5          3          0          0 |         8 
           |     62.50      37.50       0.00       0.00 |    100.00 
           |     10.64       7.69       0.00       0.00 |      7.84 
-----------+--------------------------------------------+----------
        99 |        20         36         11          5 |        72 
           |     27.78      50.00      15.28       6.94 |    100.00 
           |     42.55      92.31     100.00     100.00 |     70.59 
-----------+--------------------------------------------+----------
     Total |        47         39         11          5 |       102 
           |     46.08      38.24      10.78       4.90 |    100.00 
           |    100.00     100.00     100.00     100.00 |    100.00
*/


** First save the total number of patients reperfused whose cases were fully abstracted
preserve
tab htype sd_absstatus ,m
contract sex htype if sd_absstatus==1
rename _freq number
egen totstemi=total(number) if htype==1
egen totstemi_female=total(number) if htype==1 & sex==1
egen totstemi_male=total(number) if htype==1 & sex==2
egen number_total=total(number)
fillmissing tot*
drop if htype!=1
gen id=_n
drop if id==2
drop number sex htype id

order totstemi_female totstemi_male totstemi number_total
save "`datapath'\version03\2-working\pm2_stemi_heart" ,replace
restore

** Save these results as a dataset for reporting Table 1.6
preserve
by sex,sort:tab reperf htype if sd_absstatus==1 , m row col //by sex
contract reperf sex if sd_absstatus==1 & htype==1
rename _freq number
egen totreperf=total(number) if reperf==1
egen number_total=total(number)
gen totreperf_male=number if reperf==1 & sex==2
fillmissing totreperf_male
gen id=_n
drop if id!=1
rename number totreperf_female
keep id totreperf*

append using "`datapath'\version03\2-working\pm2_stemi_heart"

fillmissing totreperf*
drop if id==1
drop id

gen percent_pm2_stemireperf=(totreperf)/totstemi*100
replace percent_pm2_stemireperf=round(percent_pm2_stemireperf,1.0)

gen percent_pm2_stemireperf_female=(totreperf_female)/totstemi_female*100
replace percent_pm2_stemireperf_female=round(percent_pm2_stemireperf_female,1.0)

gen percent_pm2_stemireperf_male=(totreperf_male)/totstemi_male*100
replace percent_pm2_stemireperf_male=round(percent_pm2_stemireperf_male,1.0)

order totreperf_female percent_pm2_stemireperf_female totstemi_female totreperf_male percent_pm2_stemireperf_male totstemi_male totreperf percent_pm2_stemireperf totstemi

tostring totreperf_female ,replace
tostring percent_pm2_stemireperf_female ,replace
tostring totstemi_female ,replace
tostring totreperf_male ,replace
tostring percent_pm2_stemireperf_male ,replace
tostring totstemi_male ,replace
tostring totreperf ,replace
tostring percent_pm2_stemireperf ,replace

rename totreperf_female reperfused_female
rename percent_pm2_stemireperf_female percent_female
replace reperfused_female=reperfused_female+" "+"("+percent_female+"%)"
drop percent_female
rename totstemi_female stemi_female

rename totreperf_male reperfused_male
rename percent_pm2_stemireperf_male percent_male
replace reperfused_male=reperfused_male+" "+"("+percent_male+"%)"
drop percent_male
rename totstemi_male stemi_male

rename totreperf reperfused_total
rename percent_pm2_stemireperf percent_total
replace reperfused_total=reperfused_total+" "+"("+percent_total+"%)"
drop percent_total
rename totstemi stemi_total

save "`datapath'\version03\2-working\pm2_stemi_heart" ,replace
restore



***********************************************
** PM3: Median time to reperfusion for STEMI **
***********************************************


**********************************************
** 2021: Time from scene to arrival at A&E  **  
**********************************************
preserve
** Check for and remove cases wherein AMI occurred after admission to hospital, i.e. in-hospital events
count if edate>dae & inhosp==1 //7 - in-hospital AMIs
//list record_id dae edate inhosp arrival if edate>dae
drop if edate>dae & inhosp==1 //7 deleted

** Check for and remove cases that were not abstracted
tab sd_absstatus ,m //282 partially abs + DCOs
drop if sd_absstatus!=1 //282 deleted

** Check timings wherein time ambulance from scene is AFTER arrival to A&E
** JC 19mar2023: although these were checked during cleaning, some could not be corrected as timings could not be confirmed via MedData
count if sd_daetae<sd_frmscndt & sd_daetae!=. & sd_frmscndt!=. //2 - records 2840 + 2442 I could not confirm correct times so need to drop so it does not skew median time for this PM
//list record_id frmscnd frmscnt dae tae sd_comments if sd_daetae<sd_frmscndt & sd_daetae!=. & sd_frmscndt!=.
drop if record_id=="2840"|record_id=="2442" //2 deleted


** Check if admission time and time from scene have not been mistakenly switched at abstraction
gen double tae_pm3 = clock(tae, "hm") 
format tae_pm3 %tc_HH:MM
gen double frmscnt_pm3 = clock(frmscnt, "hm") 
format frmscnt_pm3 %tc_HH:MM
count if tae_pm3<frmscnt_pm3 & tae_pm3!=. & frmscnt_pm3!=. & dae==frmscnd //0

** Check if admission time and time from scene have not been mistakenly assigned as AM and PM, respectively, at abstraction
count if tae_pm3<frmscnt_pm3 & tae_pm3!=. & frmscnt_pm3!=. & dae==frmscnd //0

** Check if datetime variables for 'from scene' and 'admission' are not missing
count if sd_daetae==. & dae!=. & tae_pm3!=. //0
count if sd_frmscndt==. & frmscnd!=. & frmscnt_pm3!=. //0

count if sd_daetae==. //13
count if sd_frmscndt==. //89
count if sd_daetae==. & sd_frmscndt==. //5


** Create variables to assess timing
gen mins_scn2door=round(minutes(round(sd_daetae-sd_frmscndt))) if (sd_daetae!=. & sd_frmscndt!=.)
replace mins_scn2door=round(minutes(round(tae_pm3-frmscnt_pm3))) if mins_scn2door==. & (tae_pm3!=. & frmscnt_pm3!=.) //0 changes
count if mins_scn2door<0 //0 - checking to ensure this has been correctly generated
count if mins_scn2door==. //97 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_scn2door==. //97 deleted; JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_scn2door=(mins_scn2door/60)
label var mins_scn2door "Total minutes from patient pickup to hospital" 
label var hrs_scn2door "Total hours from patient pickup to hospital"

tab mins_scn2door ,m
tab hrs_scn2door ,m

gen k=1

ameans mins_scn2door
ameans hrs_scn2door

** This code will run in Stata 17
table k, stat(q2 mins_scn2door) stat(q1 mins_scn2door) stat(q3 mins_scn2door) stat(min mins_scn2door) stat(max mins_scn2door)
table k, stat(q2 hrs_scn2door) stat(q1 hrs_scn2door) stat(q3 hrs_scn2door) stat(min hrs_scn2door) stat(max hrs_scn2door)


** Save these 'p50' results as a dataset for reporting Table 1.7

drop if k!=1 //0 deleted

save "`datapath'\version03\2-working\pm3_scn2door_heart_ar" ,replace

sum mins_scn2door
sum mins_scn2door ,detail
gen mins_scn2door_2021=r(p50)

tostring mins_scn2door_2021 ,replace
replace mins_scn2door_2021=mins_scn2door_2021+" "+"minutes"


replace mins_scn2door_2021="" if mins_scn2door_2021==". minutes"
fillmissing mins_scn2door_2021

keep mins_scn2door_2021
order mins_scn2door_2021
save "`datapath'\version03\2-working\pm3_scn2door_heart" ,replace

use "`datapath'\version03\2-working\pm3_scn2door_heart_ar" ,clear

sum hrs_scn2door
sum hrs_scn2door ,detail
gen hours_2021=r(p50)

collapse hours_2021


gen double fullhour_2021=int(hours_2021)
gen double fraction_2021=hours_2021-fullhour_2021
gen minutes_2021=round(fraction_2021*60,1)

tostring fullhour_2021 ,replace
tostring minutes_2021 ,replace
replace fullhour_2021=minutes_2021+" "+"minutes"
rename fullhour_2021 hrs_scn2door_2021

keep hrs_scn2door_2021

append using "`datapath'\version03\2-working\pm3_scn2door_heart"

fillmissing mins_scn2door*
gen id=_n
drop if id>1 
drop id
gen median_2021=mins_scn2door_2021
keep median_2021
gen pm3_category=1

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2021
erase "`datapath'\version03\2-working\pm3_scn2door_heart_ar.dta"
save "`datapath'\version03\2-working\pm3_scn2door_heart" ,replace
restore

*******************************************
** PM3: Time from admission to first ECG ** 
*******************************************

********************************************
** 2021: Time from admission to first ECG **
********************************************
preserve
** Check for and remove cases wherein AMI occurred after admission to hospital, i.e. in-hospital events
count if edate>dae & inhosp==1 //7 - in-hospital AMIs
//list record_id dae edate inhosp arrival if edate>dae
drop if edate>dae & inhosp==1 //7 deleted

** Check for and remove cases that were not abstracted
tab sd_absstatus ,m //282 partially abs + DCOs
drop if sd_absstatus!=1 //282 deleted

** Check timings wherein ECG time is BEFORE arrival to A&E
** JC 19mar2023: although these were checked during cleaning, some could not be corrected as timings could not be confirmed via MedData
count if sd_ecgdt<sd_daetae & sd_daetae!=. & sd_ecgdt!=. //32 - ECG done at FMC prior to arrival to A&E so need to drop so it does not skew median time for this PM
//list record_id dae tae ecgd ecgt sd_comments if sd_ecgdt<sd_daetae & sd_daetae!=. & sd_ecgdt!=. ,string(30)
drop if sd_ecgdt<sd_daetae & sd_daetae!=. & sd_ecgdt!=. //32 deleted


** Check if admission time and ECG time are consistent
gen double tae_pm3 = clock(tae, "hm") 
format tae_pm3 %tc_HH:MM
gen double ecgt_pm3 = clock(ecgt, "hm") 
format ecgt_pm3 %tc_HH:MM
count if tae_pm3>ecgt_pm3 & tae_pm3!=. & ecgt_pm3!=. & dae==ecgd //0

** Check if admission time and ECG time have not been mistakenly assigned as AM and PM, respectively, at abstraction
count if tae_pm3>ecgt_pm3 & tae_pm3!=. & ecgt_pm3!=. & dae==ecgd //0

** Check if datetime variables for 'ecg' and 'admission' are not missing
count if sd_daetae==. & dae!=. & tae_pm3!=. //0
count if sd_ecgdt==. & ecgd!=. & ecgt_pm3!=. //0

count if sd_daetae==. //13
count if sd_ecgdt==. //39
count if sd_daetae==. & sd_ecgdt==. //5

** Create variables to assess timing
gen mins_door2ecg=round(minutes(round(sd_ecgdt-sd_daetae))) if (sd_ecgdt!=. & sd_daetae!=.)
replace mins_door2ecg=round(minutes(round(ecgt_pm3-tae_pm3))) if mins_door2ecg==. & (ecgt_pm3!=. & tae_pm3!=.) //0 changes
count if mins_door2ecg<0 //0 - checking to ensure this has been correctly generated
count if mins_door2ecg==. //47 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_door2ecg==. //47 deleted; JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_door2ecg=(mins_door2ecg/60)
label var mins_door2ecg "Total minutes from hospital admission to ECG" 
label var hrs_door2ecg "Total hours from hospital admission to ECG"

tab mins_door2ecg ,m
tab hrs_door2ecg ,m

gen k=1

ameans mins_door2ecg
ameans hrs_door2ecg

** This code will run in Stata 17
table k, stat(q2 mins_door2ecg) stat(q1 mins_door2ecg) stat(q3 mins_door2ecg) stat(min mins_door2ecg) stat(max mins_door2ecg)
table k, stat(q2 hrs_door2ecg) stat(q1 hrs_door2ecg) stat(q3 hrs_door2ecg) stat(min hrs_door2ecg) stat(max hrs_door2ecg)

** Save these 'p50' results as a dataset for reporting Table 1.7

drop if k!=1

save "`datapath'\version03\2-working\pm3_door2ecg_heart_ar" ,replace

sum mins_door2ecg
sum mins_door2ecg ,detail
gen mins_door2ecg_2021=r(p50)

tostring mins_door2ecg_2021 ,replace
replace mins_door2ecg_2021=mins_door2ecg_2021+" "+"minutes"


replace mins_door2ecg_2021="" if mins_door2ecg_2021==". minutes"
fillmissing mins_door2ecg_2021

keep mins_door2ecg_2021
order mins_door2ecg_2021
save "`datapath'\version03\2-working\pm3_door2ecg_heart" ,replace

use "`datapath'\version03\2-working\pm3_door2ecg_heart_ar" ,clear

sum hrs_door2ecg
sum hrs_door2ecg ,detail
gen hours_2021=r(p50)

collapse hours_2021


gen double fullhour_2021=int(hours_2021)
gen double fraction_2021=hours_2021-fullhour_2021
gen minutes_2021=round(fraction_2021*60,1)

tostring fullhour_2021 ,replace
tostring minutes_2021 ,replace
replace fullhour_2021=fullhour_2021+" "+"hour"+" "+minutes_2021+" "+"minutes"
rename fullhour_2021 hrs_door2ecg_2021

keep hrs_door2ecg_2021

append using "`datapath'\version03\2-working\pm3_door2ecg_heart"

fillmissing mins_door2ecg*
gen id=_n
drop if id>1 
drop id
gen median_2021=mins_door2ecg_2021+" "+"or"+" "+hrs_door2ecg_2021
keep median_2021
gen pm3_category=2

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2021

erase "`datapath'\version03\2-working\pm3_door2ecg_heart_ar.dta"
save "`datapath'\version03\2-working\pm3_door2ecg_heart" ,replace
restore


*********************************************************************
** PM3: STEMI pts door2needle time for those who were thrombolysed **
*********************************************************************

***********************************************
** 2021: Time from admission to thrombolysis **
***********************************************
tab reperf ,m //29 pts had reperf
tab reperf htype ,m //all 29 were STEMI; only 29 of 76 STEMI were thrombolysed

preserve
** Check for and remove cases wherein AMI occurred after admission to hospital, i.e. in-hospital events
count if edate>dae & inhosp==1 //7 - in-hospital AMIs
//list record_id dae edate inhosp arrival if edate>dae
drop if edate>dae & inhosp==1 //7 deleted

** Check for and remove cases that were not abstracted
tab sd_absstatus ,m //282 partially abs + DCOs
drop if sd_absstatus!=1 //282 deleted

** Check timings wherein reperfusion time is BEFORE arrival to A&E
** JC 19mar2023: although these were checked during cleaning, some could not be corrected as timings could not be confirmed via MedData
count if sd_reperfdt<sd_daetae & sd_daetae!=. & sd_reperfdt!=. //0
drop if sd_reperfdt<sd_daetae & sd_daetae!=. & sd_reperfdt!=. //0 deleted


** Check if admission time and reperfusion time are consistent
gen double tae_pm3 = clock(tae, "hm") 
format tae_pm3 %tc_HH:MM
gen double reperft_pm3 = clock(reperft, "hm") 
format reperft_pm3 %tc_HH:MM
count if tae_pm3>reperft_pm3 & tae_pm3!=. & reperft_pm3!=. & dae==reperfd //0

** Check if admission time and reperfusion time have not been mistakenly assigned as AM and PM, respectively, at abstraction
count if tae_pm3>reperft_pm3 & tae_pm3!=. & reperft_pm3!=. & dae==reperfd //0

** Check if datetime variables for 'from scene' and 'admission' are not missing
count if sd_daetae==. & dae!=. & tae_pm3!=. //0
count if sd_reperfdt==. & reperfd!=. & reperft_pm3!=. //0

count if sd_daetae==. //13
count if sd_reperfdt==. //149
count if sd_daetae==. & sd_reperfdt==. //12


** Create variables to assess timing
gen mins_door2needle=round(minutes(round(sd_reperfdt-sd_daetae))) if (sd_reperfdt!=. & sd_daetae!=.)
replace mins_door2needle=round(minutes(round(reperft_pm3-tae_pm3))) if mins_door2needle==. & (reperft_pm3!=. & tae_pm3!=.) //0 changes
count if mins_door2needle<0 //0 - checking to ensure this has been correctly generated
count if mins_door2needle==. //150 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_door2needle==. //150 deleted; JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_door2needle=(mins_door2needle/60)
label var mins_door2needle "Total minutes from arrival at hospital to thrombolysis (door-to-needle)" 
label var hrs_door2needle "Total hours from arrival at hospital to thrombolysis (door-to-needle)"

tab mins_door2needle ,m
tab hrs_door2needle ,m

gen k=1

ameans mins_door2needle
ameans hrs_door2needle

** This code will run in Stata 17
table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle)
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle)

** Save these 'p50' results as a dataset for reporting Table 1.7

drop if k!=1

save "`datapath'\version03\2-working\pm3_door2needle_heart_ar" ,replace

sum mins_door2needle
sum mins_door2needle ,detail
gen mins_door2needle_2021=r(p50)

tostring mins_door2needle_2021 ,replace
replace mins_door2needle_2021=mins_door2needle_2021+" "+"minutes"


replace mins_door2needle_2021="" if mins_door2needle_2021==". minutes"
fillmissing mins_door2needle_2021

keep mins_door2needle_2021
order mins_door2needle_2021
save "`datapath'\version03\2-working\pm3_door2needle_heart" ,replace

use "`datapath'\version03\2-working\pm3_door2needle_heart_ar" ,clear

sum hrs_door2needle
sum hrs_door2needle ,detail
gen hours_2021=r(p50)

collapse hours_2021

gen double fullhour_2021=int(hours_2021)
gen double fraction_2021=hours_2021-fullhour_2021
gen minutes_2021=round(fraction_2021*60,1)

tostring fullhour_2021 ,replace
tostring minutes_2021 ,replace
replace fullhour_2021=fullhour_2021+" "+"hour"+" "+minutes_2021+" "+"minutes"
rename fullhour_2021 hrs_door2needle_2021

keep hrs_door2needle_2021

append using "`datapath'\version03\2-working\pm3_door2needle_heart"

fillmissing mins_door2needle*
gen id=_n
drop if id>1 
drop id
gen median_2021=mins_door2needle_2021+" "+"or"+" "+hrs_door2needle_2021
keep median_2021
gen pm3_category=3

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2021

erase "`datapath'\version03\2-working\pm3_door2needle_heart_ar.dta"
save "`datapath'\version03\2-working\pm3_door2needle_heart" ,replace
restore


**********************************************************************
** PM3: STEMI pts onset2needle time for those who were thrombolysed **
**********************************************************************

**************************************
** 2021: from Onset to Thrombolysis **
**************************************
tab reperf ,m //29 pts had reperf
tab reperf htype ,m //all 29 were STEMI; only 29 of 76 STEMI were thrombolysed

preserve
** Check for and remove cases wherein AMI occurred after admission to hospital, i.e. in-hospital events
count if edate>dae & inhosp==1 //7 - in-hospital AMIs
//list record_id dae edate inhosp arrival if edate>dae
//drop if edate>dae & inhosp==1 //7 deleted
//DO NOT remove in-hospital AMIs as these can be applicable for timing of this performance measure

** Check for and remove cases that were not abstracted
tab sd_absstatus ,m //282 partially abs + DCOs
drop if sd_absstatus!=1 //282 deleted

** Check timings wherein reperfusion time is BEFORE onset/event
** JC 19mar2023: although these were checked during cleaning, some could not be corrected as timings could not be confirmed via MedData
count if sd_reperfdt<sd_eventdt & sd_eventdt!=. & sd_reperfdt!=. //0
drop if sd_reperfdt<sd_eventdt & sd_eventdt!=. & sd_reperfdt!=. //0 deleted


** Check if event time and reperfusion time are consistent
gen double etime_pm3 = clock(etime, "hm") 
format etime_pm3 %tc_HH:MM
gen double reperft_pm3 = clock(reperft, "hm") 
format reperft_pm3 %tc_HH:MM
count if etime_pm3>reperft_pm3 & etime_pm3!=. & reperft_pm3!=. & edate==reperfd //0

** Check if event time and reperfusion time have not been mistakenly assigned as AM and PM, respectively, at abstraction
count if etime_pm3>reperft_pm3 & etime_pm3!=. & reperft_pm3!=. & edate==reperfd //0

** Check if datetime variables for 'from scene' and 'admission' are not missing
count if sd_eventdt==. & edate!=. & etime_pm3!=. //0
count if sd_reperfdt==. & reperfd!=. & reperft_pm3!=. //0

count if sd_eventdt==. //73
count if sd_reperfdt==. //156
count if sd_eventdt==. & sd_reperfdt==. //70


** Create variables to assess timing
gen mins_onset2needle=round(minutes(round(sd_reperfdt-sd_eventdt))) if (sd_reperfdt!=. & sd_eventdt!=.)
replace mins_onset2needle=round(minutes(round(reperft_pm3-etime_pm3))) if mins_onset2needle==. & (reperft_pm3!=. & etime_pm3!=.) //0 changes
count if mins_onset2needle<0 //0 - checking to ensure this has been correctly generated
count if mins_onset2needle==. //159 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_onset2needle==. //159 deleted; JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_onset2needle=(mins_onset2needle/60)
label var mins_onset2needle "Total minutes from onset to thrombolysis (onset-to-needle)" 
label var hrs_onset2needle "Total hours from onset to thrombolysis (onset-to-needle)"

tab mins_onset2needle ,m
tab hrs_onset2needle ,m

gen k=1

ameans mins_onset2needle
ameans hrs_onset2needle

** This code will run in Stata 17
table k, stat(q2 mins_onset2needle) stat(q1 mins_onset2needle) stat(q3 mins_onset2needle) stat(min mins_onset2needle) stat(max mins_onset2needle)
table k, stat(q2 hrs_onset2needle) stat(q1 hrs_onset2needle) stat(q3 hrs_onset2needle) stat(min hrs_onset2needle) stat(max hrs_onset2needle)

** Save these 'p50' results as a dataset for reporting Table 1.7
drop if k!=1

save "`datapath'\version03\2-working\pm3_onset2needle_heart_ar" ,replace

sum mins_onset2needle
sum mins_onset2needle ,detail
gen mins_onset2needle_2021=r(p50)

tostring mins_onset2needle_2021 ,replace
replace mins_onset2needle_2021=mins_onset2needle_2021+" "+"minutes"

replace mins_onset2needle_2021="" if mins_onset2needle_2021==". minutes"
fillmissing mins_onset2needle_2021

keep mins_onset2needle_2021
order mins_onset2needle_2021
save "`datapath'\version03\2-working\pm3_onset2needle_heart" ,replace

use "`datapath'\version03\2-working\pm3_onset2needle_heart_ar" ,clear

sum hrs_onset2needle
sum hrs_onset2needle ,detail
gen hours_2021=r(p50)

collapse hours_2021


gen double fullhour_2021=int(hours_2021)
gen double fraction_2021=hours_2021-fullhour_2021
gen minutes_2021=round(fraction_2021*60,1)

tostring fullhour_2021 ,replace
tostring minutes_2021 ,replace
replace fullhour_2021=fullhour_2021+" "+"hours"+" "+minutes_2021+" "+"minutes"
rename fullhour_2021 hrs_onset2needle_2021

keep hrs_onset2needle_2021

append using "`datapath'\version03\2-working\pm3_onset2needle_heart"

fillmissing mins_onset2needle*
gen id=_n
drop if id>1 
drop id
gen median_2021=mins_onset2needle_2021+" "+"or"+" "+hrs_onset2needle_2021
keep median_2021
gen pm3_category=4

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2021

append using "`datapath'\version03\2-working\pm3_scn2door_heart"
append using "`datapath'\version03\2-working\pm3_door2ecg_heart"
append using "`datapath'\version03\2-working\pm3_door2needle_heart"

sort pm3_category
rename pm3_category category

erase "`datapath'\version03\2-working\pm3_onset2needle_heart_ar.dta"
erase "`datapath'\version03\2-working\pm3_scn2door_heart.dta"
erase "`datapath'\version03\2-working\pm3_door2ecg_heart.dta"
erase "`datapath'\version03\2-working\pm3_door2needle_heart.dta"

save "`datapath'\version03\2-working\pm3_heart" ,replace
restore


*************************************************
** PM4: PTs who received ECHO before discharge **
*************************************************
tab decho ,m
/*
        ECHO |
(Transthorac |
     ic echo |
cardiography |
           ) |      Freq.     Percent        Cum.
-------------+-----------------------------------
         Yes |         57       12.21       12.21
          No |          1        0.21       12.42
Referred for |         65       13.92       26.34
          99 |         42        8.99       35.33
           . |        302       64.67      100.00
-------------+-----------------------------------
       Total |        467      100.00
*/

tab decho sex ,m
/*
        ECHO |
(Transthorac |
     ic echo |
cardiography |  Incidence Data: Sex
           ) |    Female       Male |     Total
-------------+----------------------+----------
         Yes |        25         32 |        57 
          No |         1          0 |         1 
Referred for |        24         41 |        65 
          99 |        22         20 |        42 
           . |       150        152 |       302 
-------------+----------------------+----------
       Total |       222        245 |       467
*/

tab decho sd_absstatus ,m

** Save these results as a dataset for reporting Table 1.8
preserve
drop if sd_absstatus!=1 //282 deleted - DCOs and partial abstractions
tab decho vstatus ,m
/*
        ECHO |
(Transthorac |
     ic echo |    Vital Status at
cardiography |       discharge
           ) |     Alive   Deceased |     Total
-------------+----------------------+----------
         Yes |        45         12 |        57 
          No |         1          0 |         1 
Referred for |        54         11 |        65 
          99 |        23         19 |        42 
           . |         0         20 |        20 
-------------+----------------------+----------
       Total |       123         62 |       185
*/
tab decho sex ,m
/*
        ECHO |
(Transthorac |
     ic echo |
cardiography |  Incidence Data: Sex
           ) |    Female       Male |     Total
-------------+----------------------+----------
         Yes |        25         32 |        57 
          No |         1          0 |         1 
Referred for |        24         41 |        65 
          99 |        22         20 |        42 
           . |        11          9 |        20 
-------------+----------------------+----------
       Total |        83        102 |       185
*/

contract decho sex

drop if decho==.
rename _freq number
egen disecho=total(number) if decho==1
egen refecho=total(number) if decho==3
egen totecho=total(number)
gen percent_disecho_f=number/disecho*100 if sex==1 & disecho!=.
gen percent_disecho_m=number/disecho*100 if sex==2 & disecho!=.
gen percent_refecho_f=number/refecho*100 if sex==1 & refecho!=.
gen percent_refecho_m=number/refecho*100 if sex==2 & refecho!=.
gen percent_disecho_tot=disecho/totecho*100
gen percent_refecho_tot=refecho/totecho*100

drop if decho!=1 & decho!=3
gen id=_n

order id

reshape wide decho number disecho refecho totecho percent_disecho_f percent_disecho_m percent_refecho_f percent_refecho_m percent_disecho_tot percent_refecho_tot, i(id)  j(sex)

rename decho1 Timing

label var Timing "Timing"
label define Timing_lab 1 "Before discharge" 3 "Referred to receive after discharge" , modify
label values Timing Timing_lab

drop decho2
fillmissing disecho* refecho* totecho* percent_disecho_f* percent_disecho_m* percent_refecho_f* percent_refecho_m* percent_disecho_tot* percent_refecho_tot*
replace number2=number2[_n+1] if number2==.
drop if id==2|id==4

rename number1 female_num
rename number2 male_num
rename percent_disecho_f1 female_percent
replace female_percent=percent_refecho_f1 if id==3
rename percent_disecho_m2 male_percent
replace male_percent=percent_refecho_m2 if id==3
rename disecho1 total_num
replace total_num=refecho1 if id==3
rename percent_disecho_tot1 total_percent
replace total_percent=percent_refecho_tot1 if id==3

order id Timing female_num female_percent male_num male_percent total_num total_percent
keep Timing female_num female_percent male_num male_percent total_num total_percent

replace female_percent=round(female_percent,1.0)
replace male_percent=round(male_percent,1.0)
replace total_percent=round(total_percent,1.0)

save "`datapath'\version03\2-working\pm4_ecg_heart" ,replace
restore

**********************************************
** PM5: PTs prescribed Aspirin at discharge **
**********************************************
tab aspdis if sd_absstatus==1 ,m
tab aspdis sex if sd_absstatus==1 ,m
tab vstatus if sd_absstatus==1 ,m
tab aspdis if sd_absstatus==1 ,m
tab aspdis if sd_absstatus==1 & vstatus==1 ,m
** Of those discharged(123), 101 had aspirin at discharge //2021
dis 101/123  //82%
** Of those discharged(222), 184 had aspirin at discharge //2020
dis 184/222  //83%

** JC 17mar2022: per discussion with NS, check for cases wherein [aspdis]!=yes/at discharge but antiplatelets [pladis]=yes/at discharge and same for aspirin used chronically [aspchr]
tab pladis if aspdis==99 //3
tab asp___2 if aspdis==99 //7
tab asp___2 if aspdis==99 & pladis==99 //7
tab aspdis pladis
tab aspdis asp___2

bysort asp___2 :tab aspdis pladis if sd_absstatus==1
bysort sd_absstatus :tab aspdis pladis if asp___2!=1
bysort sd_absstatus :tab aspdis pladis if asp___2!=1 & vstatus==1

tabulate aspdis pladis if sd_absstatus==1 & vstatus==1, nokey row column 

** Save these results as a dataset for reporting PM5 "Documented aspirin prescribed at discharge"
preserve
tab vstatus aspdis if sd_absstatus==1
save "`datapath'\version03\2-working\pm5_asp_heart" ,replace
restore

** JC 09jun2022: NS requested combining aspirin and antiplatelets into one group called 'Aspirin/Antiplatelet therapy' which would include those not discharged on aspirin but discharged on antiplatelets and those chronically on aspirin
preserve
bysort sd_eyear :tab vstatus
tab aspdis sd_eyear if aspdis==1, matcell(foo)
mat li foo
svmat foo, names(sd_eyear)
egen total_alive_2021=total(vstatus) if vstatus==1 & sd_eyear==2021
fillmissing total_alive*

gen id=_n
keep id sd_eyear1 total_alive*

drop if id!=1
gen category="aspirin"
drop id

rename sd_eyear1 aspdis
//reshape wide aspdis_*, i(id)  j(year)

rename total_alive_2021 total_alive
gen year=5
keep year aspdis total_alive

label define year_lab 1 "2017" 2 "2018" 3 "2019" 4 "2020" 5 "2021" ,modify
label values year year_lab
label var year "Year"

save "`datapath'\version03\2-working\pm5_asppla_heart" ,replace
restore

preserve
tab pladis sd_eyear if pladis==1 & aspdis==99, matcell(foo)
mat li foo
svmat foo, names(sd_eyear)
gen id=_n

keep id sd_eyear1

drop if id!=1
gen category="antiplatelets"
drop id

//reshape wide pladis_*, i(id)  j(year)

gen year=5
rename sd_eyear1 pladis
keep year pladis

label define year_lab 1 "2017" 2 "2018" 3 "2019" 4 "2020" 5 "2021" ,modify
label values year year_lab
label var year "Year"

merge 1:1 year using "`datapath'\version03\2-working\pm5_asppla_heart"
drop _merge

save "`datapath'\version03\2-working\pm5_asppla_heart" ,replace
restore

preserve
tab asp___2 sd_eyear if asp___2==1 & aspdis==99
tab asp___2 sd_eyear if asp___2==1 & aspdis==99 & pladis==99
tab asp___2 sd_eyear if asp___2==1 & aspdis==99 & pladis==99, matcell(foo)
mat li foo
svmat foo, names(sd_eyear)
gen id=_n

keep id sd_eyear1

drop if id!=1
gen category="chronic aspirin"
drop id

gen year=5
rename sd_eyear1 aspchr
keep year aspchr

label define year_lab 1 "2017" 2 "2018" 3 "2019" 4 "2020" 5 "2021" ,modify
label values year year_lab
label var year "Year"

merge 1:1 year using "`datapath'\version03\2-working\pm5_asppla_heart"
drop _merge

gen asppla = aspdis + pladis + aspchr
gen asppla_percent=asppla/total_alive*100
replace asppla_percent=round(asppla_percent,1.0)

order year aspchr pladis aspdis asppla total_alive asppla_percent
drop aspchr pladis
save "`datapath'\version03\2-working\pm5_asppla_heart" ,replace
restore


*********************************************
** PM6: PTs prescribed Statin at discharge **
*********************************************
tab statdis ,m
tab statdis if sd_absstatus==1 ,m
tab vstatus if sd_absstatus==1 ,m
tab statdis if sd_absstatus==1 & vstatus==1 ,m
** Of those discharged(123), 95 had statin at discharge //2021
dis 95/123  //77%
** Of those discharged(222), 181 had statin at discharge //2020
dis 181/222  //82%

** JC update: Save these results as a dataset for reporting PM6 "Documented statins prescribed at discharge"
preserve
tab vstatus statdis if sd_absstatus==1
save "`datapath'\version03\2-working\pm6_statin_heart" ,replace
restore



*************************************************
** Additional Analyses: % persons <70 with AMI **
*************************************************
** Requested by SF via email on 20may2022
count if age<70 //all cases
count if age<70 & sd_absstatus==1 //cases abstracted by BNR
count if sd_eyear==2021
count if sd_eyear==2021 & sd_absstatus==1

preserve
egen totcases=count(sd_etype) if sd_etype!=.
egen totabs=count(sd_etype) if sd_absstatus==1
egen totagecases=count(sd_etype) if age<70
egen totageabs=count(sd_etype) if age<70 & sd_absstatus==1
fillmissing totcases totabs totagecases totageabs
gen id=_n
drop if id!=1

keep totcases totabs totagecases totageabs
gen totagecases_percent=totagecases/totcases*100
replace totagecases_percent=round(totagecases_percent,1.0)
gen totageabs_percent=totageabs/totabs*100
replace totageabs_percent=round(totageabs_percent,1.0)
gen id=2
gen registry="heart"
gen category=2
gen year=2021

order id registry category year totagecases totcases totagecases_percent totageabs totabs totageabs_percent

label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

save "`datapath'\version03\2-working\addanalyses_age" ,replace
restore
