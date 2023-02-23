** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3j_clean comp_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      23-FEB-2023
    // 	date last modified      23-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Complications & Dx form
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
    log using "`logpath'\3j_clean comp_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_tests", clear

count //1144

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

************************
** Complications Info **
************************
********************
** Complications? **
********************
** Missing
count if hcomp==. & complications_dx_complete!=0 & complications_dx_complete!=. //0
** Invalid missing code
count if hcomp==88|hcomp==999|hcomp==9999 //0
** Invalid (comp=No/ND; comp options=Yes)
count if (hcomp==2|hcomp==99) & (hdvt==1|hpneu==1|hulcer==1|huti==1|hfall==1|hhydro==1|hhaemo==1|hoinfect==1|hgibleed==1|hccf==1|hcpang==1|haneur==1|hhypo==1|hblock==1|hseizures==1|hafib==1|hcshock==1|hinfarct==1|hrenal==1|hcarest==1) //0
** Invalid (comp=Yes; comp options NOT=Yes)
count if hcomp==1 & hdvt!=1 & hpneu!=1 & hulcer!=1 & huti!=1 & hfall!=1 & hhydro!=1 & hhaemo!=1 & hoinfect!=1 & hgibleed!=1 & hccf!=1 & hcpang!=1 & haneur!=1 & hhypo!=1 & hblock!=1 & hseizures!=1 & hafib!=1 & hcshock!=1 & hinfarct!=1 & hrenal!=1 & hcarest!=1 & ohcomp>5 //1 - stroke record 2325 corrected below
** Invalid (comp=Yes/No; comp options all=ND)
count if hcomp!=99 & hdvt==99 & hpneu==99 & hulcer==99 & huti==99 & hfall==99 & hhydro==99 & hhaemo==99 & hoinfect==99 & hgibleed==99 & hccf==99 & hcpang==99 & haneur==99 & hhypo==99 & hblock==99 & hseizures==99 & hafib==99 & hcshock==99 & hinfarct==99 & hrenal==99 & hcarest==99 //0
*********
** DVT **
*********
** Missing
count if hdvt==. & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //3 - stroke record 2821 has all hcomp options blank except for pneumonia; stroke record 3292 has all hcomp options blank except for fall; heart record 2995 has all hcomp options blank except for recurrent chest pain; all corrected below
** Invalid missing code
count if hdvt==88|hdvt==999|hdvt==9999 //0
***************
** Pneumonia **
***************
** Missing
count if hpneu==. & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //2 - same records already flagged above; corrected below
** Invalid missing code
count if hpneu==88|hpneu==999|hpneu==9999 //0
***********
** Ulcer **
***********
** Missing
count if hulcer==. & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //3 - same records already flagged above; corrected below
** Invalid missing code
count if hulcer==88|hulcer==999|hulcer==9999 //0
*********
** UTI **
*********
** Missing
count if huti==. & sd_etype==1 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //2 - same records already flagged above; corrected below
** Invalid missing code
count if huti==88|huti==999|huti==9999 //0
**********
** Fall **
**********
** Missing
count if hfall==. & sd_etype==1 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hfall==88|hfall==999|hfall==9999 //0
*******************
** Hydrocephalus **
*******************
** Missing
count if hhydro==. & sd_etype==1 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //2 - same records already flagged above; corrected below
** Invalid missing code
count if hhydro==88|hhydro==999|hhydro==9999 //0
**********************
** Haem. Transform. **
**********************
** Missing
count if hhaemo==. & sd_etype==1 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //2 - same records already flagged above; corrected below
** Invalid missing code
count if hhaemo==88|hhaemo==999|hhaemo==9999 //0
*******************
** Oth Infection **
*******************
** Missing
count if hoinfect==. & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //3 - same records already flagged above; corrected below
** Invalid missing code
count if hoinfect==88|hoinfect==999|hoinfect==9999 //0
**************
** GI Bleed **
**************
** Missing
count if hgibleed==. & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //3 - same records already flagged above; corrected below
** Invalid missing code
count if hgibleed==88|hgibleed==999|hgibleed==9999 //0
*********
** CCF **
*********
** Missing
count if hccf==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hccf==88|hccf==999|hccf==9999 //0
**************************
** Recurrent chest pain **
**************************
** Missing
count if hcpang==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //0
** Invalid missing code
count if hcpang==88|hcpang==999|hcpang==9999 //0
**************
** Aneurysm **
**************
** Missing
count if haneur==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if haneur==88|haneur==999|haneur==9999 //0
*****************
** Hypotension **
*****************
** Missing
count if hhypo==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hhypo==88|hhypo==999|hhypo==9999 //0
*****************
** Heart Block **
*****************
** Missing
count if hblock==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hblock==88|hblock==999|hblock==9999 //0
**************
** Seizures **
**************
** Missing
count if hseizures==. & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //3 - same records already flagged above; corrected below
** Invalid missing code
count if hseizures==88|hseizures==999|hseizures==9999 //0
*****************
** Atrial Fib. **
*****************
** Missing
count if hafib==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hafib==88|hafib==999|hafib==9999 //0
*****************
** Card. Shock **
*****************
** Missing
count if hcshock==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hcshock==88|hcshock==999|hcshock==9999 //0
******************
** Reinfarction **
******************
** Missing
count if hinfarct==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hinfarct==88|hinfarct==999|hinfarct==9999 //0
*******************
** Renal failure **
*******************
** Missing
count if hrenal==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hrenal==88|hrenal==999|hrenal==9999 //0
********************
** Cardiac Arrest **
********************
** Missing
count if hcarest==. & sd_etype==2 & hcomp==1 & complications_dx_complete!=0 & complications_dx_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if hcarest==88|hcarest==999|hcarest==9999 //0

*************************
** Other complications **
** 	(Heart + Stroke)   **
*************************
** Missing
count if  hcomp!=. & hcomp!=99 & hcomp!=99999 & ohcomp==. //301 - JC 23feb2023 updated branching logic in CVDdb to reflect same convention used by similar variables to hcomp + ohcomp
replace ohcomp=6 if hcomp==2 & ohcomp==. //301 changes - DAs do not need to update CVDdb as this error was due to branching logic
** Invalid missing code
count if ohcomp==88|ohcomp==999|ohcomp==9999 //0
** Missing (other comp. options=1 but other comp. text blank)
*****************
** Oth Comp. 1 **
*****************
count if ohcomp==1 & ohcomp1=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (ohcomp==6|ohcomp==99|ohcomp==99999) & ohcomp1!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if ohcomp1!="" //26 - reviewed and correct
count if sd_etype==2 & (regexm(ohcomp1,"dvt")|regexm(ohcomp1,"thrombosis")|regexm(ohcomp1,"pneumonia")|regexm(ohcomp1,"decubitus")|regexm(ohcomp1,"ulcer")|regexm(ohcomp1,"infection")|regexm(ohcomp1,"septic")|regexm(ohcomp1,"bleed")|regexm(ohcomp1,"gastrointestinal")|regexm(ohcomp1,"ccf")|regexm(ohcomp1,"chf")|regexm(ohcomp1,"failure")|regexm(ohcomp1,"chest pain")|regexm(ohcomp1,"angina")|regexm(ohcomp1,"aneurysm")|regexm(ohcomp1,"hypotension")|regexm(ohcomp1,"block")|regexm(ohcomp1,"seizure")|regexm(ohcomp1,"fibrill*")|regexm(ohcomp1,"shock")|regexm(ohcomp1,"reinfarct")|regexm(ohcomp1,"renal")|regexm(ohcomp1,"arrest")) //0
count if sd_etype==1 & (regexm(ohcomp1,"dvt")|regexm(ohcomp1,"thrombosis")|regexm(ohcomp1,"pneumonia")|regexm(ohcomp1,"decubitus")|regexm(ohcomp1,"ulcer")|regexm(ohcomp1,"uti")|regexm(ohcomp1,"fall")|regexm(ohcomp1,"cephalus")|regexm(ohcomp1,"transform")|regexm(ohcomp1,"pneumonia")|regexm(ohcomp1,"decubitus")|regexm(ohcomp1,"ulcer")|regexm(ohcomp1,"infection")|regexm(ohcomp1,"septic")|regexm(ohcomp1,"bleed")|regexm(ohcomp1,"gastrointestinal")|regexm(ohcomp1,"seizure")) //1 - correct; leave as is
*****************
** Oth Comp. 2 **
*****************
count if ohcomp==2 & ohcomp2=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (ohcomp==6|ohcomp==99|ohcomp==99999) & ohcomp2!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if ohcomp2!="" //2 - reviewed and correct
count if sd_etype==2 & (regexm(ohcomp2,"dvt")|regexm(ohcomp2,"thrombosis")|regexm(ohcomp2,"pneumonia")|regexm(ohcomp2,"decubitus")|regexm(ohcomp2,"ulcer")|regexm(ohcomp2,"infection")|regexm(ohcomp2,"septic")|regexm(ohcomp2,"bleed")|regexm(ohcomp2,"gastrointestinal")|regexm(ohcomp2,"ccf")|regexm(ohcomp2,"chf")|regexm(ohcomp2,"failure")|regexm(ohcomp2,"chest pain")|regexm(ohcomp2,"angina")|regexm(ohcomp2,"aneurysm")|regexm(ohcomp2,"hypotension")|regexm(ohcomp2,"block")|regexm(ohcomp2,"seizure")|regexm(ohcomp2,"fibrill*")|regexm(ohcomp2,"shock")|regexm(ohcomp2,"reinfarct")|regexm(ohcomp2,"renal")|regexm(ohcomp2,"arrest")) //0
count if sd_etype==1 & (regexm(ohcomp2,"dvt")|regexm(ohcomp2,"thrombosis")|regexm(ohcomp2,"pneumonia")|regexm(ohcomp2,"decubitus")|regexm(ohcomp2,"ulcer")|regexm(ohcomp2,"uti")|regexm(ohcomp2,"fall")|regexm(ohcomp2,"cephalus")|regexm(ohcomp2,"transform")|regexm(ohcomp2,"pneumonia")|regexm(ohcomp2,"decubitus")|regexm(ohcomp2,"ulcer")|regexm(ohcomp2,"infection")|regexm(ohcomp2,"septic")|regexm(ohcomp2,"bleed")|regexm(ohcomp2,"gastrointestinal")|regexm(ohcomp2,"seizure")) //0
*****************
** Oth Comp. 3 **
*****************
count if ohcomp==3 & ohcomp3=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (ohcomp==6|ohcomp==99|ohcomp==99999) & ohcomp3!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if ohcomp3!="" //1 - reviewed and correct
count if sd_etype==2 & (regexm(ohcomp3,"dvt")|regexm(ohcomp3,"thrombosis")|regexm(ohcomp3,"pneumonia")|regexm(ohcomp3,"decubitus")|regexm(ohcomp3,"ulcer")|regexm(ohcomp3,"infection")|regexm(ohcomp3,"septic")|regexm(ohcomp3,"bleed")|regexm(ohcomp3,"gastrointestinal")|regexm(ohcomp3,"ccf")|regexm(ohcomp3,"chf")|regexm(ohcomp3,"failure")|regexm(ohcomp3,"chest pain")|regexm(ohcomp3,"angina")|regexm(ohcomp3,"aneurysm")|regexm(ohcomp3,"hypotension")|regexm(ohcomp3,"block")|regexm(ohcomp3,"seizure")|regexm(ohcomp3,"fibrill*")|regexm(ohcomp3,"shock")|regexm(ohcomp3,"reinfarct")|regexm(ohcomp3,"renal")|regexm(ohcomp3,"arrest")) //0
count if sd_etype==1 & (regexm(ohcomp3,"dvt")|regexm(ohcomp3,"thrombosis")|regexm(ohcomp3,"pneumonia")|regexm(ohcomp3,"decubitus")|regexm(ohcomp3,"ulcer")|regexm(ohcomp3,"uti")|regexm(ohcomp3,"fall")|regexm(ohcomp3,"cephalus")|regexm(ohcomp3,"transform")|regexm(ohcomp3,"pneumonia")|regexm(ohcomp3,"decubitus")|regexm(ohcomp3,"ulcer")|regexm(ohcomp3,"infection")|regexm(ohcomp3,"septic")|regexm(ohcomp3,"bleed")|regexm(ohcomp3,"gastrointestinal")|regexm(ohcomp3,"seizure")) //0
*****************
** Oth Comp. 4 **
*****************
count if ohcomp==4 & ohcomp4=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (ohcomp==6|ohcomp==99|ohcomp==99999) & ohcomp4!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if ohcomp4!="" //0
count if sd_etype==2 & (regexm(ohcomp4,"dvt")|regexm(ohcomp4,"thrombosis")|regexm(ohcomp4,"pneumonia")|regexm(ohcomp4,"decubitus")|regexm(ohcomp4,"ulcer")|regexm(ohcomp4,"infection")|regexm(ohcomp4,"septic")|regexm(ohcomp4,"bleed")|regexm(ohcomp4,"gastrointestinal")|regexm(ohcomp4,"ccf")|regexm(ohcomp4,"chf")|regexm(ohcomp4,"failure")|regexm(ohcomp4,"chest pain")|regexm(ohcomp4,"angina")|regexm(ohcomp4,"aneurysm")|regexm(ohcomp4,"hypotension")|regexm(ohcomp4,"block")|regexm(ohcomp4,"seizure")|regexm(ohcomp4,"fibrill*")|regexm(ohcomp4,"shock")|regexm(ohcomp4,"reinfarct")|regexm(ohcomp4,"renal")|regexm(ohcomp4,"arrest")) //0
count if sd_etype==1 & (regexm(ohcomp4,"dvt")|regexm(ohcomp4,"thrombosis")|regexm(ohcomp4,"pneumonia")|regexm(ohcomp4,"decubitus")|regexm(ohcomp4,"ulcer")|regexm(ohcomp4,"uti")|regexm(ohcomp4,"fall")|regexm(ohcomp4,"cephalus")|regexm(ohcomp4,"transform")|regexm(ohcomp4,"pneumonia")|regexm(ohcomp4,"decubitus")|regexm(ohcomp4,"ulcer")|regexm(ohcomp4,"infection")|regexm(ohcomp4,"septic")|regexm(ohcomp4,"bleed")|regexm(ohcomp4,"gastrointestinal")|regexm(ohcomp4,"seizure")) //0
*****************
** Oth Comp. 5 **
*****************
count if ohcomp==5 & ohcomp5=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (ohcomp==6|ohcomp==99|ohcomp==99999) & ohcomp5!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if ohcomp5!="" //0
count if sd_etype==2 & (regexm(ohcomp5,"dvt")|regexm(ohcomp5,"thrombosis")|regexm(ohcomp5,"pneumonia")|regexm(ohcomp5,"decubitus")|regexm(ohcomp5,"ulcer")|regexm(ohcomp5,"infection")|regexm(ohcomp5,"septic")|regexm(ohcomp5,"bleed")|regexm(ohcomp5,"gastrointestinal")|regexm(ohcomp5,"ccf")|regexm(ohcomp5,"chf")|regexm(ohcomp5,"failure")|regexm(ohcomp5,"chest pain")|regexm(ohcomp5,"angina")|regexm(ohcomp5,"aneurysm")|regexm(ohcomp5,"hypotension")|regexm(ohcomp5,"block")|regexm(ohcomp5,"seizure")|regexm(ohcomp5,"fibrill*")|regexm(ohcomp5,"shock")|regexm(ohcomp5,"reinfarct")|regexm(ohcomp5,"renal")|regexm(ohcomp5,"arrest")) //0
count if sd_etype==1 & (regexm(ohcomp5,"dvt")|regexm(ohcomp5,"thrombosis")|regexm(ohcomp5,"pneumonia")|regexm(ohcomp5,"decubitus")|regexm(ohcomp5,"ulcer")|regexm(ohcomp5,"uti")|regexm(ohcomp5,"fall")|regexm(ohcomp5,"cephalus")|regexm(ohcomp5,"transform")|regexm(ohcomp5,"pneumonia")|regexm(ohcomp5,"decubitus")|regexm(ohcomp5,"ulcer")|regexm(ohcomp5,"infection")|regexm(ohcomp5,"septic")|regexm(ohcomp5,"bleed")|regexm(ohcomp5,"gastrointestinal")|regexm(ohcomp5,"seizure")) //0




** Corrections from above checks
destring flag421 ,replace
destring flag1346 ,replace


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace hdvt=99999 if record_id=="2821"|record_id=="3292"|record_id=="2995"
replace hpneu=99999 if record_id=="3292"|record_id=="2995"
replace hulcer=99999 if record_id=="2821"|record_id=="3292"|record_id=="2995"
replace huti=99999 if record_id=="2821"|record_id=="3292"
replace hfall=99999 if record_id=="2821"
replace hhydro=99999 if record_id=="2821"|record_id=="3292"
replace hhaemo=99999 if record_id=="2821"|record_id=="3292"
replace hoinfect=99999 if record_id=="2821"|record_id=="3292"|record_id=="2995"
replace hgibleed=99999 if record_id=="2821"|record_id=="3292"|record_id=="2995"
replace hseizures=99999 if record_id=="2821"|record_id=="3292"|record_id=="2995"
replace hccf=99999 if record_id=="2995"
replace haneur=99999 if record_id=="2995"
replace hhypo=99999 if record_id=="2995"
replace hblock=99999 if record_id=="2995"
replace hafib=99999 if record_id=="2995"
replace hcshock=99999 if record_id=="2995"
replace hinfarct=99999 if record_id=="2995"
replace hrenal=99999 if record_id=="2995"
replace hcarest=99999 if record_id=="2995"


replace flag421=hcomp if record_id=="2325"
replace hcomp=2 if record_id=="2325" //see above
replace flag1346=hcomp if record_id=="2325"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

replace flagdate=sd_currentdate if record_id=="2325"



********************
** Diagnosis Info **
********************
*************************
** Same as Initial dx? **
*************************
** Missing
count if absdxsame==. & complications_dx_complete!=0 & complications_dx_complete!=. //0
** Invalid missing code
count if absdxsame==88|absdxsame==99|absdxsame==999|absdxsame==9999 //0
***************
** Stroke dx **
***************
** Missing
count if absdxsame!=1 & sd_etype==1 & absdxs___1==0 & absdxs___2==0 & absdxs___3==0 & absdxs___4==0 & absdxs___5==0 & absdxs___6==0 & absdxs___7==0 & absdxs___8==0 & absdxs___99==0 & complications_dx_complete!=0 & complications_dx_complete!=. //0
** Invalid missing code
count if absdxs___88==1|absdxs___999==1|absdxs___9999==1 //0
** Invalid (same=No; dx options all unticked/None)
count if absdxsame==2 & sd_etype==1 & absdxs___1==0 & absdxs___2==0 & absdxs___3==0 & absdxs___4==0 & absdxs___5==0 & absdxs___6==0 & absdxs___7==0 & absdxs___8==0 & absdxs___99==0 & (oabsdx==5|oabsdx==99) //0
***************
** Heart dx **
***************
** Missing
count if absdxsame!=1 & sd_etype==2 & absdxh___1==0 & absdxh___2==0 & absdxh___3==0 & absdxh___4==0 & absdxh___5==0 & absdxh___6==0 & absdxh___7==0 & absdxh___8==0 & absdxh___9==0 & absdxh___10==0 & absdxh___99==0 & complications_dx_complete!=0 & complications_dx_complete!=. //0
** Invalid missing code
count if absdxh___88==1|absdxh___999==1|absdxh___9999==1 //0
** Invalid (same=No; dx options all unticked/None)
count if absdxsame==2 & sd_etype==2 & absdxh___1==0 & absdxh___2==0 & absdxh___3==0 & absdxh___4==0 & absdxh___5==0 & absdxh___6==0 & absdxh___7==0 & absdxh___8==0 & absdxh___9==0 & absdxh___10==0 & absdxh___99==0 & (oabsdx==5|oabsdx==99) //0


**********************
** Other diagnoses  **
** (Heart + Stroke) **
**********************
** Missing
count if absdxsame!=. & absdxsame!=1 & oabsdx==. //0
** Invalid missing code
count if oabsdx==88|oabsdx==999|oabsdx==9999 //0
** Missing (other dx options=1 but other dx text blank)
**************
** Oth Dx 1 **
**************
count if oabsdx==1 & oabsdx1=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (oabsdx==5|oabsdx==99|oabsdx==99999) & oabsdx1!="" //0
** possibly Invalid (other dx=one of the dx options)
count if oabsdx1!="" //4 - reviewed and correct
count if sd_etype==2 & (regexm(oabsdx1,"stemi")|regexm(oabsdx1,"nstemi")|regexm(oabsdx1,"ami")|regexm(oabsdx1,"acs")|regexm(oabsdx1,"angina")|regexm(oabsdx1,"chest")|regexm(oabsdx1,"septic")|regexm(oabsdx1,"bleed")|regexm(oabsdx1,"gastrointestinal")|regexm(oabsdx1,"ccf")|regexm(oabsdx1,"chf")|regexm(oabsdx1,"failure")|regexm(oabsdx1,"chest pain")|regexm(oabsdx1,"angina")|regexm(oabsdx1,"lbbb")|regexm(oabsdx1,"documented")|regexm(oabsdx1,"unknown")) //0
count if sd_etype==1 & (regexm(oabsdx1,"stroke")|regexm(oabsdx1,"haemorrhage")|regexm(oabsdx1,"hemorrhage")|regexm(oabsdx1,"unclassified")|regexm(oabsdx1,"cva")|regexm(oabsdx1,"tia")|regexm(oabsdx1,"documented")|regexm(oabsdx1,"unknown")) //1 - correct; leave as is
**************
** Oth Dx 2 **
**************
count if oabsdx==2 & oabsdx2=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (oabsdx==5|oabsdx==99|oabsdx==99999) & oabsdx2!="" //0
** possibly Invalid (other dx=one of the dx options)
count if oabsdx2!="" //0
count if sd_etype==2 & (regexm(oabsdx2,"stemi")|regexm(oabsdx2,"nstemi")|regexm(oabsdx2,"ami")|regexm(oabsdx2,"acs")|regexm(oabsdx2,"angina")|regexm(oabsdx2,"chest")|regexm(oabsdx2,"septic")|regexm(oabsdx2,"bleed")|regexm(oabsdx2,"gastrointestinal")|regexm(oabsdx2,"ccf")|regexm(oabsdx2,"chf")|regexm(oabsdx2,"failure")|regexm(oabsdx2,"chest pain")|regexm(oabsdx2,"angina")|regexm(oabsdx2,"lbbb")|regexm(oabsdx2,"documented")|regexm(oabsdx2,"unknown")) //0
count if sd_etype==1 & (regexm(oabsdx2,"stroke")|regexm(oabsdx2,"haemorrhage")|regexm(oabsdx2,"hemorrhage")|regexm(oabsdx2,"unclassified")|regexm(oabsdx2,"cva")|regexm(oabsdx2,"tia")|regexm(oabsdx2,"documented")|regexm(oabsdx2,"unknown")) //0
**************
** Oth Dx 3 **
**************
count if oabsdx==3 & oabsdx3=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (oabsdx==5|oabsdx==99|oabsdx==99999) & oabsdx3!="" //0
** possibly Invalid (other dx=one of the dx options)
count if oabsdx3!="" //0
count if sd_etype==2 & (regexm(oabsdx3,"stemi")|regexm(oabsdx3,"nstemi")|regexm(oabsdx3,"ami")|regexm(oabsdx3,"acs")|regexm(oabsdx3,"angina")|regexm(oabsdx3,"chest")|regexm(oabsdx3,"septic")|regexm(oabsdx3,"bleed")|regexm(oabsdx3,"gastrointestinal")|regexm(oabsdx3,"ccf")|regexm(oabsdx3,"chf")|regexm(oabsdx3,"failure")|regexm(oabsdx3,"chest pain")|regexm(oabsdx3,"angina")|regexm(oabsdx3,"lbbb")|regexm(oabsdx3,"documented")|regexm(oabsdx3,"unknown")) //0
count if sd_etype==1 & (regexm(oabsdx3,"stroke")|regexm(oabsdx3,"haemorrhage")|regexm(oabsdx3,"hemorrhage")|regexm(oabsdx3,"unclassified")|regexm(oabsdx3,"cva")|regexm(oabsdx3,"tia")|regexm(oabsdx3,"documented")|regexm(oabsdx3,"unknown")) //0
**************
** Oth Dx 4 **
**************
count if oabsdx==4 & oabsdx4=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (oabsdx==5|oabsdx==99|oabsdx==99999) & oabsdx4!="" //0
** possibly Invalid (other dx=one of the dx options)
count if oabsdx4!="" //0
count if sd_etype==2 & (regexm(oabsdx4,"stemi")|regexm(oabsdx4,"nstemi")|regexm(oabsdx4,"ami")|regexm(oabsdx4,"acs")|regexm(oabsdx4,"angina")|regexm(oabsdx4,"chest")|regexm(oabsdx4,"septic")|regexm(oabsdx4,"bleed")|regexm(oabsdx4,"gastrointestinal")|regexm(oabsdx4,"ccf")|regexm(oabsdx4,"chf")|regexm(oabsdx4,"failure")|regexm(oabsdx4,"chest pain")|regexm(oabsdx4,"angina")|regexm(oabsdx4,"lbbb")|regexm(oabsdx4,"documented")|regexm(oabsdx4,"unknown")) //0
count if sd_etype==1 & (regexm(oabsdx4,"stroke")|regexm(oabsdx4,"haemorrhage")|regexm(oabsdx4,"hemorrhage")|regexm(oabsdx4,"unclassified")|regexm(oabsdx4,"cva")|regexm(oabsdx4,"tia")|regexm(oabsdx4,"documented")|regexm(oabsdx4,"unknown")) //0




/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
//format flagdate flag117 flag1042 flag150 flag1075 flag267 flag1192 flag343 flag1268 flag367 flag1292 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag421 if ///
		flag421!=. & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_COMP1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1346 if ///
		 flag1346!=. & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_COMP1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_comp" ,replace