** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3i_clean tests_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      20-FEB-2023
    // 	date last modified      23-FEB-2023
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
count if dieany==1 & dct!=1 & decg!=1 & dmri!=1 & dcerangio!=1 & dcarangio!=1 & dcarus!=1 & decho!=1 & dctcorang!=1 & dstress!=1 & ovrf>4 //1 - corrected below
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
count if doct!=. & cfadmdate!=. & doct<cfadmdate & inhosp!=1 & fmcdate==. //7 - 2816 + 2910 for review by NS; 3403 DA notes CT done privately but FMC not entered; the others are correct i.e. A&E date same as CT date
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
** possibly Invalid (CT/MRI date not partial but partial field not blank)
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

**************************
** CT/MRI Features Info **
**************************
*******************
** Any features? **
*******************
** Missing
count if ctfeat==. & ct==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ctfeat==88|ctfeat==999|ctfeat==9999 //0
** Invalid (features=Yes/No; Infarct/SAH/ICH=ND)
count if ctfeat!=. & ctfeat<3 & ctinfarct==99 & ctsubhaem==99 & ctinthaem==99 //2 - records 2015 + 3110 corrected below
** Invalid (features=Yes; Infarct/SAH/ICH=No/ND)
count if ctfeat==1 & (ctinfarct==2|ctinfarct==99) & (ctsubhaem==2|ctsubhaem==99) & (ctinthaem==2|ctinthaem==99) //10 - all corrected below
** Invalid (features=No; Infarct/SAH/ICH=Yes)
count if ctfeat==2 & (ctinfarct==1|ctsubhaem==1|ctinthaem==1) //3 - all corrected below
**************
** Infarct? **
**************
** Missing
count if ctinfarct==. & ctfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ctinfarct==88|ctinfarct==999|ctinfarct==9999 //0
** possibly Invalid (infarct=Yes; stroke type NOT=Ischaemic)
count if ctinfarct==1 & stype!=1 //4 - record 1870 for NS to review; other 3 are correct
** possibly Invalid (infarct=No; stroke type=Ischaemic)
count if ctinfarct==2 & stype==1 //117 - reviewed and will assume are correct as don't have access to CT report and ischaemic strokes can be a clinical dx i.e. infarct not seen on CT but still classified as ischaemic.
** possibly Invalid (infarct=Yes; dxtype NOT=confirmed by dx techniques)
count if ctinfarct==1 & dxtype!=2 & dxtype!=3 //0
**********
** SAH? **
**********
** Missing
count if ctsubhaem==. & ctfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ctsubhaem==88|ctsubhaem==999|ctsubhaem==9999 //0
** possibly Invalid (SAH=Yes; stroke type NOT=SAH)
count if ctsubhaem==1 & stype!=3 //4 - records 2278, 2612, 3225 + 4111 for NS to review
** possibly Invalid (SAH=No; stroke type=SAH)
count if ctsubhaem==2 & stype==3 //0
** possibly Invalid (SAH=Yes; dxtype NOT=confirmed by dx techniques)
count if ctsubhaem==1 & dxtype!=2 & dxtype!=3 //1 - record 4111, it's correct as confirmed by medical autopsy
**********
** ICH? **
**********
** Missing
count if ctinthaem==. & ctfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ctinthaem==88|ctinthaem==999|ctinthaem==9999 //0
** possibly Invalid (ICH=Yes; stroke type NOT=ICH)
count if ctinthaem==1 & stype!=2 //3 - record 1808 for NS to review; other 2 are correct
** possibly Invalid (ICH=No; stroke type=ICH)
count if ctinthaem==2 & stype==2 //0
** possibly Invalid (ICH=Yes; dxtype NOT=confirmed by dx techniques)
count if ctinthaem==1 & dxtype!=2 & dxtype!=3 //2 - records 1808 + 4111, they're correct as confirmed by medical autopsy




** Corrections from above checks
destring flag343 ,replace
destring flag1268 ,replace
destring flag150 ,replace
destring flag1075 ,replace
destring flag117 ,replace
destring flag1042 ,replace
destring flag348 ,replace
destring flag1273 ,replace
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

replace flag348=ctfeat if record_id=="2015"|record_id=="3110"|record_id=="1916"|record_id=="2060"|record_id=="2127"|record_id=="2252"|record_id=="2334"|record_id=="2365"|record_id=="2726"|record_id=="3169"|record_id=="2302"|record_id=="3134"|record_id=="3281"
replace ctfeat=99 if record_id=="2015"|record_id=="3110" //see above
replace ctfeat=2 if record_id=="1916"|record_id=="2060"|record_id=="2127"|record_id=="2252"|record_id=="2334"|record_id=="2365"|record_id=="2726"|record_id=="3169" //see above
replace ctfeat=1 if record_id=="2302"|record_id=="3134"|record_id=="3281" //see above
replace flag1273=ctfeat if record_id=="2015"|record_id=="3110"|record_id=="1916"|record_id=="2060"|record_id=="2127"|record_id=="2252"|record_id=="2334"|record_id=="2365"|record_id=="2726"|record_id=="3169"|record_id=="2302"|record_id=="3134"|record_id=="3281"

replace ctinfarct=. if record_id=="2015"|record_id=="3110"
replace ctsubhaem=. if record_id=="2015"|record_id=="3110"
replace ctinthaem=. if record_id=="2015"|record_id=="3110"
//DAs do not need to correct in CVDdb as these dates were generated in dofiles ptm and event

replace flag257=stype if record_id=="2278"|record_id=="2612"
replace stype=3 if record_id=="2278"|record_id=="2612"
replace flag1182=stype if record_id=="2278"|record_id=="2612"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2212"|record_id=="2275"|record_id=="2633"|record_id=="2165"|record_id=="2450"|record_id=="2015"|record_id=="3110"|record_id=="1916"|record_id=="2060"|record_id=="2127"|record_id=="2252"|record_id=="2334"|record_id=="2365"|record_id=="2726"|record_id=="3169"|record_id=="2302"|record_id=="3134"|record_id=="3281"|record_id=="2278"|record_id=="2612"


**************************
** Cardiac Enzymes Info **
**************************
*****************
** CK-MB done? **
*****************
** Missing
count if ckmbdone==. & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ckmbdone==88|ckmbdone==999|ckmbdone==9999 //0
** possibly Invalid (test=Yes; dxtype NOT=confirmed by dx techniques)
count if ckmbdone==1 & dxtype==1 //0
***************
** AST done? **
***************
** Missing
count if astdone==. & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if astdone==88|astdone==999|astdone==9999 //0
** possibly Invalid (test=Yes; dxtype NOT=confirmed by dx techniques)
count if astdone==1 & dxtype==1 //0
********************
** Troponin done? **
********************
** Missing
count if tropdone==. & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tropdone==88|tropdone==999|tropdone==9999 //0
** possibly Invalid (test=Yes; dxtype NOT=confirmed by dx techniques)
count if tropdone==1 & dxtype==1 //0
*********************************
** Troponin done in Community? **
*********************************
** Missing
count if tropcomm==. & sourcetype==2 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tropcomm==88|tropcomm==999|tropcomm==9999 //0
** possibly Invalid (test=Yes; dxtype NOT=confirmed by dx techniques)
count if tropcomm==1 & dxtype==1 //0

*******************
** Troponin Date **
*******************
** Missing date
count if tropd==. & tropdone==1 //9 - entered as 99 in CVDdb
** Invalid (not 2021)
count if tropd!=. & year(tropd)!=2021 //1 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & tropd!=. & tropd<dob //0
** possibly Invalid (before CFAdmDate)
count if tropd!=. & cfadmdate!=. & tropd<cfadmdate & inhosp!=1 & fmcdate==. //1 - 3220 for review by NS
** possibly Invalid (after DLC/DOD)
count if dlc!=. & tropd!=. & tropd>dlc //0
count if cfdod!=. & tropd!=. & tropd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if tropd!=. & dae!=. & tropd<dae & inhosp!=1 & fmcdate==. //1 - already flagged above - pending review by NS
** possibly Invalid (after WardAdmDate)
count if tropd!=. & doh!=. & tropd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if tropd!=. & tropd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if tropdone==1 & tropd==. & tropdday==99 & tropdmonth==99 & tropdyear==9999 //0
** possibly Invalid (trop date not partial but partial field not blank)
count if tropd==. & tropdday!=. & tropdmonth!=. & tropdyear!=. //0
replace tropdday=. if tropd==. & tropdday!=. & tropdmonth!=. & tropdyear!=. //0 changes
replace tropdmonth=. if tropd==. & tropdmonth!=. & tropdyear!=. //0 changes
replace tropdyear=. if tropd==. & tropdyear!=. //0 changes
count if tropd==. & (tropdday!=. | tropdmonth!=. | tropdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if tropdday==88|tropdday==999|tropdday==9999 //0
count if tropdmonth==88|tropdmonth==999|tropdmonth==9999 //0
count if tropdyear==88|tropdyear==99|tropdyear==999 //0
** Invalid (before NotifiedDate)
count if tropd!=. & ambcalld!=. & tropd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if tropd!=. & atscnd!=. & tropd<atscnd & inhosp!=1 //1 - record 3030 correct as trop done at SCMC before arrival to A&E by ambulance
** Invalid (before FromSceneDate)
count if tropd!=. & frmscnd!=. & tropd<frmscnd & inhosp!=1 //1 - same record already flagged above
** Invalid (before AtHospitalDate)
count if tropd!=. & hospd!=. & tropd<hospd & inhosp!=1 //1 - same record already flagged above
** Invalid (before EventDate)
count if tropd!=. & edate!=. & tropd<edate //1 - record 2865 for NS to review
** Missing time
count if tropt=="" & tropdone==1 //0
** Invalid (time format)
count if tropt!="" & tropt!="88" & tropt!="99" & (length(tropt)<5|length(tropt)>5) //0
count if tropt!="" & tropt!="88" & tropt!="99" & !strmatch(strupper(tropt), "*:*") //0
generate byte non_numeric_tropt = indexnot(tropt, "0123456789.-:")
count if non_numeric_tropt //0
** Invalid missing code
count if tropt=="999"|tropt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if tropt=="88" & troptampm==. //0
** Invalid (trop time before notified time)
count if tropt!="" & tropt!="99" & ambcallt!="" & ambcallt!="99" & tropt<ambcallt //1 - record 2897 correct as trop done at SCMC prior to A&E visit
** Invalid (trop time before time at scene)
count if tropt!="" & tropt!="99" & atscnt!="" & atscnt!="99" & tropt<atscnt //2 - same record as above + record 2064: correct as trop done at SCMC prior to A&E visit
** Invalid (trop time before time from scene)
count if tropt!="" & tropt!="99" & frmscnt!="" & frmscnt!="99" & tropt<frmscnt //2 - same records as above
** Invalid (trop time before time at hospital)
count if tropt!="" & tropt!="99" & hospt!="" & hospt!="99" & tropt<hospt //2 - same records as above
** Invalid (trop time before event time)
count if tropt!="" & tropt!="99" & etime!="" & etime!="99" & tropt<etime //1 - record 3316 for NS to review
** Invalid missing code
count if troptampm==88|troptampm==99|troptampm==999|troptampm==9999 //0

**********************
** Type of Troponin **
**********************
** Missing
count if troptype==. & tropdone==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if troptype==88|troptype==999|troptype==9999 //0
************************
** How many troponin? **
************************
** Missing
count if tropres==. & tropdone==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tropres==88|tropres==99|tropres==999|tropres==9999 //0
** Invalid (how many trop=1; result 2 NOT blank)
count if tropres==1 & trop2res!=. //0
************************
** Result 1: Troponin **
************************
** Missing
count if trop1res==. & tropres==1 & tests_complete!=0 & tests_complete!=. //0
** Missing
count if trop1res==. & trop1res!=99 & tropres!=. & tropres>1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if trop1res==88|trop1res==999|trop1res==9999 //0
************************
** Result 2: Troponin **
************************
** Missing
count if trop2res==. & tropres==2 & tests_complete!=0 & tests_complete!=. //0
** Missing
count if trop2res==. & trop2res!=99 & tropres!=. & tropres>1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if trop2res==88|trop2res==999|trop2res==9999 //0
** possibly Invalid (trop 2 res lower than trop 1 res)
count if trop1res!=. & trop1res!=99 & trop2res!=. & trop2res!=99 & trop2res<trop1res //31 - ask NS to review



** Corrections from above checks
destring flag267 ,replace
destring flag1192 ,replace
format flag267 flag1192 %dM_d,_CY


replace flag267=edate if record_id=="2865"
replace edate=dae if record_id=="2865" //see above
replace flag1192=edate if record_id=="2865"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2865"


**************
** ECG Info **
**************
*****************
** ECG report? **
*****************
** Missing
count if ecg==. & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecg==88|ecg==999|ecg==9999 //0
** possibly Invalid (ecg=Yes; decg=No/ND)
count if ecg==1 & (decg==2|decg==99) //0
** possibly Invalid (test=Yes; dxtype NOT=confirmed by dx techniques)
count if ecg==1 & dxtype==1 //0

**************
** ECG Date **
**************
** Missing date
count if ecgd==. & ecg==1 //3 - entered as 99 in CVDdb
** Invalid (not 2021)
count if ecgd!=. & year(ecgd)!=2021 //1 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & ecgd!=. & ecgd<dob //0
** possibly Invalid (before CFAdmDate)
count if ecgd!=. & cfadmdate!=. & ecgd<cfadmdate & inhosp!=1 & fmcdate==. //1 - 3220 for review by NS
** possibly Invalid (after DLC/DOD)
count if dlc!=. & ecgd!=. & ecgd>dlc //1 - record 2555 corrected below
count if cfdod!=. & ecgd!=. & ecgd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if ecgd!=. & dae!=. & ecgd<dae & inhosp!=1 & fmcdate==. //1 - already flagged above - pending review by NS
** possibly Invalid (after WardAdmDate)
count if ecgd!=. & doh!=. & ecgd>doh & inhosp!=1 & fmcdate==. //2 - record 2555 already corrected; record 3318 for NS to review
** Invalid (future date)
count if ecgd!=. & ecgd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ecg==1 & ecgd==. & ecgdday==99 & ecgdmonth==99 & ecgdyear==9999 //0
** possibly Invalid (oth sym date not partial but partial field not blank)
count if ecgd==. & ecgdday!=. & ecgdmonth!=. & ecgdyear!=. //0
replace ecgdday=. if ecgd==. & ecgdday!=. & ecgdmonth!=. & ecgdyear!=. //0 changes
replace ecgdmonth=. if ecgd==. & ecgdmonth!=. & ecgdyear!=. //0 changes
replace ecgdyear=. if ecgd==. & ecgdyear!=. //0 changes
count if ecgd==. & (ecgdday!=. | ecgdmonth!=. | ecgdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if ecgdday==88|ecgdday==999|ecgdday==9999 //0
count if ecgdmonth==88|ecgdmonth==999|ecgdmonth==9999 //0
count if ecgdyear==88|ecgdyear==99|ecgdyear==999 //0
** Invalid (before NotifiedDate)
count if ecgd!=. & ambcalld!=. & ecgd<ambcalld & inhosp!=1 //2 - records 2432 + 2966: correct as ecg done at SCMC prior to A&E visit
** Invalid (before AtSceneDate)
count if ecgd!=. & atscnd!=. & ecgd<atscnd & inhosp!=1 //3 - records 2432, 2966 + 3030 correct as ecg done at SCMC before arrival to A&E by ambulance
** Invalid (before FromSceneDate)
count if ecgd!=. & frmscnd!=. & ecgd<frmscnd & inhosp!=1 //3 - same records already flagged above
** Invalid (before AtHospitalDate)
count if ecgd!=. & hospd!=. & ecgd<hospd & inhosp!=1 //3 - same records already flagged above
** Invalid (before EventDate)
count if ecgd!=. & edate!=. & ecgd<edate & inhosp!=1 //0
** Missing time
count if ecgt=="" & ecg==1 //0
** Invalid (time format)
count if ecgt!="" & ecgt!="88" & ecgt!="99" & (length(ecgt)<5|length(ecgt)>5) //0
count if ecgt!="" & ecgt!="88" & ecgt!="99" & !strmatch(strupper(ecgt), "*:*") //0
generate byte non_numeric_ecgt = indexnot(ecgt, "0123456789.-:")
count if non_numeric_ecgt //0
** Invalid missing code
count if ecgt=="999"|ecgt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if ecgt=="88" & ecgtampm==. //0
** Invalid (ecg time before notified time)
count if ecgt!="" & ecgt!="99" & ambcallt!="" & ambcallt!="99" & fmcdate==. & ecgd<ambcalld & ecgt<ambcallt //0
** Invalid (ecg time before time at scene)
count if ecgt!="" & ecgt!="99" & atscnt!="" & atscnt!="99" & fmcdate==. & ecgd<atscnd & ecgt<atscnt //0
** Invalid (ecg time before time from scene)
count if ecgt!="" & ecgt!="99" & frmscnt!="" & frmscnt!="99" & fmcdate==. & ecgd<frmscnd & ecgt<frmscnt //0
** Invalid (ecg time before time at hospital)
count if ecgt!="" & ecgt!="99" & hospt!="" & hospt!="99" & fmcdate==. & ecgd<hospd & ecgt<hospt //0
** Invalid (ecg time before event time)
count if ecgt!="" & ecgt!="99" & etime!="" & etime!="99" & ecgd<edate & ecgt<etime //0
** Invalid missing code
count if ecgtampm==88|ecgtampm==99|ecgtampm==999|ecgtampm==9999 //0
******************
** serial ECGs? **
******************
** Missing
count if ecgs==. & ecg==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgs==88|ecgs==999|ecgs==9999 //0
** possibly Invalid (ecgs=Yes; decg=No/ND)
count if ecgs==1 & (decg==2|decg==99) //0
** possibly Invalid (test=Yes; dxtype NOT=confirmed by dx techniques)
count if ecgs==1 & dxtype==1 //0

**********************
** ECG Regions Info **
**********************
******************
** Any regions? **
******************
** Missing
count if ischecg==. & ecg==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ischecg==88|ischecg==999|ischecg==9999 //0
** Invalid (ischecg=No/ND; ischecg options=Yes)
count if (ischecg==2|ischecg==99) & (ecgantero==1|ecgrv==1|ecgant==1|ecglat==1|ecgpost==1|ecginf==1|ecgsep==1|ecgnd==1) //0
** Invalid (ischecg=Yes; ischecg options NOT=Yes)
count if ischecg==1 & ecgantero!=1 & ecgrv!=1 & ecgant!=1 & ecglat!=1 & ecgpost!=1 & ecginf!=1 & ecgsep!=1 & ecgnd!=1 & oecg>4 //0
** Invalid (ischecg=Yes/No; ischecg options all=ND)
count if ischecg!=99 & ecgantero==99 & ecgrv==99 & ecgant==99 & ecglat==99 & ecgpost==99 & ecginf==99 & ecgsep==99 & ecgnd==99 //0
** Invalid (ischecg=ND; ischecg options NOT blank)
count if ischecg==99 & ecgantero!=. & ecgrv!=. & ecgant!=. & ecglat!=. & ecgpost!=. & ecginf!=. & ecgsep!=. & ecgnd!=. //0
*************
** Regions **
*************
** Missing
count if ecgantero==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecgrv==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecgant==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecglat==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecgpost==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecginf==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecgsep==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
count if ecgnd==. & ischecg!=. & ischecg!=99 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgantero==88|ecgantero==999|ecgantero==9999 //0
count if ecgrv==88|ecgrv==999|ecgrv==9999 //0
count if ecgant==88|ecgant==999|ecgant==9999 //0
count if ecglat==88|ecglat==999|ecglat==9999 //0
count if ecgpost==88|ecgpost==999|ecgpost==9999 //0
count if ecginf==88|ecginf==999|ecginf==9999 //0
count if ecgsep==88|ecgsep==999|ecgsep==9999 //0
count if ecgnd==88|ecgnd==999|ecgnd==9999 //0

*******************
** Other regions **
*******************
** Missing
count if ischecg!=. & ischecg!=99 & oecg==. //0
** Invalid missing code
count if oecg==88|oecg==999|oecg==9999 //0
** Missing (other exam options=1 but other exam text blank)

tab oecg1 ,m
tab oecg2 ,m
tab oecg3 ,m
tab oecg4 ,m
//all are blank for 2021 so they're variable type is byte so below code won't work unless they have values in them so below code disabled for now
/*
***************
** Oth ECG 1 **
***************
count if oecg==1 & oecg1=="" //0
** Invalid (other ECGECG options=ND/None but other ECG text NOT=blank)
count if (oecg==5|oecg==99|oecg==99999) & oecg1!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecg1!="" //280 - reviewed and correct
count if regexm(oecg1,"antero")|regexm(oecg1,"lateral")|regexm(oecg1,"ventricle")|regexm(oecg1,"anterior")|regexm(oecg1,"posterior")|regexm(oecg1,"inferior")|regexm(oecg1,"septal")|regexm(oecg1,"determined") //0
***************
** Oth ECG 2 **
***************
count if oecg==2 & oecg2=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecg==5|oecg==99|oecg==99999) & oecg2!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecg2!="" //280 - reviewed and correct
count if regexm(oecg2,"antero")|regexm(oecg2,"lateral")|regexm(oecg2,"ventricle")|regexm(oecg2,"anterior")|regexm(oecg2,"posterior")|regexm(oecg2,"inferior")|regexm(oecg2,"septal")|regexm(oecg2,"determined") //0
***************
** Oth ECG 3 **
***************
count if oecg==3 & oecg3=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecg==5|oecg==99|oecg==99999) & oecg3!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecg3!="" //280 - reviewed and correct
count if regexm(oecg3,"antero")|regexm(oecg3,"lateral")|regexm(oecg3,"ventricle")|regexm(oecg3,"anterior")|regexm(oecg3,"posterior")|regexm(oecg3,"inferior")|regexm(oecg3,"septal")|regexm(oecg3,"determined") //0
***************
** Oth ECG 3 **
***************
count if oecg==4 & oecg4=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecg==5|oecg==99|oecg==99999) & oecg4!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecg4!="" //280 - reviewed and correct
count if regexm(oecg4,"antero")|regexm(oecg4,"lateral")|regexm(oecg4,"ventricle")|regexm(oecg4,"anterior")|regexm(oecg4,"posterior")|regexm(oecg4,"inferior")|regexm(oecg4,"septal")|regexm(oecg4,"determined") //0
*/

*******************
** Any features? **
*******************
** Missing
count if ecgfeat==. & ecg==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgfeat==88|ecgfeat==999|ecgfeat==9999 //0
** Invalid (features=Yes/No; options=ND)
count if ecgfeat!=. & ecgfeat<3 & ecglbbb==99 & ecgaf==99 & ecgste==99 & ecgstd==99 & ecgpqw==99 & ecgtwv==99 & ecgnor==99 & ecgnorsin==99 & ecgomi==99 & ecgnstt==99 & ecglvh==99 & oecgfeat>4 //0
** Invalid (features=Yes; options=No/ND)
count if ecgfeat==1 & (ecglbbb==2|ecglbbb==99) & (ecgaf==2|ecgaf==99) & (ecgste==2|ecgste==99) & (ecgstd==2|ecgstd==99) & (ecgpqw==2|ecgpqw==99) & (ecgtwv==2|ecgtwv==99) & (ecgnor==2|ecgnor==99) & (ecgnorsin==2|ecgnorsin==99) & (ecgomi==2|ecgomi==99) & (ecgnstt==2|ecgnstt==99) & (ecglvh==2|ecglvh==99) & oecgfeat>4 //0
** Invalid (features=Yes; features options NOT=Yes)
count if ecgfeat==1 & ecglbbb!=1 & ecgaf!=1 & ecgste!=1 & ecgstd!=1 & ecgpqw!=1 & ecgtwv!=1 & ecgnor!=1 & ecgnorsin!=1 & ecgomi!=1 & ecgnstt!=1 & ecglvh!=1 & oecgfeat>4 //0
** Invalid (features=No; options=Yes)
count if ecgfeat==2 & (ecglbbb==1|ecgaf==1|ecgste==1|ecgstd==1|ecgpqw==1|ecgtwv==1|ecgnor==1|ecgnorsin==1|ecgomi==1|ecgnstt==1|ecglvh==1) //0
** possibly Invalid (features=Yes; dxtype NOT=confirmed by dx techniques)
count if ecgfeat==1 & dxtype!=2 & dxtype!=3 //7 - correct as confirmed by medical autopsy
**********
** LBBB **
**********
** Missing
count if ecglbbb==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecglbbb==88|ecglbbb==999|ecglbbb==9999 //0
****************
** Atrial Fib **
****************
** Missing
count if ecgaf==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgaf==88|ecgaf==999|ecgaf==9999 //0
******************
** ST Elevation **
******************
** Missing
count if ecgste==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgste==88|ecgste==999|ecgste==9999 //0
** possibly Invalid (STE=Yes; heart type NOT=STEMI)
count if ecgste==1 & htype!=1 //21 - for NS to review
** possibly Invalid (STE=No; heart type=STEMI)
count if ecgste==2 & htype==1 //0
*******************
** ST Depression **
*******************
** Missing
count if ecgstd==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgstd==88|ecgstd==999|ecgstd==9999 //0
** possibly Invalid (STD=Yes; STE not=Yes; heart type NOT=NSTEMI)
count if ecgstd==1 & ecgste!=1 & htype!=2 //5 - for NS to review
** possibly Invalid (STD=No; heart type=NSTEMI)
count if ecgstd==2 & htype==2 //9 - some have t-wave, pq-wave etc. not sure we can have such a specific check for NSTEMIs
******************
** Path Q waves **
******************
** Missing
count if ecgpqw==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgpqw==88|ecgpqw==999|ecgpqw==9999 //0
**********************
** T wave inversion **
**********************
** Missing
count if ecgtwv==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgtwv==88|ecgtwv==999|ecgtwv==9999 //0
****************
** Normal ECG **
****************
** Missing
count if ecgnor==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgnor==88|ecgnor==999|ecgnor==9999 //0
****************
** Nor. sinus **
****************
** Missing
count if ecgnorsin==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgnorsin==88|ecgnorsin==999|ecgnorsin==9999 //0
************
** Old MI **
************
** Missing
count if ecgomi==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgomi==88|ecgomi==999|ecgomi==9999 //0
***********************
** N-S STT-T changes **
***********************
** Missing
count if ecgnstt==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecgnstt==88|ecgnstt==999|ecgnstt==9999 //0
*********
** LVH **
*********
** Missing
count if ecglvh==. & ecgfeat==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if ecglvh==88|ecglvh==999|ecglvh==9999 //0

********************
** Other features **
********************
** Missing
count if ecgfeat==1 & oecgfeat==. //0
** Invalid missing code
count if oecgfeat==88|oecgfeat==999|oecgfeat==9999 //0
** Missing (other ECG options=1 but other ECG text blank)
***************
** Oth ECG 1 **
***************
count if oecgfeat==1 & oecgfeat1=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecgfeat==5|oecgfeat==99|oecgfeat==99999) & oecgfeat1!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecgfeat1!="" //46 - reviewed and correct
count if regexm(oecgfeat1,"lbbb")|regexm(oecgfeat1,"bundle")|regexm(oecgfeat1,"fibrill*")|regexm(oecgfeat1,"elevation")|regexm(oecgfeat1,"depression")|regexm(oecgfeat1,"waves")|regexm(oecgfeat1,"inversion")|regexm(oecgfeat1,"normal")|regexm(oecgfeat1,"old")|regexm(oecgfeat1,"specific")|regexm(oecgfeat1,"lvh")|regexm(oecgfeat1,"hypertrophy") //1 - record 1940 it's correct
***************
** Oth ECG 2 **
***************
count if oecgfeat==2 & oecgfeat2=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecgfeat==5|oecgfeat==99|oecgfeat==99999) & oecgfeat2!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecgfeat2!="" //15 - reviewed and correct
count if regexm(oecgfeat2,"lbbb")|regexm(oecgfeat2,"bundle")|regexm(oecgfeat2,"fibrill*")|regexm(oecgfeat2,"elevation")|regexm(oecgfeat2,"depression")|regexm(oecgfeat2,"waves")|regexm(oecgfeat2,"inversion")|regexm(oecgfeat2,"normal")|regexm(oecgfeat2,"old")|regexm(oecgfeat2,"specific")|regexm(oecgfeat2,"lvh")|regexm(oecgfeat2,"hypertrophy") //1 - record 3124 it's correct
***************
** Oth ECG 3 **
***************
count if oecgfeat==3 & oecgfeat3=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecgfeat==5|oecgfeat==99|oecgfeat==99999) & oecgfeat3!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecgfeat3!="" //6 - reviewed and correct
count if regexm(oecgfeat3,"lbbb")|regexm(oecgfeat3,"bundle")|regexm(oecgfeat3,"fibrill*")|regexm(oecgfeat3,"elevation")|regexm(oecgfeat3,"depression")|regexm(oecgfeat3,"waves")|regexm(oecgfeat3,"inversion")|regexm(oecgfeat3,"normal")|regexm(oecgfeat3,"old")|regexm(oecgfeat3,"specific")|regexm(oecgfeat3,"lvh")|regexm(oecgfeat3,"hypertrophy") //1 - record 4175 it's correct
***************
** Oth ECG 4 **
***************
count if oecgfeat==4 & oecgfeat4=="" //0
** Invalid (other ECG options=ND/None but other ECG text NOT=blank)
count if (oecgfeat==5|oecgfeat==99|oecgfeat==99999) & oecgfeat4!="" //0
** possibly Invalid (other ECG=one of the ECG options)
count if oecgfeat4!="" //1 - reviewed and correct
count if regexm(oecgfeat4,"lbbb")|regexm(oecgfeat4,"bundle")|regexm(oecgfeat4,"fibrill*")|regexm(oecgfeat4,"elevation")|regexm(oecgfeat4,"depression")|regexm(oecgfeat4,"waves")|regexm(oecgfeat4,"inversion")|regexm(oecgfeat4,"normal")|regexm(oecgfeat4,"old")|regexm(oecgfeat4,"specific")|regexm(oecgfeat4,"lvh")|regexm(oecgfeat4,"hypertrophy") //0
 
          
 
 
** Corrections from above checks
destring flag367 ,replace
destring flag1292 ,replace
format flag367 flag1292 %dM_d,_CY


replace flag367=ecgd if record_id=="2555"|record_id=="3318"
replace ecgd=dae if record_id=="2555" //see above
replace ecgd=doh if record_id=="3318" //see above
replace flag1292=ecgd if record_id=="2555"|record_id=="3318"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2555"|record_id=="3318"


**********************
** Therapeutic Info **
**********************
************************
** Any interventions? **
************************
** Missing
count if tiany==. & tests_complete!=0 & tests_complete!=. //2 - corrected below
** Invalid missing code
count if tiany==88|tiany==999|tiany==9999 //0
** Invalid (tiany=No/ND; tiany options=Yes)
count if (tiany==2|tiany==99) & (tppv==1|tnippv==1|tdefib==1|tcpr==1|tmech==1|tctcorang==1|tpacetemp==1|tcath==1|tdhemi==1|tvdrain==1) //0
** Invalid (tiany=Yes; tiany options NOT=Yes)
count if tiany==1 & tppv!=1 & tnippv!=1 & tdefib!=1 & tcpr!=1 & tmech!=1 & tctcorang!=1 & tpacetemp!=1 & tcath!=1 & tdhemi!=1 & tvdrain!=1 & oti>3 //0
** Invalid (tiany=Yes/No; tiany options all=ND)
count if tiany!=99 & tppv==99 & tnippv==99 & tdefib==99 & tcpr==99 & tmech==99 & tctcorang==99 & tpacetemp==99 & tcath==99 & tdhemi==99 & tvdrain==99 //0
********************
** Invasive vent. **
********************
** Missing
count if tppv==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tppv==88|tppv==999|tppv==9999 //0
************************
** Non-invasive vent. **
************************
** Missing
count if tnippv==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tnippv==88|tnippv==999|tnippv==9999 //0
****************
** Defibrill. **
****************
** Missing
count if tdefib==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tdefib==88|tdefib==999|tdefib==9999 //0
** Invalid (resus on event form=Yes; defibrill=No/ND)
count if resus==1 & tdefib!=1 //5 - records 2205 + 4174 have CPR selected as the intervention; 3 corrected below in CPR
*********
** CPR **
*********
** Missing
count if tcpr==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tcpr==88|tcpr==999|tcpr==9999 //0
** Invalid (resus on event form=Yes; CPR=No/ND)
count if resus==1 & tcpr!=1 //3 - same records already flagged above; record 2920 was confimred but not fully abs so leave as is; 2 corrected below
************************
** Mech. Cir. support **
************************
** Missing
count if tmech==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tmech==88|tmech==999|tmech==9999 //0
*************************
** CT/Cor. Angioplasty **
*************************
** Missing
count if tctcorang==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tctcorang==88|tctcorang==999|tctcorang==9999 //0
*********************
** Temp. pacemaker **
*********************
** Missing
count if tpacetemp==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tpacetemp==88|tpacetemp==999|tpacetemp==9999 //0
*******************
** Cardiac Cath. **
*******************
** Missing
count if tcath==. & tiany!=. & tiany!=99 & sd_etype==2 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tcath==88|tcath==999|tcath==9999 //0
***********************
** Decomp. hemicran. **
***********************
** Missing
count if tdhemi==. & tiany!=. & tiany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tdhemi==88|tdhemi==999|tdhemi==9999 //0
*****************
** Vent. drain **
*****************
** Missing
count if tvdrain==. & tiany!=. & tiany!=99 & sd_etype==1 & tests_complete!=0 & tests_complete!=. //0
** Invalid missing code
count if tvdrain==88|tvdrain==999|tvdrain==9999 //0

*************************
** Other interventions **
** 	(Heart + Stroke)   **
*************************
** Missing
count if  tiany!=. & tiany!=99 & tiany!=99999 & oti==. //0
** Invalid missing code
count if oti==88|oti==999|oti==9999 //0
** Missing (other int. options=1 but other int. text blank)
****************
** Oth Int. 1 **
****************
count if oti==1 & oti1=="" //0
** Invalid (other int. options=ND/None but other int. text NOT=blank)
count if (oti==4|oti==99|oti==99999) & oti1!="" //0
** possibly Invalid (other int.=one of the int. options)
count if oti1!="" //4 - reviewed and correct
count if sd_etype==2 & (regexm(oti1,"ventilation")|regexm(oti1,"ppv")|regexm(oti1,"cpap")|regexm(oti1,"defibrill*")|regexm(oti1,"cardioversion")|regexm(oti1,"resus*")|regexm(oti1,"pump")|regexm(oti1,"counterpulsation")|regexm(oti1,"support")|regexm(oti1,"angioplasty")|regexm(oti1,"pacemaker")|regexm(oti1,"cath*")) //0
count if sd_etype==1 & (regexm(oti1,"craniectomy")|regexm(oti1,"drain")) //0
****************
** Oth Int. 2 **
****************
count if oti==2 & oti2=="" //0
** Invalid (other int. options=ND/None but other int. text NOT=blank)
count if (oti==4|oti==99|oti==99999) & oti2!="" //0
** possibly Invalid (other int.=one of the int. options)
count if oti2!="" //1 - reviewed and correct
count if sd_etype==2 & (regexm(oti2,"ventilation")|regexm(oti2,"ppv")|regexm(oti2,"cpap")|regexm(oti2,"defibrill*")|regexm(oti2,"cardioversion")|regexm(oti2,"resus*")|regexm(oti2,"pump")|regexm(oti2,"counterpulsation")|regexm(oti2,"support")|regexm(oti2,"angioplasty")|regexm(oti2,"pacemaker")|regexm(oti2,"cath*")) //0
count if sd_etype==1 & (regexm(oti2,"craniectomy")|regexm(oti2,"drain")) //0
****************
** Oth Int. 3 **
****************
count if oti==3 & oti3=="" //0
** Invalid (other int. options=ND/None but other int. text NOT=blank)
count if (oti==4|oti==99|oti==99999) & oti3!="" //0
** possibly Invalid (other int.=one of the int. options)
count if oti3!="" //0
count if sd_etype==2 & (regexm(oti3,"ventilation")|regexm(oti3,"ppv")|regexm(oti3,"cpap")|regexm(oti3,"defibrill*")|regexm(oti3,"cardioversion")|regexm(oti3,"resus*")|regexm(oti3,"pump")|regexm(oti3,"counterpulsation")|regexm(oti3,"support")|regexm(oti3,"angioplasty")|regexm(oti3,"pacemaker")|regexm(oti3,"cath*")) //0
count if sd_etype==1 & (regexm(oti3,"craniectomy")|regexm(oti3,"drain")) //0




** Corrections from above checks
destring flag409 ,replace
destring flag1334 ,replace


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace tiany=99999 if record_id=="2309"|record_id=="2353"


replace flag409=tcpr if record_id=="2550"|record_id=="3647"
replace tcpr=1 if record_id=="2550"|record_id=="3647" //see above
replace flag1334=tcpr if record_id=="2550"|record_id=="3647"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2550"|record_id=="3647"



****************************
** Additional Checks for  **
** History Form Variables **
****************************

** JC 22feb2023: additional checks below added for History form but placed here as corrections list already completed for that form (Note: I also added these checks to the dofile 3h_clean hx_cvd.do for upcoming years of cleaning)
***********************
** Family Hx Stroke? **
***********************
** Invalid (famstroke=No/ND; famstroke options=Yes)
count if (famstroke==2|famstroke==99) & (mumstroke==1|dadstroke==1|sibstroke==1) //0
** Invalid (famstroke=Yes; famstroke options NOT=Yes)
count if famstroke==1 & mumstroke!=1 & dadstroke!=1 & sibstroke!=1 //5 - corrected below
** Invalid (famstroke=Yes/No; famstroke options all=ND)
count if famstroke!=99 & mumstroke==99 & dadstroke==99 & sibstroke==99 //5 - same records as above

********************
** Family Hx AMI? **
********************
** Invalid (famstroke=No/ND; famstroke options=Yes)
count if (famami==2|famami==99) & (mumami==1|dadami==1|sibami==1) //0
** Invalid (famstroke=Yes; famstroke options NOT=Yes)
count if famami==1 & mumami!=1 & dadami!=1 & sibami!=1 //3 - corrected below
** Invalid (famstroke=Yes/No; famstroke options all=ND)
count if famami!=99 & mumami==99 & dadami==99 & sibami==99 //3 - same records as above

***********************
** Any risk factors? **
***********************
** Invalid (rfany=No/ND; rfany options=Yes)
count if (rfany==2|rfany==99) & (smoker==1|hcl==1|af==1|tia==1|ccf==1|htn==1|diab==1|hld==1|alco==1|drugs==1) //3 - corrected below
** Invalid (rfany=Yes; rfany options NOT=Yes)
count if rfany==1 & smoker!=1 & hcl!=1 & af!=1 & (tia!=1 & sd_etype==1) & ccf!=1 & htn!=1 & diab!=1 & hld!=1 & alco!=1 & drugs!=1 & ovrf>4 //11 - corrected below
** Invalid (rfany=Yes/No; rfany options all=ND)
count if rfany!=99 & smoker==99 & hcl==99 & af==99 & tia==99 & ccf==99 & htn==99 & diab==99 & hld==99 & alco==99 & drugs==99 //5 - 4 correct; 1 already flagged above



** Corrections from above checks
destring flag285 ,replace
destring flag1210 ,replace
destring flag286 ,replace
destring flag1211 ,replace

replace flag285=famstroke if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316"
replace famstroke=99 if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316" //see above
replace flag1210=famstroke if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316"

replace mumstroke=. if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316"
replace dadstroke=. if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316"
replace sibstroke=. if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316" 
//DA won't need to correct CVDdb for this correction since it would be done when famstroke is corrected in CVDdb

replace flag286=famami if record_id=="2016"|record_id=="2965"|record_id=="3316"
replace famami=99 if record_id=="2016"|record_id=="2965"|record_id=="3316" //see above
replace flag1211=famami if record_id=="2016"|record_id=="2965"|record_id=="3316"

replace mumami=. if record_id=="2016"|record_id=="2965"|record_id=="3316"
replace dadami=. if record_id=="2016"|record_id=="2965"|record_id=="3316"
replace sibami=. if record_id=="2016"|record_id=="2965"|record_id=="3316"
//DA won't need to correct CVDdb for this correction since it would be done when famami is corrected in CVDdb

replace flag293=rfany if record_id=="2908"|record_id=="3013"|record_id=="3124"|record_id=="1925"|record_id=="2244"|record_id=="2306"|record_id=="2309"|record_id=="2368"|record_id=="2449"|record_id=="2763"|record_id=="3086"|record_id=="3169"|record_id=="3389"|record_id=="4223"
replace rfany=1 if record_id=="2908"|record_id=="3013"|record_id=="3124" //see above
replace rfany=2 if record_id=="1925"|record_id=="2244"|record_id=="2306"|record_id=="2309"|record_id=="2368"|record_id=="2449"|record_id=="2763"|record_id=="3086"|record_id=="3169"|record_id=="3389" //see above
replace rfany=99 if record_id=="4223" //see above
replace flag1218=rfany if record_id=="2908"|record_id=="3013"|record_id=="3124"|record_id=="1925"|record_id=="2244"|record_id=="2306"|record_id=="2309"|record_id=="2368"|record_id=="2449"|record_id=="2763"|record_id=="3086"|record_id=="3169"|record_id=="3389"|record_id=="4223"



** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2016"|record_id=="2183"|record_id=="2965"|record_id=="3168"|record_id=="3316"|record_id=="2908"|record_id=="3013"|record_id=="3124"|record_id=="1925"|record_id=="2244"|record_id=="2306"|record_id=="2309"|record_id=="2368"|record_id=="2449"|record_id=="2763"|record_id=="3086"|record_id=="3169"|record_id=="3389"|record_id=="4223"




/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flagdate flag117 flag1042 flag150 flag1075 flag267 flag1192 flag343 flag1268 flag367 flag1292 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag117 flag150 flag154 flag257 flag259 flag267 flag285 flag286 flag293 flag317 flag328 flag343 flag348 flag367 flag409 if ///
		(flag117!=. | flag150!=. | flag154!="" | flag257!=. | flag259!=. | flag267!=. |  flag285!=. |  flag286!=. | flag293!=. |  flag317!=. |  flag328!=. |  flag343!=. |  flag348!=. |  flag367!=. |  flag409!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_TESTS1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1042 flag1075 flag1079 flag1182 flag1184 flag1192 flag1210 flag1211 flag1218 flag1242 flag1253 flag1268 flag1273 flag1292 flag1334 if ///
		 (flag1042!=. | flag1075!=. | flag1079!="" | flag1182!=. | flag1184!=. | flag1192!=. |  flag1210!=. |  flag1211!=. | flag1218!=. |  flag1242!=. |  flag1253!=. |  flag1268!=. |  flag1273!=. |  flag1292!=. |  flag1334!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_TESTS1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/



** Create datetime variables in prep for analysis (prepend with 'sd_') - only for variables wherein both date and time are not missing
** FMC
drop sd_fmcdatetime fmcdate_text fmcdatetime2
gen fmcdate_text = string(fmcdate, "%td")
gen fmcdatetime2 = fmcdate_text+" "+fmctime if fmcdate!=. & fmctime!="" & fmctime!="88" & fmctime!="99"
gen double sd_fmcdatetime = clock(fmcdatetime2,"DMYhm") if fmcdatetime2!=""
format sd_fmcdatetime %tc
label var sd_fmcdatetime "DateTime of FIRST MEDICAL CONTACT"
** A&E admission
drop sd_daetae dae_text daetae2
gen dae_text = string(dae, "%td")
gen daetae2 = dae_text+" "+tae if dae!=. & tae!="" & tae!="88" & tae!="99"
gen double sd_daetae = clock(daetae2,"DMYhm") if daetae2!=""
format sd_daetae %tc
label var sd_daetae "DateTime Admitted to A&E"
** A&E discharge
drop sd_daetaedis daedis_text daetaedis2
gen daedis_text = string(daedis, "%td")
gen daetaedis2 = daedis_text+" "+taedis if daedis!=. & taedis!="" & taedis!="88" & taedis!="99"
gen double sd_daetaedis = clock(daetaedis2,"DMYhm") if daetaedis2!=""
format sd_daetaedis %tc
label var sd_daetaedis "DateTime Discharged from A&E"
** Admission (Ward)
drop sd_dohtoh doh_text dohtoh2
gen doh_text = string(doh, "%td")
gen dohtoh2 = doh_text+" "+toh if doh!=. & toh!="" & toh!="88" & toh!="99"
gen double sd_dohtoh = clock(dohtoh2,"DMYhm") if dohtoh2!=""
format sd_dohtoh %tc
label var sd_dohtoh "DateTime Admitted to Ward"
** Notified (Ambulance)
drop sd_ambcalldt ambcalld_text ambcalldt2
gen ambcalld_text = string(ambcalld, "%td")
gen ambcalldt2 = ambcalld_text+" "+ambcallt if ambcalld!=. & ambcallt!="" & ambcallt!="88" & ambcallt!="99"
gen double sd_ambcalldt = clock(ambcalldt2,"DMYhm") if ambcalldt2!=""
format sd_ambcalldt %tc
label var sd_ambcalldt "DateTime Ambulance NOTIFIED"
** At Scene (Ambulance)
drop sd_atscndt atscnd_text atscndt2
gen atscnd_text = string(atscnd, "%td")
gen atscndt2 = atscnd_text+" "+atscnt if atscnd!=. & atscnt!="" & atscnt!="88" & atscnt!="99"
gen double sd_atscndt = clock(atscndt2,"DMYhm") if atscndt2!=""
format sd_atscndt %tc
label var sd_atscndt "DateTime Ambulance AT SCENE"
** From Scene (Ambulance)
drop sd_frmscndt frmscnd_text frmscndt2
gen frmscnd_text = string(frmscnd, "%td")
gen frmscndt2 = frmscnd_text+" "+frmscnt if frmscnd!=. & frmscnt!="" & frmscnt!="88" & frmscnt!="99"
gen double sd_frmscndt = clock(frmscndt2,"DMYhm") if frmscndt2!=""
format sd_frmscndt %tc
label var sd_frmscndt "DateTime Ambulance FROM SCENE"
** At Hospital (Ambulance)
drop sd_hospdt hospd_text hospdt2
gen hospd_text = string(hospd, "%td")
gen hospdt2 = hospd_text+" "+hospt if hospd!=. & hospt!="" & hospt!="88" & hospt!="99"
gen double sd_hospdt = clock(hospdt2,"DMYhm") if hospdt2!=""
format sd_hospdt %tc
label var sd_hospdt "DateTime Ambulance AT HOSPITAL"
** Chest Pain
drop hsym1d_text hsym1dt2 sd_hsym1dt
gen hsym1d_text = string(hsym1d, "%td")
gen hsym1dt2 = hsym1d_text+" "+hsym1t if hsym1d!=. & hsym1t!="" & hsym1t!="88" & hsym1t!="99"
gen double sd_hsym1dt = clock(hsym1dt2,"DMYhm") if hsym1dt2!=""
format sd_hsym1dt %tc
label var sd_hsym1dt "DateTime of Chest Pain"
** Event
drop edate_text eventdt2 sd_eventdt
gen edate_text = string(edate, "%td")
gen eventdt2 = edate_text+" "+etime if edate!=. & etime!="" & etime!="88" & etime!="99"
gen double sd_eventdt = clock(eventdt2,"DMYhm") if eventdt2!=""
format sd_eventdt %tc
label var sd_eventdt "DateTime of Event"
** Troponin
gen tropd_text = string(tropd, "%td")
gen tropdt2 = tropd_text+" "+tropt if tropd!=. & tropt!="" & tropt!="88" & tropt!="99"
gen double sd_tropdt = clock(tropdt2,"DMYhm") if tropdt2!=""
format sd_tropdt %tc
label var sd_tropdt "DateTime of Troponin"
** ECG
gen ecgd_text = string(ecgd, "%td")
gen ecgdt2 = ecgd_text+" "+ecgt if ecgd!=. & ecgt!="" & ecgt!="88" & ecgt!="99"
gen double sd_ecgdt = clock(ecgdt2,"DMYhm") if ecgdt2!=""
format sd_ecgdt %tc
label var sd_ecgdt "DateTime of ECG"


** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_tests" ,replace