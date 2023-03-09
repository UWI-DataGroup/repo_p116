** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3k_clean rx_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      27-FEB-2023
    // 	date last modified      28-FEB-2023
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
count if reperfd!=. & cfadmdate!=. & reperfd<cfadmdate & inhosp!=1 & fmcdate==. //1 - heart record 2052 for review by NS: Leave as is as cannot be confirmed and most likely reperf date is incorrect but cannot verify.
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
** possibly Invalid (reperf time before notified time)
count if reperft!="" & reperft!="99" & ambcallt!="" & ambcallt!="99" & reperft<ambcallt //3 - 2 are correct; heart record 2139 corrected below
** possibly Invalid (reperf time before time at scene)
count if reperft!="" & reperft!="99" & atscnt!="" & atscnt!="99" & reperft<atscnt //3 - same records as above
** possibly Invalid (reperf time before time from scene)
count if reperft!="" & reperft!="99" & frmscnt!="" & frmscnt!="99" & reperft<frmscnt //3 - same records as above
** possibly Invalid (reperf time before time at hospital)
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

replace flagdate=sd_currentdate if record_id=="2139"


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

replace flag562=antih___99 if record_id=="4223"
replace antih___99=1 if record_id=="4223" //see above
replace flag1487=antih___99 if record_id=="4223"

replace flag563=antih___88 if record_id=="4223"
replace antih___88=0 if record_id=="4223" //see above
replace flag1488=antih___88 if record_id=="4223"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2283"|record_id=="4223"


******************
** Aspirin Dose **
******************
** Missing date
count if aspdose==. & asp___1==1 //0
** Invalid missing code
count if aspdose==88|aspdose==99|aspdose==9999 //0
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
** possibly Invalid (asp time before notified time)
count if aspt!="" & aspt!="99" & ambcallt!="" & ambcallt!="99" & aspt<ambcallt //81 - all are correct; stroke records 1916, 2938 heart record 2897 took prior to QEH adm; stroke record 2351 corrected below
** possibly Invalid (asp time before time at scene)
count if aspt!="" & aspt!="99" & atscnt!="" & atscnt!="99" & aspt<atscnt //87 - same records as above
** possibly Invalid (asp time before time from scene)
count if aspt!="" & aspt!="99" & frmscnt!="" & frmscnt!="99" & aspt<frmscnt //85 - same records as above
** possibly Invalid (asp time before time at hospital)
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


replace flag602=aspd if record_id=="2060"|record_id=="2654"|record_id=="2351"
replace aspd=dae if record_id=="2060"|record_id=="2654" //see above
replace aspd=hepd if record_id=="2351" //see above
replace flag1527=aspd if record_id=="2060"|record_id=="2654"|record_id=="2351"

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
replace flagdate=sd_currentdate if record_id=="2060"|record_id=="2654"|record_id=="2139"|record_id=="3361"|record_id=="2351"

*******************
** Warfarin Date **
*******************
** Missing date
count if warfd==. & warf___1==1 //0
** Invalid (not 2021)
count if warfd!=. & year(warfd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & warfd!=. & warfd<dob //0
** possibly Invalid (before CFAdmDate)
count if warfd!=. & cfadmdate!=. & warfd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & warfd!=. & warfd>dlc //0
count if cfdod!=. & warfd!=. & warfd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if warfd!=. & dae!=. & warfd<dae & inhosp!=1 & fmcdate==. //0
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
count if warfd!=. & ambcalld!=. & warfd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if warfd!=. & atscnd!=. & warfd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if warfd!=. & frmscnd!=. & warfd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if warfd!=. & hospd!=. & warfd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if warfd!=. & edate!=. & warfd<edate //0
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
** possibly Invalid (warf time before notified time)
count if warft!="" & warft!="99" & ambcallt!="" & ambcallt!="99" & warft<ambcallt //0
** possibly Invalid (warf time before time at scene)
count if warft!="" & warft!="99" & atscnt!="" & atscnt!="99" & warft<atscnt //1 - heart record 2071 is correct
** possibly Invalid (warf time before time from scene)
count if warft!="" & warft!="99" & frmscnt!="" & frmscnt!="99" & warft<frmscnt //1 - same record as above
** possibly Invalid (warf time before time at hospital)
count if warft!="" & warft!="99" & hospt!="" & hospt!="99" & warft<hospt //1 - same record as above
** Invalid (warf time before event time)
count if warft!="" & warft!="99" & etime!="" & etime!="99" & warft<etime //0
** Invalid missing code
count if warftampm==88|warftampm==99|warftampm==999|warftampm==9999 //0

**************************
** Heparin (sc/iv) Date **
**************************
** Missing date
count if hepd==. & hep___1==1 //0
** Invalid (not 2021)
count if hepd!=. & year(hepd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hepd!=. & hepd<dob //0
** possibly Invalid (before CFAdmDate)
count if hepd!=. & cfadmdate!=. & hepd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hepd!=. & hepd>dlc //1 - stroke record 2038 corrected below
count if cfdod!=. & hepd!=. & hepd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if hepd!=. & dae!=. & hepd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if hepd!=. & doh!=. & hepd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if hepd!=. & hepd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hep___1==1 & hepd==. & hepdday==99 & hepdmonth==99 & hepdyear==9999 //0
** possibly Invalid (hep date not partial but partial field not blank)
count if hepd==. & hepdday!=. & hepdmonth!=. & hepdyear!=. //0
replace hepdday=. if hepd==. & hepdday!=. & hepdmonth!=. & hepdyear!=. //0 changes
replace hepdmonth=. if hepd==. & hepdmonth!=. & hepdyear!=. //0 changes
replace hepdyear=. if hepd==. & hepdyear!=. //0 changes
count if hepd==. & (hepdday!=. | hepdmonth!=. | hepdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if hepdday==88|hepdday==999|hepdday==9999 //0
count if hepdmonth==88|hepdmonth==999|hepdmonth==9999 //0
count if hepdyear==88|hepdyear==99|hepdyear==999 //0
** Invalid (before NotifiedDate)
count if hepd!=. & ambcalld!=. & hepd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if hepd!=. & atscnd!=. & hepd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if hepd!=. & frmscnd!=. & hepd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if hepd!=. & hospd!=. & hepd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hepd!=. & edate!=. & hepd<edate //0
** Missing time
count if hept=="" & hep___1==1 //0
** Invalid (time format)
count if hept!="" & hept!="88" & hept!="99" & (length(hept)<5|length(hept)>5) //0
count if hept!="" & hept!="88" & hept!="99" & !strmatch(strupper(hept), "*:*") //0
generate byte non_numeric_hept = indexnot(hept, "0123456789.-:")
count if non_numeric_hept //0
** Invalid missing code
count if hept=="999"|hept=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if hept=="88" & heptampm==. //0
** possibly Invalid (hep time before notified time)
count if hept!="" & hept!="99" & ambcallt!="" & ambcallt!="99" & hept<ambcallt //29 - all correct
** possibly Invalid (hep time before time at scene)
count if hept!="" & hept!="99" & atscnt!="" & atscnt!="99" & hept<atscnt //30 - all correct except stroke record 2261 corrected below
** possibly Invalid (hep time before time from scene)
count if hept!="" & hept!="99" & frmscnt!="" & frmscnt!="99" & hept<frmscnt //30 - all correct
** possibly Invalid (hep time before time at hospital)
count if hept!="" & hept!="99" & hospt!="" & hospt!="99" & hept<hospt //26 - all correct
** Invalid (hep time before event time)
count if hept!="" & hept!="99" & etime!="" & etime!="99" & hept<etime //42 - all are correct
** Invalid missing code
count if heptampm==88|heptampm==99|heptampm==999|heptampm==9999 //0

************************
** Heparin (lmw) Date **
************************
** Missing date
count if heplmwd==. & heplmw___1==1 //1 - entered as 99 in CVDdb
** Invalid (not 2021)
count if heplmwd!=. & year(heplmwd)!=2021 //1 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & heplmwd!=. & heplmwd<dob //0
** possibly Invalid (before CFAdmDate)
count if heplmwd!=. & cfadmdate!=. & heplmwd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & heplmwd!=. & heplmwd>dlc //0
count if cfdod!=. & heplmwd!=. & heplmwd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if heplmwd!=. & dae!=. & heplmwd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if heplmwd!=. & doh!=. & heplmwd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if heplmwd!=. & heplmwd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if heplmw___1==1 & heplmwd==. & heplmwdday==99 & heplmwdmonth==99 & heplmwdyear==9999 //0
** possibly Invalid (heplmw date not partial but partial field not blank)
count if heplmwd==. & heplmwdday!=. & heplmwdmonth!=. & heplmwdyear!=. //0
replace heplmwdday=. if heplmwd==. & heplmwdday!=. & heplmwdmonth!=. & heplmwdyear!=. //0 changes
replace heplmwdmonth=. if heplmwd==. & heplmwdmonth!=. & heplmwdyear!=. //0 changes
replace heplmwdyear=. if heplmwd==. & heplmwdyear!=. //0 changes
count if heplmwd==. & (heplmwdday!=. | heplmwdmonth!=. | heplmwdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if heplmwdday==88|heplmwdday==999|heplmwdday==9999 //0
count if heplmwdmonth==88|heplmwdmonth==999|heplmwdmonth==9999 //0
count if heplmwdyear==88|heplmwdyear==99|heplmwdyear==999 //0
** Invalid (before NotifiedDate)
count if heplmwd!=. & ambcalld!=. & heplmwd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if heplmwd!=. & atscnd!=. & heplmwd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if heplmwd!=. & frmscnd!=. & heplmwd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if heplmwd!=. & hospd!=. & heplmwd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if heplmwd!=. & edate!=. & heplmwd<edate //2 - stroke records 2322 + 3025 are both correct as they're in-hospital events
** Missing time
count if heplmwt=="" & heplmw___1==1 //0
** Invalid (time format)
count if heplmwt!="" & heplmwt!="88" & heplmwt!="99" & (length(heplmwt)<5|length(heplmwt)>5) //0
count if heplmwt!="" & heplmwt!="88" & heplmwt!="99" & !strmatch(strupper(heplmwt), "*:*") //0
generate byte non_numeric_heplmwt = indexnot(heplmwt, "0123456789.-:")
count if non_numeric_heplmwt //0
** Invalid missing code
count if heplmwt=="999"|heplmwt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if heplmwt=="88" & heplmwtampm==. //0
** possibly Invalid (heplmw time before notified time)
count if heplmwt!="" & heplmwt!="99" & ambcallt!="" & ambcallt!="99" & heplmwt<ambcallt //20 - all are correct
** possibly Invalid (heplmw time before time at scene)
count if heplmwt!="" & heplmwt!="99" & atscnt!="" & atscnt!="99" & heplmwt<atscnt //21 - all correct
** possibly Invalid (heplmw time before time from scene)
count if heplmwt!="" & heplmwt!="99" & frmscnt!="" & frmscnt!="99" & heplmwt<frmscnt //21 - all correct
** possibly Invalid (heplmw time before time at hospital)
count if heplmwt!="" & heplmwt!="99" & hospt!="" & hospt!="99" & heplmwt<hospt //26 - all correct
** Invalid (heplmw time before event time)
count if heplmwt!="" & heplmwt!="99" & etime!="" & etime!="99" & heplmwt<etime //53 - all are correct except heart record 2045 for NS to review - reviewed and corrected below
** Invalid missing code
count if heplmwtampm==88|heplmwtampm==99|heplmwtampm==999|heplmwtampm==9999 //0

************************
** Antiplatelets Date **
************************
** Missing date
count if plad==. & pla___1==1 //1 - entered as 99 in CVDdb
** Invalid (not 2021)
count if plad!=. & year(plad)!=2021 //1 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & plad!=. & plad<dob //0
** possibly Invalid (before CFAdmDate)
count if plad!=. & cfadmdate!=. & plad<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & plad!=. & plad>dlc //0
count if cfdod!=. & plad!=. & plad>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if plad!=. & dae!=. & plad<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if plad!=. & doh!=. & plad>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if plad!=. & plad>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if pla___1==1 & plad==. & pladday==99 & pladmonth==99 & pladyear==9999 //0
** possibly Invalid (pla date not partial but partial field not blank)
count if plad==. & pladday!=. & pladmonth!=. & pladyear!=. //0
replace pladday=. if plad==. & pladday!=. & pladmonth!=. & pladyear!=. //0 changes
replace pladmonth=. if plad==. & pladmonth!=. & pladyear!=. //0 changes
replace pladyear=. if plad==. & pladyear!=. //0 changes
count if plad==. & (pladday!=. | pladmonth!=. | pladyear!=.) //0
** Invalid missing code (notified date partial fields)
count if pladday==88|pladday==999|pladday==9999 //0
count if pladmonth==88|pladmonth==999|pladmonth==9999 //0
count if pladyear==88|pladyear==99|pladyear==999 //0
** Invalid (before NotifiedDate)
count if plad!=. & ambcalld!=. & plad<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if plad!=. & atscnd!=. & plad<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if plad!=. & frmscnd!=. & plad<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if plad!=. & hospd!=. & plad<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if plad!=. & edate!=. & plad<edate //1 - stroke record 2322 is correct as it's an in-hospital event
** Missing time
count if plat=="" & pla___1==1 //0
** Invalid (time format)
count if plat!="" & plat!="88" & plat!="99" & (length(plat)<5|length(plat)>5) //0
count if plat!="" & plat!="88" & plat!="99" & !strmatch(strupper(plat), "*:*") //0
generate byte non_numeric_plat = indexnot(plat, "0123456789.-:")
count if non_numeric_plat //0
** Invalid missing code
count if plat=="999"|plat=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if plat=="88" & platampm==. //0
** possibly Invalid (pla time before notified time)
count if plat!="" & plat!="99" & ambcallt!="" & ambcallt!="99" & plat<ambcallt //25 - all are correct; heart records 2897 + 3402 ecg, trop done at SCMC + CMC, respectively, prior to QEH so meds given then too
** possibly Invalid (pla time before time at scene)
count if plat!="" & plat!="99" & atscnt!="" & atscnt!="99" & plat<atscnt //28 - all correct except heart record 3030 corrected below; heart record 3402 ecg, trop done at CMC prior to QEH and meds given then too
** possibly Invalid (pla time before time from scene)
count if plat!="" & plat!="99" & frmscnt!="" & frmscnt!="99" & plat<frmscnt //28 - all correct; heart record 2071 for NS to review (leave as is since GPs can and do give antiplatelets to pts prior to QEH); heart record 2897 took prior to QEH adm; heart record 3030 corrected below
** possibly Invalid (pla time before time at hospital)
count if plat!="" & plat!="99" & hospt!="" & hospt!="99" & plat<hospt //22 - all correct except ones already flagged above
** Invalid (pla time before event time)
count if plat!="" & plat!="99" & etime!="" & etime!="99" & plat<etime //56 - all are correct except heart record 2702 corrected below; stroke record 3096 for NS to review
** Invalid missing code
count if platampm==88|platampm==99|platampm==999|platampm==9999 //0

*****************
** Statin Date **
*****************
** Missing date
count if statd==. & stat___1==1 //0
** Invalid (not 2021)
count if statd!=. & year(statd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & statd!=. & statd<dob //0
** possibly Invalid (before CFAdmDate)
count if statd!=. & cfadmdate!=. & statd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & statd!=. & statd>dlc //0
count if cfdod!=. & statd!=. & statd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if statd!=. & dae!=. & statd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if statd!=. & doh!=. & statd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if statd!=. & statd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if stat___1==1 & statd==. & statdday==99 & statdmonth==99 & statdyear==9999 //0
** possibly Invalid (stat date not partial but partial field not blank)
count if statd==. & statdday!=. & statdmonth!=. & statdyear!=. //0
replace statdday=. if statd==. & statdday!=. & statdmonth!=. & statdyear!=. //0 changes
replace statdmonth=. if statd==. & statdmonth!=. & statdyear!=. //0 changes
replace statdyear=. if statd==. & statdyear!=. //0 changes
count if statd==. & (statdday!=. | statdmonth!=. | statdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if statdday==88|statdday==999|statdday==9999 //0
count if statdmonth==88|statdmonth==999|statdmonth==9999 //0
count if statdyear==88|statdyear==99|statdyear==999 //0
** Invalid (before NotifiedDate)
count if statd!=. & ambcalld!=. & statd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if statd!=. & atscnd!=. & statd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if statd!=. & frmscnd!=. & statd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if statd!=. & hospd!=. & statd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if statd!=. & edate!=. & statd<edate //1 - stroke record 2322 is correct as it's an in-hospital event
** Missing time
count if statt=="" & stat___1==1 //0
** Invalid (time format)
count if statt!="" & statt!="88" & statt!="99" & (length(statt)<5|length(statt)>5) //0
count if statt!="" & statt!="88" & statt!="99" & !strmatch(strupper(statt), "*:*") //0
generate byte non_numeric_statt = indexnot(statt, "0123456789.-:")
count if non_numeric_statt //0
** Invalid missing code
count if statt=="999"|statt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if statt=="88" & stattampm==. //0
** possibly Invalid (stat time before notified time)
count if statt!="" & statt!="99" & ambcallt!="" & ambcallt!="99" & statt<ambcallt //23 - all are correct
** possibly Invalid (stat time before time at scene)
count if statt!="" & statt!="99" & atscnt!="" & atscnt!="99" & statt<atscnt //25 - all correct
** possibly Invalid (stat time before time from scene)
count if statt!="" & statt!="99" & frmscnt!="" & frmscnt!="99" & statt<frmscnt //26 - all correct
** possibly Invalid (stat time before time at hospital)
count if statt!="" & statt!="99" & hospt!="" & hospt!="99" & statt<hospt //24 - all correct
** Invalid (stat time before event time)
count if statt!="" & statt!="99" & etime!="" & etime!="99" & statt<etime //38 - all are correct
** Invalid missing code
count if stattampm==88|stattampm==99|stattampm==999|stattampm==9999 //0

************************
** Fibrinolytics Date **
************************
** Missing date
count if fibrd==. & fibr___1==1 //0
** Invalid (not 2021)
count if fibrd!=. & year(fibrd)!=2021 //1 - correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & fibrd!=. & fibrd<dob //0
** possibly Invalid (before CFAdmDate)
count if fibrd!=. & cfadmdate!=. & fibrd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & fibrd!=. & fibrd>dlc //0
count if cfdod!=. & fibrd!=. & fibrd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if fibrd!=. & dae!=. & fibrd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if fibrd!=. & doh!=. & fibrd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if fibrd!=. & fibrd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if fibr___1==1 & fibrd==. & fibrdday==99 & fibrdmonth==99 & fibrdyear==9999 //0
** possibly Invalid (fibr date not partial but partial field not blank)
count if fibrd==. & fibrdday!=. & fibrdmonth!=. & fibrdyear!=. //0
replace fibrdday=. if fibrd==. & fibrdday!=. & fibrdmonth!=. & fibrdyear!=. //0 changes
replace fibrdmonth=. if fibrd==. & fibrdmonth!=. & fibrdyear!=. //0 changes
replace fibrdyear=. if fibrd==. & fibrdyear!=. //0 changes
count if fibrd==. & (fibrdday!=. | fibrdmonth!=. | fibrdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if fibrdday==88|fibrdday==999|fibrdday==9999 //0
count if fibrdmonth==88|fibrdmonth==999|fibrdmonth==9999 //0
count if fibrdyear==88|fibrdyear==99|fibrdyear==999 //0
** Invalid (before NotifiedDate)
count if fibrd!=. & ambcalld!=. & fibrd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if fibrd!=. & atscnd!=. & fibrd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if fibrd!=. & frmscnd!=. & fibrd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if fibrd!=. & hospd!=. & fibrd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if fibrd!=. & edate!=. & fibrd<edate //1 - stroke record 2322 is correct as it's an in-hospital event
** Missing time
count if fibrt=="" & fibr___1==1 //0
** Invalid (time format)
count if fibrt!="" & fibrt!="88" & fibrt!="99" & (length(fibrt)<5|length(fibrt)>5) //0
count if fibrt!="" & fibrt!="88" & fibrt!="99" & !strmatch(strupper(fibrt), "*:*") //0
generate byte non_numeric_fibrt = indexnot(fibrt, "0123456789.-:")
count if non_numeric_fibrt //0
** Invalid missing code
count if fibrt=="999"|fibrt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if fibrt=="88" & fibrtampm==. //0
** possibly Invalid (fibr time before notified time)
count if fibrt!="" & fibrt!="99" & ambcallt!="" & ambcallt!="99" & fibrt<ambcallt //3 - all are correct
** possibly Invalid (fibr time before time at scene)
count if fibrt!="" & fibrt!="99" & atscnt!="" & atscnt!="99" & fibrt<atscnt //3 - all correct
** possibly Invalid (fibr time before time from scene)
count if fibrt!="" & fibrt!="99" & frmscnt!="" & frmscnt!="99" & fibrt<frmscnt //3 - all correct
** possibly Invalid (fibr time before time at hospital)
count if fibrt!="" & fibrt!="99" & hospt!="" & hospt!="99" & fibrt<hospt //3 - all correct
** Invalid (fibr time before event time)
count if fibrt!="" & fibrt!="99" & etime!="" & etime!="99" & fibrt<etime //10 - all are correct
** Invalid missing code
count if fibrtampm==88|fibrtampm==99|fibrtampm==999|fibrtampm==9999 //0

**************
** ACE Date **
**************
** Missing date
count if aced==. & ace___1==1 //0
** Invalid (not 2021)
count if aced!=. & year(aced)!=2021 //0
** Invalid (before DOB)
count if dob!=. & aced!=. & aced<dob //0
** possibly Invalid (before CFAdmDate)
count if aced!=. & cfadmdate!=. & aced<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & aced!=. & aced>dlc //0
count if cfdod!=. & aced!=. & aced>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if aced!=. & dae!=. & aced<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if aced!=. & doh!=. & aced>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if aced!=. & aced>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ace___1==1 & aced==. & acedday==99 & acedmonth==99 & acedyear==9999 //0
** possibly Invalid (ace date not partial but partial field not blank)
count if aced==. & acedday!=. & acedmonth!=. & acedyear!=. //0
replace acedday=. if aced==. & acedday!=. & acedmonth!=. & acedyear!=. //0 changes
replace acedmonth=. if aced==. & acedmonth!=. & acedyear!=. //0 changes
replace acedyear=. if aced==. & acedyear!=. //0 changes
count if aced==. & (acedday!=. | acedmonth!=. | acedyear!=.) //0
** Invalid missing code (notified date partial fields)
count if acedday==88|acedday==999|acedday==9999 //0
count if acedmonth==88|acedmonth==999|acedmonth==9999 //0
count if acedyear==88|acedyear==99|acedyear==999 //0
** Invalid (before NotifiedDate)
count if aced!=. & ambcalld!=. & aced<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if aced!=. & atscnd!=. & aced<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if aced!=. & frmscnd!=. & aced<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if aced!=. & hospd!=. & aced<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if aced!=. & edate!=. & aced<edate //0
** Missing time
count if acet=="" & ace___1==1 //0
** Invalid (time format)
count if acet!="" & acet!="88" & acet!="99" & (length(acet)<5|length(acet)>5) //0
count if acet!="" & acet!="88" & acet!="99" & !strmatch(strupper(acet), "*:*") //0
generate byte non_numeric_acet = indexnot(acet, "0123456789.-:")
count if non_numeric_acet //0
** Invalid missing code
count if acet=="999"|acet=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if acet=="88" & acetampm==. //0
** possibly Invalid (ace time before notified time)
count if acet!="" & acet!="99" & ambcallt!="" & ambcallt!="99" & acet<ambcallt //7 - all are correct
** possibly Invalid (ace time before time at scene)
count if acet!="" & acet!="99" & atscnt!="" & atscnt!="99" & acet<atscnt //9 - all correct
** possibly Invalid (ace time before time from scene)
count if acet!="" & acet!="99" & frmscnt!="" & frmscnt!="99" & acet<frmscnt //9 - all correct
** possibly Invalid (ace time before time at hospital)
count if acet!="" & acet!="99" & hospt!="" & hospt!="99" & acet<hospt //8 - all correct
** Invalid (ace time before event time)
count if acet!="" & acet!="99" & etime!="" & etime!="99" & acet<etime //14 - all are correct
** Invalid missing code
count if acetampm==88|acetampm==99|acetampm==999|acetampm==9999 //0

***************
** ARBs Date **
***************
** Missing date
count if arbsd==. & arbs___1==1 //0
** Invalid (not 2021)
count if arbsd!=. & year(arbsd)!=2021 //1 - stroke record 2266 corrected below
** Invalid (before DOB)
count if dob!=. & arbsd!=. & arbsd<dob //0
** possibly Invalid (before CFAdmDate)
count if arbsd!=. & cfadmdate!=. & arbsd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & arbsd!=. & arbsd>dlc //1 - stroke record 2266 already flagged above
count if cfdod!=. & arbsd!=. & arbsd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if arbsd!=. & dae!=. & arbsd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if arbsd!=. & doh!=. & arbsd>doh & inhosp!=1 & fmcdate==. //1 - stroke record 2266 already flagged above
** Invalid (future date)
count if arbsd!=. & arbsd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if arbs___1==1 & arbsd==. & arbsdday==99 & arbsdmonth==99 & arbsdyear==9999 //0
** possibly Invalid (arbs date not partial but partial field not blank)
count if arbsd==. & arbsdday!=. & arbsdmonth!=. & arbsdyear!=. //0
replace arbsdday=. if arbsd==. & arbsdday!=. & arbsdmonth!=. & arbsdyear!=. //0 changes
replace arbsdmonth=. if arbsd==. & arbsdmonth!=. & arbsdyear!=. //0 changes
replace arbsdyear=. if arbsd==. & arbsdyear!=. //0 changes
count if arbsd==. & (arbsdday!=. | arbsdmonth!=. | arbsdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if arbsdday==88|arbsdday==999|arbsdday==9999 //0
count if arbsdmonth==88|arbsdmonth==999|arbsdmonth==9999 //0
count if arbsdyear==88|arbsdyear==99|arbsdyear==999 //0
** Invalid (before NotifiedDate)
count if arbsd!=. & ambcalld!=. & arbsd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if arbsd!=. & atscnd!=. & arbsd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if arbsd!=. & frmscnd!=. & arbsd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if arbsd!=. & hospd!=. & arbsd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if arbsd!=. & edate!=. & arbsd<edate //0
** Missing time
count if arbst=="" & arbs___1==1 //0
** Invalid (time format)
count if arbst!="" & arbst!="88" & arbst!="99" & (length(arbst)<5|length(arbst)>5) //0
count if arbst!="" & arbst!="88" & arbst!="99" & !strmatch(strupper(arbst), "*:*") //0
generate byte non_numeric_arbst = indexnot(arbst, "0123456789.-:")
count if non_numeric_arbst //0
** Invalid missing code
count if arbst=="999"|arbst=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if arbst=="88" & arbstampm==. //0
** possibly Invalid (arbs time before notified time)
count if arbst!="" & arbst!="99" & ambcallt!="" & ambcallt!="99" & arbst<ambcallt //8 - all are correct
** possibly Invalid (arbs time before time at scene)
count if arbst!="" & arbst!="99" & atscnt!="" & atscnt!="99" & arbst<atscnt //8 - all correct
** possibly Invalid (arbs time before time from scene)
count if arbst!="" & arbst!="99" & frmscnt!="" & frmscnt!="99" & arbst<frmscnt //9 - all correct
** possibly Invalid (arbs time before time at hospital)
count if arbst!="" & arbst!="99" & hospt!="" & hospt!="99" & arbst<hospt //6 - all correct
** Invalid (arbs time before event time)
count if arbst!="" & arbst!="99" & etime!="" & etime!="99" & arbst<etime //12 - all are correct except stroke record 4229 corrected below
** Invalid missing code
count if arbstampm==88|arbstampm==99|arbstampm==999|arbstampm==9999 //0

**************************
** Corticosteroids Date **
**************************
** Missing date
count if corsd==. & cors___1==1 //0
** Invalid (not 2021)
count if corsd!=. & year(corsd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & corsd!=. & corsd<dob //0
** possibly Invalid (before CFAdmDate)
count if corsd!=. & cfadmdate!=. & corsd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & corsd!=. & corsd>dlc //0
count if cfdod!=. & corsd!=. & corsd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if corsd!=. & dae!=. & corsd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if corsd!=. & doh!=. & corsd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if corsd!=. & corsd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if cors___1==1 & corsd==. & corsdday==99 & corsdmonth==99 & corsdyear==9999 //0
** possibly Invalid (cors date not partial but partial field not blank)
count if corsd==. & corsdday!=. & corsdmonth!=. & corsdyear!=. //0
replace corsdday=. if corsd==. & corsdday!=. & corsdmonth!=. & corsdyear!=. //0 changes
replace corsdmonth=. if corsd==. & corsdmonth!=. & corsdyear!=. //0 changes
replace corsdyear=. if corsd==. & corsdyear!=. //0 changes
count if corsd==. & (corsdday!=. | corsdmonth!=. | corsdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if corsdday==88|corsdday==999|corsdday==9999 //0
count if corsdmonth==88|corsdmonth==999|corsdmonth==9999 //0
count if corsdyear==88|corsdyear==99|corsdyear==999 //0
** Invalid (before NotifiedDate)
count if corsd!=. & ambcalld!=. & corsd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if corsd!=. & atscnd!=. & corsd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if corsd!=. & frmscnd!=. & corsd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if corsd!=. & hospd!=. & corsd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if corsd!=. & edate!=. & corsd<edate //0
** Missing time
count if corst=="" & cors___1==1 //0
** Invalid (time format)
count if corst!="" & corst!="88" & corst!="99" & (length(corst)<5|length(corst)>5) //0
count if corst!="" & corst!="88" & corst!="99" & !strmatch(strupper(corst), "*:*") //0
generate byte non_numeric_corst = indexnot(corst, "0123456789.-:")
count if non_numeric_corst //0
** Invalid missing code
count if corst=="999"|corst=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if corst=="88" & corstampm==. //0
** possibly Invalid (cors time before notified time)
count if corst!="" & corst!="99" & ambcallt!="" & ambcallt!="99" & corst<ambcallt //3 - all are correct
** possibly Invalid (cors time before time at scene)
count if corst!="" & corst!="99" & atscnt!="" & atscnt!="99" & corst<atscnt //3 - all correct
** possibly Invalid (cors time before time from scene)
count if corst!="" & corst!="99" & frmscnt!="" & frmscnt!="99" & corst<frmscnt //2 - all correct
** possibly Invalid (cors time before time at hospital)
count if corst!="" & corst!="99" & hospt!="" & hospt!="99" & corst<hospt //1 - all correct
** Invalid (cors time before event time)
count if corst!="" & corst!="99" & etime!="" & etime!="99" & corst<etime //2 - all are correct
** Invalid missing code
count if corstampm==88|corstampm==99|corstampm==999|corstampm==9999 //0

****************************
** Antihypertensives Date **
****************************
** Missing date
count if antihd==. & antih___1==1 //0
** Invalid (not 2021)
count if antihd!=. & year(antihd)!=2021 //2 - stroke record 2266 already corrected below; stroke record 3416 correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & antihd!=. & antihd<dob //0
** possibly Invalid (before CFAdmDate)
count if antihd!=. & cfadmdate!=. & antihd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & antihd!=. & antihd>dlc //1 - stroke record 2266 already flagged above
count if cfdod!=. & antihd!=. & antihd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if antihd!=. & dae!=. & antihd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if antihd!=. & doh!=. & antihd>doh & inhosp!=1 & fmcdate==. //2 - stroke record 2266 already flagged above; stroke record 2623 is correct
** Invalid (future date)
count if antihd!=. & antihd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if antih___1==1 & antihd==. & antihdday==99 & antihdmonth==99 & antihdyear==9999 //0
** possibly Invalid (antih date not partial but partial field not blank)
count if antihd==. & antihdday!=. & antihdmonth!=. & antihdyear!=. //0
replace antihdday=. if antihd==. & antihdday!=. & antihdmonth!=. & antihdyear!=. //0 changes
replace antihdmonth=. if antihd==. & antihdmonth!=. & antihdyear!=. //0 changes
replace antihdyear=. if antihd==. & antihdyear!=. //0 changes
count if antihd==. & (antihdday!=. | antihdmonth!=. | antihdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if antihdday==88|antihdday==999|antihdday==9999 //0
count if antihdmonth==88|antihdmonth==999|antihdmonth==9999 //0
count if antihdyear==88|antihdyear==99|antihdyear==999 //0
** Invalid (before NotifiedDate)
count if antihd!=. & ambcalld!=. & antihd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if antihd!=. & atscnd!=. & antihd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if antihd!=. & frmscnd!=. & antihd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if antihd!=. & hospd!=. & antihd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if antihd!=. & edate!=. & antihd<edate //1 - stroke record 2322 is correct as it's an in-hospital event
** Missing time
count if antiht=="" & antih___1==1 //0
** Invalid (time format)
count if antiht!="" & antiht!="88" & antiht!="99" & (length(antiht)<5|length(antiht)>5) //0
count if antiht!="" & antiht!="88" & antiht!="99" & !strmatch(strupper(antiht), "*:*") //0
generate byte non_numeric_antiht = indexnot(antiht, "0123456789.-:")
count if non_numeric_antiht //0
** Invalid missing code
count if antiht=="999"|antiht=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if antiht=="88" & antihtampm==. //0
** possibly Invalid (antih time before notified time)
count if antiht!="" & antiht!="99" & ambcallt!="" & ambcallt!="99" & antiht<ambcallt //22 - all are correct except stroke record 2351 corrected below
** possibly Invalid (antih time before time at scene)
count if antiht!="" & antiht!="99" & atscnt!="" & atscnt!="99" & antiht<atscnt //24 - all correct except stroke records 2430 + 2537 corrected below
** possibly Invalid (antih time before time from scene)
count if antiht!="" & antiht!="99" & frmscnt!="" & frmscnt!="99" & antiht<frmscnt //23 - all correct
** possibly Invalid (antih time before time at hospital)
count if antiht!="" & antiht!="99" & hospt!="" & hospt!="99" & antiht<hospt //21 - all correct except stroke record 2220 corrected below
** Invalid (antih time before event time)
count if antiht!="" & antiht!="99" & etime!="" & etime!="99" & antiht<etime //39 - all are correct
** Invalid missing code
count if antihtampm==88|antihtampm==99|antihtampm==999|antihtampm==9999 //0

*********************
** Nimodipine Date **
*********************
** Missing date
count if nimod==. & nimo___1==1 //0
** Invalid (not 2021)
count if nimod!=. & year(nimod)!=2021 //0
** Invalid (before DOB)
count if dob!=. & nimod!=. & nimod<dob //0
** possibly Invalid (before CFAdmDate)
count if nimod!=. & cfadmdate!=. & nimod<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & nimod!=. & nimod>dlc //0
count if cfdod!=. & nimod!=. & nimod>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if nimod!=. & dae!=. & nimod<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if nimod!=. & doh!=. & nimod>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if nimod!=. & nimod>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if nimo___1==1 & nimod==. & nimodday==99 & nimodmonth==99 & nimodyear==9999 //0
** possibly Invalid (nimo date not partial but partial field not blank)
count if nimod==. & nimodday!=. & nimodmonth!=. & nimodyear!=. //0
replace nimodday=. if nimod==. & nimodday!=. & nimodmonth!=. & nimodyear!=. //0 changes
replace nimodmonth=. if nimod==. & nimodmonth!=. & nimodyear!=. //0 changes
replace nimodyear=. if nimod==. & nimodyear!=. //0 changes
count if nimod==. & (nimodday!=. | nimodmonth!=. | nimodyear!=.) //0
** Invalid missing code (notified date partial fields)
count if nimodday==88|nimodday==999|nimodday==9999 //0
count if nimodmonth==88|nimodmonth==999|nimodmonth==9999 //0
count if nimodyear==88|nimodyear==99|nimodyear==999 //0
** Invalid (before NotifiedDate)
count if nimod!=. & ambcalld!=. & nimod<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if nimod!=. & atscnd!=. & nimod<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if nimod!=. & frmscnd!=. & nimod<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if nimod!=. & hospd!=. & nimod<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if nimod!=. & edate!=. & nimod<edate //0
** Missing time
count if nimot=="" & nimo___1==1 //0
** Invalid (time format)
count if nimot!="" & nimot!="88" & nimot!="99" & (length(nimot)<5|length(nimot)>5) //0
count if nimot!="" & nimot!="88" & nimot!="99" & !strmatch(strupper(nimot), "*:*") //0
generate byte non_numeric_nimot = indexnot(nimot, "0123456789.-:")
count if non_numeric_nimot //0
** Invalid missing code
count if nimot=="999"|nimot=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if nimot=="88" & nimotampm==. //0
** possibly Invalid (nimo time before notified time)
count if nimot!="" & nimot!="99" & ambcallt!="" & ambcallt!="99" & nimot<ambcallt //1 - all are correct
** possibly Invalid (nimo time before time at scene)
count if nimot!="" & nimot!="99" & atscnt!="" & atscnt!="99" & nimot<atscnt //1 - all correct
** possibly Invalid (nimo time before time from scene)
count if nimot!="" & nimot!="99" & frmscnt!="" & frmscnt!="99" & nimot<frmscnt //1 - all correct
** possibly Invalid (nimo time before time at hospital)
count if nimot!="" & nimot!="99" & hospt!="" & hospt!="99" & nimot<hospt //1 - all correct except stroke record 2220 corrected below
** Invalid (nimo time before event time)
count if nimot!="" & nimot!="99" & etime!="" & etime!="99" & nimot<etime //2 - all are correct
** Invalid missing code
count if nimotampm==88|nimotampm==99|nimotampm==999|nimotampm==9999 //0

***********************
** Antiseizures Date **
***********************
** Missing date
count if antisd==. & antis___1==1 //0
** Invalid (not 2021)
count if antisd!=. & year(antisd)!=2021 //1 - stroke record 3416 correct as event 31dec2021 but adm on 01jan2022
** Invalid (before DOB)
count if dob!=. & antisd!=. & antisd<dob //0
** possibly Invalid (before CFAdmDate)
count if antisd!=. & cfadmdate!=. & antisd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & antisd!=. & antisd>dlc //0
count if cfdod!=. & antisd!=. & antisd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if antisd!=. & dae!=. & antisd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if antisd!=. & doh!=. & antisd>doh & inhosp!=1 & fmcdate==. //1 - stroke record 2623 is correct
** Invalid (future date)
count if antisd!=. & antisd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if antis___1==1 & antisd==. & antisdday==99 & antisdmonth==99 & antisdyear==9999 //0
** possibly Invalid (antis date not partial but partial field not blank)
count if antisd==. & antisdday!=. & antisdmonth!=. & antisdyear!=. //0
replace antisdday=. if antisd==. & antisdday!=. & antisdmonth!=. & antisdyear!=. //0 changes
replace antisdmonth=. if antisd==. & antisdmonth!=. & antisdyear!=. //0 changes
replace antisdyear=. if antisd==. & antisdyear!=. //0 changes
count if antisd==. & (antisdday!=. | antisdmonth!=. | antisdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if antisdday==88|antisdday==999|antisdday==9999 //0
count if antisdmonth==88|antisdmonth==999|antisdmonth==9999 //0
count if antisdyear==88|antisdyear==99|antisdyear==999 //0
** Invalid (before NotifiedDate)
count if antisd!=. & ambcalld!=. & antisd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if antisd!=. & atscnd!=. & antisd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if antisd!=. & frmscnd!=. & antisd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if antisd!=. & hospd!=. & antisd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if antisd!=. & edate!=. & antisd<edate //0
** Missing time
count if antist=="" & antis___1==1 //0
** Invalid (time format)
count if antist!="" & antist!="88" & antist!="99" & (length(antist)<5|length(antist)>5) //0
count if antist!="" & antist!="88" & antist!="99" & !strmatch(strupper(antist), "*:*") //0
generate byte non_numeric_antist = indexnot(antist, "0123456789.-:")
count if non_numeric_antist //0
** Invalid missing code
count if antist=="999"|antist=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if antist=="88" & antistampm==. //0
** possibly Invalid (antis time before notified time)
count if antist!="" & antist!="99" & ambcallt!="" & ambcallt!="99" & antist<ambcallt //4 - all are correct
** possibly Invalid (antis time before time at scene)
count if antist!="" & antist!="99" & atscnt!="" & atscnt!="99" & antist<atscnt //4 - all correct except record 2537 already flagged above
** possibly Invalid (antis time before time from scene)
count if antist!="" & antist!="99" & frmscnt!="" & frmscnt!="99" & antist<frmscnt //4 - all correct except record 2537 already flagged above
** possibly Invalid (antis time before time at hospital)
count if antist!="" & antist!="99" & hospt!="" & hospt!="99" & antist<hospt //3 - all correct except record 2537 already flagged above
** Invalid (antis time before event time)
count if antist!="" & antist!="99" & etime!="" & etime!="99" & antist<etime //11 - all are correct
** Invalid missing code
count if antistampm==88|antistampm==99|antistampm==999|antistampm==9999 //0

************************
** TED Stockings Date **
************************
** Missing date
count if tedd==. & ted___1==1 //0
** Invalid (not 2021)
count if tedd!=. & year(tedd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & tedd!=. & tedd<dob //0
** possibly Invalid (before CFAdmDate)
count if tedd!=. & cfadmdate!=. & tedd<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & tedd!=. & tedd>dlc //0
count if cfdod!=. & tedd!=. & tedd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if tedd!=. & dae!=. & tedd<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if tedd!=. & doh!=. & tedd>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if tedd!=. & tedd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ted___1==1 & tedd==. & teddday==99 & teddmonth==99 & teddyear==9999 //0
** possibly Invalid (ted date not partial but partial field not blank)
count if tedd==. & teddday!=. & teddmonth!=. & teddyear!=. //0
replace teddday=. if tedd==. & teddday!=. & teddmonth!=. & teddyear!=. //0 changes
replace teddmonth=. if tedd==. & teddmonth!=. & teddyear!=. //0 changes
replace teddyear=. if tedd==. & teddyear!=. //0 changes
count if tedd==. & (teddday!=. | teddmonth!=. | teddyear!=.) //0
** Invalid missing code (notified date partial fields)
count if teddday==88|teddday==999|teddday==9999 //0
count if teddmonth==88|teddmonth==999|teddmonth==9999 //0
count if teddyear==88|teddyear==99|teddyear==999 //0
** Invalid (before NotifiedDate)
count if tedd!=. & ambcalld!=. & tedd<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if tedd!=. & atscnd!=. & tedd<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if tedd!=. & frmscnd!=. & tedd<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if tedd!=. & hospd!=. & tedd<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if tedd!=. & edate!=. & tedd<edate //0
** Missing time
count if tedt=="" & ted___1==1 //0
** Invalid (time format)
count if tedt!="" & tedt!="88" & tedt!="99" & (length(tedt)<5|length(tedt)>5) //0
count if tedt!="" & tedt!="88" & tedt!="99" & !strmatch(strupper(tedt), "*:*") //0
generate byte non_numeric_tedt = indexnot(tedt, "0123456789.-:")
count if non_numeric_tedt //0
** Invalid missing code
count if tedt=="999"|tedt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if tedt=="88" & tedtampm==. //0
** possibly Invalid (ted time before notified time)
count if tedt!="" & tedt!="99" & ambcallt!="" & ambcallt!="99" & tedt<ambcallt //0
** possibly Invalid (ted time before time at scene)
count if tedt!="" & tedt!="99" & atscnt!="" & atscnt!="99" & tedt<atscnt //0
** possibly Invalid (ted time before time from scene)
count if tedt!="" & tedt!="99" & frmscnt!="" & frmscnt!="99" & tedt<frmscnt //0
** possibly Invalid (ted time before time at hospital)
count if tedt!="" & tedt!="99" & hospt!="" & hospt!="99" & tedt<hospt //0
** Invalid (ted time before event time)
count if tedt!="" & tedt!="99" & etime!="" & etime!="99" & tedt<etime //0
** Invalid missing code
count if tedtampm==88|tedtampm==99|tedtampm==999|tedtampm==9999 //0

************************
** Beta Blockers Date **
************************
** Missing date
count if betad==. & beta___1==1 //0
** Invalid (not 2021)
count if betad!=. & year(betad)!=2021 //0
** Invalid (before DOB)
count if dob!=. & betad!=. & betad<dob //0
** possibly Invalid (before CFAdmDate)
count if betad!=. & cfadmdate!=. & betad<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & betad!=. & betad>dlc //0
count if cfdod!=. & betad!=. & betad>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if betad!=. & dae!=. & betad<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if betad!=. & doh!=. & betad>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if betad!=. & betad>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if beta___1==1 & betad==. & betadday==99 & betadmonth==99 & betadyear==9999 //0
** possibly Invalid (beta date not partial but partial field not blank)
count if betad==. & betadday!=. & betadmonth!=. & betadyear!=. //0
replace betadday=. if betad==. & betadday!=. & betadmonth!=. & betadyear!=. //0 changes
replace betadmonth=. if betad==. & betadmonth!=. & betadyear!=. //0 changes
replace betadyear=. if betad==. & betadyear!=. //0 changes
count if betad==. & (betadday!=. | betadmonth!=. | betadyear!=.) //0
** Invalid missing code (notified date partial fields)
count if betadday==88|betadday==999|betadday==9999 //0
count if betadmonth==88|betadmonth==999|betadmonth==9999 //0
count if betadyear==88|betadyear==99|betadyear==999 //0
** Invalid (before NotifiedDate)
count if betad!=. & ambcalld!=. & betad<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if betad!=. & atscnd!=. & betad<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if betad!=. & frmscnd!=. & betad<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if betad!=. & hospd!=. & betad<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if betad!=. & edate!=. & betad<edate //0
** Missing time
count if betat=="" & beta___1==1 //0
** Invalid (time format)
count if betat!="" & betat!="88" & betat!="99" & (length(betat)<5|length(betat)>5) //0
count if betat!="" & betat!="88" & betat!="99" & !strmatch(strupper(betat), "*:*") //0
generate byte non_numeric_betat = indexnot(betat, "0123456789.-:")
count if non_numeric_betat //0
** Invalid missing code
count if betat=="999"|betat=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if betat=="88" & betatampm==. //0
** possibly Invalid (beta time before notified time)
count if betat!="" & betat!="99" & ambcallt!="" & ambcallt!="99" & betat<ambcallt //8 - all are correct
** possibly Invalid (beta time before time at scene)
count if betat!="" & betat!="99" & atscnt!="" & atscnt!="99" & betat<atscnt //8 - all are correct
** possibly Invalid (beta time before time from scene)
count if betat!="" & betat!="99" & frmscnt!="" & frmscnt!="99" & betat<frmscnt //8 - all are correct
** possibly Invalid (beta time before time at hospital)
count if betat!="" & betat!="99" & hospt!="" & hospt!="99" & betat<hospt //6 - all are correct
** Invalid (beta time before event time)
count if betat!="" & betat!="99" & etime!="" & etime!="99" & betat<etime //13 - all are correct
** Invalid missing code
count if betatampm==88|betatampm==99|betatampm==999|betatampm==9999 //0

*********************
** Bivalrudin Date **
*********************
** Missing date
count if bivald==. & bival___1==1 //0
** Invalid (not 2021)
count if bivald!=. & year(bivald)!=2021 //0
** Invalid (before DOB)
count if dob!=. & bivald!=. & bivald<dob //0
** possibly Invalid (before CFAdmDate)
count if bivald!=. & cfadmdate!=. & bivald<cfadmdate & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & bivald!=. & bivald>dlc //0
count if cfdod!=. & bivald!=. & bivald>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if bivald!=. & dae!=. & bivald<dae & inhosp!=1 & fmcdate==. //0
** possibly Invalid (after WardAdmDate)
count if bivald!=. & doh!=. & bivald>doh & inhosp!=1 & fmcdate==. //0
** Invalid (future date)
count if bivald!=. & bivald>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if bival___1==1 & bivald==. & bivaldday==99 & bivaldmonth==99 & bivaldyear==9999 //0
** possibly Invalid (bival date not partial but partial field not blank)
count if bivald==. & bivaldday!=. & bivaldmonth!=. & bivaldyear!=. //0
replace bivaldday=. if bivald==. & bivaldday!=. & bivaldmonth!=. & bivaldyear!=. //0 changes
replace bivaldmonth=. if bivald==. & bivaldmonth!=. & bivaldyear!=. //0 changes
replace bivaldyear=. if bivald==. & bivaldyear!=. //0 changes
count if bivald==. & (bivaldday!=. | bivaldmonth!=. | bivaldyear!=.) //0
** Invalid missing code (notified date partial fields)
count if bivaldday==88|bivaldday==999|bivaldday==9999 //0
count if bivaldmonth==88|bivaldmonth==999|bivaldmonth==9999 //0
count if bivaldyear==88|bivaldyear==99|bivaldyear==999 //0
** Invalid (before NotifiedDate)
count if bivald!=. & ambcalld!=. & bivald<ambcalld & inhosp!=1 //0
** Invalid (before AtSceneDate)
count if bivald!=. & atscnd!=. & bivald<atscnd & inhosp!=1 //0
** Invalid (before FromSceneDate)
count if bivald!=. & frmscnd!=. & bivald<frmscnd & inhosp!=1 //0
** Invalid (before AtHospitalDate)
count if bivald!=. & hospd!=. & bivald<hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if bivald!=. & edate!=. & bivald<edate //0
** JC 28feb2023: Bivalrudin not selected for any of the cases so time for this med is byte instead of string in Stata
tostring bivalt ,replace
replace bivalt="" if bivalt=="." //1145 changes
** Missing time
count if bivalt=="" & bival___1==1 //0
** Invalid (time format)
count if bivalt!="" & bivalt!="88" & bivalt!="99" & (length(bivalt)<5|length(bivalt)>5) //0
count if bivalt!="" & bivalt!="88" & bivalt!="99" & !strmatch(strupper(bivalt), "*:*") //0
generate byte non_numeric_bivalt = indexnot(bivalt, "0123456789.-:")
count if non_numeric_bivalt //0
** Invalid missing code
count if bivalt=="999"|bivalt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if bivalt=="88" & bivaltampm==. //0
** possibly Invalid (bival time before notified time)
count if bivalt!="" & bivalt!="99" & ambcallt!="" & ambcallt!="99" & bivalt<ambcallt //0
** possibly Invalid (bival time before time at scene)
count if bivalt!="" & bivalt!="99" & atscnt!="" & atscnt!="99" & bivalt<atscnt //0
** possibly Invalid (bival time before time from scene)
count if bivalt!="" & bivalt!="99" & frmscnt!="" & frmscnt!="99" & bivalt<frmscnt //0
** possibly Invalid (bival time before time at hospital)
count if bivalt!="" & bivalt!="99" & hospt!="" & hospt!="99" & bivalt<hospt //0
** Invalid (bival time before event time)
count if bivalt!="" & bivalt!="99" & etime!="" & etime!="99" & bivalt<etime //0
** Invalid missing code
count if bivaltampm==88|bivaltampm==99|bivaltampm==999|bivaltampm==9999 //0





** Corrections from above checks
destring flag135 ,replace
destring flag1060 ,replace
destring flag136 ,replace
destring flag1061 ,replace
destring flag267 ,replace
destring flag1192 ,replace
destring flag367 ,replace
destring flag1292 ,replace
destring flag614 ,replace
destring flag1539 ,replace
destring flag620 ,replace
destring flag1545 ,replace
destring flag626 ,replace
destring flag1551 ,replace
destring flag650 ,replace
destring flag1575 ,replace
destring flag662 ,replace
destring flag1587 ,replace
format flag136 flag1061 flag267 flag1192 flag367 flag1292 flag614 flag1539 flag620 flag1545 flag626 flag1551 flag650 flag1575 flag662 flag1587 %dM_d,_CY


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling for instances wherein the question is unanswered by the DA so the DAs do not need to update the CVDdb post-cleaning
//replace reperf=99999 if record_id==""

replace flag614=hepd if record_id=="2038"
replace hepd=hepd-31 if record_id=="2038" //see above
replace flag1539=hepd if record_id=="2038"

replace flag620=heplmwd if record_id=="2045"
replace heplmwd=heplmwd+1 if record_id=="2045" //see above
replace flag1545=heplmwd if record_id=="2045"

replace flag626=plad if record_id=="2045"|record_id=="2702"
replace plad=plad+1 if record_id=="2045"|record_id=="2702" //see above
replace flag1551=plad if record_id=="2045"|record_id=="2702"

replace flag650=arbsd if record_id=="2038"|record_id=="2266"
replace arbsd=arbsd-31 if record_id=="2038" //see above
replace arbsd=dae if record_id=="2266" //see above
replace flag1575=arbsd if record_id=="2038"|record_id=="2266"

replace flag662=antihd if record_id=="2266"|record_id=="2351"
replace antihd=dae if record_id=="2266" //see above
replace antihd=aspd if record_id=="2351" //see above
replace flag1587=antihd if record_id=="2266"|record_id=="2351"

replace flag135=atscene if record_id=="2261"|record_id=="3030"|record_id=="2430"|record_id=="2537"
replace atscene=2 if record_id=="2261"|record_id=="3030"|record_id=="2430"|record_id=="2537" //see above
replace flag1060=atscene if record_id=="2261"|record_id=="3030"|record_id=="2430"|record_id=="2537"

replace flag136=atscnd if record_id=="2261"|record_id=="3030"|record_id=="2430"|record_id=="2537"
replace atscnd=ambcalld if record_id=="2261"|record_id=="3030"|record_id=="2430"|record_id=="2537" //see above
replace flag1061=atscnd if record_id=="2261"|record_id=="3030"|record_id=="2430"|record_id=="2537"

replace flag367=ecgd if record_id=="2045"
replace ecgd=ecgd+1 if record_id=="2045" //see above
replace flag1292=ecgd if record_id=="2045"

replace flag267=edate if record_id=="4229"
replace edate=edate+10 if record_id=="4229" //see above
replace flag1192=edate if record_id=="4229"

replace flag666=antiht if record_id=="2220"
replace antiht=aspt if record_id=="2220" //see above
replace flag1591=antiht if record_id=="2220"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2038"|record_id=="2261"|record_id=="2045"|record_id=="3030"|record_id=="2702"|record_id=="2266"|record_id=="4229"|record_id=="2351"|record_id=="2430"|record_id=="2537"|record_id=="2220"



/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flagdate flag136 flag1061 flag267 flag1192 flag367 flag1292 flag483 flag1408 flag602 flag1527 flag614 flag1539 flag620 flag1545 flag626 flag1551 flag638 flag1563 flag650 flag1575 flag662 flag1587 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag135 flag136 flag267 flag367 flag483 flag555 flag556 flag562 flag563 flag602 flag614 flag620 flag626 flag638 flag650 flag662 flag666 if ///
		(flag135!=. | flag136!=. | flag267!=. |  flag367!=. |  flag483!=. |  flag555!=. |  flag556!=. |  flag562!=. |  flag563!=. |  flag602!=. |  flag614!=. |  flag620!=. |  flag626!=. |  flag638!=. |  flag650!=. |  flag662!=. |  flag666!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_RX1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1060 flag1061 flag1192 flag1292 flag1408 flag1480 flag1481 flag1487 flag1488 flag1527 flag1539 flag1545 flag1551 flag1563 flag1575 flag1587 flag1591 if ///
		 (flag1060!=. | flag1061!=. | flag1192!=. |  flag1292!=. |  flag1408!=. |  flag1480!=. |  flag1481!=. |  flag1487!=. |  flag1488!=. |  flag1527!=. |  flag1539!=. |  flag1545!=. |  flag1551!=. |  flag1563!=. |  flag1575!=. |  flag1587!=. |  flag1591!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_RX1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/

** Populate date (& time: hospt) variables for atscene, frmscene and sameadm in prep for analysis
replace hospd=dae if sameadm==1 & hospd==. //86 changes
replace atscnd=hospd if atscene==1 & atscnd==. //375 changes
replace atscnd=ambcalld if atscene==2 & atscnd==dae //1 change
replace frmscnd=atscnd if atscene==2 & frmscene==1 //3 changes
replace frmscnd=atscnd if frmscene==1 & frmscnd==. //376 changes
count if atscene==1 & atscnd==. //0
count if frmscene==1 & frmscnd==. //0
count if sameadm==1 & hospd==. //0

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
drop tropd_text tropdt2 sd_tropdt
gen tropd_text = string(tropd, "%td")
gen tropdt2 = tropd_text+" "+tropt if tropd!=. & tropt!="" & tropt!="88" & tropt!="99"
gen double sd_tropdt = clock(tropdt2,"DMYhm") if tropdt2!=""
format sd_tropdt %tc
label var sd_tropdt "DateTime of Troponin"
** ECG
drop ecgd_text ecgdt2 sd_ecgdt
gen ecgd_text = string(ecgd, "%td")
gen ecgdt2 = ecgd_text+" "+ecgt if ecgd!=. & ecgt!="" & ecgt!="88" & ecgt!="99"
gen double sd_ecgdt = clock(ecgdt2,"DMYhm") if ecgdt2!=""
format sd_ecgdt %tc
label var sd_ecgdt "DateTime of ECG"
** Reperfusion
gen reperfd_text = string(reperfd, "%td")
gen reperfdt2 = reperfd_text+" "+reperft if reperfd!=. & reperft!="" & reperft!="88" & reperft!="99"
gen double sd_reperfdt = clock(reperfdt2,"DMYhm") if reperfdt2!=""
format sd_reperfdt %tc
label var sd_reperfdt "DateTime of Reperfusion"
** Aspirin
gen aspd_text = string(aspd, "%td")
gen aspdt2 = aspd_text+" "+aspt if aspd!=. & aspt!="" & aspt!="88" & aspt!="99"
gen double sd_aspdt = clock(aspdt2,"DMYhm") if aspdt2!=""
format sd_aspdt %tc
label var sd_aspdt "DateTime of Aspirin"
** Warfarin
gen warfd_text = string(warfd, "%td")
gen warfdt2 = warfd_text+" "+warft if warfd!=. & warft!="" & warft!="88" & warft!="99"
gen double sd_warfdt = clock(warfdt2,"DMYhm") if warfdt2!=""
format sd_warfdt %tc
label var sd_warfdt "DateTime of Warfarin"
** Heparin (sc/iv)
gen hepd_text = string(hepd, "%td")
gen hepdt2 = hepd_text+" "+hept if hepd!=. & hept!="" & hept!="88" & hept!="99"
gen double sd_hepdt = clock(hepdt2,"DMYhm") if hepdt2!=""
format sd_hepdt %tc
label var sd_hepdt "DateTime of Heparin (sc/iv)"
** Heparin (lmw)
gen heplmwd_text = string(heplmwd, "%td")
gen heplmwdt2 = heplmwd_text+" "+heplmwt if heplmwd!=. & heplmwt!="" & heplmwt!="88" & heplmwt!="99"
gen double sd_heplmwdt = clock(heplmwdt2,"DMYhm") if heplmwdt2!=""
format sd_heplmwdt %tc
label var sd_heplmwdt "DateTime of Heparin (lmw)"
** Antiplatelets
gen plad_text = string(plad, "%td")
gen pladt2 = plad_text+" "+plat if plad!=. & plat!="" & plat!="88" & plat!="99"
gen double sd_pladt = clock(pladt2,"DMYhm") if pladt2!=""
format sd_pladt %tc
label var sd_pladt "DateTime of Antiplatelets"
** Statin
gen statd_text = string(statd, "%td")
gen statdt2 = statd_text+" "+statt if statd!=. & statt!="" & statt!="88" & statt!="99"
gen double sd_statdt = clock(statdt2,"DMYhm") if statdt2!=""
format sd_statdt %tc
label var sd_statdt "DateTime of Statin"
** Fibrinolytics
gen fibrd_text = string(fibrd, "%td")
gen fibrdt2 = fibrd_text+" "+fibrt if fibrd!=. & fibrt!="" & fibrt!="88" & fibrt!="99"
gen double sd_fibrdt = clock(fibrdt2,"DMYhm") if fibrdt2!=""
format sd_fibrdt %tc
label var sd_fibrdt "DateTime of Fibrinolytics"
** ACE
gen aced_text = string(aced, "%td")
gen acedt2 = aced_text+" "+acet if aced!=. & acet!="" & acet!="88" & acet!="99"
gen double sd_acedt = clock(acedt2,"DMYhm") if acedt2!=""
format sd_acedt %tc
label var sd_acedt "DateTime of ACE Inhibitors"
** ARBs
gen arbsd_text = string(arbsd, "%td")
gen arbsdt2 = arbsd_text+" "+arbst if arbsd!=. & arbst!="" & arbst!="88" & arbst!="99"
gen double sd_arbsdt = clock(arbsdt2,"DMYhm") if arbsdt2!=""
format sd_arbsdt %tc
label var sd_arbsdt "DateTime of ARBs"
** Corticosteroids
gen corsd_text = string(corsd, "%td")
gen corsdt2 = corsd_text+" "+corst if corsd!=. & corst!="" & corst!="88" & corst!="99"
gen double sd_corsdt = clock(corsdt2,"DMYhm") if corsdt2!=""
format sd_corsdt %tc
label var sd_corsdt "DateTime of Corticosteroids"
** Antihypertensives
gen antihd_text = string(antihd, "%td")
gen antihdt2 = antihd_text+" "+antiht if antihd!=. & antiht!="" & antiht!="88" & antiht!="99"
gen double sd_antihdt = clock(antihdt2,"DMYhm") if antihdt2!=""
format sd_antihdt %tc
label var sd_antihdt "DateTime of Antihypertensives"
** Nimodipine
gen nimod_text = string(nimod, "%td")
gen nimodt2 = nimod_text+" "+nimot if nimod!=. & nimot!="" & nimot!="88" & nimot!="99"
gen double sd_nimodt = clock(nimodt2,"DMYhm") if nimodt2!=""
format sd_nimodt %tc
label var sd_nimodt "DateTime of Nimodipine"
** Antiseizures
gen antisd_text = string(antisd, "%td")
gen antisdt2 = antisd_text+" "+antist if antisd!=. & antist!="" & antist!="88" & antist!="99"
gen double sd_antisdt = clock(antisdt2,"DMYhm") if antisdt2!=""
format sd_antisdt %tc
label var sd_antisdt "DateTime of Antiseizures"
** TED Stockings
gen tedd_text = string(tedd, "%td")
gen teddt2 = tedd_text+" "+tedt if tedd!=. & tedt!="" & tedt!="88" & tedt!="99"
gen double sd_teddt = clock(teddt2,"DMYhm") if teddt2!=""
format sd_teddt %tc
label var sd_teddt "DateTime of TED Stockings"
** Beta Blockers
gen betad_text = string(betad, "%td")
gen betadt2 = betad_text+" "+betat if betad!=. & betat!="" & betat!="88" & betat!="99"
gen double sd_betadt = clock(betadt2,"DMYhm") if betadt2!=""
format sd_betadt %tc
label var sd_betadt "DateTime of Beta Blockers"
** Bivalrudin
gen bivald_text = string(bivald, "%td")
gen bivaldt2 = bivald_text+" "+bivalt if bivald!=. & bivalt!="" & bivalt!="88" & bivalt!="99"
gen double sd_bivaldt = clock(bivaldt2,"DMYhm") if bivaldt2!=""
format sd_bivaldt %tc
label var sd_bivaldt "DateTime of Bivalrudin"

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_rx" ,replace