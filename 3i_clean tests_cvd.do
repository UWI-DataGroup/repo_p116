** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3i_clean tests_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      20-FEB-2023
    // 	date last modified      21-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Tests form
    //  status                  Completed
    //  objective               (1) To have a cleaned 2021 cvd incidence dataset ready for analysis
	//							(2) To have a list with errors and corrections for DAs to correct data directly into CVDdb
    //  methods                 Using missing and invalid checks to correct data
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
    log using "`logpath'\3i_clean tests_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_hx", clear

count //1144

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

**********************
** Vital Signs Info **
**********************
*******************
** BP - Systolic **
*******************
** Missing
count if sysbp==. & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if sysbp==9999 //0
** Invalid range
count if sysbp<50 & sysbp>350 //0
********************
** BP - Diastolic **
********************
** Missing
count if diasbp==. & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if diasbp==9999 //0
** Invalid range
count if diasbp<20 & diasbp>250 //0
****************
** Heart Rate **
****************
** Missing
count if bpm==. & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if bpm==9999 //0
** Invalid range
count if bpm<20 & bpm>250 //0
*******************
** Blood Glucose **
*******************
** Missing (unit)
count if bgunit==. & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code (unit)
count if bgunit==88|bgunit==999|bgunit==9999 //0
** Missing (mg/dl)
count if bgmg==. & bgunit==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code (mg/dl)
count if bgmg==88|bgmg==99|bgmg==999|bgmg==9999 //0
** Invalid range (mg/dl)
count if bgmg<0 & bgmg>800 //0
** Missing (mmol/l)
count if bgmmol==. & bgunit==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code (mmol/l)
count if bgmmol==88|bgmmol==99|bgmmol==999|bgmmol==9999 //0
** Invalid range (mmol/l)
count if bgmmol<0 & bgmmol>40 //0
** Invalid (unit=mg/dl; mmol/l has a value)
count if bgunit==1 & bgmmol!=. //0
** Invalid (unit=mmol/l; mg/dl has a value)
count if bgunit==2 & bgmg!=. //0
** Invalid (unit=machine; mmol/l or mg/dl has a value)
count if bgunit==3 & (bgmg!=.|bgmmol!=.) //0
*******************
** O2 Saturation **
*******************
** Missing
count if o2sat==. & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if o2sat==9999 //0
** Invalid range
count if o2sat<50 & o2sat>100 //0


**********************
** Assessments Info **
**********************
**********************
** Any assessments? **
**********************
** Missing
count if assess==. & sd_etype==1 & tests_complete!=0 & tests_complete!=. //1 - stroke record 2309 is missing so corrected below.
** Invalid missing code
count if assess==88|assess==999|assess==9999 //0
** Invalid (assess=No/ND; assess options=Yes)
count if (assess==2|assess==99) & (assess1==1|assess2==1|assess3==1|assess4==1|assess7==1|assess8==1|assess9==1|assess10==1|assess12==1|assess14==1) //12 - corrected below
** Invalid (assess=Yes; assess options NOT=Yes)
count if assess==1 & assess1!=1 & assess2!=1 & assess3!=1 & assess4!=1 & assess7!=1 & assess8!=1 & assess9!=1 & assess10!=1 & assess12!=1 & assess14!=1 //4 - corrected below
** Invalid (assess=Yes/No; assess options all=ND)
count if assess!=99 & assess1==99 & assess2==99 & assess3==99 & assess4==99 & assess7==99 & assess8==99 & assess9==99 & assess10==99 & assess12==99 & assess14==99 //1 - corrected below
********************
** Occ. Therapist **
********************
** Missing
count if assess1==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //3 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below
** Invalid missing code
count if assess1==88|assess1==999|assess1==9999 //0
*********************
** Physiotherapist **
*********************
** Missing
count if assess2==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //2 - record 2017 has all assess1-14 blank except for assess9; record 2309 already corrected below
** Invalid missing code
count if assess2==88|assess2==999|assess2==9999 //0
**********************
** Speech Therapist **
**********************
** Missing
count if assess3==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //3 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below
** Invalid missing code
count if assess3==88|assess3==999|assess3==9999 //0
*********************
** Swallow Assess. **
*********************
** Missing
count if assess4==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //4 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess4==88|assess4==999|assess4==9999 //0
**********************
** Rehab Specialist **
**********************
** Missing
count if assess7==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //4 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess7==88|assess7==999|assess7==9999 //0
******************
** Cardiologist **
******************
** Missing
count if assess8==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //4 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess8==88|assess8==999|assess8==9999 //0
*****************
** Neurologist **
*****************
** Missing
count if assess9==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //2 - record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess9==88|assess9==999|assess9==9999 //0
******************
** Neurosurgeon **
******************
** Missing
count if assess10==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //4 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess10==88|assess10==999|assess10==9999 //0
**************************
** Malnutrition Assess. **
**************************
** Missing
count if assess12==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //4 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess12==88|assess12==999|assess12==9999 //0
**********************
** Cognitive Screen **
**********************
** Missing
count if assess14==. & assess!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //4 - record 2017 has all assess1-14 blank except for assess9; record 3214 has all assess1-14 blank except for assess2 + assess9; record 2309 already corrected below; record 3225 has all assess1-14 blank except for assess1, assess2 + assess3
** Invalid missing code
count if assess14==88|assess14==999|assess14==9999 //0




** Corrections from above checks
destring flag317 ,replace
destring flag1242 ,replace

** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace assess=99999 if record_id=="2309" //see above
replace assess1=99999 if record_id=="2017"|record_id=="3214" //see above
replace assess2=99999 if record_id=="2017" //see above
replace assess3=99999 if record_id=="2017"|record_id=="3214" //see above
replace assess4=99999 if record_id=="2017"|record_id=="3214"|record_id=="3225" //see above
replace assess7=99999 if record_id=="2017"|record_id=="3214"|record_id=="3225" //see above
replace assess8=99999 if record_id=="2017"|record_id=="3214"|record_id=="3225" //see above
replace assess10=99999 if record_id=="2017"|record_id=="3214"|record_id=="3225" //see above
replace assess12=99999 if record_id=="2017"|record_id=="3214"|record_id=="3225" //see above
replace assess14=99999 if record_id=="2017"|record_id=="3214"|record_id=="3225" //see above

replace flag317=assess if assess==2 & (assess1==1|assess2==1|assess3==1|assess4==1|assess7==1|assess8==1|assess9==1|assess10==1|assess12==1|assess14==1)
replace assess=1 if assess==2 & (assess1==1|assess2==1|assess3==1|assess4==1|assess7==1|assess8==1|assess9==1|assess10==1|assess12==1|assess14==1) //see above
replace flag1242=assess if flag317!=.

replace flag317=assess if assess==1 & assess1!=1 & assess2!=1 & assess3!=1 & assess4!=1 & assess7!=1 & assess8!=1 & assess9!=1 & assess10!=1 & assess12!=1 & assess14!=1
replace assess=2 if assess==1 & assess1!=1 & assess2!=1 & assess3!=1 & assess4!=1 & assess7!=1 & assess8!=1 & assess9!=1 & assess10!=1 & assess12!=1 & assess14!=1 //see above
replace flag1242=assess if flag317!=.

replace flag317=assess if record_id=="1807"
replace assess=99 if record_id=="1807" //see above
replace flag1242=assess if record_id=="1807"

replace assess1=. if record_id=="1807"
replace assess2=. if record_id=="1807"
replace assess3=. if record_id=="1807"
replace assess4=. if record_id=="1807"
replace assess7=. if record_id=="1807"
replace assess8=. if record_id=="1807"
replace assess9=. if record_id=="1807"
replace assess10=. if record_id=="1807"
replace assess12=. if record_id=="1807"
replace assess14=. if record_id=="1807"
//DAs don't need to update these in CVDdb as they will be erased once the other correction is performed


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

replace flagdate=sd_currentdate if flag1242!=.|record_id=="1807"


**************************
** Exam/Diagnostic Info **
**************************
*******************
** Any dx exams? **
*******************
** Missing
count if dieany==. & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if dieany==88|dieany==999|dieany==9999 //0
** Invalid (dieany=No/ND; dieany options=Yes)
count if (dieany==2|dieany==99) & (dct==1|decg==1|dmri==1|dcerangio==1|dcarangio==1|dcarus==1|decho==1|dctcorang==1|dstress==1) //3 - corrected below
** Invalid (dieany=Yes; dieany options NOT=Yes)
count if dieany==1 & dct!=1 & decg!=1 & dmri!=1 & dcerangio!=1 & dcarangio!=1 & dcarus!=1 & decho!=1 & dctcorang!=1 & dstress!=1 //1 - corrected below
** Invalid (dieany=Yes/No; dieany options all=ND)
count if dieany!=99 & dct==99 & decg==99 & dmri==99 & dcerangio==99 & dcarangio==99 & dcarus==99 & decho==99 & dctcorang==99 & dstress==99 //0
** Invalid (dieany=No/ND; how dx made=confirmed/unconfirmed by dx techniques)
count if dieany!=. & dieany!=1 & (dxtype==2|dxtype==3) //2 - for stroke record 1889 the tests form in CVDdb is completely blank/unanswered so cannot correct dxtype; record 2982 corrected below
** possibly Invalid (dieany=Yes; how dx made=clinical dx alone)
count if dieany==1 & dxtype==1 //7 - stroke record 4243 already reviewed by NS so leave as is; heart records 2263 + 4094 corrected below; 4 others are stroke records who only had ECG performed so leave as is
*******************
** CT brain scan **
*******************
** Missing
count if dct==. & dieany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if dct==88|dct==999|dct==9999 //0
** Invalid (dct=Yes; how dx made=clinical dx alone)
count if dct==1 & dxtype==1 //0
*********
** ECG **
*********
** Missing
count if decg==. & dieany!=99 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if decg==88|decg==999|decg==9999 //0
** Invalid (decg=Yes; how dx made=clinical dx alone)
count if decg==1 & dxtype==1 //7 - same records from above except heart record 2744 which is corrected below
********************
** MRI brain scan **
********************
** Missing
count if dmri==. & dieany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //1 - stroke record 2017 has blank values for several fields on this tests form
** Invalid missing code
count if dmri==88|dmri==999|dmri==9999 //0
** Invalid (dmri=Yes; how dx made=clinical dx alone)
count if dmri==1 & dxtype==1 //0
*********************
** Angio. cerebral **
*********************
** Missing
count if dcerangio==. & dieany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //1 - stroke record 2017 has blank values for several fields on this tests form
** Invalid missing code
count if dcerangio==88|dcerangio==999|dcerangio==9999 //0
** Invalid (dmri=Yes; how dx made=clinical dx alone)
count if dcerangio==1 & dxtype==1 //0
********************
** Angio. carotid **
********************
** Missing
count if dcarangio==. & dieany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //1 - stroke record 2017 has blank values for several fields on this tests form
** Invalid missing code
count if dcarangio==88|dcarangio==999|dcarangio==9999 //0
** Invalid (dmri=Yes; how dx made=clinical dx alone)
count if dcarangio==1 & dxtype==1 //0
************************
** Carotid Ultrasound **
************************
** Missing
count if dcarus==. & dieany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //1 - stroke record 2017 has blank values for several fields on this tests form
** Invalid missing code
count if dcarus==88|dcarus==999|dcarus==9999 //0
** Invalid (dmri=Yes; how dx made=clinical dx alone)
count if dcarus==1 & dxtype==1 //0
**********
** ECHO **
**********
** Missing
count if decho==. & dieany!=99 & tests_complete!=0 & tests_complete!=. //1 - stroke record 2017 has blank values for several fields on this tests form
** Invalid missing code
count if decho==88|decho==999|decho==9999 //0
** Invalid (decg=Yes; how dx made=clinical dx alone)
count if decho==1 & dxtype==1 //0
************************
** CT/Coronary Angio. **
************************
** Missing
count if dctcorang==. & dieany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if dctcorang==88|dctcorang==999|dctcorang==9999 //0
** Invalid (dmri=Yes; how dx made=clinical dx alone)
count if dctcorang==1 & dxtype==1 //0
*****************
** Stress Test **
*****************
** Missing
count if dstress==. & dieany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if dstress==88|dstress==999|dstress==9999 //0
** Invalid (dmri=Yes; how dx made=clinical dx alone)
count if dstress==1 & dxtype==1 //0

**********************
**   Other exams    **
** (Heart + Stroke) **
**********************
** Missing
count if  dieany!=. & dieany!=99 & odie==. //0
** Invalid missing code
count if odie==88|odie==999|odie==9999 //0
** Missing (other exam options=1 but other exam text blank)
****************
** Oth Exam 1 **
****************
count if odie==1 & odie1=="" //0
** Invalid (other exam options=ND/None but other exam text NOT=blank)
count if (odie==4|odie==99|odie==99999) & odie1!="" //0
** possibly Invalid (other exam=one of the exam options)
count if odie1!="" //280 - reviewed and correct
count if regexm(odie1,"scan")|regexm(odie1,"ecg")|regexm(odie1,"cardiogram")|regexm(odie1,"angiography")|regexm(odie1,"carotid")|regexm(odie1,"echo")|regexm(odie1,"stress")|regexm(odie1,"treadmill") //0
****************
** Oth Exam 2 **
****************
count if odie==2 & odie2=="" //0
** Invalid (other exam options=ND/None but other exam text NOT=blank)
count if (odie==4|odie==99|odie==99999) & odie2!="" //0
** possibly Invalid (other exam=one of the exam options)
count if odie2!="" //8 - reviewed and correct
count if regexm(odie2,"scan")|regexm(odie2,"ecg")|regexm(odie2,"cardiogram")|regexm(odie2,"angiography")|regexm(odie2,"carotid")|regexm(odie2,"echo")|regexm(odie2,"stress")|regexm(odie2,"treadmill") //0
****************
** Oth Exam 3 **
****************
count if odie==3 & odie3=="" //0
** Invalid (other exam options=ND/None but other exam text NOT=blank)
count if (odie==4|odie==99|odie==99999) & odie3!="" //0
** possibly Invalid (other exam=one of the exam options)
count if odie3!="" //0
count if regexm(odie3,"scan")|regexm(odie3,"ecg")|regexm(odie3,"cardiogram")|regexm(odie3,"angiography")|regexm(odie3,"carotid")|regexm(odie3,"echo")|regexm(odie3,"stress")|regexm(odie3,"treadmill") //0



** Corrections from above checks
destring flag328 ,replace
destring flag1253 ,replace


replace flag328=dieany if record_id=="2744"|record_id=="4178"
replace dieany=1 if record_id=="2744"|record_id=="4178" //see above
replace flag1253=dieany if record_id=="2744"|record_id=="4178"

replace flag328=dieany if record_id=="3656"
replace dieany=2 if record_id=="3656" //see above
replace flag1253=dieany if record_id=="3656"

replace dieany=1 if record_id=="2982" //dxtype + dct were corrected in the dofile '3g_clean event_cvd.do' but dieany wasn't updated so have done so now - DA won't need to correct CVDdb for this correction since it would be done when dxtype + dct were corrected from event dofile

replace flag259=dxtype if record_id=="4094"|record_id=="2263"|record_id=="2744"
replace dxtype=3 if record_id=="4094"|record_id=="2263"|record_id=="2744"
replace flag1184=dxtype if record_id=="4094"|record_id=="2263"|record_id=="2744"


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace dmri=99999 if record_id=="2017"
replace dcerangio=99999 if record_id=="2017"
replace dcarangio=99999 if record_id=="2017" //see above
replace dcarus=99999 if record_id=="2017"
replace decho=99999 if record_id=="2017"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2744"|record_id=="4178"|record_id=="3656"|record_id=="4094"|record_id=="2263"


*****************
** CT/MRI Info **
*****************
*****************
** CT/MRI Date **
*****************
** Missing
count if ct==. & sd_etype==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ct==88|ct==999|ct==9999 //0
** Invalid (ct rpt=Yes; dct=No/ND)
count if ct==1 & dct!=1 & dmri!=1 //0
** Missing date
count if doct==. & ct==1 //0
** Invalid (not 2021)
count if doct!=. & year(doct)!=2021 //3 - record 3416 is correct but 2 others corrected below
** Invalid (before DOB)
count if dob!=. & doct!=. & doct<dob //0
** possibly Invalid (before CFAdmDate)
count if doct!=. & cfadmdate!=. & doct<cfadmdate & inhosp!=1& fmcdate==. //7 - 2816 + 2910 for review by NS; 3403 DA notes CT done privately but FMC not entered; the others are correct i.e. A&E date same as CT date
** possibly Invalid (after DLC/DOD)
count if dlc!=. & doct!=. & doct>dlc //1 - stroke record 3654's CT date from merged stroke-in-evolution 2728
count if cfdod!=. & doct!=. & doct>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if doct!=. & dae!=. & doct<dae & inhosp!=1 & fmcdate==. //3 - already flagged above - pending review by NS
** possibly Invalid (after WardAdmDate)
count if doct!=. & doh!=. & doct>doh & inhosp!=1 & fmcdate==. //10 - reviewed and all correct
** Invalid (future date)
count if doct!=. & doct>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ct==1 & doct==. & doctday==99 & doctmonth==99 & doctyear==9999 //0
** possibly Invalid (oth sym date not partial but partial field not blank)
count if doct==. & doctday!=. & doctmonth!=. & doctyear!=. //0
replace doctday=. if doct==. & doctday!=. & doctmonth!=. & doctyear!=. //1 change
replace doctmonth=. if doct==. & doctmonth!=. & doctyear!=. //0 changes
replace doctyear=. if doct==. & doctyear!=. //0 changes
count if doct==. & (doctday!=. | doctmonth!=. | doctyear!=.) //0
** Invalid missing code (notified date partial fields)
count if doctday==88|doctday==999|doctday==9999 //0
count if doctmonth==88|doctmonth==999|doctmonth==9999 //0
count if doctyear==88|doctyear==99|doctyear==999 //0
** Invalid (before NotifiedDate)
count if doct!=. & ambcalld!=. & doct<ambcalld & inhosp!=1 //3 - record 2633's doct incorrect as seen clearly in reviewing Notes section of MedData; records 2816 + 2403 already flagged above
** Invalid (before AtSceneDate)
count if doct!=. & atscnd!=. & doct<atscnd & inhosp!=1 //4 - record 2165 has incorrect date for at scene so corrected below; other records already flagged above
count if dae!=. & hospd!=. & dae!=hospd //4 - records 2165 + 2450 are incorrect
** Invalid (before FromSceneDate)
count if doct!=. & frmscnd!=. & doct<frmscnd & inhosp!=1 //4 - same records already flagged above
** Invalid (before AtHospitalDate)
count if doct!=. & hospd!=. & doct<hospd & inhosp!=1 //3 - same records already flagged above
** Invalid (before EventDate)
count if doct!=. & edate!=. & doct<edate //1 - record 2816 already flagged above for review by NS
** Create variable for timing between stroke onset & CT/MRI scan
gen stime2=doct-edate
count if stime!=. & stime2!=. & stime!=stime2 //4 - records 2494 + 2623 are correct; stroke record 3654's CT date from merged stroke-in-evolution 2728 so leave as is but 2816 is pending review by NS
//list record_id edate doct stime stime2 if stime!=. & stime2!=. & stime!=stime2
count if edate!=. & doct!=. & stime==. //35
count if edate!=. & doct!=. & stime2==. //0
replace stime=stime2 //39 changes
drop stime2


** Corrections from above checks
destring flag343 ,replace
destring flag1268 ,replace
destring flag150 ,replace
destring flag1075 ,replace
destring flag117 ,replace
destring flag1042 ,replace
format flag343 flag1268 flag150 flag1075 flag117 flag1042 %dM_d,_CY


replace flag343=doct if record_id=="2212"|record_id=="2275"|record_id=="2633"
replace doct=doct-365 if record_id=="2212"|record_id=="2275"
replace doct=doct+1 if record_id=="2633"
replace flag1268=doct if record_id=="2212"|record_id=="2275"|record_id=="2633"

replace atscnd=ambcalld if record_id=="2165"
replace frmscnd=ambcalld if record_id=="2165"
//DAs do not need to correct in CVDdb as these dates were generated in dofiles ptm and event

replace flag150=hospd if record_id=="2165"
replace hospd=ambcalld if record_id=="2165"
replace flag1075=hospd if record_id=="2165"

replace flag154=hospt if record_id=="2165"
replace hospt=subinstr(hospt,"14","04",.) if record_id=="2165"
replace flag1079=hospt if record_id=="2165"

replace flag117=dae if record_id=="2450"
replace dae=ambcalld if record_id=="2450" //see above
replace flag1042=dae if record_id=="2450"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2212"|record_id=="2275"|record_id=="2633"|record_id=="2165"|record_id=="2450"

STOP
******************
** Risk Factors **
******************
***********************
** Any risk factors? **
***********************
** Missing
count if rfany==. & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if rfany==88|rfany==999|rfany==9999 //0
******************
** Tobacco use? **
******************
** Missing
count if rfany!=. & rfany!=99 & smoker==. //0
** Invalid missing code
count if smoker==88|smoker==999|smoker==9999 //0
******************
** Cholesterol? **
******************
** Missing
count if rfany!=. & rfany!=99 & hcl==. //1 - stroke record 1887 has blank/unanswered values in CVDdb so corrected below.
** Invalid missing code
count if hcl==88|hcl==999|hcl==9999 //0
*****************
** Atrial Fib? **
*****************
** Missing
count if rfany!=. & rfany!=99 & af==. //1 - stroke record 1887 has blank/unanswered values in CVDdb so corrected below.
** Invalid missing code
count if af==88|af==999|af==9999 //0
**********
** TIA? **
**********
** Missing
count if rfany!=. & rfany!=99 & sd_etype==1 & tia==. //1 - stroke record 1887 has blank/unanswered values in CVDdb so corrected below.
** Invalid missing code
count if tia==88|tia==999|tia==9999 //0
**********
** CCF? **
**********
** Missing
count if rfany!=. & rfany!=99 & ccf==. //0
** Invalid missing code
count if ccf==88|ccf==999|ccf==9999 //0
**********
** HTN? **
**********
** Missing
count if rfany!=. & rfany!=99 & htn==. //0
** Invalid missing code
count if htn==88|htn==999|htn==9999 //0
*********
** DM? **
*********
** Missing
count if rfany!=. & rfany!=99 & diab==. //0
** Invalid missing code
count if diab==88|diab==999|diab==9999 //0
**********************
** Hyperlipidaemia? **
**********************
** Missing
count if rfany!=. & rfany!=99 & hld==. //1 - stroke record 1887 has blank/unanswered values in CVDdb so corrected below.
** Invalid missing code
count if hld==88|hld==999|hld==9999 //0
**************
** Alcohol? **
**************
** Missing
count if rfany!=. & rfany!=99 & alco==. //0
** Invalid missing code
count if alco==88|alco==999|alco==9999 //0
************
** Drugs? **
************
** Missing
count if rfany!=. & rfany!=99 & drugs==. //1 - stroke record 1887 has blank/unanswered values in CVDdb so corrected below.
** Invalid missing code
count if drugs==88|drugs==999|drugs==9999 //0

**********************
**     Other RFs    **
** (Heart + Stroke) **
**********************
** Missing
count if  rfany!=. & rfany!=99 & ovrf==. //0
** Invalid missing code
count if ovrf==88|ovrf==999|ovrf==9999 //0
** Missing (other rf options=1 but other rf text blank)
**************
** Oth RF 1 **
**************
count if ovrf==1 & ovrf1=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf1!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf1!="" //107 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf1,"smoke")|regexm(ovrf1,"cholesterol")|regexm(ovrf1,"fibrill*")|regexm(ovrf1,"tia")|regexm(ovrf1,"transient")|regexm(ovrf1,"ccf")|regexm(ovrf1,"failure")|regexm(ovrf1,"htn")|regexm(ovrf1,"hypertension")|regexm(ovrf1,"dm")|regexm(ovrf1,"diab*")|regexm(ovrf1,"hyperlipid*")|regexm(ovrf1,"hld")|regexm(ovrf1,"alcohol")|regexm(ovrf1,"drug")|regexm(ovrf1,"cocaine")|regexm(ovrf1,"marijuana")) //2 - 1 correct leave as is; stroke record 3438 corrected below as drug use mentioned in ovrf1
count if sd_etype==2 & (regexm(ovrf1,"smoke")|regexm(ovrf1,"cholesterol")|regexm(ovrf1,"fibrill*")|regexm(ovrf1,"transient")|regexm(ovrf1,"ccf")|regexm(ovrf1,"failure")|regexm(ovrf1,"htn")|regexm(ovrf1,"hypertension")|regexm(ovrf1,"dm")|regexm(ovrf1,"diab*")|regexm(ovrf1,"hyperlipid*")|regexm(ovrf1,"hld")|regexm(ovrf1,"alcohol")|regexm(ovrf1,"drug")|regexm(ovrf1,"cocaine")|regexm(ovrf1,"marijuana")) //0
**************
** Oth RF 2 **
**************
count if ovrf==2 & ovrf2=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf2!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf2!="" //12 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf2,"smoke")|regexm(ovrf2,"cholesterol")|regexm(ovrf2,"fibrill*")|regexm(ovrf2,"tia")|regexm(ovrf2,"transient")|regexm(ovrf2,"ccf")|regexm(ovrf2,"failure")|regexm(ovrf2,"htn")|regexm(ovrf2,"hypertension")|regexm(ovrf2,"dm")|regexm(ovrf2,"diab*")|regexm(ovrf2,"hyperlipid*")|regexm(ovrf2,"hld")|regexm(ovrf2,"alcohol")|regexm(ovrf2,"drug")|regexm(ovrf2,"cocaine")|regexm(ovrf2,"marijuana")) //3 - all correct leave as is
count if sd_etype==2 & (regexm(ovrf2,"smoke")|regexm(ovrf2,"cholesterol")|regexm(ovrf2,"fibrill*")|regexm(ovrf2,"transient")|regexm(ovrf2,"ccf")|regexm(ovrf2,"failure")|regexm(ovrf2,"htn")|regexm(ovrf2,"hypertension")|regexm(ovrf2,"dm")|regexm(ovrf2,"diab*")|regexm(ovrf2,"hyperlipid*")|regexm(ovrf2,"hld")|regexm(ovrf2,"alcohol")|regexm(ovrf2,"drug")|regexm(ovrf2,"cocaine")|regexm(ovrf2,"marijuana")) //0
**************
** Oth RF 3 **
**************
count if ovrf==3 & ovrf3=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf3!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf3!="" //2 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf3,"smoke")|regexm(ovrf3,"cholesterol")|regexm(ovrf3,"fibrill*")|regexm(ovrf3,"tia")|regexm(ovrf3,"transient")|regexm(ovrf3,"ccf")|regexm(ovrf3,"failure")|regexm(ovrf3,"htn")|regexm(ovrf3,"hypertension")|regexm(ovrf3,"dm")|regexm(ovrf3,"diab*")|regexm(ovrf3,"hyperlipid*")|regexm(ovrf3,"hld")|regexm(ovrf3,"alcohol")|regexm(ovrf3,"drug")|regexm(ovrf3,"cocaine")|regexm(ovrf3,"marijuana")) //0
count if sd_etype==2 & (regexm(ovrf3,"smoke")|regexm(ovrf3,"cholesterol")|regexm(ovrf3,"fibrill*")|regexm(ovrf3,"transient")|regexm(ovrf3,"ccf")|regexm(ovrf3,"failure")|regexm(ovrf3,"htn")|regexm(ovrf3,"hypertension")|regexm(ovrf3,"dm")|regexm(ovrf3,"diab*")|regexm(ovrf3,"hyperlipid*")|regexm(ovrf3,"hld")|regexm(ovrf3,"alcohol")|regexm(ovrf3,"drug")|regexm(ovrf3,"cocaine")|regexm(ovrf3,"marijuana")) //0
**************
** Oth RF 4 **
**************
count if ovrf==4 & ovrf4=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf4!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf4!="" //0 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf4,"smoke")|regexm(ovrf4,"cholesterol")|regexm(ovrf4,"fibrill*")|regexm(ovrf4,"tia")|regexm(ovrf4,"transient")|regexm(ovrf4,"ccf")|regexm(ovrf4,"failure")|regexm(ovrf4,"htn")|regexm(ovrf4,"hypertension")|regexm(ovrf4,"dm")|regexm(ovrf4,"diab*")|regexm(ovrf4,"hyperlipid*")|regexm(ovrf4,"hld")|regexm(ovrf4,"alcohol")|regexm(ovrf4,"drug")|regexm(ovrf4,"cocaine")|regexm(ovrf4,"marijuana")) //0
count if sd_etype==2 & (regexm(ovrf4,"smoke")|regexm(ovrf4,"cholesterol")|regexm(ovrf4,"fibrill*")|regexm(ovrf4,"transient")|regexm(ovrf4,"ccf")|regexm(ovrf4,"failure")|regexm(ovrf4,"htn")|regexm(ovrf4,"hypertension")|regexm(ovrf4,"dm")|regexm(ovrf4,"diab*")|regexm(ovrf4,"hyperlipid*")|regexm(ovrf4,"hld")|regexm(ovrf4,"alcohol")|regexm(ovrf4,"drug")|regexm(ovrf4,"cocaine")|regexm(ovrf4,"marijuana")) //0




** Corrections from above checks
destring flag293 ,replace
destring flag1218 ,replace
destring flag303 ,replace
destring flag1228 ,replace

** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace hcl=99999 if record_id=="1887" //see above
replace af=99999 if record_id=="1887" //see above
replace tia=99999 if record_id=="1887" //see above
replace hld=99999 if record_id=="1887" //see above
replace drugs=99999 if record_id=="1887" //see above

replace flag293=rfany if record_id=="3438"
replace rfany=1 if record_id=="3438" //see above
replace flag1218=rfany if record_id=="3438"

replace flag303=drugs if record_id=="3438"
replace drugs=1 if record_id=="3438" //see above
replace flag1228=drugs if record_id=="3438"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
//drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

gen flagdate=sd_currentdate if record_id=="1887"|record_id=="3438"

/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
//format flagdate flag45 flag970  %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag293 flag303 if ///
		(flag293!=. | flag303!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_HX1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1218 flag1228 if ///
		 (flag1218!=. | flag1228!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_HX1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_tests" ,replace