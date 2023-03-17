** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5n_analysis PMs_heart.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      17-MAR-2023
    // 	date last modified      17-MAR-2023
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
clear

STOP


***********************************************
** PM3: Median time to reperfusion for STEMI **
***********************************************


****************************************
** Time from scene to arrival at A&E  **  
****************************************
//preserve
** Check for and remove cases wherein AMI occurred after admission to hospital
count if edate>dae //7 - in-hospital AMIs
list record_id dae edate inhosp arrival if edate>dae
drop if edate>dae //7 deleted

** Check for and remove cases that were not abstracted
tab sd_absstatus ,m //282 partially abs + DCOs
drop if sd_absstatus!=1 //282 deleted

** Create variable to assess timing
** JC 17mar2022 using a different method from AH for this as it's best to use datetime variable instead of time variable only when calculating timing
** JC 17mar2022 cleaning check for if admission date after at scene or from scene dates as error noted from below minutes variable
count if dae<frmscnd & dae!=. & frmscnd!=. //0
//list record_id dae frmscnd if dae<frmscnd & dae!=. & frmscnd!=.
count if sd_daetae<sd_frmscndt & sd_daetae!=. & sd_frmscndt!=. //3
list record_id frmscnd frmscnt dae tae sd_comments if sd_daetae<sd_frmscndt & sd_daetae!=. & sd_frmscndt!=.

STOP
** First check if admission time and time from scene have not been mistakenly switched at abstraction
count if tae<frmscnt & tae!=. & frmscnt!=. & dae==frmscnd //3
list anon_pid record_id org_id tae frmscnt dae frmscnd if tae<frmscnt & tae!=. & frmscnt!=. & dae==frmscnd
di clock("13:55:00.000", "hms") //50100000
replace tae=50100000 if anon_pid==1935|record_id=="2020896"
swapval tae t_hosp if anon_pid==2924|record_id=="2020211"
replace tae=t_hosp if anon_pid==1468|record_id=="2020706"


** Check if admission time and time from scene have not been mistakenly assigned as AM and PM, respectively, at abstraction
generate double tae_pm3=hms(hh(tae), mm(tae), ss(tae))
format tae_pm3 %tcHH:MM:SS
generate double frmscnt_pm3=hms(hh(frmscnt), mm(frmscnt), ss(frmscnt))
format frmscnt_pm3 %tcHH:MM:SS
count if tae_pm3<frmscnt_pm3 & tae!=. & frmscnt!=. & dae==frmscnd //0
list anon_pid record_id tae frmscnt if tae_pm3<frmscnt_pm3 & tae!=. & frmscnt!=. & dae==frmscnd

/*
** JC 12apr2022 below copied from 2019 code above - kept in for historical purposes.
di clock("09:35:00.000", "hms") //34500000
di clock("21:35:00.000", "hms") //77700000
di clock("21:07:00.000", "hms") //76020000
replace tae=77700000 if anon_pid==544|record_id=="20191083"
replace t_hosp=77700000 if anon_pid==544|record_id=="20191083"
replace ambcallt=76020000 if anon_pid==544|record_id=="20191083"
*/

** Check if datetime variables for 'from scene' and 'admission' are not missing
count if daetae==. & dae!=. & tae!=. //5
list record_id dae tae daetae if daetae==. & dae!=. & tae!=.
gen double daetae_pm3 = dhms(dae,hh(tae),mm(tae),ss(tae))
format daetae_pm3 %tcNN/DD/CCYY_HH:MM:SS
//format daetae_pm3 %tCDDmonCCYY_HH:MM:SS - when using this is changes the mm:ss part of the time
//list record_id daetae_pm3 dae tae if daetae_pm3!=.

count if frmscnt_dtime==. & frmscnd!=. & frmscnt!=. //0
gen double frmscndt_pm3 = dhms(frmscnd,hh(frmscnt),mm(frmscnt),ss(frmscnt))
format frmscndt_pm3 %tcNN/DD/CCYY_HH:MM:SS
//list record_id frmscndt_pm3 frmscnd frmscnt if frmscndt_pm3!=.

count if daetae_pm3==. //10
count if frmscndt_pm3==. //108


** Create variables to assess timing
gen mins_scn2door=round(minutes(round(daetae_pm3-frmscndt_pm3))) if (daetae_pm3!=. & frmscndt_pm3!=.)
replace mins_scn2door=round(minutes(round(t_hosp-frmscnt))) if mins_scn2door==. & (t_hosp!=. & frmscnt!=.) //0 changes
count if mins_scn2door<0 //0 - checking to ensure this has been correctly generated
count if mins_scn2door==. //110 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_scn2door==. //JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_scn2door=(mins_scn2door/60)
label var mins_scn2door "Total minutes from patient pickup to hospital" 
label var hrs_scn2door "Total hours from patient pickup to hospital"

tab mins_scn2door if year==2020 ,miss
tab hrs_scn2door if year==2020 ,miss

save "`datapath'\version03\2-working\pm3_scn2door_heart_2020" ,replace

gen k=1

ameans mins_scn2door
ameans hrs_scn2door

** This code will run in Stata 17
table k, stat(q2 mins_scn2door) stat(q1 mins_scn2door) stat(q3 mins_scn2door) stat(min mins_scn2door) stat(max mins_scn2door)
table k, stat(q2 hrs_scn2door) stat(q1 hrs_scn2door) stat(q3 hrs_scn2door) stat(min hrs_scn2door) stat(max hrs_scn2door)
restore


** JC update: Save these 'p50' results as a dataset for reporting Table 1.7
preserve

use "`datapath'\version03\2-working\pm3_scn2door_heart_2018" ,clear
append using "`datapath'\version03\2-working\pm3_scn2door_heart_2019"
append using "`datapath'\version03\2-working\pm3_scn2door_heart_2020"

drop mins_scn2door hrs_scn2door
gen mins_scn2door=round(minutes(round(daetae_pm3-frmscndt_pm3))) if year==2020 & (daetae_pm3!=. & frmscndt_pm3!=.) // changes
replace mins_scn2door=round(minutes(round(daetae_pm3-frmscndt_pm3))) if year==2020 & mins_scn2door==. & (t_hosp!=. & frmscnt!=.) // changes

replace mins_scn2door=round(minutes(round(dohtoh_pm3-frmscndt_pm3))) if year==2019 & (dohtoh_pm3!=. & frmscndt_pm3!=.) // changes
replace mins_scn2door=round(minutes(round(t_hosp-frmscnt))) if year==2019 & mins_scn2door==. & (t_hosp!=. & frmscnt!=.) // changes

replace mins_scn2door=round(minutes(round(dohtoh_pm3-frmscndt_pm3))) if year==2018 & (dohtoh_pm3!=. & frmscndt_pm3!=.) // changes
replace mins_scn2door=round(minutes(round(t_hosp-frmscnt))) if year==2018 & mins_scn2door==. & (t_hosp!=. & frmscnt!=.) // changes

gen hrs_scn2door=(mins_scn2door/60) // changes
label var mins_scn2door "Total minutes from patient pickup to hospital (scene-to-door)"
label var hrs_scn2door "Total hours from patient pickup to hospital (scene-to-door)"

gen k=1

table k, stat(q2 mins_scn2door) stat(q1 mins_scn2door) stat(q3 mins_scn2door) stat(min mins_scn2door) stat(max mins_scn2door), if year==2020
table k, stat(q2 hrs_scn2door) stat(q1 hrs_scn2door) stat(q3 hrs_scn2door) stat(min hrs_scn2door) stat(max hrs_scn2door), if year==2020

table k, stat(q2 mins_scn2door) stat(q1 mins_scn2door) stat(q3 mins_scn2door) stat(min mins_scn2door) stat(max mins_scn2door), if year==2019
table k, stat(q2 hrs_scn2door) stat(q1 hrs_scn2door) stat(q3 hrs_scn2door) stat(min hrs_scn2door) stat(max hrs_scn2door), if year==2019

table k, stat(q2 mins_scn2door) stat(q1 mins_scn2door) stat(q3 mins_scn2door) stat(min mins_scn2door) stat(max mins_scn2door), if year==2018
table k, stat(q2 hrs_scn2door) stat(q1 hrs_scn2door) stat(q3 hrs_scn2door) stat(min hrs_scn2door) stat(max hrs_scn2door), if year==2018

drop if year<2018
drop if k!=1

save "`datapath'\version03\2-working\pm3_scn2door_heart_ar" ,replace

sum mins_scn2door if year==2020
sum mins_scn2door ,detail, if year==2020
gen mins_scn2door_2020=r(p50) if year==2020

tostring mins_scn2door_2020 ,replace
replace mins_scn2door_2020=mins_scn2door_2020+" "+"minutes"


sum mins_scn2door if year==2019
sum mins_scn2door ,detail, if year==2019
gen mins_scn2door_2019=r(p50) if year==2019

tostring mins_scn2door_2019 ,replace
replace mins_scn2door_2019=mins_scn2door_2019+" "+"minutes"


sum mins_scn2door if year==2018
sum mins_scn2door ,detail, if year==2018
gen mins_scn2door_2018=r(p50) if year==2018

tostring mins_scn2door_2018 ,replace
replace mins_scn2door_2018=mins_scn2door_2018+" "+"minutes"

replace mins_scn2door_2018="" if mins_scn2door_2018==". minutes"
replace mins_scn2door_2019="" if mins_scn2door_2019==". minutes"
replace mins_scn2door_2020="" if mins_scn2door_2020==". minutes"
fillmissing mins_scn2door_2018 mins_scn2door_2019 mins_scn2door_2020

keep mins_scn2door_2018 mins_scn2door_2019 mins_scn2door_2020
order mins_scn2door_2018 mins_scn2door_2019 mins_scn2door_2020
save "`datapath'\version03\2-working\pm3_scn2door_heart" ,replace

use "`datapath'\version03\2-working\pm3_scn2door_heart_ar" ,clear

sum hrs_scn2door if year==2020
sum hrs_scn2door ,detail, if year==2020
gen hours_2020=r(p50) if year==2020

sum hrs_scn2door if year==2019
sum hrs_scn2door ,detail, if year==2019
gen hours_2019=r(p50) if year==2019

sum hrs_scn2door if year==2018
sum hrs_scn2door ,detail, if year==2018
gen hours_2018=r(p50) if year==2018

collapse hours_2018 hours_2019 hours_2020

gen double fullhour_2018=int(hours_2018)
gen double fraction_2018=hours_2018-fullhour_2018
gen minutes_2018=round(fraction_2018*60,1)

tostring fullhour_2018 ,replace
tostring minutes_2018 ,replace
replace fullhour_2018=minutes_2018+" "+"minutes"
rename fullhour_2018 hrs_scn2door_2018


gen double fullhour_2019=int(hours_2019)
gen double fraction_2019=hours_2019-fullhour_2019
gen minutes_2019=round(fraction_2019*60,1)

tostring fullhour_2019 ,replace
tostring minutes_2019 ,replace
replace fullhour_2019=minutes_2019+" "+"minutes"
rename fullhour_2019 hrs_scn2door_2019


gen double fullhour_2020=int(hours_2020)
gen double fraction_2020=hours_2020-fullhour_2020
gen minutes_2020=round(fraction_2020*60,1)

tostring fullhour_2020 ,replace
tostring minutes_2020 ,replace
replace fullhour_2020=minutes_2020+" "+"minutes"
rename fullhour_2020 hrs_scn2door_2020

keep hrs_scn2door_2018 hrs_scn2door_2019 hrs_scn2door_2020

append using "`datapath'\version03\2-working\pm3_scn2door_heart"

fillmissing mins_scn2door*
gen id=_n
drop if id>1 
drop id
gen median_2018=mins_scn2door_2018
gen median_2019=mins_scn2door_2019
gen median_2020=mins_scn2door_2020
keep median_2018 median_2019 median_2020
gen pm3_category=1

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2018 median_2019 median_2020
erase "`datapath'\version03\2-working\pm3_scn2door_heart_ar.dta"
save "`datapath'\version03\2-working\pm3_scn2door_heart" ,replace
restore

*******************************************
** PM3: Time from admission to first ECG ** 
*******************************************

****************************************
** 2020 Time from admission to first ECG
****************************************
preserve
** Use corrected 2020 dataset from above (scene-to-door)
use "`datapath'\version03\2-working\pm3_scn2door_heart_2020" ,clear

** Remove non-2020 cases
drop if year!=2020 //0 deleted

** Check for and remove cases wherein ECG was performed before admission to hospital (different day)
count if year==2020 & dae>ecgd //3
list record_id ecgd ecgt dae tae ambulance if year==2020 & dae>ecgd
list record_id if year==2020 & dae>ecgd
drop if year==2020 & dae>ecgd //3 deleted

** Check if datetime variables for 'from scene' and 'admission' are not missing
count if ecgdt==. & ecgd!=. & ecgt!=. //5
list record_id ecgd ecgt ecgdt if ecgdt==. & ecgd!=. & ecgt!=.
gen double ecgdt_pm3 = dhms(ecgd,hh(ecgt),mm(ecgt),ss(ecgt))
format ecgdt_pm3 %tcNN/DD/CCYY_HH:MM:SS
//format ecgdtae_pm3 %tCDDmonCCYY_HH:MM:SS - when using this is changes the mm:ss part of the time
//list record_id ecgdtae_pm3 ecgd tae if ecgdtae_pm3!=.

count if daetae==. & dae!=. & tae!=. //5 - already corrected in this dataset
//gen double daetae_pm3 = dhms(dae,hh(tae),mm(tae),ss(tae))
//format daetae_pm3 %tcNN/DD/CCYY_HH:MM:SS
//list record_id daetae_pm3 frmscnd tae if daetae_pm3!=.

count if ecgdt_pm3==. //75
count if daetae_pm3==. //0

** Check for and remove cases wherein ECG was performed before admission to hospital (same day different time)
count if daetae_pm3>ecgdt_pm3 //18
list record_id ecgd ecgt dae tae ambulance if daetae_pm3>ecgdt_pm3
drop if daetae_pm3>ecgdt_pm3 //18 deleted


** Create variables to assess timing
gen mins_door2ecg=round(minutes(round(ecgdt_pm3-daetae_pm3))) if (ecgdt_pm3!=. & daetae_pm3!=.)
replace mins_door2ecg=round(minutes(round(ecgt-tae))) if mins_door2ecg==. & (ecgt!=. & tae!=.) //0 changes
count if mins_door2ecg<0 //0 - checking to ensure this has been correctly generated
count if mins_door2ecg==. //75 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_door2ecg==. //JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_door2ecg=(mins_door2ecg/60)
label var mins_door2ecg "Total minutes from hospital admission to ECG" 
label var hrs_door2ecg "Total hours from hospital admission to ECG"

tab mins_door2ecg if year==2020 & ambulance==1 ,miss
tab hrs_door2ecg if year==2020 & ambulance==1,miss

save "`datapath'\version03\2-working\pm3_door2ecg_heart_2020" ,replace
 
gen k=1

ameans mins_door2ecg
ameans hrs_door2ecg

** This code will run in Stata 17
table k, stat(q2 mins_door2ecg) stat(q1 mins_door2ecg) stat(q3 mins_door2ecg) stat(min mins_door2ecg) stat(max mins_door2ecg)
table k, stat(q2 hrs_door2ecg) stat(q1 hrs_door2ecg) stat(q3 hrs_door2ecg) stat(min hrs_door2ecg) stat(max hrs_door2ecg)
restore


** JC update: Save these 'p50' results as a dataset for reporting Table 1.7
preserve
use "`datapath'\version03\2-working\pm3_door2ecg_heart_2018" ,clear
append using "`datapath'\version03\2-working\pm3_door2ecg_heart_2019"
append using "`datapath'\version03\2-working\pm3_door2ecg_heart_2020"

drop mins_door2ecg hrs_door2ecg
gen mins_door2ecg=round(minutes(round(ecgdt_pm3-daetae_pm3))) if year==2020 & (ecgdt_pm3!=. & daetae_pm3!=.) // changes
replace mins_door2ecg=round(minutes(round(ecgt-tae))) if year==2020 & mins_door2ecg==. & (ecgt!=. & tae!=.) // changes

replace mins_door2ecg=round(minutes(round(ecgdt_pm3-dohtoh_pm3))) if year==2019 & (ecgdt_pm3!=. & dohtoh_pm3!=.) // changes
replace mins_door2ecg=round(minutes(round(ecgt-toh))) if year==2019 & mins_door2ecg==. & (ecgt!=. & toh!=.) // changes

replace mins_door2ecg=round(minutes(round(ecgdt_pm3-dohtoh_pm3))) if year==2018 & (ecgdt_pm3!=. & dohtoh_pm3!=.) // changes
replace mins_door2ecg=round(minutes(round(ecgt-toh))) if year==2018 & mins_door2ecg==. & (ecgt!=. & toh!=.)  // changes

gen hrs_door2ecg=(mins_door2ecg/60) // changes
label var mins_door2ecg "Total minutes from hospital admission to ECG (door-to-ecg)"
label var hrs_door2ecg "Total hours from hospital admission to ECG (door-to-ecg)"

gen k=1

table k, stat(q2 mins_door2ecg) stat(q1 mins_door2ecg) stat(q3 mins_door2ecg) stat(min mins_door2ecg) stat(max mins_door2ecg), if year==2020
table k, stat(q2 hrs_door2ecg) stat(q1 hrs_door2ecg) stat(q3 hrs_door2ecg) stat(min hrs_door2ecg) stat(max hrs_door2ecg), if year==2020

table k, stat(q2 mins_door2ecg) stat(q1 mins_door2ecg) stat(q3 mins_door2ecg) stat(min mins_door2ecg) stat(max mins_door2ecg), if year==2019
table k, stat(q2 hrs_door2ecg) stat(q1 hrs_door2ecg) stat(q3 hrs_door2ecg) stat(min hrs_door2ecg) stat(max hrs_door2ecg), if year==2019

table k, stat(q2 mins_door2ecg) stat(q1 mins_door2ecg) stat(q3 mins_door2ecg) stat(min mins_door2ecg) stat(max mins_door2ecg), if year==2018
table k, stat(q2 hrs_door2ecg) stat(q1 hrs_door2ecg) stat(q3 hrs_door2ecg) stat(min hrs_door2ecg) stat(max hrs_door2ecg), if year==2018

drop if year<2018
drop if k!=1

save "`datapath'\version03\2-working\pm3_door2ecg_heart_ar" ,replace

sum mins_door2ecg if year==2020
sum mins_door2ecg ,detail, if year==2020
gen mins_door2ecg_2020=r(p50) if year==2020

tostring mins_door2ecg_2020 ,replace
replace mins_door2ecg_2020=mins_door2ecg_2020+" "+"minutes"


sum mins_door2ecg if year==2019
sum mins_door2ecg ,detail, if year==2019
gen mins_door2ecg_2019=r(p50) if year==2019

tostring mins_door2ecg_2019 ,replace
replace mins_door2ecg_2019=mins_door2ecg_2019+" "+"minutes"


sum mins_door2ecg if year==2018
sum mins_door2ecg ,detail, if year==2018
gen mins_door2ecg_2018=r(p50) if year==2018

tostring mins_door2ecg_2018 ,replace
replace mins_door2ecg_2018=mins_door2ecg_2018+" "+"minutes"

replace mins_door2ecg_2018="" if mins_door2ecg_2018==". minutes"
replace mins_door2ecg_2019="" if mins_door2ecg_2019==". minutes"
replace mins_door2ecg_2020="" if mins_door2ecg_2020==". minutes"
fillmissing mins_door2ecg_2018 mins_door2ecg_2019 mins_door2ecg_2020

keep mins_door2ecg_2018 mins_door2ecg_2019 mins_door2ecg_2020
order mins_door2ecg_2018 mins_door2ecg_2019 mins_door2ecg_2020
save "`datapath'\version03\2-working\pm3_door2ecg_heart" ,replace

use "`datapath'\version03\2-working\pm3_door2ecg_heart_ar" ,clear

sum hrs_door2ecg if year==2020
sum hrs_door2ecg ,detail, if year==2020
gen hours_2020=r(p50) if year==2020

sum hrs_door2ecg if year==2019
sum hrs_door2ecg ,detail, if year==2019
gen hours_2019=r(p50) if year==2019

sum hrs_door2ecg if year==2018
sum hrs_door2ecg ,detail, if year==2018
gen hours_2018=r(p50) if year==2018

collapse hours_2018 hours_2019 hours_2020

gen double fullhour_2018=int(hours_2018)
gen double fraction_2018=hours_2018-fullhour_2018
gen minutes_2018=round(fraction_2018*60,1)

tostring fullhour_2018 ,replace
tostring minutes_2018 ,replace
replace fullhour_2018=minutes_2018+" "+"minutes"
rename fullhour_2018 hrs_door2ecg_2018


gen double fullhour_2019=int(hours_2019)
gen double fraction_2019=hours_2019-fullhour_2019
gen minutes_2019=round(fraction_2019*60,1)

tostring fullhour_2019 ,replace
tostring minutes_2019 ,replace
replace fullhour_2019=minutes_2019+" "+"minutes"
rename fullhour_2019 hrs_door2ecg_2019


gen double fullhour_2020=int(hours_2020)
gen double fraction_2020=hours_2020-fullhour_2020
gen minutes_2020=round(fraction_2020*60,1)

tostring fullhour_2020 ,replace
tostring minutes_2020 ,replace
replace fullhour_2020=fullhour_2020+" "+"hour"+" "+minutes_2020+" "+"minutes"
rename fullhour_2020 hrs_door2ecg_2020

keep hrs_door2ecg_2018 hrs_door2ecg_2019 hrs_door2ecg_2020

append using "`datapath'\version03\2-working\pm3_door2ecg_heart"

fillmissing mins_door2ecg*
gen id=_n
drop if id>1 
drop id
gen median_2018=mins_door2ecg_2018
gen median_2019=mins_door2ecg_2019
gen median_2020=mins_door2ecg_2020+" "+"or"+" "+hrs_door2ecg_2020
keep median_2018 median_2019 median_2020
gen pm3_category=2

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2018 median_2019 median_2020
erase "`datapath'\version03\2-working\pm3_door2ecg_heart_ar.dta"
save "`datapath'\version03\2-working\pm3_door2ecg_heart" ,replace
restore


** JC 17mar2022: Below was the only code for PM3 in the 2020 analysis dofile

*********************************************************************
** PM3: STEMI pts door2needle time for those who were thrombolysed **
*********************************************************************
tab reperf if year==2017,m // 40 pts had reperf
tab reperf if year==2018,m // 42 pts had reperf
tab reperf if year==2019,m // 44 pts had reperf
tab reperf if year==2020,m // 51 pts had reperf

preserve

drop if  record_id=="20202380" | record_id=="202096" // case missing daetae - case ecg before admission.

*******************************************************************************************************
** Added by JC 10mar2022 - totals differ from AH's comments below (maybe a copy and paste error?)
count if year==2020 & reperfdt !=. //47
list record_id frmscnt dohtoh daetae reperfdt if year==2020 & reperfdt !=.
count if year==2020 & daetae!=. & reperfdt !=. //44
********************************************************************************************************

list reperfdt if year==2020 & reperfdt !=.
list record_id frmscnt doh toh daetae reperfdt if year==2020 & reperfdt !=.
** This shows that only 41 had times recorded for BOTH hosp arrival and TPA
** So we calculate door-to-needle time for 31 patients
gen mins_door2needle=round(minutes(round(reperfdt-daetae))) if year==2020 & (daetae!=. & reperfdt!=.) //44 changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2020 & (frmscnt_dtime!=. & daetae==. & reperfdt!=.) //2 changes

gen hrs_door2needle=(mins_door2needle/60) //46 changes
label var mins_door2needle "Total minutes from arrival at hospital to thrombolysis (door-to-needle)"
label var hrs_door2needle "Total hours from arrival at hospital to thrombolysis (door-to-needle)"

tab mins_door2needle 
tab hrs_door2needle 
list record_id gidcf reperfdt daetae daetae mins_door2needle hrs_door2needle if mins_door2needle<0

list record_id if year==2020 & hrs_door2needle<0
list record_id frmscnt doh toh daetae reperfdt mins_door2needle hrs_door2needle if year==2020 & hrs_door2needle<0

gen k=1

ameans mins_door2needle
ameans hrs_door2needle

** This code will run in Stata 17
table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle)
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle)

restore


** JC update: Save these 'p50' results as a dataset for reporting Table 1.7
preserve

drop if  record_id=="20202380" | record_id=="202096" // case missing daetae - case ecg before admission.

count if year==2018 & reperfdt !=. //40
list record_id frmscnt dohtoh daetae reperfdt if year==2018 & reperfdt !=.
count if year==2018 & dohtoh!=. & reperfdt !=. //37

count if year==2019 & reperfdt !=. //41
list record_id frmscnt dohtoh daetae reperfdt if year==2019 & reperfdt !=.
count if year==2019 & dohtoh!=. & reperfdt !=. //39

count if year==2020 & reperfdt !=. //47
list record_id frmscnt dohtoh daetae reperfdt if year==2020 & reperfdt !=.
count if year==2020 & daetae!=. & reperfdt !=. //44

gen mins_door2needle=round(minutes(round(reperfdt-daetae))) if year==2020 & (daetae!=. & reperfdt!=.) //44 changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2020 & (frmscnt_dtime!=. & daetae==. & reperfdt!=.) //2 changes

replace mins_door2needle=round(minutes(round(reperfdt-dohtoh))) if year==2019 & (dohtoh!=. & reperfdt!=.) // changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2019 & (frmscnt_dtime!=. & dohtoh==. & reperfdt!=.) // changes

replace mins_door2needle=round(minutes(round(reperfdt-dohtoh))) if year==2018 & (dohtoh!=. & reperfdt!=.) // changes
replace mins_door2needle=round(minutes(round(reperfdt-frmscnt_dtime))) if year==2018 & (frmscnt_dtime!=. & dohtoh==. & reperfdt!=.) // changes

gen hrs_door2needle=(mins_door2needle/60) //46 changes
label var mins_door2needle "Total minutes from arrival at hospital to thrombolysis (door-to-needle)"
label var hrs_door2needle "Total hours from arrival at hospital to thrombolysis (door-to-needle)"

gen k=1

table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle), if year==2020
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle), if year==2020

table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle), if year==2019
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle), if year==2019

table k, stat(q2 mins_door2needle) stat(q1 mins_door2needle) stat(q3 mins_door2needle) stat(min mins_door2needle) stat(max mins_door2needle), if year==2018
table k, stat(q2 hrs_door2needle) stat(q1 hrs_door2needle) stat(q3 hrs_door2needle) stat(min hrs_door2needle) stat(max hrs_door2needle), if year==2018

drop if year<2018
drop if k!=1

save "`datapath'\version03\2-working\pm3_door2needle_heart_ar" ,replace

sum mins_door2needle if year==2020
sum mins_door2needle ,detail, if year==2020
gen mins_door2needle_2020=r(p50) if year==2020

tostring mins_door2needle_2020 ,replace
replace mins_door2needle_2020=mins_door2needle_2020+" "+"minutes"


sum mins_door2needle if year==2019
sum mins_door2needle ,detail, if year==2019
gen mins_door2needle_2019=r(p50) if year==2019

tostring mins_door2needle_2019 ,replace
replace mins_door2needle_2019=mins_door2needle_2019+" "+"minutes"


sum mins_door2needle if year==2018
sum mins_door2needle ,detail, if year==2018
gen mins_door2needle_2018=r(p50) if year==2018

tostring mins_door2needle_2018 ,replace
replace mins_door2needle_2018=mins_door2needle_2018+" "+"minutes"

replace mins_door2needle_2018="" if mins_door2needle_2018==". minutes"
replace mins_door2needle_2019="" if mins_door2needle_2019==". minutes"
replace mins_door2needle_2020="" if mins_door2needle_2020==". minutes"
fillmissing mins_door2needle_2018 mins_door2needle_2019 mins_door2needle_2020

keep mins_door2needle_2018 mins_door2needle_2019 mins_door2needle_2020
order mins_door2needle_2018 mins_door2needle_2019 mins_door2needle_2020
save "`datapath'\version03\2-working\pm3_door2needle_heart" ,replace

use "`datapath'\version03\2-working\pm3_door2needle_heart_ar" ,clear

sum hrs_door2needle if year==2020
sum hrs_door2needle ,detail, if year==2020
gen hours_2020=r(p50) if year==2020

sum hrs_door2needle if year==2019
sum hrs_door2needle ,detail, if year==2019
gen hours_2019=r(p50) if year==2019

sum hrs_door2needle if year==2018
sum hrs_door2needle ,detail, if year==2018
gen hours_2018=r(p50) if year==2018

collapse hours_2018 hours_2019 hours_2020

gen double fullhour_2018=int(hours_2018)
gen double fraction_2018=hours_2018-fullhour_2018
gen minutes_2018=round(fraction_2018*60,1)

tostring fullhour_2018 ,replace
tostring minutes_2018 ,replace
replace fullhour_2018=fullhour_2018+" "+"hour"+" "+minutes_2018+" "+"minutes"
rename fullhour_2018 hrs_door2needle_2018


gen double fullhour_2019=int(hours_2019)
gen double fraction_2019=hours_2019-fullhour_2019
gen minutes_2019=round(fraction_2019*60,1)

tostring fullhour_2019 ,replace
tostring minutes_2019 ,replace
replace fullhour_2019=fullhour_2019+" "+"hours"+" "+minutes_2019+" "+"minutes"
rename fullhour_2019 hrs_door2needle_2019


gen double fullhour_2020=int(hours_2020)
gen double fraction_2020=hours_2020-fullhour_2020
gen minutes_2020=round(fraction_2020*60,1)

tostring fullhour_2020 ,replace
tostring minutes_2020 ,replace
replace fullhour_2020=fullhour_2020+" "+"hour"+" "+minutes_2020+" "+"minutes"
rename fullhour_2020 hrs_door2needle_2020

keep hrs_door2needle_2018 hrs_door2needle_2019 hrs_door2needle_2020

append using "`datapath'\version03\2-working\pm3_door2needle_heart"

fillmissing mins_door2needle*
gen id=_n
drop if id>1 
drop id
gen median_2018=mins_door2needle_2018+" "+"or"+" "+hrs_door2needle_2018
gen median_2019=mins_door2needle_2019+" "+"or"+" "+hrs_door2needle_2019
gen median_2020=mins_door2needle_2020+" "+"or"+" "+hrs_door2needle_2020
keep median_2018 median_2019 median_2020
gen pm3_category=3

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2018 median_2019 median_2020


erase "`datapath'\version03\2-working\pm3_door2needle_heart_ar.dta"
save "`datapath'\version03\2-working\pm3_door2needle_heart" ,replace

restore


**********************************************************************
** PM3: STEMI pts onset2needle time for those who were thrombolysed **
**********************************************************************

**********************************
** 2020 from Onset to Thrombolysis
**********************************
preserve
** Use corrected 2018 dataset from above (scene-to-door)
use "`datapath'\version03\2-working\pm3_scn2door_heart_2020" ,clear

** Time of chest pain (too) created to match 2018, 2019
gen too_pm3=hsym1t if hsym1t!="" & hsym1t!="88" & hsym1t!="99"
gen too_pm3_am="January 1,1960"+" "+too_pm3+" "+"am" if substr(too_pm3, 1, 2) < "12" & too_pm3!=""

generate double numtime = clock(too_pm3_am, "MDYhm")
format numtime %tc_HH:MM:SS
drop too_pm3_am
rename numtime too_pm3_am

gen too_pm3_pm="January 1,1960"+" "+too_pm3+" "+"am" if substr(too_pm3, 1, 2) > "12" & too_pm3!=""

generate double numtime = clock(too_pm3_pm, "MDYhm")
format numtime %tc_HH:MM:SS
drop too_pm3_pm
rename numtime too_pm3_pm
replace too_pm3_am=too_pm3_pm if too_pm3_am==.
drop too_pm3 too_pm3_pm
rename too_pm3_am too_pm3

** Time of AMI (tom) is datetime variable (dom + tom) - create var that contains only time (below code kept for reference/historical value)
count if too!=. & tom==. //0
list anon_pid record_id doo too sob_date vom_date dizzy_date palp_date sweat_date dom tom if too!=. & tom==.

generate double tom_pm3=hms(hhC(tom), mmC(tom), ssC(tom)) if tom!=.
format tom_pm3 %tc_HH:MM:SS

list tom tom_pm3

** Remove non-2020 cases
drop if year!=2020 //0 deleted

** Check for and remove cases wherein reperf was performed before admission to hospital (different day)
count if year==2020 & dom>reperfd //0
list record_id reperfd reperft dom tom ambulance if year==2020 & dom>reperfd
list record_id if year==2020 & dom>reperfd
drop if year==2020 & dom>reperfd //0 deleted

** Check if datetime variables for 'from scene' and 'admission' are not missing
count if reperfdt==. & reperfd!=. & reperft!=. //0
list record_id reperfd reperft reperfdt if reperfdt==. & reperfd!=. & reperft!=.
gen double reperfdt_pm3 = dhms(reperfd,hh(reperft),mm(reperft),ss(reperft))
format reperfdt_pm3 %tcNN/DD/CCYY_HH:MM:SS
//format reperfdtom_pm3 %tCDDmonCCYY_HH:MM:SS - when using this is changes the mm:ss part of the time
//list record_id reperfdtom_pm3 reperfd tom if reperfdtom_pm3!=.

//count if domtom==. & dom!=. & tom!=. //7 - already corrected in this dataset
gen double domtom_pm3 = dhms(dom,hh(tom_pm3),mm(tom_pm3),ss(tom_pm3))
format domtom_pm3 %tcNN/DD/CCYY_HH:MM:SS
count if domtom_pm3==. & tom!=. //0
//list record_id domtom_pm3 reperfdt tom if domtom_pm3!=.

count if reperfdt_pm3==. //131
count if domtom_pm3==. //47

** Check for and remove cases wherein reperf was performed before admission to hospital (same day different time)
count if domtom_pm3>reperfdt_pm3 //3
list anon_pid record_id reperfd reperft dom tom tom_pm3 domtom_pm3 reperfdt_pm3 if domtom_pm3>reperfdt_pm3
count if domtom_pm3>reperfdt_pm3 & domtom_pm3!=. & reperfdt_pm3!=. //1
list anon_pid record_id reperfd reperft dom tom tom_pm3 domtom_pm3 reperfdt_pm3 if domtom_pm3>reperfdt_pm3 & domtom_pm3!=. & reperfdt_pm3!=.
di %tc clock("12mar2020 14:58:00.000", "dmyhms")
di clock("14:58:00.000", "hms") //
replace reperft=53880000 if anon_pid==3944|record_id=="20202407"
replace reperfdt=dhms(reperfd,hhC(reperft),mmC(reperft),ssC(reperft)) if anon_pid==3944|record_id=="20202407"
replace reperfdt_pm3=reperfdt if anon_pid==3944|record_id=="20202407"

drop if domtom_pm3>reperfdt_pm3 //2 deleted


** Create variables to assess timing
gen mins_onset2needle=round(minutes(round(reperfdt_pm3-domtom_pm3))) if (reperfdt_pm3!=. & domtom_pm3!=.)
replace mins_onset2needle=round(minutes(round(reperft-tom_pm3))) if mins_onset2needle==. & (reperft!=. & tom_pm3!=.) //0 changes
count if mins_onset2needle<0 //0 - checking to ensure this has been correctly generated
count if mins_onset2needle==. //131 - ask NS if to drop these before calculating minutes for PM3 Timing since these are missing datetime so will automatically be missing
drop if mins_onset2needle==. //JC 12apr2022: Timing still calculated the same as not removing the missing datetimes so doesn't matter if they're removed
gen hrs_onset2needle=(mins_onset2needle/60)
label var mins_onset2needle "Total minutes from onset to thrombolysis (onset-to-needle)" 
label var hrs_onset2needle "Total hours from onset to thrombolysis (onset-to-needle)"

tab mins_onset2needle if year==2020 ,miss
tab hrs_onset2needle if year==2020 ,miss

save "`datapath'\version03\2-working\pm3_onset2needle_heart_2020" ,replace
 
gen k=1

ameans mins_onset2needle
ameans hrs_onset2needle

** This code will run in Stata 17
table k, stat(q2 mins_onset2needle) stat(q1 mins_onset2needle) stat(q3 mins_onset2needle) stat(min mins_onset2needle) stat(max mins_onset2needle)
table k, stat(q2 hrs_onset2needle) stat(q1 hrs_onset2needle) stat(q3 hrs_onset2needle) stat(min hrs_onset2needle) stat(max hrs_onset2needle)
restore


** JC update: Save these 'p50' results as a dataset for reporting Table 1.7
preserve
use "`datapath'\version03\2-working\pm3_onset2needle_heart_2018" ,clear
append using "`datapath'\version03\2-working\pm3_onset2needle_heart_2019"
append using "`datapath'\version03\2-working\pm3_onset2needle_heart_2020"

drop mins_onset2needle hrs_onset2needle
gen mins_onset2needle=round(minutes(round(reperfdt_pm3-domtom_pm3))) if year==2020 & (reperfdt_pm3!=. & domtom_pm3!=.) // changes
replace mins_onset2needle=round(minutes(round(reperft-tom_pm3))) if year==2020 & mins_onset2needle==. & (reperft!=. & tom_pm3!=.) // changes

replace mins_onset2needle=round(minutes(round(reperfdt_pm3-domtom_pm3))) if year==2019 & (reperfdt_pm3!=. & domtom_pm3!=.) // changes
replace mins_onset2needle=round(minutes(round(reperft-tom_pm3))) if year==2019 & mins_onset2needle==. & (reperft!=. & tom_pm3!=.) // changes

replace mins_onset2needle=round(minutes(round(reperfdt_pm3-domtom_pm3))) if year==2018 & (reperfdt_pm3!=. & domtom_pm3!=.) // changes
replace mins_onset2needle=round(minutes(round(reperft-tom_pm3))) if year==2018 & mins_onset2needle==. & (reperft!=. & tom_pm3!=.)  // changes

gen hrs_onset2needle=(mins_onset2needle/60) // changes
label var mins_onset2needle "Total minutes from onset to thrombolysis (onset-to-needle)"
label var hrs_onset2needle "Total hours from onset to thrombolysis (onset-to-needle)"

gen k=1

table k, stat(q2 mins_onset2needle) stat(q1 mins_onset2needle) stat(q3 mins_onset2needle) stat(min mins_onset2needle) stat(max mins_onset2needle), if year==2020
table k, stat(q2 hrs_onset2needle) stat(q1 hrs_onset2needle) stat(q3 hrs_onset2needle) stat(min hrs_onset2needle) stat(max hrs_onset2needle), if year==2020

table k, stat(q2 mins_onset2needle) stat(q1 mins_onset2needle) stat(q3 mins_onset2needle) stat(min mins_onset2needle) stat(max mins_onset2needle), if year==2019
table k, stat(q2 hrs_onset2needle) stat(q1 hrs_onset2needle) stat(q3 hrs_onset2needle) stat(min hrs_onset2needle) stat(max hrs_onset2needle), if year==2019

table k, stat(q2 mins_onset2needle) stat(q1 mins_onset2needle) stat(q3 mins_onset2needle) stat(min mins_onset2needle) stat(max mins_onset2needle), if year==2018
table k, stat(q2 hrs_onset2needle) stat(q1 hrs_onset2needle) stat(q3 hrs_onset2needle) stat(min hrs_onset2needle) stat(max hrs_onset2needle), if year==2018

drop if year<2018
drop if k!=1

save "`datapath'\version03\2-working\pm3_onset2needle_heart_ar" ,replace

sum mins_onset2needle if year==2020
sum mins_onset2needle ,detail, if year==2020
gen mins_onset2needle_2020=r(p50) if year==2020

tostring mins_onset2needle_2020 ,replace
replace mins_onset2needle_2020=mins_onset2needle_2020+" "+"minutes"


sum mins_onset2needle if year==2019
sum mins_onset2needle ,detail, if year==2019
gen mins_onset2needle_2019=r(p50) if year==2019

tostring mins_onset2needle_2019 ,replace
replace mins_onset2needle_2019=mins_onset2needle_2019+" "+"minutes"


sum mins_onset2needle if year==2018
sum mins_onset2needle ,detail, if year==2018
gen mins_onset2needle_2018=r(p50) if year==2018

tostring mins_onset2needle_2018 ,replace
replace mins_onset2needle_2018=mins_onset2needle_2018+" "+"minutes"

replace mins_onset2needle_2018="" if mins_onset2needle_2018==". minutes"
replace mins_onset2needle_2019="" if mins_onset2needle_2019==". minutes"
replace mins_onset2needle_2020="" if mins_onset2needle_2020==". minutes"
fillmissing mins_onset2needle_2018 mins_onset2needle_2019 mins_onset2needle_2020

keep mins_onset2needle_2018 mins_onset2needle_2019 mins_onset2needle_2020
order mins_onset2needle_2018 mins_onset2needle_2019 mins_onset2needle_2020
save "`datapath'\version03\2-working\pm3_onset2needle_heart" ,replace

use "`datapath'\version03\2-working\pm3_onset2needle_heart_ar" ,clear

sum hrs_onset2needle if year==2020
sum hrs_onset2needle ,detail, if year==2020
gen hours_2020=r(p50) if year==2020

sum hrs_onset2needle if year==2019
sum hrs_onset2needle ,detail, if year==2019
gen hours_2019=r(p50) if year==2019

sum hrs_onset2needle if year==2018
sum hrs_onset2needle ,detail, if year==2018
gen hours_2018=r(p50) if year==2018

collapse hours_2018 hours_2019 hours_2020

gen double fullhour_2018=int(hours_2018)
gen double fraction_2018=hours_2018-fullhour_2018
gen minutes_2018=round(fraction_2018*60,1)

tostring fullhour_2018 ,replace
tostring minutes_2018 ,replace
replace fullhour_2018=fullhour_2018+" "+"hours"+" "+minutes_2018+" "+"minutes"
rename fullhour_2018 hrs_onset2needle_2018


gen double fullhour_2019=int(hours_2019)
gen double fraction_2019=hours_2019-fullhour_2019
gen minutes_2019=round(fraction_2019*60,1)

tostring fullhour_2019 ,replace
tostring minutes_2019 ,replace
replace fullhour_2019=fullhour_2019+" "+"hours"+" "+minutes_2019+" "+"minutes"
rename fullhour_2019 hrs_onset2needle_2019


gen double fullhour_2020=int(hours_2020)
gen double fraction_2020=hours_2020-fullhour_2020
gen minutes_2020=round(fraction_2020*60,1)

tostring fullhour_2020 ,replace
tostring minutes_2020 ,replace
replace fullhour_2020=fullhour_2020+" "+"hours"+" "+minutes_2020+" "+"minutes"
rename fullhour_2020 hrs_onset2needle_2020

keep hrs_onset2needle_2018 hrs_onset2needle_2019 hrs_onset2needle_2020

append using "`datapath'\version03\2-working\pm3_onset2needle_heart"

fillmissing mins_onset2needle*
gen id=_n
drop if id>1 
drop id
gen median_2018=mins_onset2needle_2018+" "+"or"+" "+hrs_onset2needle_2018
gen median_2019=mins_onset2needle_2019+" "+"or"+" "+hrs_onset2needle_2019
gen median_2020=mins_onset2needle_2020+" "+"or"+" "+hrs_onset2needle_2020
keep median_2018 median_2019 median_2020
gen pm3_category=4

label var pm3_category "PM3 Category"
label define pm3_category_lab 1 "Median time from scene to arrival at A&E" 2 "Median time from admission to first ECG" ///
							  3 "Median time from admission to fibrinolysis" 4 "Median time from onset to fibrinolysis" , modify
label values pm3_category pm3_category_lab

order pm3_category median_2018 median_2019 median_2020

append using "`datapath'\version03\2-working\pm3_scn2door_heart"
append using "`datapath'\version03\2-working\pm3_door2ecg_heart"
append using "`datapath'\version03\2-working\pm3_door2needle_heart"

sort pm3_category
rename pm3_category category

erase "`datapath'\version03\2-working\pm3_scn2door_heart_2018.dta"
erase "`datapath'\version03\2-working\pm3_scn2door_heart_2019.dta"
erase "`datapath'\version03\2-working\pm3_scn2door_heart_2020.dta"
erase "`datapath'\version03\2-working\pm3_door2ecg_heart_2018.dta"
erase "`datapath'\version03\2-working\pm3_door2ecg_heart_2019.dta"
erase "`datapath'\version03\2-working\pm3_door2ecg_heart_2020.dta"
erase "`datapath'\version03\2-working\pm3_onset2needle_heart_2018.dta"
erase "`datapath'\version03\2-working\pm3_onset2needle_heart_2019.dta"
erase "`datapath'\version03\2-working\pm3_onset2needle_heart_2020.dta"
erase "`datapath'\version03\2-working\pm3_onset2needle_heart_ar.dta"
erase "`datapath'\version03\2-working\pm3_scn2door_heart.dta"
erase "`datapath'\version03\2-working\pm3_door2ecg_heart.dta"
erase "`datapath'\version03\2-working\pm3_door2needle_heart.dta"

save "`datapath'\version03\2-working\pm3_heart" ,replace
restore


*************************************************
** PM4: PTs who received ECHO before discharge **
*************************************************
tab decho year
tab decho sex if year==2011
tab decho sex if year==2012
tab decho sex if year==2013
tab decho sex if year==2014
tab decho sex if year==2015
tab decho sex if year==2016
tab decho sex if year==2017
tab decho sex if year==2018
tab decho sex if year==2019
tab decho sex if year==2020
tab decho if year==2019
tab decho if year==2020


** JC update: Save these results as a dataset for reporting Table 1.8
preserve
save "`datapath'\version03\2-working\pm4_ecg_heart_ar" ,replace

drop if year!=2020

/* JC 14mar2022: testing out below code to output to Word using asdoc command
cd "`datapath'\version03\3-output"
asdoc tabulate decho sex , nokey row column replace
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
/* 
	JC 20jul2022: Simon Anderson's query from 2020 annual report review: Can we do this by NSTEMI and STEMI? Particularly the latter…
	So I added the below code to create a separate table from the above to differentiate by heart type

use "`datapath'\version03\2-working\pm4_ecg_heart_ar" ,clear
STOP - need to ask NS how best to do this as in other code, e.g. PM2 + PM3, the heart type variable [htype] is not used but the ECG variable denoting STEMI [ecgste] is used to identify STEMI cases; So how do I identify NSTEMI cases? Do I use [htype]? However, [htype] has less NSTEMI cases than when [ecgstd] and [ecgtwv] are used...
tab ecgste if year==2020
tab htype if year==2020

** STEMI
by year,sort:tab decho ecgste, m row col
by year sex,sort:tab decho ecgste, m row col //use this for STEMI

by year sex,sort:tab decho ecgstd, m row col
by year sex,sort:tab decho ecgtwv, m row col

by year sex,sort:tab decho htype, m row col
tab decho htype if year==2020 & sex==2
tab decho ecgstd if year==2020 & sex==2
tab decho ecgtwv if year==2020 & sex==2
** 
tab decho sex if year==2020 

drop if year!=2020
...
*/
erase "`datapath'\version03\2-working\pm4_ecg_heart_ar.dta"
restore

**********************************************
** PM5: PTs prescribed Aspirin at discharge **
**********************************************
tab aspdis year
tab aspdis sex if year==2011
tab aspdis sex if year==2012
tab aspdis sex if year==2013
tab aspdis sex if year==2014
tab aspdis sex if year==2015
tab aspdis sex if year==2016
tab aspdis sex if year==2017
tab aspdis sex if year==2018
tab aspdis sex if year==2019
tab aspdis sex if year==2020
tab aspdis if year==2019
tab vstatus if  abstracted==1 & year==2019
tab aspdis if year==2019 & vstatus==1
tab aspdis if year==2020
tab vstatus if  abstracted==1 & year==2020
** Of those discharged( 222), 184 had aspirin at discharge.
dis 184/222  //83%

** JC 17mar2022: per discussion with NS, check for cases wherein [aspdis]!=yes/at discharge but antiplatelets [pladis]=yes/at discharge and same for aspirin used chronically [aspchr]
bysort year :tab pladis if aspdis==99|aspdis==2
bysort year :tab aspchr if aspdis==99|aspdis==2
bysort year :tab aspchr if (aspdis==99|aspdis==2) & (pladis==99|pladis==2)
bysort year :tab aspdis pladis
bysort year :tab aspdis aspchr

tab pladis if year==2020 & (aspdis==99|aspdis==2)
tab aspchr if year==2020 & (aspdis==99|aspdis==2)
tab aspdis pladis if year==2020
tab aspdis aspchr if year==2020

bysort aspchr :tab aspdis pladis if year==2019
bysort year :tab aspdis pladis if aspchr!=1
bysort year :tab aspdis pladis if aspchr!=1 & vstatus==1

tab aspdis if vstatus==1 & year==2019 //77%
tab aspdis if abstracted==1 & year==2019 //59%
tab aspdis if vstatus==1 & year==2019 & pladis==1
tabulate aspdis pladis if year==2019, nokey row column 

** JC update: Save these results as a dataset for reporting PM5 "Documented aspirin prescribed at discharge"
preserve
tab vstatus aspdis if abstracted==1 & year==2020
save "`datapath'\version03\2-working\pm5_asp_heart" ,replace
restore

** JC 09jun2022: NS requested combining aspirin and antiplatelets into one group called 'Aspirin/Antiplatelet therapy' which would include those not discharged on aspirin but discharged on antiplatelets and those chronically on aspirin
preserve
bysort year :tab vstatus
tab aspdis year if aspdis==1, matcell(foo)
mat li foo
svmat foo, names(year)
egen total_alive_2020=total(vstatus) if vstatus==1 & year==2020
egen total_alive_2019=total(vstatus) if vstatus==1 & year==2019
egen total_alive_2018=total(vstatus) if vstatus==1 & year==2018
egen total_alive_2017=total(vstatus) if vstatus==1 & year==2017
fillmissing total_alive*

gen id=_n
keep id year9-year12 total_alive*

drop if id!=1
gen category="aspirin"
drop id
expand 4 in 1
gen id=_n

gen year=1 if id==1
replace year=2 if id==2
replace year=3 if id==3
replace year=4 if id==4
rename year9 aspdis_2017
rename year10 aspdis_2018
rename year11 aspdis_2019
rename year12 aspdis_2020
reshape wide aspdis_*, i(id)  j(year)

replace aspdis_20171=aspdis_20182 if id==2
replace aspdis_20171=aspdis_20193 if id==3
replace aspdis_20171=aspdis_20204 if id==4
rename id year
rename aspdis_20171 aspdis
rename total_alive_2020 total_alive
replace total_alive=total_alive_2017 if year==1
replace total_alive=total_alive_2018 if year==2
replace total_alive=total_alive_2019 if year==3
keep year aspdis total_alive

label define year_lab 1 "2017" 2 "2018" 3 "2019" 4 "2020" ,modify
label values year year_lab
label var year "Year"

save "`datapath'\version03\2-working\pm5_asppla_heart" ,replace
restore

preserve
tab pladis year if pladis==1 & (aspdis==99|aspdis==2), matcell(foo)
mat li foo
svmat foo, names(year)
gen id=_n
keep id year7-year10

drop if id!=1
gen category="antiplatelets"
drop id
expand 4 in 1
gen id=_n

gen year=1 if id==1
replace year=2 if id==2
replace year=3 if id==3
replace year=4 if id==4
rename year7 pladis_2017
rename year8 pladis_2018
rename year9 pladis_2019
rename year10 pladis_2020
reshape wide pladis_*, i(id)  j(year)

replace pladis_20171=pladis_20182 if id==2
replace pladis_20171=pladis_20193 if id==3
replace pladis_20171=pladis_20204 if id==4
rename id year
rename pladis_20171 pladis
keep year pladis

label define year_lab 1 "2017" 2 "2018" 3 "2019" 4 "2020" ,modify
label values year year_lab
label var year "Year"

merge 1:1 year using "`datapath'\version03\2-working\pm5_asppla_heart"
drop _merge

save "`datapath'\version03\2-working\pm5_asppla_heart" ,replace
restore

preserve
tab aspchr year if aspchr==1 & (aspdis==99|aspdis==2)
tab aspchr year if aspchr==1 & (aspdis==99|aspdis==2) & (pladis==99|pladis==2)
tab aspchr year if aspchr==1 & (aspdis==99|aspdis==2) & (pladis==99|pladis==2), matcell(foo)
mat li foo
svmat foo, names(year)
gen id=_n
keep id year7-year10

drop if id!=1
gen category="chronic aspirin"
drop id
expand 4 in 1
gen id=_n

gen year=1 if id==1
replace year=2 if id==2
replace year=3 if id==3
replace year=4 if id==4
rename year7 aspchr_2017
rename year8 aspchr_2018
rename year9 aspchr_2019
rename year10 aspchr_2020
reshape wide aspchr_*, i(id)  j(year)

replace aspchr_20171=aspchr_20182 if id==2
replace aspchr_20171=aspchr_20193 if id==3
replace aspchr_20171=aspchr_20204 if id==4
rename id year
rename aspchr_20171 aspchr
keep year aspchr

label define year_lab 1 "2017" 2 "2018" 3 "2019" 4 "2020" ,modify
label values year year_lab
label var year "Year"

merge 1:1 year using "`datapath'\version03\2-working\pm5_asppla_heart"
drop _merge

gen asppla = aspdis + pladis + aspchr
gen asppla_percent=asppla/total_alive*100
replace asppla_percent=round(asppla_percent,1.0)

order year aspchr pladis aspdis asppla total_alive asppla_percent
save "`datapath'\version03\2-working\pm5_asppla_heart" ,replace
restore


*********************************************
** PM6: PTs prescribed Statin at discharge **
*********************************************
tab statdis year
tab statdis sex if year==2011
tab statdis sex if year==2012
tab statdis sex if year==2013
tab statdis sex if year==2014
tab statdis sex if year==2015
tab statdis sex if year==2016
tab statdis sex if year==2017
tab statdis sex if year==2018
tab statdis sex if year==2019
tab statdis sex if year==2020
tab statdis if year==2020
tab vstatus if abstracted==1 & year==2020
** Of those discharged( 222), 181 had statin at discharge.
dis 181/222  //82%

** JC update: Save these results as a dataset for reporting PM6 "Documented statins prescribed at discharge"
preserve
tab vstatus statdis if abstracted==1 & year==2020
save "`datapath'\version03\2-working\pm6_statin_heart" ,replace
restore



***********************************************************
** Additional Analyses: % CTs for those discharged alive **
***********************************************************
** Requested by SF via email on 20may2022

tab ct ,m
tab ct year
tab vstatus ct
tab ct year if vstatus==1
tab vstatus if abstracted==1
tab vstatus ct if abstracted==1 & year==2020


** JC update: Save these results as a dataset for reporting Figure 1.4 
preserve
tab year if ct==1 & vstatus==1 & abstracted==1 ,m matcell(foo)
mat li foo
svmat foo
egen total_alive=total(vstatus) if vstatus==1 & abstracted==1 & year==2020
fillmissing total_alive
drop if foo==.
keep foo total_alive

gen id=1
gen registry="heart"
gen category=1
gen year=2020

rename foo ct

order id registry category year ct total_alive
gen ct_percent=ct/total_alive*100
replace ct_percent=round(ct_percent,1.0)


label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

save "`datapath'\version03\2-working\addanalyses_ct" ,replace
restore


*************************************************
** Additional Analyses: % persons <70 with AMI **
*************************************************
** Requested by SF via email on 20may2022
count if age<70 & year==2020 //all cases
count if age<70 & year==2020 & abstracted==1 //cases abstracted by BNR
count if year==2020
count if year==2020 & abstracted==1

preserve
egen totcases=count(year) if year==2020
egen totabs=count(year) if year==2020 & abstracted==1
egen totagecases=count(year) if age<70 & year==2020
egen totageabs=count(year) if age<70 & year==2020 & abstracted==1
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
gen year=2020

order id registry category year totagecases totcases totagecases_percent totageabs totabs totageabs_percent

label define category_lab 1 "CT for those alive at discharge" 2 "Under age 70" ,modify
label values category category_lab
label var category "Additional Analyses Category"

save "`datapath'\version03\2-working\addanalyses_age" ,replace
restore
