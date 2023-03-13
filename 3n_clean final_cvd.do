** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3n_clean final_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-MAR-2023
    // 	date last modified      13-MAR-2023
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

destring flag256 ,replace
destring flag1181 ,replace
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

destring flag295 ,replace
destring flag1220 ,replace
replace flag295=hcl if hcl==99999
replace flag1220=hcl if hcl==99999

destring flag296 ,replace
destring flag1221 ,replace
replace flag296=af if af==99999
replace flag1221=af if af==99999

destring flag297 ,replace
destring flag1222 ,replace
replace flag297=tia if tia==99999
replace flag1222=tia if tia==99999

destring flag301 ,replace
destring flag1226 ,replace
replace flag301=hld if hld==99999
replace flag1226=hld if hld==99999

replace flag303=drugs if drugs==99999
replace flag1228=drugs if drugs==99999

** Unanswered variables from 3i_clean tests_cvd.do **

destring flag318 ,replace
destring flag1243 ,replace
replace flag318=assess1 if assess1==99999
replace flag1243=assess1 if assess1==99999

destring flag319 ,replace
destring flag1244 ,replace
replace flag319=assess2 if assess2==99999
replace flag1244=assess2 if assess2==99999

destring flag320 ,replace
destring flag1245 ,replace
replace flag320=assess3 if assess3==99999
replace flag1245=assess3 if assess3==99999

destring flag321 ,replace
destring flag1246 ,replace
replace flag321=assess4 if assess4==99999
replace flag1246=assess4 if assess4==99999

destring flag322 ,replace
destring flag1247 ,replace
replace flag322=assess7 if assess7==99999
replace flag1247=assess7 if assess7==99999

destring flag323 ,replace
destring flag1248 ,replace
replace flag323=assess8 if assess8==99999
replace flag1248=assess8 if assess8==99999

destring flag325 ,replace
destring flag1250 ,replace
replace flag325=assess10 if assess10==99999
replace flag1250=assess10 if assess10==99999

destring flag326 ,replace
destring flag1251 ,replace
replace flag326=assess12 if assess12==99999
replace flag1251=assess12 if assess12==99999

destring flag327 ,replace
destring flag1252 ,replace
replace flag327=assess14 if assess14==99999
replace flag1252=assess14 if assess14==99999

destring flag331 ,replace
destring flag1256 ,replace
replace flag331=dmri if dmri==99999
replace flag1256=dmri if dmri==99999

destring flag332 ,replace
destring flag1257 ,replace
replace flag332=dcerangio if dcerangio==99999
replace flag1257=dcerangio if dcerangio==99999

destring flag333 ,replace
destring flag1258 ,replace
replace flag333=dcarangio if dcarangio==99999
replace flag1258=dcarangio if dcarangio==99999

destring flag334 ,replace
destring flag1259 ,replace
replace flag334=dcarus if dcarus==99999
replace flag1259=dcarus if dcarus==99999

destring flag335 ,replace
destring flag1260 ,replace
replace flag335=decho if decho==99999
replace flag1260=decho if decho==99999

** Unanswered variables from 3j_clean comp_cvd.do **

destring flag422 ,replace
destring flag1347 ,replace
replace flag422=hdvt if hdvt==99999
replace flag1347=hdvt if hdvt==99999

destring flag423 ,replace
destring flag1348 ,replace
replace flag423=hpneu if hpneu==99999
replace flag1348=hpneu if hpneu==99999

destring flag424 ,replace
destring flag1349 ,replace
replace flag424=hulcer if hulcer==99999
replace flag1349=hulcer if hulcer==99999

destring flag425 ,replace
destring flag1350 ,replace
replace flag425=huti if huti==99999
replace flag1350=huti if huti==99999

destring flag426 ,replace
destring flag1351 ,replace
replace flag426=hfall if hfall==99999
replace flag1351=hfall if hfall==99999

destring flag427 ,replace
destring flag1352 ,replace
replace flag427=hhydro if hhydro==99999
replace flag1352=hhydro if hhydro==99999

destring flag428 ,replace
destring flag1353 ,replace
replace flag428=hhaemo if hhaemo==99999
replace flag1353=hhaemo if hhaemo==99999

destring flag429 ,replace
destring flag1354 ,replace
replace flag429=hoinfect if hoinfect==99999
replace flag1354=hoinfect if hoinfect==99999

destring flag430 ,replace
destring flag1355 ,replace
replace flag430=hgibleed if hgibleed==99999
replace flag1355=hgibleed if hgibleed==99999

destring flag431 ,replace
destring flag1356 ,replace
replace flag431=hccf if hccf==99999
replace flag1356=hccf if hccf==99999

destring flag433 ,replace
destring flag1358 ,replace
replace flag433=haneur if haneur==99999
replace flag1358=haneur if haneur==99999

destring flag434 ,replace
destring flag1359 ,replace
replace flag434=hhypo if hhypo==99999
replace flag1359=hhypo if hhypo==99999

destring flag435 ,replace
destring flag1360 ,replace
replace flag435=hblock if hblock==99999
replace flag1360=hblock if hblock==99999

destring flag437 ,replace
destring flag1362 ,replace
replace flag437=hafib if hafib==99999
replace flag1362=hafib if hafib==99999

destring flag438 ,replace
destring flag1363 ,replace
replace flag438=hcshock if hcshock==99999
replace flag1363=hcshock if hcshock==99999

destring flag439 ,replace
destring flag1364 ,replace
replace flag439=hinfarct if hinfarct==99999
replace flag1364=hinfarct if hinfarct==99999

destring flag440 ,replace
destring flag1365 ,replace
replace flag440=hrenal if hrenal==99999
replace flag1365=hrenal if hrenal==99999

destring flag441 ,replace
destring flag1366 ,replace
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

destring flag1851 ,replace
destring flag1863 ,replace
replace flag1851=warf___99999 if warf___99999==1
replace flag1863=warf___99999 if warf___99999==1

destring flag1852 ,replace
destring flag1864 ,replace
replace flag1852=hep___99999 if hep___99999==1
replace flag1864=hep___99999 if hep___99999==1

destring flag1853 ,replace
destring flag1865 ,replace
replace flag1853=heplmw___99999 if heplmw___99999==1
replace flag1865=heplmw___99999 if heplmw___99999==1

destring flag1854 ,replace
destring flag1866 ,replace
replace flag1854=pla___99999 if pla___99999==1
replace flag1866=pla___99999 if pla___99999==1

destring flag1855 ,replace
destring flag1867 ,replace
replace flag1855=stat___99999 if stat___99999==1
replace flag1867=stat___99999 if stat___99999==1

destring flag1856 ,replace
destring flag1868 ,replace
replace flag1856=fibr___99999 if fibr___99999==1
replace flag1868=fibr___99999 if fibr___99999==1

destring flag1857 ,replace
destring flag1869 ,replace
replace flag1857=ace___99999 if ace___99999==1
replace flag1869=ace___99999 if ace___99999==1

destring flag1858 ,replace
destring flag1870 ,replace
replace flag1858=arbs___99999 if arbs___99999==1
replace flag1870=arbs___99999 if arbs___99999==1

destring flag1859 ,replace
destring flag1871 ,replace
replace flag1859=cors___99999 if cors___99999==1
replace flag1871=cors___99999 if cors___99999==1

destring flag1860 ,replace
destring flag1872 ,replace
replace flag1860=nimo___99999 if nimo___99999==1
replace flag1872=nimo___99999 if nimo___99999==1

destring flag1861 ,replace
destring flag1873 ,replace
replace flag1861=antis___99999 if antis___99999==1
replace flag1873=antis___99999 if antis___99999==1

destring flag1862 ,replace
destring flag1874 ,replace
replace flag1862=ted___99999 if ted___99999==1
replace flag1874=ted___99999 if ted___99999==1


** Unanswered variables from 3l_clean dis_cvd.do **

destring flag738 ,replace
destring flag1663 ,replace
replace flag738=ddvt if ddvt==99999
replace flag1663=ddvt if ddvt==99999

destring flag740 ,replace
destring flag1665 ,replace
replace flag740=dulcer if dulcer==99999
replace flag1665=dulcer if dulcer==99999

destring flag745 ,replace
destring flag1670 ,replace
replace flag745=doinfect if doinfect==99999
replace flag1670=doinfect if doinfect==99999

destring flag746 ,replace
destring flag1671 ,replace
replace flag746=dgibleed if dgibleed==99999
replace flag1671=dgibleed if dgibleed==99999

destring flag747 ,replace
destring flag1672 ,replace
replace flag747=dccf if dccf==99999
replace flag1672=dccf if dccf==99999

destring flag748 ,replace
destring flag1673 ,replace
replace flag748=dcpang if dcpang==99999
replace flag1673=dcpang if dcpang==99999

destring flag749 ,replace
destring flag1674 ,replace
replace flag749=daneur if daneur==99999
replace flag1674=daneur if daneur==99999

destring flag750 ,replace
destring flag1675 ,replace
replace flag750=dhypo if dhypo==99999
replace flag1675=dhypo if dhypo==99999

destring flag751 ,replace
destring flag1676 ,replace
replace flag751=dblock if dblock==99999
replace flag1676=dblock if dblock==99999

destring flag752 ,replace
destring flag1677 ,replace
replace flag752=dseizures if dseizures==99999
replace flag1677=dseizures if dseizures==99999

destring flag753 ,replace
destring flag1678 ,replace
replace flag753=dafib if dafib==99999
replace flag1678=dafib if dafib==99999

destring flag754 ,replace
destring flag1679 ,replace
replace flag754=dcshock if dcshock==99999
replace flag1679=dcshock if dcshock==99999

destring flag755 ,replace
destring flag1680 ,replace
replace flag755=dinfarct if dinfarct==99999
replace flag1680=dinfarct if dinfarct==99999

destring flag756 ,replace
destring flag1681 ,replace
replace flag756=drenal if drenal==99999
replace flag1681=drenal if drenal==99999

destring flag757 ,replace
destring flag1682 ,replace
replace flag757=dcarest if dcarest==99999
replace flag1682=dcarest if dcarest==99999

** Unanswered variables from 3m_clean fu_cvd.do **

destring flag919 ,replace
destring flag1844 ,replace
replace flag919=f1rankin1 if f1rankin1==99999
replace flag1844=f1rankin1 if f1rankin1==99999


/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
//format %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
** JC 13mar2023: Since this corrections list only contains variables that are blank/unanswered by DA, only the CORRECTIONS tab is needed
/*
capture export_excel record_id sd_etype flag259 flag260 flag261 flag269 flag176 flag177 flag178 flag179 flag187 flag244 flag245 flag246 flag247 flag248 flag249 flag254 flag255 flag256 flag310 flag311 flag313 flag317 flag328 flag342 flag405 flag180 flag181 flag182 flag183 flag184 flag185 flag186 flag271 flag272 flag295 flag296 flag297 flag301 flag303 flag318 flag319 flag320 flag321 flag322 flag323 flag325 flag326 flag327 flag331 flag332 flag333 flag334 flag335 flag422 flag423 flag424 flag425 flag426 flag427 flag428 flag429 flag430 flag431 flag433 flag434 flag435 flag437 flag438 flag439 flag440 flag441 flag1851 flag1852 flag1853 flag1854 flag1855 flag1856 flag1857 flag1858 flag1859 flag1860 flag1861 flag1862 flag738 flag740 flag745 flag746 flag747 flag748 flag749 flag750 flag751 flag752 flag753 flag754 flag755 flag756 flag757 flag919 if ///
		(flag259==99999 | flag260==99999 | flag261==99999 | flag269=="99999" | flag176==99999 | flag177==99999 | flag178==99999 | flag179==99999 | flag187==99999 | flag244==99999 | flag245==99999 | flag246==99999 | flag247==99999 | flag248==99999 | flag249==99999 | flag254==99999 | flag255==99999 | flag256==99999 | flag310==99999 | flag311==99999 | flag313==99999 | flag317==99999 | flag328==99999 | flag342==99999 | flag405==99999 | flag180==99999 | flag181==99999 | flag182==99999 | flag183==99999 | flag184==99999 | flag185==99999 | flag186==99999 | flag271==99999 | flag272==99999 | flag295==99999 | flag296==99999 | flag297==99999 | flag301==99999 | flag303==99999 | flag318==99999 | flag319==99999 | flag320==99999 | flag321==99999 | flag322==99999 | flag323==99999 | flag325==99999 | flag326==99999 | flag327==99999 | flag331==99999 | flag332==99999 | flag333==99999 | flag334==99999 | flag335==99999 | flag422==99999 | flag423==99999 | flag424==99999 | flag425==99999 | flag426==99999 | flag427==99999 | flag428==99999 | flag429==99999 | flag430==99999 | flag431==99999 | flag433==99999 | flag434==99999 | flag435==99999 | flag437==99999 | flag438==99999 | flag439==99999 | flag440==99999 | flag441==99999 | flag1851==99999 | flag1852==99999 | flag1853==99999 | flag1854==99999 | flag1855==99999 | flag1856==99999 | flag1857==99999 | flag1858==99999 | flag1859==99999 | flag1860==99999 | flag1861==99999 | flag1862==99999 | flag738==99999 | flag740==99999 | flag745==99999 | flag746==99999 | flag747==99999 | flag748==99999 | flag749==99999 | flag750==99999 | flag751==99999 | flag752==99999 | flag753==99999 | flag754==99999 | flag755==99999 | flag756==99999 | flag757==99999 | flag919==99999) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FINAL1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
*/
capture export_excel record_id sd_etype flag1184 flag1185 flag1186 flag1194 flag1101 flag1102 flag1103 flag1104 flag1112 flag1169 flag1170 flag1171 flag1172 flag1173 flag1174 flag1179 flag1180 flag1181 flag1235 flag1236 flag1238 flag1242 flag1253 flag1267 flag1330 flag1105 flag1106 flag1107 flag1108 flag1109 flag1110 flag1111 flag1196 flag1197 flag1220 flag1221 flag1222 flag1226 flag1228 flag1243 flag1244 flag1245 flag1246 flag1247 flag1248 flag1250 flag1251 flag1252 flag1256 flag1257 flag1258 flag1259 flag1260 flag1347 flag1348 flag1349 flag1350 flag1351 flag1352 flag1353 flag1354 flag1355 flag1356 flag1358 flag1359 flag1360 flag1362 flag1363 flag1364 flag1365 flag1366 flag1863 flag1864 flag1865 flag1866 flag1867 flag1868 flag1869 flag1870 flag1871 flag1872 flag1873 flag1874 flag1663 flag1665 flag1670 flag1671 flag1672 flag1673 flag1674 flag1675 flag1676 flag1677 flag1678 flag1679 flag1680 flag1681 flag1682 flag1844 if ///
		 flag1184==99999 | flag1185==99999 | flag1186==99999 | flag1194=="999999" | flag1101==99999 | flag1102==99999 | flag1103==99999 | flag1104==99999 | flag1112==99999 | flag1169==99999 | flag1170==99999 | flag1171==99999 | flag1172==99999 | flag1173==99999 | flag1174==99999 | flag1179==99999 | flag1180==99999 | flag1181==99999 | flag1235==99999 | flag1236==99999 | flag1238==99999 | flag1242==99999 | flag1253==99999 | flag1267==99999 | flag1330==99999 | flag1105==99999 | flag1106==99999 | flag1107==99999 | flag1108==99999 | flag1109==99999 | flag1110==99999 | flag1111==99999 | flag1196==99999 | flag1197==99999 | flag1220==99999 | flag1221==99999 | flag1222==99999 | flag1226==99999 | flag1228==99999 | flag1243==99999 | flag1244==99999 | flag1245==99999 | flag1246==99999 | flag1247==99999 | flag1248==99999 | flag1250==99999 | flag1251==99999 | flag1252==99999 | flag1256==99999 | flag1257==99999 | flag1258==99999 | flag1259==99999 | flag1260==99999 | flag1347==99999 | flag1348==99999 | flag1349==99999 | flag1350==99999 | flag1351==99999 | flag1352==99999 | flag1353==99999 | flag1354==99999 | flag1355==99999 | flag1356==99999 | flag1358==99999 | flag1359==99999 | flag1360==99999 | flag1362==99999 | flag1363==99999 | flag1364==99999 | flag1365==99999 | flag1366==99999 | flag1863==99999 | flag1864==99999 | flag1865==99999 | flag1866==99999 | flag1867==99999 | flag1868==99999 | flag1869==99999 | flag1870==99999 | flag1871==99999 | flag1872==99999 | flag1873==99999 | flag1874==99999 | flag1663==99999 | flag1665==99999 | flag1670==99999 | flag1671==99999 | flag1672==99999 | flag1673==99999 | flag1674==99999 | flag1675==99999 | flag1676==99999 | flag1677==99999 | flag1678==99999 | flag1679==99999 | flag1680==99999 | flag1681==99999 | flag1682==99999 | flag1844==99999 ///
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
	
** Invalid (pla time before event time)
count if plat!="" & plat!="99" & etime!="" & etime!="99" & plat<etime //56 - all are correct except heart record 2702 corrected below; stroke record 3096 for NS to review
//see OneNote book for outcome of these query reviews + stroke record 3096 corrected below


	** Queries from 3l_clean dis_cvd.do **

** Queries #116 + #117 in OneNote bk (stroke records 1833 + 1956) already corrected in 3l_clean dis_cvd.do


	** Queries from 3m_clean fu_cvd.do **

** Query #118 in OneNote bk (stroke record 1729) leave as is.

** Queries #118 + #119 in OneNote bk (11 records + 37 records) already corrected in 3m_clean fu_cvd.do.



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
replace flag1043=tae if record_id=="3318"|record_id=="2322"
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

replace flag269=etime if record_id=="3096"
replace etime=subinstr(etime,"19","07",.) if record_id=="3096" //see above
replace flag1194=etime if record_id=="3096"



** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
replace flagdate=sd_currentdate if record_id=="2816"|record_id=="2910"|record_id=="1870"|record_id=="1808"|record_id=="3220"|record_id=="3318"|record_id=="2322"|record_id=="2083"|record_id=="2149"|record_id=="2270"|record_id=="2435"|record_id=="2441"|record_id=="2442"|record_id=="2678"|record_id=="3037"|record_id=="3318"|record_id=="3338"|record_id=="3517"|record_id=="4106"|record_id=="4173"|record_id=="1848"|record_id=="2245"|record_id=="2439"|record_id=="2540"|record_id=="2265"|record_id=="2322"|record_id=="3096"



/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flag117 flag1042 flag343 flag1268 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag117 flag118 flag257 flag258 flag269 flag343 flag349 flag350 flag351 flag407 flag531 flag534 if ///
		(flag117!=. | flag118!="" | flag257!=. | flag258!=. | flag269!="" | flag343!=. | flag349!=. | flag350!=. | flag351!=. | flag407!=. | flag531!=. | flag534!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FINAL2_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag1042 flag1043 flag1182 flag1183 flag1194 flag1268 flag1274 flag1275 flag1276 flag1332 flag1456 flag1459 if ///
		 (flag1042!=. | flag1043!="" | flag1182!=. | flag1183!=. | flag1194!="" | flag1268!=. | flag1274!=. | flag1275!=. | flag1276!=. | flag1332!=. | flag1456!=. | flag1459!=.) & flagdate!=. ///
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
drop disd_text disdt2 sd_disdt
gen disd_text = string(disd, "%td")
gen disdt2 = disd_text+" "+dist if disd!=. & dist!="" & dist!="88" & dist!="99"
gen double sd_disdt = clock(disdt2,"DMYhm") if disdt2!=""
format sd_disdt %tc
label var sd_disdt "DateTime of Discharge"
** Death
drop dod_text dodtod2 sd_dodtod
gen dod_text = string(dod, "%td")
gen dodtod2 = dod_text+" "+tod if dod!=. & tod!="" & tod!="88" & tod!="99"
gen double sd_dodtod = clock(dodtod2,"DMYhm") if dodtod2!=""
format sd_dodtod %tc
label var sd_dodtod "DateTime of Death"


*****************************
** 	   Final Cleaning of   **
** Annual Report Variables **
*****************************
****************
** Event Date **
****************
count if edate==. //3

STOP


*********
** Age **
*********
count if (age==.|age==999) & cfage_da!=. //18 - all have missing DOB + NRN
replace age=cfage_da if (age==.|age==999) & cfage_da!=. //18 changes

count if (age==.|age==999) & dob!=. //3


** Create age by event variable
drop age
gen age2=(edate-dob)/365.25
gen age=int(age2)
label var age "Age at Event"
drop age2

tab age ,m //16 missing age - cross check against electoral list
list sd_etype record_id dd_deathid dd_fname dd_mname dd_lname dd_age 


STOP







** Remove unnecessary variables
drop fu1doa2 fu1date

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_final" ,replace