** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3e_clean demo_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-FEB-2023
    // 	date last modified      02-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Demographics form
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
    log using "`logpath'\3e_clean demo_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load merged unduplicated 2021 dataset (from dofile 3d_death match_cvd.do)
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_merged_cf", clear


** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

********************
** Marital Status **
********************
** Missing
count if mstatus==. & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if mstatus==88|mstatus==999|mstatus==9999 //0

*********************
** Resident Status **
*********************
** Missing
count if resident==. & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if resident==88|resident==999|resident==9999 //0
** Invalid (resident=Yes but 28d resident=less than 6 months)
count if resident==1 & furesident==1 //1 - stroke record 3110 ask NS if this case is eligible.
** Invalid (resident=No but 28d resident=more than 6 months)
count if resident==2 & furesident==2 //1
** Invalid (resident not Yes but NRN not blank)
count if resident!=. & resident!=1 & sd_natregno!="" & !(strmatch(strupper(sd_natregno), "*9999*")) //20 - ask NS
** Invalid (resident=ND but case status NOT=ineligible)
count if resident==99 & cstatus!=2 //19
** Corrections from above checks
destring flag89 ,replace
destring flag1014 ,replace

replace flag89=resident if record_id=="1718"
replace resident=1 if record_id=="1718"
replace flag1014=resident if record_id=="1718"

********************
** Citizen Status **
********************
** Missing
count if citizen==. & demographics_complete!=0 & demographics_complete!=. //0
** Invalid missing code
count if citizen==88|citizen==999|citizen==9999 //0
** Invalid (citizen=Yes but last 4 digits in NRN begins with '7' or '8')
gen nrndigits = substr(sd_natregno,-4,1)
count if citizen==1 & (nrndigits=="7"|nrndigits=="8") //62 - ask NS how to handle these cases
** Invalid (citizen=No but last 4 digits in NRN do not begin with '7' or '8')
count if citizen==2 & nrndigits!="7" & nrndigits!="8" & nrndigits!="" //1 - stroke record 3364 ask NS how to handle
drop nrndigits

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


STOP - need NS' feedback on above queries
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
capture export_excel record_id sd_etype flag89 if ///
		flag89!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_DEMO1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1014 if ///
		 flag1014!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_DEMO1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/



** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_demo" ,replace