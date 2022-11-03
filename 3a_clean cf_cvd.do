** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3a_clean cf_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-NOV-2022
    // 	date last modified      03-NOV-2022
    //  algorithm task          Cleaning variables in the REDCap Casefinding form
    //  status                  Pending
    //  objective               To have a cleaned 2021 cvd incidence dataset ready for cleaning
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
    log using "`logpath'\3a_clean cf_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load prepared 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_PreparedData", clear

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

*************
** CF Date **
*************
** Missing
count if cfdoa==. //0
** Invalid (CF Date after ABS Date if not stroke-in-evolution)
count if evolution!=1 & (cfdoa>adoa & adoa!=.)|evolution!=1 & (cfdoa>adoa & ptmdoa!=.)|evolution!=1 & (cfdoa>adoa & edoa!=.)|evolution!=1 & (cfdoa>adoa & hxdoa!=.)|evolution!=1 & (cfdoa>adoa & tdoa!=.)|evolution!=1 & (cfdoa>adoa & dxdoa!=.)|evolution!=1 & (cfdoa>adoa & rxdoa!=.)|evolution!=1 & (cfdoa>adoa & ddoa!=.) //0
** Invalid (future date)
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY
label var sd_currentdate "Current date"
count if cfdoa!=. & cfdoa>sd_currentdate //0

*************
** CF Time **
*************
** Missing
count if cfdoat=="" //0
** Invalid (format)
count if length(cfdoat)<5|length(cfdoat)>5 //0
count if !strmatch(strupper(cfdoat), "*:*") //0
generate byte non_numeric_cfdoat = indexnot(cfdoat, "0123456789.-:")
count if non_numeric_cfdoat //0
drop non_numeric_cfdoat

***********
** CF DA **
***********
** Missing
count if cfda=="" //0
** Invalid (format)
count if !strmatch(strupper(cfda), "*.*") //0

*********************
** Multiple Events **
**	  (Stroke)	   **
*********************
** Invalid (sri=Yes and event type=Heart)
count if sri==1 & sd_etype==2 //0
** Invalid (sri=Yes and no corresponding pid in heart arm)
count if sri==1 & srirec==. //0
** Populate data if sri=Yes
count if sri==1 //0

************************
** Event-in-evolution **
**	    (Stroke)	  **
************************
** Invalid (evolution=Yes and event type=Heart)
count if evolution==1 & sd_etype==2 //0
** Invalid (evolution=Yes and no repeating instance)
count if evolution==1 & (redcap_repeat_instance==.|redcap_repeat_instance==1) //0
** Populate symptoms data if evolution=Yes
count if evolution==1 //5 - records 1729, 2309, 2353, 2853, 3247
//no symptoms data to populate after above records reviewed
drop if evolution==1 & redcap_repeat_instance==2 | record_id=="2853" //6 deleted - 2853 is a duplicate of 3247

*****************
** Source Type **
*****************
** Missing
count if sourcetype==. //0
** Invalid (sourcetype=Hospital and no hospital source ticked)
count if sourcetype==1 & cfsource___1!=0 & cfsource___2!=0 & cfsource___3!=0 & cfsource___4!=0 & cfsource___5!=0 & cfsource___6!=0 & cfsource___7!=0 & cfsource___8!=0 & cfsource___9!=0 & cfsource___10!=0 & cfsource___11!=0 & cfsource___12!=0 & cfsource___13!=0 & cfsource___14!=0 & cfsource___15!=0 & cfsource___16!=0 & cfsource___17!=0 & cfsource___18!=0 & cfsource___19!=0 & cfsource___20!=0 & cfsource___21!=0 & cfsource___22!=0 & cfsource___23!=0 & cfsource___24!=0 //0
** Invalid (sourcetype=Community and no community source ticked)
count if sourcetype==2 & cfsource___25!=0 & cfsource___26!=0 & cfsource___27!=0 & cfsource___28!=0 & cfsource___29!=0 & cfsource___30!=0 & cfsource___31!=0 & cfsource___32!=0 //0

*********************
** First NF Source **
*********************
** Missing
count if firstnf==. //0
** Invalid (FirstNF=Missing before 29-Sep-2020 and CF Date after 29-Sep-2020)
count if firstnf==33 & cfdoa>d(29sep2020) //0

***************
** CF Source **
***************
** Missing
count if cfsource___1==0 & cfsource___2==0 & cfsource___3==0 & cfsource___4==0 & cfsource___5==0 & cfsource___6==0 & cfsource___7==0 & cfsource___8==0 & cfsource___9==0 & cfsource___10==0 & cfsource___11==0 & cfsource___12==0 & cfsource___13==0 & cfsource___14==0 & cfsource___15==0 & cfsource___16==0 & cfsource___17==0 & cfsource___18==0 & cfsource___19==0 & cfsource___20==0 & cfsource___21==0 & cfsource___22==0 & cfsource___23==0 & cfsource___24==0 & cfsource___25==0 & cfsource___26==0 & cfsource___27==0 & cfsource___28==0 & cfsource___29==0 & cfsource___30==0 & cfsource___31==0 & cfsource___32==0
//1 - blank heart record but there's a valid stroke record with same id
drop if record_id=="1945" & sd_etype==2 //1 deleted

*********************
** Retrieval Source **
*********************
** Missing
count if retsource==. //0
count if retsource==98 & oretsrce=="" //0
** Invalid (evolution/sri=Yes and Retrieval Source not blank)
count if retsource!=. & (evolution==1|sri==1) //0

**************************
** First, Middle + Last **
**		  Names			**
**************************
** Missing
count if fname=="" //0
count if mname=="" //0
count if lname=="" //0
**Invalid (contains a number or special character)
count if regexm(fname,"0")|regexm(mname,"0")|regexm(lname,"0") //0
count if regexm(fname,"1")|regexm(mname,"1")|regexm(lname,"1") //0
count if regexm(fname,"2")|regexm(mname,"2")|regexm(lname,"2") //0
count if regexm(fname,"3")|regexm(mname,"3")|regexm(lname,"3") //0
count if regexm(fname,"4")|regexm(mname,"4")|regexm(lname,"4") //0
count if regexm(fname,"5")|regexm(mname,"5")|regexm(lname,"5") //0
count if regexm(fname,"6")|regexm(mname,"6")|regexm(lname,"6") //0
count if regexm(fname,"7")|regexm(mname,"7")|regexm(lname,"7") //0
count if regexm(fname,"8")|regexm(mname,"8")|regexm(lname,"8") //0
count if (fname!="99" & mname!="99" & lname!="99") & (regexm(fname,"9")|regexm(mname,"9")|regexm(lname,"9")) //1
replace mname="99" if record_id=="2291" //1 change
count if regexm(fname,"9") & length(fname)>2 //0
count if regexm(mname,"9") & length(mname)>2 //0
count if regexm(lname,"9") & length(lname)>2 //0
count if length(fname)<3 //0
count if length(mname)<3 & mname!="99" //288 - correct; all initials
count if length(lname)<3 //0
** Format names
replace fname = lower(rtrim(ltrim(itrim(fname))))
replace mname = lower(rtrim(ltrim(itrim(mname))))
replace lname = lower(rtrim(ltrim(itrim(lname))))
** Remove dummy data
count if regexm(fname,"DUMM")|regexm(fname,"DATA") //0
count if regexm(mname,"DUMM")|regexm(mname,"DATA") //0
count if regexm(lname,"DUMM")|regexm(lname,"DATA") //0

*********
** Sex **
*********
** Missing
count if sex==. //0
STOP

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_cf", replace

PERFORM DUPLICATES CHECKS USING NRN, DOB, NAMES AFTER COMPLETION OF THE CF FORM AND BEFORE PROCEEDING TO CLEANING THE OTHER FORMS


** Create cleaned non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_cf", replace