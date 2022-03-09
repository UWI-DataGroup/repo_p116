** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          stroke_duplicates.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-MAY-2021
    // 	date last modified      09-MAR-2022
    //  algorithm task          Importing data from REDCap via API, removing non-stroke data arms, identifying duplicates and exporting flagged duplicates back into REDCap
    //  status                  Completed
    //  objective               (1) To have list of possible stroke duplicates identified during this process so DAs can correct in REDCap's BNRCVD_CORE database.
	//							(2) To have the SOP for this process also written into the dofile.
	//								The SOP is in the BNR Ops Manual OneNote book in the path - https://theuwi.sharepoint.com/sites/CaveHillTheBNR
    //  methods                 Importing current REDCap dataset, identifying duplicates using Names, CF Admission Date and NRN and pushing flagged duplicates back into REDCap.
	//							The possible duplicates are flagged using the variable [duplicate] which is used for filtering the REDCap report called 'Possible Duplicates (STROKE)'.
	//							This dofile is also saved in the path: L:\Sync\CVD\Database Management\Redcap\Duplicates

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
** HEADER -----------------------------------------------------

version 17.0
set more off
clear 

**********************
** IMPORT DATA FROM **
** REDCAP TO STATA  **
**********************
local token "A82D69F01EB026B40B994DED67A78555"
local outfile  "exported_dup.csv"

** Pull data from REDCap using only the variables you want to code in Stata
shell curl	///
	--output `outfile' 		///
	--form token=`token'	///
	--form content=record 	///
	--form format=csv 		///
	--form type=flat 		///
	--form fields[]=record_id ///
	--form fields[]=fname ///
	--form fields[]=lname ///
	--form fields[]=natregno ///
	--form fields[]=cfadmdate ///
	--form fields[]=duplicate ///
	--form fields[]=dupcheck "https://caribdata.org/redcap/api/" 

import delimited `outfile'

export delimited using "stroke_dup.csv", replace
br

**********************
** EXPORT DATA FROM **
** STATA TO REDCAP  **
**********************
version 17.0
set more off
clear 

local token "A82D69F01EB026B40B994DED67A78555"
local outfile "stroke_dup.csv"

shell curl --output `outfile' --form token=`token' --form content=record --form format=csv --form type=flat --form fields[]=record_id --form fields[]=fname --form fields[]=lname --form fields[]=natregno --form fields[]=cfadmdate --form fields[]=duplicate --form fields[]=dupcheck "https://caribdata.org/redcap/api/"
import delimited `outfile'


*** ---- S T R O K E  D U P L I C A T E S ----- ***

drop if redcap_event_name=="heart_arm_2" | redcap_event_name=="tracking_arm_3" | redcap_event_name=="reviewing_arm_4" | redcap_event_name=="dashboards_arm_5"
drop if regexm(record_id,"108-") 

** Format NRN to identify duplicates more accurately
format natregno %12.0g
tostring natregno ,replace
/*gen cfadmdate2 = date(cfadmdate, "YMD")
format cfadmdate2 %dD_m_CY
drop cfadmdate
rename cfadmdate2 cfadmdate*/

/*
	Format name fields to be sentence case as some are upper case BEFORE
	performing duplicate check since bysort is case-sensitive.
	First, change all to lower-case with extra spaces removed then 
	change all to sentence-case.
*/
replace fname = lower(rtrim(ltrim(itrim(fname)))) //963 changes
replace lname = lower(rtrim(ltrim(itrim(lname)))) //963 changes
replace fname = regexr(fname, word(fname,1) ,proper(word(fname,1)))
replace lname = regexr(lname, word(lname,1) ,proper(word(lname,1)))

************ Name DUPLICATES *******************

** Perform duplicate searches, by name & cfadmdate and by NRN & cfadmdate
sort lname fname cfadmdate
quietly by lname fname cfadmdate :  gen dupadmpt = cond(_N==1,0,_n)
sort lname fname cfadmdate record_id
count if dupadmpt>0 //34
sort lname fname cfadmdate record_id
list record_id fname lname natregno cfadmdate dupadmpt duplicate dupcheck if dupadmpt>0 & redcap_event_name=="stroke_arm_1"


** Create a variable to identify duplicates flagged in Names check to use later to remove these before NRN after push to REDCap below
gen nameslist=1 if  (dupadmpt>0 & redcap_event_name=="stroke_arm_1" & fname!="" & lname!="" & cfadmdate!="" & duplicate==.) ///
					   |(dupadmpt>0 & redcap_event_name=="stroke_arm_1" & fname!="" & lname!="" & cfadmdate!="" & dupcheck==.) //flagging possible NAMES duplicates 
//23 changes
replace duplicate=3 if  (dupadmpt>0 & redcap_event_name=="stroke_arm_1" & fname!="" & lname!="" & cfadmdate!="" & duplicate==.) ///
					   |(dupadmpt>0 & redcap_event_name=="stroke_arm_1" & fname!="" & lname!="" & cfadmdate!="" & dupcheck==.) //flagging possible duplicates 
//23 changes

drop dupadmpt

preserve
** Remove variables that do not need to be pushed back into REDCap - don't remove name variables so that any upper case ones can be updated in REDCap db
drop natregno cfadmdate dupcheck nameslist

**Push data back into REDCap project
drop if duplicate!=3 //1520 deleted
local fileforimport "data_for_import_namesS.csv"
export delimited using `fileforimport', nolabel replace
//restore //delete this restore once tested and are ready to push into REDCap
local cmd="C:\Windows\System32\curl.exe" ///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form format=csv" 		///
          + " --form type=flat" 		///
          + " --form data="+char(34)+"<`fileforimport'"+char(34) /// The < is critical! It causes curl to read the contents of the file, not just send the file name.
          + " https://caribdata.org/redcap/api/"

shell `cmd' 
restore
//delete "//" before the restore above when ready to push into REDCap



************ NRN DUPLICATES *******************

drop if natregno=="88"|natregno=="99" //171 deleted
sort natregno cfadmdate
quietly by natregno cfadmdate :  gen dupadmnrn = cond(_N==1,0,_n)
sort natregno cfadmdate record_id
count if dupadmnrn>0 //30
sort natregno record_id
list record_id fname lname natregno cfadmdate dupadmnrn duplicate dupcheck redcap_event_name nameslist if dupadmnrn>0 & redcap_event_name=="stroke_arm_1"

replace duplicate=3 if (dupadmnrn>0 & redcap_event_name=="stroke_arm_1" & natregno!="." & cfadmdate!="" & duplicate==.) ///
					  |(dupadmnrn>0 & redcap_event_name=="stroke_arm_1" & natregno!="." & cfadmdate!="" & dupcheck==.) //flagging possible duplicates
//1 change as other possible dup NRNs were already flagged and updated in Names check

sort record_id
drop  dupadmnrn

** Remove data that has already been pushed to REDCap from NAMES check and that hasn't been flagged as a possible duplicate
count if nameslist==1 //21
drop if nameslist==1 //21 deleted
drop if duplicate!=3 //770 deleted


** Format NRN to match format in REDCap
** Remove variables that do not need to be pushed back into REDCap
destring natregno ,replace
format natregno %12.0g
drop fname lname natregno cfadmdate dupcheck nameslist

**Push data back into REDCap project
local fileforimport "data_for_import_nrnS.csv"
export delimited using `fileforimport', nolabel replace
local cmd="C:\Windows\System32\curl.exe" ///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form format=csv" 		///
          + " --form type=flat" 		///
          + " --form data="+char(34)+"<`fileforimport'"+char(34) /// The < is critical! It causes curl to read the contents of the file, not just send the file name.
          + " https://caribdata.org/redcap/api/"

shell `cmd'
