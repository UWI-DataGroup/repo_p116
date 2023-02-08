** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3f_clean ptm_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      06-FEB-2023
    // 	date last modified      08-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Patient Management form
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
    log using "`logpath'\3f_clean ptm_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_demo", clear


** Cleaning each variable as they appear in REDCap BNRCVD_CORE db


** First Medical Contact **

**************************
** Referral to Hospital **
**************************
** Missing
count if fmc==. & patient_management_complete!=0 & patient_management_complete!=. //0 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid missing code
count if fmc==88|fmc==999|fmc==9999 //0

*******************
** Referred From **
*******************
** Missing
count if fmcplace==. & fmc==1 //0
** Invalid missing code
count if fmcplace==88|fmcplace==99|fmcplace==999|fmcplace==9999 //0
** possibly Invalid (fmcplace=other; other place=one of the fmcplace options)
count if fmcplace==98 //34 - reviewed and are correct

***********************
** Visit Date & Time **
***********************
** Missing date
count if fmcdate==. & fmc==1 //9 - checked CVDdb and these have fmcdate=99 so no need to update
** Invalid (not 2021)
count if fmcdate!=. & year(fmcdate)!=2021 //1 - stroke record 3963 incorrect as event was mistakenly entered as 2021 but all other dates in abs=2022
** Invalid (before DOB)
count if dob!=. & fmcdate!=. & fmcdate<dob //0
** Invalid (after CFAdmDate)
count if fmcdate!=. & cfadmdate!=. & fmcdate>cfadmdate //0
** Invalid (after DLC/DOD)
count if dlc!=. & fmcdate!=. & fmcdate>dlc //0
count if cfdod!=. & fmcdate!=. & fmcdate>cfdod //0
** Invalid (after A&EAdmDate)
count if fmcdate!=. & dae!=. & fmcdate>dae //0
** Invalid (after WardAdmDate)
count if fmcdate!=. & doh!=. & fmcdate>doh //0
** Invalid (future date)
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY
count if fmcdate!=. & fmcdate>sd_currentdate //0
** Invalid (fmcdate partial missing codes for all)
count if fmcdate==88 & fmcdday==. & fmcdmonth==. & fmcdyear==. //0
** Invalid (fmcdate not partial but partial field not blank)
count if fmcdate!=88 & fmcdday!=. & fmcdmonth!=. & fmcdyear!=. //0
count if fmcdate!=88 & (fmcdday!=. | fmcdmonth!=. | fmcdyear!=.) //0
** Invalid missing code (fmcdate partial fields)
count if fmcdday==88|fmcdday==999|fmcdday==9999 //0
count if fmcdmonth==88|fmcdmonth==999|fmcdmonth==9999 //0
count if fmcdyear==88|fmcdyear==99|fmcdyear==999 //0
** Missing time
count if fmctime=="" & fmc==1 //0
** Invalid (time format)
count if fmctime!="" & fmctime!="88" & fmctime!="99" & (length(fmctime)<5|length(fmctime)>5) //0
count if fmctime!="" & fmctime!="88" & fmctime!="99" & !strmatch(strupper(fmctime), "*:*") //0
generate byte non_numeric_fmctime = indexnot(fmctime, "0123456789.-:")
count if non_numeric_fmctime //0
** Invalid missing code
count if fmctime=="999"|fmctime=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if fmctime=="88" & fmcampm==. //0

**********************
** Name of Hospital **
**********************
** Missing
count if hospital==. & sd_casetype!=2 & eligible!=6 //2 - checked CVDdb and corrected below
//list sd_etype record_id cstatus eligible fmc sd_casetype if hospital==. & sd_casetype!=2 & eligible!=6
** Invalid missing code
count if hospital==88|hospital==999|hospital==9999 //0
** Invalid (relation=other; other relation=one of the relation options)
count if hospital==98 //0


** Corrections from above checks
destring flag267 ,replace
destring flag1192 ,replace
format flag267 flag1192 %dM_d,_CY

replace flag267=edate if record_id=="3963"
replace edate=edate+365 if record_id=="3963" //see above
replace flag1192=edate if record_id=="3963"
//remove this record at the end of this dofile after the corrections list has been generated

replace flag74=eligible if record_id=="2791"|record_id=="2830"
replace eligible=6 if record_id=="2791"|record_id=="2830"
replace flag999=eligible if record_id=="2791"|record_id=="2830"

replace flag267=edate if record_id=="2830"
replace edate=dd_dod if record_id=="2830"
replace flag1192=edate if record_id=="2830"
//heart record 2830 was a missed reportable abstraction - only CF form was completed



** A&E Info **

******************
** Seen in A&E? **
******************
** Missing
count if aeadmit==. & patient_management_complete!=0 & patient_management_complete!=. //0 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid missing code
count if aeadmit==88|aeadmit==99|aeadmit==999|aeadmit==9999 //0

*************************
** A&E Adm Date & Time **
*************************
** Missing date
count if dae==. & aeadmit==1 //0
** Invalid (not 2021)
count if dae!=. & year(dae)!=2021 //4 - 2 stroke records 3963 + 4289 incorrect as event was mistakenly entered as 2021 but all other dates in abs=2022; 1 stroke record has incorrect year for dae; 1 stroke record is correct as edate is dec2021.
** Invalid (before DOB)
count if dob!=. & dae!=. & dae<dob //0
** Invalid (after CFAdmDate)
count if dae!=. & cfadmdate!=. & dae>cfadmdate //0
** Invalid (after DLC/DOD)
count if dlc!=. & dae!=. & dae>dlc //0
count if cfdod!=. & dae!=. & dae>cfdod //0
** Invalid (before FMCVisitDate)
count if fmcdate!=. & dae!=. & dae<fmcdate //0
** Invalid (after WardAdmDate)
count if dae!=. & doh!=. & dae>doh //0
** Invalid (future date)
count if dae!=. & dae>sd_currentdate //0
** Invalid missing code (dae should not be missing)
count if dae==88|dae==99|dae==999|dae==9999 //0
** Missing time
count if tae=="" & aeadmit==1 //0
** Invalid (time format)
count if tae!="" & tae!="88" & tae!="99" & (length(tae)<5|length(tae)>5) //0
count if tae!="" & tae!="88" & tae!="99" & !strmatch(strupper(tae), "*:*") //0
generate byte non_numeric_tae = indexnot(tae, "0123456789.-:")
count if non_numeric_tae //0
** Invalid missing code
count if tae=="999"|tae=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if tae=="88" & taeampm==. //0

*************************
** A&E Dis Date & Time **
*************************
** Missing date
count if daedis==. & aeadmit==1 //457 - date=99 in CVDdb
** Invalid (not 2021)
count if daedis!=. & year(daedis)!=2021 //1 - stroke records 3963 incorrect as event was mistakenly entered as 2021 but all other dates in abs=2022
** Invalid (before DOB)
count if dob!=. & daedis!=. & daedis<dob //0
** Invalid (before A&EAdmDate)
count if daedis!=. & dae!=. & daedis<dae //0
** Invalid (after DLC/DOD)
count if dlc!=. & daedis!=. & daedis>dlc //1 - stroke record 2211 incorrect as A&E discharge date incorrect
count if cfdod!=. & daedis!=. & daedis>cfdod //0
** Invalid (before FMCVisitDate)
count if fmcdate!=. & daedis!=. & daedis<fmcdate //0
** Invalid (after WardAdmDate)
count if daedis!=. & doh!=. & daedis>doh //0
** Invalid (future date)
count if daedis!=. & daedis>sd_currentdate //0
** Invalid missing code (daedis should not be missing)
count if daedis==88|daedis==99|daedis==999|daedis==9999 //0
** Missing time
count if taedis=="" & aeadmit==1 //0
** Invalid (time format)
count if taedis!="" & taedis!="88" & taedis!="99" & (length(taedis)<5|length(taedis)>5) //0
count if taedis!="" & taedis!="88" & taedis!="99" & !strmatch(strupper(taedis), "*:*") //0
generate byte non_numeric_taedis = indexnot(taedis, "0123456789.-:")
count if non_numeric_taedis //0
** Invalid missing code
count if taedis=="999"|taedis=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if taedis=="88" & taedisampm==. //0


** Corrections from above checks
destring flag117 ,replace
destring flag1042 ,replace
destring flag120 ,replace
destring flag1045 ,replace
destring flag194 ,replace
destring flag1119 ,replace
destring flag240 ,replace
destring flag1165 ,replace
format flag117 flag1042 flag120 flag1045 flag194 flag1119 flag240 flag1165 %dM_d,_CY

replace flag117=dae if record_id=="2351"
replace dae=dae+365 if record_id=="2351" //see above
replace flag1042=dae if record_id=="2351"

replace flag120=daedis if record_id=="2211"
replace daedis=daedis-10 if record_id=="2211" //see above
replace flag1045=daedis if record_id=="2211"

replace flag194=ssym1d if record_id=="4289"
replace ssym1d=ssym1d+365 if record_id=="4289" //see above
replace flag1119=ssym1d if record_id=="4289"

replace flag240=osymd if record_id=="4289"
replace osymd=osymd+365 if record_id=="4289" //see above
replace flag1165=osymd if record_id=="4289"

replace flag267=edate if record_id=="4289"
replace edate=edate+365 if record_id=="4289" //see above
replace flag1192=edate if record_id=="4289"
//remove this record at the end of this dofile after the corrections list has been generated


** WARD Info **

***********************
** Admitted to Ward? **
***********************
** Missing
count if wardadmit==. & patient_management_complete!=0 & patient_management_complete!=. //0 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
count if wardadmit==1 & dohsame==. //0
** Invalid missing code
count if wardadmit==88|wardadmit==99|wardadmit==999|wardadmit==9999 //0
count if dohsame==88|dohsame==99|dohsame==999|dohsame==9999 //0
** possibly Invalid (Not admitted to Ward and Same date as CF form NOT=missing)
count if wardadmit!=1 & dohsame!=. //0

**************************
** Ward Adm Date & Time **
**************************
** Missing date
count if doh==. & wardadmit==1 & dohsame!=1 //0
** Invalid (not 2021)
count if doh!=. & year(doh)!=2021 //8 - 2 stroke records 3963 + 4289 incorrect as event was mistakenly entered as 2021 but all other dates in abs=2022; 1 stroke record has incorrect date for doh; 5 records are correct as edate is dec2021.
** Invalid (before DOB)
count if dob!=. & doh!=. & doh<dob //0
** Invalid (before CFAdmDate)
count if doh!=. & cfadmdate!=. & doh<cfadmdate //0
** Invalid (Same as CFAdmDate=No but WardAdmDate=CFAdmDate)
count if doh!=. & cfadmdate!=. & dohsame!=1 & doh==cfadmdate //7
** Invalid (after DLC/DOD)
count if dlc!=. & doh!=. & doh>dlc //2 - stroke records 1907 + 3021 incorrect.
count if cfdod!=. & doh!=. & doh>cfdod //0
** Invalid (before FMCVisitDate)
count if fmcdate!=. & doh!=. & doh<fmcdate //0
** Invalid (before A&EAdmDate)
count if doh!=. & dae!=. & doh<dae //0
** Invalid (future date)
count if doh!=. & doh>sd_currentdate //0
** Invalid missing code (doh should not be missing)
count if doh==88|doh==99|doh==999|doh==9999 //0
** Missing time
count if toh=="" & wardadmit==1 //0
** Invalid (time format)
count if toh!="" & toh!="88" & toh!="99" & (length(toh)<5|length(toh)>5) //0
count if toh!="" & toh!="88" & toh!="99" & !strmatch(strupper(toh), "*:*") //0
generate byte non_numeric_toh = indexnot(toh, "0123456789.-:")
count if non_numeric_toh //0
** Invalid missing code
count if toh=="999"|toh=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if toh=="88" & tohampm==. //0


** Corrections from above checks
destring flag125 ,replace
destring flag1050 ,replace
format flag125 flag1050 %dM_d,_CY
destring flag124 ,replace
destring flag1049 ,replace

replace flag124=dohsame if doh!=. & cfadmdate!=. & dohsame!=1 & doh==cfadmdate
replace dohsame=1 if doh!=. & cfadmdate!=. & dohsame!=1 & doh==cfadmdate //7 changes - see above
replace flag1050=dohsame if flag124!=. //7 changes

replace flag125=doh if record_id=="3757"
replace doh=doh-212 if record_id=="3757" //see above
replace flag1050=doh if record_id=="3757"

replace flag125=doh if record_id=="1907"
replace doh=doh-90 if record_id=="1907" //see above
replace flag1050=doh if record_id=="1907"

replace flag125=doh if record_id=="3021"
replace doh=doh-31 if record_id=="3021" //see above
replace flag1050=doh if record_id=="3021"


** Mode of Arrival Info **

*********************
** Mode of Arrival **
*********************
** Missing
count if arrivalmode==. & patient_management_complete!=0 & patient_management_complete!=. //0 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid missing code
count if arrivalmode==88|arrivalmode==999|arrivalmode==9999 //0

**************************
** Notified Date & Time **
**************************
** Missing date
count if ambcalld==. & arrivalmode==1 //8 - checked CVDdb and these have notified date=99 but 5 corrected below; 3 are correct
** Invalid (not 2021)
count if ambcalld!=. & year(ambcalld)!=2021 //2 - stroke record 4289 incorrect as event was mistakenly entered as 2021 but all other dates in abs=2022; stroke record 3403 correct as edate=dec2021
** Invalid (before DOB)
count if dob!=. & ambcalld!=. & ambcalld<dob //0
** Invalid (after CFAdmDate)
count if ambcalld!=. & cfadmdate!=. & ambcalld>cfadmdate //5 - all incorrect and corrected below
** Invalid (after DLC/DOD)
count if dlc!=. & ambcalld!=. & ambcalld>dlc //0
count if cfdod!=. & ambcalld!=. & ambcalld>cfdod //0
** Invalid (after A&EAdmDate)
count if ambcalld!=. & dae!=. & ambcalld>dae //6 - all incorrect and corrected below
** Invalid (after WardAdmDate)
count if ambcalld!=. & doh!=. & ambcalld>doh //2 - corrected below
** Invalid (future date)
count if ambcalld!=. & ambcalld>sd_currentdate //0
** Invalid (notified date partial missing codes for all)
count if arrivalmode==1 & ambcalld==. & ambcallday==99 & ambcallmonth==99 & ambcallyear==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if ambcalld==. & ambcallday!=. & ambcallmonth!=. & ambcallyear!=. //3 - reviewed & ambcall date corrected below and partial fields corrected also but no need for DAs to correct in CVDdb as these are already flagged below so when they add in the ambcalld then the partials will be erased.
replace ambcallday=. if ambcalld==. & ambcallday!=. & ambcallmonth!=. & ambcallyear!=. //3 changes
replace ambcallmonth=. if ambcalld==. & ambcallmonth!=. & ambcallyear!=. //3 changes
replace ambcallyear=. if ambcalld==. & ambcallyear!=. //3 changes
count if ambcalld==. & (ambcallday!=. | ambcallmonth!=. | ambcallyear!=.) //0
** Invalid missing code (notified date partial fields)
count if ambcallday==88|ambcallday==999|ambcallday==9999 //0
count if ambcallmonth==88|ambcallmonth==999|ambcallmonth==9999 //0
count if ambcallyear==88|ambcallyear==99|ambcallyear==999 //0
** Invalid (after AtSceneDate)
count if ambcalld!=. & atscnd!=. & ambcalld>atscnd //0
** Invalid (after FromSceneDate)
count if ambcalld!=. & frmscnd!=. & ambcalld>frmscnd //0
** Invalid (after AtHospitalDate)
count if ambcalld!=. & hospd!=. & ambcalld>hospd //0
** Missing time
count if ambcallt=="" & arrivalmode==1 //0
** Invalid (time format)
count if ambcallt!="" & ambcallt!="88" & ambcallt!="99" & (length(ambcallt)<5|length(ambcallt)>5) //0
count if ambcallt!="" & ambcallt!="88" & ambcallt!="99" & !strmatch(strupper(ambcallt), "*:*") //0
generate byte non_numeric_ambcallt = indexnot(ambcallt, "0123456789.-:")
count if non_numeric_ambcallt //0
** Invalid missing code
count if ambcallt=="999"|ambcallt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if ambcallt=="88" & ambcalltampm==. //0


** Corrections from above checks
destring flag129 ,replace
destring flag1054 ,replace
destring flag150 ,replace
destring flag1075 ,replace
format flag129 flag1054 flag150 flag1075 %dM_d,_CY

replace flag129=ambcalld if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="3758"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"
replace ambcalld=dae if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="3758"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099" //see above
replace flag1054=ambcalld if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="3758"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"

replace flag150=hospd if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="3758"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"
replace hospd=dae if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="3758"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099" //see above
replace flag1075=hospd if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="3758"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"

replace flag117=dae if record_id=="1831"
replace dae=dae+10 if record_id=="1831" //see above
replace flag1042=dae if record_id=="1831"

replace flag118=tae if record_id=="1831"
replace flag154=hospt if record_id=="1831"
//ssc install swapval
swapval tae hospt if record_id=="1831" //see above
replace flag1043=tae if record_id=="1831"
replace flag1079=hospt if record_id=="1831"




STOP
*************
** Address **
*************
** Missing
count if addr=="" & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if addr=="88"|addr=="999"|addr=="9999" //0
count if addr=="Not Stated"|addr=="NONE"|addr=="NOT STATED"|addr=="None"|addr=="ND"|addr=="Nil" //0
** Invalid (address not blank/ND but resident NOT=yes)
count if addr!="" & addr!="99" & resident!=1 & sd_casetype!=2 & demographics_complete!=0 & demographics_complete!=. //19
** Invalid (addr=blank but dd_address NOT=blank)
count if addr=="" & addr=="99" & dd_address!="" & dd_address!="99" //0

************
** Parish **
************
** Missing
count if parish==. & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if parish==88|parish==999|parish==9999 //0
** Invalid (parish not blank/ND but resident NOT=yes)
count if parish!=. & parish!=99 & resident!=1 & sd_casetype!=2 & demographics_complete!=0 & demographics_complete!=. //19
** Invalid (parish=blank but dd_parish NOT=blank)
count if parish==. & parish==99 & dd_parish!=. & dd_parish!=99 //0
** Invalid (parish NOT=blank but address=blank)
count if parish!=. & parish!=99 & addr=="" //0
** Invalid (parish=blank but address NOT=blank)
count if parish==. & addr!="" & addr!="99" //0

***************
** Telephone **
**	Numbers	 **
***************
** Missing
count if hometel=="" & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
count if worktel=="" & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
count if celltel=="" & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if hometel=="88"|hometel=="999"|hometel=="9999" //0
count if worktel=="88"|worktel=="999"|worktel=="9999" //0
count if celltel=="88"|celltel=="999"|celltel=="9999" //0

**************************
** First, Middle + Last **
** Names (Next of Kin)	**
**************************
** Missing
count if fnamekin=="" & slc!=2 & sd_casetype!=2 & demographics_complete!=0 & demographics_complete!=. //0
count if lnamekin=="" & slc!=2 & sd_casetype!=2 & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if fnamekin=="88"|fnamekin=="999"|fnamekin=="9999" //0
count if lnamekin=="88"|lnamekin=="999"|lnamekin=="9999" //0
**Invalid (contains a number or special character)
count if regexm(fnamekin,"0")|regexm(lnamekin,"0") //0
count if regexm(fnamekin,"1")|regexm(lnamekin,"1") //0
count if regexm(fnamekin,"2")|regexm(lnamekin,"2") //0
count if regexm(fnamekin,"3")|regexm(lnamekin,"3") //0
count if regexm(fnamekin,"4")|regexm(lnamekin,"4") //0
count if regexm(fnamekin,"5")|regexm(lnamekin,"5") //0
count if regexm(fnamekin,"6")|regexm(lnamekin,"6") //0
count if regexm(fnamekin,"7")|regexm(lnamekin,"7") //0
count if regexm(fnamekin,"8")|regexm(lnamekin,"8") //0
count if (fnamekin!="99" & lnamekin!="99") & (regexm(fnamekin,"9")|regexm(lnamekin,"9")) //0
count if regexm(fnamekin,"9") & length(fnamekin)>2 //0
count if regexm(lnamekin,"9") & length(lnamekin)>2 //0
count if fnamekin!="" & fnamekin!="99" & length(fnamekin)<3 //0
count if lnamekin!="" & lnamekin!="99" & length(lnamekin)<3 //0
** Format names
replace fnamekin = lower(rtrim(ltrim(itrim(fnamekin)))) //574 changes
replace lnamekin = lower(rtrim(ltrim(itrim(lnamekin)))) //573 changes
** Remove dummy data
count if regexm(fnamekin,"DUMM")|regexm(fnamekin,"DATA") //0
count if regexm(lnamekin,"DUMM")|regexm(lnamekin,"DATA") //0

***************
** Telephone **
**	Numbers	 **
**   (NOK)	 **
***************
** Missing
count if homekin=="" & sametel!=1 & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
count if workkin=="" & sametel!=1 & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
count if cellkin=="" & sametel!=1 & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if homekin=="88"|homekin=="999"|homekin=="9999" //0
count if workkin=="88"|workkin=="999"|workkin=="9999" //0
count if cellkin=="88"|cellkin=="999"|cellkin=="9999" //0

******************
** Relationship **
**   of NOK		**
******************
** Missing
count if relation==. & slc!=2 & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if relation==88|relation==999|relation==9999 //0
** Invalid (relation=other; other relation=one of the relation options)
count if relation==98 //3 - reviewed and is correct, leave as is



/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
//format flag851 flag852 flag1776 flag1777 flag45 flag970 flag57 flag982 flag61 flag986 flag65 flag990  %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag89 flag90 if ///
		flag89!=. | flag90!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_DEMO1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1014 flag1015 if ///
		 flag1014!=. | flag1015!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_DEMO1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/

** Remove 2022 cases + unnecessary variables from above 
drop if record_id=="3963"|record_id=="4289" //2 deleted
drop sd_currentdate non_numeric_fmctime


** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_ptm" ,replace