** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3a_clean cf_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-NOV-2022
    // 	date last modified      08-DEC-2022
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

** JC 01dec2022: Review and remove cases that are ineligible and/or duplicates prior to cleaning to reduce number of records to be cleaned
count if cstatus==2 //1093
gen sd_record_id=record_id
destring sd_record_id ,replace
order sd_record_id
count if cstatus==2 & inrange(sd_record_id, 0, 3000) //599
count if cstatus==2 & inrange(sd_record_id, 3001, 5000) //494
order record_id sd_etype ineligible initialdx finaldx cfcods duprec
//list record_id sd_etype ineligible initialdx finaldx cfcods duprec if cstatus==2 & inrange(sd_record_id, 0, 3000), string(20)
//list record_id sd_etype ineligible initialdx finaldx cfcods duprec if cstatus==2 & inrange(sd_record_id, 3001, 5000), string(20)

** Update the 1st admission record with re-admission info 
//replace ineligible=2 if record_id=="2077" & sd_etype==2|record_id=="2255" & sd_etype==2
replace cstatus=2 if record_id=="4982"|record_id=="5116"
replace ineligible=3 if record_id=="4982"|record_id=="5116"

replace readmit=1 if record_id=="2064"
replace readmitadm=d(02may2021) if record_id=="2064"
replace readmitdis=d(09may2021) if record_id=="2064"
replace readmitdays=readmitdis-readmitadm if record_id=="2064"

replace readmit=1 if record_id=="3144"
replace readmitadm=d(07jun2021) if record_id=="3144"
replace readmitdis=d(01jul2021) if record_id=="3144"
replace readmitdays=readmitdis-readmitadm if record_id=="3144"

count if cstatus==3 //2 cases listed as pending review

** Review cases listed as duplicate to (1) ensure re-admission info is completed and (2) duplicate and case status fields are correctly completed
count if ineligible==2 & duplicate==. //0
count if ineligible!=2 & duplicate==1 //89
count if ineligible==2 & toabs!=2 //7

** Remove cases listed as ineligible and duplicate
count //1834
tab cstatus ,m
/*
   Case Status |      Freq.     Percent        Cum.
---------------+-----------------------------------
      Eligible |        739       40.29       40.29
    Ineligible |      1,095       59.71      100.00
---------------+-----------------------------------
         Total |      1,834      100.00
*/

tab ineligible ,m
/*
            Case Status - Ineligible |      Freq.     Percent        Cum.
-------------------------------------+-----------------------------------
             Abstracted (Ineligible) |         48        2.62        2.62
                           Duplicate |         86        4.69        7.31
         Not Abstracted (Ineligible) |        837       45.64       52.94
Not Abstracted (Irretrievable Notes) |        110        6.00       58.94
       Not Abstracted (Non-resident) |         16        0.87       59.81
                                   . |        737       40.19      100.00
-------------------------------------+-----------------------------------
                               Total |      1,834      100.00
*/

tab eligible ,m
/*
                 Case Status - Eligible |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
            Pending initial abstraction |          1        0.05        0.05
               Pending 28-day follow-up |         19        1.04        1.09
Confirmed but NOT fully abstracted at c |         40        2.18        3.27
     Re-admitted to ward within 28 days |          4        0.22        3.49
                              Completed |        677       36.91       40.40
                                      . |      1,093       59.60      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,834      100.00
*/

** JC 06dec2022: update ineligible cases that were reviewed with NSobers (see OneNote: CVD DM Re-engineer\2021 cases for NS to review)
** Heart records 2891/4703 - JC entered 24jun2021 adm found in MedData as a new CF record with eligible cstatus: confirmed but not fully abs (added on 07dec2022 record_id 5495)
** Stroke record 3042 - JC entered 01sep2021 adm found in CODs field on CF form as a new CF record with eligible cstatus: confirmed but not fully abs (added on 07dec2022 record_id 5496)
** Heart record 3253 - JC copied this adm as a new CF record as it was accidentally entered into Heart arm and labelled as ineligible; cstatus changed to eligible: confirmed but not fully abs (added on 07dec2022 record_id 5497)

** JC 07dec2022: updated raw data was exported from CVDdb and dofiles 1_format_cvd + 2a_prep_cvd were re-run to include the above additional records

count //1837
tab cstatus ,m
/*
   Case Status |      Freq.     Percent        Cum.
---------------+-----------------------------------
      Eligible |        742       40.39       40.39
    Ineligible |      1,095       59.61      100.00
---------------+-----------------------------------
         Total |      1,837      100.00
*/

tab ineligible ,m
/*
            Case Status - Ineligible |      Freq.     Percent        Cum.
-------------------------------------+-----------------------------------
             Abstracted (Ineligible) |         48        2.61        2.61
                           Duplicate |         89        4.84        7.46
         Not Abstracted (Ineligible) |        834       45.40       52.86
Not Abstracted (Irretrievable Notes) |        110        5.99       58.85
       Not Abstracted (Non-resident) |         16        0.87       59.72
                                   . |        740       40.28      100.00
-------------------------------------+-----------------------------------
                               Total |      1,837      100.00
*/

tab eligible ,m
/*
                 Case Status - Eligible |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
            Pending initial abstraction |          1        0.05        0.05
               Pending 28-day follow-up |         19        1.03        1.09
Confirmed but NOT fully abstracted at c |         43        2.34        3.43
     Re-admitted to ward within 28 days |          4        0.22        3.65
                              Completed |        677       36.85       40.50
                                      . |      1,093       59.50      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,837      100.00
*/

** Remove true ineligibles
drop if ineligible!=. //1097
count //737; 740
** JC 07dec2022: Now ineligibles have been removed, re-run below cleaning code

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
count if evolution==1 //5 - records 1729, 2309, 2353, 2853, 3247; now 4 as ineligibles removed above
//no symptoms data to populate after above records reviewed
drop if evolution==1 & redcap_repeat_instance==2 | record_id=="2853" //6 deleted - 2853 is a duplicate of 3247; now 4 deleted as ineligibles removed above
** Populate re-admission data using dates from 2nd admission in CVDdb (record_id 2309, 2353, 2853, 3247 already entered by DA)
replace readmit=1 if record_id=="1729"
replace readmitadm=d(08feb2021) if record_id=="1729"
replace readmitdis=d(12feb2021) if record_id=="1729"
replace readmitdays=readmitdis-readmitadm if record_id=="1729"


*****************
** Source Type **
*****************
** Missing
count if sourcetype==. //0
** Invalid (sourcetype=Hospital and no hospital source ticked)
count if sourcetype==1 & cfsource___1!=0 & cfsource___2!=0 & cfsource___3!=0 & cfsource___4!=0 & cfsource___5!=0 & cfsource___6!=0 & cfsource___7!=0 & cfsource___8!=0 & cfsource___9!=0 & cfsource___10!=0 & cfsource___11!=0 & cfsource___12!=0 & cfsource___13!=0 & cfsource___14!=0 & cfsource___15!=0 & cfsource___16!=0 & cfsource___17!=0 & cfsource___18!=0 & cfsource___19!=0 & cfsource___20!=0 & cfsource___21!=0 & cfsource___22!=0 & cfsource___23!=0 & cfsource___24!=0 & cfsource___33!=0 //0
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
count if cfsource___1==0 & cfsource___2==0 & cfsource___3==0 & cfsource___4==0 & cfsource___5==0 & cfsource___6==0 & cfsource___7==0 & cfsource___8==0 & cfsource___9==0 & cfsource___10==0 & cfsource___11==0 & cfsource___12==0 & cfsource___13==0 & cfsource___14==0 & cfsource___15==0 & cfsource___16==0 & cfsource___17==0 & cfsource___18==0 & cfsource___19==0 & cfsource___20==0 & cfsource___21==0 & cfsource___22==0 & cfsource___23==0 & cfsource___24==0 & cfsource___25==0 & cfsource___26==0 & cfsource___27==0 & cfsource___28==0 & cfsource___29==0 & cfsource___30==0 & cfsource___31==0 & cfsource___32==0 & cfsource___33==0
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
** Invalid missing code
count if fname=="88"|fname=="999"|fname=="9999" //0
count if mname=="88"|mname=="999"|mname=="9999" //0
count if lname=="88"|lname=="999"|lname=="9999" //0
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
count if (fname!="99" & mname!="99" & lname!="99") & (regexm(fname,"9")|regexm(mname,"9")|regexm(lname,"9")) //1 - was an ineligible that was removed above
//replace mname="99" if record_id=="2291" //1 change
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


** JC 09nov2022: Although Sex comes before DOB and NRN on the CF form, a validity check for Sex needs NRN to be formatted and cleaned so DOB and NRN cleaned before Sex; Also cleaned NRN before DOB for similar reason
*********
** NRN **
*********
** Create a string variable for NRN
format natregno %12.0g
tostring natregno, gen(sd_natregno) format(%12.0g)
** Missing
count if natregno==. //0
count if natregno==. & dob!=. & dob!=99 //0
count if natregno==88 & (nrnyear==.|nrnmonth==.|nrnday==.|nrnnum==.) //0
** Invalid missing code
count if natregno==999|natregno==9999 //0
** Invalid format
count if length(sd_natregno)==9 //2 - now 1 as ineligible was removed
replace sd_natregno="0"+sd_natregno if record_id=="1842"|record_id=="3024" //2 changes - these are not errors in the CVDdb; it's an import error (1 change)
count if length(sd_natregno)==8 //0
count if length(sd_natregno)==7 //0
** Combine partial NRN variables to use in validity checks
tostring nrnyear, gen(yr)
replace yr="200"+yr if record_id=="3741" //1 change
replace yr="19"+yr if natregno==88 & record_id!="3741" //15 changes; now 3 changes
tostring nrnmonth, gen(mon)
replace mon="0"+mon if natregno==88 & length(mon)<2 //15 changes; now 4 changes
tostring nrnday, gen(day)
replace day="0"+day if natregno==88 & length(day)<2 //7 changes; now 2 changes
tostring nrnnum, gen(num)
gen nrndate=yr+mon+day if natregno==88
gen nrn_corr = date(nrndate, "YMD")
format nrn_corr %dM_d,_CY
** Invalid (DOB and NRN do not match)
count if natregno==88 & dob!=nrn_corr //0
** Update Stata-Derived NRN with partial NRN data
gen nrn=substr(nrndate,3,6) + num if natregno==88
replace sd_natregno=nrn if natregno==88 //16 changes; now 4 changes
drop yr mon day num nrndate nrn_corr nrn


*********
** DOB **
*********
** Missing
count if dob==. //208; now 32
count if dob==88 & (dobyear==.|dobmonth==.|dobday==.) //0
count if dob==. & natregno!=. & natregno!=99 //2 - records 2256 + 4117: corrected below; now 1 as 4117 was removed as ineligible
** Invalid missing code
count if dob==999|dob==9999 //0
** Invalid (future date)
count if dob!=. & dob>sd_currentdate //0
** Invalid (DOB and NRN do not match)
gen dob_nrn = substr(sd_natregno,1,6)
replace dob_nrn="19"+dob_nrn if record_id=="2256"|record_id=="4117" //2 changes; now 1 change
replace dob_nrn="19"+dob_nrn if record_id=="3192" | dob!=. & dob<d(01jan2000) //1616 changes; now 701 changes
replace dob_nrn="20"+dob_nrn if dob!=. & dob>d(31dec1999) & record_id!="3192" //3 changes; now 2 changes
gen dob_nrn2 = date(dob_nrn, "YMD")
format dob_nrn2 %dM_d,_CY
count if dob!=dob_nrn2 & natregno!=99 //25; now 12
//list record_id redcap_event_name dob dob_nrn2 cfage natregno if dob!=dob_nrn2 & natregno!=99

** Corrections for missing
replace dob=dob_nrn2 if record_id=="2256" //|record_id=="4117"
** Corrections for invalid
replace dob=dob_nrn2 if record_id=="2728"|record_id=="2808"| ///
						record_id=="3021"|record_id=="3191"|record_id=="3247"| ///
						record_id=="3291"|record_id=="3306"|record_id=="3410"|record_id=="3610"|record_id=="3757" //19 changes; now 10 changes
						//|record_id=="3728"|record_id=="3441"|record_id=="3541"|record_id=="3555"|record_id=="3192"|record_id=="3170"|record_id=="2882"|record_id=="2274"|record_id=="2675"
//replace sd_natregno=subinstr(sd_natregno,"69","79",.) if record_id=="2192"
//replace sd_natregno=subinstr(sd_natregno,"10","40",.) if record_id=="2194"
//replace sd_natregno=subinstr(sd_natregno,"20","10",.) if record_id=="2482"
//replace sd_natregno=subinstr(sd_natregno,"89","86",.) if record_id=="2551"
//replace sd_natregno=subinstr(sd_natregno,"31","13",.) if record_id=="3397"
replace sd_natregno=subinstr(sd_natregno,"02","10",.) if record_id=="2280"
replace sd_natregno=subinstr(sd_natregno,"03","30",.) if record_id=="2280"
** Corrections for NRN from above
gen nrn=sd_natregno
destring nrn ,replace
replace natregno=nrn if record_id=="2280" //record_id=="2192"|record_id=="2194"|record_id=="2482"|record_id=="2551"|record_id=="3397" //6 changes; now 1 change
replace dob=dob+241 if record_id=="2280"
drop dob_nrn* nrn


*********
** Sex **
*********
** Missing
count if sex==. //0
** Invalid missing code
count if sex==88|sex==999|sex==9999 //0
count if sex==99 //0
** Possibly invalid (first name, NRN and sex check: MALES)
gen nrnid=substr(sd_natregno, -4,4)
count if sex==1 & nrnid!="9999" & regex(substr(sd_natregno,-2,1), "[1,3,5,7,9]") //123; now 28 - checked in MedData
//list record_id fname lname sex sd_natregno dob if sex==1 & nrnid!="9999" & regex(substr(sd_natregno,-2,1), "[1,3,5,7,9]")
** Corrections
replace sex=2 if record_id=="2060"
		//record_id=="1799"||record_id=="2463"|record_id=="2586"|record_id=="2907"|record_id=="2911"|record_id=="3601"|record_id=="4116"|record_id=="4357" 
//incidental corrections from above review
//replace fname=subinstr(fname,"s","",.) if record_id=="2907"
//replace fname=subinstr(fname,"'","",.) if record_id=="4318"
** Possibly invalid (first name, NRN and sex check: FEMALES)
count if sex==2 & nrnid!="9999" & regex(substr(sd_natregno,-2,1), "[0,2,4,6,8]") //12; now 3
//list record_id fname lname sex sd_natregno dob if sex==2 & nrnid!="9999" & regex(substr(sd_natregno,-2,1), "[0,2,4,6,8]")
** Corrections
replace sex=1 if record_id=="2150" 
				//record_id=="1817"|record_id=="1853"|record_id=="2018"|record_id=="2050"|record_id=="2557"|record_id=="2649"|record_id=="3738"|record_id=="4354"
//incidental corrections from above review
gen fname2=substr(fname,7,5) if record_id=="2150"
replace fname=fname2 if record_id=="2150"
drop fname2 nrnid


** Need to clean cfadmdate first in order to clean age
*****************************
** CF Admission/Visit Date **
*****************************
** Missing
count if cfadmdate==. //1 - checked MedData but last encounter was outpatient months before death; I think dod is adm date (check with NS)
replace cfadmdate=cfdod if record_id=="2830" //see above
//incidental correction for NRN
preserve
clear
import excel using "`datapath'\version03\2-working\MissingNRN_20221122.xlsx" , firstrow case(lower)
tostring record_id, replace
destring elec_natregno, replace
save "`datapath'\version03\2-working\missing_nrn" ,replace
restore

merge m:1 record_id using "`datapath'\version03\2-working\missing_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           734
        from master                       734  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------
*/
replace natregno=elec_natregno if _merge==3 //2 changes
replace sd_natregno=elec_sd_natregno if _merge==3
replace dob=elec_dob if _merge==3
drop elec_* _merge
erase "`datapath'\version03\2-working\missing_nrn.dta"

** Invalid (not 2021)
count if year(cfadmdate)!=2021 //3 - correct as event was in 2021
** Invalid (before DOB)
count if dob!=. & cfadmdate!=. & cfadmdate<dob //0
** Invalid (after CF Date)
count if cfdoa!=. & cfadmdate!=. & cfadmdate>cfdoa //0
** Invalid (after DLC/DOD)
count if dlc!=. & cfadmdate!=. & cfadmdate>dlc //0
count if cfdod!=. & cfadmdate!=. & cfadmdate>cfdod //1 - cannot find in DeathData but still changed year; now 0
//replace cfdod=cfdod+365  if record_id=="3232"
//replace cfdodyr=2022 if record_id=="3232"
** Invalid (future date)
count if cfadmdate>sd_currentdate //0
** Create CF adm date YEAR variable
drop cfadmyr
gen cfadmyr=year(cfadmdate)
count if cfadmyr==. //0
order link_id unique_id record_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance redcap_data_access_group cfdoa cfdoat cfda sri srirec evolution sourcetype firstnf cfsource___1 cfsource___2 cfsource___3 cfsource___4 cfsource___5 cfsource___6 cfsource___7 cfsource___8 cfsource___9 cfsource___10 cfsource___11 cfsource___12 cfsource___13 cfsource___14 cfsource___15 cfsource___16 cfsource___17 cfsource___18 cfsource___19 cfsource___20 cfsource___21 cfsource___22 cfsource___23 cfsource___24 cfsource___25 cfsource___26 cfsource___27 cfsource___28 cfsource___29 cfsource___30 cfsource___31 cfsource___32 retsource oretsrce fname mname lname sex dob dobday dobmonth dobyear cfage cfage_da natregno sd_natregno nrnyear nrnmonth nrnday nrnnum recnum cfadmdate cfadmyr


*********
** AGE **
*********
** Missing
count if cfage==. & dob!=. //autocalculated by REDCap
//2 - cfage_da has values for these missing; probably DOB was added after this form was initially completed
count if cfage_da==. & dob==. //entered by DA
//0
** Invalid missing code
count if cfage_da==9999 //0
** Invalid autocalculated ages
gen cfage2=(cfadmdate-dob)/365.25
gen checkage=int(cfage2)
count if cfage!=. & cfage!=checkage //286; now 105
//list record_id cfadmdate dob cfage checkage if cfage!=. & cfage!=checkage
replace cfage=checkage if cfage!=. & cfage!=checkage //286 changes - no need for DAs to correct in db as this is autocalculated by db; now 105 changes
** Invalid DA-entered age
count if dob!=. & cfage==. & cfage_da!=. & cfage_da!=checkage //0
drop cfage2 checkage

***********************
** Hospital/Record # **
***********************
** Missing
count if recnum=="" //0
** Invalid missing code
count if recnum=="88"|recnum=="999"|recnum=="9999" //0

***********************
** Initial Diagnosis **
***********************
** Missing
count if initialdx=="" //0
** Invalid missing code (88, 99, 999, 9999 are invalid)
count if regexm(initialdx,"9") //34 - all correct; now 11
count if regexm(initialdx,"8") //0
//replace initialdx = lower(rtrim(ltrim(itrim(initialdx)))) if record_id=="3244"

*********************
** Hospital Status **
*********************
** Missing
count if sourcetype==1 & hstatus==. //0
** Invalid missing code (88, 999, 999 are invalid)
count if hstatus==88|hstatus==999|hstatus==9999 //0
** Invalid (discharged but retrieval source = ward)
count if hstatus==1 & retsource!=. & retsource<20 //0
** Invalid (on ward but retrieval source = records dept)
count if hstatus==2 & retsource!=. & retsource>19 //2 - both are true duplicates and will be deleted later so leave as is; now 0
** Invalid (discharged but no DLC/DOD)
count if hstatus==1 & dlc==. & cfdod==. //15; now 4
//list record_id fname mname lname natregno cfadmdate if hstatus==1 & dlc==. & cfdod==.

//corrections from above using MedData and Deathdb
replace dlc=d(13mar2021) if record_id=="1823"
//replace cfdod=d(07aug2021) if record_id=="3179"
//replace slc=2 if record_id=="3179"
//replace dlc=d(01jul2021) if record_id=="3444"
replace dlc=d(18nov2021) if record_id=="4335"
//replace dlc=d(28nov2021) if record_id=="4354"
//replace dlc=d(09dec2021) if record_id=="4363"
replace dlc=d(08jan2022) if record_id=="4404"
** Invalid (on ward but has DLC/DOD)
count if hstatus==2 & (dlc!=.|cfdod!=.) //0


preserve
clear
import excel using "`datapath'\version03\2-working\MissingNRN_20221207.xlsx" , firstrow case(lower)
tostring record_id, replace
destring elec_natregno, replace
tostring elec_sd_natregno, replace
tostring elec_recnum, replace
save "`datapath'\version03\2-working\missing_nrn" ,replace
restore

merge m:1 record_id using "`datapath'\version03\2-working\missing_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           733
        from master                       733  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 2  (_merge==3)
    -----------------------------------------
*/
replace natregno=elec_natregno if _merge==3 //2 changes
replace sd_natregno=elec_sd_natregno if _merge==3
replace dob=elec_dob if _merge==3
replace recnum=elec_recnum if _merge==3
drop elec_* _merge
replace cfage=64 if record_id=="4404"
replace cfage=38 if record_id=="4335"
erase "`datapath'\version03\2-working\missing_nrn.dta"



************************************
**  Status at Last Contact (SLC)  **
** (currently known vital status) **
************************************
** Missing
count if slc==. //0
** Invalid (slc=alive but cfdod/dod not blank or 28d vstatus=deceased)
count if slc==1 & (cfdod!=. | dod!=. | f1vstatus==2) //3
replace slc=2 if record_id=="2704" & sd_etype==2
replace cfdod=d(20oct2021) if record_id=="2704" & sd_etype==2
replace slc=2 if record_id=="2840" & sd_etype==2
replace cfdod=d(09oct2021) if record_id=="2840" & sd_etype==2
replace slc=2 if record_id=="3362" & sd_etype==1 //cannot find pt in 2022 or multi-yr Deathdb + no death info in MedData
** Invalid (slc=deceased but cfdod/dod=blank or 28d vstatus=alive)
count if slc==2 & cfdod==. & dod==. & f1vstatus!=2 //1
replace cfdod=d(31may2021) if record_id=="2126" & sd_etype==1
** Invalid (slc=deceased but cfdod/dod=blank)
count if slc==2 & cfdod==. & dod==. //1 - record 3362 cannot find pt in Deathdb (see above)


**************************
** Date at Last Contact **
**		  (DLC) 		**
**************************
** Missing
count if dlc==. //215 - all deceased except one whose DLC is truly missing
replace dlc=cfdod if dlc==. //214 changes
** Missing
count if slc==1 & dlc==. //1 - record 3121 (stroke) cannot find in MedData or DeathDb
** Invalid missing code
count if dlc==999|dlc==9999 //0
** Invalid (bfore 2021)
count if year(dlc)<2021 //0
** Invalid (future date)
count if dlc>sd_currentdate //1 - record 3121 (stroke) see above note
** Invalid (before CF Adm/Visit Date)
count if dlc!=. & cfadmdate!=. & dlc<cfadmdate //0
** Invalid (before DOB)
count if dlc!=. & dob!=. & dlc<dob //0
** Invalid (after DOD)
count if dlc!=. & cfdod!=. & dlc>cfdod //0
count if dlc!=. & dod!=. & dlc>dod //0
** Invalid (DLC not blank; Hosp.Status=discharged)
count if sourcetype!=2 & dlc!=. & hstatus!=1 //0
** Invalid (DLC partial missing codes for all)
count if dlc==88 & dlcday==. & dlcmonth==. & dlcyear==. //0
** Invalid (DLC not partial but partial field not blank)
count if dlc!=88 & dlcday!=. & dlcmonth!=. & dlcyear!=. //0
count if dlc!=88 & (dlcday!=. | dlcmonth!=. | dlcyear!=.) //0
** Invalid missing code (DLC partial fields)
count if dlcday==88|dlcday==999|dlcday==9999 //0
count if dlcmonth==88|dlcmonth==999|dlcmonth==9999 //0
count if dlcyear==88|dlcyear==999|dlcyear==9999 //0
** Create DLC YEAR variable
drop dlcyr
gen dlcyr=year(dlc)
count if dlcyr==. //1 - record 3121 (stroke) with true missing DLC


****************
** Death Date **
**	(CFDOD)	  **
****************
** Missing
count if cfdod==. //468 - all alive except one whose DOD is unk (see below)
** Missing
count if slc==2 & cfdod==. //1 - record 3362 (stroke) cannot find in MedData, 2022 or multiyr DeathDbs
** Invalid missing code
count if cfdod==999|cfdod==9999 //0
** Invalid (bfore 2021)
count if year(cfdod)<2021 //0
** Invalid (future date)
count if cfdod!=. & cfdod>sd_currentdate //0
** Invalid (before CF Adm/Visit Date)
count if cfdod!=. & cfadmdate!=. & cfdod<cfadmdate //0
** Invalid (before DOB)
count if cfdod!=. & dob!=. & cfdod<dob //0
** Invalid (before DLC)
count if dlc!=. & cfdod!=. & cfdod<dlc //0
** Invalid (CFDOD not= DOD)
count if cfdod!=. & dod!=. & cfdod!=dod //0
** Invalid (DLC not blank; Hosp.Status=discharged)
count if sourcetype!=2 & cfdod!=. & hstatus!=1 //0
** Invalid (DLC partial missing codes for all)
count if cfdod==88 & cfdodday==. & cfdodmonth==. & cfdodyear==. //0
** Invalid (DLC not partial but partial field not blank)
count if cfdod!=88 & cfdodday!=. & cfdodmonth!=. & cfdodyear!=. //0
count if cfdod!=88 & (cfdodday!=. | cfdodmonth!=. | cfdodyear!=.) //0
** Invalid missing code (DLC partial fields)
count if cfdodday==88|cfdodday==999|cfdodday==9999 //0
count if cfdodmonth==88|cfdodmonth==999|cfdodmonth==9999 //0
count if cfdodyear==88|cfdodyear==999|cfdodyear==9999 //0
** Create CFDOD YEAR variable
drop cfdodyr
gen cfdodyr=year(cfdod)
count if cfdodyr==. //468 - 467 alive and 1 dead - record 3362 (stroke) with true missing CFDOD


*********************
** Final Diagnosis **
*********************
** Missing
count if slc==1 & finaldx=="" //0
count if slc!=2 & hstatus==1 & finaldx=="" //0
** Invalid missing code (88, 99, 999, 9999 are invalid)
count if regexm(finaldx,"9") //3 - all correct
count if regexm(finaldx,"8") //0
** Invalid (finaldx not blank and hosp.status/SLC not=discharged/alive)
count if slc!=1 & hstatus!=1 & finaldx!="" //0


***********************
** Cause(s) of Death **
***********************
** Missing
count if slc==2 & cfcods=="" //10 - record 3362 (stroke) cannot find in DeathDbs
replace dlc=cfdod if record_id=="1882" & sd_etype==2
replace cfdod=cfdod + 19 if record_id=="1882" & sd_etype==2
** Invalid missing code (88, 99, 999, 9999 are invalid)
count if regexm(cfcods,"9") //10 - check for CODs in DeathDbs and add to excel corrections sheet 
stop
count if regexm(cfcods,"8") //0
** Invalid (CODs not blank and SLC not=deceased)
count if slc!=2 & cfcods!="" //0

//corrections from above
preserve
clear
import excel using "`datapath'\version03\2-working\MissingCODs_20221208.xlsx" , firstrow case(lower)
tostring record_id, replace
save "`datapath'\version03\2-working\missing_cods" ,replace
restore

merge m:1 record_id using "`datapath'\version03\2-working\missing_cods" ,force
/*

*/
replace cfcods=elec_cfcods if _merge==3
drop elec_* _merge
erase "`datapath'\version03\2-working\missing_cods.dta"


stop
** Remove unnecessary variables (i.e. variables used for db functionality but not needed for cleaning and analysis)
cfadmdatemon cfadmdatemondash

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_cf", replace


PERFORM DUPLICATES CHECKS USING NRN, DOB, NAMES AFTER COMPLETION OF THE CF FORM AND BEFORE PROCEEDING TO CLEANING THE OTHER FORMS


** Create cleaned non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_cf", replace