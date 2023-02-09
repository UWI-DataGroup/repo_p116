** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3g_clean event_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-FEB-2023
    // 	date last modified      09-FEB-2023
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
replace dxtype=99 if eligible==6 & dxtype==. & record_id!="3121" //42 changes
replace flag1184=dxtype if eligible==6 & dxtype!=. & record_id!="3121" & record_id!="2163" & record_id!="2227" //42 changes

replace flag260=dstroke if eligible==6 & dstroke==. & sd_etype==1 & record_id!="3121" //27
replace dstroke=1 if eligible==6 & dstroke==. & sd_etype==1 & record_id!="3121" //27 changes
replace flag1185=dstroke if eligible==6 & dstroke!=. & sd_etype==1 & record_id!="3121" & record_id!="2163" & record_id!="2227" //27 changes

replace flag261=review if eligible==6 & review==. //42
replace review=1 if eligible==6 & review==. //42 changes
replace flag1186=review if eligible==6 & review!=. & record_id!="3121" & record_id!="2163" & record_id!="2227" //42 changes
//JC 09feb2023: I added a note in the Closing Off SOP which variables the DAs should complete (see BNR Ops Manual --> Database + Data Entry Protocols --> Database Protocol --> Closing-Off Process) so for 2022 closing off and onwards this will be done.

replace flag267=edate if eligible==6 & edate==. & record_id!="3121" //25
replace edate=cfadmdate if eligible==6 & edate==. & record_id!="3121" //see above
replace flag1192=edate if (record_id=="1876"|record_id=="1964"|record_id=="2155"|record_id=="2323"|record_id=="2331"|record_id=="2590"|record_id=="2666"|record_id=="3082"|record_id=="3104"|record_id=="3108"|record_id=="3173"|record_id=="3440"|record_id=="3551"|record_id=="3663"|record_id=="3723"|record_id=="3730"|record_id=="4112"|record_id=="4335"|record_id=="4336"|record_id=="4348"|record_id=="4361"|record_id=="4404"|record_id=="5495"|record_id=="5496"|record_id=="5497") & record_id!="3121" //25 changes

replace flag269=etime if eligible==6 & etime!="99" & etime=="" & record_id!="3121" //26
replace etime="99" if eligible==6 & etime!="99" & etime=="" & record_id!="3121" //see above
replace flag1194=etime if (record_id=="1876"|record_id=="1964"|record_id=="2155"|record_id=="2323"|record_id=="2331"|record_id=="2590"|record_id=="2666"|record_id=="2830"|record_id=="3082"|record_id=="3104"|record_id=="3108"|record_id=="3173"|record_id=="3440"|record_id=="3551"|record_id=="3663"|record_id=="3723"|record_id=="3730"|record_id=="4112"|record_id=="4335"|record_id=="4336"|record_id=="4348"|record_id=="4361"|record_id=="4404"|record_id=="5495"|record_id=="5496"|record_id=="5497") & record_id!="3121" //26 changes


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

gen flagdate=sd_currentdate if eligible==6 & record_id!="2163" & record_id!="2227"

** JC 09feb2023: This was an incidental correction I found yesterday but forgot to add it to PTM corrections list
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
		(flag45!=. | flag51!=. | flag257!=. | flag258!=. | flag259!=. | flag260!=. | flag261!=. | flag262!="" | flag265!=. | flag266!=. | flag267!=. | flag269!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_EVE1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag970 flag976 flag1182 flag1183 flag1184 flag1185 flag1186 flag1187 flag1190 flag1191 flag1192 flag1194 if ///
		 (flag970!=. | flag976!=. | flag1182!=. | flag1183!=. | flag1184!=. | flag1185!=. | flag1186!=. | flag1187!="" | flag1190!=. | flag1191!=. | flag1192!=. | flag1194!="") & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_EVE1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore

** In order to split up the excel lists for this form so they are not too large, remove the flagdate once the above list has been created
drop sd_currentdate flagdate

STOP
** Symptoms (Stroke) **

********************
** Slurred Speech **
********************
** Missing
count if ssym1==. & sd_etype==1 & event_complete!=0 & event_complete!=. //5 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid missing code
count if ssym1==88|ssym1==999|ssym1==9999 //0


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
destring flag240 ,replace
destring flag1165 ,replace
format flag240 flag1165 %dM_d,_CY
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

replace flag176=ssym1 if record_id=="1910"
replace ssym1=99 if record_id=="1910" //see above
replace flag1101=ssym1 if record_id=="1910"

replace flag177=ssym2 if record_id=="1910"
replace ssym2=99 if record_id=="1910" //see above
replace flag1102=ssym2 if record_id=="1910"

replace flag178=ssym3 if record_id=="1910"
replace ssym3=99 if record_id=="1910" //see above
replace flag1103=ssym3 if record_id=="1910"

replace flag179=ssym4 if record_id=="1910"
replace ssym4=99 if record_id=="1910" //see above
replace flag1104=ssym4 if record_id=="1910"

replace flag187=osym if record_id=="1910"
replace osym=1 if record_id=="1910" //see above
replace flag1112=osym if record_id=="1910"

replace flag188=osym1 if record_id=="1910"
replace osym1="HEADACHE" if record_id=="1910" //see above
replace flag1113=osym1 if record_id=="1910"

replace flag240=osymd if record_id=="1910"
replace osymd=edate if record_id=="1910" //see above
replace flag1165=osymd if record_id=="1910"

replace flag244=sign1 if record_id=="1910"
replace sign1=99 if record_id=="1910" //see above
replace flag1169=sign1 if record_id=="1910"

replace flag245=sign2 if record_id=="1910"
replace sign2=99 if record_id=="1910" //see above
replace flag1170=sign2 if record_id=="1910"

replace flag246=sign3 if record_id=="1910"
replace sign3=99 if record_id=="1910" //see above
replace flag1171=sign3 if record_id=="1910"

replace flag247=sign4 if record_id=="1910"
replace sign4=99 if record_id=="1910" //see above
replace flag1172=sign4 if record_id=="1910"

replace flag248=sonset if record_id=="1910"
replace sonset=99 if record_id=="1910" //see above
replace flag1173=sonset if record_id=="1910"

replace flag249=sday if record_id=="1910"
replace sday=99 if record_id=="1910" //see above
replace flag1174=sday if record_id=="1910"

replace flag254=cardmon if record_id=="1910"
replace cardmon=99 if record_id=="1910" //see above
replace flag1179=cardmon if record_id=="1910"

replace flag255=nihss if record_id=="1910"
replace nihss=99 if record_id=="1910" //see above
replace flag1180=nihss if record_id=="1910"
//stroke record 1910 was missing all the symptoms + signs info although all forms were completed - used symptom from initial dx on CF form



** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

gen flagdate=sd_currentdate if record_id==""|record_id==""
STOP
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

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
gen flagdate=sd_currentdate if record_id=="3963"|record_id=="2791"|record_id=="2830"


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

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2351"|record_id=="2211"|record_id=="4289"

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
replace flag1049=dohsame if flag124!=. //7 changes

replace flag125=doh if record_id=="3757"
replace doh=doh-212 if record_id=="3757" //see above
replace flag1050=doh if record_id=="3757"

replace flag125=doh if record_id=="1907"
replace doh=doh-90 if record_id=="1907" //see above
replace flag1050=doh if record_id=="1907"

replace flag125=doh if record_id=="3021"
replace doh=doh-31 if record_id=="3021" //see above
replace flag1050=doh if record_id=="3021"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if flag124!=.|record_id=="3757"|record_id=="1907"|record_id=="3021"

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
count if ambcalld==. & arrivalmode==1 //8 - checked CVDdb and these have notified date=99 but 4 corrected below; 4 are correct - heart record 3758 missing ambulance sheet in notes.
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
** Invalid (notified time after time at scene)
count if ambcallt!="" & ambcallt!="99" & atscnt!="" & ambcallt>atscnt //2 - 1 is correct; stroke record 2311 corrected below
** Invalid (notified time after time from scene)
count if ambcallt!="" & ambcallt!="99" & frmscnt!="" & ambcallt>frmscnt //4 - all correct
** Invalid (notified time after time at hospital)
count if ambcallt!="" & ambcallt!="99" & hospt!="" & ambcallt>hospt //7 - all correct


** Corrections from above checks
destring flag129 ,replace
destring flag1054 ,replace
destring flag150 ,replace
destring flag1075 ,replace
format flag129 flag1054 flag150 flag1075 %dM_d,_CY

replace flag129=ambcalld if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"
replace ambcalld=dae if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099" //see above
replace flag1054=ambcalld if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"

replace flag150=hospd if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"
replace hospd=dae if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099" //see above
replace flag1075=hospd if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"

replace flag117=dae if record_id=="1831"
replace dae=dae+10 if record_id=="1831" //see above
replace flag1042=dae if record_id=="1831"

replace flag118=tae if record_id=="1831"
replace flag154=hospt if record_id=="1831"
//ssc install swapval
swapval tae hospt if record_id=="1831" //see above
replace flag1043=tae if record_id=="1831"
replace flag1079=hospt if record_id=="1831"

replace flag133=ambcallt if record_id=="2311"
replace flag140=atscnt if record_id=="2311"
//ssc install swapval
swapval ambcallt atscnt if record_id=="2311" //see above
replace flag1058=ambcallt if record_id=="2311"
replace flag1065=atscnt if record_id=="2311"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2356"|record_id=="3103"|record_id=="3240"|record_id=="3335"|record_id=="1957"|record_id=="2053"|record_id=="2180"|record_id=="2794"|record_id=="3099"|record_id=="1831"|record_id=="2311"

**************************
** At Scene Date & Time **
**************************
** Missing date
count if atscnd==. & arrivalmode==1 & atscene!=1 //3 - checked CVDdb and these have atscene date=99 as ambulance sheet missing from notes so leave as is.
** Missing invalid codes
count if atscene==88|atscene==999|atscene==9999 //0
** Invalid (not 2021)
count if atscnd!=. & year(atscnd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & atscnd!=. & atscnd<dob //0
** Invalid (after CFAdmDate)
count if atscnd!=. & cfadmdate!=. & atscnd>cfadmdate //0
** Invalid (after DLC/DOD)
count if dlc!=. & atscnd!=. & atscnd>dlc //0
count if cfdod!=. & atscnd!=. & atscnd>cfdod //0
** Invalid (after A&EAdmDate)
count if atscnd!=. & dae!=. & atscnd>dae //0
** Invalid (after WardAdmDate)
count if atscnd!=. & doh!=. & atscnd>doh //0
** Invalid (future date)
count if atscnd!=. & atscnd>sd_currentdate //0
** Invalid (notified date partial missing codes for all)
count if arrivalmode==1 & atscnd==. & atscnday==99 & atscnmonth==99 & atscnyear==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if atscnd==. & atscnday!=. & atscnmonth!=. & atscnyear!=. //0
replace atscnday=. if atscnd==. & atscnday!=. & atscnmonth!=. & atscnyear!=. //0 changes
replace atscnmonth=. if atscnd==. & atscnmonth!=. & atscnyear!=. //0 changes
replace atscnyear=. if atscnd==. & atscnyear!=. //0 changes
count if atscnd==. & (atscnday!=. | atscnmonth!=. | atscnyear!=.) //0
** Invalid missing code (notified date partial fields)
count if atscnday==88|atscnday==999|atscnday==9999 //0
count if atscnmonth==88|atscnmonth==999|atscnmonth==9999 //0
count if atscnyear==88|atscnyear==99|atscnyear==999 //0
** Invalid (before NotifiedDate)
count if atscnd!=. & ambcalld!=. & atscnd<ambcalld //0
** Invalid (after FromSceneDate)
count if atscnd!=. & frmscnd!=. & atscnd>frmscnd //0
** Invalid (after AtHospitalDate)
count if atscnd!=. & hospd!=. & atscnd>hospd //0
** Missing time
count if atscnt=="" & arrivalmode==1 //3 - ambulance sheet missing from notes; leave as is.
** Invalid (time format)
count if atscnt!="" & atscnt!="88" & atscnt!="99" & (length(atscnt)<5|length(atscnt)>5) //0
count if atscnt!="" & atscnt!="88" & atscnt!="99" & !strmatch(strupper(atscnt), "*:*") //0
generate byte non_numeric_atscnt = indexnot(atscnt, "0123456789.-:")
count if non_numeric_atscnt //0
** Invalid missing code
count if atscnt=="999"|atscnt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if atscnt=="88" & atscntampm==. //0
** Invalid (atscene time before notified time)
count if atscnt!="" & atscnt!="99" & ambcallt!="" & ambcallt!="99" & atscnt<ambcallt //1 - correct
** Invalid (atscene time after time from scene)
count if atscnt!="" & atscnt!="99" & frmscnt!="" & frmscnt!="99" & atscnt>frmscnt //3 - all correct
** Invalid (atscene time after time at hospital)
count if atscnt!="" & atscnt!="99" & hospt!="" & hospt!="99" & atscnt>hospt //6 - all correct

****************************
** From Scene Date & Time **
****************************
** Missing date
count if frmscnd==. & arrivalmode==1 & frmscene!=1 //3 - checked CVDdb and these have fromscene date=99 as ambulance sheet missing from notes so leave as is.
** Missing invalid codes
count if frmscene==88|frmscene==999|frmscene==9999 //0
** Invalid (not 2021)
count if frmscnd!=. & year(frmscnd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & frmscnd!=. & frmscnd<dob //0
** Invalid (after CFAdmDate)
count if frmscnd!=. & cfadmdate!=. & frmscnd>cfadmdate //0
** Invalid (after DLC/DOD)
count if dlc!=. & frmscnd!=. & frmscnd>dlc //0
count if cfdod!=. & frmscnd!=. & frmscnd>cfdod //0
** Invalid (after A&EAdmDate)
count if frmscnd!=. & dae!=. & frmscnd>dae //0
** Invalid (after WardAdmDate)
count if frmscnd!=. & doh!=. & frmscnd>doh //0
** Invalid (future date)
count if frmscnd!=. & frmscnd>sd_currentdate //0
** Invalid (notified date partial missing codes for all)
count if arrivalmode==1 & frmscnd==. & frmscnday==99 & frmscnmonth==99 & frmscnyear==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if frmscnd==. & frmscnday!=. & frmscnmonth!=. & frmscnyear!=. //0
replace frmscnday=. if frmscnd==. & frmscnday!=. & frmscnmonth!=. & frmscnyear!=. //0 changes
replace frmscnmonth=. if frmscnd==. & frmscnmonth!=. & frmscnyear!=. //0 changes
replace frmscnyear=. if frmscnd==. & frmscnyear!=. //0 changes
count if frmscnd==. & (frmscnday!=. | frmscnmonth!=. | frmscnyear!=.) //0
** Invalid missing code (notified date partial fields)
count if frmscnday==88|frmscnday==999|frmscnday==9999 //0
count if frmscnmonth==88|frmscnmonth==999|frmscnmonth==9999 //0
count if frmscnyear==88|frmscnyear==99|frmscnyear==999 //0
** Invalid (before NotifiedDate)
count if frmscnd!=. & ambcalld!=. & frmscnd<ambcalld //0
** Invalid (before AtSceneDate)
count if frmscnd!=. & atscnd!=. & frmscnd<atscnd //0
** Invalid (after AtHospitalDate)
count if frmscnd!=. & hospd!=. & frmscnd>hospd //0
** Missing time
count if frmscnt=="" & arrivalmode==1 //3 - ambulance sheet missing from notes; leave as is.
** Invalid (time format)
count if frmscnt!="" & frmscnt!="88" & frmscnt!="99" & (length(frmscnt)<5|length(frmscnt)>5) //0
count if frmscnt!="" & frmscnt!="88" & frmscnt!="99" & !strmatch(strupper(frmscnt), "*:*") //0
generate byte non_numeric_frmscnt = indexnot(frmscnt, "0123456789.-:")
count if non_numeric_frmscnt //0
** Invalid missing code
count if frmscnt=="999"|frmscnt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if frmscnt=="88" & frmscntampm==. //0
** Invalid (frmscene time before notified time)
count if frmscnt!="" & frmscnt!="99" & ambcallt!="" & ambcallt!="99" & frmscnt<ambcallt //4 - all correct
** Invalid (fromscene time before time at scene)
count if frmscnt!="" & frmscnt!="99" & atscnt!="" & atscnt!="99" & frmscnt<atscnt //3 - all correct
** Invalid (atscene time after time at hospital)
count if frmscnt!="" & frmscnt!="99" & hospt!="" & hospt!="99" & frmscnt>hospt //3 - all correct

*****************************
** At Hospital Date & Time **
*****************************
** Missing date
count if hospd==. & arrivalmode==1 & sameadm!=1 //4 - checked CVDdb and 3 have athospital date=99 as ambulance sheet missing from notes so leave as is; stroke record 3510 corrected below.
** Missing invalid codes
count if sameadm==88|sameadm==999|sameadm==9999 //0
** Invalid (not 2021)
count if hospd!=. & year(hospd)!=2021 //2 - stroke record 4289 incorrect as event was mistakenly entered as 2021 but all other dates in abs=2022; stroke record 3403 correct as edate=dec2021
** Invalid (before DOB)
count if dob!=. & hospd!=. & hospd<dob //0
** Invalid (after CFAdmDate)
count if hospd!=. & cfadmdate!=. & hospd>cfadmdate //1 - correct
** Invalid (after DLC/DOD)
count if dlc!=. & hospd!=. & hospd>dlc //0
count if cfdod!=. & hospd!=. & hospd>cfdod //0
** Invalid (after A&EAdmDate)
count if hospd!=. & dae!=. & hospd>dae //1 - correct
** Invalid (after WardAdmDate)
count if hospd!=. & doh!=. & hospd>doh //0
** Invalid (future date)
count if hospd!=. & hospd>sd_currentdate //0
** Invalid (notified date partial missing codes for all)
count if arrivalmode==1 & hospd==. & hospday==99 & hospmonth==99 & hospyear==9999 //0
** possibly Invalid (notified date not partial but partial field not blank)
count if hospd==. & hospday!=. & hospmonth!=. & hospyear!=. //0
replace hospday=. if hospd==. & hospday!=. & hospmonth!=. & hospyear!=. //0 changes
replace hospmonth=. if hospd==. & hospmonth!=. & hospyear!=. //0 changes
replace hospyear=. if hospd==. & hospyear!=. //0 changes
count if hospd==. & (hospday!=. | hospmonth!=. | hospyear!=.) //0
** Invalid missing code (notified date partial fields)
count if hospday==88|hospday==999|hospday==9999 //0
count if hospmonth==88|hospmonth==999|hospmonth==9999 //0
count if hospyear==88|hospyear==99|hospyear==999 //0
** Invalid (before NotifiedDate)
count if hospd!=. & ambcalld!=. & hospd<ambcalld //0
** Invalid (before AtSceneDate)
count if hospd!=. & atscnd!=. & hospd<atscnd //0
** Invalid (before FromSceneDate)
count if hospd!=. & frmscnd!=. & hospd<frmscnd //0
** Missing time
count if hospt=="" & arrivalmode==1 & sameadm!=1 //0
** Invalid (time format)
count if hospt!="" & hospt!="88" & hospt!="99" & (length(hospt)<5|length(hospt)>5) //0
count if hospt!="" & hospt!="88" & hospt!="99" & !strmatch(strupper(hospt), "*:*") //0
generate byte non_numeric_hospt = indexnot(hospt, "0123456789.-:")
count if non_numeric_hospt //0
** Invalid missing code
count if hospt=="999"|hospt=="9999" //0
** Invalid (time=88 and am/pm is missing)
count if hospt=="88" & hosptampm==. //0
** Invalid (athospital time before notified time)
count if hospt!="" & hospt!="99" & ambcallt!="" & ambcallt!="99" & hospt<ambcallt //7 - all correct
** Invalid (athospital time before fromscene time)
count if hospt!="" & hospt!="99" & atscnt!="" & atscnt!="99" & hospt<atscnt //6 - all correct
** Invalid (athospital time before time at scene)
count if hospt!="" & hospt!="99" & hospt!="" & hospt!="99" & hospt<frmscnt //3 - all correct


** Corrections from above checks
replace flag129=ambcalld if record_id=="3510"
replace ambcalld=dae if record_id=="3510" //see above
replace flag1054=ambcalld if record_id=="3510"

replace flag150=hospd if record_id=="3510"
replace hospd=dae if record_id=="3510" //see above
replace flag1075=hospd if record_id=="3510"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="3510"


*****************************
** Patient Management Info **
*****************************
** Missing (ward info)
count if ward___1==0 & ward___2==0 & ward___3==0 & ward___4==0 & ward___5==0 & ward___98==0 & patient_management_complete!=0 & patient_management_complete!=. //0 - note we have to add in the form status variable since cases wherein dx was confirmed but case not abstracted as year was closed would have NO data in this form.
** Invalid (ward=other; other ward=one of the relation options)
count if ward___98==1 //8 - reviewed and 6 are correct; 2 corrected below
** Missing (ptm info)
count if sourcetype==2 & nohosp___1==0 & nohosp___2==0 & nohosp___3==0 & nohosp___4==0 & nohosp___5==0 & nohosp___6==0 & nohosp___98==0 & nohosp___99==0 & patient_management_complete!=0 & patient_management_complete!=. //0
** Invalid missing code
count if nohosp___88==1|nohosp___999==1|nohosp___9999==1 //0
** Invalid (relation=other; other relation=one of the relation options)
count if nohosp___98==1 //0


** Corrections from above checks
destring flag158 ,replace
destring flag1083 ,replace
destring flag161 ,replace
destring flag1086 ,replace

replace flag158=ward___3 if record_id=="1729"|record_id=="3741"
replace flag161=ward___98 if record_id=="1729"|record_id=="3741"
replace flag162=oward if record_id=="1729"|record_id=="3741"
replace ward___3=1 if record_id=="1729"|record_id=="3741" //see above
replace ward___98=0 if record_id=="1729"|record_id=="3741" //see above
replace oward="" if record_id=="1729"|record_id=="3741" //see above
replace flag1083=ward___3 if record_id=="1729"|record_id=="3741"
replace flag1086=ward___98 if record_id=="1729"|record_id=="3741"
replace flag1087=oward if record_id=="1729"|record_id=="3741"

** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="1729"|record_id=="3741"


/*
** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile (so added the code for that to this dofile and all the others preceding it with corrections).

** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flagdate flag267 flag1192 flag117 flag1042 flag120 flag1045 flag194 flag1119 flag240 flag1165 flag125 flag1050 flag129 flag1054 flag150 flag1075  %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag74 flag117 flag118 flag120 flag124 flag125 flag129 flag133 flag140 flag150 flag154 flag158 flag161 flag240 flag267 if ///
		(flag74!=. | flag117!=. | flag118!="" | flag120!=. | flag124!=. | flag125!=. | flag129!=. | flag133!="" | flag140!="" | flag150!=. | flag154!="" | flag158!=. | flag161!=. | flag240!=. | flag267!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_PTM1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag999 flag1042 flag1043 flag1045 flag1049 flag1050 flag1054 flag1058 flag1065 flag1075 flag1079 flag1083 flag1086 flag1165 flag1192 if ///
		 (flag999!=. | flag1042!=. | flag1043!="" | flag1045!=. | flag1049!=. | flag1050!=. | flag1054!=. | flag1058!="" | flag1065!="" | flag1075!=. | flag1079!="" | flag1083!=. | flag1086!=. | flag1165!=. | flag1192!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_PTM1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
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
gen fmcdate_text = string(fmcdate, "%td")
gen fmcdatetime2 = fmcdate_text+" "+fmctime if fmcdate!=. & fmctime!="" & fmctime!="88" & fmctime!="99"
gen double sd_fmcdatetime = clock(fmcdatetime2,"DMYhm") if fmcdatetime2!=""
format sd_fmcdatetime %tc
label var sd_fmcdatetime "DateTime of FIRST MEDICAL CONTACT"
** A&E admission
gen dae_text = string(dae, "%td")
gen daetae2 = dae_text+" "+tae if dae!=. & tae!="" & tae!="88" & tae!="99"
gen double sd_daetae = clock(daetae2,"DMYhm") if daetae2!=""
format sd_daetae %tc
label var sd_daetae "DateTime Admitted to A&E"
** A&E discharge
gen daedis_text = string(daedis, "%td")
gen daetaedis2 = daedis_text+" "+taedis if daedis!=. & taedis!="" & taedis!="88" & taedis!="99"
gen double sd_daetaedis = clock(daetaedis2,"DMYhm") if daetaedis2!=""
format sd_daetaedis %tc
label var sd_daetaedis "DateTime Discharged from A&E"
** Admission (Ward)
gen doh_text = string(doh, "%td")
gen dohtoh2 = doh_text+" "+toh if doh!=. & toh!="" & toh!="88" & toh!="99"
gen double sd_dohtoh = clock(dohtoh2,"DMYhm") if dohtoh2!=""
format sd_dohtoh %tc
label var sd_dohtoh "DateTime Admitted to Ward"
** Notified (Ambulance)
gen ambcalld_text = string(ambcalld, "%td")
gen ambcalldt2 = ambcalld_text+" "+ambcallt if ambcalld!=. & ambcallt!="" & ambcallt!="88" & ambcallt!="99"
gen double sd_ambcalldt = clock(ambcalldt2,"DMYhm") if ambcalldt2!=""
format sd_ambcalldt %tc
label var sd_ambcalldt "DateTime Ambulance NOTIFIED"
** At Scene (Ambulance)
gen atscnd_text = string(atscnd, "%td")
gen atscndt2 = atscnd_text+" "+atscnt if atscnd!=. & atscnt!="" & atscnt!="88" & atscnt!="99"
gen double sd_atscndt = clock(atscndt2,"DMYhm") if atscndt2!=""
format sd_atscndt %tc
label var sd_atscndt "DateTime Ambulance AT SCENE"
** From Scene (Ambulance)
gen frmscnd_text = string(frmscnd, "%td")
gen frmscndt2 = frmscnd_text+" "+frmscnt if frmscnd!=. & frmscnt!="" & frmscnt!="88" & frmscnt!="99"
gen double sd_frmscndt = clock(frmscndt2,"DMYhm") if frmscndt2!=""
format sd_frmscndt %tc
label var sd_frmscndt "DateTime Ambulance FROM SCENE"
** At Hospital (Ambulance)
gen hospd_text = string(hospd, "%td")
gen hospdt2 = hospd_text+" "+hospt if hospd!=. & hospt!="" & hospt!="88" & hospt!="99"
gen double sd_hospdt = clock(hospdt2,"DMYhm") if hospdt2!=""
format sd_hospdt %tc
label var sd_hospdt "DateTime Ambulance AT HOSPITAL"


** Remove 2022 cases + unnecessary variables from above 
drop if record_id=="3121"|record_id=="" //2 deleted

drop flagdate sd_currentdate

FOR TESTS FORM - add check for if assess=No and assess1 or assess2 etc = Yes

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_ptm" ,replace