** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3k_clean rx_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-FEB-2023
    // 	date last modified      27-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Medications form
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
    log using "`logpath'\3k_clean rx_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_comp", clear

count //1144

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

**********************
** Reperfusion Info **
**********************
****************************
** Reperfusion attempted? **
****************************
** Missing
count if reperf==. & medications_complete!=0 & medications_complete!=. //1 - stroke record 3247 corrected below
** Invalid missing code
count if reperf==88|reperf==999|reperf==9999 //0
**********************
** Reperfusion Type **
**********************
** Missing
count if repertype==. & reperf==1 //3 - stroke record 2821 has all hcomp options blank except for pneumonia; stroke record 3292 has all hcomp options blank except for fall; heart record 2995 has all hcomp options blank except for recurrent chest pain; all corrected below
** Invalid missing code
count if repertype==88|repertype==999|repertype==9999 //0
** Invalid (reperf=PCI/Rescue PCI; event=Stroke)
count if repertype!=. & repertype>1 & sd_etype==1 //0

**********************
** Reperfusion Date **
**********************
** Missing date
count if reperfd==. & reperf==1 //0
** Invalid (not 2021)
count if reperfd!=. & year(reperfd)!=2021 //1 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & reperfd!=. & reperfd<dob //0
** possibly Invalid (before CFAdmDate)
count if reperfd!=. & cfadmdate!=. & reperfd<cfadmdate & inhosp!=1 & fmcdate==. //1 - heart record 2052 for review by NS
** possibly Invalid (after DLC/DOD)
count if dlc!=. & reperfd!=. & reperfd>dlc //0
count if cfdod!=. & reperfd!=. & reperfd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if reperfd!=. & dae!=. & reperfd<dae & inhosp!=1 & fmcdate==. //1 - already flagged above - pending review by NS
** possibly Invalid (after WardAdmDate)
count if reperfd!=. & doh!=. & reperfd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if reperfd!=. & reperfd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if reperf==1 & reperfd==. & reperfdday==99 & reperfdmonth==99 & reperfdyear==9999 //0
** possibly Invalid (reperf date not partial but partial field not blank)
count if reperfd==. & reperfdday!=. & reperfdmonth!=. & reperfdyear!=. //0
replace reperfdday=. if reperfd==. & reperfdday!=. & reperfdmonth!=. & reperfdyear!=. //0 changes
replace reperfdmonth=. if reperfd==. & reperfdmonth!=. & reperfdyear!=. //0 changes
replace reperfdyear=. if reperfd==. & reperfdyear!=. //0 changes
count if reperfd==. & (reperfdday!=. | reperfdmonth!=. | reperfdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if reperfdday==88|reperfdday==999|reperfdday==9999 //0
count if reperfdmonth==88|reperfdmonth==999|reperfdmonth==9999 //0
count if reperfdyear==88|reperfdyear==99|reperfdyear==999 //0
** Invalid (before NotifiedDate)
count if reperfd!=. & ambcalld!=. & reperfd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if reperfd!=. & atscnd!=. & reperfd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if reperfd!=. & frmscnd!=. & reperfd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if reperfd!=. & hospd!=. & reperfd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if reperfd!=. & edate!=. & reperfd<edate //0
** Missing time
count if reperft=="" & reperf==1 //0
** Invalid (time format)
count if reperft!="" & reperft!="88" & reperft!="99" & (length(reperft)<5|length(reperft)>5) //0
count if reperft!="" & reperft!="88" & reperft!="99" & !strmatch(strupper(reperft), "*:*") //0
generate byte non_numeric_reperft = indexnot(reperft, "0123456789.-:")
count if non_numeric_reperft //0
** Invalid missing code
count if reperft=="999"|reperft=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if reperft=="88" & reperftampm==. //0
** Invalid (reperf time before notified time)
count if reperft!="" & reperft!="99" & ambcallt!="" & ambcallt!="99" & reperft<ambcallt //3 - 2 are correct; heart record 2139 corrected below
** Invalid (reperf time before time at scene)
count if reperft!="" & reperft!="99" & atscnt!="" & atscnt!="99" & reperft<atscnt //3 - same records as above
** Invalid (reperf time before time from scene)
count if reperft!="" & reperft!="99" & frmscnt!="" & frmscnt!="99" & reperft<frmscnt //3 - same records as above
** Invalid (reperf time before time at hospital)
count if reperft!="" & reperft!="99" & hospt!="" & hospt!="99" & reperft<hospt //3 - same records as above
** Invalid (reperf time before event time)
count if reperft!="" & reperft!="99" & etime!="" & etime!="99" & reperft<etime //10 - all correct except one already flagged above
** Invalid missing code
count if reperftampm==88|reperftampm==99|reperftampm==999|reperftampm==9999 //0



** Corrections from above checks
destring flag483 ,replace
destring flag1408 ,replace
format flag483 flag1408 %dM_d,_CY


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling for instances wherein the question is unanswered by the DA so the DAs do not need to update the CVDdb post-cleaning
replace reperf=99999 if record_id=="3247"


replace flag483=reperfd if record_id=="2139"
replace reperfd=tropd if record_id=="2139" //see above
replace flag1408=reperfd if record_id=="2139"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

replace flagdate=sd_currentdate if record_id=="3247"|record_id=="2139"


**********************
** Medications Info **
**********************
*************
** Aspirin **
*************
** Missing
count if asp___1==0 & asp___2==0 & asp___3==0 & asp___99==0 & medications_complete!=0 & medications_complete!=. //0
** Invalid missing code
count if asp___88==1|asp___999==1|asp___9999==1 //0
**************
** Warfarin **
**************
** Missing
count if warf___1==0 & warf___2==0 & warf___3==0 & warf___99==0 & medications_complete!=0 & medications_complete!=. //2 - heart record 2477 + stroke record 3247 corrected below
** Invalid missing code
count if warf___88==1|warf___999==1|warf___9999==1 //0
*********************
** Heparin (sc/iv) **
*********************
** Missing
count if hep___1==0 & hep___2==0 & hep___3==0 & hep___99==0 & medications_complete!=0 & medications_complete!=. //2 - same records already flagged above
** Invalid missing code
count if hep___88==1|hep___999==1|hep___9999==1 //0
*******************
** Heparin (lmw) **
*******************
** Missing
count if heplmw___1==0 & heplmw___2==0 & heplmw___3==0 & heplmw___99==0 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if heplmw___88==1|heplmw___999==1|heplmw___9999==1 //0
*******************
** Antiplatelets **
*******************
** Missing
count if pla___1==0 & pla___2==0 & pla___3==0 & pla___99==0 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if pla___88==1|pla___999==1|pla___9999==1 //0
************
** Statin **
************
** Missing
count if stat___1==0 & stat___2==0 & stat___3==0 & stat___99==0 & medications_complete!=0 & medications_complete!=. //2 - same records already flagged above
** Invalid missing code
count if stat___88==1|stat___999==1|stat___9999==1 //0
*******************
** Fibrinolytics **
*******************
** Missing
count if fibr___1==0 & fibr___2==0 & fibr___3==0 & fibr___99==0 & medications_complete!=0 & medications_complete!=. //2 - same records already flagged above
** Invalid missing code
count if fibr___88==1|fibr___999==1|fibr___9999==1 //0
*********
** ACE **
*********
** Missing
count if ace___1==0 & ace___2==0 & ace___3==0 & ace___99==0 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if ace___88==1|ace___999==1|ace___9999==1 //0
**********
** ARBs **
**********
** Missing
count if arbs___1==0 & arbs___2==0 & arbs___3==0 & arbs___99==0 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if arbs___88==1|arbs___999==1|arbs___9999==1 //0
*********************
** Corticosteroids **
*********************
** Missing
count if cors___1==0 & cors___2==0 & cors___3==0 & cors___99==0 & sd_etype==1 & medications_complete!=0 & medications_complete!=. //2 - stroke record 3247 already flagged above; stroke record 2283 corrected below
** Invalid missing code
count if cors___88==1|cors___999==1|cors___9999==1 //1 - stroke record 2283 corrected below
***********************
** Antihypertensives **
***********************
** Missing
count if antih___1==0 & antih___2==0 & antih___3==0 & antih___99==0 & sd_etype==1 & medications_complete!=0 & medications_complete!=. //1 - stroke record 4223 corrected below
** Invalid missing code
count if antih___88==1|antih___999==1|antih___9999==1 //1 - stroke record 4223 corrected below
****************
** Nimodipine **
****************
** Missing
count if nimo___1==0 & nimo___2==0 & nimo___3==0 & nimo___99==0 & sd_etype==1 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if nimo___88==1|nimo___999==1|nimo___9999==1 //0
******************
** Antiseizures **
******************
** Missing
count if antis___1==0 & antis___2==0 & antis___3==0 & antis___99==0 & sd_etype==1 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if antis___88==1|antis___999==1|antis___9999==1 //0
*******************
** TED Stockings **
*******************
** Missing
count if ted___1==0 & ted___2==0 & ted___3==0 & ted___99==0 & sd_etype==1 & medications_complete!=0 & medications_complete!=. //1 - same record already flagged above
** Invalid missing code
count if ted___88==1|ted___999==1|ted___9999==1 //0
*******************
** Beta Blockers **
*******************
** Missing
count if beta___1==0 & beta___2==0 & beta___3==0 & beta___99==0 & sd_etype==2 & medications_complete!=0 & medications_complete!=. //0
** Invalid missing code
count if beta___88==1|beta___999==1|beta___9999==1 //0
****************
** Bivalrudin **
****************
** Missing
count if bival___1==0 & bival___2==0 & bival___3==0 & bival___99==0 & sd_etype==2 & medications_complete!=0 & medications_complete!=. //0
** Invalid missing code
count if bival___88==1|bival___999==1|bival___9999==1 //0





** Corrections from above checks
destring flag555 ,replace
destring flag1480 ,replace
destring flag556 ,replace
destring flag1481 ,replace
destring flag562 ,replace
destring flag1487 ,replace
destring flag563 ,replace
destring flag1488 ,replace


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling for instances wherein the question is unanswered by the DA so the DAs do not need to update the CVDdb post-cleaning
replace reperf=99999 if record_id=="3247"
gen warf___99999=1 if record_id=="2477"|record_id=="3247"
gen hep___99999=1 if record_id=="2477"|record_id=="3247"
gen heplmw___99999=1 if record_id=="3247"
gen pla___99999=1 if record_id=="3247"
gen stat___99999=1 if record_id=="2477"|record_id=="3247"
gen fibr___99999=1 if record_id=="2477"|record_id=="3247"
gen ace___99999=1 if record_id=="3247"
gen arbs___99999=1 if record_id=="2477"
gen cors___99999=1 if record_id=="3247"
gen nimo___99999=1 if record_id=="3247"
gen antis___99999=1 if record_id=="3247"
gen ted___99999=1 if record_id=="3247"


replace flag555=cors___99 if record_id=="2283"
replace cors___99=1 if record_id=="2283" //see above
replace flag1480=cors___99 if record_id=="2283"

replace flag556=cors___88 if record_id=="2283"
replace cors___88=0 if record_id=="2283" //see above
replace flag1481=cors___88 if record_id=="2283"

replace flag562=cors___99 if record_id=="4223"
replace cors___99=1 if record_id=="4223" //see above
replace flag1487=cors___99 if record_id=="4223"

replace flag563=cors___88 if record_id=="4223"
replace cors___88=0 if record_id=="4223" //see above
replace flag1488=cors___88 if record_id=="4223"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2477"|record_id=="3247"|record_id=="2283"|record_id=="4223"


******************
** Aspirin Date **
******************
** Missing date
count if aspd==. & asp___1==1 //3 - entered as 99 in CVDdb
** Invalid (not 2021)
count if aspd!=. & year(aspd)!=2021 //2 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & aspd!=. & aspd<dob //0
** possibly Invalid (before CFAdmDate)
count if aspd!=. & cfadmdate!=. & aspd<cfadmdate & inhosp!=1 & fmcdate==. //1 - stroke record 2060 corrected below
** possibly Invalid (after DLC/DOD)
count if dlc!=. & aspd!=. & aspd>dlc //0
count if cfdod!=. & aspd!=. & aspd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if aspd!=. & dae!=. & aspd<dae & inhosp!=1 & fmcdate==. //1 - already flagged above - pending review by NS
** possibly Invalid (after WardAdmDate)
count if aspd!=. & doh!=. & aspd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if aspd!=. & aspd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if asp___1==1 & aspd==. & aspdday==99 & aspdmonth==99 & aspdyear==9999 //0
** possibly Invalid (asp date not partial but partial field not blank)
count if aspd==. & aspdday!=. & aspdmonth!=. & aspdyear!=. //0
replace aspdday=. if aspd==. & aspdday!=. & aspdmonth!=. & aspdyear!=. //0 changes
replace aspdmonth=. if aspd==. & aspdmonth!=. & aspdyear!=. //0 changes
replace aspdyear=. if aspd==. & aspdyear!=. //0 changes
count if aspd==. & (aspdday!=. | aspdmonth!=. | aspdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if aspdday==88|aspdday==999|aspdday==9999 //0
count if aspdmonth==88|aspdmonth==999|aspdmonth==9999 //0
count if aspdyear==88|aspdyear==99|aspdyear==999 //0
** Invalid (before NotifiedDate)
count if aspd!=. & ambcalld!=. & aspd<ambcalld & inhosp!=1 //2 - stroke record 2178 given at Urgent Care; heart record 2432 given at SCMC prior to QEH adm; both correct
** Invalid (before AtSceneDate)
count if aspd!=. & atscnd!=. & aspd<atscnd & inhosp!=1 //2 - same records already flagged above
** Invalid (before FromSceneDate)
count if aspd!=. & frmscnd!=. & aspd<frmscnd & inhosp!=1 //2 - same records already flagged above
** Invalid (before AtHospitalDate)
count if aspd!=. & hospd!=. & aspd<hospd & inhosp!=1 //2 - same records already flagged above
** Invalid (before EventDate)
count if aspd!=. & edate!=. & aspd<edate //3 - record 2060 already flagged above; stroke record 2322 is in-hosp event so correct as is; stroke record 2654 corrected below
** Missing time
count if aspt=="" & asp___1==1 //0
** Invalid (time format)
count if aspt!="" & aspt!="88" & aspt!="99" & (length(aspt)<5|length(aspt)>5) //0
count if aspt!="" & aspt!="88" & aspt!="99" & !strmatch(strupper(aspt), "*:*") //0
generate byte non_numeric_aspt = indexnot(aspt, "0123456789.-:")
count if non_numeric_aspt //0
** Invalid missing code
count if aspt=="999"|aspt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if aspt=="88" & asptampm==. //0
** Invalid (asp time before notified time)
count if aspt!="" & aspt!="99" & ambcallt!="" & ambcallt!="99" & aspt<ambcallt //81 - all are correct; stroke records 1916, 2351, 2938 heart record 2897 took prior to QEH adm
** Invalid (asp time before time at scene)
count if aspt!="" & aspt!="99" & atscnt!="" & atscnt!="99" & aspt<atscnt //87 - same records as above
** Invalid (asp time before time from scene)
count if aspt!="" & aspt!="99" & frmscnt!="" & frmscnt!="99" & aspt<frmscnt //85 - same records as above
** Invalid (asp time before time at hospital)
count if aspt!="" & aspt!="99" & hospt!="" & hospt!="99" & aspt<hospt //67 - same records as above
** Invalid (asp time before event time)
count if aspt!="" & aspt!="99" & etime!="" & etime!="99" & aspt<etime //152 - all correct except heart records 2139 + 3361 corrected below
** Invalid missing code
count if asptampm==88|asptampm==99|asptampm==999|asptampm==9999 //0



** Corrections from above checks
destring flag602 ,replace
destring flag1527 ,replace
destring flag620 ,replace
destring flag1545 ,replace
destring flag626 ,replace
destring flag1551 ,replace
destring flag638 ,replace
destring flag1563 ,replace
format flag602 flag1527 flag620 flag1545 flag626 flag1551 flag638 flag1563 %dM_d,_CY


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling for instances wherein the question is unanswered by the DA so the DAs do not need to update the CVDdb post-cleaning
//replace reperf=99999 if record_id==""


replace flag602=aspd if record_id=="2060"|record_id=="2654"
replace aspd=dae if record_id=="2060"|record_id=="2654" //see above
replace flag1527=aspd if record_id=="2060"|record_id=="2654"

replace flag602=aspd if record_id=="2139"
replace aspd=reperfd if record_id=="2139" //see above
replace flag1527=aspd if record_id=="2139"

replace flag620=heplmwd if record_id=="2139"
replace heplmwd=reperfd if record_id=="2139" //see above
replace flag1545=heplmwd if record_id=="2139"

replace flag626=plad if record_id=="2139"
replace plad=reperfd if record_id=="2139" //see above
replace flag1551=plad if record_id=="2139"

replace flag638=fibrd if record_id=="2139"
replace fibrd=reperfd if record_id=="2139" //see above
replace flag1563=fibrd if record_id=="2139"

replace flag602=aspd if record_id=="3361"
replace aspd=plad if record_id=="3361" //see above
replace flag1527=aspd if record_id=="3361"



** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2060"|record_id=="2654"|record_id=="2139"|record_id=="3361"

STOP

*******************
** Warfarin Date **
*******************
** Missing date
count if warfd==. & warf___1==1 //3 - entered as 99 in CVDdb
** Invalid (not 2021)
count if warfd!=. & year(warfd)!=2021 //2 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & warfd!=. & warfd<dob //0
** possibly Invalid (before CFAdmDate)
count if warfd!=. & cfadmdate!=. & warfd<cfadmdate & inhosp!=1 & fmcdate==. //1 - stroke record 2060 corrected below
** possibly Invalid (after DLC/DOD)
count if dlc!=. & warfd!=. & warfd>dlc //0
count if cfdod!=. & warfd!=. & warfd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if warfd!=. & dae!=. & warfd<dae & inhosp!=1 & fmcdate==. //1 - already flagged above - pending review by NS
** possibly Invalid (after WardAdmDate)
count if warfd!=. & doh!=. & warfd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if warfd!=. & warfd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if warf___1==1 & warfd==. & warfdday==99 & warfdmonth==99 & warfdyear==9999 //0
** possibly Invalid (warf date not partial but partial field not blank)
count if warfd==. & warfdday!=. & warfdmonth!=. & warfdyear!=. //0
replace warfdday=. if warfd==. & warfdday!=. & warfdmonth!=. & warfdyear!=. //0 changes
replace warfdmonth=. if warfd==. & warfdmonth!=. & warfdyear!=. //0 changes
replace warfdyear=. if warfd==. & warfdyear!=. //0 changes
count if warfd==. & (warfdday!=. | warfdmonth!=. | warfdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if warfdday==88|warfdday==999|warfdday==9999 //0
count if warfdmonth==88|warfdmonth==999|warfdmonth==9999 //0
count if warfdyear==88|warfdyear==99|warfdyear==999 //0
** Invalid (before NotifiedDate)
count if warfd!=. & ambcalld!=. & warfd<ambcalld & inhosp!=1 //2 - stroke record 2178 given at Urgent Care; heart record 2432 given at SCMC prior to QEH adm; both correct
** Invalid (before AtSceneDate)
count if warfd!=. & atscnd!=. & warfd<atscnd & inhosp!=1 //2 - same records already flagged above
** Invalid (before FromSceneDate)
count if warfd!=. & frmscnd!=. & warfd<frmscnd & inhosp!=1 //2 - same records already flagged above
** Invalid (before AtHospitalDate)
count if warfd!=. & hospd!=. & warfd<hospd & inhosp!=1 //2 - same records already flagged above
** Invalid (before EventDate)
count if warfd!=. & edate!=. & warfd<edate //3 - record 2060 already flagged above; stroke record 2322 is in-hosp event so correct as is; stroke record 2654 corrected below
** Missing time
count if warft=="" & warf___1==1 //0
** Invalid (time format)
count if warft!="" & warft!="88" & warft!="99" & (length(warft)<5|length(warft)>5) //0
count if warft!="" & warft!="88" & warft!="99" & !strmatch(strupper(warft), "*:*") //0
generate byte non_numeric_warft = indexnot(warft, "0123456789.-:")
count if non_numeric_warft //0
** Invalid missing code
count if warft=="999"|warft=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if warft=="88" & warftampm==. //0
** Invalid (warf time before notified time)
count if warft!="" & warft!="99" & ambcallt!="" & ambcallt!="99" & warft<ambcallt //81 - all are correct; stroke records 1916, 2351, 2938 heart record 2897 took prior to QEH adm
** Invalid (warf time before time at scene)
count if warft!="" & warft!="99" & atscnt!="" & atscnt!="99" & warft<atscnt //87 - same records as above
** Invalid (warf time before time from scene)
count if warft!="" & warft!="99" & frmscnt!="" & frmscnt!="99" & warft<frmscnt //85 - same records as above
** Invalid (warf time before time at hospital)
count if warft!="" & warft!="99" & hospt!="" & hospt!="99" & warft<hospt //67 - same records as above
** Invalid (warf time before event time)
count if warft!="" & warft!="99" & etime!="" & etime!="99" & warft<etime //152 - all correct except heart records 2139 + 3361 corrected below
** Invalid missing code
count if warftampm==88|warftampm==99|warftampm==999|warftampm==9999 //0



** Corrections from above checks
destring flag602 ,replace
destring flag1527 ,replace
destring flag620 ,replace
destring flag1545 ,replace
destring flag626 ,replace
destring flag1551 ,replace
destring flag638 ,replace
destring flag1563 ,replace
format flag602 flag1527 flag620 flag1545 flag626 flag1551 flag638 flag1563 %dM_d,_CY


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling for instances wherein the question is unanswered by the DA so the DAs do not need to update the CVDdb post-cleaning
//replace reperf=99999 if record_id==""


replace flag602=aspd if record_id==""|record_id==""
replace aspd=dae if record_id==""|record_id=="" //see above
replace flag1527=aspd if record_id==""|record_id==""

replace flag602=aspd if record_id==""
replace aspd=reperfd if record_id=="" //see above
replace flag1527=aspd if record_id==""

replace flag620=heplmwd if record_id==""
replace heplmwd=reperfd if record_id=="" //see above
replace flag1545=heplmwd if record_id==""

replace flag626=plad if record_id==""
replace plad=reperfd if record_id=="" //see above
replace flag1551=plad if record_id==""

replace flag638=fibrd if record_id==""
replace fibrd=reperfd if record_id=="" //see above
replace flag1563=fibrd if record_id==""

replace flag602=aspd if record_id==""
replace aspd=plad if record_id=="" //see above
replace flag1527=aspd if record_id==""



** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id==""|record_id==""|record_id==""|record_id==""

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