** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3f_clean ptm_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      06-FEB-2023
    // 	date last modified      06-FEB-2023
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
count if fmcplace==88|fmcplace==999|fmcplace==9999 //0
** possibly Invalid (fmcplace=other; other place=one of the fmcplace options)
count if fmcplace==98 //34 - reviewed and are correct

***********************
** Visit Date & Time **
***********************
** Missing
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
count if fmcdyear==88|fmcdyear==999|fmcdyear==9999 //0
** Missing
count if fmctime=="" & fmc==1 //0
** Invalid (fmctime format)
count if fmctime!="" & fmctime!="88" & fmctime!="99" & (length(fmctime)<5|length(fmctime)>5) //0
count if fmctime!="" & fmctime!="88" & fmctime!="99" & !strmatch(strupper(fmctime), "*:*") //0
generate byte non_numeric_fmctime = indexnot(fmctime, "0123456789.-:")
count if non_numeric_fmctime //0
** Invalid missing code
count if fmctime=="999"|fmctime=="9999" //0
** Invalid (fmctime=88 and am/pm is missing)
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
count if aeadmit==88|aeadmit==999|aeadmit==9999 //0

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

** Remove 2022 case + unnecessary variables from above 
drop if record_id=="3963" //1 deleted
drop sd_currentdate non_numeric_fmctime


** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_ptm" ,replace