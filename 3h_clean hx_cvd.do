** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3h_clean hx_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      16-FEB-2023
    // 	date last modified      20-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb History form
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
    log using "`logpath'\3h_clean hx_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_eve", clear

count //1144

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

*************************
** Previous Event Info **
*************************
**********************
** Previous Stroke? **
**********************
** Missing
count if pstroke==. & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if pstroke==88|pstroke==999|pstroke==9999 //0
*******************
** Previous AMI? **
*******************
** Missing
count if pami==. & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if pami==88|pami==999|pami==9999 //0
*******************
** Previous IHD? **
*******************
** Missing
count if pihd==. & sd_etype==2 & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if pihd==88|pihd==999|pihd==9999 //0
** Invalid (not blank; event=stroke)
count if pihd!=. & sd_etype==1 //0
********************
** Previous CABG? **
********************
** Missing
count if pcabg==. & sd_etype==2 & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if pcabg==88|pcabg==999|pcabg==9999 //0
** Invalid (not blank; event=stroke)
count if pcabg!=. & sd_etype==1 //0
***************************
** Previous Angioplasty? **
***************************
** Missing
count if pcorangio==. & sd_etype==2 & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if pcorangio==88|pcorangio==999|pcorangio==9999 //0
** Invalid (not blank; event=stroke)
count if pcorangio!=. & sd_etype==1 //0
**************************
** Previous Stroke YEAR **
**************************
** Missing
count if pstroke==1 & pstrokeyr==. //0
** Invalid missing code
count if pstrokeyr==88|pstrokeyr==99|pstrokeyr==999 //0
** Invalid length
count if pstrokeyr!=9999 & pstrokeyr!=. //107 - visually reviewed to ensure full year entered - all correct
** Invalid (after 2021)
count if pstrokeyr!=9999 & pstrokeyr!=. & pstrokeyr>2021 //0
***********************
** Previous AMI YEAR **
***********************
** Missing
count if pami==1 & pamiyr==. //0
** Invalid missing code
count if pamiyr==88|pamiyr==99|pamiyr==999 //0
** Invalid length
count if pamiyr!=9999 & pamiyr!=. //44 - visually reviewed to ensure full year entered - all correct
** Invalid (after 2021)
count if pamiyr!=9999 & pamiyr!=. & pamiyr>2021 //0
***********************
** Database Checked? **
***********************
** Missing
count if (pami==1|pstroke==1) & dbchecked==. //0
** Invalid missing code
count if dbchecked==88|dbchecked==99|dbchecked==999|dbchecked==9999 //0
** Invalid (eligible dx year but db not checked)
count if sd_etype==1 & pamiyr>2009 & dbchecked==2 //57 - DAs don't perform cumulative abstraction process so leave as is.
count if sd_etype==1 & pstrokeyr>2008 & dbchecked==2 //48 - DAs don't perform cumulative abstraction process so leave as is.

********************
** Family History **
********************
***********************
** Family Hx Stroke? **
***********************
** Missing
count if famstroke==. & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if famstroke==88|famstroke==999|famstroke==9999 //0
********************
** Family Hx AMI? **
********************
** Missing
count if famami==. & history_complete!=0 & history_complete!=. //0
** Invalid missing code
count if famami==88|famami==999|famami==9999 //0
********************
** Mother Stroke? **
********************
** Missing
count if famstroke==1 & mumstroke==. //0
** Invalid missing code
count if mumstroke==88|mumstroke==999|mumstroke==9999 //0
********************
** Father Stroke? **
********************
** Missing
count if famstroke==1 & dadstroke==. //0
** Invalid missing code
count if dadstroke==88|dadstroke==999|dadstroke==9999 //0
*********************
** Sibling Stroke? **
*********************
** Missing
count if famstroke==1 & sibstroke==. //0
** Invalid missing code
count if sibstroke==88|sibstroke==999|sibstroke==9999 //0
*****************
** Mother AMI? **
*****************
** Missing
count if famami==1 & mumami==. //0
** Invalid missing code
count if mumami==88|mumami==999|mumami==9999 //0
*****************
** Father AMI? **
*****************
** Missing
count if famami==1 & dadami==. //0
** Invalid missing code
count if dadami==88|dadami==999|dadami==9999 //0
******************
** Sibling AMI? **
******************
** Missing
count if famami==1 & sibami==. //0
** Invalid missing code
count if sibami==88|sibami==999|sibami==9999 //0

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
** Invalid (other rf options=ND/None but other rf text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf1!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf1!="" //107 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf1,"smoke")|regexm(ovrf1,"cholesterol")|regexm(ovrf1,"fibrill*")|regexm(ovrf1,"tia")|regexm(ovrf1,"transient")|regexm(ovrf1,"ccf")|regexm(ovrf1,"failure")|regexm(ovrf1,"htn")|regexm(ovrf1,"hypertension")|regexm(ovrf1,"dm")|regexm(ovrf1,"diab*")|regexm(ovrf1,"hyperlipid*")|regexm(ovrf1,"hld")|regexm(ovrf1,"alcohol")|regexm(ovrf1,"drug")|regexm(ovrf1,"cocaine")|regexm(ovrf1,"marijuana")) //2 - 1 correct leave as is; stroke record 3438 corrected below as drug use mentioned in ovrf1
count if sd_etype==2 & (regexm(ovrf1,"smoke")|regexm(ovrf1,"cholesterol")|regexm(ovrf1,"fibrill*")|regexm(ovrf1,"transient")|regexm(ovrf1,"ccf")|regexm(ovrf1,"failure")|regexm(ovrf1,"htn")|regexm(ovrf1,"hypertension")|regexm(ovrf1,"dm")|regexm(ovrf1,"diab*")|regexm(ovrf1,"hyperlipid*")|regexm(ovrf1,"hld")|regexm(ovrf1,"alcohol")|regexm(ovrf1,"drug")|regexm(ovrf1,"cocaine")|regexm(ovrf1,"marijuana")) //0
**************
** Oth RF 2 **
**************
count if ovrf==2 & ovrf2=="" //0
** Invalid (other rf options=ND/None but other rf text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf2!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf2!="" //12 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf2,"smoke")|regexm(ovrf2,"cholesterol")|regexm(ovrf2,"fibrill*")|regexm(ovrf2,"tia")|regexm(ovrf2,"transient")|regexm(ovrf2,"ccf")|regexm(ovrf2,"failure")|regexm(ovrf2,"htn")|regexm(ovrf2,"hypertension")|regexm(ovrf2,"dm")|regexm(ovrf2,"diab*")|regexm(ovrf2,"hyperlipid*")|regexm(ovrf2,"hld")|regexm(ovrf2,"alcohol")|regexm(ovrf2,"drug")|regexm(ovrf2,"cocaine")|regexm(ovrf2,"marijuana")) //3 - all correct leave as is
count if sd_etype==2 & (regexm(ovrf2,"smoke")|regexm(ovrf2,"cholesterol")|regexm(ovrf2,"fibrill*")|regexm(ovrf2,"transient")|regexm(ovrf2,"ccf")|regexm(ovrf2,"failure")|regexm(ovrf2,"htn")|regexm(ovrf2,"hypertension")|regexm(ovrf2,"dm")|regexm(ovrf2,"diab*")|regexm(ovrf2,"hyperlipid*")|regexm(ovrf2,"hld")|regexm(ovrf2,"alcohol")|regexm(ovrf2,"drug")|regexm(ovrf2,"cocaine")|regexm(ovrf2,"marijuana")) //0
**************
** Oth RF 3 **
**************
count if ovrf==3 & ovrf3=="" //0
** Invalid (other rf options=ND/None but other rf text NOT=blank)
count if (ovrf==5|ovrf==99|ovrf==99999) & ovrf3!="" //0
** possibly Invalid (other rf=one of the rf options)
count if ovrf3!="" //2 - reviewed and correct
count if sd_etype==1 & (regexm(ovrf3,"smoke")|regexm(ovrf3,"cholesterol")|regexm(ovrf3,"fibrill*")|regexm(ovrf3,"tia")|regexm(ovrf3,"transient")|regexm(ovrf3,"ccf")|regexm(ovrf3,"failure")|regexm(ovrf3,"htn")|regexm(ovrf3,"hypertension")|regexm(ovrf3,"dm")|regexm(ovrf3,"diab*")|regexm(ovrf3,"hyperlipid*")|regexm(ovrf3,"hld")|regexm(ovrf3,"alcohol")|regexm(ovrf3,"drug")|regexm(ovrf3,"cocaine")|regexm(ovrf3,"marijuana")) //0
count if sd_etype==2 & (regexm(ovrf3,"smoke")|regexm(ovrf3,"cholesterol")|regexm(ovrf3,"fibrill*")|regexm(ovrf3,"transient")|regexm(ovrf3,"ccf")|regexm(ovrf3,"failure")|regexm(ovrf3,"htn")|regexm(ovrf3,"hypertension")|regexm(ovrf3,"dm")|regexm(ovrf3,"diab*")|regexm(ovrf3,"hyperlipid*")|regexm(ovrf3,"hld")|regexm(ovrf3,"alcohol")|regexm(ovrf3,"drug")|regexm(ovrf3,"cocaine")|regexm(ovrf3,"marijuana")) //0
**************
** Oth RF 4 **
**************
count if ovrf==4 & ovrf4=="" //0
** Invalid (other rf options=ND/None but other rf text NOT=blank)
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
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_hx" ,replace