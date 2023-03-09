** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3n_clean final_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-MAR-2023
    // 	date last modified      09-MAR-2023
    //  algorithm task          Final cleaning variables in prep for analysis
    //  status                  Completed
    //  objective               (1) To have a cleaned 2021 cvd incidence dataset ready for analysis
	//							(2) To have a list with errors and corrections for DAs to correct data directly into CVDdb
    //  methods                 Using missing and invalid checks to correct data
	//	note					This dofile consists of:
	//							- flagging variables unanswered by DA for DAs to correct using the missing code 99999 in CVDdb
	//							- flagging variables for DAs to correct from query reviews with NS post-cleaning of CVDdb forms
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
    log using "`logpath'\3n_clean final_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_fu", clear

count //1145


****************************************************
** Corrections from variables unanswered by DAs   **
**	 (See CVD DM Re-engineer OneNote book)		  **
** Missing code 99999 added to CVDdb on 09mar2023 **
****************************************************

** Unanswered variables from 3g_clean event_cvd.do **

STOP
replace flag259=dxtype if dxtype==999999 //41
replace flag1184=dxtype if dxtype==999999 //41 changes

replace flag260=dstroke if dstroke==99999 //27dstroke=99999
replace flag1185=dstroke if dstroke==99999 //27 changes

replace flag261=review if review==99999 //41
replace flag1186=review if review==99999 //42 changes

replace flag269=etime if etime=="99999" //26
replace flag1194=etime if etime=="99999" //26 changes

replace flag176=ssym1 if ssym1==99999
replace flag1101=ssym1 if ssym1==99999

replace flag177=ssym2 if ssym2==99999
replace flag1102=ssym2 if ssym2==99999

replace flag178=ssym3 if ssym3==99999
replace flag1103=ssym3 if ssym3==99999

replace flag179=ssym4 if ssym4==99999
replace flag1104=ssym4 if ssym4==99999

replace flag187=osym if osym==99999
replace flag1112=osym if osym==99999

replace flag244=sign1 if sign1==99999
replace flag1169=sign1 if sign1==99999

replace flag245=sign2 if sign2==99999
replace flag1170=sign2 if sign2==99999

replace flag246=sign3 if sign3==99999
replace flag1171=sign3 if sign3==99999

replace flag247=sign4 if sign4==99999
replace flag1172=sign4 if sign4==99999

replace flag248=sonset if sonset==99999
replace flag1173=sonset if sonset==99999

replace flag249=sday if sday==99999
replace flag1174=sday if sday==99999

replace flag254=cardmon if cardmon==99999
replace flag1179=cardmon if cardmon==99999

replace flag255=nihss if nihss==99999
replace flag1180=nihss if nihss==99999

replace flag256=timi if timi==99999
replace flag1181=timi if timi==99999

replace flag310=sysbp if sysbp==99999
replace flag1235=sysbp if sysbp==99999

replace flag311=diasbp if diasbp==99999
replace flag1236=diasbp if diasbp==99999

replace flag313=bgunit if bgunit==99999
replace flag1238=bgunit if bgunit==99999

replace flag317=assess if assess==99999
replace flag1242=assess if assess==99999

replace flag328=dieany if dieany==99999
replace flag1253=dieany if dieany==99999

replace flag342=ct if ct==99999
replace flag1267=ct if ct==99999

replace flag405=tiany if tiany==99999
replace flag1330=tiany if tiany==99999

replace flag180=hsym1 if hsym1==99999
replace flag1105=hsym1 if hsym1==99999

replace flag181=hsym2 if hsym2==99999
replace flag1106=hsym2 if hsym2==99999

replace flag182=hsym3 if hsym3==99999
replace flag1107=hsym3 if hsym3==99999

replace flag183=hsym4 if hsym4==99999
replace flag1108=hsym4 if hsym4==99999

replace flag184=hsym5 if hsym5==99999
replace flag1109=hsym5 if hsym5==99999

replace flag185=hsym6 if hsym6==99999
replace flag1110=hsym6 if hsym6==99999

replace flag186=hsym7 if hsym7==99999
replace flag1111=hsym7 if hsym7==99999

replace flag271=cardiac if cardiac==99999
replace flag1196=cardiac if cardiac==99999

replace flag272=cardiachosp if cardiachosp==99999
replace flag1197=cardiachosp if cardiachosp==99999

** Unanswered variables from 3h_clean hx_cvd.do **

replace flag295=hcl if hcl==99999
replace flag1220=hcl if hcl==99999

replace flag296=af if af==99999
replace flag1221=af if af==99999

replace flag297=tia if tia==99999
replace flag1222=tia if tia==99999

replace flag301=hld if hld==99999
replace flag1226=hld if hld==99999

replace flag303=drugs if drugs==99999
replace flag1228=drugs if drugs==99999

** Unanswered variables from 3i_clean tests_cvd.do **

replace flag318=assess1 if assess1==99999
replace flag1243=assess1 if assess1==99999

replace flag319=assess2 if assess2==99999
replace flag1244=assess2 if assess2==99999

replace flag320=assess3 if assess3==99999
replace flag1246=assess3 if assess3==99999

replace flag321=assess4 if assess4==99999
replace flag1245=assess4 if assess4==99999

replace flag322=assess7 if assess7==99999
replace flag1247=assess7 if assess7==99999

replace flag323=assess8 if assess8==99999
replace flag1248=assess8 if assess8==99999

replace flag325=assess10 if assess10==99999
replace flag1250=assess10 if assess10==99999

replace flag326=assess12 if assess12==99999
replace flag1251=assess12 if assess12==99999

replace flag327=assess14 if assess14==99999
replace flag1252=assess14 if assess14==99999

replace flag331=dmri if dmri==99999
replace flag1256=dmri if dmri==99999

replace flag332=dcerangio if dcerangio==99999
replace flag1257=dcerangio if dcerangio==99999

replace flag333=dcarangio if dcarangio==99999
replace flag1258=dcarangio if dcarangio==99999

replace flag334=dcarus if dcarus==99999
replace flag1259=dcarus if dcarus==99999

replace flag335=decho if decho==99999
replace flag1260=decho if decho==99999

** Unanswered variables from 3j_clean comp_cvd.do **

replace flag422=hdvt if hdvt==99999
replace flag1347=hdvt if hdvt==99999

replace flag423=hpneu if hpneu==99999
replace flag1348=hpneu if hpneu==99999

replace flag424=hulcer if hulcer==99999
replace flag1349=hulcer if hulcer==99999

replace flag425=huti if huti==99999
replace flag1350=huti if huti==99999

replace flag426=hfall if hfall==99999
replace flag1351=hfall if hfall==99999

replace flag427=hhydro if hhydro==99999
replace flag1352=hhydro if hhydro==99999

replace flag428=hhaemo if hhaemo==99999
replace flag1353=hhaemo if hhaemo==99999

replace flag429=hoinfect if hoinfect==99999
replace flag1354=hoinfect if hoinfect==99999

replace flag430=hgibleed if hgibleed==99999
replace flag1355=hgibleed if hgibleed==99999

replace flag431=hccf if hccf==99999
replace flag1356=hccf if hccf==99999

replace flag433=haneur if haneur==99999
replace flag1358=haneur if haneur==99999

replace flag434=hhypo if hhypo==99999
replace flag1359=hhypo if hhypo==99999

replace flag435=hblock if hblock==99999
replace flag1360=hblock if hblock==99999

replace flag437=hafib if hafib==99999
replace flag1362=hafib if hafib==99999

replace flag438=hcshock if hcshock==99999
replace flag1363=hcshock if hcshock==99999

replace flag439=hinfarct if hinfarct==99999
replace flag1364=hinfarct if hinfarct==99999

replace flag440=hrenal if hrenal==99999
replace flag1365=hrenal if hrenal==99999

replace flag441=hcarest if hcarest==99999
replace flag1366=hcarest if hcarest==99999

** Unanswered variables from 3k_clean rx_cvd.do **

//There are no flags created for these corrections as 2b_prep flags_cvd.do was done before these types of blank variables were identified during cleaning
forvalues j=1851/1874 {
	gen flag`j'=""
}
***********
** Error **
** Flags **
***********
label var flag1851 "Warfarin (Missing code=99999)"
label var flag1852 "Heparin (Missing code=99999)"
label var flag1853 "Heparin lmw (Missing code=99999)"
label var flag1854 "Antiplatelets (Missing code=99999)"
label var flag1855 "Statin (Missing code=99999)"
label var flag1856 "Fibrinolytics (Missing code=99999)"
label var flag1857 "ACE (Missing code=99999)"
label var flag1858 "ARBs (Missing code=99999)"
label var flag1859 "Corticosteroids (Missing code=99999)"
label var flag1860 "Nimodipine (Missing code=99999)"
label var flag1861 "Antiseizures (Missing code=99999)"
label var flag1862 "TED Stockings (Missing code=99999)"

****************
** Correction **
**	 Flags	  **
****************
label var flag1863 "Warfarin (Missing code=99999)"
label var flag1864 "Heparin (Missing code=99999)"
label var flag1865 "Heparin lmw (Missing code=99999)"
label var flag1866 "Antiplatelets (Missing code=99999)"
label var flag1867 "Statin (Missing code=99999)"
label var flag1868 "Fibrinolytics (Missing code=99999)"
label var flag1869 "ACE (Missing code=99999)"
label var flag1870 "ARBs (Missing code=99999)"
label var flag1871 "Corticosteroids (Missing code=99999)"
label var flag1872 "Nimodipine (Missing code=99999)"
label var flag1873 "Antiseizures (Missing code=99999)"
label var flag1874 "TED Stockings (Missing code=99999)"

replace flag1851=warf___99999 if warf___99999==1
replace flag1863=warf___99999 if warf___99999==1

replace flag1852=hep___99999 if hep___99999==1
replace flag1864=hep___99999 if hep___99999==1

replace flag1853=heplmw___99999 if heplmw___99999==1
replace flag1865=heplmw___99999 if heplmw___99999==1

replace flag1854=pla___99999 if pla___99999==1
replace flag1866=pla___99999 if pla___99999==1

replace flag1855=stat___99999 if stat___99999==1
replace flag1867=stat___99999 if stat___99999==1

replace flag1856=fibr___99999 if fibr___99999==1
replace flag1868=fibr___99999 if fibr___99999==1

replace flag1857=ace___99999 if ace___99999==1
replace flag1869=ace___99999 if ace___99999==1

replace flag1858=arbs___99999 if arbs___99999==1
replace flag1870=arbs___99999 if arbs___99999==1

replace flag1859=cors___99999 if cors___99999==1
replace flag1871=cors___99999 if cors___99999==1

replace flag1860=nimo___99999 if nimo___99999==1
replace flag1872=nimo___99999 if nimo___99999==1

replace flag1861=antis___99999 if antis___99999==1
replace flag1873=antis___99999 if antis___99999==1

replace flag1862=ted___99999 if ted___99999==1
replace flag1874=ted___99999 if ted___99999==1


** Unanswered variables from 3l_clean dis_cvd.do **

replace flag738=ddvt if ddvt==99999
replace flag1663=ddvt if ddvt==99999

replace flag740=dulcer if dulcer==99999
replace flag1665=dulcer if dulcer==99999

replace flag745=doinfect if doinfect==99999
replace flag1670=doinfect if doinfect==99999

replace flag746=dgibleed if dgibleed==99999
replace flag1671=dgibleed if dgibleed==99999

replace flag747=dccf if dccf==99999
replace flag1672=dccf if dccf==99999

replace flag748=dcpang if dcpang==99999
replace flag1673=dcpang if dcpang==99999

replace flag749=daneur if daneur==99999
replace flag1674=daneur if daneur==99999

replace flag750=dhypo if dhypo==99999
replace flag1675=dhypo if dhypo==99999

replace flag751=dblock if dblock==99999
replace flag1676=dblock if dblock==99999

replace flag752=dseizures if dseizures==99999
replace flag1677=dseizures if dseizures==99999

replace flag753=dafib if dafib==99999
replace flag1678=dafib if dafib==99999

replace flag754=dcshock if dcshock==99999
replace flag1679=dcshock if dcshock==99999

replace flag755=dinfarct if dinfarct==99999
replace flag1680=dinfarct if dinfarct==99999

replace flag756=drenal if drenal==99999
replace flag1681=drenal if drenal==99999

replace flag757=dcarest if dcarest==99999
replace flag1682=dcarest if dcarest==99999

** Unanswered variables from 3m_clean fu_cvd.do **

replace flag919=f1rankin1 if f1rankin1==99999
replace flag1844=f1rankin1 if f1rankin1==99999



/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flag61 flag986 flag700 flag1625 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag61 flag700 flag712 flag855 flag856 flag861 if ///
		(flag61!=. | flag700!=. | flag712!=. |  flag855!=. |  flag856!=. |  flag861!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FINAL1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag986 flag1625 flag1637 flag1780 flag1781 flag1786 if ///
		 (flag986!=. | flag1625!=. | flag1637!=. |  flag1780!=. |  flag1781!=. |  flag1786!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FINAL1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


**********************************************************
** Corrections from query reviews with NS post-cleaning **
**			(See CVD DM Re-engineer OneNote book)		**
**********************************************************

	** Queries from 3i_clean tests_cvd.do **

*****************
** CT/MRI Date **
*****************
** possibly Invalid (before CFAdmDate)
count if doct!=. & cfadmdate!=. & doct<cfadmdate & inhosp!=1 & fmcdate==. //7 - 2816 + 2910 for review by NS; 3403 DA notes CT done privately but FMC not entered; the others are correct i.e. A&E date same as CT date
//NS found CTs on her system - see OneNote book for outcome of these query reviews

**************************
** CT/MRI Features Info **
**************************
**************
** Infarct? **
**************
** possibly Invalid (infarct=Yes; stroke type NOT=Ischaemic)
count if ctinfarct==1 & stype!=1 //4 - record 1870 for NS to review; other 3 are correct
//NS found CT on her system - see OneNote book for outcome of these query reviews
**********
** SAH? **
**********
** possibly Invalid (SAH=Yes; stroke type NOT=SAH)
count if ctsubhaem==1 & stype!=3 //4 - records 2278, 2612, 3225 + 4111 for NS to review
//NS found CT on her system - see OneNote book for outcome of these query reviews; Note records 2278 + 2612 already corrected in tests dofile and 3225 + 4111 are correct so leave as is.
**********
** ICH? **
**********
** possibly Invalid (ICH=Yes; stroke type NOT=ICH)
count if ctinthaem==1 & stype!=2 //3 - record 1808 for NS to review; other 2 are correct
//NS found CT on her system - see OneNote book for outcome of these query reviews

*******************
** Troponin Date **
*******************
** possibly Invalid (before CFAdmDate)
count if tropd!=. & cfadmdate!=. & tropd<cfadmdate & inhosp!=1 & fmcdate==. //1 - 3220 for review by NS
//see OneNote book for outcome of these query reviews

**************
** ECG Date **
**************
** possibly Invalid (after WardAdmDate)
count if ecgd!=. & doh!=. & ecgd>doh & inhosp!=1 & fmcdate==. //2 - record 2555 already corrected; record 3318 for NS to review
//see OneNote book for outcome of these query reviews; note - heart record 3318 pt also had a stroke see 2322

******************
** ST Elevation **
******************
** possibly Invalid (STE=Yes; heart type NOT=STEMI)
count if ecgste==1 & htype!=1 //21 - for NS to review
//see OneNote book for outcome of these query reviews: in OneNote bk NS noted that consultant may indicate the ST-elevation on ECG is not significant enough to dx as STEMI so the finaldx ends up=NSTEMI so change the ones wherein htype=AMI(definite) to STEMI but leave the NSTEMIs as is and note in reviewer comments this anomaly

*******************
** ST Depression **
*******************
** possibly Invalid (STD=Yes; STE not=Yes; heart type NOT=NSTEMI)
count if ecgstd==1 & ecgste!=1 & htype!=2 //5 - for NS to review 1848, 2245, 2439, 2477 + 2540
//see OneNote book for outcome of these query reviews; change all except 2477 to NSTEMI

*************************
** Other interventions **
** 	(Heart + Stroke)   **
*************************
****************
** Oth Int. 1 **
****************
** possibly Invalid (other int.=one of the int. options)
count if oti1!="" //4 - reviewed and correct - heart record 2265 BiPAP to be corrected below
//see OneNote book for outcome of these query reviews

	** Queries from 3k_clean rx_cvd.do **

** Query #111 in OneNote bk corrected below as fibrinolytics usually given specific ones for MI and different ones for stroke so since pt was first admitted for MI (record 3318) then had stroke while in hospital then fibrinolytics should be No for stroke (record 2322)

** Query #113 in OneNote bk (heart record 2045) already corrected in 3k_clean rx_cvd.do

STOP
** Corrections from above checks
destring flag117 ,replace
destring flag1042 ,replace
destring flag257 ,replace
destring flag1182 ,replace
destring flag343 ,replace
destring flag1268 ,replace
destring flag349 ,replace
destring flag1274 ,replace
destring flag350 ,replace
destring flag1275 ,replace
destring flag351 ,replace
destring flag1276 ,replace
destring flag407 ,replace
destring flag1332 ,replace
destring flag531 ,replace
destring flag1456 ,replace
destring flag534 ,replace
destring flag1459 ,replace
format flag117 flag1042 flag343 flag1268 %dM_d,_CY


replace flag343=doct if record_id=="2816"
replace doct=doct+22 if record_id=="2816"
replace flag1268=doct if record_id=="2816"

replace flag117=dae if record_id=="2910"|record_id=="3220"
replace dae=dae-1 if record_id=="2910"|record_id=="3220" //see above
replace flag1042=dae if record_id=="2910"|record_id=="3220"

replace flag349=ctinfarct if record_id=="1870"
replace ctinfarct=2 if record_id=="1870" //see above
replace flag1274=ctinfarct if record_id=="1870"

replace flag350=ctsubhaem if record_id=="1870"
replace ctsubhaem=1 if record_id=="1870" //see above
replace flag1275=ctsubhaem if record_id=="1870"

replace flag351=ctinthaem if record_id=="1870"
replace ctinthaem=1 if record_id=="1870" //see above
replace flag1276=ctinthaem if record_id=="1870"

replace flag257=stype if record_id=="1808"
replace stype=2 if record_id=="1808" //see above
replace flag1182=stype if record_id=="1808"

replace flag118=tae if record_id=="3318"|record_id=="2322"
replace tae=subinstr(tae,"12","00",.) if record_id=="3318"|record_id=="2322" //see above
replace flag1043=stype if record_id=="3318"|record_id=="2322"
//ECG date already corrected in tests dofile for heart record 3318


replace flag258=htype if record_id=="2083"|record_id=="2149"|record_id=="2270"|record_id=="2435"|record_id=="2441"|record_id=="2442"|record_id=="2678"|record_id=="3037"|record_id=="3318"|record_id=="3338"|record_id=="3517"|record_id=="4106"|record_id=="4173"
replace htype=1 if record_id=="2083"|record_id=="2149"|record_id=="2270"|record_id=="2435"|record_id=="2441"|record_id=="2442"|record_id=="2678"|record_id=="3037"|record_id=="3318"|record_id=="3338"|record_id=="3517"|record_id=="4106"|record_id=="4173" //see above
replace flag1183=htype if record_id=="2083"|record_id=="2149"|record_id=="2270"|record_id=="2435"|record_id=="2441"|record_id=="2442"|record_id=="2678"|record_id=="3037"|record_id=="3318"|record_id=="3338"|record_id=="3517"|record_id=="4106"|record_id=="4173"

replace comments="On review of this case during cleaning, NS noted that the consultant may indicate the ST-elevation on ECG is not significant enough to dx as STEMI so the finaldx ends up=NSTEMI so change the ones wherein htype=AMI(definite) to STEMI but leave the NSTEMIs as is so the heart type of this case has been updated from AMI (definite) to STEMI." if record_id=="2083"|record_id=="2149"|record_id=="2270"|record_id=="2435"|record_id=="2441"|record_id=="2442"|record_id=="2678"|record_id=="3037"|record_id=="3318"|record_id=="3338"|record_id=="3517"|record_id=="4106"|record_id=="4173"

replace comments="On review of this case during cleaning, NS noted that the consultant may indicate the ST-elevation on ECG is not significant enough to dx as STEMI so the finaldx ends up=NSTEMI so change the ones wherein htype=AMI(definite) to STEMI but leave the NSTEMIs as is so the heart type of this case has NOT been updated but is left as NSTEMI." if record_id=="1970"|record_id=="2045"|record_id=="2282"|record_id=="2420"|record_id=="2600"|record_id=="2758"|record_id=="2880"|record_id=="3265"


replace flag258=htype if record_id=="1848"|record_id=="2245"|record_id=="2439"|record_id=="2540"
replace htype=2 if record_id=="1848"|record_id=="2245"|record_id=="2439"|record_id=="2540" //see above
replace flag1183=htype if record_id=="1848"|record_id=="2245"|record_id=="2439"|record_id=="2540"

replace flag407=tnippv if record_id=="2265"
replace tnippv=1 if record_id=="2265" //see above
replace flag1332=tnippv if record_id=="2265"
replace oti=4 if record_id=="2265" //CVDdb will automatically erase this value once DA performs above correction
replace oti1="" if record_id=="2265" //CVDdb will automatically erase this value once DA performs above correction

replace flag531=fibr___1 if record_id=="2322"
replace fibr___1=0 if record_id=="2322" //see above
replace flag1456=fibr___1 if record_id=="2322"

replace flag534=fibr___99 if record_id=="2322"
replace fibr___99=1 if record_id=="2322" //see above
replace flag1459=fibr___99 if record_id=="2322"



** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2816"|record_id=="2910"|record_id=="1870"|record_id=="1808"|record_id=="3220"|record_id=="3318"|record_id=="2322"|record_id=="2083"|record_id=="2149"|record_id=="2270"|record_id=="2435"|record_id=="2441"|record_id=="2442"|record_id=="2678"|record_id=="3037"|record_id=="3318"|record_id=="3338"|record_id=="3517"|record_id=="4106"|record_id=="4173"|record_id=="1848"|record_id=="2245"|record_id=="2439"|record_id=="2540"|record_id=="2265"|record_id=="2322"



/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flag61 flag986 flag700 flag1625 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag61 flag700 flag712 flag855 flag856 flag861 if ///
		(flag61!=. | flag700!=. | flag712!=. |  flag855!=. |  flag856!=. |  flag861!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FINAL2_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag986 flag1625 flag1637 flag1780 flag1781 flag1786 if ///
		 (flag986!=. | flag1625!=. | flag1637!=. |  flag1780!=. |  flag1781!=. |  flag1786!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FINAL2_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


** Populate SU admission + discharge dates in prep for analysis
count if sunitadmsame==1 & astrunitd==. & doh!=. //131
replace astrunitd=doh if sunitadmsame==1 & astrunitd==. //131 changes
count if sunitdissame==1 & dstrunitd==. & disd!=. //138
replace dstrunitd=disd if sunitdissame==1 & dstrunitd==. //138 changes

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
drop reperfd_text reperfdt2 sd_reperfdt
gen reperfd_text = string(reperfd, "%td")
gen reperfdt2 = reperfd_text+" "+reperft if reperfd!=. & reperft!="" & reperft!="88" & reperft!="99"
gen double sd_reperfdt = clock(reperfdt2,"DMYhm") if reperfdt2!=""
format sd_reperfdt %tc
label var sd_reperfdt "DateTime of Reperfusion"
** Aspirin
drop aspd_text aspdt2 sd_aspdt
gen aspd_text = string(aspd, "%td")
gen aspdt2 = aspd_text+" "+aspt if aspd!=. & aspt!="" & aspt!="88" & aspt!="99"
gen double sd_aspdt = clock(aspdt2,"DMYhm") if aspdt2!=""
format sd_aspdt %tc
label var sd_aspdt "DateTime of Aspirin"
** Warfarin
drop warfd_text warfdt2 sd_warfdt
gen warfd_text = string(warfd, "%td")
gen warfdt2 = warfd_text+" "+warft if warfd!=. & warft!="" & warft!="88" & warft!="99"
gen double sd_warfdt = clock(warfdt2,"DMYhm") if warfdt2!=""
format sd_warfdt %tc
label var sd_warfdt "DateTime of Warfarin"
** Heparin (sc/iv)
drop hepd_text hepdt2 sd_hepdt
gen hepd_text = string(hepd, "%td")
gen hepdt2 = hepd_text+" "+hept if hepd!=. & hept!="" & hept!="88" & hept!="99"
gen double sd_hepdt = clock(hepdt2,"DMYhm") if hepdt2!=""
format sd_hepdt %tc
label var sd_hepdt "DateTime of Heparin (sc/iv)"
** Heparin (lmw)
drop heplmwd_text heplmwdt2 sd_heplmwdt
gen heplmwd_text = string(heplmwd, "%td")
gen heplmwdt2 = heplmwd_text+" "+heplmwt if heplmwd!=. & heplmwt!="" & heplmwt!="88" & heplmwt!="99"
gen double sd_heplmwdt = clock(heplmwdt2,"DMYhm") if heplmwdt2!=""
format sd_heplmwdt %tc
label var sd_heplmwdt "DateTime of Heparin (lmw)"
** Antiplatelets
drop plad_text pladt2 sd_pladt
gen plad_text = string(plad, "%td")
gen pladt2 = plad_text+" "+plat if plad!=. & plat!="" & plat!="88" & plat!="99"
gen double sd_pladt = clock(pladt2,"DMYhm") if pladt2!=""
format sd_pladt %tc
label var sd_pladt "DateTime of Antiplatelets"
** Statin
drop statd_text statdt2 sd_statdt
gen statd_text = string(statd, "%td")
gen statdt2 = statd_text+" "+statt if statd!=. & statt!="" & statt!="88" & statt!="99"
gen double sd_statdt = clock(statdt2,"DMYhm") if statdt2!=""
format sd_statdt %tc
label var sd_statdt "DateTime of Statin"
** Fibrinolytics
drop fibrd_text fibrdt2 sd_fibrdt
gen fibrd_text = string(fibrd, "%td")
gen fibrdt2 = fibrd_text+" "+fibrt if fibrd!=. & fibrt!="" & fibrt!="88" & fibrt!="99"
gen double sd_fibrdt = clock(fibrdt2,"DMYhm") if fibrdt2!=""
format sd_fibrdt %tc
label var sd_fibrdt "DateTime of Fibrinolytics"
** ACE
drop aced_text acedt2 sd_acedt
gen aced_text = string(aced, "%td")
gen acedt2 = aced_text+" "+acet if aced!=. & acet!="" & acet!="88" & acet!="99"
gen double sd_acedt = clock(acedt2,"DMYhm") if acedt2!=""
format sd_acedt %tc
label var sd_acedt "DateTime of ACE Inhibitors"
** ARBs
drop arbsd_text arbsdt2 sd_arbsdt
gen arbsd_text = string(arbsd, "%td")
gen arbsdt2 = arbsd_text+" "+arbst if arbsd!=. & arbst!="" & arbst!="88" & arbst!="99"
gen double sd_arbsdt = clock(arbsdt2,"DMYhm") if arbsdt2!=""
format sd_arbsdt %tc
label var sd_arbsdt "DateTime of ARBs"
** Corticosteroids
drop corsd_text corsdt2 sd_corsdt
gen corsd_text = string(corsd, "%td")
gen corsdt2 = corsd_text+" "+corst if corsd!=. & corst!="" & corst!="88" & corst!="99"
gen double sd_corsdt = clock(corsdt2,"DMYhm") if corsdt2!=""
format sd_corsdt %tc
label var sd_corsdt "DateTime of Corticosteroids"
** Antihypertensives
drop antihd_text antihdt2 sd_antihdt
gen antihd_text = string(antihd, "%td")
gen antihdt2 = antihd_text+" "+antiht if antihd!=. & antiht!="" & antiht!="88" & antiht!="99"
gen double sd_antihdt = clock(antihdt2,"DMYhm") if antihdt2!=""
format sd_antihdt %tc
label var sd_antihdt "DateTime of Antihypertensives"
** Nimodipine
drop nimod_text nimodt2 sd_nimodt
gen nimod_text = string(nimod, "%td")
gen nimodt2 = nimod_text+" "+nimot if nimod!=. & nimot!="" & nimot!="88" & nimot!="99"
gen double sd_nimodt = clock(nimodt2,"DMYhm") if nimodt2!=""
format sd_nimodt %tc
label var sd_nimodt "DateTime of Nimodipine"
** Antiseizures
drop antisd_text antisdt2 sd_antisdt
gen antisd_text = string(antisd, "%td")
gen antisdt2 = antisd_text+" "+antist if antisd!=. & antist!="" & antist!="88" & antist!="99"
gen double sd_antisdt = clock(antisdt2,"DMYhm") if antisdt2!=""
format sd_antisdt %tc
label var sd_antisdt "DateTime of Antiseizures"
** TED Stockings
drop tedd_text teddt2 sd_teddt
gen tedd_text = string(tedd, "%td")
gen teddt2 = tedd_text+" "+tedt if tedd!=. & tedt!="" & tedt!="88" & tedt!="99"
gen double sd_teddt = clock(teddt2,"DMYhm") if teddt2!=""
format sd_teddt %tc
label var sd_teddt "DateTime of TED Stockings"
** Beta Blockers
drop betad_text betadt2 sd_betadt
gen betad_text = string(betad, "%td")
gen betadt2 = betad_text+" "+betat if betad!=. & betat!="" & betat!="88" & betat!="99"
gen double sd_betadt = clock(betadt2,"DMYhm") if betadt2!=""
format sd_betadt %tc
label var sd_betadt "DateTime of Beta Blockers"
** Bivalrudin
drop bivald_text bivaldt2 sd_bivaldt
gen bivald_text = string(bivald, "%td")
gen bivaldt2 = bivald_text+" "+bivalt if bivald!=. & bivalt!="" & bivalt!="88" & bivalt!="99"
gen double sd_bivaldt = clock(bivaldt2,"DMYhm") if bivaldt2!=""
format sd_bivaldt %tc
label var sd_bivaldt "DateTime of Bivalrudin"
** Discharge
//drop disd_text disdt2 sd_disdt
gen disd_text = string(disd, "%td")
gen disdt2 = disd_text+" "+dist if disd!=. & dist!="" & dist!="88" & dist!="99"
gen double sd_disdt = clock(disdt2,"DMYhm") if disdt2!=""
format sd_disdt %tc
label var sd_disdt "DateTime of Discharge"
** Death
//drop dod_text dodtod2 sd_dodtod
gen dod_text = string(dod, "%td")
gen dodtod2 = dod_text+" "+tod if dod!=. & tod!="" & tod!="88" & tod!="99"
gen double sd_dodtod = clock(dodtod2,"DMYhm") if dodtod2!=""
format sd_dodtod %tc
label var sd_dodtod "DateTime of Death"


** Remove unnecessary variables
drop fu1doa2 fu1date

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_final" ,replace