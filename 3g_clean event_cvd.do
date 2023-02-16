** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3g_clean event_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-FEB-2023
    // 	date last modified      16-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Event form
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
    log using "`logpath'\3g_clean event_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_ptm", clear

count //1145

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

****************************************
** Confirmed but not fully abstracted **
****************************************
** First reivew and populate data into some variables based on initial and final dx and cfcods and cfadmdate on CF form for cases wherein case was eligible (confirmed but not fully abstracted):
count if eligible==6 //45
//list sd_etype record_id initialdx finaldx cfcods cfadmdate stype htype dxtype dstroke review edate etime etimeampm inhosp if eligible==6

** JC 13feb2023: after discussing with NS the best approach to documenting missing DA by DA vs by patient notes (i.e. ND=99/999/9999), it was decided that data missing due to DA leaving fields and/or forms blank would have the code 99999 in order to differentiate with data missing due to lack of documentation in patient notes.

** Corrections from above checks
destring flag257 ,replace
destring flag1182 ,replace
destring flag258 ,replace
destring flag1183 ,replace
destring flag259 ,replace
destring flag1184 ,replace
destring flag260 ,replace
destring flag1185 ,replace
destring flag261 ,replace
destring flag1186 ,replace
destring flag265 ,replace
destring flag1190 ,replace
destring flag266 ,replace
destring flag1191 ,replace
format flag266 flag1191 %dM_d,_CY

replace flag261=review if record_id=="3121"
replace review=4 if record_id=="3121" //see above
replace flag1186=review if record_id=="3121"

replace flag262=reviewreason if record_id=="3121"
replace reviewreason="Final dx indicates case is possibly ineligible." if record_id=="3121" //see above
replace flag1187=reviewreason if record_id=="3121"

replace flag265=reviewer___3 if record_id=="3121"
replace reviewer___3=1 if record_id=="3121" //see above
replace flag1190=reviewer___3 if record_id=="3121"

replace flag266=reviewd if record_id=="3121"
replace reviewd=d(09feb2023) if record_id=="3121" //see above
replace flag1191=reviewd if record_id=="3121"
//remove this record at the end of this dofile after the corrections list has been generated


replace flag257=stype if eligible==6 & stype==. & sd_etype==1 & record_id!="3121" //27
replace stype=2 if record_id=="3026"|record_id=="4335" //2 changes
replace stype=3 if record_id=="3342" //1 change
replace stype=1 if eligible==6 & stype==. & sd_etype==1 & record_id!="3121" //24 changes
replace flag1182=stype if eligible==6 & stype!=. & sd_etype==1 & record_id!="3121" & record_id!="2163" & record_id!="2227" //27 changes

replace flag258=htype if eligible==6 & htype==. & sd_etype==2 //15
replace htype=1 if record_id=="2791"|record_id=="3295" //2 changes
replace htype=2 if record_id=="1977"|record_id=="2883"|record_id=="3001" //3 changes
replace htype=3 if record_id=="1964"|record_id=="2331"|record_id=="2590"|record_id=="2666"|record_id=="2830"|record_id=="3551"|record_id=="4336"|record_id=="4348"|record_id=="5495" //9 changes
replace htype=4 if record_id=="3730" //1 change
replace flag1183=htype if eligible==6 & htype!=. & sd_etype==2 //15 changes

replace flag259=dxtype if eligible==6 & dxtype==. & record_id!="3121" //42
replace dxtype=99999 if eligible==6 & dxtype==. & record_id!="3121" //42 changes
replace flag1184=dxtype if eligible==6 & dxtype!=. & record_id!="3121" & record_id!="2163" & record_id!="2227" //42 changes

replace flag260=dstroke if eligible==6 & dstroke==. & sd_etype==1 & record_id!="3121" //27
replace dstroke=99999 if eligible==6 & dstroke==. & sd_etype==1 & record_id!="3121" //27 changes
replace flag1185=dstroke if eligible==6 & dstroke!=. & sd_etype==1 & record_id!="3121" & record_id!="2163" & record_id!="2227" //27 changes

replace flag261=review if eligible==6 & review==. //42
replace review=99999 if eligible==6 & review==. //42 changes
replace flag1186=review if eligible==6 & review!=. & record_id!="3121" & record_id!="2163" & record_id!="2227" //42 changes
//JC 09feb2023: I added a note in the Closing Off SOP which variables the DAs should complete (see BNR Ops Manual --> Database + Data Entry Protocols --> Database Protocol --> Closing-Off Process) so for 2022 closing off and onwards this will be done.

replace flag267=edate if eligible==6 & edate==. & record_id!="3121" //25
replace edate=cfadmdate if eligible==6 & edate==. & record_id!="3121" //see above
replace flag1192=edate if (record_id=="1876"|record_id=="1964"|record_id=="2155"|record_id=="2323"|record_id=="2331"|record_id=="2590"|record_id=="2666"|record_id=="3082"|record_id=="3104"|record_id=="3108"|record_id=="3173"|record_id=="3440"|record_id=="3551"|record_id=="3663"|record_id=="3723"|record_id=="3730"|record_id=="4112"|record_id=="4335"|record_id=="4336"|record_id=="4348"|record_id=="4361"|record_id=="4404"|record_id=="5495"|record_id=="5496"|record_id=="5497") & record_id!="3121" //25 changes

replace flag269=etime if eligible==6 & etime!="99" & etime=="" & record_id!="3121" //26
replace etime="99999" if eligible==6 & etime!="99" & etime=="" & record_id!="3121" //see above
replace flag1194=etime if (record_id=="1876"|record_id=="1964"|record_id=="2155"|record_id=="2323"|record_id=="2331"|record_id=="2590"|record_id=="2666"|record_id=="2830"|record_id=="3082"|record_id=="3104"|record_id=="3108"|record_id=="3173"|record_id=="3440"|record_id=="3551"|record_id=="3663"|record_id=="3723"|record_id=="3730"|record_id=="4112"|record_id=="4335"|record_id=="4336"|record_id=="4348"|record_id=="4361"|record_id=="4404"|record_id=="5495"|record_id=="5496"|record_id=="5497") & record_id!="3121" //26 changes


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

gen flagdate=sd_currentdate if eligible==6 & record_id!="2163" & record_id!="2227"

** JC 09feb2023: This was an incidental correction I found yesterday (3f_clean ptm_cvd.do) but forgot to add it to PTM corrections list
preserve
clear
import excel using "`datapath'\version03\2-working\MissingNRN_20230209.xlsx" , firstrow case(lower)
tostring record_id, replace
tostring elec_sd_natregno, replace
save "`datapath'\version03\2-working\missing_nrn" ,replace
restore

merge m:1 record_id using "`datapath'\version03\2-working\missing_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,144
        from master                     1,144  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------

*/
replace natregno=elec_natregno if _merge==3 //2 changes
replace flag51=sd_natregno if _merge==3
replace sd_natregno=elec_sd_natregno if _merge==3
replace flag976=sd_natregno if _merge==3
replace flag45=dob if _merge==3
replace dob=elec_dob if _merge==3
replace flag970=dob if _merge==3
replace flagdate=sd_currentdate if _merge==3 //JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace dd_dob=dob if record_id=="1831"
replace dd_natregno=sd_natregno if record_id=="1831"
replace cfage=cfage-10 if record_id=="1831"
drop elec_* _merge
erase "`datapath'\version03\2-working\missing_nrn.dta"


/*
** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile (so added the code for that to this dofile and all the others preceding it with corrections).

** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flagdate flag45 flag970 flag266 flag1191 flag267 flag1192 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag45 flag51 flag257 flag258 flag259 flag260 flag261 flag262 flag265 flag266 flag267 flag269 if ///
		(flag45!=. | flag51!="" | flag257!=. | flag258!=. | flag259!=. | flag260!=. | flag261!=. | flag262!="" | flag265!=. | flag266!=. | flag267!=. | flag269!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_EVE1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag970 flag976 flag1182 flag1183 flag1184 flag1185 flag1186 flag1187 flag1190 flag1191 flag1192 flag1194 if ///
		 (flag970!=. | flag976!="" | flag1182!=. | flag1183!=. | flag1184!=. | flag1185!=. | flag1186!=. | flag1187!="" | flag1190!=. | flag1191!=. | flag1192!=. | flag1194!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_EVE1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/

** In order to split up the excel lists for this form so they are not too large, remove the flagdate once the above list has been created
drop sd_currentdate flagdate


** Symptoms (Stroke) **

********************
** Slurred Speech **
********************
** Missing
count if ssym1==. & sd_etype==1 & event_complete!=0 & event_complete!=. //5 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form; 2 stroke records 1910 + 2261 have all forms completed so these are corrected below.
** Invalid missing code
count if ssym1==88|ssym1==999|ssym1==9999 //0
** Missing date
count if ssym1d==. & ssym1==1 //4 - checked CVDdb and these have atscene date=99; record 2965 was partial but month was long in advance of admission so will not use.
** Invalid (not 2021)
count if ssym1d!=. & year(ssym1d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & ssym1d!=. & ssym1d<dob //0
** possibly Invalid (after CFAdmDate)
count if ssym1d!=. & cfadmdate!=. & ssym1d>cfadmdate & inhosp!=1 //4 - records 2309 + 2885 are strokes-in-evolution; 2 corrected below
** possibly Invalid (after DLC/DOD)
count if dlc!=. & ssym1d!=. & ssym1d>dlc //3 - 2 corrected below; record 2309 is stroke-in-evolution
count if cfdod!=. & ssym1d!=. & ssym1d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if ssym1d!=. & dae!=. & ssym1d>dae & inhosp!=1 //4 - records 2309 + 2885 are strokes-in-evolution; 2 corrected below
** possibly Invalid (after WardAdmDate)
count if ssym1d!=. & doh!=. & ssym1d>doh & inhosp!=1 //3 - records 2309 + 2885 are strokes-in-evolution; 1 corrected below
** Invalid (future date)
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY
count if ssym1d!=. & ssym1d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ssym1==1 & ssym1d==. & ssym1day==99 & ssym1month==99 & ssym1year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if ssym1d==. & ssym1day!=. & ssym1month!=. & ssym1year!=. //1 - record 2965 was partial but month was long in advance of admission so will not use.
replace ssym1day=. if ssym1d==. & ssym1day!=. & ssym1month!=. & ssym1year!=. //0 changes
replace ssym1month=. if ssym1d==. & ssym1month!=. & ssym1year!=. //0 changes
replace ssym1year=. if ssym1d==. & ssym1year!=. //0 changes
count if ssym1d==. & (ssym1day!=. | ssym1month!=. | ssym1year!=.) //0
** Invalid missing code (notified date partial fields)
count if ssym1day==88|ssym1day==999|ssym1day==9999 //0
count if ssym1month==88|ssym1month==999|ssym1month==9999 //0
count if ssym1year==88|ssym1year==99|ssym1year==999 //0
** Invalid (after NotifiedDate)
count if ssym1d!=. & ambcalld!=. & ssym1d>ambcalld & inhosp!=1 //4 - all corrected below
** Invalid (after AtSceneDate)
count if ssym1d!=. & atscnd!=. & ssym1d>atscnd & inhosp!=1 //1 - record 3399 changed at end of ptm dofile when populating atscnd + frmscnd so DAs don't need to correct in CVDdb
replace atscnd=dae if record_id=="3399"
** Invalid (after FromSceneDate)
count if ssym1d!=. & frmscnd!=. & ssym1d>frmscnd & inhosp!=1 //1 - record 3399 changed at end of ptm dofile when populating atscnd + frmscnd so DAs don't need to correct in CVDdb
replace frmscnd=dae if record_id=="3399"
** Invalid (after AtHospitalDate)
count if ssym1d!=. & hospd!=. & ssym1d>hospd & inhosp!=1 //1 - record 3399 corrected below
** Invalid (before EventDate)
count if ssym1d!=. & edate!=. & ssym1d<edate //0



** Corrections from above checks
destring flag176 ,replace
destring flag1101 ,replace
destring flag177 ,replace
destring flag1102 ,replace
destring flag178 ,replace
destring flag1103 ,replace
destring flag179 ,replace
destring flag1104 ,replace
destring flag187 ,replace
destring flag1112 ,replace
destring flag194 ,replace
destring flag1119 ,replace
destring flag240 ,replace
destring flag1165 ,replace
destring flag202 ,replace
destring flag1127 ,replace
destring flag206 ,replace
destring flag1131 ,replace
format flag194 flag1119 flag202 flag1127 flag206 flag1131 flag240 flag1165 %dM_d,_CY
destring flag244 ,replace
destring flag1169 ,replace
destring flag245 ,replace
destring flag1170 ,replace
destring flag246 ,replace
destring flag1171 ,replace
destring flag247 ,replace
destring flag1172 ,replace
destring flag248 ,replace
destring flag1173 ,replace
destring flag249 ,replace
destring flag1174 ,replace
destring flag254 ,replace
destring flag1179 ,replace
destring flag255 ,replace
destring flag1180 ,replace
destring flag268 ,replace
destring flag1193 ,replace

** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
//replace flag176=ssym1 if record_id=="1910"|record_id=="2261"
replace ssym1=99999 if record_id=="1910"|record_id=="2261" //see above
//replace flag1101=ssym1 if record_id=="1910"|record_id=="2261"

//replace flag177=ssym2 if record_id=="1910"|record_id=="2261"
replace ssym2=99999 if record_id=="1910"|record_id=="2261" //see above
//replace flag1102=ssym2 if record_id=="1910"|record_id=="2261"

//replace flag178=ssym3 if record_id=="1910"
replace ssym3=99999 if record_id=="1910" //see above
//replace flag1103=ssym3 if record_id=="1910"

//replace flag179=ssym4 if record_id=="1910"
replace ssym4=99999 if record_id=="1910" //see above
//replace flag1104=ssym4 if record_id=="1910"

replace flag187=osym if record_id=="1910"|record_id=="2261"
replace osym=1 if record_id=="1910" //see above
replace flag1112=osym if record_id=="1910"|record_id=="2261"
replace osym=99999 if record_id=="2261" //see above

replace flag188=osym1 if record_id=="1910"
replace osym1="HEADACHE" if record_id=="1910" //see above
replace flag1113=osym1 if record_id=="1910"

replace flag194=ssym1d if record_id=="1843"|record_id=="1925"
replace ssym1d=edate if record_id=="1843"|record_id=="1925" //see above
replace flag1119=ssym1d if record_id=="1843"|record_id=="1925"

replace flag202=ssym3d if record_id=="2261"|record_id=="1843"|record_id=="1925"
replace ssym3d=edate if record_id=="2261"|record_id=="1843"|record_id=="1925" //see above
replace flag1127=ssym3d if record_id=="2261"|record_id=="1843"|record_id=="1925"

replace flag206=ssym4d if record_id=="2261"
replace ssym4d=edate if record_id=="2261" //see above
replace flag1131=ssym4d if record_id=="2261"

replace flag240=osymd if record_id=="1910"
replace osymd=edate if record_id=="1910" //see above
replace flag1165=osymd if record_id=="1910"

//replace flag244=sign1 if record_id=="1910"|record_id=="2261"
replace sign1=99999 if record_id=="1910"|record_id=="2261" //see above
//replace flag1169=sign1 if record_id=="1910"|record_id=="2261"

//replace flag245=sign2 if record_id=="1910"
replace sign2=99999 if record_id=="1910" //see above
//replace flag1170=sign2 if record_id=="1910"

//replace flag246=sign3 if record_id=="1910"|record_id=="2261"
replace sign3=99999 if record_id=="1910"|record_id=="2261" //see above
//replace flag1171=sign3 if record_id=="1910"|record_id=="2261"

//replace flag247=sign4 if record_id=="1910"
replace sign4=99999 if record_id=="1910" //see above
//replace flag1172=sign4 if record_id=="1910"

//replace flag248=sonset if record_id=="1910"
replace sonset=99999 if record_id=="1910" //see above
//replace flag1173=sonset if record_id=="1910"

//replace flag249=sday if record_id=="1910"
replace sday=99999 if record_id=="1910" //see above
//replace flag1174=sday if record_id=="1910"

//replace flag254=cardmon if record_id=="1910"|record_id=="2261"
replace cardmon=99999 if record_id=="1910"|record_id=="2261" //see above
//replace flag1179=cardmon if record_id=="1910"|record_id=="2261"

//replace flag255=nihss if record_id=="1910"
replace nihss=99999 if record_id=="1910" //see above
//replace flag1180=nihss if record_id=="1910"
//stroke record 1910 was missing all the symptoms + signs info although all forms were completed - used symptom from initial dx on CF form
//stroke record 2261 was missing some of the symptoms + signs info although all forms were completed

//replace flag268=inhosp if record_id=="1719"
replace inhosp=. if record_id=="1719" //see above
//replace flag1193=inhosp if record_id=="1719"
//JC 09feb2023 - I already erased this on CVDdb

replace flag129=ambcalld if record_id=="1719"|record_id=="2936"|record_id=="3399"|record_id=="3750"
replace ambcalld=dae if record_id=="1719"|record_id=="2936"|record_id=="3399"|record_id=="3750" //see above
replace flag1054=ambcalld if record_id=="1719"|record_id=="2936"|record_id=="3399"|record_id=="3750"

replace flag150=hospd if record_id=="3399"
replace hospd=dae if record_id=="3399" //see above
replace flag1075=hospd if record_id=="3399"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

gen flagdate=sd_currentdate if record_id=="1910"|record_id=="2261"|record_id=="1843"|record_id=="1925"|record_id=="1719"|record_id=="2936"|record_id=="3399"|record_id=="3750"


******************************
** Diminshed Responsiveness **
******************************
** Missing
count if ssym2==. & sd_etype==1 & event_complete!=0 & event_complete!=. //4 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form; stroke record 1889 does not have all fields and/or forms completed so these are corrected below.
** Invalid missing code
count if ssym2==88|ssym2==999|ssym2==9999 //0
** Missing date
count if ssym2d==. & ssym2==1 //0
** Invalid (not 2021)
count if ssym2d!=. & year(ssym2d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & ssym2d!=. & ssym2d<dob //0
** possibly Invalid (after CFAdmDate)
count if ssym2d!=. & cfadmdate!=. & ssym2d>cfadmdate & inhosp!=1 //6 - records 1729, 2309, 2353 2623, 3136 + 2654 are strokes-in-evolution so leave as is.
** possibly Invalid (after DLC/DOD)
count if dlc!=. & ssym2d!=. & ssym2d>dlc //5 - all are strokes-in-evolution
count if cfdod!=. & ssym2d!=. & ssym2d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if ssym2d!=. & dae!=. & ssym2d>dae & inhosp!=1 //6 - all are strokes-in-evolution
** possibly Invalid (after WardAdmDate)
count if ssym2d!=. & doh!=. & ssym2d>doh & inhosp!=1 //5 - all are strokes-in-evolution
** Invalid (future date)
count if ssym2d!=. & ssym2d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ssym2==1 & ssym2d==. & ssym2day==99 & ssym2month==99 & ssym2year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if ssym2d==. & ssym2day!=. & ssym2month!=. & ssym2year!=. //1 - record 2965 was partial but month was long in advance of admission so will not use.
replace ssym2day=. if ssym2d==. & ssym2day!=. & ssym2month!=. & ssym2year!=. //0 changes
replace ssym2month=. if ssym2d==. & ssym2month!=. & ssym2year!=. //0 changes
replace ssym2year=. if ssym2d==. & ssym2year!=. //0 changes
count if ssym2d==. & (ssym2day!=. | ssym2month!=. | ssym2year!=.) //0
** Invalid missing code (notified date partial fields)
count if ssym2day==88|ssym2day==999|ssym2day==9999 //0
count if ssym2month==88|ssym2month==999|ssym2month==9999 //0
count if ssym2year==88|ssym2year==99|ssym2year==999 //0
** Invalid (after NotifiedDate)
count if ssym2d!=. & ambcalld!=. & ssym2d>ambcalld & inhosp!=1 //2 - both are strokes-in-evolution
** Invalid (after AtSceneDate)
count if ssym2d!=. & atscnd!=. & ssym2d>atscnd & inhosp!=1 //2 - both are strokes-in-evolution
** Invalid (after FromSceneDate)
count if ssym2d!=. & frmscnd!=. & ssym2d>frmscnd & inhosp!=1 //2 - both are strokes-in-evolution
** Invalid (after AtHospitalDate)
count if ssym2d!=. & hospd!=. & ssym2d>hospd & inhosp!=1 //2 - both are strokes-in-evolution
** Invalid (before EventDate)
count if ssym2d!=. & edate!=. & ssym2d<edate //0



** Corrections from above checks
destring flag310 ,replace
destring flag1235 ,replace
destring flag311 ,replace
destring flag1236 ,replace
destring flag313 ,replace
destring flag1238 ,replace
destring flag317 ,replace
destring flag1242 ,replace
destring flag328 ,replace
destring flag1253 ,replace
destring flag342 ,replace
destring flag1267 ,replace
destring flag405 ,replace
destring flag1330 ,replace

//replace flag177=ssym2 if record_id=="1889"
replace ssym2=99999 if record_id=="1889" //see above
//replace flag1102=ssym2 if record_id=="1889"

//replace flag179=ssym4 if record_id=="1889"
replace ssym4=99999 if record_id=="1889" //see above
//replace flag1104=ssym4 if record_id=="1889"

//replace flag254=cardmon if record_id=="1889"
replace cardmon=99999 if record_id=="1889" //see above
//replace flag1179=cardmon if record_id=="1889"

//replace flag310=sysbp if record_id=="1889"
replace sysbp=99999 if record_id=="1889" //see above
//replace flag1235=sysbp if record_id=="1889"

//replace flag311=diasbp if record_id=="1889"
replace diasbp=99999 if record_id=="1889" //see above
//replace flag1236=diasbp if record_id=="1889"

//replace flag313=bgunit if record_id=="1889"
replace bgunit=99999 if record_id=="1889" //see above
//replace flag1238=bgunit if record_id=="1889"

//replace flag317=assess if record_id=="1889"
replace assess=99999 if record_id=="1889" //see above
//replace flag1242=assess if record_id=="1889"

//replace flag328=dieany if record_id=="1889"
replace dieany=99999 if record_id=="1889" //see above
//replace flag1253=dieany if record_id=="1889"

//replace flag342=ct if record_id=="1889"
replace ct=99999 if record_id=="1889" //see above
//replace flag1267=ct if record_id=="1889"

//replace flag405=tiany if record_id=="1889"
replace tiany=99999 if record_id=="1889" //see above
//replace flag1330=tiany if record_id=="1889"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
//replace flagdate=sd_currentdate if record_id=="1889"


**************
** Weakness **
**************
** Missing
count if ssym3==. & sd_etype==1 & event_complete!=0 & event_complete!=. //3 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid missing code
count if ssym3==88|ssym3==999|ssym3==9999 //0
** Missing date
count if ssym3d==. & ssym3==1 //1 - date=99 in CVDdb; leave as is.
** Invalid (not 2021)
count if ssym3d!=. & year(ssym3d)!=2021 //1 - corrected below
** Invalid (before DOB)
count if dob!=. & ssym3d!=. & ssym3d<dob //0
** possibly Invalid (after CFAdmDate)
count if ssym3d!=. & cfadmdate!=. & ssym3d>cfadmdate & inhosp!=1 //3 - records 2309 + 2623 are strokes-in-evolution so leave as is; 1 corrected below.
** possibly Invalid (after DLC/DOD)
count if dlc!=. & ssym3d!=. & ssym3d>dlc //2 - all are strokes-in-evolution
count if cfdod!=. & ssym3d!=. & ssym3d>cfdod //1 - corrected below
** possibly Invalid (after A&EAdmDate)
count if ssym3d!=. & dae!=. & ssym3d>dae & inhosp!=1 //3 - 2 are strokes-in-evolution; 1 corrected below
** possibly Invalid (after WardAdmDate)
count if ssym3d!=. & doh!=. & ssym3d>doh & inhosp!=1 //2 - all are strokes-in-evolution
** Invalid (future date)
count if ssym3d!=. & ssym3d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ssym3==1 & ssym3d==. & ssym3day==99 & ssym3month==99 & ssym3year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if ssym3d==. & ssym3day!=. & ssym3month!=. & ssym3year!=. //0
replace ssym3day=. if ssym3d==. & ssym3day!=. & ssym3month!=. & ssym3year!=. //0 changes
replace ssym3month=. if ssym3d==. & ssym3month!=. & ssym3year!=. //0 changes
replace ssym3year=. if ssym3d==. & ssym3year!=. //0 changes
count if ssym3d==. & (ssym3day!=. | ssym3month!=. | ssym3year!=.) //0
** Invalid missing code (notified date partial fields)
count if ssym3day==88|ssym3day==999|ssym3day==9999 //0
count if ssym3month==88|ssym3month==999|ssym3month==9999 //0
count if ssym3year==88|ssym3year==99|ssym3year==999 //0
** Invalid (after NotifiedDate)
count if ssym3d!=. & ambcalld!=. & ssym3d>ambcalld & inhosp!=1 //1 - record 3204 corrected below
** Invalid (after AtSceneDate)
count if ssym3d!=. & atscnd!=. & ssym3d>atscnd & inhosp!=1 //1 - record 3204 changed at end of ptm dofile when populating atscnd + frmscnd so DAs don't need to correct in CVDdb; corrected below
replace atscnd=dae if record_id=="3204"
** Invalid (after FromSceneDate)
count if ssym3d!=. & frmscnd!=. & ssym3d>frmscnd & inhosp!=1 //1 - record 3204 changed at end of ptm dofile when populating atscnd + frmscnd so DAs don't need to correct in CVDdb; corrected below
replace frmscnd=dae if record_id=="3204"
** Invalid (after AtHospitalDate)
count if ssym3d!=. & hospd!=. & ssym3d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if ssym3d!=. & edate!=. & ssym3d<edate //0



** Corrections from above checks
destring flag135 ,replace
destring flag1060 ,replace

replace flag202=ssym3d if record_id=="2906"
replace ssym3d=edate if record_id=="2906" //see above
replace flag1127=ssym3d if record_id=="2906"

replace flag129=ambcalld if record_id=="3204"
replace ambcalld=dae if record_id=="3204" //see above
replace flag1054=ambcalld if record_id=="3204"

replace flag133=ambcallt if record_id=="3204"
replace flag140=atscnt if record_id=="3204"
replace flag147=frmscnt if record_id=="3204"
replace ambcallt=subinstr(ambcallt,"13","09",.) if record_id=="3204"
replace atscnt=subinstr(atscnt,"13","09",.) if record_id=="3204"
replace frmscnt=subinstr(frmscnt,"13","09",.) if record_id=="3204"
replace flag1058=ambcallt if record_id=="3204"
replace flag1065=atscnt if record_id=="3204"
replace flag1072=frmscnt if record_id=="3204"

replace flag135=atscene if record_id=="3204"
replace atscene=1 if record_id=="3204" //see above
replace flag1060=atscene if record_id=="3204"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2906"|record_id=="3204"

*************
** Swallow **
*************
** Missing
count if ssym4==. & sd_etype==1 & event_complete!=0 & event_complete!=. //3 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid missing code
count if ssym4==88|ssym4==999|ssym4==9999 //0
** Missing date
count if ssym4d==. & ssym4==1 //0
** Invalid (not 2021)
count if ssym4d!=. & year(ssym4d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & ssym4d!=. & ssym4d<dob //0
** possibly Invalid (after CFAdmDate)
count if ssym4d!=. & cfadmdate!=. & ssym4d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & ssym4d!=. & ssym4d>dlc //0
count if cfdod!=. & ssym4d!=. & ssym4d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if ssym4d!=. & dae!=. & ssym4d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if ssym4d!=. & doh!=. & ssym4d>doh & inhosp!=1 //0
** Invalid (future date)
count if ssym4d!=. & ssym4d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if ssym4==1 & ssym4d==. & ssym4day==99 & ssym4month==99 & ssym4year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if ssym4d==. & ssym4day!=. & ssym4month!=. & ssym4year!=. //0
replace ssym4day=. if ssym4d==. & ssym4day!=. & ssym4month!=. & ssym4year!=. //0 changes
replace ssym4month=. if ssym4d==. & ssym4month!=. & ssym4year!=. //0 changes
replace ssym4year=. if ssym4d==. & ssym4year!=. //0 changes
count if ssym4d==. & (ssym4day!=. | ssym4month!=. | ssym4year!=.) //0
** Invalid missing code (notified date partial fields)
count if ssym4day==88|ssym4day==999|ssym4day==9999 //0
count if ssym4month==88|ssym4month==999|ssym4month==9999 //0
count if ssym4year==88|ssym4year==99|ssym4year==999 //0
** Invalid (after NotifiedDate)
count if ssym4d!=. & ambcalld!=. & ssym4d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if ssym4d!=. & atscnd!=. & ssym4d>atscnd & inhosp!=1 //0
** Invalid (after FromSceneDate)
count if ssym4d!=. & frmscnd!=. & ssym4d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if ssym4d!=. & hospd!=. & ssym4d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if ssym4d!=. & edate!=. & ssym4d<edate //0



** Symptoms (Heart) **

****************
** Chest Pain **
****************
** Missing
count if hsym1==. & sd_etype==2 & event_complete!=0 & event_complete!=. //4 - all incorrect: records 2256, 2260, 2902 + 2920 corrected below
** Invalid missing code
count if hsym1==88|hsym1==999|hsym1==9999 //0
** Missing date
count if hsym1d==. & hsym1==1 //0
** Invalid (not 2021)
count if hsym1d!=. & year(hsym1d)!=2021 //1 - corrected below
** Invalid (before DOB)
count if dob!=. & hsym1d!=. & hsym1d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym1d!=. & cfadmdate!=. & hsym1d>cfadmdate & inhosp!=1 //2 - corrected below; Checked MedData notes for record 3318
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym1d!=. & hsym1d>dlc //1 - corrected below
count if cfdod!=. & hsym1d!=. & hsym1d>cfdod //1 - corrected below
** possibly Invalid (after A&EAdmDate)
count if hsym1d!=. & dae!=. & hsym1d>dae & inhosp!=1 //2 - corrected below
** possibly Invalid (after WardAdmDate)
count if hsym1d!=. & doh!=. & hsym1d>doh & inhosp!=1 //1 - corrected below
** Invalid (future date)
count if hsym1d!=. & hsym1d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym1==1 & hsym1d==. & hsym1day==99 & hsym1month==99 & hsym1year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym1d==. & hsym1day!=. & hsym1month!=. & hsym1year!=. //0
replace hsym1day=. if hsym1d==. & hsym1day!=. & hsym1month!=. & hsym1year!=. //0 changes
replace hsym1month=. if hsym1d==. & hsym1month!=. & hsym1year!=. //0 changes
replace hsym1year=. if hsym1d==. & hsym1year!=. //0 changes
count if hsym1d==. & (hsym1day!=. | hsym1month!=. | hsym1year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym1day==88|hsym1day==999|hsym1day==9999 //0
count if hsym1month==88|hsym1month==999|hsym1month==9999 //0
count if hsym1year==88|hsym1year==99|hsym1year==999 //0
** Invalid (after NotifiedDate)
count if hsym1d!=. & ambcalld!=. & hsym1d>ambcalld & inhosp!=1 //1 - corrected below
** Invalid (after AtSceneDate)
count if hsym1d!=. & atscnd!=. & hsym1d>atscnd & inhosp!=1 //1 - record 4371 changed at end of ptm dofile when populating atscnd + frmscnd so DAs don't need to correct in CVDdb; corrected below
replace atscnd=dae if record_id=="4371"
** Invalid (after FromSceneDate)
count if hsym1d!=. & frmscnd!=. & hsym1d>frmscnd & inhosp!=1 //1 - record 4371 changed at end of ptm dofile when populating atscnd + frmscnd so DAs don't need to correct in CVDdb; corrected below
replace frmscnd=dae if record_id=="4371"
** Invalid (after AtHospitalDate)
count if hsym1d!=. & hospd!=. & hsym1d>hospd & inhosp!=1 //1 - corrected below
** Invalid (before EventDate)
count if hsym1d!=. & edate!=. & hsym1d<edate //1 - corrected below
** Missing time
count if hsym1t=="" & hsym1==1 //0
** Invalid (time format)
count if hsym1t!="" & hsym1t!="88" & hsym1t!="99" & (length(hsym1t)<5|length(hsym1t)>5) //0
count if hsym1t!="" & hsym1t!="88" & hsym1t!="99" & !strmatch(strupper(hsym1t), "*:*") //0
generate byte non_numeric_hsym1t = indexnot(hsym1t, "0123456789.-:")
count if non_numeric_hsym1t //0
** Invalid missing code
count if hsym1t=="999"|hsym1t=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if hsym1t=="88" & hsym1tampm==. //0
** Invalid (symptom time after notified time)
count if hsym1t!="" & hsym1t!="99" & ambcallt!="" & ambcallt!="99" & hsym1t>ambcallt //18 - 15 correct; records 1918, 2425 (query for NS), 2892 (query for NS) corrected below
gen comments="JC 13feb2023: after reviewing case with NS today, note the irregularity with ambulance times and chest pain time will remain as cannot confirm event time in MedData or any other external source at this point in data handling." if record_id=="2425"
** Invalid (symptom time after time at scene)
count if hsym1t!="" & hsym1t!="99" & atscnt!="" & atscnt!="99" & hsym1t>atscnt //18 - same records as above
** Invalid (symptom time after time from scene)
count if hsym1t!="" & hsym1t!="99" & frmscnt!="" & frmscnt!="99" & hsym1t>frmscnt //17 - same records as above
** Invalid (symptom time after time at hospital)
count if hsym1t!="" & hsym1t!="99" & hospt!="" & hospt!="99" & hsym1t>hospt //12 - same records as above
** Invalid (symptom time after event time)
count if hsym1t!="" & hsym1t!="99" & etime!="" & etime!="99" & hsym1t>etime //1 - record 3361 (query for NS)



** Corrections from above checks
destring flag180 ,replace
destring flag1105 ,replace
destring flag181 ,replace
destring flag1106 ,replace
destring flag182 ,replace
destring flag1107 ,replace
destring flag183 ,replace
destring flag1108 ,replace
destring flag184 ,replace
destring flag1109,replace
destring flag185 ,replace
destring flag1110 ,replace
destring flag186 ,replace
destring flag1111 ,replace
destring flag271 ,replace
destring flag1196 ,replace
destring flag272 ,replace
destring flag1197 ,replace
destring flag210 ,replace
destring flag1135 ,replace
destring flag216 ,replace
destring flag1141 ,replace
destring flag220 ,replace
destring flag1145 ,replace
destring flag224 ,replace
destring flag1149 ,replace
destring flag232 ,replace
destring flag1157 ,replace
destring flag236 ,replace
destring flag1161 ,replace
format flag210 flag1135 flag216 flag1141 flag224 flag1149 flag232 flag1157 flag236 flag1161 %dM_d,_CY

//replace flag180=hsym1 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"
replace hsym1=99999 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920" //see above
//replace flag1105=hsym1 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"

//replace flag181=hsym2 if record_id=="2256"|record_id=="2260"|record_id=="2902"
replace hsym2=99999 if record_id=="2256"|record_id=="2260"|record_id=="2902" //see above
//replace flag1106=hsym2 if record_id=="2256"|record_id=="2260"|record_id=="2902"

//replace flag182=hsym3 if record_id=="2256"|record_id=="2260"|record_id=="2902"
replace hsym3=99999 if record_id=="2256"|record_id=="2260"|record_id=="2902" //see above
//replace flag1107=hsym3 if record_id=="2256"|record_id=="2260"|record_id=="2902"

//replace flag183=hsym4 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"
replace hsym4=99999 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920" //see above
//replace flag1108=hsym4 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"

//replace flag184=hsym5 if record_id=="2256"|record_id=="2902"|record_id=="2920"
replace hsym5=99999 if record_id=="2256"|record_id=="2902"|record_id=="2920" //see above
//replace flag1109=hsym5 if record_id=="2256"|record_id=="2902"|record_id=="2920"

//replace flag185=hsym6 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"
replace hsym6=99999 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920" //see above
//replace flag1110=hsym6 if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"

//replace flag186=hsym7 if record_id=="2256"|record_id=="2260"|record_id=="2902"
replace hsym7=99999 if record_id=="2256"|record_id=="2260"|record_id=="2902" //see above
//replace flag1111=hsym7 if record_id=="2256"|record_id=="2260"|record_id=="2902"

replace flag268=inhosp if record_id=="2256"
replace inhosp=1 if record_id=="2256" //see above
replace flag1193=inhosp if record_id=="2256"

//replace flag271=cardiac if record_id=="2256"
replace cardiac=99999 if record_id=="2256" //see above
//replace flag1196=cardiac if record_id=="2256"

//replace flag272=cardiachosp if record_id=="2256"
replace cardiachosp=99999 if record_id=="2256" //see above
//replace flag1197=cardiachosp if record_id=="2256"

replace flag74=eligible if record_id=="2920"
replace eligible=6 if record_id=="2920" //see above
replace flag999=eligible if record_id=="2920"
//JC 10feb2023: forms History down to Discharge are blank - no comments to indicate reason so changed eligible case status from completed to confirmed but not fully abstracted

replace flag210=hsym1d if record_id=="1946"|record_id=="3318"|record_id=="2863"|record_id=="1918"
replace hsym1d=edate if record_id=="1946"|record_id=="3318"|record_id=="2863" //see above
replace hsym1d=hsym1d+1 if record_id=="1918" //see above
replace flag1135=hsym1d if record_id=="1946"|record_id=="3318"|record_id=="2863"|record_id=="1918"

replace flag216=hsym2d if record_id=="3318"|record_id=="1918"
replace hsym2d=edate if record_id=="3318" //see above
replace hsym2d=hsym2d-1 if record_id=="1918" //see above
replace flag1141=hsym2d if record_id=="3318"|record_id=="1918"

replace flag220=hsym3d if record_id=="1918"
replace hsym3d=hsym3d+1 if record_id=="1918" //see above
replace flag1145=hsym3d if record_id=="1918"

replace flag224=hsym4d if record_id=="3318"
replace hsym4d=edate if record_id=="3318" //see above
replace flag1149=hsym4d if record_id=="3318"

replace flag232=hsym6d if record_id=="3318"
replace hsym6d=edate if record_id=="3318" //see above
replace flag1157=hsym6d if record_id=="3318"

replace flag236=hsym7d if record_id=="3318"|record_id=="1918"
replace hsym7d=edate if record_id=="3318" //see above
replace hsym7d=hsym7d+1 if record_id=="1918" //see above
replace flag1161=hsym7d if record_id=="3318"|record_id=="1918"

replace flag129=ambcalld if record_id=="4371"
replace ambcalld=dae if record_id=="4371" //see above
replace flag1054=ambcalld if record_id=="4371"

replace flag150=hospd if record_id=="4371"
replace hospd=dae if record_id=="4371" //see above
replace flag1075=hospd if record_id=="4371"

replace flag74=eligible if record_id=="4371"
replace eligible=4 if record_id=="4371" //see above
replace flag999=eligible if record_id=="4371"
//JC 10feb2023: 28d form is blank so changed eligible case status from completed to pending 28d F/U

replace flag267=edate if record_id=="1918"
replace edate=edate+1 if record_id=="1918" //see above
replace flag1192=edate if record_id=="1918"

replace flag154=hospt if record_id=="2892"
replace hospt=subinstr(hospt,"19","09",.) if record_id=="2892"
replace flag1079=hospt if record_id=="2892"

replace flag269=etime if record_id=="2892"|record_id=="3361"
replace etime=hsym1t if record_id=="2892"|record_id=="3361"
replace flag1194=etime if record_id=="2892"|record_id=="3361"


** Invalid (eligible NOT=pending 28d f/u; 28d form is blank)
//order sd_etype record_id eligible casefinding_complete demographics_complete patient_management_complete event_complete history_complete tests_complete complications_dx_complete medications_complete discharge_complete day_fu_complete

count if eligible!=4 & eligible!=6 & day_fu_complete==0 //1
//JC 10feb2023: Incidentally saw an error for this so for 2022 onwards to add in this above check (I've already added a note in dofile 3a_clean cf_cvd.do)
replace day_fu_complete=1 if record_id=="1945" //DAs don't need to update CVDdb as the form status for 28d form is already set to Unverified.

count if eligible!=6 & sd_casetype==1 & (casefinding_complete==0|demographics_complete==0|patient_management_complete==0|event_complete==0|history_complete==0|tests_complete==0|complications_dx_complete==0|medications_complete==0|discharge_complete==0|day_fu_complete==0) //2 - 1 correct

replace casefinding_complete=1 if record_id=="1945"
replace demographics_complete=1 if record_id=="1945"
replace patient_management_complete=1 if record_id=="1945"
replace event_complete=1 if record_id=="1945"
replace history_complete=1 if record_id=="1945"
replace tests_complete=1 if record_id=="1945"
replace complications_dx_complete=1 if record_id=="1945"
replace medications_complete=1 if record_id=="1945"
replace discharge_complete=1 if record_id=="1945"
//1945 was mistakenly entered into heart arm by DA so that's why these forms appear as incomplete but this record contains the stroke data as the heart record was dropped when the records were merged in the prep dofile
//DAs don't need to update CVDdb as the form status for 28d form is already set to Unverified.

count if eligible!=6 & sd_casetype==1 & (casefinding_complete==.|demographics_complete==.|patient_management_complete==.|event_complete==.|history_complete==.|tests_complete==.|complications_dx_complete==.|medications_complete==.|discharge_complete==.|day_fu_complete==.) //9 - 5 correct; record 1889 missing Tests form in CVDdb so leave as is; 3 corrected below.

replace flag74=eligible if record_id=="2244"|record_id=="2912"|record_id=="4229"
replace eligible=4 if record_id=="2244"|record_id=="2912"|record_id=="4229" //see above
replace flag999=eligible if record_id=="2244"|record_id=="2912"|record_id=="4229"
//JC 10feb2023: 28d form is blank so changed eligible case status from completed to pending 28d F/U


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2256"|record_id=="2260"|record_id=="2902"|record_id=="2920"|record_id=="1946"|record_id=="3318"|record_id=="2863"|record_id=="1918"|record_id=="4371"|record_id=="2892"|record_id=="3361"|record_id=="2244"|record_id=="2912"|record_id=="4229"

*********
** SOB **
*********
** Missing
count if hsym2==. & sd_etype==2 & event_complete!=0 & event_complete!=. //1 - all incorrect: records 3290 corrected below
** Invalid missing code
count if hsym2==88|hsym2==999|hsym2==9999 //0
** Missing date
count if hsym2d==. & hsym2==1 //1 - correct as hsym2d=99 in CVDdb
** Invalid (not 2021)
count if hsym2d!=. & year(hsym2d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hsym2d!=. & hsym2d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym2d!=. & cfadmdate!=. & hsym2d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym2d!=. & hsym2d>dlc //0
count if cfdod!=. & hsym2d!=. & hsym2d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if hsym2d!=. & dae!=. & hsym2d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if hsym2d!=. & doh!=. & hsym2d>doh & inhosp!=1 //0
** Invalid (future date)
count if hsym2d!=. & hsym2d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym2==1 & hsym2d==. & hsym2day==99 & hsym2month==99 & hsym2year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym2d==. & hsym2day!=. & hsym2month!=. & hsym2year!=. //0
replace hsym2day=. if hsym2d==. & hsym2day!=. & hsym2month!=. & hsym2year!=. //0 changes
replace hsym2month=. if hsym2d==. & hsym2month!=. & hsym2year!=. //0 changes
replace hsym2year=. if hsym2d==. & hsym2year!=. //0 changes
count if hsym2d==. & (hsym2day!=. | hsym2month!=. | hsym2year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym2day==88|hsym2day==999|hsym2day==9999 //0
count if hsym2month==88|hsym2month==999|hsym2month==9999 //0
count if hsym2year==88|hsym2year==99|hsym2year==999 //0
** Invalid (after NotifiedDate)
count if hsym2d!=. & ambcalld!=. & hsym2d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if hsym2d!=. & atscnd!=. & hsym2d>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if hsym2d!=. & frmscnd!=. & hsym2d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if hsym2d!=. & hospd!=. & hsym2d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hsym2d!=. & edate!=. & hsym2d<edate //0


** Corrections from above checks

** Below are blank/unanswered in CVDdb
replace hsym2=99999 if record_id=="3290" //see above
replace hsym4=99999 if record_id=="3290"
replace hsym5=99999 if record_id=="3290"
replace hsym6=99999 if record_id=="3290"
replace hsym7=99999 if record_id=="3290"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
//replace flagdate=sd_currentdate if record_id==""


***************
** Vomitting **
***************
** Missing
count if hsym3==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if hsym3==88|hsym3==999|hsym3==9999 //0
** Missing date
count if hsym3d==. & hsym3==1 //2 - correct as hsym3d=99 in CVDdb
** Invalid (not 2021)
count if hsym3d!=. & year(hsym3d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hsym3d!=. & hsym3d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym3d!=. & cfadmdate!=. & hsym3d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym3d!=. & hsym3d>dlc //0
count if cfdod!=. & hsym3d!=. & hsym3d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if hsym3d!=. & dae!=. & hsym3d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if hsym3d!=. & doh!=. & hsym3d>doh & inhosp!=1 //0
** Invalid (future date)
count if hsym3d!=. & hsym3d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym3==1 & hsym3d==. & hsym3day==99 & hsym3month==99 & hsym3year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym3d==. & hsym3day!=. & hsym3month!=. & hsym3year!=. //0
replace hsym3day=. if hsym3d==. & hsym3day!=. & hsym3month!=. & hsym3year!=. //0 changes
replace hsym3month=. if hsym3d==. & hsym3month!=. & hsym3year!=. //0 changes
replace hsym3year=. if hsym3d==. & hsym3year!=. //0 changes
count if hsym3d==. & (hsym3day!=. | hsym3month!=. | hsym3year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym3day==88|hsym3day==999|hsym3day==9999 //0
count if hsym3month==88|hsym3month==999|hsym3month==9999 //0
count if hsym3year==88|hsym3year==99|hsym3year==999 //0
** Invalid (after NotifiedDate)
count if hsym3d!=. & ambcalld!=. & hsym3d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if hsym3d!=. & atscnd!=. & hsym3d>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if hsym3d!=. & frmscnd!=. & hsym3d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if hsym3d!=. & hospd!=. & hsym3d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hsym3d!=. & edate!=. & hsym3d<edate //1  heart record 2549: checked MedData notes section re vomit date as it looks to be an error but cannot confirm so will leave as is.


** Corrections from above checks
replace flag220=hsym3d if record_id=="2549"
replace hsym3d=edate if record_id=="2549" //see above
replace flag1145=hsym3d if record_id=="2549"



** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2549"


***************
** Dizziness **
***************
** Missing
count if hsym4==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if hsym4==88|hsym4==999|hsym4==9999 //0
** Missing date
count if hsym4d==. & hsym4==1 //0
** Invalid (not 2021)
count if hsym4d!=. & year(hsym4d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hsym4d!=. & hsym4d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym4d!=. & cfadmdate!=. & hsym4d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym4d!=. & hsym4d>dlc //0
count if cfdod!=. & hsym4d!=. & hsym4d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if hsym4d!=. & dae!=. & hsym4d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if hsym4d!=. & doh!=. & hsym4d>doh & inhosp!=1 //0
** Invalid (future date)
count if hsym4d!=. & hsym4d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym4==1 & hsym4d==. & hsym4day==99 & hsym4month==99 & hsym4year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym4d==. & hsym4day!=. & hsym4month!=. & hsym4year!=. //0
replace hsym4day=. if hsym4d==. & hsym4day!=. & hsym4month!=. & hsym4year!=. //0 changes
replace hsym4month=. if hsym4d==. & hsym4month!=. & hsym4year!=. //0 changes
replace hsym4year=. if hsym4d==. & hsym4year!=. //0 changes
count if hsym4d==. & (hsym4day!=. | hsym4month!=. | hsym4year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym4day==88|hsym4day==999|hsym4day==9999 //0
count if hsym4month==88|hsym4month==999|hsym4month==9999 //0
count if hsym4year==88|hsym4year==99|hsym4year==999 //0
** Invalid (after NotifiedDate)
count if hsym4d!=. & ambcalld!=. & hsym4d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if hsym4d!=. & atscnd!=. & hsym4d>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if hsym4d!=. & frmscnd!=. & hsym4d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if hsym4d!=. & hospd!=. & hsym4d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hsym4d!=. & edate!=. & hsym4d<edate //0


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
//replace flagdate=sd_currentdate if record_id==""


*********
** LOC **
*********
** Missing
count if hsym5==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if hsym5==88|hsym5==999|hsym5==9999 //0
** Missing date
count if hsym5d==. & hsym5==1 //0
** Invalid (not 2021)
count if hsym5d!=. & year(hsym5d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hsym5d!=. & hsym5d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym5d!=. & cfadmdate!=. & hsym5d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym5d!=. & hsym5d>dlc //0
count if cfdod!=. & hsym5d!=. & hsym5d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if hsym5d!=. & dae!=. & hsym5d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if hsym5d!=. & doh!=. & hsym5d>doh & inhosp!=1 //0
** Invalid (future date)
count if hsym5d!=. & hsym5d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym5==1 & hsym5d==. & hsym5day==99 & hsym5month==99 & hsym5year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym5d==. & hsym5day!=. & hsym5month!=. & hsym5year!=. //0
replace hsym5day=. if hsym5d==. & hsym5day!=. & hsym5month!=. & hsym5year!=. //0 changes
replace hsym5month=. if hsym5d==. & hsym5month!=. & hsym5year!=. //0 changes
replace hsym5year=. if hsym5d==. & hsym5year!=. //0 changes
count if hsym5d==. & (hsym5day!=. | hsym5month!=. | hsym5year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym5day==88|hsym5day==999|hsym5day==9999 //0
count if hsym5month==88|hsym5month==999|hsym5month==9999 //0
count if hsym5year==88|hsym5year==99|hsym5year==999 //0
** Invalid (after NotifiedDate)
count if hsym5d!=. & ambcalld!=. & hsym5d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if hsym5d!=. & atscnd!=. & hsym5d>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if hsym5d!=. & frmscnd!=. & hsym5d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if hsym5d!=. & hospd!=. & hsym5d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hsym5d!=. & edate!=. & hsym5d<edate //00


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
//replace flagdate=sd_currentdate if record_id==""


******************
** Palpitations **
******************
** Missing
count if hsym6==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if hsym6==88|hsym6==999|hsym6==9999 //0
** Missing date
count if hsym6d==. & hsym6==1 //1 - correct as hsym6d=99 in CVDdb
** Invalid (not 2021)
count if hsym6d!=. & year(hsym6d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hsym6d!=. & hsym6d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym6d!=. & cfadmdate!=. & hsym6d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym6d!=. & hsym6d>dlc //0
count if cfdod!=. & hsym6d!=. & hsym6d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if hsym6d!=. & dae!=. & hsym6d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if hsym6d!=. & doh!=. & hsym6d>doh & inhosp!=1 //0
** Invalid (future date)
count if hsym6d!=. & hsym6d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym6==1 & hsym6d==. & hsym6day==99 & hsym6month==99 & hsym6year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym6d==. & hsym6day!=. & hsym6month!=. & hsym6year!=. //0
replace hsym6day=. if hsym6d==. & hsym6day!=. & hsym6month!=. & hsym6year!=. //0 changes
replace hsym6month=. if hsym6d==. & hsym6month!=. & hsym6year!=. //0 changes
replace hsym6year=. if hsym6d==. & hsym6year!=. //0 changes
count if hsym6d==. & (hsym6day!=. | hsym6month!=. | hsym6year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym6day==88|hsym6day==999|hsym6day==9999 //0
count if hsym6month==88|hsym6month==999|hsym6month==9999 //0
count if hsym6year==88|hsym6year==99|hsym6year==999 //0
** Invalid (after NotifiedDate)
count if hsym6d!=. & ambcalld!=. & hsym6d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if hsym6d!=. & atscnd!=. & hsym6d>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if hsym6d!=. & frmscnd!=. & hsym6d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if hsym6d!=. & hospd!=. & hsym6d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hsym6d!=. & edate!=. & hsym6d<edate //0


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
//replace flagdate=sd_currentdate if record_id==""


**************
** Sweating **
**************
** Missing
count if hsym7==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if hsym7==88|hsym7==999|hsym7==9999 //0
** Missing date
count if hsym7d==. & hsym7==1 //1 - correct as hsym7d=99 in CVDdb
** Invalid (not 2021)
count if hsym7d!=. & year(hsym7d)!=2021 //0
** Invalid (before DOB)
count if dob!=. & hsym7d!=. & hsym7d<dob //0
** possibly Invalid (after CFAdmDate)
count if hsym7d!=. & cfadmdate!=. & hsym7d>cfadmdate & inhosp!=1 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & hsym7d!=. & hsym7d>dlc //0
count if cfdod!=. & hsym7d!=. & hsym7d>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if hsym7d!=. & dae!=. & hsym7d>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if hsym7d!=. & doh!=. & hsym7d>doh & inhosp!=1 //0
** Invalid (future date)
count if hsym7d!=. & hsym7d>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if hsym7==1 & hsym7d==. & hsym7day==99 & hsym7month==99 & hsym7year==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hsym7d==. & hsym7day!=. & hsym7month!=. & hsym7year!=. //0
replace hsym7day=. if hsym7d==. & hsym7day!=. & hsym7month!=. & hsym7year!=. //0 changes
replace hsym7month=. if hsym7d==. & hsym7month!=. & hsym7year!=. //0 changes
replace hsym7year=. if hsym7d==. & hsym7year!=. //0 changes
count if hsym7d==. & (hsym7day!=. | hsym7month!=. | hsym7year!=.) //0
** Invalid missing code (notified date partial fields)
count if hsym7day==88|hsym7day==999|hsym7day==9999 //0
count if hsym7month==88|hsym7month==999|hsym7month==9999 //0
count if hsym7year==88|hsym7year==99|hsym7year==999 //0
** Invalid (after NotifiedDate)
count if hsym7d!=. & ambcalld!=. & hsym7d>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if hsym7d!=. & atscnd!=. & hsym7d>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if hsym7d!=. & frmscnd!=. & hsym7d>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if hsym7d!=. & hospd!=. & hsym7d>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if hsym7d!=. & edate!=. & hsym7d<edate //0


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
//replace flagdate=sd_currentdate if record_id==""


**********************
**  Other Symptoms  **
** (Heart + Stroke) **
**********************
** Missing
count if osym==. & event_complete!=0 & event_complete!=. //3 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form; stroke records 1985, 2227, 2611 do not have all fields and/or forms completed so these are corrected below - but need to use code 99999 for all of these wherein eligible=6(confirmed but not fully abstracted).
** Invalid missing code
count if osym==88|osym==999|osym==9999 //0
** Missing (other sym options=1 but other sym text blank)
***************
** Oth Sym 1 **
***************
count if osym==1 & osym1=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (osym==7|osym==99|osym==99999) & osym1!="" //0
** possibly Invalid (other symptom=one of the symptom options)
count if sd_etype==1 & osym1!="" //... - reviewed and are correct
count if sd_etype==1 & (regexm(osym1,"slurred")|regexm(osym1,"speech")|regexm(osym1,"unresponsive")|regexm(osym1,"drows")|regexm(osym1,"unilateral")|regexm(osym1,"facial")|regexm(osym1,"weak")|regexm(osym1,"swallow")) //7 - ask NS re rt upper limb weakness stroke record 3300
count if sd_etype==2 & (regexm(osym1,"chest")|regexm(osym1,"breath")|regexm(osym1,"vomit")|regexm(osym1,"dizz")|regexm(osym1,"vertigo")|regexm(osym1,"conscious")|regexm(osym1,"palpit")|regexm(osym1,"heart")|regexm(osym1,"sweat")|regexm(osym1,"diaphore")) //0
***************
** Oth Sym 2 **
***************
** Missing (other sym options=2 but other sym text blank)
count if osym==2 & osym2=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (osym==7|osym==99|osym==99999) & osym2!="" //0
** possibly Invalid (other symptom=one of the symptom options)
//count if sd_etype==1 & osym2!="" //... - reviewed and are correct
count if sd_etype==1 & (regexm(osym2,"slurred")|regexm(osym2,"speech")|regexm(osym2,"unresponsive")|regexm(osym2,"drows")|regexm(osym2,"unilateral")|regexm(osym2,"facial")|regexm(osym2,"weak")|regexm(osym2,"swallow")) //3 - correct
count if sd_etype==2 & (regexm(osym2,"chest")|regexm(osym2,"breath")|regexm(osym2,"vomit")|regexm(osym2,"dizz")|regexm(osym2,"vertigo")|regexm(osym2,"conscious")|regexm(osym2,"palpit")|regexm(osym2,"heart")|regexm(osym2,"sweat")|regexm(osym2,"diaphore")) //0
***************
** Oth Sym 3 **
***************
** Missing (other sym options=2 but other sym text blank)
count if osym==3 & osym3=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (osym==7|osym==99|osym==99999) & osym3!="" //0
** possibly Invalid (other symptom=one of the symptom options)
//count if sd_etype==1 & osym3!="" //... - reviewed and are correct
count if sd_etype==1 & (regexm(osym3,"slurred")|regexm(osym3,"speech")|regexm(osym3,"unresponsive")|regexm(osym3,"drows")|regexm(osym3,"unilateral")|regexm(osym3,"facial")|regexm(osym3,"weak")|regexm(osym3,"swallow")) //2 - correct
count if sd_etype==2 & (regexm(osym3,"chest")|regexm(osym3,"breath")|regexm(osym3,"vomit")|regexm(osym3,"dizz")|regexm(osym3,"vertigo")|regexm(osym3,"conscious")|regexm(osym3,"palpit")|regexm(osym3,"heart")|regexm(osym3,"sweat")|regexm(osym3,"diaphore")) //0
***************
** Oth Sym 4 **
***************
** Missing (other sym options=2 but other sym text blank)
count if osym==4 & osym4=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (osym==7|osym==99|osym==99999) & osym4!="" //0
** possibly Invalid (other symptom=one of the symptom options)
//count if sd_etype==1 & osym4!="" //... - reviewed and are correct
count if sd_etype==1 & (regexm(osym4,"slurred")|regexm(osym4,"speech")|regexm(osym4,"unresponsive")|regexm(osym4,"drows")|regexm(osym4,"unilateral")|regexm(osym4,"facial")|regexm(osym4,"weak")|regexm(osym4,"swallow")) //3 - correct
count if sd_etype==2 & (regexm(osym4,"chest")|regexm(osym4,"breath")|regexm(osym4,"vomit")|regexm(osym4,"dizz")|regexm(osym4,"vertigo")|regexm(osym4,"conscious")|regexm(osym4,"palpit")|regexm(osym4,"heart")|regexm(osym4,"sweat")|regexm(osym4,"diaphore")) //0
***************
** Oth Sym 5 **
***************
** Missing (other sym options=2 but other sym text blank)
count if osym==5 & osym5=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (osym==7|osym==99|osym==99999) & osym5!="" //0
** possibly Invalid (other symptom=one of the symptom options)
//count if sd_etype==1 & osym5!="" //... - reviewed and are correct
count if sd_etype==1 & (regexm(osym5,"slurred")|regexm(osym5,"speech")|regexm(osym5,"unresponsive")|regexm(osym5,"drows")|regexm(osym5,"unilateral")|regexm(osym5,"facial")|regexm(osym5,"weak")|regexm(osym5,"swallow")) //0
count if sd_etype==2 & (regexm(osym5,"chest")|regexm(osym5,"breath")|regexm(osym5,"vomit")|regexm(osym5,"dizz")|regexm(osym5,"vertigo")|regexm(osym5,"conscious")|regexm(osym5,"palpit")|regexm(osym5,"heart")|regexm(osym5,"sweat")|regexm(osym5,"diaphore")) //0
***************
** Oth Sym 6 **
***************
** Missing (other sym options=2 but other sym text blank)
count if osym==6 & osym6=="" //0
** Invalid (other sym options=ND/None but other sym text NOT=blank)
count if (osym==7|osym==99|osym==99999) & osym6!="" //0
** possibly Invalid (other symptom=one of the symptom options)
//count if sd_etype==1 & osym6!="" //... - reviewed and are correct
count if sd_etype==1 & (regexm(osym6,"slurred")|regexm(osym6,"speech")|regexm(osym6,"unresponsive")|regexm(osym6,"drows")|regexm(osym6,"unilateral")|regexm(osym6,"facial")|regexm(osym6,"weak")|regexm(osym6,"swallow")) //0
count if sd_etype==2 & (regexm(osym6,"chest")|regexm(osym6,"breath")|regexm(osym6,"vomit")|regexm(osym6,"dizz")|regexm(osym6,"vertigo")|regexm(osym6,"conscious")|regexm(osym6,"palpit")|regexm(osym6,"heart")|regexm(osym6,"sweat")|regexm(osym6,"diaphore")) //0


**************
** Oth Date **
**************
** Missing
count if osym==. & event_complete!=0 & event_complete!=. //3 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form; stroke records 1985, 2227, 2611 do not have all fields and/or forms completed so these are corrected below - but need to use code 99999 for all of these wherein eligible=6(confirmed but not fully abstracted).
** Missing date
count if osymd==. & osym==1 //7 - stroke record 1889, heart record 2256 oth date is blank in CVDdb; but others are correct as osymd=99 in CVDdb
** Invalid (not 2021)
count if osymd!=. & year(osymd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & osymd!=. & osymd<dob //0
** possibly Invalid (after CFAdmDate)
count if osymd!=. & cfadmdate!=. & osymd>cfadmdate & inhosp!=1 //1 - stroke record 3654's oth sym date from merged stroke-in-evolution 2728
** possibly Invalid (after DLC/DOD)
count if dlc!=. & osymd!=. & osymd>dlc //1 - stroke record 3654's oth sym date from merged stroke-in-evolution 2728
count if cfdod!=. & osymd!=. & osymd>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if osymd!=. & dae!=. & osymd>dae & inhosp!=1 //1 - stroke record 3654's oth sym date from merged stroke-in-evolution 2728
** possibly Invalid (after WardAdmDate)
count if osymd!=. & doh!=. & osymd>doh & inhosp!=1 //0
** Invalid (future date)
count if osymd!=. & osymd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if osym==1 & osymd==. & osymday==99 & osymmonth==99 & osymyear==9999 //0
** possibly Invalid (oth sym date not partial but partial field not blank)
count if osymd==. & osymday!=. & osymmonth!=. & osymyear!=. //1 - stroke record 1974 corrected below
replace osymday=. if osymd==. & osymday!=. & osymmonth!=. & osymyear!=. //1 change
replace osymmonth=. if osymd==. & osymmonth!=. & osymyear!=. //1 change
replace osymyear=. if osymd==. & osymyear!=. //1 change
count if osymd==. & (osymday!=. | osymmonth!=. | osymyear!=.) //0
** Invalid missing code (notified date partial fields)
count if osymday==88|osymday==999|osymday==9999 //0
count if osymmonth==88|osymmonth==999|osymmonth==9999 //0
count if osymyear==88|osymyear==99|osymyear==999 //0
** Invalid (after NotifiedDate)
count if osymd!=. & ambcalld!=. & osymd>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if osymd!=. & atscnd!=. & osymd>atscnd & inhosp!=1 //00
** Invalid (after FromSceneDate)
count if osymd!=. & frmscnd!=. & osymd>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if osymd!=. & hospd!=. & osymd>hospd & inhosp!=1 //0
** Invalid (before EventDate)
count if osymd!=. & edate!=. & osymd<edate //9 - checked MedData but cannot confirm if osymd is incorrect for stroke records 1996, 2076, 2862, 3025, 3047, 3087, 3699 or heart records 2613 + 2900


** Corrections from above checks
** Below are blank/unanswered in CVDdb for those wherein eligible=6 (confirmed but not fully abstracted)
replace ssym1=99999 if eligible==6 & sd_etype==1 & ssym1==. //see above
replace ssym2=99999 if eligible==6 & sd_etype==1 & ssym2==.
replace ssym3=99999 if eligible==6 & sd_etype==1 & ssym3==.
replace ssym4=99999 if eligible==6 & sd_etype==1 & ssym4==.
replace osym=99999 if eligible==6 & sd_etype==1 & osym==.
replace sign1=99999 if eligible==6 & sd_etype==1 & sign1==.
replace sign2=99999 if eligible==6 & sd_etype==1 & sign2==.
replace sign3=99999 if eligible==6 & sd_etype==1 & sign3==.
replace sign4=99999 if eligible==6 & sd_etype==1 & sign4==.
replace sonset=99999 if eligible==6 & sd_etype==1 & sonset==.
replace sday=99999 if eligible==6 & sd_etype==1 & sday==.
replace cardmon=99999 if eligible==6 & sd_etype==1 & cardmon==.
replace nihss=99999 if eligible==6 & sd_etype==1 & nihss==.


replace hsym1=99999 if eligible==6 & sd_etype==2 & hsym1==. //see above
replace hsym2=99999 if eligible==6 & sd_etype==2 & hsym2==.
replace hsym3=99999 if eligible==6 & sd_etype==2 & hsym3==.
replace hsym4=99999 if eligible==6 & sd_etype==2 & hsym4==.
replace hsym5=99999 if eligible==6 & sd_etype==2 & hsym5==.
replace hsym6=99999 if eligible==6 & sd_etype==2 & hsym6==.
replace hsym7=99999 if eligible==6 & sd_etype==2 & hsym7==.
replace osym=99999 if eligible==6 & sd_etype==2 & osym==.
replace timi=99999 if eligible==6 & sd_etype==2 & timi==.
replace cardiac=99999 if eligible==6 & sd_etype==2 & cardiac==.
replace cardiachosp=99999 if eligible==6 & sd_etype==2 & cardiachosp==.

replace flag269=etime if record_id=="1974"
replace etime="20:00" if record_id=="1974" //see above - time seen in MedData notes section
replace flag1194=etime if record_id=="1974"
replace osymd=d(15jan2021) if record_id=="1974" //used unk day code for this partial date


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="1974"

** Incidental correction
preserve
clear
import excel using "`datapath'\version03\2-working\MissingNRN_20230214.xlsx" , firstrow case(lower)
tostring record_id, replace
tostring elec_sd_natregno, replace
save "`datapath'\version03\2-working\missing_nrn" ,replace
restore

merge m:1 record_id using "`datapath'\version03\2-working\missing_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,144
        from master                     1,144  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------
*/
replace natregno=elec_natregno if _merge==3 //2 changes
replace flag51=sd_natregno if _merge==3
replace sd_natregno=elec_sd_natregno if _merge==3
replace flag976=sd_natregno if _merge==3
replace flag45=dob if _merge==3
replace dob=elec_dob if _merge==3
replace flag970=dob if _merge==3
replace flagdate=sd_currentdate if _merge==3
replace dd_dob=dob if record_id=="2076"
replace dd_natregno=sd_natregno if record_id=="2076"
replace cfage=cfage-1 if record_id=="2076"
drop elec_* _merge
erase "`datapath'\version03\2-working\missing_nrn.dta"


********************
** Signs + Scores **
** Heart + Stroke **
********************
************
** Sign 1 **
************
** Missing
count if sign1==. & sd_etype==1 & event_complete!=0 & event_complete!=. //1 - record 3247=99 in CVDdb according to history button.
** Invalid missing code
count if sign1==88|sign1==999|sign1==9999 //0
************
** Sign 2 **
************
** Missing
count if sign2==. & sd_etype==1 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if sign2==88|sign2==999|sign2==9999 //0
************
** Sign 3 **
************
** Missing
count if sign3==. & sd_etype==1 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if sign3==88|sign3==999|sign3==9999 //0
************
** Sign 4 **
************
** Missing
count if sign4==. & sd_etype==1 & event_complete!=0 & event_complete!=. //1 - record 3247=99 in CVDdb according to history button.
** Invalid missing code
count if sign4==88|sign4==999|sign4==9999 //0
**********************
**   Sudden Onset   **
** neuro impairment **
**********************
** Missing
count if sonset==. & sd_etype==1 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if sonset==88|sonset==999|sonset==9999 //0
****************
** Symp/death **
**  in 24hrs  **
****************
** Missing
count if sday==. & sd_etype==1 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if sday==88|sday==999|sday==9999 //0

********************
** Swallow Screen **
**     Date       **
********************
** Missing date
count if swalldate==. & sign4==1 //0
** Invalid (not 2021)
count if swalldate!=. & year(swalldate)!=2021 //2 - both records have edate=dec2021.
** Invalid (before DOB)
count if dob!=. & swalldate!=. & swalldate<dob //0
** possibly Invalid (before CFAdmDate)
count if swalldate!=. & cfadmdate!=. & swalldate<cfadmdate //5 - stroke records 1916, 2178, 2879 (no comment by DA but will assume) swallow done at FMC; stroke record 2543 cfadmdate changed by DA on 14feb2023 according to history button of CVDdb so corrected below; record 2910 also corrected below.
** possibly Invalid (after DLC/DOD)
count if dlc!=. & swalldate!=. & swalldate>dlc //1 - stroke record 3136's oth sym date from merged stroke-in-evolution 4331
count if cfdod!=. & swalldate!=. & swalldate>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if swalldate!=. & dae!=. & swalldate<dae //4 - same records as above
** possibly Invalid (after WardAdmDate)
count if swalldate!=. & doh!=. & swalldate>doh //2 - stroke record 3136's oth sym date from merged stroke-in-evolution 4331; record 3438 is an in-hosp event
** Invalid (future date)
count if swalldate!=. & swalldate>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if sign4==1 & swalldate==. & swalldday==99 & swalldmonth==99 & swalldyear==9999 //0
** possibly Invalid (oth sym date not partial but partial field not blank)
count if swalldate==. & swalldday!=. & swalldmonth!=. & swalldyear!=. //0
replace swalldday=. if swalldate==. & swalldday!=. & swalldmonth!=. & swalldyear!=. //0 changes
replace swalldmonth=. if swalldate==. & swalldmonth!=. & swalldyear!=. //0 changes
replace swalldyear=. if swalldate==. & swalldyear!=. //0 changes
count if swalldate==. & (swalldday!=. | swalldmonth!=. | swalldyear!=.) //0
** Invalid missing code (notified date partial fields)
count if swalldday==88|swalldday==999|swalldday==9999 //0
count if swalldmonth==88|swalldmonth==999|swalldmonth==9999 //0
count if swalldyear==88|swalldyear==99|swalldyear==999 //0
** Invalid (before NotifiedDate)
count if swalldate!=. & ambcalld!=. & swalldate<ambcalld //2 - same records as above
** Invalid (before AtSceneDate)
count if swalldate!=. & atscnd!=. & swalldate<atscnd //2 - same records as above
** Invalid (before FromSceneDate)
count if swalldate!=. & frmscnd!=. & swalldate<frmscnd //2 - same records as above
** Invalid (before AtHospitalDate)
count if swalldate!=. & hospd!=. & swalldate<hospd //2 - same records as above
** Invalid (before EventDate)
count if swalldate!=. & edate!=. & swalldate<edate //0

************************
** Cardiac Monitoring **
************************
** Missing
count if cardmon==. & sd_etype==1 & event_complete!=0 & event_complete!=. //1 - record 3247=99 in CVDdb according to history button.
** Invalid missing code
count if cardmon==88|cardmon==999|cardmon==9999 //0

********************
** NIH risk score **
********************
** Missing
count if nihss==. & sd_etype==1 & event_complete!=0 & event_complete!=. //1 - record 3247=99 in CVDdb according to history button.
** Invalid missing code
count if nihss==88|nihss==999|nihss==9999 //0

*********************
** TIMI risk score **
*********************
** Missing
count if timi==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if timi==88|timi==999|timi==9999 //0


** Corrections from above checks
destring flag250 ,replace
destring flag1175 ,replace
format flag250 flag1175 %dM_d,_CY


** Below are code=99 in CVDdb according to history button
replace sign1=99 if record_id=="3247"
replace sign4=99 if record_id=="3247"
replace etime="99" if record_id=="3247"

replace cfadmdate=cfadmdate-4 if record_id=="2543"

replace flag250=swalldate if record_id=="2910"
replace swalldate=dae if record_id=="2910"
replace flag1175=swalldate if record_id=="2910"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2910"


***********************
** Diagnosis + Event **
**  Heart + Stroke   **
***********************
*************
** Dx Type **
*************
** Missing
count if stype==. & sd_etype==1 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if stype==88|stype==999|stype==9999 //0
** Missing
count if htype==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if htype==88|htype==999|htype==9999 //0
*************
** Dx Made **
*************
** Missing
count if dxtype==. & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if dxtype==88|dxtype==999|dxtype==9999 //0
** possibly Invalid for stroke (dx made=clinical; dx type NOT=unclassified; dx tests were done)
count if sd_etype==1 & dxtype==1 & stype!=4 & dct>1 & dmri>1 & dcerangio>1 & dcarangio>1 & dcarus>1 & odie>1 & odie!=4 //3 - 1890, 2982, 2800 CODs have finaldx as pt died within few mins of being in A&E and no PM done so leave as is; ask NS to review all of these.
** possibly Invalid for stroke (dx made=clinical; dx tests were done)
count if sd_etype==1 & dxtype==1 & stype!=4 & (dct==1|dmri==1|dcerangio==1|dcarangio==1|dcarus==1|odie<4) //2 - none of the dx tests showed evidence of infarct/bleed.
** possibly Invalid for stroke (dx=unclassified; not for review)
count if sd_etype==1 & stype==4 & review<2 //1 - record 4243 ask NS to review
** possibly Invalid for heart (dx made=clinical; dx tests were done)
count if sd_etype==2 & dxtype==1 & (decg==1|decho==1|dctcorang==1|dstress==1|odie<4|ckmbdone==1|astdone==1|tropdone==1) //3 - none of the dx tests showed evidence of MI
***********************
** Definite/Possible **
***********************
** Missing
count if dstroke==. & sd_etype==1 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if dstroke==88|dstroke==999|dstroke==9999 //0
** possibly Invalid (stroke=definite; finaldx/CODs=CVA vs Todd's paresis or CVA vs TIA)
count if dstroke==1 & (regexm(finaldx,"Todd")|regexm(finaldx,"TIA")|regexm(cfcods,"Todd")|regexm(cfcods,"TIA")) //7 - 5 reviewed=eligible; 2 not reviewed but 1 is correct; record 2815 for NS to review.
** possibly Invalid (stroke=possible; not flagged for review)
count if dstroke==2 & review!=2 & review!=4 //2 - record 2800 already for NS to review; other record corrected below
** possibly Invalid (finaldx/CODs=intracranial bleed; not flagged for review)
count if review!=2 & review!=4 & (regexm(finaldx,"intracranial")|regexm(finaldx,"intra-cranial")|regexm(finaldx,"intra cranial")|regexm(cfcods,"intracranial")|regexm(cfcods,"intra-cranial")|regexm(cfcods,"intra cranial")) //8 - all correct
************
** Review **
************
** Missing
count if review==. & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if review==88|review==999|review==9999 //0
** possibly Invalid (case status=pending review; not flagged for review)
count if cstatus==3 & review<2 //0
** Missing
count if review!=. & review!=99999 & review>1 & reviewreason=="" //0
** Missing
count if review!=. & review!=99999 & review>2 & reviewer___1==0 & reviewer___2==0 & reviewer___3==0  //0
** Missing date
count if reviewd==. & review!=. & review!=99999 & review>2 //0
** Invalid (future date)
count if reviewd!=. & reviewd>sd_currentdate //0



** Corrections from above checks
destring flag260 ,replace
destring flag1185 ,replace

replace flag260=dstroke if record_id=="3741"
replace dstroke=1 if record_id=="3741"
replace flag1185=dstroke if record_id=="3741"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="3741"


****************
** Event Date **
****************
** Missing date
count if edate==. //1 - stroke record 3121 which is to be deleted below.
** Invalid (not 2021)
count if edate!=. & year(edate)!=2021 //0
** Invalid (before DOB)
count if dob!=. & edate!=. & edate<dob //0
** possibly Invalid (after CFAdmDate)
count if edate!=. & cfadmdate!=. & edate>cfadmdate & inhosp!=1 //1 - corrected below; Checked MedData notes/encounters + initialdx for heart record 3001
** possibly Invalid (after DLC/DOD)
count if dlc!=. & edate!=. & edate>dlc //0
count if cfdod!=. & edate!=. & edate>cfdod //0
** possibly Invalid (after A&EAdmDate)
count if edate!=. & dae!=. & edate>dae & inhosp!=1 //0
** possibly Invalid (after WardAdmDate)
count if edate!=. & doh!=. & edate>doh & inhosp!=1 //0
** Invalid (future date)
count if edate!=. & edate>sd_currentdate //0
** Invalid (after NotifiedDate)
count if edate!=. & ambcalld!=. & edate>ambcalld & inhosp!=1 //0
** Invalid (after AtSceneDate)
count if edate!=. & atscnd!=. & edate>atscnd & inhosp!=1 //0
** Invalid (after FromSceneDate)
count if edate!=. & frmscnd!=. & edate>frmscnd & inhosp!=1 //0
** Invalid (after AtHospitalDate)
count if edate!=. & hospd!=. & edate>hospd & inhosp!=1 //0
** Invalid (after AbsDate)
count if edate!=. & adoa!=. & edate>adoa //0
** Missing time
count if etime=="" & sd_casetype==1 //1 - stroke record 3121 which is to be deleted below.
** Missing time for heart
count if hsym1t!="" & hsym1t!="99" & sd_casetype==1 & sd_etype==2 & (etime==""|etime=="99"|etime=="88") //14 - 10 correct; 4 corrected below
** Invalid (time format)
count if etime!="" & etime!="88" & etime!="99" & (length(etime)<5|length(etime)>5) //0
count if etime!="" & etime!="88" & etime!="99" & etime!="99999" & !strmatch(strupper(etime), "*:*") //0
generate byte non_numeric_etime = indexnot(etime, "0123456789.-:")
count if non_numeric_etime //0
** Invalid missing code
count if etime=="999"|etime=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if etime=="88" & etimeampm==. //0
** Invalid (event time after notified time)
count if etime!="" & etime!="99" & etime!="88" & ambcallt!="" & ambcallt!="99" & edate==ambcalld & etime>ambcallt //10 - using method from previously incorrect ones like these; corrected below
replace comments="JC 16feb2023: Note the irregularity with ambulance times and event time will remain as cannot confirm event time in MedData or any other external source at this point in data handling." if record_id=="1934"|record_id=="2075"|record_id=="2555"|record_id=="3136"|record_id=="3510"|record_id=="4103"
** Invalid (event time after time at scene)
count if etime!="" & etime!="99" & etime!="88" & atscnt!="" & atscnt!="99" & edate==atscnd & etime>atscnt //5 - same records as above
** Invalid (event time after time from scene)
count if etime!="" & etime!="99" & etime!="88" & frmscnt!="" & frmscnt!="99" & edate==frmscnd & etime>frmscnt //2 - same records as above
** Invalid (event time after time at hospital)
count if etime!="" & etime!="99" & etime!="88" & hospt!="" & hospt!="99" & edate==hospd & etime>hospt //1 - same record as above
** Create event date YEAR variable
drop edateyr
gen edateyr=year(edate)
count if edateyr==. //1 - stroke record 3121 which is to be deleted below
** Create age by event variable
drop age
gen age2=(edate-dob)/365.25
gen age=int(age2)
label var age "Age at Event"
drop age2



** Corrections from above checks
replace flag210=edate if record_id=="3001"|record_id=="2719"
replace edate=edate-7 if record_id=="3001" //see above
replace edate=hsym1d if record_id=="2719" //see above
replace edate=edate-1 if record_id=="4104" //see above
replace flag1135=edate if record_id=="3001"|record_id=="2719"


replace flag269=etime if record_id=="2477"|record_id=="2719"|record_id=="3031"|record_id=="3220"|record_id=="2819"
replace etime=hsym1t if record_id=="2477"|record_id=="2719"|record_id=="3031"|record_id=="3220" //see above
replace etime=subinstr(etime,"12","00",.) if record_id=="2819" //see above
replace flag1194=etime if record_id=="2477"|record_id=="2719"|record_id=="3031"|record_id=="3220"|record_id=="2819"

replace etimeampm=. if record_id=="2477"


replace flag133=ambcallt if record_id=="2794"
replace ambcallt=subinstr(ambcallt,"21","25",.) if record_id=="2794"
replace flag1058=ambcallt if record_id=="2794"


replace flag269=etime if record_id=="2794"
replace etime=ambcallt if record_id=="2794" //see above
replace flag1194=etime if record_id=="2794"


replace flag194=ssym1d if record_id=="4104"
replace ssym1d=edate if record_id=="4104" //see above
replace flag1119=ssym1d if record_id=="4104"

replace flag202=ssym3d if record_id=="4104"
replace ssym3d=edate if record_id=="4104" //see above
replace flag1127=ssym3d if record_id=="4104"

replace flag240=osymd if record_id=="4104"
replace osymd=edate if record_id=="4104" //see above
replace flag1165=osymd if record_id=="4104"


** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="3001"|record_id=="2477"|record_id=="2719"|record_id=="3031"|record_id=="3220"|record_id=="2794"|record_id=="2819"|record_id=="4104"


*****************
** In-hospital **
*****************
** Missing
count if inhosp==. & (edate>dae|edate>doh) & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if inhosp==88|inhosp==99|inhosp==999|inhosp==9999 //0
** possibly Invalid (inhosp=Yes but edate before adm date)
count if inhosp==1 & edate!=. & cfadmdate!=. & dae!=. & doh!=. & (edate<cfadmdate|edate<dae) //0
** possibly Invalid (inhosp=No but edate after adm date)
count if inhosp!=1 & edate!=. & cfadmdate!=. & dae!=. & doh!=. & (edate>cfadmdate|edate>dae|edate>doh) //0


*************************
** Cardiac Arrest Info **
*************************
** Missing
count if cardiac==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if cardiac==88|cardiac==999|cardiac==9999 //0
** possibly Invalid (edate on/after adm date; cardiac prior to hosp=Yes)
count if cardiac==1 & sd_etype==2 & edate!=. & cfadmdate!=. & dae!=. & doh!=. & (edate==cfadmdate|edate==dae|edate==doh) & (edate>cfadmdate|edate>dae|edate>doh) //0
** Missing
count if cardiachosp==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if cardiachosp==88|cardiachosp==999|cardiachosp==9999 //0
** possibly Invalid (edate before adm date; cardiac during hosp=Yes)
count if cardiachosp==1 & sd_etype==2 & edate!=. & cfadmdate!=. & dae!=. & doh!=. & (edate<cfadmdate|edate<dae|edate<doh) //8 - all correct except one query for NS record 2902.
** Missing
count if cardiac==1 & resus==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if resus==88|resus==999|resus==9999 //0
** Missing
count if resus==1 & sudd==. & sd_etype==2 & event_complete!=0 & event_complete!=. //0
** Invalid missing code
count if sudd==88|sudd==999|sudd==9999 //0
** Invalid (survive resus=No; slc/vstatus=Alive)
count if sudd==2 & (slc==1|vstatus==1) //0
** Invalid (survive resus=Yes; slc/vstatus=Deceased)
count if sudd!=2 & sudd!=. & sudd!=99 & (slc==2|vstatus==2) //0



/*
** JC 16feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile (so added the code for that to this dofile and all the others preceding it with corrections).

** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flagdate flag45 flag970 flag267 flag1192 flag202 flag1127 flag206 flag1131 flag210 flag1135 flag216 flag1141 flag220 flag1145 flag224 flag1149 flag232 flag1157 flag236 flag1161 flag250 flag1175 flag194 flag1119 flag240 flag1165 flag125 flag1050 flag129 flag1054 flag150 flag1075 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag45 flag51 flag74 flag129 flag133 flag135 flag140 flag147 flag150 flag154 flag187 flag188 flag194 flag202 flag206 flag210 flag216 flag220 flag224 flag232 flag236 flag240 flag250 flag260 flag267 flag268 flag269 if ///
		(flag45!=. | flag51!="" | flag74!=. | flag129!=. | flag133!="" | flag135!=. | flag140!="" | flag147!="" | flag150!=. | flag154!="" | flag187!=. | flag188!="" | flag194!=. | flag202!=. | flag206!=. | flag210!=. | flag216!=. | flag220!=. | flag224!=. | flag232!=. | flag236!=. | flag240!=. | flag250!=. | flag260!=. | flag267!=. | flag268!=. | flag269!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_EVE2_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag970 flag976 flag999 flag1054 flag1058 flag1060 flag1065 flag1072 flag1075 flag1079 flag1112 flag1113 flag1119 flag1127 flag1131 flag1135 flag1141 flag1145 flag1149 flag1157 flag1161 flag1165 flag1175 flag1185 flag1192 flag1193 flag1194 if ///
		 (flag970!=. | flag976!="" | flag999!=. | flag1054!=. | flag1058!="" | flag1060!=. | flag1065!="" | flag1072!="" | flag1075!=. | flag1079!="" | flag1112!=. | flag1113!="" | flag1119!=. | flag1127!=. | flag1131!=. | flag1135!=. | flag1141!=. | flag1145!=. | flag1149!=. | flag1157!=. | flag1161!=. | flag1165!=. | flag1175!=. | flag1185!=. | flag1192!=. | flag1193!=. | flag1194!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_EVE2_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/

** Populate date (& time: hospt) variables for atscene, frmscene and sameadm in prep for analysis
replace hospd=dae if sameadm==1 & hospd==. //86 changes
replace atscnd=hospd if atscene==1 & atscnd==. //375 changes
replace frmscnd=atscnd if frmscene==1 & frmscnd==. //376 changes
count if atscene==1 & atscnd==. //0
count if frmscene==1 & frmscnd==. //0
count if sameadm==1 & hospd==. //0


** Create datetime variables in prep for analysis (prepend with 'sd_') - only for variables wherein both date and time are not missing
** FMC
drop sd_fmcdatetime
gen fmcdate_text = string(fmcdate, "%td")
gen fmcdatetime2 = fmcdate_text+" "+fmctime if fmcdate!=. & fmctime!="" & fmctime!="88" & fmctime!="99"
gen double sd_fmcdatetime = clock(fmcdatetime2,"DMYhm") if fmcdatetime2!=""
format sd_fmcdatetime %tc
label var sd_fmcdatetime "DateTime of FIRST MEDICAL CONTACT"
** A&E admission
drop sd_daetae
gen dae_text = string(dae, "%td")
gen daetae2 = dae_text+" "+tae if dae!=. & tae!="" & tae!="88" & tae!="99"
gen double sd_daetae = clock(daetae2,"DMYhm") if daetae2!=""
format sd_daetae %tc
label var sd_daetae "DateTime Admitted to A&E"
** A&E discharge
drop sd_daetaedis
gen daedis_text = string(daedis, "%td")
gen daetaedis2 = daedis_text+" "+taedis if daedis!=. & taedis!="" & taedis!="88" & taedis!="99"
gen double sd_daetaedis = clock(daetaedis2,"DMYhm") if daetaedis2!=""
format sd_daetaedis %tc
label var sd_daetaedis "DateTime Discharged from A&E"
** Admission (Ward)
drop sd_dohtoh
gen doh_text = string(doh, "%td")
gen dohtoh2 = doh_text+" "+toh if doh!=. & toh!="" & toh!="88" & toh!="99"
gen double sd_dohtoh = clock(dohtoh2,"DMYhm") if dohtoh2!=""
format sd_dohtoh %tc
label var sd_dohtoh "DateTime Admitted to Ward"
** Notified (Ambulance)
drop sd_ambcalldt
gen ambcalld_text = string(ambcalld, "%td")
gen ambcalldt2 = ambcalld_text+" "+ambcallt if ambcalld!=. & ambcallt!="" & ambcallt!="88" & ambcallt!="99"
gen double sd_ambcalldt = clock(ambcalldt2,"DMYhm") if ambcalldt2!=""
format sd_ambcalldt %tc
label var sd_ambcalldt "DateTime Ambulance NOTIFIED"
** At Scene (Ambulance)
drop sd_atscndt
gen atscnd_text = string(atscnd, "%td")
gen atscndt2 = atscnd_text+" "+atscnt if atscnd!=. & atscnt!="" & atscnt!="88" & atscnt!="99"
gen double sd_atscndt = clock(atscndt2,"DMYhm") if atscndt2!=""
format sd_atscndt %tc
label var sd_atscndt "DateTime Ambulance AT SCENE"
** From Scene (Ambulance)
drop sd_frmscndt
gen frmscnd_text = string(frmscnd, "%td")
gen frmscndt2 = frmscnd_text+" "+frmscnt if frmscnd!=. & frmscnt!="" & frmscnt!="88" & frmscnt!="99"
gen double sd_frmscndt = clock(frmscndt2,"DMYhm") if frmscndt2!=""
format sd_frmscndt %tc
label var sd_frmscndt "DateTime Ambulance FROM SCENE"
** At Hospital (Ambulance)
drop sd_hospdt
gen hospd_text = string(hospd, "%td")
gen hospdt2 = hospd_text+" "+hospt if hospd!=. & hospt!="" & hospt!="88" & hospt!="99"
gen double sd_hospdt = clock(hospdt2,"DMYhm") if hospdt2!=""
format sd_hospdt %tc
label var sd_hospdt "DateTime Ambulance AT HOSPITAL"
** Chest Pain
gen hsym1d_text = string(hsym1d, "%td")
gen hsym1dt2 = hsym1d_text+" "+hsym1t if hsym1d!=. & hsym1t!="" & hsym1t!="88" & hsym1t!="99"
gen double sd_hsym1dt = clock(hsym1dt2,"DMYhm") if hsym1dt2!=""
format sd_hsym1dt %tc
label var sd_hsym1dt "DateTime of Chest Pain"
** Event
gen edate_text = string(edate, "%td")
gen eventdt2 = edate_text+" "+etime if edate!=. & etime!="" & etime!="88" & etime!="99"
gen double sd_eventdt = clock(eventdt2,"DMYhm") if eventdt2!=""
format sd_eventdt %tc
label var sd_eventdt "DateTime of Event"


** Remove 2022 cases + unnecessary variables from above 
drop if record_id=="3121" //1 deleted

drop flagdate sd_currentdate fu1date edatemon edatemondash edateetime daetae ambcalldt onsetevetoae onsetambtoae fu1done

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_eve" ,replace