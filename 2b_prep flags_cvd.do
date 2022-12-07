** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          2b_prep flags_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified      07-DEC-2022
    //  algorithm task          Creating flags for each variable
    //  status                  Pending
    //  objective               To have the prepared 2021 cvd incidence dataset with flagged fields for the CVD team to correct data in REDCap's BNRCVD_CORE db
    //  methods                 Using forvalues loop to create sequential flag variables for each field in the db except the reviewing form fields
	//							Using the frame command (multiple datasets), to copy values from both the prepared (ds with errors) and corrected datasets
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
    log using "`logpath'\2b_prep flags_cvd.smcl", replace
** HEADER -----------------------------------------------------

/*
	In order for the CVD team to correct the data in the REDCap database based on the errors and corrections found and performed 
	during this Stata cleaning process, a dataset with the erroneous and corrected data needs to be created.
	Using the multiple datasets Stata method,
	
	(1)	Create a dataset with erroneous data (prepared ds in dofile 2a_prep_cvd.do)
	(2)	Create a dataset with flagged data (flagged ds in this dofile)
	(3)	Create a dataset with corrected data (corrected ds in dofiles 3a - ....)
	(4) Use the flagged ds to push these flagged records into the Reviewing form in REDCap's BNRCVD_CORE db (arm 4)
*/

** Load prepared 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_PreparedData", clear
count //1834

** Create REDCap's Reviewing form variables
gen rvetype=. //Event Type or Db Arm
gen rvpid=. //Review ID
gen rvpidcfabs="" //Record ID (CF/ABS)
gen rvcfadoa=. //Date/Time from CF/ABS forms
gen rvcfada="" //DA REDCap username from CF/ABS forms
gen rvflagd=. //Date/Time correction was flagged
gen rvflag="" //Field that was flagged for correction
gen rvflag_old="" //Error value in field
gen rvflag_new="" //Corrected value in field

** Create flagged dataset
drop cfdoa cfdoat cfda sri srirec evolution sourcetype firstnf cfsource___1 cfsource___2 cfsource___3 cfsource___4 cfsource___5 cfsource___6 cfsource___7 cfsource___8 cfsource___9 cfsource___10 cfsource___11 cfsource___12 cfsource___13 cfsource___14 cfsource___15 cfsource___16 cfsource___17 cfsource___18 cfsource___19 cfsource___20 cfsource___21 cfsource___22 cfsource___23 cfsource___24 cfsource___25 cfsource___26 cfsource___27 cfsource___28 cfsource___29 cfsource___30 cfsource___31 cfsource___32 retsource oretsrce fname mname lname sex dob dobday dobmonth dobyear cfage cfage_da natregno nrnyear nrnmonth nrnday nrnnum recnum cfadmdate cfadmyr cfadmdatemon cfadmdatemondash initialdx hstatus slc dlc dlcyr dlcday dlcmonth dlcyear cfdod cfdodyr cfdodday cfdodmonth cfdodyear finaldx cfcods docname docaddr cstatus eligible ineligible pendrv duplicate duprec dupcheck requestdate1 requestdate2 requestdate3 nfdb nfdbrec reabsrec toabs copycf casefinding_complete adoa adoat ada mstatus resident citizen addr parish hometel worktel celltel fnamekin lnamekin sametel homekin workkin cellkin relation orelation copydemo demographics_complete ptmdoa ptmdoat ptmda fmc fmcplace ofmcplace fmcdate fmcdday fmcdmonth fmcdyear fmctime fmcampm hospital ohospital aeadmit dae tae taeampm daedis taedis taedisampm wardadmit dohsame doh toh tohampm arrivalmode ambcalld ambcallday ambcallmonth ambcallyear ambcallt ambcalltampm atscene atscnd atscnday atscnmonth atscnyear atscnt atscntampm frmscene frmscnd frmscnday frmscnmonth frmscnyear frmscnt frmscntampm sameadm hospd hospday hospmonth hospyear hospt hosptampm ward___1 ward___2 ward___3 ward___4 ward___5 ward___98 oward nohosp___1 nohosp___2 nohosp___3 nohosp___4 nohosp___5 nohosp___6 nohosp___98 nohosp___99 nohosp___88 nohosp___999 nohosp___9999 onohosp copyptm patient_management_complete edoa edoat eda ssym1 ssym2 ssym3 ssym4 hsym1 hsym2 hsym3 hsym4 hsym5 hsym6 hsym7 osym osym1 osym2 osym3 osym4 osym5 osym6 ssym1d ssym1day ssym1month ssym1year ssym2d ssym2day ssym2month ssym2year ssym3d ssym3day ssym3month ssym3year ssym4d ssym4day ssym4month ssym4year hsym1d hsym1day hsym1month hsym1year hsym1t hsym1tampm hsym2d hsym2day hsym2month hsym2year hsym3d hsym3day hsym3month hsym3year hsym4d hsym4day hsym4month hsym4year hsym5d hsym5day hsym5month hsym5year hsym6d hsym6day hsym6month hsym6year hsym7d hsym7day hsym7month hsym7year osymd osymday osymmonth osymyear sign1 sign2 sign3 sign4 sonset sday swalldate swalldday swalldmonth swalldyear cardmon nihss timi stype htype dxtype dstroke review reviewreason reviewer___1 reviewer___2 reviewer___3 reviewd edate fu1date edateyr edatemon edatemondash inhosp etime etimeampm age edateetime daetae ambcalldt onsetevetoae onsetambtoae cardiac cardiachosp resus sudd fname_eve lname_eve sex_eve slc_eve cstatus_eve eligible_eve fu1done copyeve f1vstatus_eve event_complete hxdoa hxdoat hxda pstroke pami pihd pcabg pcorangio pstrokeyr pamiyr dbchecked famstroke famami mumstroke dadstroke sibstroke mumami dadami sibami rfany smoker hcl af tia ccf htn diab hld alco drugs ovrf ovrf1 ovrf2 ovrf3 ovrf4 copyhx history_complete tdoa tdoat tda sysbp diasbp bpm bgunit bgmg bgmmol o2sat assess assess1 assess2 assess3 assess4 assess7 assess8 assess9 assess10 assess12 assess14 dieany dct decg dmri dcerangio dcarangio dcarus decho dctcorang dstress odie odie1 odie2 odie3 ct doct doctday doctmonth doctyear stime ctfeat ctinfarct ctsubhaem ctinthaem ckmbdone astdone tropdone tropcomm tropd tropdday tropdmonth tropdyear tropt troptampm troptype tropres trop1res trop2res ecg ecgd ecgdday ecgdmonth ecgdyear ecgt ecgtampm ecgs ischecg ecgantero ecgrv ecgant ecglat ecgpost ecginf ecgsep ecgnd oecg oecg1 oecg2 oecg3 oecg4 ecgfeat ecglbbb ecgaf ecgste ecgstd ecgpqw ecgtwv ecgnor ecgnorsin ecgomi ecgnstt ecglvh oecgfeat oecgfeat1 oecgfeat2 oecgfeat3 oecgfeat4 tiany tppv tnippv tdefib tcpr tmech tctcorang tpacetemp tcath tdhemi tvdrain oti oti1 oti2 oti3 copytests tests_complete dxdoa dxdoat dxda hcomp hdvt hpneu hulcer huti hfall hhydro hhaemo hoinfect hgibleed hccf hcpang haneur hhypo hblock hseizures hafib hcshock hinfarct hrenal hcarest ohcomp ohcomp1 ohcomp2 ohcomp3 ohcomp4 ohcomp5 absdxsame absdxs___1 absdxs___2 absdxs___3 absdxs___4 absdxs___5 absdxs___6 absdxs___7 absdxs___8 absdxs___99 absdxs___88 absdxs___999 absdxs___9999 absdxh___1 absdxh___2 absdxh___3 absdxh___4 absdxh___5 absdxh___6 absdxh___7 absdxh___8 absdxh___9 absdxh___10 absdxh___99 absdxh___88 absdxh___999 absdxh___9999 oabsdx oabsdx1 oabsdx2 oabsdx3 oabsdx4 copycomp complications_dx_complete rxdoa rxdoat rxda reperf repertype reperfd reperfdday reperfdmonth reperfdyear reperft reperftampm asp___1 asp___2 asp___3 asp___99 asp___88 asp___999 asp___9999 warf___1 warf___2 warf___3 warf___99 warf___88 warf___999 warf___9999 hep___1 hep___2 hep___3 hep___99 hep___88 hep___999 hep___9999 heplmw___1 heplmw___2 heplmw___3 heplmw___99 heplmw___88 heplmw___999 heplmw___9999 pla___1 pla___2 pla___3 pla___99 pla___88 pla___999 pla___9999 stat___1 stat___2 stat___3 stat___99 stat___88 stat___999 stat___9999 fibr___1 fibr___2 fibr___3 fibr___99 fibr___88 fibr___999 fibr___9999 ace___1 ace___2 ace___3 ace___99 ace___88 ace___999 ace___9999 arbs___1 arbs___2 arbs___3 arbs___99 arbs___88 arbs___999 arbs___9999 cors___1 cors___2 cors___3 cors___99 cors___88 cors___999 cors___9999 antih___1 antih___2 antih___3 antih___99 antih___88 antih___999 antih___9999 nimo___1 nimo___2 nimo___3 nimo___99 nimo___88 nimo___999 nimo___9999 antis___1 antis___2 antis___3 antis___99 antis___88 antis___999 antis___9999 ted___1 ted___2 ted___3 ted___99 ted___88 ted___999 ted___9999 beta___1 beta___2 beta___3 beta___99 beta___88 beta___999 beta___9999 bival___1 bival___2 bival___3 bival___99 bival___88 bival___999 bival___9999 aspdose aspd aspdday aspdmonth aspdyear aspt asptampm warfd warfdday warfdmonth warfdyear warft warftampm hepd hepdday hepdmonth hepdyear hept heptampm heplmwd heplmwdday heplmwdmonth heplmwdyear heplmwt heplmwtampm plad pladday pladmonth pladyear plat platampm statd statdday statdmonth statdyear statt stattampm fibrd fibrdday fibrdmonth fibrdyear fibrt fibrtampm aced acedday acedmonth acedyear acet acetampm arbsd arbsdday arbsdmonth arbsdyear arbst arbstampm corsd corsdday corsdmonth corsdyear corst corstampm antihd antihdday antihdmonth antihdyear antiht antihtampm nimod nimodday nimodmonth nimodyear nimot nimotampm antisd antisdday antisdmonth antisdyear antist antistampm tedd teddday teddmonth teddyear tedt tedtampm betad betadday betadmonth betadyear betat betatampm bivald bivaldday bivaldmonth bivaldyear bivalt bivaltampm copymeds edateyr_rx edatemondash_rx medications_complete ddoa ddoat dda vstatus disd disdday disdmonth disdyear dist distampm dod dodday dodmonth dodyear tod todampm pm codsame cods cod1 cod2 cod3 cod4 aspdis warfdis heplmwdis pladis statdis fibrdis acedis arbsdis corsdis antihdis nimodis antisdis teddis betadis bivaldis aspdosedis dissysbp disdiasbp dcomp ddvt dpneu dulcer duti dfall dhydro dhaemo doinfect dgibleed dccf dcpang daneur dhypo dblock dseizures dafib dcshock dinfarct drenal dcarest odcomp odcomp1 odcomp2 odcomp3 odcomp4 odcomp5 disdxsame disdxs___1 disdxs___2 disdxs___3 disdxs___4 disdxs___5 disdxs___6 disdxs___7 disdxs___8 disdxs___99 disdxs___88 disdxs___999 disdxs___9999 disdxh___1 disdxh___2 disdxh___3 disdxh___4 disdxh___5 disdxh___6 disdxh___7 disdxh___8 disdxh___9 disdxh___10 disdxh___99 disdxh___88 disdxh___999 disdxh___9999 odisdx odisdx1 odisdx2 odisdx3 odisdx4 reclass recdxs___1 recdxs___2 recdxs___3 recdxs___4 recdxs___5 recdxs___6 recdxs___7 recdxs___8 recdxs___99 recdxs___88 recdxs___999 recdxs___9999 recdxh___1 recdxh___2 recdxh___3 recdxh___4 recdxh___5 recdxh___6 recdxh___7 recdxh___8 recdxh___9 recdxh___10 recdxh___99 recdxh___88 recdxh___999 recdxh___9999 orecdx orecdx1 orecdx2 orecdx3 orecdx4 strunit sunitadmsame astrunitd astrunitdday astrunitdmonth astrunitdyear sunitdissame dstrunitd dstrunitdday dstrunitdmonth dstrunitdyear carunit cunitadmsame acarunitd acarunitdday acarunitdmonth acarunitdyear cunitdissame dcarunitd dcarunitdday dcarunitdmonth dcarunitdyear readmit readmitadm readmitdis readmitdays copydis discharge_complete fu1call1 fu1call2 fu1call3 fu1call4 fu1type fu1doa fu1da fu1oda edatefu1doadiff fu1day fu1oday fu1sicf fu1con fu1how f1vstatus fu1sit fu1osit fu1readm fu1los furesident ethnicity oethnic education mainwork employ prevemploy pstrsit pstrosit rankin rankin1 rankin2 rankin3 rankin4 rankin5 rankin6 famhxs famhxa mahxs dahxs sibhxs mahxa dahxa sibhxa smoke stopsmoke stopsmkday stopsmkmonth stopsmkyear stopsmokeage smokeage cig pipe cigar otobacco tobacmari marijuana cignum tobgram cigarnum spliffnum alcohol stopalc stopalcday stopalcmonth stopalcyear stopalcage alcage beernumnd spiritnumnd winenumnd beernum spiritnum winenum f1rankin f1rankin1 f1rankin2 f1rankin3 f1rankin4 f1rankin5 f1rankin6 copyfu1 day_fu_complete repinstrument sd_multiadm sd_dcyear

count //1834

save "`datapath'\version03\2-working\BNRCVDCORE_FlaggedData", replace
use "`datapath'\version03\2-working\BNRCVDCORE_FlaggedData", clear

************
** ERRORS **
************
** Create frame for prepared (errors) ds
frame rename default flags
frame create errors
frame create corrections

** Copy errors from prepared ds into flagged ds
frame change errors
use "`datapath'\version03\2-working\BNRCVDCORE_PreparedData", clear

frame change flags

frlink 1:1 link_id, frame(errors) //all obs in frame flags matched
//replace rvflag_old = frval(errors,mname) if record_id=="2291" //1 change
replace rvflag_old = frval(errors,dob) if record_id=="2256" ///
		|record_id=="2728"|record_id=="2808"|record_id=="3021" ///
		|record_id=="3191"|record_id=="3247"|record_id=="3291"|record_id=="3306"|record_id=="3410" ///
		|record_id=="3610"|record_id=="3757"|record_id=="2280"|record_id=="2830"|record_id=="4335"|record_id=="4404"
expand=2 if record_id=="4335", gen (dupobs1)
replace rvflag_old = frval(errors,natregno) if record_id=="4335" & dupobs1==1 //1 change
expand=2 if record_id=="4335", gen (dupobs2)
replace rvflag_old = frval(errors,recnum) if record_id=="4335" & dupobs2==1 //1 change
expand=2 if record_id=="4335", gen (dupobs3)
replace rvflag_old = frval(errors,dlc) if record_id=="4335" & dupobs3==1 //1 change 	 
expand=2 if record_id=="4404", gen (dupobs1)
replace rvflag_old = frval(errors,natregno) if record_id=="4404" & dupobs1==1 //1 change
expand=2 if record_id=="4404", gen (dupobs2)
replace rvflag_old = frval(errors,recnum) if record_id=="4404" & dupobs2==1 //1 change
expand=2 if record_id=="4404", gen (dupobs3)
replace rvflag_old = frval(errors,dlc) if record_id=="4404" & dupobs3==1 //1 change 	 //|record_id=="4117"|record_id=="3728"|record_id=="3441"|record_id=="3541"|record_id=="3555"|record_id=="3192"|record_id=="3170"|record_id=="2882"|record_id=="2274"|record_id=="2675"
//0 changes as they're blank
replace rvflag_old = frval(errors,natregno) if record_id=="2280"|record_id=="2830" 
		//record_id=="2192"|record_id=="2194"|record_id=="2482"|record_id=="2551"|record_id=="3397"
replace rvflag_old = frval(errors,sex) if record_id=="2060"|record_id=="2150"
		//record_id=="1799"|record_id=="2463"|record_id=="2586"|record_id=="2907"|record_id=="2911"|record_id=="3601"|record_id=="4116"|record_id=="4357"|record_id=="1817"|record_id=="1853"|record_id=="2018"|record_id=="2050"|record_id=="2557"|record_id=="2649"|record_id=="3738"|record_id=="4354"
replace rvflag_old = frval(errors,fname) if record_id=="2150" //record_id=="4318"|
//replace rvflag_old = frval(errors,cfdod) if record_id=="3232" //1 change
replace rvflag_old = frval(errors,readmit) if record_id=="1729" //1 change
expand=2 if record_id=="1729", gen (dupobs1)
replace rvflag_old = frval(errors,readmitadm) if record_id=="1729" & dupobs1==1 //1 change
expand=2 if record_id=="1729", gen (dupobs2)
replace rvflag_old = frval(errors,readmitdis) if record_id=="1729" & dupobs2==1 //1 change
expand=2 if record_id=="1729", gen (dupobs3)
replace rvflag_old = frval(errors,readmitdays) if record_id=="1729" & dupobs3==1 //1 change
replace rvflag_old = frval(errors,dlc) if record_id=="1823"
replace rvflag_old = frval(errors,slc) if record_id=="2704"|record_id=="2840"|record_id=="3362"
expand=2 if record_id=="2704", gen (dupobs1)
replace rvflag_old = frval(errors,cfdod) if record_id=="2704" & dupobs1==1 //1 change
expand=2 if record_id=="2840", gen (dupobs1)
replace rvflag_old = frval(errors,cfdod) if record_id=="2840" & dupobs1==1 //1 change
replace rvflag_old = frval(errors,cfdod) if record_id=="2126"




*****************
** CORRECTIONS **
**	 CF FORM   **
*****************
** Copy corrections from cleaned ds into flagged ds
frame change corrections
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_cf", clear

frame change flags

frlink 1:1 link_id, frame(corrections) //7 obs in frame flags unmatched
//replace rvflag_new = frval(corrections,mname) if record_id=="2291" //1 change
replace rvflag_new = frval(corrections,dob) if record_id=="2256" ///
		|record_id=="2728"|record_id=="2808"|record_id=="3021" ///
		|record_id=="3191"|record_id=="3247"|record_id=="3291"|record_id=="3306"|record_id=="3410" ///
		|record_id=="3610"|record_id=="3757"|record_id=="2280"|record_id=="2830"|record_id=="4335"|record_id=="4404"  //|record_id=="4117"|record_id=="3728"|record_id=="3441"|record_id=="3541"|record_id=="3555"|record_id=="3192"|record_id=="3170"|record_id=="2882"|record_id=="2274"|record_id=="2675"
//2 changes
replace rvflag_new = frval(corrections,natregno) if record_id=="2280"|record_id=="2830" 
		//record_id=="2192"|record_id=="2194"|record_id=="2482"|record_id=="2551"|record_id=="3397"
replace rvflag_new = frval(corrections,sex) if record_id=="2060"|record_id=="2150"
		//record_id=="1799"|record_id=="2463"|record_id=="2586"|record_id=="2907"|record_id=="2911"|record_id=="3601"|record_id=="4116"|record_id=="4357"|record_id=="1817"|record_id=="1853"|record_id=="2018"|record_id=="2050"|record_id=="2557"|record_id=="2649"|record_id=="3738"|record_id=="4354" 
replace rvflag_new = frval(corrections,fname) if record_id=="2150" //record_id=="4318"|
//replace rvflag_new = frval(corrections,cfdod) if record_id=="3232" //1 change
replace rvflag_new = frval(corrections,readmit) if record_id=="1729" & dupobs1==0 & dupobs2==0 & dupobs3==0 //1 change
replace rvflag_new = frval(corrections,readmitadm) if record_id=="1729" & dupobs1==1 //1 change
replace rvflag_new = frval(corrections,readmitdis) if record_id=="1729" & dupobs2==1 //1 change
replace rvflag_new = frval(corrections,readmitdays) if record_id=="1729" & dupobs3==1 //1 change
replace rvflag_new = frval(corrections,dlc) if record_id=="1823"
replace rvflag_new = frval(corrections,dob) if record_id=="4335" & dupobs1==0 & dupobs2==0 & dupobs3==0 //1 change
replace rvflag_new = frval(corrections,natregno) if record_id=="4335" & dupobs1==1 //1 change
replace rvflag_new = frval(corrections,recnum) if record_id=="4335" & dupobs2==1 //1 change
replace rvflag_new = frval(corrections,dlc) if record_id=="4335" & dupobs3==1 //1 change
replace rvflag_new = frval(corrections,dob) if record_id=="4404" & dupobs1==0 & dupobs2==0 & dupobs3==0 //1 change
replace rvflag_new = frval(corrections,natregno) if record_id=="4404" & dupobs1==1 //1 change
replace rvflag_new = frval(corrections,recnum) if record_id=="4404" & dupobs2==1 //1 change
replace rvflag_new = frval(corrections,dlc) if record_id=="4404" & dupobs3==1 //1 change
replace rvflag_new = frval(corrections,slc) if record_id=="2704" & dupobs1==0|record_id=="2840" & dupobs1==0|record_id=="3362"
replace rvflag_new = frval(corrections,cfdod) if record_id=="2704" & dupobs1==1 //1 change
replace rvflag_new = frval(corrections,cfdod) if record_id=="2840" & dupobs1==1 //1 change
replace rvflag_new = frval(corrections,cfdod) if record_id=="2126"




NOTES TO SELF: 
(1) MAY NEED TO RENAME THIS DOFILE TO REPRESENT LAST DOFILE AFTER CLEANING PROCESS IS COMPLETED SO THE DOFILES ARE IN SEQUENTIAL ORDER
(2) NEED TO EXPAND SO RECORDS WITH MULTIPLE ERRORS HAVE THEIR OWN DATA ROW
