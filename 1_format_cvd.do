** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1_format_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified      01-NOV-2022
    //  algorithm task          Adding header and SharePoint pathways to REDCap-Stata exported dofile
    //  status                  Completed
    //  objective               To have REDCap data formatted to Stata for annual report data prep process
    //  methods                 Use REDCap's export to Stata option in BNRCVD_CORE db
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
    log using "`logpath'\1_format_cvd.smcl", replace
** HEADER -----------------------------------------------------


import delimited record_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance redcap_data_access_group tfdoastart tfdoatstart tfda tftype otftype tfsource cfupdate recid absdone disdone tfdepts___1 tfdepts___2 tfdepts___3 tfdepts___4 tfdepts___5 tfdepts___6 tfdepts___7 tfdepts___8 tfdepts___9 tfdepts___10 tfdepts___11 tfdepts___12 tfdepts___13 tfdepts___14 tfdepts___15 tfdepts___16 tfdepts___17 tfdepts___18 tfdepts___19 tfdepts___20 tfdepts___21 tfdepts___22 tfdepts___23 tfdepts___24 tfdepts___25 tfdepts___26 tfdepts___27 tfdepts___28 tfdepts___29 tfdepts___30 tfdepts___31 tfdepts___32 tfdepts___33 tfdepts___34 tfdepts___35 tfdepts___99 tfdepts___88 tfdepts___999 tfdepts___9999 tfwards___1 tfwards___2 tfwards___3 tfwards___4 tfwards___5 tfwards___6 tfwards___99 tfwards___88 tfwards___999 tfwards___9999 tfwardsdate tfmedrec___1 tfmedrec___2 tfmedrec___3 tfmedrec___4 tfmedrec___5 tfmedrec___99 tfmedrec___88 tfmedrec___999 tfmedrec___9999 tfmrdate tfpaypile tfmedpile tfgenpile totpile tfdrec___1 tfdrec___2 tfdrec___3 tfdrec___4 tfdrec___5 tfdrec___6 tfdrec___7 tfdrec___99 tfdrec___88 tfdrec___999 tfdrec___9999 tfaerec___1 tfaerec___2 tfaerec___3 tfaerec___4 tfaerec___5 tfaerec___99 tfaerec___88 tfaerec___999 tfaerec___9999 tfdoaend tfdoatend tfelapsed tracking_complete cfdoa cfdoat cfda sri srirec evolution sourcetype firstnf cfsource___1 cfsource___2 cfsource___3 cfsource___4 cfsource___5 cfsource___6 cfsource___7 cfsource___8 cfsource___9 cfsource___10 cfsource___11 cfsource___12 cfsource___13 cfsource___14 cfsource___15 cfsource___16 cfsource___17 cfsource___18 cfsource___19 cfsource___20 cfsource___21 cfsource___22 cfsource___23 cfsource___24 cfsource___25 cfsource___26 cfsource___27 cfsource___28 cfsource___29 cfsource___30 cfsource___31 cfsource___32 retsource oretsrce fname mname lname sex dob dobday dobmonth dobyear cfage cfage_da natregno nrnyear nrnmonth nrnday nrnnum recnum cfadmdate cfadmyr cfadmdatemon cfadmdatemondash initialdx hstatus slc dlc dlcyr dlcday dlcmonth dlcyear cfdod cfdodyr cfdodday cfdodmonth cfdodyear finaldx cfcods docname docaddr cstatus eligible ineligible pendrv duplicate duprec dupcheck requestdate1 requestdate2 requestdate3 nfdb nfdbrec reabsrec toabs copycf casefinding_complete adoa adoat ada mstatus resident citizen addr parish hometel worktel celltel fnamekin lnamekin sametel homekin workkin cellkin relation orelation copydemo demographics_complete ptmdoa ptmdoat ptmda fmc fmcplace ofmcplace fmcdate fmcdday fmcdmonth fmcdyear fmctime fmcampm hospital ohospital aeadmit dae tae taeampm daedis taedis taedisampm wardadmit dohsame doh toh tohampm arrivalmode ambcalld ambcallday ambcallmonth ambcallyear ambcallt ambcalltampm atscene atscnd atscnday atscnmonth atscnyear atscnt atscntampm frmscene frmscnd frmscnday frmscnmonth frmscnyear frmscnt frmscntampm sameadm hospd hospday hospmonth hospyear hospt hosptampm ward___1 ward___2 ward___3 ward___4 ward___5 ward___98 oward nohosp___1 nohosp___2 nohosp___3 nohosp___4 nohosp___5 nohosp___6 nohosp___98 nohosp___99 nohosp___88 nohosp___999 nohosp___9999 onohosp copyptm patient_management_complete edoa edoat eda ssym1 ssym2 ssym3 ssym4 hsym1 hsym2 hsym3 hsym4 hsym5 hsym6 hsym7 osym osym1 osym2 osym3 osym4 osym5 osym6 ssym1d ssym1day ssym1month ssym1year ssym2d ssym2day ssym2month ssym2year ssym3d ssym3day ssym3month ssym3year ssym4d ssym4day ssym4month ssym4year hsym1d hsym1day hsym1month hsym1year hsym1t hsym1tampm hsym2d hsym2day hsym2month hsym2year hsym3d hsym3day hsym3month hsym3year hsym4d hsym4day hsym4month hsym4year hsym5d hsym5day hsym5month hsym5year hsym6d hsym6day hsym6month hsym6year hsym7d hsym7day hsym7month hsym7year osymd osymday osymmonth osymyear sign1 sign2 sign3 sign4 sonset sday swalldate swalldday swalldmonth swalldyear cardmon nihss timi stype htype dxtype dstroke review reviewreason reviewer___1 reviewer___2 reviewer___3 reviewd edate fu1date edateyr edatemon edatemondash inhosp etime etimeampm age edateetime daetae ambcalldt onsetevetoae onsetambtoae cardiac cardiachosp resus sudd fname_eve lname_eve sex_eve slc_eve cstatus_eve eligible_eve fu1done copyeve f1vstatus_eve event_complete hxdoa hxdoat hxda pstroke pami pihd pcabg pcorangio pstrokeyr pamiyr dbchecked famstroke famami mumstroke dadstroke sibstroke mumami dadami sibami rfany smoker hcl af tia ccf htn diab hld alco drugs ovrf ovrf1 ovrf2 ovrf3 ovrf4 copyhx history_complete tdoa tdoat tda sysbp diasbp bpm bgunit bgmg bgmmol o2sat assess assess1 assess2 assess3 assess4 assess7 assess8 assess9 assess10 assess12 assess14 dieany dct decg dmri dcerangio dcarangio dcarus decho dctcorang dstress odie odie1 odie2 odie3 ct doct doctday doctmonth doctyear stime ctfeat ctinfarct ctsubhaem ctinthaem ckmbdone astdone tropdone tropcomm tropd tropdday tropdmonth tropdyear tropt troptampm troptype tropres trop1res trop2res ecg ecgd ecgdday ecgdmonth ecgdyear ecgt ecgtampm ecgs ischecg ecgantero ecgrv ecgant ecglat ecgpost ecginf ecgsep ecgnd oecg oecg1 oecg2 oecg3 oecg4 ecgfeat ecglbbb ecgaf ecgste ecgstd ecgpqw ecgtwv ecgnor ecgnorsin ecgomi ecgnstt ecglvh oecgfeat oecgfeat1 oecgfeat2 oecgfeat3 oecgfeat4 tiany tppv tnippv tdefib tcpr tmech tctcorang tpacetemp tcath tdhemi tvdrain oti oti1 oti2 oti3 copytests tests_complete dxdoa dxdoat dxda hcomp hdvt hpneu hulcer huti hfall hhydro hhaemo hoinfect hgibleed hccf hcpang haneur hhypo hblock hseizures hafib hcshock hinfarct hrenal hcarest ohcomp ohcomp1 ohcomp2 ohcomp3 ohcomp4 ohcomp5 absdxsame absdxs___1 absdxs___2 absdxs___3 absdxs___4 absdxs___5 absdxs___6 absdxs___7 absdxs___8 absdxs___99 absdxs___88 absdxs___999 absdxs___9999 absdxh___1 absdxh___2 absdxh___3 absdxh___4 absdxh___5 absdxh___6 absdxh___7 absdxh___8 absdxh___9 absdxh___10 absdxh___99 absdxh___88 absdxh___999 absdxh___9999 oabsdx oabsdx1 oabsdx2 oabsdx3 oabsdx4 copycomp complications_dx_complete rxdoa rxdoat rxda reperf repertype reperfd reperfdday reperfdmonth reperfdyear reperft reperftampm asp___1 asp___2 asp___3 asp___99 asp___88 asp___999 asp___9999 warf___1 warf___2 warf___3 warf___99 warf___88 warf___999 warf___9999 hep___1 hep___2 hep___3 hep___99 hep___88 hep___999 hep___9999 heplmw___1 heplmw___2 heplmw___3 heplmw___99 heplmw___88 heplmw___999 heplmw___9999 pla___1 pla___2 pla___3 pla___99 pla___88 pla___999 pla___9999 stat___1 stat___2 stat___3 stat___99 stat___88 stat___999 stat___9999 fibr___1 fibr___2 fibr___3 fibr___99 fibr___88 fibr___999 fibr___9999 ace___1 ace___2 ace___3 ace___99 ace___88 ace___999 ace___9999 arbs___1 arbs___2 arbs___3 arbs___99 arbs___88 arbs___999 arbs___9999 cors___1 cors___2 cors___3 cors___99 cors___88 cors___999 cors___9999 antih___1 antih___2 antih___3 antih___99 antih___88 antih___999 antih___9999 nimo___1 nimo___2 nimo___3 nimo___99 nimo___88 nimo___999 nimo___9999 antis___1 antis___2 antis___3 antis___99 antis___88 antis___999 antis___9999 ted___1 ted___2 ted___3 ted___99 ted___88 ted___999 ted___9999 beta___1 beta___2 beta___3 beta___99 beta___88 beta___999 beta___9999 bival___1 bival___2 bival___3 bival___99 bival___88 bival___999 bival___9999 aspdose aspd aspdday aspdmonth aspdyear aspt asptampm warfd warfdday warfdmonth warfdyear warft warftampm hepd hepdday hepdmonth hepdyear hept heptampm heplmwd heplmwdday heplmwdmonth heplmwdyear heplmwt heplmwtampm plad pladday pladmonth pladyear plat platampm statd statdday statdmonth statdyear statt stattampm fibrd fibrdday fibrdmonth fibrdyear fibrt fibrtampm aced acedday acedmonth acedyear acet acetampm arbsd arbsdday arbsdmonth arbsdyear arbst arbstampm corsd corsdday corsdmonth corsdyear corst corstampm antihd antihdday antihdmonth antihdyear antiht antihtampm nimod nimodday nimodmonth nimodyear nimot nimotampm antisd antisdday antisdmonth antisdyear antist antistampm tedd teddday teddmonth teddyear tedt tedtampm betad betadday betadmonth betadyear betat betatampm bivald bivaldday bivaldmonth bivaldyear bivalt bivaltampm copymeds edateyr_rx edatemondash_rx medications_complete ddoa ddoat dda vstatus disd disdday disdmonth disdyear dist distampm dod dodday dodmonth dodyear tod todampm pm codsame cods cod1 cod2 cod3 cod4 aspdis warfdis heplmwdis pladis statdis fibrdis acedis arbsdis corsdis antihdis nimodis antisdis teddis betadis bivaldis aspdosedis dissysbp disdiasbp dcomp ddvt dpneu dulcer duti dfall dhydro dhaemo doinfect dgibleed dccf dcpang daneur dhypo dblock dseizures dafib dcshock dinfarct drenal dcarest odcomp odcomp1 odcomp2 odcomp3 odcomp4 odcomp5 disdxsame disdxs___1 disdxs___2 disdxs___3 disdxs___4 disdxs___5 disdxs___6 disdxs___7 disdxs___8 disdxs___99 disdxs___88 disdxs___999 disdxs___9999 disdxh___1 disdxh___2 disdxh___3 disdxh___4 disdxh___5 disdxh___6 disdxh___7 disdxh___8 disdxh___9 disdxh___10 disdxh___99 disdxh___88 disdxh___999 disdxh___9999 odisdx odisdx1 odisdx2 odisdx3 odisdx4 reclass recdxs___1 recdxs___2 recdxs___3 recdxs___4 recdxs___5 recdxs___6 recdxs___7 recdxs___8 recdxs___99 recdxs___88 recdxs___999 recdxs___9999 recdxh___1 recdxh___2 recdxh___3 recdxh___4 recdxh___5 recdxh___6 recdxh___7 recdxh___8 recdxh___9 recdxh___10 recdxh___99 recdxh___88 recdxh___999 recdxh___9999 orecdx orecdx1 orecdx2 orecdx3 orecdx4 strunit sunitadmsame astrunitd astrunitdday astrunitdmonth astrunitdyear sunitdissame dstrunitd dstrunitdday dstrunitdmonth dstrunitdyear carunit cunitadmsame acarunitd acarunitdday acarunitdmonth acarunitdyear cunitdissame dcarunitd dcarunitdday dcarunitdmonth dcarunitdyear readmit readmitadm readmitdis readmitdays copydis discharge_complete fu1call1 fu1call2 fu1call3 fu1call4 fu1type fu1doa fu1da fu1oda edatefu1doadiff fu1day fu1oday fu1sicf fu1con fu1how f1vstatus fu1sit fu1osit fu1readm fu1los furesident ethnicity oethnic education mainwork employ prevemploy pstrsit pstrosit rankin rankin1 rankin2 rankin3 rankin4 rankin5 rankin6 famhxs famhxa mahxs dahxs sibhxs mahxa dahxa sibhxa smoke stopsmoke stopsmkday stopsmkmonth stopsmkyear stopsmokeage smokeage cig pipe cigar otobacco tobacmari marijuana cignum tobgram cigarnum spliffnum alcohol stopalc stopalcday stopalcmonth stopalcyear stopalcage alcage beernumnd spiritnumnd winenumnd beernum spiritnum winenum f1rankin f1rankin1 f1rankin2 f1rankin3 f1rankin4 f1rankin5 f1rankin6 copyfu1 day_fu_complete hcfr2020 hcfr2020_jan hcfr2020_feb hcfr2020_mar hcfr2020_apr hcfr2020_may hcfr2020_jun hcfr2020_jul hcfr2020_aug hcfr2020_sep hcfr2020_oct hcfr2020_nov hcfr2020_dec hcfr2021 hcfr2021_jan hcfr2021_feb hcfr2021_mar hcfr2021_apr hcfr2021_may hcfr2021_jun hcfr2021_jul hcfr2021_aug hcfr2021_sep hcfr2021_oct hcfr2021_nov hcfr2021_dec haspdash2020 haspdash2020_jan haspdash2020_feb haspdash2020_mar haspdash2020_apr haspdash2020_may haspdash2020_jun haspdash2020_jul haspdash2020_aug haspdash2020_sep haspdash2020_oct haspdash2020_nov haspdash2020_dec haspdash2021 haspdash2021_jan haspdash2021_feb haspdash2021_mar haspdash2021_apr haspdash2021_may haspdash2021_jun haspdash2021_jul haspdash2021_aug haspdash2021_sep haspdash2021_oct haspdash2021_nov haspdash2021_dec scfr2020 scfr2020_jan scfr2020_feb scfr2020_mar scfr2020_apr scfr2020_may scfr2020_jun scfr2020_jul scfr2020_aug scfr2020_sep scfr2020_oct scfr2020_nov scfr2020_dec scfr2021 scfr2021_jan scfr2021_feb scfr2021_mar scfr2021_apr scfr2021_may scfr2021_jun scfr2021_jul scfr2021_aug scfr2021_sep scfr2021_oct scfr2021_nov scfr2021_dec saspdash2020 saspdash2020_jan saspdash2020_feb saspdash2020_mar saspdash2020_apr saspdash2020_may saspdash2020_jun saspdash2020_jul saspdash2020_aug saspdash2020_sep saspdash2020_oct saspdash2020_nov saspdash2020_dec saspdash2021 saspdash2021_jan saspdash2021_feb saspdash2021_mar saspdash2021_apr saspdash2021_may saspdash2021_jun saspdash2021_jul saspdash2021_aug saspdash2021_sep saspdash2021_oct saspdash2021_nov saspdash2021_dec dashboards_complete rvpid rvpidcfabs rvcfadoa rvcfada ocfada rvflagd rvflag rvflag_old rvflag_new rvflagcorrect rvaction rvactiond rvactionda rvactionoda rvflagtot reviewing_complete using "`datapath'\version03\1-input\BNRCVDCORE_DATA_NOHDRS_2022-11-01_1211.csv", varnames(nonames)

label data "BNRCVDCORE_DATA_NOHDRS_2022-11-01_1211.csv"


label define tftype_ 1 "Casefinding (CF)" 2 "Abstracting (ABS)" 3 "Both CF and ABS" 98 "Other" 
label define tfsource_ 1 "QEH" 2 "Bay View" 3 "Sparman Clinic" 4 "Geriatric Hospital" 5 "District Hospital" 6 "Psychiatric Hospital" 7 "Emergency Clinic (SCMC, FMH, Coverley, etc)" 8 "Private Physician" 9 "Polyclinic" 10 "Nursing Homes" 11 "Member of Public" 12 "Office" 99 "ND" 
label define tfdepts___1_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___2_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___3_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___4_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___5_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___6_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___7_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___8_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___9_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___10_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___11_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___12_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___13_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___14_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___15_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___16_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___17_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___18_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___19_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___20_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___21_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___22_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___23_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___24_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___25_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___26_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___27_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___28_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___29_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___30_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___31_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___32_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___33_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___34_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___35_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___99_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___88_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___999_ 0 "Unchecked" 1 "Checked" 
label define tfdepts___9999_ 0 "Unchecked" 1 "Checked" 
label define tfwards___1_ 0 "Unchecked" 1 "Checked" 
label define tfwards___2_ 0 "Unchecked" 1 "Checked" 
label define tfwards___3_ 0 "Unchecked" 1 "Checked" 
label define tfwards___4_ 0 "Unchecked" 1 "Checked" 
label define tfwards___5_ 0 "Unchecked" 1 "Checked" 
label define tfwards___6_ 0 "Unchecked" 1 "Checked" 
label define tfwards___99_ 0 "Unchecked" 1 "Checked" 
label define tfwards___88_ 0 "Unchecked" 1 "Checked" 
label define tfwards___999_ 0 "Unchecked" 1 "Checked" 
label define tfwards___9999_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___1_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___2_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___3_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___4_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___5_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___99_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___88_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___999_ 0 "Unchecked" 1 "Checked" 
label define tfmedrec___9999_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___1_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___2_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___3_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___4_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___5_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___6_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___7_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___99_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___88_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___999_ 0 "Unchecked" 1 "Checked" 
label define tfdrec___9999_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___1_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___2_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___3_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___4_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___5_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___99_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___88_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___999_ 0 "Unchecked" 1 "Checked" 
label define tfaerec___9999_ 0 "Unchecked" 1 "Checked" 
label define tracking_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define sri_ 1 "Yes" 2 "No" 
label define evolution_ 1 "Yes" 2 "No" 
label define sourcetype_ 1 "Hospital" 2 "Community" 
label define firstnf_ 1 "A1" 2 "A2" 3 "A3/HDU" 4 "A5" 5 "A6" 6 "MICU" 7 "SICU" 8 "B5" 9 "B6" 10 "B7" 11 "B8" 12 "C5" 13 "C6" 14 "C7/PICU" 15 "C8" 16 "C9" 17 "C10/Stroke Unit" 18 "C12" 19 "Cardiac Unit" 20 "Med Rec" 21 "Death Rec" 22 "A&E" 23 "Bay View hospital" 24 "Sparman Clinic (4H)" 25 "Polyclinic" 26 "Private Physician" 27 "Emergency Clinic (e.g. SCMC, FMH, Coverley, etc)" 28 "Nursing Home" 29 "District Hospital" 30 "Geriatric Hospital" 31 "Psychiatric Hospital" 32 "Member of Public" 33 "Missing before 29-Sep-2020" 
label define cfsource___1_ 0 "Unchecked" 1 "Checked" 
label define cfsource___2_ 0 "Unchecked" 1 "Checked" 
label define cfsource___3_ 0 "Unchecked" 1 "Checked" 
label define cfsource___4_ 0 "Unchecked" 1 "Checked" 
label define cfsource___5_ 0 "Unchecked" 1 "Checked" 
label define cfsource___6_ 0 "Unchecked" 1 "Checked" 
label define cfsource___7_ 0 "Unchecked" 1 "Checked" 
label define cfsource___8_ 0 "Unchecked" 1 "Checked" 
label define cfsource___9_ 0 "Unchecked" 1 "Checked" 
label define cfsource___10_ 0 "Unchecked" 1 "Checked" 
label define cfsource___11_ 0 "Unchecked" 1 "Checked" 
label define cfsource___12_ 0 "Unchecked" 1 "Checked" 
label define cfsource___13_ 0 "Unchecked" 1 "Checked" 
label define cfsource___14_ 0 "Unchecked" 1 "Checked" 
label define cfsource___15_ 0 "Unchecked" 1 "Checked" 
label define cfsource___16_ 0 "Unchecked" 1 "Checked" 
label define cfsource___17_ 0 "Unchecked" 1 "Checked" 
label define cfsource___18_ 0 "Unchecked" 1 "Checked" 
label define cfsource___19_ 0 "Unchecked" 1 "Checked" 
label define cfsource___20_ 0 "Unchecked" 1 "Checked" 
label define cfsource___21_ 0 "Unchecked" 1 "Checked" 
label define cfsource___22_ 0 "Unchecked" 1 "Checked" 
label define cfsource___23_ 0 "Unchecked" 1 "Checked" 
label define cfsource___24_ 0 "Unchecked" 1 "Checked" 
label define cfsource___25_ 0 "Unchecked" 1 "Checked" 
label define cfsource___26_ 0 "Unchecked" 1 "Checked" 
label define cfsource___27_ 0 "Unchecked" 1 "Checked" 
label define cfsource___28_ 0 "Unchecked" 1 "Checked" 
label define cfsource___29_ 0 "Unchecked" 1 "Checked" 
label define cfsource___30_ 0 "Unchecked" 1 "Checked" 
label define cfsource___31_ 0 "Unchecked" 1 "Checked" 
label define cfsource___32_ 0 "Unchecked" 1 "Checked" 
label define retsource_ 1 "A1" 2 "A2" 3 "A3/HDU" 4 "A5" 5 "A6" 6 "MICU" 7 "SICU" 8 "B5" 9 "B6" 10 "B7" 11 "B8" 12 "C5" 13 "C6" 14 "C7" 15 "C8" 16 "C9" 17 "C10/Stroke Unit" 18 "C12" 19 "Cardiac Unit" 20 "Med Rec" 21 "Death Rec" 22 "A&E" 23 "Bay View" 24 "Sparman Clinic (Sparman/Heller)" 25 "District Hospital" 26 "Geriatric Hospital" 27 "Psychiatric Hospital" 28 "PP (D Corbin)" 29 "PP (S Marquez)" 30 "PP (S Moe/D Scantlebury)" 31 "PP (R Ishmael/J Ettedgui/R Henry)" 32 "PP (R Massay)" 33 "PP (K Goring)" 34 "Polyclinic (Black Rock)" 35 "Polyclinic (Edgar Cochrane)" 36 "Polyclinic (Glebe)" 37 "Polyclinic (Maurice Byer)" 38 "Polyclinic (Randal Phillips)" 39 "Polyclinic (St Philip)" 40 "Polyclinic (Warrens)" 41 "Polyclinic (Winston Scott)" 42 "SCMC" 43 "FMH" 44 "Coverley Medical Centre" 45 "Emergency Clinic (Other)" 46 "Nursing Home" 47 "Private Physician" 98 "Other" 
label define sex_ 1 "Female" 2 "Male" 
label define dobday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define dobmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define nrnmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define nrnday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define cfadmdatemondash_ 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" 
label define hstatus_ 1 "Discharged" 2 "On ward" 
label define slc_ 1 "Alive" 2 "Deceased" 
label define dlcday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 99 "99" 
label define dlcmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 99 "99" 
label define cfdodday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 99 "99" 
label define cfdodmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 99 "99" 
label define cstatus_ 1 "Eligible" 2 "Ineligible" 3 "Pending review" 
label define eligible_ 1 "Pending initial abstraction" 2 "Pending additional abstraction" 3 "Pending  discharge info" 4 "Pending 28-day follow-up" 5 "Pending 1-year follow-up" 7 "Re-admitted to A&E within 28 days" 8 "Re-admitted to ward within 28 days" 6 "Confirmed but NOT fully abstracted at closing off" 11 "Confirmed but NO discharge info at closing off" 9 "Completed" 10 "Re-abstraction" 
label define ineligible_ 1 "Abstracted (Ineligible)" 2 "Duplicate" 3 "Not Abstracted (Ineligible)" 4 "Not Abstracted (Irretrievable Notes)" 5 "Not Abstracted (Non-resident)" 6 "Not Abstracted (Year Closed)" 
label define pendrv_ 1 "Suspected" 2 "Registrar" 3 "Director" 4 "Clinical Director (Heart)" 5 "Clinical Director (Stroke)" 
label define duplicate_ 1 "Yes" 2 "No" 3 "Possible duplicate" 
label define dupcheck_ 1 "Yes" 2 "No" 
label define nfdb_ 1 "Yes" 2 "No" 
label define toabs_ 1 "Yes" 2 "No" 
label define copycf_ 1 "Yes" 2 "No" 
label define casefinding_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define mstatus_ 1 "Single" 2 "Married" 3 "Divorced/Separated" 4 "Widowed" 
label define resident_ 1 "Yes" 2 "No" 
label define citizen_ 1 "Yes" 2 "No" 
label define parish_ 1 "Christ Church" 2 "St Andrew" 3 "St George" 4 "St James" 5 "St John" 6 "St Joseph" 7 "St Lucy" 8 "St Michael" 9 "St Peter" 10 "St Phillip" 11 "St Thomas" 
label define sametel_ 1 "Yes" 2 "No" 
label define relation_ 1 "Spouse (Husband/Wife/Partner/Common-Law/Consort)" 2 "Child (Son/Daughter)" 3 "Sibling (Brother/Sister)" 4 "Parent (Father/Mother/Stepfather/Stepmother)" 5 "Extended family (grand-dad-mum-son-daughter/aunt/uncle/niece/nephew/cousin/in-laws)" 6 "Friend" 7 "Neighbour" 98 "Other" 
label define copydemo_ 1 "Yes" 2 "No" 
label define demographics_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define fmc_ 1 "Yes" 2 "No" 
label define fmcplace_ 1 "GP (general practitioner)" 2 "FMH emergency medical clinic" 3 "SCMC (sandy crest medical centre)" 4 "Coverley Medical Centre" 5 "Sparman Clinic" 6 "Geriatric Hospital" 7 "District Hospital" 8 "Psychiatric Hospital" 9 "Polyclinic" 10 "Nursing Homes" 11 "Within QEH, e.g. referred to A&E from Dialysis clinic" 98 "Other" 
label define fmcdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define fmcdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define fmcampm_ 1 "AM" 2 "PM" 
label define hospital_ 1 "QEH" 2 "Bay View" 98 "Other" 
label define aeadmit_ 1 "Yes" 2 "No" 
label define taeampm_ 1 "AM" 2 "PM" 
label define taedisampm_ 1 "AM" 2 "PM" 
label define wardadmit_ 1 "Yes" 2 "No" 
label define dohsame_ 1 "Yes" 2 "No" 
label define tohampm_ 1 "AM" 2 "PM" 
label define arrivalmode_ 1 "Ambulance" 2 "Private vehicle" 3 "Public transport" 
label define ambcallday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define ambcallmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define ambcalltampm_ 1 "AM" 2 "PM" 
label define atscene_ 1 "Yes" 2 "No" 
label define atscnday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define atscnmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define atscntampm_ 1 "AM" 2 "PM" 
label define frmscene_ 1 "Yes" 2 "No" 
label define frmscnday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define frmscnmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define frmscntampm_ 1 "AM" 2 "PM" 
label define sameadm_ 1 "Yes" 2 "No" 
label define hospday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hospmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hosptampm_ 1 "AM" 2 "PM" 
label define ward___1_ 0 "Unchecked" 1 "Checked" 
label define ward___2_ 0 "Unchecked" 1 "Checked" 
label define ward___3_ 0 "Unchecked" 1 "Checked" 
label define ward___4_ 0 "Unchecked" 1 "Checked" 
label define ward___5_ 0 "Unchecked" 1 "Checked" 
label define ward___98_ 0 "Unchecked" 1 "Checked" 
label define nohosp___1_ 0 "Unchecked" 1 "Checked" 
label define nohosp___2_ 0 "Unchecked" 1 "Checked" 
label define nohosp___3_ 0 "Unchecked" 1 "Checked" 
label define nohosp___4_ 0 "Unchecked" 1 "Checked" 
label define nohosp___5_ 0 "Unchecked" 1 "Checked" 
label define nohosp___6_ 0 "Unchecked" 1 "Checked" 
label define nohosp___98_ 0 "Unchecked" 1 "Checked" 
label define nohosp___99_ 0 "Unchecked" 1 "Checked" 
label define nohosp___88_ 0 "Unchecked" 1 "Checked" 
label define nohosp___999_ 0 "Unchecked" 1 "Checked" 
label define nohosp___9999_ 0 "Unchecked" 1 "Checked" 
label define copyptm_ 1 "Yes" 2 "No" 
label define patient_management_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define ssym1_ 1 "Yes" 2 "No" 
label define ssym2_ 1 "Yes" 2 "No" 
label define ssym3_ 1 "Yes" 2 "No" 
label define ssym4_ 1 "Yes" 2 "No" 
label define hsym1_ 1 "Yes" 2 "No" 
label define hsym2_ 1 "Yes" 2 "No" 
label define hsym3_ 1 "Yes" 2 "No" 
label define hsym4_ 1 "Yes" 2 "No" 
label define hsym5_ 1 "Yes" 2 "No" 
label define hsym6_ 1 "Yes" 2 "No" 
label define hsym7_ 1 "Yes" 2 "No" 
label define osym_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "None" 
label define ssym1day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define ssym1month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define ssym2day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define ssym2month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define ssym3day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define ssym3month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define ssym4day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define ssym4month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym1day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym1month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym1tampm_ 1 "AM" 2 "PM" 
label define hsym2day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym2month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym3day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym3month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym4day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym4month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym5day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym5month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym6day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym6month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define hsym7day_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hsym7month_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define osymday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define osymmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define sign1_ 1 "Yes" 2 "No" 
label define sign2_ 1 "Yes" 2 "No" 
label define sign3_ 1 "Yes" 2 "No" 
label define sign4_ 1 "Yes" 2 "No" 
label define sonset_ 1 "Yes" 2 "No" 
label define sday_ 1 "Yes" 2 "No" 
label define swalldday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define swalldmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define cardmon_ 1 "Yes" 2 "No" 
label define stype_ 1 "Ischaemic Stroke" 2 "Intracerebral Haemorrhage" 3 "Subarachnoid Haemorrhage" 4 "Unclassified Type" 
label define htype_ 1 "STEMI" 2 "NSTEMI" 3 "AMI (definite)" 4 "Sudden cardiac death" 5 "AMI (possible)" 
label define dxtype_ 1 "Clinical diagnosis alone" 2 "Confirmed by diagnostic techniques" 3 "Unconfirmed by diagnostic techniques" 4 "Medical autopsy" 
label define dstroke_ 1 "Definite" 2 "Possible" 
label define review_ 1 "Not for review" 2 "For review" 3 "Has been reviewed - eligible" 4 "Has been reviewed - INELIGIBLE" 
label define reviewer___1_ 0 "Unchecked" 1 "Checked" 
label define reviewer___2_ 0 "Unchecked" 1 "Checked" 
label define reviewer___3_ 0 "Unchecked" 1 "Checked" 
label define edatemondash_ 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" 
label define inhosp_ 1 "Yes" 2 "No" 
label define etimeampm_ 1 "AM" 2 "PM" 
label define cardiac_ 1 "Yes" 2 "No" 
label define cardiachosp_ 1 "Yes" 2 "No" 
label define resus_ 1 "Yes" 2 "No" 
label define sudd_ 1 "Yes" 2 "No" 
label define fu1done_ 1 "Yes" 2 "No" 
label define copyeve_ 1 "Yes" 2 "No" 
label define event_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define pstroke_ 1 "Yes" 2 "No" 
label define pami_ 1 "Yes" 2 "No" 
label define pihd_ 1 "Yes" 2 "No" 
label define pcabg_ 1 "Yes" 2 "No" 
label define pcorangio_ 1 "Yes" 2 "No" 
label define dbchecked_ 1 "Yes" 2 "No" 
label define famstroke_ 1 "Yes" 2 "No" 
label define famami_ 1 "Yes" 2 "No" 
label define mumstroke_ 1 "Yes" 2 "No" 
label define dadstroke_ 1 "Yes" 2 "No" 
label define sibstroke_ 1 "Yes" 2 "No" 
label define mumami_ 1 "Yes" 2 "No" 
label define dadami_ 1 "Yes" 2 "No" 
label define sibami_ 1 "Yes" 2 "No" 
label define rfany_ 1 "Yes" 2 "No" 
label define smoker_ 1 "Yes" 2 "No" 
label define hcl_ 1 "Yes" 2 "No" 
label define af_ 1 "Yes" 2 "No" 
label define tia_ 1 "Yes" 2 "No" 
label define ccf_ 1 "Yes" 2 "No" 
label define htn_ 1 "Yes" 2 "No" 
label define diab_ 1 "Yes" 2 "No" 
label define hld_ 1 "Yes" 2 "No" 
label define alco_ 1 "Yes" 2 "No" 
label define drugs_ 1 "Yes" 2 "No" 
label define ovrf_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define copyhx_ 1 "Yes" 2 "No" 
label define history_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define bgunit_ 1 "mg/dl" 2 "mmol/l" 3 "machine = high" 
label define assess_ 1 "Yes" 2 "No" 
label define assess1_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess2_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess3_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess4_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess7_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess8_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess9_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess10_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess12_ 1 "Yes" 2 "No" 3 "Referred for" 
label define assess14_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dieany_ 1 "Yes" 2 "No" 
label define dct_ 1 "Yes" 2 "No" 3 "Referred for" 
label define decg_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dmri_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dcerangio_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dcarangio_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dcarus_ 1 "Yes" 2 "No" 3 "Referred for" 
label define decho_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dctcorang_ 1 "Yes" 2 "No" 3 "Referred for" 
label define dstress_ 1 "Yes" 2 "No" 3 "Referred for" 
label define odie_ 1 "1" 2 "2" 3 "3" 4 "None" 
label define ct_ 1 "Yes" 2 "No" 
label define doctday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define doctmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define ctfeat_ 1 "Yes" 2 "No" 
label define ctinfarct_ 1 "Yes" 2 "No" 
label define ctsubhaem_ 1 "Yes" 2 "No" 
label define ctinthaem_ 1 "Yes" 2 "No" 
label define ckmbdone_ 1 "Yes" 2 "No" 
label define astdone_ 1 "Yes" 2 "No" 
label define tropdone_ 1 "Yes" 2 "No" 
label define tropcomm_ 1 "Yes" 2 "No" 
label define tropdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define tropdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define troptampm_ 1 "AM" 2 "PM" 
label define troptype_ 1 "Spot" 2 "Lab" 
label define tropres_ 1 "1" 2 "2" 3 "more than 2" 
label define ecg_ 1 "Yes" 2 "No" 
label define ecgdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define ecgdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define ecgtampm_ 1 "AM" 2 "PM" 
label define ecgs_ 1 "Yes" 2 "No" 
label define ischecg_ 1 "Yes" 2 "No" 
label define ecgantero_ 1 "Yes" 2 "No" 
label define ecgrv_ 1 "Yes" 2 "No" 
label define ecgant_ 1 "Yes" 2 "No" 
label define ecglat_ 1 "Yes" 2 "No" 
label define ecgpost_ 1 "Yes" 2 "No" 
label define ecginf_ 1 "Yes" 2 "No" 
label define ecgsep_ 1 "Yes" 2 "No" 
label define ecgnd_ 1 "Yes" 2 "No" 
label define oecg_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define ecgfeat_ 1 "Yes" 2 "No" 
label define ecglbbb_ 1 "Yes" 2 "No" 
label define ecgaf_ 1 "Yes" 2 "No" 
label define ecgste_ 1 "Yes" 2 "No" 
label define ecgstd_ 1 "Yes" 2 "No" 
label define ecgpqw_ 1 "Yes" 2 "No" 
label define ecgtwv_ 1 "Yes" 2 "No" 
label define ecgnor_ 1 "Yes" 2 "No" 
label define ecgnorsin_ 1 "Yes" 2 "No" 
label define ecgomi_ 1 "Yes" 2 "No" 
label define ecgnstt_ 1 "Yes" 2 "No" 
label define ecglvh_ 1 "Yes" 2 "No" 
label define oecgfeat_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define tiany_ 1 "Yes" 2 "No" 
label define tppv_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tnippv_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tdefib_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tcpr_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tmech_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tctcorang_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tpacetemp_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tcath_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tdhemi_ 1 "Yes" 2 "No" 3 "Referred for" 
label define tvdrain_ 1 "Yes" 2 "No" 3 "Referred for" 
label define oti_ 1 "1" 2 "2" 3 "3" 4 "None" 
label define copytests_ 1 "Yes" 2 "No" 
label define tests_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define hcomp_ 1 "Yes" 2 "No" 
label define hdvt_ 1 "Yes" 2 "No" 
label define hpneu_ 1 "Yes" 2 "No" 
label define hulcer_ 1 "Yes" 2 "No" 
label define huti_ 1 "Yes" 2 "No" 
label define hfall_ 1 "Yes" 2 "No" 
label define hhydro_ 1 "Yes" 2 "No" 
label define hhaemo_ 1 "Yes" 2 "No" 
label define hoinfect_ 1 "Yes" 2 "No" 
label define hgibleed_ 1 "Yes" 2 "No" 
label define hccf_ 1 "Yes" 2 "No" 
label define hcpang_ 1 "Yes" 2 "No" 
label define haneur_ 1 "Yes" 2 "No" 
label define hhypo_ 1 "Yes" 2 "No" 
label define hblock_ 1 "Yes" 2 "No" 
label define hseizures_ 1 "Yes" 2 "No" 
label define hafib_ 1 "Yes" 2 "No" 
label define hcshock_ 1 "Yes" 2 "No" 
label define hinfarct_ 1 "Yes" 2 "No" 
label define hrenal_ 1 "Yes" 2 "No" 
label define hcarest_ 1 "Yes" 2 "No" 
label define ohcomp_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "None" 
label define absdxsame_ 1 "Yes" 2 "No" 
label define absdxs___1_ 0 "Unchecked" 1 "Checked" 
label define absdxs___2_ 0 "Unchecked" 1 "Checked" 
label define absdxs___3_ 0 "Unchecked" 1 "Checked" 
label define absdxs___4_ 0 "Unchecked" 1 "Checked" 
label define absdxs___5_ 0 "Unchecked" 1 "Checked" 
label define absdxs___6_ 0 "Unchecked" 1 "Checked" 
label define absdxs___7_ 0 "Unchecked" 1 "Checked" 
label define absdxs___8_ 0 "Unchecked" 1 "Checked" 
label define absdxs___99_ 0 "Unchecked" 1 "Checked" 
label define absdxs___88_ 0 "Unchecked" 1 "Checked" 
label define absdxs___999_ 0 "Unchecked" 1 "Checked" 
label define absdxs___9999_ 0 "Unchecked" 1 "Checked" 
label define absdxh___1_ 0 "Unchecked" 1 "Checked" 
label define absdxh___2_ 0 "Unchecked" 1 "Checked" 
label define absdxh___3_ 0 "Unchecked" 1 "Checked" 
label define absdxh___4_ 0 "Unchecked" 1 "Checked" 
label define absdxh___5_ 0 "Unchecked" 1 "Checked" 
label define absdxh___6_ 0 "Unchecked" 1 "Checked" 
label define absdxh___7_ 0 "Unchecked" 1 "Checked" 
label define absdxh___8_ 0 "Unchecked" 1 "Checked" 
label define absdxh___9_ 0 "Unchecked" 1 "Checked" 
label define absdxh___10_ 0 "Unchecked" 1 "Checked" 
label define absdxh___99_ 0 "Unchecked" 1 "Checked" 
label define absdxh___88_ 0 "Unchecked" 1 "Checked" 
label define absdxh___999_ 0 "Unchecked" 1 "Checked" 
label define absdxh___9999_ 0 "Unchecked" 1 "Checked" 
label define oabsdx_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define copycomp_ 1 "Yes" 2 "No" 
label define complications_dx_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define reperf_ 1 "Yes" 2 "No" 
label define repertype_ 1 "Fibrinolytic therapy" 2 "Primary PCI" 3 "Rescue PCI" 
label define reperfdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define reperfdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define reperftampm_ 1 "AM" 2 "PM" 
label define asp___1_ 0 "Unchecked" 1 "Checked" 
label define asp___2_ 0 "Unchecked" 1 "Checked" 
label define asp___3_ 0 "Unchecked" 1 "Checked" 
label define asp___99_ 0 "Unchecked" 1 "Checked" 
label define asp___88_ 0 "Unchecked" 1 "Checked" 
label define asp___999_ 0 "Unchecked" 1 "Checked" 
label define asp___9999_ 0 "Unchecked" 1 "Checked" 
label define warf___1_ 0 "Unchecked" 1 "Checked" 
label define warf___2_ 0 "Unchecked" 1 "Checked" 
label define warf___3_ 0 "Unchecked" 1 "Checked" 
label define warf___99_ 0 "Unchecked" 1 "Checked" 
label define warf___88_ 0 "Unchecked" 1 "Checked" 
label define warf___999_ 0 "Unchecked" 1 "Checked" 
label define warf___9999_ 0 "Unchecked" 1 "Checked" 
label define hep___1_ 0 "Unchecked" 1 "Checked" 
label define hep___2_ 0 "Unchecked" 1 "Checked" 
label define hep___3_ 0 "Unchecked" 1 "Checked" 
label define hep___99_ 0 "Unchecked" 1 "Checked" 
label define hep___88_ 0 "Unchecked" 1 "Checked" 
label define hep___999_ 0 "Unchecked" 1 "Checked" 
label define hep___9999_ 0 "Unchecked" 1 "Checked" 
label define heplmw___1_ 0 "Unchecked" 1 "Checked" 
label define heplmw___2_ 0 "Unchecked" 1 "Checked" 
label define heplmw___3_ 0 "Unchecked" 1 "Checked" 
label define heplmw___99_ 0 "Unchecked" 1 "Checked" 
label define heplmw___88_ 0 "Unchecked" 1 "Checked" 
label define heplmw___999_ 0 "Unchecked" 1 "Checked" 
label define heplmw___9999_ 0 "Unchecked" 1 "Checked" 
label define pla___1_ 0 "Unchecked" 1 "Checked" 
label define pla___2_ 0 "Unchecked" 1 "Checked" 
label define pla___3_ 0 "Unchecked" 1 "Checked" 
label define pla___99_ 0 "Unchecked" 1 "Checked" 
label define pla___88_ 0 "Unchecked" 1 "Checked" 
label define pla___999_ 0 "Unchecked" 1 "Checked" 
label define pla___9999_ 0 "Unchecked" 1 "Checked" 
label define stat___1_ 0 "Unchecked" 1 "Checked" 
label define stat___2_ 0 "Unchecked" 1 "Checked" 
label define stat___3_ 0 "Unchecked" 1 "Checked" 
label define stat___99_ 0 "Unchecked" 1 "Checked" 
label define stat___88_ 0 "Unchecked" 1 "Checked" 
label define stat___999_ 0 "Unchecked" 1 "Checked" 
label define stat___9999_ 0 "Unchecked" 1 "Checked" 
label define fibr___1_ 0 "Unchecked" 1 "Checked" 
label define fibr___2_ 0 "Unchecked" 1 "Checked" 
label define fibr___3_ 0 "Unchecked" 1 "Checked" 
label define fibr___99_ 0 "Unchecked" 1 "Checked" 
label define fibr___88_ 0 "Unchecked" 1 "Checked" 
label define fibr___999_ 0 "Unchecked" 1 "Checked" 
label define fibr___9999_ 0 "Unchecked" 1 "Checked" 
label define ace___1_ 0 "Unchecked" 1 "Checked" 
label define ace___2_ 0 "Unchecked" 1 "Checked" 
label define ace___3_ 0 "Unchecked" 1 "Checked" 
label define ace___99_ 0 "Unchecked" 1 "Checked" 
label define ace___88_ 0 "Unchecked" 1 "Checked" 
label define ace___999_ 0 "Unchecked" 1 "Checked" 
label define ace___9999_ 0 "Unchecked" 1 "Checked" 
label define arbs___1_ 0 "Unchecked" 1 "Checked" 
label define arbs___2_ 0 "Unchecked" 1 "Checked" 
label define arbs___3_ 0 "Unchecked" 1 "Checked" 
label define arbs___99_ 0 "Unchecked" 1 "Checked" 
label define arbs___88_ 0 "Unchecked" 1 "Checked" 
label define arbs___999_ 0 "Unchecked" 1 "Checked" 
label define arbs___9999_ 0 "Unchecked" 1 "Checked" 
label define cors___1_ 0 "Unchecked" 1 "Checked" 
label define cors___2_ 0 "Unchecked" 1 "Checked" 
label define cors___3_ 0 "Unchecked" 1 "Checked" 
label define cors___99_ 0 "Unchecked" 1 "Checked" 
label define cors___88_ 0 "Unchecked" 1 "Checked" 
label define cors___999_ 0 "Unchecked" 1 "Checked" 
label define cors___9999_ 0 "Unchecked" 1 "Checked" 
label define antih___1_ 0 "Unchecked" 1 "Checked" 
label define antih___2_ 0 "Unchecked" 1 "Checked" 
label define antih___3_ 0 "Unchecked" 1 "Checked" 
label define antih___99_ 0 "Unchecked" 1 "Checked" 
label define antih___88_ 0 "Unchecked" 1 "Checked" 
label define antih___999_ 0 "Unchecked" 1 "Checked" 
label define antih___9999_ 0 "Unchecked" 1 "Checked" 
label define nimo___1_ 0 "Unchecked" 1 "Checked" 
label define nimo___2_ 0 "Unchecked" 1 "Checked" 
label define nimo___3_ 0 "Unchecked" 1 "Checked" 
label define nimo___99_ 0 "Unchecked" 1 "Checked" 
label define nimo___88_ 0 "Unchecked" 1 "Checked" 
label define nimo___999_ 0 "Unchecked" 1 "Checked" 
label define nimo___9999_ 0 "Unchecked" 1 "Checked" 
label define antis___1_ 0 "Unchecked" 1 "Checked" 
label define antis___2_ 0 "Unchecked" 1 "Checked" 
label define antis___3_ 0 "Unchecked" 1 "Checked" 
label define antis___99_ 0 "Unchecked" 1 "Checked" 
label define antis___88_ 0 "Unchecked" 1 "Checked" 
label define antis___999_ 0 "Unchecked" 1 "Checked" 
label define antis___9999_ 0 "Unchecked" 1 "Checked" 
label define ted___1_ 0 "Unchecked" 1 "Checked" 
label define ted___2_ 0 "Unchecked" 1 "Checked" 
label define ted___3_ 0 "Unchecked" 1 "Checked" 
label define ted___99_ 0 "Unchecked" 1 "Checked" 
label define ted___88_ 0 "Unchecked" 1 "Checked" 
label define ted___999_ 0 "Unchecked" 1 "Checked" 
label define ted___9999_ 0 "Unchecked" 1 "Checked" 
label define beta___1_ 0 "Unchecked" 1 "Checked" 
label define beta___2_ 0 "Unchecked" 1 "Checked" 
label define beta___3_ 0 "Unchecked" 1 "Checked" 
label define beta___99_ 0 "Unchecked" 1 "Checked" 
label define beta___88_ 0 "Unchecked" 1 "Checked" 
label define beta___999_ 0 "Unchecked" 1 "Checked" 
label define beta___9999_ 0 "Unchecked" 1 "Checked" 
label define bival___1_ 0 "Unchecked" 1 "Checked" 
label define bival___2_ 0 "Unchecked" 1 "Checked" 
label define bival___3_ 0 "Unchecked" 1 "Checked" 
label define bival___99_ 0 "Unchecked" 1 "Checked" 
label define bival___88_ 0 "Unchecked" 1 "Checked" 
label define bival___999_ 0 "Unchecked" 1 "Checked" 
label define bival___9999_ 0 "Unchecked" 1 "Checked" 
label define aspdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define aspdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define asptampm_ 1 "AM" 2 "PM" 
label define warfdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define warfdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define warftampm_ 1 "AM" 2 "PM" 
label define hepdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define hepdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define heptampm_ 1 "AM" 2 "PM" 
label define heplmwdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define heplmwdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define heplmwtampm_ 1 "AM" 2 "PM" 
label define pladday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define pladmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define platampm_ 1 "AM" 2 "PM" 
label define statdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define statdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define stattampm_ 1 "AM" 2 "PM" 
label define fibrdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define fibrdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define fibrtampm_ 1 "AM" 2 "PM" 
label define acedday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define acedmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define acetampm_ 1 "AM" 2 "PM" 
label define arbsdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define arbsdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define arbstampm_ 1 "AM" 2 "PM" 
label define corsdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define corsdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define corstampm_ 1 "AM" 2 "PM" 
label define antihdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define antihdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define antihtampm_ 1 "AM" 2 "PM" 
label define nimodday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define nimodmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define nimotampm_ 1 "AM" 2 "PM" 
label define antisdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define antisdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define antistampm_ 1 "AM" 2 "PM" 
label define teddday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define teddmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define tedtampm_ 1 "AM" 2 "PM" 
label define betadday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define betadmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define betatampm_ 1 "AM" 2 "PM" 
label define bivaldday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define bivaldmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define bivaltampm_ 1 "AM" 2 "PM" 
label define copymeds_ 1 "Yes" 2 "No" 
label define edatemondash_rx_ 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" 
label define medications_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define vstatus_ 1 "Alive" 2 "Deceased" 
label define disdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define disdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define distampm_ 1 "AM" 2 "PM" 
label define dodday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define dodmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define todampm_ 1 "AM" 2 "PM" 
label define pm_ 1 "Yes" 2 "No" 
label define codsame_ 1 "Yes" 2 "No" 
label define cods_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define aspdis_ 1 "at discharge" 
label define warfdis_ 1 "at discharge" 
label define heplmwdis_ 1 "at discharge" 
label define pladis_ 1 "at discharge" 
label define statdis_ 1 "at discharge" 
label define fibrdis_ 1 "at discharge" 
label define acedis_ 1 "at discharge" 
label define arbsdis_ 1 "at discharge" 
label define corsdis_ 1 "at discharge" 
label define antihdis_ 1 "at discharge" 
label define nimodis_ 1 "at discharge" 
label define antisdis_ 1 "at discharge" 
label define teddis_ 1 "at discharge" 
label define betadis_ 1 "at discharge" 
label define bivaldis_ 1 "at discharge" 
label define dcomp_ 1 "Yes" 2 "No" 3 "No new complications since those on Complications form" 
label define ddvt_ 1 "Yes" 2 "No" 
label define dpneu_ 1 "Yes" 2 "No" 
label define dulcer_ 1 "Yes" 2 "No" 
label define duti_ 1 "Yes" 2 "No" 
label define dfall_ 1 "Yes" 2 "No" 
label define dhydro_ 1 "Yes" 2 "No" 
label define dhaemo_ 1 "Yes" 2 "No" 
label define doinfect_ 1 "Yes" 2 "No" 
label define dgibleed_ 1 "Yes" 2 "No" 
label define dccf_ 1 "Yes" 2 "No" 
label define dcpang_ 1 "Yes" 2 "No" 
label define daneur_ 1 "Yes" 2 "No" 
label define dhypo_ 1 "Yes" 2 "No" 
label define dblock_ 1 "Yes" 2 "No" 
label define dseizures_ 1 "Yes" 2 "No" 
label define dafib_ 1 "Yes" 2 "No" 
label define dcshock_ 1 "Yes" 2 "No" 
label define dinfarct_ 1 "Yes" 2 "No" 
label define drenal_ 1 "Yes" 2 "No" 
label define dcarest_ 1 "Yes" 2 "No" 
label define odcomp_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "None" 
label define disdxsame_ 1 "Yes" 2 "No" 
label define disdxs___1_ 0 "Unchecked" 1 "Checked" 
label define disdxs___2_ 0 "Unchecked" 1 "Checked" 
label define disdxs___3_ 0 "Unchecked" 1 "Checked" 
label define disdxs___4_ 0 "Unchecked" 1 "Checked" 
label define disdxs___5_ 0 "Unchecked" 1 "Checked" 
label define disdxs___6_ 0 "Unchecked" 1 "Checked" 
label define disdxs___7_ 0 "Unchecked" 1 "Checked" 
label define disdxs___8_ 0 "Unchecked" 1 "Checked" 
label define disdxs___99_ 0 "Unchecked" 1 "Checked" 
label define disdxs___88_ 0 "Unchecked" 1 "Checked" 
label define disdxs___999_ 0 "Unchecked" 1 "Checked" 
label define disdxs___9999_ 0 "Unchecked" 1 "Checked" 
label define disdxh___1_ 0 "Unchecked" 1 "Checked" 
label define disdxh___2_ 0 "Unchecked" 1 "Checked" 
label define disdxh___3_ 0 "Unchecked" 1 "Checked" 
label define disdxh___4_ 0 "Unchecked" 1 "Checked" 
label define disdxh___5_ 0 "Unchecked" 1 "Checked" 
label define disdxh___6_ 0 "Unchecked" 1 "Checked" 
label define disdxh___7_ 0 "Unchecked" 1 "Checked" 
label define disdxh___8_ 0 "Unchecked" 1 "Checked" 
label define disdxh___9_ 0 "Unchecked" 1 "Checked" 
label define disdxh___10_ 0 "Unchecked" 1 "Checked" 
label define disdxh___99_ 0 "Unchecked" 1 "Checked" 
label define disdxh___88_ 0 "Unchecked" 1 "Checked" 
label define disdxh___999_ 0 "Unchecked" 1 "Checked" 
label define disdxh___9999_ 0 "Unchecked" 1 "Checked" 
label define odisdx_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define reclass_ 1 "Yes" 2 "No" 
label define recdxs___1_ 0 "Unchecked" 1 "Checked" 
label define recdxs___2_ 0 "Unchecked" 1 "Checked" 
label define recdxs___3_ 0 "Unchecked" 1 "Checked" 
label define recdxs___4_ 0 "Unchecked" 1 "Checked" 
label define recdxs___5_ 0 "Unchecked" 1 "Checked" 
label define recdxs___6_ 0 "Unchecked" 1 "Checked" 
label define recdxs___7_ 0 "Unchecked" 1 "Checked" 
label define recdxs___8_ 0 "Unchecked" 1 "Checked" 
label define recdxs___99_ 0 "Unchecked" 1 "Checked" 
label define recdxs___88_ 0 "Unchecked" 1 "Checked" 
label define recdxs___999_ 0 "Unchecked" 1 "Checked" 
label define recdxs___9999_ 0 "Unchecked" 1 "Checked" 
label define recdxh___1_ 0 "Unchecked" 1 "Checked" 
label define recdxh___2_ 0 "Unchecked" 1 "Checked" 
label define recdxh___3_ 0 "Unchecked" 1 "Checked" 
label define recdxh___4_ 0 "Unchecked" 1 "Checked" 
label define recdxh___5_ 0 "Unchecked" 1 "Checked" 
label define recdxh___6_ 0 "Unchecked" 1 "Checked" 
label define recdxh___7_ 0 "Unchecked" 1 "Checked" 
label define recdxh___8_ 0 "Unchecked" 1 "Checked" 
label define recdxh___9_ 0 "Unchecked" 1 "Checked" 
label define recdxh___10_ 0 "Unchecked" 1 "Checked" 
label define recdxh___99_ 0 "Unchecked" 1 "Checked" 
label define recdxh___88_ 0 "Unchecked" 1 "Checked" 
label define recdxh___999_ 0 "Unchecked" 1 "Checked" 
label define recdxh___9999_ 0 "Unchecked" 1 "Checked" 
label define orecdx_ 1 "1" 2 "2" 3 "3" 4 "4" 5 "None" 
label define strunit_ 1 "Yes" 2 "No" 
label define sunitadmsame_ 1 "Yes" 2 "No" 
label define astrunitdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define astrunitdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define sunitdissame_ 1 "Yes" 2 "No" 
label define dstrunitdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define dstrunitdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define carunit_ 1 "Yes" 2 "No" 
label define cunitadmsame_ 1 "Yes" 2 "No" 
label define acarunitdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define acarunitdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define cunitdissame_ 1 "Yes" 2 "No" 
label define dcarunitdday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define dcarunitdmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define readmit_ 1 "Yes" 2 "No" 
label define copydis_ 1 "Yes" 2 "No" 
label define discharge_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define fu1type_ 1 "Yes" 2 "No" 
label define fu1da_ 18 "AROB" 19 "MF" 20 "NR" 98 "Other" 
label define fu1day_ 1 "Yes-patient interviewed at 28 days +/- 2 days" 2 "No-other reason (please specify)" 3 "No-pt deceased before or on F/U date" 
label define fu1sicf_ 1 "Yes" 2 "No-patient/representative refused" 3 "No-patient incapable and no representative found" 4 "No-contact information missing or incorrect" 5 "No-no contact made after 4 attempts" 
label define fu1con_ 1 "Patient" 2 "Representative" 
label define fu1how_ 1 "Face-to-face interview" 2 "Telephone interview" 
label define f1vstatus_ 1 "Alive" 2 "Deceased" 
label define fu1sit_ 1 "Own Home" 2 "Relatives Home" 3 "Still acute in hospital" 4 "Nursing Home" 5 "District/Geriatric Hospital" 6 "Overseas (for treatment)" 7 "Readmitted to hospital" 8 "Refused" 98 "Other (please specify)" 
label define fu1readm_ 1 "Yes" 2 "No" 3 "Refused" 
label define furesident_ 1 "Less than 6 months" 2 "More than 6 months" 3 "Refused" 
label define ethnicity_ 1 "Black" 2 "White" 3 "Chinese" 4 "East Indian" 5 "Arab" 6 "Mixed" 7 "Refused" 98 "Other (please specify)" 
label define education_ 1 "No formal schooling" 2 "Less than primary school" 3 "Primary school completed" 4 "Secondary school completed" 5 "College/university completed" 6 "Post graduate degree" 7 "Refused" 
label define mainwork_ 1 "Government employee" 2 "Non-Government employee" 3 "Self-employed" 4 "Non-paid" 5 "Student" 6 "Homemaker" 7 "Retired" 8 "Unemployed" 9 "Unknown employed" 10 "Refused" 
label define pstrsit_ 1 "Own Home" 2 "Relatives Home" 3 "Still acute in hospital" 4 "Nursing Home" 5 "District/Geriatric Hospital" 6 "Overseas (for treatment)" 7 "Readmitted to hospital" 8 "Refused" 98 "Other (please specify)" 
label define rankin_ 1 "unable to answer" 2 "refused to answer" 
label define rankin1_ 1 "Yes" 2 "No" 
label define rankin2_ 1 "Yes" 2 "No" 
label define rankin3_ 1 "Yes" 2 "No" 
label define rankin4_ 1 "Yes" 2 "No" 
label define rankin5_ 1 "Yes" 2 "No" 
label define rankin6_ 1 "Yes" 2 "No" 
label define famhxs_ 1 "Yes" 2 "No" 3 "Refused" 
label define famhxa_ 1 "Yes" 2 "No" 3 "Refused" 
label define mahxs_ 1 "Yes" 2 "No" 
label define dahxs_ 1 "Yes" 2 "No" 
label define sibhxs_ 1 "Yes" 2 "No" 
label define mahxa_ 1 "Yes" 2 "No" 
label define dahxa_ 1 "Yes" 2 "No" 
label define sibhxa_ 1 "Yes" 2 "No" 
label define smoke_ 1 "Yes - active smoker" 2 "Yes - daily smoker" 3 "Yes - stopped" 4 "No - never smoked" 5 "Refused" 
label define stopsmkday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define stopsmkmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define cig_ 1 "Yes" 2 "No" 
label define pipe_ 1 "Yes" 2 "No" 
label define cigar_ 1 "Yes" 2 "No" 
label define otobacco_ 1 "Yes" 2 "No" 
label define tobacmari_ 1 "Yes" 2 "No" 
label define marijuana_ 1 "Yes" 2 "No" 
label define alcohol_ 1 "Yes - more than one drink per week" 2 "Yes - less than one drink per week" 3 "Yes - stopped" 4 "No - never" 5 "Refused" 
label define stopalcday_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 
label define stopalcmonth_ 01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" 07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" 
label define beernumnd_ 1 "Yes" 2 "No" 
label define spiritnumnd_ 1 "Yes" 2 "No" 
label define winenumnd_ 1 "Yes" 2 "No" 
label define f1rankin_ 1 "unable to answer" 2 "refused to answer" 
label define f1rankin1_ 1 "Yes" 2 "No" 
label define f1rankin2_ 1 "Yes" 2 "No" 
label define f1rankin3_ 1 "Yes" 2 "No" 
label define f1rankin4_ 1 "Yes" 2 "No" 
label define f1rankin5_ 1 "Yes" 2 "No" 
label define f1rankin6_ 1 "Yes" 2 "No" 
label define copyfu1_ 1 "Yes" 2 "No" 
label define day_fu_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define dashboards_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label define rvcfada_ 18 "AROB" 19 "MF" 20 "NR" 98 "Other" 
label define rvflagcorrect_ 1 "Yes" 2 "No" 
label define rvaction_ 1 "Corrected" 2 "No correction needed" 
label define rvactionda_ 18 "AROB" 19 "MF" 20 "NR" 98 "Other" 
label define reviewing_complete_ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
label values tftype tftype_
label values tfsource tfsource_
label values tfdepts___1 tfdepts___1_
label values tfdepts___2 tfdepts___2_
label values tfdepts___3 tfdepts___3_
label values tfdepts___4 tfdepts___4_
label values tfdepts___5 tfdepts___5_
label values tfdepts___6 tfdepts___6_
label values tfdepts___7 tfdepts___7_
label values tfdepts___8 tfdepts___8_
label values tfdepts___9 tfdepts___9_
label values tfdepts___10 tfdepts___10_
label values tfdepts___11 tfdepts___11_
label values tfdepts___12 tfdepts___12_
label values tfdepts___13 tfdepts___13_
label values tfdepts___14 tfdepts___14_
label values tfdepts___15 tfdepts___15_
label values tfdepts___16 tfdepts___16_
label values tfdepts___17 tfdepts___17_
label values tfdepts___18 tfdepts___18_
label values tfdepts___19 tfdepts___19_
label values tfdepts___20 tfdepts___20_
label values tfdepts___21 tfdepts___21_
label values tfdepts___22 tfdepts___22_
label values tfdepts___23 tfdepts___23_
label values tfdepts___24 tfdepts___24_
label values tfdepts___25 tfdepts___25_
label values tfdepts___26 tfdepts___26_
label values tfdepts___27 tfdepts___27_
label values tfdepts___28 tfdepts___28_
label values tfdepts___29 tfdepts___29_
label values tfdepts___30 tfdepts___30_
label values tfdepts___31 tfdepts___31_
label values tfdepts___32 tfdepts___32_
label values tfdepts___33 tfdepts___33_
label values tfdepts___34 tfdepts___34_
label values tfdepts___35 tfdepts___35_
label values tfdepts___99 tfdepts___99_
label values tfdepts___88 tfdepts___88_
label values tfdepts___999 tfdepts___999_
label values tfdepts___9999 tfdepts___9999_
label values tfwards___1 tfwards___1_
label values tfwards___2 tfwards___2_
label values tfwards___3 tfwards___3_
label values tfwards___4 tfwards___4_
label values tfwards___5 tfwards___5_
label values tfwards___6 tfwards___6_
label values tfwards___99 tfwards___99_
label values tfwards___88 tfwards___88_
label values tfwards___999 tfwards___999_
label values tfwards___9999 tfwards___9999_
label values tfmedrec___1 tfmedrec___1_
label values tfmedrec___2 tfmedrec___2_
label values tfmedrec___3 tfmedrec___3_
label values tfmedrec___4 tfmedrec___4_
label values tfmedrec___5 tfmedrec___5_
label values tfmedrec___99 tfmedrec___99_
label values tfmedrec___88 tfmedrec___88_
label values tfmedrec___999 tfmedrec___999_
label values tfmedrec___9999 tfmedrec___9999_
label values tfdrec___1 tfdrec___1_
label values tfdrec___2 tfdrec___2_
label values tfdrec___3 tfdrec___3_
label values tfdrec___4 tfdrec___4_
label values tfdrec___5 tfdrec___5_
label values tfdrec___6 tfdrec___6_
label values tfdrec___7 tfdrec___7_
label values tfdrec___99 tfdrec___99_
label values tfdrec___88 tfdrec___88_
label values tfdrec___999 tfdrec___999_
label values tfdrec___9999 tfdrec___9999_
label values tfaerec___1 tfaerec___1_
label values tfaerec___2 tfaerec___2_
label values tfaerec___3 tfaerec___3_
label values tfaerec___4 tfaerec___4_
label values tfaerec___5 tfaerec___5_
label values tfaerec___99 tfaerec___99_
label values tfaerec___88 tfaerec___88_
label values tfaerec___999 tfaerec___999_
label values tfaerec___9999 tfaerec___9999_
label values tracking_complete tracking_complete_
label values sri sri_
label values evolution evolution_
label values sourcetype sourcetype_
label values firstnf firstnf_
label values cfsource___1 cfsource___1_
label values cfsource___2 cfsource___2_
label values cfsource___3 cfsource___3_
label values cfsource___4 cfsource___4_
label values cfsource___5 cfsource___5_
label values cfsource___6 cfsource___6_
label values cfsource___7 cfsource___7_
label values cfsource___8 cfsource___8_
label values cfsource___9 cfsource___9_
label values cfsource___10 cfsource___10_
label values cfsource___11 cfsource___11_
label values cfsource___12 cfsource___12_
label values cfsource___13 cfsource___13_
label values cfsource___14 cfsource___14_
label values cfsource___15 cfsource___15_
label values cfsource___16 cfsource___16_
label values cfsource___17 cfsource___17_
label values cfsource___18 cfsource___18_
label values cfsource___19 cfsource___19_
label values cfsource___20 cfsource___20_
label values cfsource___21 cfsource___21_
label values cfsource___22 cfsource___22_
label values cfsource___23 cfsource___23_
label values cfsource___24 cfsource___24_
label values cfsource___25 cfsource___25_
label values cfsource___26 cfsource___26_
label values cfsource___27 cfsource___27_
label values cfsource___28 cfsource___28_
label values cfsource___29 cfsource___29_
label values cfsource___30 cfsource___30_
label values cfsource___31 cfsource___31_
label values cfsource___32 cfsource___32_
label values retsource retsource_
label values sex sex_
label values dobday dobday_
label values dobmonth dobmonth_
label values nrnmonth nrnmonth_
label values nrnday nrnday_
label values cfadmdatemondash cfadmdatemondash_
label values hstatus hstatus_
label values slc slc_
label values dlcday dlcday_
label values dlcmonth dlcmonth_
label values cfdodday cfdodday_
label values cfdodmonth cfdodmonth_
label values cstatus cstatus_
label values eligible eligible_
label values ineligible ineligible_
label values pendrv pendrv_
label values duplicate duplicate_
label values dupcheck dupcheck_
label values nfdb nfdb_
label values toabs toabs_
label values copycf copycf_
label values casefinding_complete casefinding_complete_
label values mstatus mstatus_
label values resident resident_
label values citizen citizen_
label values parish parish_
label values sametel sametel_
label values relation relation_
label values copydemo copydemo_
label values demographics_complete demographics_complete_
label values fmc fmc_
label values fmcplace fmcplace_
label values fmcdday fmcdday_
label values fmcdmonth fmcdmonth_
label values fmcampm fmcampm_
label values hospital hospital_
label values aeadmit aeadmit_
label values taeampm taeampm_
label values taedisampm taedisampm_
label values wardadmit wardadmit_
label values dohsame dohsame_
label values tohampm tohampm_
label values arrivalmode arrivalmode_
label values ambcallday ambcallday_
label values ambcallmonth ambcallmonth_
label values ambcalltampm ambcalltampm_
label values atscene atscene_
label values atscnday atscnday_
label values atscnmonth atscnmonth_
label values atscntampm atscntampm_
label values frmscene frmscene_
label values frmscnday frmscnday_
label values frmscnmonth frmscnmonth_
label values frmscntampm frmscntampm_
label values sameadm sameadm_
label values hospday hospday_
label values hospmonth hospmonth_
label values hosptampm hosptampm_
label values ward___1 ward___1_
label values ward___2 ward___2_
label values ward___3 ward___3_
label values ward___4 ward___4_
label values ward___5 ward___5_
label values ward___98 ward___98_
label values nohosp___1 nohosp___1_
label values nohosp___2 nohosp___2_
label values nohosp___3 nohosp___3_
label values nohosp___4 nohosp___4_
label values nohosp___5 nohosp___5_
label values nohosp___6 nohosp___6_
label values nohosp___98 nohosp___98_
label values nohosp___99 nohosp___99_
label values nohosp___88 nohosp___88_
label values nohosp___999 nohosp___999_
label values nohosp___9999 nohosp___9999_
label values copyptm copyptm_
label values patient_management_complete patient_management_complete_
label values ssym1 ssym1_
label values ssym2 ssym2_
label values ssym3 ssym3_
label values ssym4 ssym4_
label values hsym1 hsym1_
label values hsym2 hsym2_
label values hsym3 hsym3_
label values hsym4 hsym4_
label values hsym5 hsym5_
label values hsym6 hsym6_
label values hsym7 hsym7_
label values osym osym_
label values ssym1day ssym1day_
label values ssym1month ssym1month_
label values ssym2day ssym2day_
label values ssym2month ssym2month_
label values ssym3day ssym3day_
label values ssym3month ssym3month_
label values ssym4day ssym4day_
label values ssym4month ssym4month_
label values hsym1day hsym1day_
label values hsym1month hsym1month_
label values hsym1tampm hsym1tampm_
label values hsym2day hsym2day_
label values hsym2month hsym2month_
label values hsym3day hsym3day_
label values hsym3month hsym3month_
label values hsym4day hsym4day_
label values hsym4month hsym4month_
label values hsym5day hsym5day_
label values hsym5month hsym5month_
label values hsym6day hsym6day_
label values hsym6month hsym6month_
label values hsym7day hsym7day_
label values hsym7month hsym7month_
label values osymday osymday_
label values osymmonth osymmonth_
label values sign1 sign1_
label values sign2 sign2_
label values sign3 sign3_
label values sign4 sign4_
label values sonset sonset_
label values sday sday_
label values swalldday swalldday_
label values swalldmonth swalldmonth_
label values cardmon cardmon_
label values stype stype_
label values htype htype_
label values dxtype dxtype_
label values dstroke dstroke_
label values review review_
label values reviewer___1 reviewer___1_
label values reviewer___2 reviewer___2_
label values reviewer___3 reviewer___3_
label values edatemondash edatemondash_
label values inhosp inhosp_
label values etimeampm etimeampm_
label values cardiac cardiac_
label values cardiachosp cardiachosp_
label values resus resus_
label values sudd sudd_
label values fu1done fu1done_
label values copyeve copyeve_
label values event_complete event_complete_
label values pstroke pstroke_
label values pami pami_
label values pihd pihd_
label values pcabg pcabg_
label values pcorangio pcorangio_
label values dbchecked dbchecked_
label values famstroke famstroke_
label values famami famami_
label values mumstroke mumstroke_
label values dadstroke dadstroke_
label values sibstroke sibstroke_
label values mumami mumami_
label values dadami dadami_
label values sibami sibami_
label values rfany rfany_
label values smoker smoker_
label values hcl hcl_
label values af af_
label values tia tia_
label values ccf ccf_
label values htn htn_
label values diab diab_
label values hld hld_
label values alco alco_
label values drugs drugs_
label values ovrf ovrf_
label values copyhx copyhx_
label values history_complete history_complete_
label values bgunit bgunit_
label values assess assess_
label values assess1 assess1_
label values assess2 assess2_
label values assess3 assess3_
label values assess4 assess4_
label values assess7 assess7_
label values assess8 assess8_
label values assess9 assess9_
label values assess10 assess10_
label values assess12 assess12_
label values assess14 assess14_
label values dieany dieany_
label values dct dct_
label values decg decg_
label values dmri dmri_
label values dcerangio dcerangio_
label values dcarangio dcarangio_
label values dcarus dcarus_
label values decho decho_
label values dctcorang dctcorang_
label values dstress dstress_
label values odie odie_
label values ct ct_
label values doctday doctday_
label values doctmonth doctmonth_
label values ctfeat ctfeat_
label values ctinfarct ctinfarct_
label values ctsubhaem ctsubhaem_
label values ctinthaem ctinthaem_
label values ckmbdone ckmbdone_
label values astdone astdone_
label values tropdone tropdone_
label values tropcomm tropcomm_
label values tropdday tropdday_
label values tropdmonth tropdmonth_
label values troptampm troptampm_
label values troptype troptype_
label values tropres tropres_
label values ecg ecg_
label values ecgdday ecgdday_
label values ecgdmonth ecgdmonth_
label values ecgtampm ecgtampm_
label values ecgs ecgs_
label values ischecg ischecg_
label values ecgantero ecgantero_
label values ecgrv ecgrv_
label values ecgant ecgant_
label values ecglat ecglat_
label values ecgpost ecgpost_
label values ecginf ecginf_
label values ecgsep ecgsep_
label values ecgnd ecgnd_
label values oecg oecg_
label values ecgfeat ecgfeat_
label values ecglbbb ecglbbb_
label values ecgaf ecgaf_
label values ecgste ecgste_
label values ecgstd ecgstd_
label values ecgpqw ecgpqw_
label values ecgtwv ecgtwv_
label values ecgnor ecgnor_
label values ecgnorsin ecgnorsin_
label values ecgomi ecgomi_
label values ecgnstt ecgnstt_
label values ecglvh ecglvh_
label values oecgfeat oecgfeat_
label values tiany tiany_
label values tppv tppv_
label values tnippv tnippv_
label values tdefib tdefib_
label values tcpr tcpr_
label values tmech tmech_
label values tctcorang tctcorang_
label values tpacetemp tpacetemp_
label values tcath tcath_
label values tdhemi tdhemi_
label values tvdrain tvdrain_
label values oti oti_
label values copytests copytests_
label values tests_complete tests_complete_
label values hcomp hcomp_
label values hdvt hdvt_
label values hpneu hpneu_
label values hulcer hulcer_
label values huti huti_
label values hfall hfall_
label values hhydro hhydro_
label values hhaemo hhaemo_
label values hoinfect hoinfect_
label values hgibleed hgibleed_
label values hccf hccf_
label values hcpang hcpang_
label values haneur haneur_
label values hhypo hhypo_
label values hblock hblock_
label values hseizures hseizures_
label values hafib hafib_
label values hcshock hcshock_
label values hinfarct hinfarct_
label values hrenal hrenal_
label values hcarest hcarest_
label values ohcomp ohcomp_
label values absdxsame absdxsame_
label values absdxs___1 absdxs___1_
label values absdxs___2 absdxs___2_
label values absdxs___3 absdxs___3_
label values absdxs___4 absdxs___4_
label values absdxs___5 absdxs___5_
label values absdxs___6 absdxs___6_
label values absdxs___7 absdxs___7_
label values absdxs___8 absdxs___8_
label values absdxs___99 absdxs___99_
label values absdxs___88 absdxs___88_
label values absdxs___999 absdxs___999_
label values absdxs___9999 absdxs___9999_
label values absdxh___1 absdxh___1_
label values absdxh___2 absdxh___2_
label values absdxh___3 absdxh___3_
label values absdxh___4 absdxh___4_
label values absdxh___5 absdxh___5_
label values absdxh___6 absdxh___6_
label values absdxh___7 absdxh___7_
label values absdxh___8 absdxh___8_
label values absdxh___9 absdxh___9_
label values absdxh___10 absdxh___10_
label values absdxh___99 absdxh___99_
label values absdxh___88 absdxh___88_
label values absdxh___999 absdxh___999_
label values absdxh___9999 absdxh___9999_
label values oabsdx oabsdx_
label values copycomp copycomp_
label values complications_dx_complete complications_dx_complete_
label values reperf reperf_
label values repertype repertype_
label values reperfdday reperfdday_
label values reperfdmonth reperfdmonth_
label values reperftampm reperftampm_
label values asp___1 asp___1_
label values asp___2 asp___2_
label values asp___3 asp___3_
label values asp___99 asp___99_
label values asp___88 asp___88_
label values asp___999 asp___999_
label values asp___9999 asp___9999_
label values warf___1 warf___1_
label values warf___2 warf___2_
label values warf___3 warf___3_
label values warf___99 warf___99_
label values warf___88 warf___88_
label values warf___999 warf___999_
label values warf___9999 warf___9999_
label values hep___1 hep___1_
label values hep___2 hep___2_
label values hep___3 hep___3_
label values hep___99 hep___99_
label values hep___88 hep___88_
label values hep___999 hep___999_
label values hep___9999 hep___9999_
label values heplmw___1 heplmw___1_
label values heplmw___2 heplmw___2_
label values heplmw___3 heplmw___3_
label values heplmw___99 heplmw___99_
label values heplmw___88 heplmw___88_
label values heplmw___999 heplmw___999_
label values heplmw___9999 heplmw___9999_
label values pla___1 pla___1_
label values pla___2 pla___2_
label values pla___3 pla___3_
label values pla___99 pla___99_
label values pla___88 pla___88_
label values pla___999 pla___999_
label values pla___9999 pla___9999_
label values stat___1 stat___1_
label values stat___2 stat___2_
label values stat___3 stat___3_
label values stat___99 stat___99_
label values stat___88 stat___88_
label values stat___999 stat___999_
label values stat___9999 stat___9999_
label values fibr___1 fibr___1_
label values fibr___2 fibr___2_
label values fibr___3 fibr___3_
label values fibr___99 fibr___99_
label values fibr___88 fibr___88_
label values fibr___999 fibr___999_
label values fibr___9999 fibr___9999_
label values ace___1 ace___1_
label values ace___2 ace___2_
label values ace___3 ace___3_
label values ace___99 ace___99_
label values ace___88 ace___88_
label values ace___999 ace___999_
label values ace___9999 ace___9999_
label values arbs___1 arbs___1_
label values arbs___2 arbs___2_
label values arbs___3 arbs___3_
label values arbs___99 arbs___99_
label values arbs___88 arbs___88_
label values arbs___999 arbs___999_
label values arbs___9999 arbs___9999_
label values cors___1 cors___1_
label values cors___2 cors___2_
label values cors___3 cors___3_
label values cors___99 cors___99_
label values cors___88 cors___88_
label values cors___999 cors___999_
label values cors___9999 cors___9999_
label values antih___1 antih___1_
label values antih___2 antih___2_
label values antih___3 antih___3_
label values antih___99 antih___99_
label values antih___88 antih___88_
label values antih___999 antih___999_
label values antih___9999 antih___9999_
label values nimo___1 nimo___1_
label values nimo___2 nimo___2_
label values nimo___3 nimo___3_
label values nimo___99 nimo___99_
label values nimo___88 nimo___88_
label values nimo___999 nimo___999_
label values nimo___9999 nimo___9999_
label values antis___1 antis___1_
label values antis___2 antis___2_
label values antis___3 antis___3_
label values antis___99 antis___99_
label values antis___88 antis___88_
label values antis___999 antis___999_
label values antis___9999 antis___9999_
label values ted___1 ted___1_
label values ted___2 ted___2_
label values ted___3 ted___3_
label values ted___99 ted___99_
label values ted___88 ted___88_
label values ted___999 ted___999_
label values ted___9999 ted___9999_
label values beta___1 beta___1_
label values beta___2 beta___2_
label values beta___3 beta___3_
label values beta___99 beta___99_
label values beta___88 beta___88_
label values beta___999 beta___999_
label values beta___9999 beta___9999_
label values bival___1 bival___1_
label values bival___2 bival___2_
label values bival___3 bival___3_
label values bival___99 bival___99_
label values bival___88 bival___88_
label values bival___999 bival___999_
label values bival___9999 bival___9999_
label values aspdday aspdday_
label values aspdmonth aspdmonth_
label values asptampm asptampm_
label values warfdday warfdday_
label values warfdmonth warfdmonth_
label values warftampm warftampm_
label values hepdday hepdday_
label values hepdmonth hepdmonth_
label values heptampm heptampm_
label values heplmwdday heplmwdday_
label values heplmwdmonth heplmwdmonth_
label values heplmwtampm heplmwtampm_
label values pladday pladday_
label values pladmonth pladmonth_
label values platampm platampm_
label values statdday statdday_
label values statdmonth statdmonth_
label values stattampm stattampm_
label values fibrdday fibrdday_
label values fibrdmonth fibrdmonth_
label values fibrtampm fibrtampm_
label values acedday acedday_
label values acedmonth acedmonth_
label values acetampm acetampm_
label values arbsdday arbsdday_
label values arbsdmonth arbsdmonth_
label values arbstampm arbstampm_
label values corsdday corsdday_
label values corsdmonth corsdmonth_
label values corstampm corstampm_
label values antihdday antihdday_
label values antihdmonth antihdmonth_
label values antihtampm antihtampm_
label values nimodday nimodday_
label values nimodmonth nimodmonth_
label values nimotampm nimotampm_
label values antisdday antisdday_
label values antisdmonth antisdmonth_
label values antistampm antistampm_
label values teddday teddday_
label values teddmonth teddmonth_
label values tedtampm tedtampm_
label values betadday betadday_
label values betadmonth betadmonth_
label values betatampm betatampm_
label values bivaldday bivaldday_
label values bivaldmonth bivaldmonth_
label values bivaltampm bivaltampm_
label values copymeds copymeds_
label values edatemondash_rx edatemondash_rx_
label values medications_complete medications_complete_
label values vstatus vstatus_
label values disdday disdday_
label values disdmonth disdmonth_
label values distampm distampm_
label values dodday dodday_
label values dodmonth dodmonth_
label values todampm todampm_
label values pm pm_
label values codsame codsame_
label values cods cods_
label values aspdis aspdis_
label values warfdis warfdis_
label values heplmwdis heplmwdis_
label values pladis pladis_
label values statdis statdis_
label values fibrdis fibrdis_
label values acedis acedis_
label values arbsdis arbsdis_
label values corsdis corsdis_
label values antihdis antihdis_
label values nimodis nimodis_
label values antisdis antisdis_
label values teddis teddis_
label values betadis betadis_
label values bivaldis bivaldis_
label values dcomp dcomp_
label values ddvt ddvt_
label values dpneu dpneu_
label values dulcer dulcer_
label values duti duti_
label values dfall dfall_
label values dhydro dhydro_
label values dhaemo dhaemo_
label values doinfect doinfect_
label values dgibleed dgibleed_
label values dccf dccf_
label values dcpang dcpang_
label values daneur daneur_
label values dhypo dhypo_
label values dblock dblock_
label values dseizures dseizures_
label values dafib dafib_
label values dcshock dcshock_
label values dinfarct dinfarct_
label values drenal drenal_
label values dcarest dcarest_
label values odcomp odcomp_
label values disdxsame disdxsame_
label values disdxs___1 disdxs___1_
label values disdxs___2 disdxs___2_
label values disdxs___3 disdxs___3_
label values disdxs___4 disdxs___4_
label values disdxs___5 disdxs___5_
label values disdxs___6 disdxs___6_
label values disdxs___7 disdxs___7_
label values disdxs___8 disdxs___8_
label values disdxs___99 disdxs___99_
label values disdxs___88 disdxs___88_
label values disdxs___999 disdxs___999_
label values disdxs___9999 disdxs___9999_
label values disdxh___1 disdxh___1_
label values disdxh___2 disdxh___2_
label values disdxh___3 disdxh___3_
label values disdxh___4 disdxh___4_
label values disdxh___5 disdxh___5_
label values disdxh___6 disdxh___6_
label values disdxh___7 disdxh___7_
label values disdxh___8 disdxh___8_
label values disdxh___9 disdxh___9_
label values disdxh___10 disdxh___10_
label values disdxh___99 disdxh___99_
label values disdxh___88 disdxh___88_
label values disdxh___999 disdxh___999_
label values disdxh___9999 disdxh___9999_
label values odisdx odisdx_
label values reclass reclass_
label values recdxs___1 recdxs___1_
label values recdxs___2 recdxs___2_
label values recdxs___3 recdxs___3_
label values recdxs___4 recdxs___4_
label values recdxs___5 recdxs___5_
label values recdxs___6 recdxs___6_
label values recdxs___7 recdxs___7_
label values recdxs___8 recdxs___8_
label values recdxs___99 recdxs___99_
label values recdxs___88 recdxs___88_
label values recdxs___999 recdxs___999_
label values recdxs___9999 recdxs___9999_
label values recdxh___1 recdxh___1_
label values recdxh___2 recdxh___2_
label values recdxh___3 recdxh___3_
label values recdxh___4 recdxh___4_
label values recdxh___5 recdxh___5_
label values recdxh___6 recdxh___6_
label values recdxh___7 recdxh___7_
label values recdxh___8 recdxh___8_
label values recdxh___9 recdxh___9_
label values recdxh___10 recdxh___10_
label values recdxh___99 recdxh___99_
label values recdxh___88 recdxh___88_
label values recdxh___999 recdxh___999_
label values recdxh___9999 recdxh___9999_
label values orecdx orecdx_
label values strunit strunit_
label values sunitadmsame sunitadmsame_
label values astrunitdday astrunitdday_
label values astrunitdmonth astrunitdmonth_
label values sunitdissame sunitdissame_
label values dstrunitdday dstrunitdday_
label values dstrunitdmonth dstrunitdmonth_
label values carunit carunit_
label values cunitadmsame cunitadmsame_
label values acarunitdday acarunitdday_
label values acarunitdmonth acarunitdmonth_
label values cunitdissame cunitdissame_
label values dcarunitdday dcarunitdday_
label values dcarunitdmonth dcarunitdmonth_
label values readmit readmit_
label values copydis copydis_
label values discharge_complete discharge_complete_
label values fu1type fu1type_
label values fu1da fu1da_
label values fu1day fu1day_
label values fu1sicf fu1sicf_
label values fu1con fu1con_
label values fu1how fu1how_
label values f1vstatus f1vstatus_
label values fu1sit fu1sit_
label values fu1readm fu1readm_
label values furesident furesident_
label values ethnicity ethnicity_
label values education education_
label values mainwork mainwork_
label values pstrsit pstrsit_
label values rankin rankin_
label values rankin1 rankin1_
label values rankin2 rankin2_
label values rankin3 rankin3_
label values rankin4 rankin4_
label values rankin5 rankin5_
label values rankin6 rankin6_
label values famhxs famhxs_
label values famhxa famhxa_
label values mahxs mahxs_
label values dahxs dahxs_
label values sibhxs sibhxs_
label values mahxa mahxa_
label values dahxa dahxa_
label values sibhxa sibhxa_
label values smoke smoke_
label values stopsmkday stopsmkday_
label values stopsmkmonth stopsmkmonth_
label values cig cig_
label values pipe pipe_
label values cigar cigar_
label values otobacco otobacco_
label values tobacmari tobacmari_
label values marijuana marijuana_
label values alcohol alcohol_
label values stopalcday stopalcday_
label values stopalcmonth stopalcmonth_
label values beernumnd beernumnd_
label values spiritnumnd spiritnumnd_
label values winenumnd winenumnd_
label values f1rankin f1rankin_
label values f1rankin1 f1rankin1_
label values f1rankin2 f1rankin2_
label values f1rankin3 f1rankin3_
label values f1rankin4 f1rankin4_
label values f1rankin5 f1rankin5_
label values f1rankin6 f1rankin6_
label values copyfu1 copyfu1_
label values day_fu_complete day_fu_complete_
label values dashboards_complete dashboards_complete_
label values rvcfada rvcfada_
label values rvflagcorrect rvflagcorrect_
label values rvaction rvaction_
label values rvactionda rvactionda_
label values reviewing_complete reviewing_complete_



tostring tfdoastart, replace
gen _date_ = date(tfdoastart,"YMD")
drop tfdoastart
rename _date_ tfdoastart
format tfdoastart %dM_d,_CY

tostring tfdoaend, replace
gen _date_ = date(tfdoaend,"YMD")
drop tfdoaend
rename _date_ tfdoaend
format tfdoaend %dM_d,_CY

tostring cfdoa, replace
gen _date_ = date(cfdoa,"YMD")
drop cfdoa
rename _date_ cfdoa
format cfdoa %dM_d,_CY

tostring dob, replace
gen _date_ = date(dob,"YMD")
drop dob
rename _date_ dob
format dob %dM_d,_CY

tostring cfadmdate, replace
gen _date_ = date(cfadmdate,"YMD")
drop cfadmdate
rename _date_ cfadmdate
format cfadmdate %dM_d,_CY

tostring dlc, replace
gen _date_ = date(dlc,"YMD")
drop dlc
rename _date_ dlc
format dlc %dM_d,_CY

tostring cfdod, replace
gen _date_ = date(cfdod,"YMD")
drop cfdod
rename _date_ cfdod
format cfdod %dM_d,_CY

tostring requestdate1, replace
gen _date_ = date(requestdate1,"YMD")
drop requestdate1
rename _date_ requestdate1
format requestdate1 %dM_d,_CY

tostring requestdate2, replace
gen _date_ = date(requestdate2,"YMD")
drop requestdate2
rename _date_ requestdate2
format requestdate2 %dM_d,_CY

tostring requestdate3, replace
gen _date_ = date(requestdate3,"YMD")
drop requestdate3
rename _date_ requestdate3
format requestdate3 %dM_d,_CY

tostring adoa, replace
gen _date_ = date(adoa,"YMD")
drop adoa
rename _date_ adoa
format adoa %dM_d,_CY

tostring ptmdoa, replace
gen _date_ = date(ptmdoa,"YMD")
drop ptmdoa
rename _date_ ptmdoa
format ptmdoa %dM_d,_CY

tostring fmcdate, replace
gen _date_ = date(fmcdate,"YMD")
drop fmcdate
rename _date_ fmcdate
format fmcdate %dM_d,_CY

tostring dae, replace
gen _date_ = date(dae,"YMD")
drop dae
rename _date_ dae
format dae %dM_d,_CY

tostring daedis, replace
gen _date_ = date(daedis,"YMD")
drop daedis
rename _date_ daedis
format daedis %dM_d,_CY

tostring doh, replace
gen _date_ = date(doh,"YMD")
drop doh
rename _date_ doh
format doh %dM_d,_CY

tostring ambcalld, replace
gen _date_ = date(ambcalld,"YMD")
drop ambcalld
rename _date_ ambcalld
format ambcalld %dM_d,_CY

tostring atscnd, replace
gen _date_ = date(atscnd,"YMD")
drop atscnd
rename _date_ atscnd
format atscnd %dM_d,_CY

tostring frmscnd, replace
gen _date_ = date(frmscnd,"YMD")
drop frmscnd
rename _date_ frmscnd
format frmscnd %dM_d,_CY

tostring hospd, replace
gen _date_ = date(hospd,"YMD")
drop hospd
rename _date_ hospd
format hospd %dM_d,_CY

tostring edoa, replace
gen _date_ = date(edoa,"YMD")
drop edoa
rename _date_ edoa
format edoa %dM_d,_CY

tostring ssym1d, replace
gen _date_ = date(ssym1d,"YMD")
drop ssym1d
rename _date_ ssym1d
format ssym1d %dM_d,_CY

tostring ssym2d, replace
gen _date_ = date(ssym2d,"YMD")
drop ssym2d
rename _date_ ssym2d
format ssym2d %dM_d,_CY

tostring ssym3d, replace
gen _date_ = date(ssym3d,"YMD")
drop ssym3d
rename _date_ ssym3d
format ssym3d %dM_d,_CY

tostring ssym4d, replace
gen _date_ = date(ssym4d,"YMD")
drop ssym4d
rename _date_ ssym4d
format ssym4d %dM_d,_CY

tostring hsym1d, replace
gen _date_ = date(hsym1d,"YMD")
drop hsym1d
rename _date_ hsym1d
format hsym1d %dM_d,_CY

tostring hsym2d, replace
gen _date_ = date(hsym2d,"YMD")
drop hsym2d
rename _date_ hsym2d
format hsym2d %dM_d,_CY

tostring hsym3d, replace
gen _date_ = date(hsym3d,"YMD")
drop hsym3d
rename _date_ hsym3d
format hsym3d %dM_d,_CY

tostring hsym4d, replace
gen _date_ = date(hsym4d,"YMD")
drop hsym4d
rename _date_ hsym4d
format hsym4d %dM_d,_CY

tostring hsym5d, replace
gen _date_ = date(hsym5d,"YMD")
drop hsym5d
rename _date_ hsym5d
format hsym5d %dM_d,_CY

tostring hsym6d, replace
gen _date_ = date(hsym6d,"YMD")
drop hsym6d
rename _date_ hsym6d
format hsym6d %dM_d,_CY

tostring hsym7d, replace
gen _date_ = date(hsym7d,"YMD")
drop hsym7d
rename _date_ hsym7d
format hsym7d %dM_d,_CY

tostring osymd, replace
gen _date_ = date(osymd,"YMD")
drop osymd
rename _date_ osymd
format osymd %dM_d,_CY

tostring swalldate, replace
gen _date_ = date(swalldate,"YMD")
drop swalldate
rename _date_ swalldate
format swalldate %dM_d,_CY

tostring reviewd, replace
gen _date_ = date(reviewd,"YMD")
drop reviewd
rename _date_ reviewd
format reviewd %dM_d,_CY

tostring edate, replace
gen _date_ = date(edate,"YMD")
drop edate
rename _date_ edate
format edate %dM_d,_CY

tostring fu1date, replace
gen _date_ = date(fu1date,"YMD")
drop fu1date
rename _date_ fu1date
format fu1date %dM_d,_CY

tostring edateetime, replace
gen double _temp_ = Clock(edateetime,"YMDhm")
drop edateetime
rename _temp_ edateetime
format edateetime %tCMonth_dd,_CCYY_HH:MM

tostring daetae, replace
gen double _temp_ = Clock(daetae,"YMDhm")
drop daetae
rename _temp_ daetae
format daetae %tCMonth_dd,_CCYY_HH:MM

tostring ambcalldt, replace
gen double _temp_ = Clock(ambcalldt,"YMDhm")
drop ambcalldt
rename _temp_ ambcalldt
format ambcalldt %tCMonth_dd,_CCYY_HH:MM

tostring hxdoa, replace
gen _date_ = date(hxdoa,"YMD")
drop hxdoa
rename _date_ hxdoa
format hxdoa %dM_d,_CY

tostring tdoa, replace
gen _date_ = date(tdoa,"YMD")
drop tdoa
rename _date_ tdoa
format tdoa %dM_d,_CY

tostring doct, replace
gen _date_ = date(doct,"YMD")
drop doct
rename _date_ doct
format doct %dM_d,_CY

tostring tropd, replace
gen _date_ = date(tropd,"YMD")
drop tropd
rename _date_ tropd
format tropd %dM_d,_CY

tostring ecgd, replace
gen _date_ = date(ecgd,"YMD")
drop ecgd
rename _date_ ecgd
format ecgd %dM_d,_CY

tostring dxdoa, replace
gen _date_ = date(dxdoa,"YMD")
drop dxdoa
rename _date_ dxdoa
format dxdoa %dM_d,_CY

tostring rxdoa, replace
gen _date_ = date(rxdoa,"YMD")
drop rxdoa
rename _date_ rxdoa
format rxdoa %dM_d,_CY

tostring reperfd, replace
gen _date_ = date(reperfd,"YMD")
drop reperfd
rename _date_ reperfd
format reperfd %dM_d,_CY

tostring aspd, replace
gen _date_ = date(aspd,"YMD")
drop aspd
rename _date_ aspd
format aspd %dM_d,_CY

tostring warfd, replace
gen _date_ = date(warfd,"YMD")
drop warfd
rename _date_ warfd
format warfd %dM_d,_CY

tostring hepd, replace
gen _date_ = date(hepd,"YMD")
drop hepd
rename _date_ hepd
format hepd %dM_d,_CY

tostring heplmwd, replace
gen _date_ = date(heplmwd,"YMD")
drop heplmwd
rename _date_ heplmwd
format heplmwd %dM_d,_CY

tostring plad, replace
gen _date_ = date(plad,"YMD")
drop plad
rename _date_ plad
format plad %dM_d,_CY

tostring statd, replace
gen _date_ = date(statd,"YMD")
drop statd
rename _date_ statd
format statd %dM_d,_CY

tostring fibrd, replace
gen _date_ = date(fibrd,"YMD")
drop fibrd
rename _date_ fibrd
format fibrd %dM_d,_CY

tostring aced, replace
gen _date_ = date(aced,"YMD")
drop aced
rename _date_ aced
format aced %dM_d,_CY

tostring arbsd, replace
gen _date_ = date(arbsd,"YMD")
drop arbsd
rename _date_ arbsd
format arbsd %dM_d,_CY

tostring corsd, replace
gen _date_ = date(corsd,"YMD")
drop corsd
rename _date_ corsd
format corsd %dM_d,_CY

tostring antihd, replace
gen _date_ = date(antihd,"YMD")
drop antihd
rename _date_ antihd
format antihd %dM_d,_CY

tostring nimod, replace
gen _date_ = date(nimod,"YMD")
drop nimod
rename _date_ nimod
format nimod %dM_d,_CY

tostring antisd, replace
gen _date_ = date(antisd,"YMD")
drop antisd
rename _date_ antisd
format antisd %dM_d,_CY

tostring tedd, replace
gen _date_ = date(tedd,"YMD")
drop tedd
rename _date_ tedd
format tedd %dM_d,_CY

tostring betad, replace
gen _date_ = date(betad,"YMD")
drop betad
rename _date_ betad
format betad %dM_d,_CY

tostring bivald, replace
gen _date_ = date(bivald,"YMD")
drop bivald
rename _date_ bivald
format bivald %dM_d,_CY

tostring ddoa, replace
gen _date_ = date(ddoa,"YMD")
drop ddoa
rename _date_ ddoa
format ddoa %dM_d,_CY

tostring disd, replace
gen _date_ = date(disd,"YMD")
drop disd
rename _date_ disd
format disd %dM_d,_CY

tostring dod, replace
gen _date_ = date(dod,"YMD")
drop dod
rename _date_ dod
format dod %dM_d,_CY

tostring astrunitd, replace
gen _date_ = date(astrunitd,"YMD")
drop astrunitd
rename _date_ astrunitd
format astrunitd %dM_d,_CY

tostring dstrunitd, replace
gen _date_ = date(dstrunitd,"YMD")
drop dstrunitd
rename _date_ dstrunitd
format dstrunitd %dM_d,_CY

tostring acarunitd, replace
gen _date_ = date(acarunitd,"YMD")
drop acarunitd
rename _date_ acarunitd
format acarunitd %dM_d,_CY

tostring dcarunitd, replace
gen _date_ = date(dcarunitd,"YMD")
drop dcarunitd
rename _date_ dcarunitd
format dcarunitd %dM_d,_CY

tostring readmitadm, replace
gen _date_ = date(readmitadm,"YMD")
drop readmitadm
rename _date_ readmitadm
format readmitadm %dM_d,_CY

tostring readmitdis, replace
gen _date_ = date(readmitdis,"YMD")
drop readmitdis
rename _date_ readmitdis
format readmitdis %dM_d,_CY

tostring fu1call1, replace
gen _date_ = date(fu1call1,"YMD")
drop fu1call1
rename _date_ fu1call1
format fu1call1 %dM_d,_CY

tostring fu1call2, replace
gen _date_ = date(fu1call2,"YMD")
drop fu1call2
rename _date_ fu1call2
format fu1call2 %dM_d,_CY

tostring fu1call3, replace
gen _date_ = date(fu1call3,"YMD")
drop fu1call3
rename _date_ fu1call3
format fu1call3 %dM_d,_CY

tostring fu1call4, replace
gen _date_ = date(fu1call4,"YMD")
drop fu1call4
rename _date_ fu1call4
format fu1call4 %dM_d,_CY

tostring fu1doa, replace
gen double _temp_ = Clock(fu1doa,"YMDhm")
drop fu1doa
rename _temp_ fu1doa
format fu1doa %tCMonth_dd,_CCYY_HH:MM

tostring stopsmoke, replace
gen _date_ = date(stopsmoke,"YMD")
drop stopsmoke
rename _date_ stopsmoke
format stopsmoke %dM_d,_CY

tostring stopalc, replace
gen _date_ = date(stopalc,"YMD")
drop stopalc
rename _date_ stopalc
format stopalc %dM_d,_CY

tostring rvcfadoa, replace
gen double _temp_ = Clock(rvcfadoa,"YMDhm")
drop rvcfadoa
rename _temp_ rvcfadoa
format rvcfadoa %tCMonth_dd,_CCYY_HH:MM

tostring rvflagd, replace
gen double _temp_ = Clock(rvflagd,"YMDhm")
drop rvflagd
rename _temp_ rvflagd
format rvflagd %tCMonth_dd,_CCYY_HH:MM

tostring rvactiond, replace
gen double _temp_ = Clock(rvactiond,"YMDhm")
drop rvactiond
rename _temp_ rvactiond
format rvactiond %tCMonth_dd,_CCYY_HH:MM

label variable record_id "Record ID"
label variable redcap_event_name "Event Name"
label variable redcap_repeat_instrument "Repeat Instrument"
label variable redcap_repeat_instance "Repeat Instance"
label variable redcap_data_access_group "Data Access Group"
label variable tfdoastart "TF Date - start"
label variable tfdoatstart "TF Time - start"
label variable tfda "TF DA"
label variable tftype "TF Type"
label variable otftype "Please specify other TF type"
label variable tfsource "TF Source"
label variable cfupdate "# CF records updated today"
label variable recid "RecordIDs (CF and/or ABS)"
label variable absdone "# ABS records done today"
label variable disdone "# DIS (discharge) records done today"
label variable tfdepts___1 "Wards/Departments visited (choice=A1)"
label variable tfdepts___2 "Wards/Departments visited (choice=A2)"
label variable tfdepts___3 "Wards/Departments visited (choice=A3)"
label variable tfdepts___4 "Wards/Departments visited (choice=A4)"
label variable tfdepts___5 "Wards/Departments visited (choice=A5)"
label variable tfdepts___6 "Wards/Departments visited (choice=A6)"
label variable tfdepts___7 "Wards/Departments visited (choice=B1)"
label variable tfdepts___8 "Wards/Departments visited (choice=B2)"
label variable tfdepts___9 "Wards/Departments visited (choice=B3)"
label variable tfdepts___10 "Wards/Departments visited (choice=B4)"
label variable tfdepts___11 "Wards/Departments visited (choice=B5)"
label variable tfdepts___12 "Wards/Departments visited (choice=B6)"
label variable tfdepts___13 "Wards/Departments visited (choice=B7)"
label variable tfdepts___14 "Wards/Departments visited (choice=B8)"
label variable tfdepts___15 "Wards/Departments visited (choice=C1)"
label variable tfdepts___16 "Wards/Departments visited (choice=C2)"
label variable tfdepts___17 "Wards/Departments visited (choice=C3)"
label variable tfdepts___18 "Wards/Departments visited (choice=C4)"
label variable tfdepts___19 "Wards/Departments visited (choice=C5)"
label variable tfdepts___20 "Wards/Departments visited (choice=C6)"
label variable tfdepts___21 "Wards/Departments visited (choice=C7)"
label variable tfdepts___22 "Wards/Departments visited (choice=C8)"
label variable tfdepts___23 "Wards/Departments visited (choice=C9)"
label variable tfdepts___24 "Wards/Departments visited (choice=C12)"
label variable tfdepts___25 "Wards/Departments visited (choice=HDU)"
label variable tfdepts___26 "Wards/Departments visited (choice=Stroke Unit)"
label variable tfdepts___27 "Wards/Departments visited (choice=Cardiac Unit)"
label variable tfdepts___28 "Wards/Departments visited (choice=MICU)"
label variable tfdepts___29 "Wards/Departments visited (choice=SICU)"
label variable tfdepts___30 "Wards/Departments visited (choice=NICU)"
label variable tfdepts___31 "Wards/Departments visited (choice=PICU)"
label variable tfdepts___32 "Wards/Departments visited (choice=Recovery Room)"
label variable tfdepts___33 "Wards/Departments visited (choice=A&E)"
label variable tfdepts___34 "Wards/Departments visited (choice=Medical Records)"
label variable tfdepts___35 "Wards/Departments visited (choice=Death Records)"
label variable tfdepts___99 "Wards/Departments visited (choice=ND / date ND / NK / Unknown / No record of use)"
label variable tfdepts___88 "Wards/Departments visited (choice=partial date/time)"
label variable tfdepts___999 "Wards/Departments visited (choice=Age / NRN year / BP ND)"
label variable tfdepts___9999 "Wards/Departments visited (choice=Trop / YEAR ND)"
label variable tfwards___1 "WARDS (choice=Admission book review)"
label variable tfwards___2 "WARDS (choice=Rounds book review)"
label variable tfwards___3 "WARDS (choice=Note review)"
label variable tfwards___4 "WARDS (choice=Backlog (discharge + CTB info))"
label variable tfwards___5 "WARDS (choice=Partial abstraction)"
label variable tfwards___6 "WARDS (choice=Full abstraction)"
label variable tfwards___99 "WARDS (choice=ND / date ND / NK / Unknown / No record of use)"
label variable tfwards___88 "WARDS (choice=partial date/time)"
label variable tfwards___999 "WARDS (choice=Age / NRN year / BP ND)"
label variable tfwards___9999 "WARDS (choice=Trop / YEAR ND)"
label variable tfwardsdate "Date(s) and Ward(s) Reviewed:  Adm/Disch and/or Rounds Bks"
label variable tfmedrec___1 "MEDICAL RECORDS (choice=Backlog note review)"
label variable tfmedrec___2 "MEDICAL RECORDS (choice=Full abstraction)"
label variable tfmedrec___3 "MEDICAL RECORDS (choice=Discharge abstraction)"
label variable tfmedrec___4 "MEDICAL RECORDS (choice=Clinical director review)"
label variable tfmedrec___5 "MEDICAL RECORDS (choice=Discharge note review)"
label variable tfmedrec___99 "MEDICAL RECORDS (choice=ND / date ND / NK / Unknown / No record of use)"
label variable tfmedrec___88 "MEDICAL RECORDS (choice=partial date/time)"
label variable tfmedrec___999 "MEDICAL RECORDS (choice=Age / NRN year / BP ND)"
label variable tfmedrec___9999 "MEDICAL RECORDS (choice=Trop / YEAR ND)"
label variable tfmrdate "Discharge Date(s) Reviewed"
label variable tfpaypile "# Pay Files"
label variable tfmedpile "# Medical Files"
label variable tfgenpile "# General Files"
label variable totpile "# Total Files (auto-calculated)"
label variable tfdrec___1 "DEATH RECORDS (choice=Backlog note review)"
label variable tfdrec___2 "DEATH RECORDS (choice=Full abstraction)"
label variable tfdrec___3 "DEATH RECORDS (choice=Discharge abstraction)"
label variable tfdrec___4 "DEATH RECORDS (choice=Clinical director review)"
label variable tfdrec___5 "DEATH RECORDS (choice=Discharge note review)"
label variable tfdrec___6 "DEATH RECORDS (choice=Ledger review)"
label variable tfdrec___7 "DEATH RECORDS (choice=DID/DOA book review)"
label variable tfdrec___99 "DEATH RECORDS (choice=ND / date ND / NK / Unknown / No record of use)"
label variable tfdrec___88 "DEATH RECORDS (choice=partial date/time)"
label variable tfdrec___999 "DEATH RECORDS (choice=Age / NRN year / BP ND)"
label variable tfdrec___9999 "DEATH RECORDS (choice=Trop / YEAR ND)"
label variable tfaerec___1 "A&E Records (choice=Backlog note review (>2wks))"
label variable tfaerec___2 "A&E Records (choice=Note review)"
label variable tfaerec___3 "A&E Records (choice=Full abstraction)"
label variable tfaerec___4 "A&E Records (choice=Clinical director review)"
label variable tfaerec___5 "A&E Records (choice=A&E report)"
label variable tfaerec___99 "A&E Records (choice=ND / date ND / NK / Unknown / No record of use)"
label variable tfaerec___88 "A&E Records (choice=partial date/time)"
label variable tfaerec___999 "A&E Records (choice=Age / NRN year / BP ND)"
label variable tfaerec___9999 "A&E Records (choice=Trop / YEAR ND)"
label variable tfdoaend "TF Date - end"
label variable tfdoatend "TF Time - end"
label variable tfelapsed "Time Elapsed (auto-calculated)"
label variable tracking_complete "Complete?"
label variable cfdoa "CF Date"
label variable cfdoat "CF Time"
label variable cfda "CF DA"
label variable sri "Select Yes if event=both (single-adm-multi-event) but Heart admitted and abstracted first and then Stroke occurred during hospitalization and after heart abstraction"
label variable srirec "If above field=Yes, enter Heart RecordID / PID"
label variable evolution "Is this a stroke-in-evolution?"
label variable sourcetype "Source Type"
label variable firstnf "First Notification (NF) Source"
label variable cfsource___1 "Casefinding (CF) Source (choice=A1)"
label variable cfsource___2 "Casefinding (CF) Source (choice=A2)"
label variable cfsource___3 "Casefinding (CF) Source (choice=A3/HDU)"
label variable cfsource___4 "Casefinding (CF) Source (choice=A5)"
label variable cfsource___5 "Casefinding (CF) Source (choice=A6)"
label variable cfsource___6 "Casefinding (CF) Source (choice=MICU)"
label variable cfsource___7 "Casefinding (CF) Source (choice=SICU)"
label variable cfsource___8 "Casefinding (CF) Source (choice=B5)"
label variable cfsource___9 "Casefinding (CF) Source (choice=B6)"
label variable cfsource___10 "Casefinding (CF) Source (choice=B7)"
label variable cfsource___11 "Casefinding (CF) Source (choice=B8)"
label variable cfsource___12 "Casefinding (CF) Source (choice=C5)"
label variable cfsource___13 "Casefinding (CF) Source (choice=C6)"
label variable cfsource___14 "Casefinding (CF) Source (choice=C7/PICU)"
label variable cfsource___15 "Casefinding (CF) Source (choice=C8)"
label variable cfsource___16 "Casefinding (CF) Source (choice=C9)"
label variable cfsource___17 "Casefinding (CF) Source (choice=C10/Stroke Unit)"
label variable cfsource___18 "Casefinding (CF) Source (choice=C12)"
label variable cfsource___19 "Casefinding (CF) Source (choice=Cardiac Unit)"
label variable cfsource___20 "Casefinding (CF) Source (choice=Med Rec)"
label variable cfsource___21 "Casefinding (CF) Source (choice=Death Rec)"
label variable cfsource___22 "Casefinding (CF) Source (choice=A&E)"
label variable cfsource___23 "Casefinding (CF) Source (choice=Bay View hospital)"
label variable cfsource___24 "Casefinding (CF) Source (choice=Sparman Clinic (4H))"
label variable cfsource___25 "Casefinding (CF) Source (choice=Polyclinic)"
label variable cfsource___26 "Casefinding (CF) Source (choice=Private Physician)"
label variable cfsource___27 "Casefinding (CF) Source (choice=Emergency Clinic (e.g. SCMC, FMH, Coverley, etc))"
label variable cfsource___28 "Casefinding (CF) Source (choice=Nursing Home)"
label variable cfsource___29 "Casefinding (CF) Source (choice=District Hospital)"
label variable cfsource___30 "Casefinding (CF) Source (choice=Geriatric Hospital)"
label variable cfsource___31 "Casefinding (CF) Source (choice=Psychiatric Hospital)"
label variable cfsource___32 "Casefinding (CF) Source (choice=Member of Public)"
label variable retsource "Current Location of Patient (Retrieval Source):  Ward / Department / Clinic"
label variable oretsrce "Other Retrieval Source"
label variable fname "First Name"
label variable mname "Middle Name(s)"
label variable lname "Last Name(s)"
label variable sex "Sex"
label variable dob "Date of Birth"
label variable dobday "DOB - DAY"
label variable dobmonth "DOB - MONTH"
label variable dobyear "DOB - YEAR"
label variable cfage "Age at CF (auto-calculated)"
label variable cfage_da "Age at CF (DA to enter)"
label variable natregno "National ID # (NRN)"
label variable nrnyear "NRN - YEAR"
label variable nrnmonth "NRN - MONTH"
label variable nrnday "NRN - DAY"
label variable nrnnum "NRN - last 4 digits only"
label variable recnum "Hospital / Record #"
label variable cfadmdate "Admission (hospital) Date or Visit (community) Date "
label variable cfadmyr "YEAR:"
label variable cfadmdatemon "MONTH:"
label variable cfadmdatemondash "MONTH"
label variable initialdx "Initial Diagnosis"
label variable hstatus "Hospital Status"
label variable slc "Status at last contact (SLC)"
label variable dlc "Discharge Date (Date at Last Contact - DLC)"
label variable dlcyr "YEAR:"
label variable dlcday "DIS (DLC) Date - DAY"
label variable dlcmonth "DIS (DLC) Date - MONTH"
label variable dlcyear "DIS (DLC) Date - YEAR"
label variable cfdod "Death Date"
label variable cfdodyr "YEAR:"
label variable cfdodday "DOD Date - DAY"
label variable cfdodmonth "DOD Date - MONTH"
label variable cfdodyear "DOD Date - YEAR"
label variable finaldx "Final Diagnosis"
label variable cfcods "Cause(s) of Death (COD)"
label variable docname "Doctors Name first and last name(s)"
label variable docaddr "Doctors Address (include clinic name and parish)"
label variable cstatus "Case Status"
label variable eligible "Case Status - Eligible"
label variable ineligible "Case Status - Ineligible"
label variable pendrv "Case Status - Pending review"
label variable duplicate "Duplicate? Yes = same pt, same event OR same pt, different event"
label variable duprec "Duplicate RecordID"
label variable dupcheck "Duplicate checked?"
label variable requestdate1 "Date Notes Requested 1"
label variable requestdate2 "Date Notes Requested 2"
label variable requestdate3 "Date Notes Requested 3"
label variable nfdb "Was this record from NFdb?"
label variable nfdbrec "NFdb Record ID"
label variable reabsrec "Which RecordID are you re-abstracting?"
label variable toabs "Do you want to abstract now?"
label variable copycf "Copy data to heart arm?"
label variable casefinding_complete "Complete?"
label variable adoa "ABS Date"
label variable adoat "ABS Time"
label variable ada "ABS DA"
label variable mstatus "Marital Status"
label variable resident "Resident of Barbados?"
label variable citizen "Barbadian Citizen?"
label variable addr "Address (Village/Town)"
label variable parish "Parish"
label variable hometel "Home #"
label variable worktel "Work #"
label variable celltel "Cell #"
label variable fnamekin "NOK First Name"
label variable lnamekin "NOK Last Name"
label variable sametel "Are NOKs phone numbers same as patients?"
label variable homekin "NOKs Home #"
label variable workkin "NOKs Work #"
label variable cellkin "NOKs Cell #"
label variable relation "Relationship of NOK to patient"
label variable orelation "Please specify if Other relationship"
label variable copydemo "Copy data to heart arm?"
label variable demographics_complete "Complete?"
label variable ptmdoa "ABS Date"
label variable ptmdoat "ABS Time"
label variable ptmda "ABS DA"
label variable fmc "Was patient referred to hospital?"
label variable fmcplace "Referred from?(place of first medical contact-FMC)"
label variable ofmcplace "Other Referral Centre"
label variable fmcdate "Visit Date (FMC)"
label variable fmcdday "Visit Date (FMC) - DAY"
label variable fmcdmonth "Visit Date (FMC) - MONTH"
label variable fmcdyear "Visit Date (FMC) - YEAR"
label variable fmctime "Visit Time (FMC)"
label variable fmcampm "Visit Time (am/pm) (FMC)"
label variable hospital "Name of Hospital"
label variable ohospital "Please specify if Other hospital"
label variable aeadmit "Was patient seen in A&E?"
label variable dae "Admission Date (A&E)"
label variable tae "Admission Time (A&E)"
label variable taeampm "Admission Time (am/pm) (A&E)"
label variable daedis "Discharge Date (A&E)"
label variable taedis "Discharge Time (A&E)"
label variable taedisampm "Discharge Time (am/pm) (A&E)"
label variable wardadmit "Was patient admitted to hospital (Ward)?"
label variable dohsame "Is admission date the same as on Casefinding form?"
label variable doh "Admission / Visit Date (Ward)"
label variable toh "Admission Time (Ward)"
label variable tohampm "Admission Time (am/pm) (Ward)"
label variable arrivalmode "Mode of arrival"
label variable ambcalld "Date ambulance NOTIFIED"
label variable ambcallday "Date ambulance NOTIFIED - DAY"
label variable ambcallmonth "Date ambulance NOTIFIED - MONTH"
label variable ambcallyear "Date ambulance NOTIFIED - YEAR"
label variable ambcallt "Time ambulance NOTIFIED"
label variable ambcalltampm "Time ambulance NOTIFIED (am/pm)"
label variable atscene "Is date ambulance arrived AT SCENE same as at hospital?"
label variable atscnd "Date ambulance AT SCENE"
label variable atscnday "Date ambulance AT SCENE - DAY"
label variable atscnmonth "Date ambulance AT SCENE - MONTH"
label variable atscnyear "Date ambulance AT SCENE - YEAR"
label variable atscnt "Time ambulance AT SCENE"
label variable atscntampm "Time ambulance AT SCENE (am/pm)"
label variable frmscene "Is date ambulance departed FROM SCENE same as at scene above?"
label variable frmscnd "Date ambulance FROM SCENE"
label variable frmscnday "Date ambulance FROM SCENE - DAY"
label variable frmscnmonth "Date ambulance FROM SCENE - MONTH"
label variable frmscnyear "Date ambulance FROM SCENE - YEAR"
label variable frmscnt "Time ambulance FROM SCENE"
label variable frmscntampm "Time ambulance FROM SCENE (am/pm)"
label variable sameadm "Is (A&E) Admission date & time same as ambulance arrived AT HOSPITAL?"
label variable hospd "Date ambulance AT HOSPITAL"
label variable hospday "Date ambulance AT HOSPITAL - DAY"
label variable hospmonth "Date ambulance AT HOSPITAL - MONTH"
label variable hospyear "Date ambulance AT HOSPITAL - YEAR"
label variable hospt "Time ambulance AT HOSPITAL"
label variable hosptampm "Time ambulance AT HOSPITAL (am/pm)"
label variable ward___1 "Select wards/units where patient was treated (choice=ICU/HDU)"
label variable ward___2 "Select wards/units where patient was treated (choice=A&E)"
label variable ward___3 "Select wards/units where patient was treated (choice=Medical Ward(s))"
label variable ward___4 "Select wards/units where patient was treated (choice=Stroke Unit)"
label variable ward___5 "Select wards/units where patient was treated (choice=Cardiac Unit)"
label variable ward___98 "Select wards/units where patient was treated (choice=Other than those listed above)"
label variable oward "Please specify other ward/unit?"
label variable nohosp___1 "How was the patient managed? (choice=Private Physician)"
label variable nohosp___2 "How was the patient managed? (choice=Went overseas e.g. airlift)"
label variable nohosp___3 "How was the patient managed? (choice=Nursing home)"
label variable nohosp___4 "How was the patient managed? (choice=Medically unattended (No regular medical attention prior to this event))"
label variable nohosp___5 "How was the patient managed? (choice=At home by doctor or nurse)"
label variable nohosp___6 "How was the patient managed? (choice=District/Geriatric Hospital)"
label variable nohosp___98 "How was the patient managed? (choice=Other)"
label variable nohosp___99 "How was the patient managed? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable nohosp___88 "How was the patient managed? (choice=partial date/time)"
label variable nohosp___999 "How was the patient managed? (choice=Age / NRN year / BP ND)"
label variable nohosp___9999 "How was the patient managed? (choice=Trop / YEAR ND)"
label variable onohosp "If Other please specify"
label variable copyptm "Copy data to heart arm?"
label variable patient_management_complete "Complete?"
label variable edoa "ABS Date"
label variable edoat "ABS Time"
label variable eda "ABS DA"
label variable ssym1 "Slurred speech/Loss of speech (dysarthria/aphasia)"
label variable ssym2 "Diminished Responsiveness (drowsiness/coma)"
label variable ssym3 "Unilateral weakness including facial weakness"
label variable ssym4 "Difficulty or inability to swallow"
label variable hsym1 "Sudden onset of chest/epigastric/retrosternal pain or discomfort  (chest pain)"
label variable hsym2 "Sudden onset - shortness of breath (sob)"
label variable hsym3 "Sudden onset - Vomiting (vomit)"
label variable hsym4 "Sudden onset - Dizziness/vertigo (dizzy)"
label variable hsym5 "Sudden loss of consciousness (loc)"
label variable hsym6 "Palpitations (irregular/rapid heartbeat) (palp)"
label variable hsym7 "Sweating / Diaphoresis (sweat)"
label variable osym "Other symptom(s) - How many (other than those above) are documented?"
label variable osym1 "1) Please specify other symptom"
label variable osym2 "2) Please specify other symptom"
label variable osym3 "3) Please specify other symptom"
label variable osym4 "4) Please specify other symptom"
label variable osym5 "5) Please specify other symptom"
label variable osym6 "6) Please specify other symptom"
label variable ssym1d "Onset Date (speech)"
label variable ssym1day "Onset (speech) - DAY"
label variable ssym1month "Onset (speech) - MONTH"
label variable ssym1year "Onset (speech) - YEAR"
label variable ssym2d "Onset Date (response)"
label variable ssym2day "Onset (response) - DAY"
label variable ssym2month "Onset (response) - MONTH"
label variable ssym2year "Onset (response) - YEAR"
label variable ssym3d "Onset Date (weakness)"
label variable ssym3day "Onset (weakness) - DAY"
label variable ssym3month "Onset (weakness) - MONTH"
label variable ssym3year "Onset (weakness) - YEAR"
label variable ssym4d "Onset Date (swallow)"
label variable ssym4day "Onset (swallow) - DAY"
label variable ssym4month "Onset (swallow) - MONTH"
label variable ssym4year "Onset (swallow) - YEAR"
label variable hsym1d "Onset Date (chest pain)"
label variable hsym1day "Onset (chest pain) - DAY"
label variable hsym1month "Onset (chest pain) - MONTH"
label variable hsym1year "Onset (chest pain) - YEAR"
label variable hsym1t "Onset Time (chest pain)"
label variable hsym1tampm "Onset Time - chest pain (am/pm)"
label variable hsym2d "Onset Date (sob)"
label variable hsym2day "Onset Date (sob) - DAY"
label variable hsym2month "Onset Date (sob) - MONTH"
label variable hsym2year "Onset Date (sob) - YEAR"
label variable hsym3d "Onset Date (vomit)"
label variable hsym3day "Onset Date (vomit) - DAY"
label variable hsym3month "Onset Date (vomit) - MONTH"
label variable hsym3year "Onset Date (vomit) - YEAR"
label variable hsym4d "Onset Date (dizzy)"
label variable hsym4day "Onset Date (dizzy) - DAY"
label variable hsym4month "Onset Date (dizzy) - MONTH"
label variable hsym4year "Onset Date (dizzy) - YEAR"
label variable hsym5d "Onset Date (loc)"
label variable hsym5day "Onset Date (loc) - DAY"
label variable hsym5month "Onset Date (loc) - MONTH"
label variable hsym5year "Onset Date (loc) - YEAR"
label variable hsym6d "Onset Date (palp)"
label variable hsym6day "Onset Date (palp) - DAY"
label variable hsym6month "Onset Date (palp) - MONTH"
label variable hsym6year "Onset Date (palp) - YEAR"
label variable hsym7d "Onset Date (sweat)"
label variable hsym7day "Onset Date (sweat) - DAY"
label variable hsym7month "Onset Date (sweat) - MONTH"
label variable hsym7year "Onset Date (sweat) - YEAR"
label variable osymd "Onset Date (other)"
label variable osymday "Onset (other) - DAY"
label variable osymmonth "Onset (other) - MONTH"
label variable osymyear "Onset (other) - YEAR"
label variable sign1 "Disturbed consciousness / Not responding"
label variable sign2 "Weakness/paresis of one or more limbs or facial asymmetry"
label variable sign3 "Speech lost, slurred or inappropriate"
label variable sign4 "Was patient screened for swallow difficulties by healthcare provider before oral food/fluids (within 24hrs)?"
label variable sonset "Sudden onset / rapidly progressing neurological impairment?"
label variable sday "Symptoms last for at least 24hrs / lead to death within 24hrs?"
label variable swalldate "Swallow Screen Date"
label variable swalldday "Date of swallow screen - DAY"
label variable swalldmonth "Date of swallow screen - MONTH"
label variable swalldyear "Date of swallow screen - YEAR"
label variable cardmon "Did pt receive 24h cardiac monitoring on admission?"
label variable nihss "NIHSS risk score (stroke)"
label variable timi "TIMI risk score (heart)"
label variable stype "What type of stroke was diagnosed?"
label variable htype "What type of acute MI was diagnosed?"
label variable dxtype "How was the diagnosis sub-type made?"
label variable dstroke "Definite or possible stroke?"
label variable review "Is this event for review?"
label variable reviewreason "Reason for review"
label variable reviewer___1 "If Has been reviewed... is selected then please tick who reviewed it. (choice=Clinical Director)"
label variable reviewer___2 "If Has been reviewed... is selected then please tick who reviewed it. (choice=Registrar)"
label variable reviewer___3 "If Has been reviewed... is selected then please tick who reviewed it. (choice=Principal Investigator)"
label variable reviewd "Date Reviewed"
label variable edate "Date of Event"
label variable fu1date "Date of 28-d Follow-Up"
label variable edateyr "YEAR:"
label variable edatemon "MONTH:"
label variable edatemondash "MONTH"
label variable inhosp "Date of Event is after Date of Admission. Is this an in-hospital event?"
label variable etime "Time of Event (onset time for 1st symptom)"
label variable etimeampm "Time of Event (am/pm)"
label variable age "Age at Event"
label variable edateetime "Event Date and Time"
label variable daetae "A&E Adm Date and Time"
label variable ambcalldt "Ambulance Called Date and Time"
label variable onsetevetoae "Onset from Event  to A&E Adm  - Mins"
label variable onsetambtoae "Onset from Ambulance Called  to A&E Adm  - Mins"
label variable cardiac "Did the patient experience a cardiac arrest prior to hospitalisation for this event?"
label variable cardiachosp "Did the patient experience a cardiac arrest during hospitalisation?"
label variable resus "Did the patient have cardiac resuscitation (cardiopulmonary or defibrillation i.e. CPR)?"
label variable sudd "Did the patient survive cardiac resuscitation?"
label variable fname_eve "First Name"
label variable lname_eve "Last Name"
label variable sex_eve "Sex"
label variable slc_eve "Status at last contact (SLC)"
label variable cstatus_eve "Case Status"
label variable eligible_eve "Case Status - Eligible"
label variable fu1done "28-day F/U completed?"
label variable copyeve "Copy data to heart arm?"
label variable f1vstatus_eve "Vital Status at 28-days"
label variable event_complete "Complete?"
label variable hxdoa "ABS Date"
label variable hxdoat "ABS Time"
label variable hxda "ABS DA"
label variable pstroke "Any definite previous stroke?"
label variable pami "Any definite previous AMI?"
label variable pihd "Any previous Ischaemic Heart Disease (stable/unstable angina)?"
label variable pcabg "Any previous CABG (coronary artery bypass graft)?"
label variable pcorangio "Any previous Angioplasty?"
label variable pstrokeyr "Enter YEAR of most RECENT previous stroke"
label variable pamiyr "Enter YEAR of most RECENT previous AMI"
label variable dbchecked "Have you checked the database/data files to see if this previous stroke or heart event has already been abstracted?"
label variable famstroke "Any family history of Stroke?"
label variable famami "Any family history of AMI?"
label variable mumstroke "Mother"
label variable dadstroke "Father"
label variable sibstroke "Sibling"
label variable mumami "Mother"
label variable dadami "Father"
label variable sibami "Sibling"
label variable rfany "Does the patient have any of the following risk factors?"
label variable smoker "Current tobacco use"
label variable hcl "High Cholesterol"
label variable af "Atrial Fibrillation (AF)"
label variable tia "Transient Ischaemic Attack (TIA)"
label variable ccf "Cardiac Failure (CCF)"
label variable htn "Hypertension (HTN)"
label variable diab "Diabetes Mellitus (DM)"
label variable hld "Hyperlipidaemia"
label variable alco "Alcohol"
label variable drugs "Drug abuse/misuse"
label variable ovrf "Other risk factor(s) - How many (other than those above) are documented?"
label variable ovrf1 "1) Please specify other risk factor"
label variable ovrf2 "2) Please specify other risk factor"
label variable ovrf3 "3) Please specify other risk factor"
label variable ovrf4 "4) Please specify other risk factor"
label variable copyhx "Copy data to heart arm?"
label variable history_complete "Complete?"
label variable tdoa "ABS Date"
label variable tdoat "ABS Time"
label variable tda "ABS DA"
label variable sysbp "Blood Pressure at Admission - Systolic (mmHg)"
label variable diasbp "Blood Pressure at Admission - Diastolic (mmHg)"
label variable bpm "Heart Rate (bpm)"
label variable bgunit "Blood Glucose - what is the unit of measurement? "
label variable bgmg "Blood Glucose - mg/dl"
label variable bgmmol "Blood Glucose - mmol/l"
label variable o2sat "Oxygen Saturation (O2SAT %)"
label variable assess "Patient had any of these assessments done?"
label variable assess1 "Evaluation by occupational therapist"
label variable assess2 "Evaluation by physiotherapist"
label variable assess3 "Evaluation by speech therapist"
label variable assess4 "Swallowing assessment by speech therapist"
label variable assess7 "Evaluation by rehabilitation specialist"
label variable assess8 "Evaluation by cardiologist"
label variable assess9 "Evaluation by neurologist"
label variable assess10 "Evaluation by neurosurgeon"
label variable assess12 "Malnutrition assessment"
label variable assess14 "Cognitive impairment screening Check pg 2 of Occupational therapy initial assessment sheet under section Cognition Screen"
label variable dieany "Any diagnostic exams/interventions done by the time of abstraction?"
label variable dct "CT brain scan"
label variable decg "Electrocardiogram"
label variable dmri "MRI brain scan"
label variable dcerangio "Angiography (cerebral)"
label variable dcarangio "Angiography (carotid)"
label variable dcarus "Carotid ultrasound"
label variable decho "ECHO (Transthoracic echo cardiography)"
label variable dctcorang "CT / Coronary Angiography"
label variable dstress "Stress Test / Treadmill"
label variable odie "Other examination(s) - How many (other than those above) are documented?"
label variable odie1 "1) Please specify other exam/intervention"
label variable odie2 "2) Please specify other exam/intervention"
label variable odie3 "3) Please specify other exam/intervention"
label variable ct "Was a CT/MRI brain scan report available?"
label variable doct "Date of first CT/MRI scan"
label variable doctday "Date of first CT/MRI - DAY"
label variable doctmonth "Date of first CT/MRI - MONTH"
label variable doctyear "Date of first CT/MRI - YEAR"
label variable stime "Timing between Stroke onset & CT/MRI scan (auto-calculated)"
label variable ctfeat "Any features documented on CT/MRI report?"
label variable ctinfarct "Was Infarction / Hypodensity documented?"
label variable ctsubhaem "Was Subarachnoid Haemorrhage documented?"
label variable ctinthaem "Was Intracerebral Haemorrhage documented?"
label variable ckmbdone "Was CK-MB done?"
label variable astdone "Was AST done?"
label variable tropdone "Were Troponin results available?"
label variable tropcomm "Were Troponin results documented as elevated/high in community notes?"
label variable tropd "Date of 1st Troponin"
label variable tropdday "Date of 1st Troponin - DAY"
label variable tropdmonth "Date of 1st Troponin - MONTH"
label variable tropdyear "Date of 1st Troponin - YEAR"
label variable tropt "Time of 1st Troponin"
label variable troptampm "Time of 1st Troponin (am/pm)"
label variable troptype "Type of Troponin"
label variable tropres "How many Troponin tests were results are documented?"
label variable trop1res "Result 1 - Troponin"
label variable trop2res "Result 2 - Troponin"
label variable ecg "Was an ECG report available?"
label variable ecgd "Date of ECG"
label variable ecgdday "Date of ECG - DAY"
label variable ecgdmonth "Date of ECG - MONTH"
label variable ecgdyear "Date of ECG - YEAR"
label variable ecgt "Time of ECG"
label variable ecgtampm "Time of ECG (am/pm)"
label variable ecgs "Were serial (i.e. >1) ECGs done?"
label variable ischecg "Were ischaemic region(s) documented on ECG?"
label variable ecgantero "Anterolateral (V3, V4, V5, V6, I, aVL)"
label variable ecgrv "Right Ventricle (II, III, aVF, V1, V4R, V5R, V6R)"
label variable ecgant "Anterior (V3, V4)"
label variable ecglat "Lateral (I, aVL, V5, V6)"
label variable ecgpost "Posterior (V7, V8, V9)"
label variable ecginf "Inferior (II, III, aVF)"
label variable ecgsep "Septal (V1, V2)"
label variable ecgnd "Undetermined"
label variable oecg "Other region(s) - How many (other than those above) are documented?"
label variable oecg1 "1) Please specify other ischaemic region"
label variable oecg2 "2) Please specify other ischaemic region"
label variable oecg3 "3) Please specify other ischaemic region"
label variable oecg4 "4) Please specify other ischaemic region"
label variable ecgfeat "Were any features documented on ECG report?"
label variable ecglbbb "Left Bundle Branch Block (LBBB)"
label variable ecgaf "Atrial Fibrillation (AF)"
label variable ecgste "ST segment elevation"
label variable ecgstd "ST segment depression"
label variable ecgpqw "Pathological Q waves"
label variable ecgtwv "T wave inversion"
label variable ecgnor "Normal ECG"
label variable ecgnorsin "Normal sinus rhythm"
label variable ecgomi "Old MI"
label variable ecgnstt "Non-specific ST-T changes"
label variable ecglvh "Left Ventricle Hypertrophy (LVH)"
label variable oecgfeat "Other feature(s) - How many (other than those above) are documented?"
label variable oecgfeat1 "1) Please specify other ECG feature"
label variable oecgfeat2 "2) Please specify other ECG feature"
label variable oecgfeat3 "3) Please specify other ECG feature"
label variable oecgfeat4 "4) Please specify other ECG feature"
label variable tiany "Any therapeutic interventions done by the time of abstraction?"
label variable tppv "Invasive mechanical ventilation, e.g. Intubation / PPV"
label variable tnippv "Non-invasive mechanical ventilation, e.g. CPAP / NIPPV"
label variable tdefib "Defibrillation / Cardioversion"
label variable tcpr "CPR (cardiopulmonary resuscitation)"
label variable tmech "Mechanical circulatory support (Intraaortic balloon pump / Counterpulsation)"
label variable tctcorang "CT / Coronary Angioplasty"
label variable tpacetemp "Temporary pacemaker"
label variable tcath "Cardiac Catherization"
label variable tdhemi "Decompressive hemicraniectomy"
label variable tvdrain "Ventricular drain"
label variable oti "Other intervention(s) - How many (other than those above) are documented?"
label variable oti1 "1) Please specify other therapeutic intervention"
label variable oti2 "2) Please specify other therapeutic intervention"
label variable oti3 "3) Please specify other therapeutic intervention"
label variable copytests "Copy data to heart arm?"
label variable tests_complete "Complete?"
label variable dxdoa "ABS Date"
label variable dxdoat "ABS Time"
label variable dxda "ABS DA"
label variable hcomp "Did any complications occur during hospitalisation, following the diagnosis of AMI and/or Stroke, by time of abstraction?"
label variable hdvt "Deep Vein Thrombosis (DVT)"
label variable hpneu "Pneumonia"
label variable hulcer "Decubitus ulcer"
label variable huti "Urinary Tract Infection (UTI)"
label variable hfall "Fall"
label variable hhydro "Hydrocephalus"
label variable hhaemo "Haemorrhagic transformation"
label variable hoinfect "Other Infection / Septic Shock"
label variable hgibleed "Gastrointestinal (GI) Bleed"
label variable hccf "Congestive Cardiac/Heart Failure (CCF/CHF)"
label variable hcpang "Recurrent chest pain / angina"
label variable haneur "Ventricular aneurysm"
label variable hhypo "Postural hypotension"
label variable hblock "Heart Block (pacemaker needed)"
label variable hseizures "Seizures"
label variable hafib "Atrial Fibrillation (AF)"
label variable hcshock "Cardiogenic shock"
label variable hinfarct "Reinfarction"
label variable hrenal "Renal failure"
label variable hcarest "Cardiac arrest"
label variable ohcomp "Other complication(s) - How many (other than those above) are documented?"
label variable ohcomp1 "1) Please specify other complication"
label variable ohcomp2 "2) Please specify other complication"
label variable ohcomp3 "3) Please specify other complication"
label variable ohcomp4 "4) Please specify other complication"
label variable ohcomp5 "5) Please specify other complication"
label variable absdxsame "Is ABSTRACTION dx the SAME as INITIAL dx?"
label variable absdxs___1 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=Ischaemic Stroke)"
label variable absdxs___2 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=Intracerebral Haemorrhage)"
label variable absdxs___3 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=Subarachnoid Haemorrhage)"
label variable absdxs___4 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=Unclassified Type)"
label variable absdxs___5 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=CVA)"
label variable absdxs___6 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=R/o query (?)CVA)"
label variable absdxs___7 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=TIA)"
label variable absdxs___8 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=R/o query (?)TIA)"
label variable absdxs___99 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable absdxs___88 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=partial date/time)"
label variable absdxs___999 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=Age / NRN year / BP ND)"
label variable absdxs___9999 "What was the STROKE diagnosis documented by physician at time of abstraction? (choice=Trop / YEAR ND)"
label variable absdxh___1 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=STEMI)"
label variable absdxh___2 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=NSTEMI)"
label variable absdxh___3 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=AMI (definite))"
label variable absdxh___4 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=R/o query (?)AMI)"
label variable absdxh___5 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=ACS)"
label variable absdxh___6 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=R/o query (?)ACS)"
label variable absdxh___7 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=Unstable Angina)"
label variable absdxh___8 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=Chest pain ?cause)"
label variable absdxh___9 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=LBBB (new onset))"
label variable absdxh___10 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=Sudden cardiac death)"
label variable absdxh___99 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable absdxh___88 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=partial date/time)"
label variable absdxh___999 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=Age / NRN year / BP ND)"
label variable absdxh___9999 "What was the AMI diagnosis documented by physician at time of abstraction? (choice=Trop / YEAR ND)"
label variable oabsdx "Other diagnosis(s) - How many (other than those above) are documented?"
label variable oabsdx1 "1) Please specify other diagnosis"
label variable oabsdx2 "2) Please specify other diagnosis"
label variable oabsdx3 "3) Please specify other diagnosis"
label variable oabsdx4 "4) Please specify other diagnosis"
label variable copycomp "Copy data to heart arm?"
label variable complications_dx_complete "Complete?"
label variable rxdoa "ABS Date"
label variable rxdoat "ABS Time"
label variable rxda "ABS DA"
label variable reperf "Was reperfusion treatment attempted?"
label variable repertype "Type of reperfusion"
label variable reperfd "Date of reperfusion"
label variable reperfdday "Date of reperfusion - DAY"
label variable reperfdmonth "Date of reperfusion - MONTH"
label variable reperfdyear "Date of reperfusion - YEAR"
label variable reperft "Time of reperfusion"
label variable reperftampm "Time of reperfusion (am/pm)"
label variable asp___1 "Aspirin (ASA) (choice=Acute use (in/out of QEH))"
label variable asp___2 "Aspirin (ASA) (choice=Chronic use)"
label variable asp___3 "Aspirin (ASA) (choice=Contraindications)"
label variable asp___99 "Aspirin (ASA) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable asp___88 "Aspirin (ASA) (choice=partial date/time)"
label variable asp___999 "Aspirin (ASA) (choice=Age / NRN year / BP ND)"
label variable asp___9999 "Aspirin (ASA) (choice=Trop / YEAR ND)"
label variable warf___1 "Warfarin (Coumadin) (choice=Acute use (in/out of QEH))"
label variable warf___2 "Warfarin (Coumadin) (choice=Chronic use)"
label variable warf___3 "Warfarin (Coumadin) (choice=Contraindications)"
label variable warf___99 "Warfarin (Coumadin) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable warf___88 "Warfarin (Coumadin) (choice=partial date/time)"
label variable warf___999 "Warfarin (Coumadin) (choice=Age / NRN year / BP ND)"
label variable warf___9999 "Warfarin (Coumadin) (choice=Trop / YEAR ND)"
label variable hep___1 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=Acute use (in/out of QEH))"
label variable hep___2 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=Chronic use)"
label variable hep___3 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=Contraindications)"
label variable hep___99 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable hep___88 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=partial date/time)"
label variable hep___999 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=Age / NRN year / BP ND)"
label variable hep___9999 "Heparin  (sc) (iv) (UFH-Unfractionated Heparin) (choice=Trop / YEAR ND)"
label variable heplmw___1 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=Acute use (in/out of QEH))"
label variable heplmw___2 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=Chronic use)"
label variable heplmw___3 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=Contraindications)"
label variable heplmw___99 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable heplmw___88 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=partial date/time)"
label variable heplmw___999 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=Age / NRN year / BP ND)"
label variable heplmw___9999 "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin) (choice=Trop / YEAR ND)"
label variable pla___1 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=Acute use (in/out of QEH))"
label variable pla___2 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=Chronic use)"
label variable pla___3 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=Contraindications)"
label variable pla___99 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable pla___88 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=partial date/time)"
label variable pla___999 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=Age / NRN year / BP ND)"
label variable pla___9999 "Antiplatelet agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel) (choice=Trop / YEAR ND)"
label variable stat___1 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=Acute use (in/out of QEH))"
label variable stat___2 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=Chronic use)"
label variable stat___3 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=Contraindications)"
label variable stat___99 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable stat___88 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=partial date/time)"
label variable stat___999 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=Age / NRN year / BP ND)"
label variable stat___9999 "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol) (choice=Trop / YEAR ND)"
label variable fibr___1 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=Acute use (in/out of QEH))"
label variable fibr___2 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=Chronic use)"
label variable fibr___3 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=Contraindications)"
label variable fibr___99 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable fibr___88 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=partial date/time)"
label variable fibr___999 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=Age / NRN year / BP ND)"
label variable fibr___9999 "Fibrinolytic agents (Metalyse, Alteplase(tPA), Tenecteplase(TNK-tPA), Reteplase(rPA), Streptokinase) (choice=Trop / YEAR ND)"
label variable ace___1 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=Acute use (in/out of QEH))"
label variable ace___2 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=Chronic use)"
label variable ace___3 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=Contraindications)"
label variable ace___99 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable ace___88 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=partial date/time)"
label variable ace___999 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=Age / NRN year / BP ND)"
label variable ace___9999 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril) (choice=Trop / YEAR ND)"
label variable arbs___1 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=Acute use (in/out of QEH))"
label variable arbs___2 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=Chronic use)"
label variable arbs___3 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=Contraindications)"
label variable arbs___99 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable arbs___88 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=partial date/time)"
label variable arbs___999 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=Age / NRN year / BP ND)"
label variable arbs___9999 "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan) (choice=Trop / YEAR ND)"
label variable cors___1 "Corticosteroids (Dexmethasone) (choice=Acute use (in/out of QEH))"
label variable cors___2 "Corticosteroids (Dexmethasone) (choice=Chronic use)"
label variable cors___3 "Corticosteroids (Dexmethasone) (choice=Contraindications)"
label variable cors___99 "Corticosteroids (Dexmethasone) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable cors___88 "Corticosteroids (Dexmethasone) (choice=partial date/time)"
label variable cors___999 "Corticosteroids (Dexmethasone) (choice=Age / NRN year / BP ND)"
label variable cors___9999 "Corticosteroids (Dexmethasone) (choice=Trop / YEAR ND)"
label variable antih___1 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=Acute use (in/out of QEH))"
label variable antih___2 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=Chronic use)"
label variable antih___3 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=Contraindications)"
label variable antih___99 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable antih___88 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=partial date/time)"
label variable antih___999 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=Age / NRN year / BP ND)"
label variable antih___9999 "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil) (choice=Trop / YEAR ND)"
label variable nimo___1 "Nimodipine (calcium channel blocker) (choice=Acute use (in/out of QEH))"
label variable nimo___2 "Nimodipine (calcium channel blocker) (choice=Chronic use)"
label variable nimo___3 "Nimodipine (calcium channel blocker) (choice=Contraindications)"
label variable nimo___99 "Nimodipine (calcium channel blocker) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable nimo___88 "Nimodipine (calcium channel blocker) (choice=partial date/time)"
label variable nimo___999 "Nimodipine (calcium channel blocker) (choice=Age / NRN year / BP ND)"
label variable nimo___9999 "Nimodipine (calcium channel blocker) (choice=Trop / YEAR ND)"
label variable antis___1 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=Acute use (in/out of QEH))"
label variable antis___2 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=Chronic use)"
label variable antis___3 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=Contraindications)"
label variable antis___99 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable antis___88 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=partial date/time)"
label variable antis___999 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=Age / NRN year / BP ND)"
label variable antis___9999 "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol) (choice=Trop / YEAR ND)"
label variable ted___1 "TED Stockings (pneumatic compression) (choice=Acute use (in/out of QEH))"
label variable ted___2 "TED Stockings (pneumatic compression) (choice=Chronic use)"
label variable ted___3 "TED Stockings (pneumatic compression) (choice=Contraindications)"
label variable ted___99 "TED Stockings (pneumatic compression) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable ted___88 "TED Stockings (pneumatic compression) (choice=partial date/time)"
label variable ted___999 "TED Stockings (pneumatic compression) (choice=Age / NRN year / BP ND)"
label variable ted___9999 "TED Stockings (pneumatic compression) (choice=Trop / YEAR ND)"
label variable beta___1 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=Acute use (in/out of QEH))"
label variable beta___2 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=Chronic use)"
label variable beta___3 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=Contraindications)"
label variable beta___99 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable beta___88 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=partial date/time)"
label variable beta___999 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=Age / NRN year / BP ND)"
label variable beta___9999 "Beta Blockers (Metoprolol, Cardoxone, Propranolol) (choice=Trop / YEAR ND)"
label variable bival___1 "Bivalrudin (thrombin inhibitor) (choice=Acute use (in/out of QEH))"
label variable bival___2 "Bivalrudin (thrombin inhibitor) (choice=Chronic use)"
label variable bival___3 "Bivalrudin (thrombin inhibitor) (choice=Contraindications)"
label variable bival___99 "Bivalrudin (thrombin inhibitor) (choice=ND / date ND / NK / Unknown / No record of use)"
label variable bival___88 "Bivalrudin (thrombin inhibitor) (choice=partial date/time)"
label variable bival___999 "Bivalrudin (thrombin inhibitor) (choice=Age / NRN year / BP ND)"
label variable bival___9999 "Bivalrudin (thrombin inhibitor) (choice=Trop / YEAR ND)"
label variable aspdose "Dose of ASA"
label variable aspd "Date of ASA"
label variable aspdday "Date of ASA - DAY"
label variable aspdmonth "Date of ASA - MONTH"
label variable aspdyear "Date of ASA - YEAR"
label variable aspt "Time of ASA"
label variable asptampm "Time of ASA (am/pm)"
label variable warfd "Date of WARF"
label variable warfdday "Date of WARF - DAY"
label variable warfdmonth "Date of WARF - MONTH"
label variable warfdyear "Date of WARF - YEAR"
label variable warft "Time of WARF"
label variable warftampm "Time of WARF (am/pm)"
label variable hepd "Date of HEP (sc) (iv)"
label variable hepdday "Date of HEP (sc) (iv) - DAY"
label variable hepdmonth "Date of HEP (sc) (iv) - MONTH"
label variable hepdyear "Date of HEP (sc) (iv) - YEAR"
label variable hept "Time of HEP (sc) (iv)"
label variable heptampm "Time of HEP (sc) (iv) (am/pm)"
label variable heplmwd "Date of HEP (lmw)"
label variable heplmwdday "Date of HEP (lmw) - DAY"
label variable heplmwdmonth "Date of HEP (lmw) - MONTH"
label variable heplmwdyear "Date of HEP (lmw) - YEAR"
label variable heplmwt "Time of HEP (lmw)"
label variable heplmwtampm "Time of HEP (lmw) (am/pm)"
label variable plad "Date of Antiplatelets"
label variable pladday "Date of Antiplatelets - DAY"
label variable pladmonth "Date of Antiplatelets - MONTH"
label variable pladyear "Date of Antiplatelets - YEAR"
label variable plat "Time of Antiplatelets"
label variable platampm "Time of Antiplatelets (am/pm)"
label variable statd "Date of Statin"
label variable statdday "Date of Statin - DAY"
label variable statdmonth "Date of Statin - MONTH"
label variable statdyear "Date of Statin - YEAR"
label variable statt "Time of Statin"
label variable stattampm "Time of Statin (am/pm)"
label variable fibrd "Date of Fibrinolytic Agents"
label variable fibrdday "Date of Fibrinolytic Agents - DAY"
label variable fibrdmonth "Date of Fibrinolytic Agents - MONTH"
label variable fibrdyear "Date of Fibrinolytic Agents - YEAR"
label variable fibrt "Time of Fibrinolytic Agents"
label variable fibrtampm "Time of Fibrinolytic Agents (am/pm)"
label variable aced "Date of ACE Inhibitors"
label variable acedday "Date of ACE Inhibitors - DAY"
label variable acedmonth "Date of ACE Inhibitors - MONTH"
label variable acedyear "Date of ACE Inhibitors - YEAR"
label variable acet "Time of ACE Inhibitors"
label variable acetampm "Time of ACE Inhibitors (am/pm)"
label variable arbsd "Date of ARBs"
label variable arbsdday "Date of ARBs - DAY"
label variable arbsdmonth "Date of ARBs - MONTH"
label variable arbsdyear "Date of ARBs - YEAR"
label variable arbst "Time of ARBs"
label variable arbstampm "Time of ARBs (am/pm)"
label variable corsd "Date of Corticosteroids"
label variable corsdday "Date of Corticosteroids - DAY"
label variable corsdmonth "Date of Corticosteroids - MONTH"
label variable corsdyear "Date of Corticosteroids - YEAR"
label variable corst "Time of Corticosteroids"
label variable corstampm "Time of Corticosteroids (am/pm)"
label variable antihd "Date of Antihypertensives"
label variable antihdday "Date of Antihypertensives - DAY"
label variable antihdmonth "Date of Antihypertensives - MONTH"
label variable antihdyear "Date of Antihypertensives - YEAR"
label variable antiht "Time of Antihypertensives"
label variable antihtampm "Time of Antihypertensives (am/pm)"
label variable nimod "Date of Nimodipine"
label variable nimodday "Date of Nimodipine - DAY"
label variable nimodmonth "Date of Nimodipine - MONTH"
label variable nimodyear "Date of Nimodipine - YEAR"
label variable nimot "Time of Nimodipine"
label variable nimotampm "Time of Nimodipine (am/pm)"
label variable antisd "Date of Antiseizures"
label variable antisdday "Date of Antiseizures - DAY"
label variable antisdmonth "Date of Antiseizures - MONTH"
label variable antisdyear "Date of Antiseizures - YEAR"
label variable antist "Time of Antiseizures"
label variable antistampm "Time of Antiseizures (am/pm)"
label variable tedd "Date of TED"
label variable teddday "Date of TED - DAY"
label variable teddmonth "Date of TED - MONTH"
label variable teddyear "Date of TED - YEAR"
label variable tedt "Time of TED"
label variable tedtampm "Time of TED (am/pm)"
label variable betad "Date of Beta Blockers"
label variable betadday "Date of Beta Blockers - DAY"
label variable betadmonth "Date of Beta Blockers - MONTH"
label variable betadyear "Date of Beta Blockers - YEAR"
label variable betat "Time of Beta Blockers"
label variable betatampm "Time of Beta Blockers (am/pm)"
label variable bivald "Date of Bivalrudin"
label variable bivaldday "Date of Bivalrudin - DAY"
label variable bivaldmonth "Date of Bivalrudin - MONTH"
label variable bivaldyear "Date of Bivalrudin - YEAR"
label variable bivalt "Time of Bivalrudin"
label variable bivaltampm "Time of Bivalrudin (am/pm)"
label variable copymeds "Copy data to heart arm?"
label variable edateyr_rx "Event YEAR"
label variable edatemondash_rx "MONTH"
label variable medications_complete "Complete?"
label variable ddoa "ABS Date"
label variable ddoat "ABS Time"
label variable dda "ABS DA"
label variable vstatus "Vital Status at discharge"
label variable disd "Date of discharge"
label variable disdday "Date of discharge - DAY"
label variable disdmonth "Date of discharge - MONTH"
label variable disdyear "Date of discharge - YEAR"
label variable dist "Time of discharge"
label variable distampm "Time of discharge (am/pm)"
label variable dod "Date of death"
label variable dodday "Date of death - DAY"
label variable dodmonth "Date of death - MONTH"
label variable dodyear "Date of death - YEAR"
label variable tod "Time of death"
label variable todampm "Time of death (am/pm)"
label variable pm "If deceased, was an autopsy performed?"
label variable codsame "Are causes of death (CODs) the SAME as those on Casefinding form?"
label variable cods "Cause(s) of death - How many are documented?"
label variable cod1 "1) Cause(s) of Death"
label variable cod2 "2) Cause(s) of Death"
label variable cod3 "3) Cause(s) of Death"
label variable cod4 "4) Cause(s) of Death"
label variable aspdis "Aspirin (ASA)"
label variable warfdis "Warfarin (Coumadin)"
label variable heplmwdis "Heparin (lmw) (LMWH-Low molecular weight heparin) (Clexane, Fragmin)"
label variable pladis "Antiplatelet Agents (Clopidogrel/Plavix, Ticagrelor, Prasugrel)"
label variable statdis "Statin (e.g. Lipitor, Zocor, Crestor, Pravachol, Lescol)"
label variable fibrdis "Fibrinolytic agents (streptokinase, alteplase, reteplase, tenecteplase)"
label variable acedis "Angiotensin-Converting Enzyme (ACE) Inhibitors (Captopril, Enalapril, Lisinopril, Ramipril)"
label variable arbsdis "Angiotensin II Receptor Blockers (ARBs) (Candesartan, Losartan, Telmisartan, Valsartan)"
label variable corsdis "Corticosteroids (Dexmethasone)"
label variable antihdis "Antihypertensives (Frusemide/Lasix, Amlodipine/Norvasc, Chlorthalidone, Hydrochlorothiazide, Indapamaide/Natrillix, Hydralazine, Spironolactone, Verapamil)"
label variable nimodis "Nimodipine (calcium channel blocker)"
label variable antisdis "Antiseizures (Phenytoin/Dilantin, Carbamazepine/Tregretol)"
label variable teddis "TED Stockings (pneumatic compression)"
label variable betadis "Beta Blockers (Metoprolol, Cardoxone, Propranolol)"
label variable bivaldis "Bivalrudin (thrombin inhibitor)"
label variable aspdosedis "Dose of ASA at discharge"
label variable dissysbp "Blood Pressure at Discharge - Systolic (mmHg)"
label variable disdiasbp "Blood Pressure at Discharge - Diastolic (mmHg)"
label variable dcomp "Did any complications occur during hospitalisation, following the diagnosis of AMI and/or Stroke, by time of discharge?"
label variable ddvt "Deep Vein Thrombosis (DVT)"
label variable dpneu "Pneumonia"
label variable dulcer "Decubitus ulcer"
label variable duti "Urinary Tract Infection (UTI)"
label variable dfall "Fall"
label variable dhydro "Hydrocephalus"
label variable dhaemo "Haemorrhagic transformation"
label variable doinfect "Other Infection / Septic Shock"
label variable dgibleed "Gastrointestinal (GI) Bleed"
label variable dccf "Congestive Cardiac Failure (CCF/CHF)"
label variable dcpang "Recurrent chest pain / angina"
label variable daneur "Ventricular aneurysm"
label variable dhypo "Postural hypotension"
label variable dblock "Heart Block (pacemaker needed)"
label variable dseizures "Seizures"
label variable dafib "Atrial Fibrillation (AF)"
label variable dcshock "Cardiogenic shock"
label variable dinfarct "Reinfarction"
label variable drenal "Renal failure"
label variable dcarest "Cardiac arrest"
label variable odcomp "Other complication(s) - How many (other than those above) are documented?"
label variable odcomp1 "1) Please specify other complication"
label variable odcomp2 "2) Please specify other complication"
label variable odcomp3 "3) Please specify other complication"
label variable odcomp4 "4) Please specify other complication"
label variable odcomp5 "5) Please specify other complication"
label variable disdxsame "Is DISCHARGE dx the SAME as ABSTRACTION dx?"
label variable disdxs___1 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=Ischaemic Stroke)"
label variable disdxs___2 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=Intracerebral Haemorrhage)"
label variable disdxs___3 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=Subarachnoid Haemorrhage)"
label variable disdxs___4 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=Unclassified Type)"
label variable disdxs___5 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=CVA)"
label variable disdxs___6 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=R/o query (?)CVA)"
label variable disdxs___7 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=TIA)"
label variable disdxs___8 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=R/o query (?)TIA)"
label variable disdxs___99 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable disdxs___88 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=partial date/time)"
label variable disdxs___999 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=Age / NRN year / BP ND)"
label variable disdxs___9999 "If patient alive at discharge, what was the STROKE diagnosis documented by physician at time of discharge? (choice=Trop / YEAR ND)"
label variable disdxh___1 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=STEMI)"
label variable disdxh___2 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=NSTEMI)"
label variable disdxh___3 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=AMI (definite))"
label variable disdxh___4 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=R/o query (?)AMI)"
label variable disdxh___5 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=ACS)"
label variable disdxh___6 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=R/o query (?)ACS)"
label variable disdxh___7 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=Unstable Angina)"
label variable disdxh___8 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=Chest pain ?cause)"
label variable disdxh___9 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=LBBB (new onset))"
label variable disdxh___10 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=Sudden cardiac death)"
label variable disdxh___99 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable disdxh___88 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=partial date/time)"
label variable disdxh___999 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=Age / NRN year / BP ND)"
label variable disdxh___9999 "If patient alive at discharge, what was the AMI diagnosis documented by physician at time of abstraction? (choice=Trop / YEAR ND)"
label variable odisdx "Other diagnosis(s) - How many (other than those above) are documented?"
label variable odisdx1 "1) Please specify other diagnosis"
label variable odisdx2 "2) Please specify other diagnosis"
label variable odisdx3 "3) Please specify other diagnosis"
label variable odisdx4 "4) Please specify other diagnosis"
label variable reclass "Was the final EVENT diagnosis reclassified by Clinical Director?"
label variable recdxs___1 "What was the STROKE diagnosis reclassified to? (choice=Ischaemic Stroke)"
label variable recdxs___2 "What was the STROKE diagnosis reclassified to? (choice=Intracerebral Haemorrhage)"
label variable recdxs___3 "What was the STROKE diagnosis reclassified to? (choice=Subarachnoid Haemorrhage)"
label variable recdxs___4 "What was the STROKE diagnosis reclassified to? (choice=Unclassified Type)"
label variable recdxs___5 "What was the STROKE diagnosis reclassified to? (choice=CVA)"
label variable recdxs___6 "What was the STROKE diagnosis reclassified to? (choice=R/o query (?)CVA)"
label variable recdxs___7 "What was the STROKE diagnosis reclassified to? (choice=TIA)"
label variable recdxs___8 "What was the STROKE diagnosis reclassified to? (choice=R/o query (?)TIA)"
label variable recdxs___99 "What was the STROKE diagnosis reclassified to? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable recdxs___88 "What was the STROKE diagnosis reclassified to? (choice=partial date/time)"
label variable recdxs___999 "What was the STROKE diagnosis reclassified to? (choice=Age / NRN year / BP ND)"
label variable recdxs___9999 "What was the STROKE diagnosis reclassified to? (choice=Trop / YEAR ND)"
label variable recdxh___1 "What was the AMI diagnosis reclassified to? (choice=STEMI)"
label variable recdxh___2 "What was the AMI diagnosis reclassified to? (choice=NSTEMI)"
label variable recdxh___3 "What was the AMI diagnosis reclassified to? (choice=AMI (definite))"
label variable recdxh___4 "What was the AMI diagnosis reclassified to? (choice=R/o query (?)AMI)"
label variable recdxh___5 "What was the AMI diagnosis reclassified to? (choice=ACS)"
label variable recdxh___6 "What was the AMI diagnosis reclassified to? (choice=R/o query (?)ACS)"
label variable recdxh___7 "What was the AMI diagnosis reclassified to? (choice=Unstable Angina)"
label variable recdxh___8 "What was the AMI diagnosis reclassified to? (choice=Chest pain ?cause)"
label variable recdxh___9 "What was the AMI diagnosis reclassified to? (choice=LBBB (new onset))"
label variable recdxh___10 "What was the AMI diagnosis reclassified to? (choice=Sudden cardiac death)"
label variable recdxh___99 "What was the AMI diagnosis reclassified to? (choice=ND / date ND / NK / Unknown / No record of use)"
label variable recdxh___88 "What was the AMI diagnosis reclassified to? (choice=partial date/time)"
label variable recdxh___999 "What was the AMI diagnosis reclassified to? (choice=Age / NRN year / BP ND)"
label variable recdxh___9999 "What was the AMI diagnosis reclassified to? (choice=Trop / YEAR ND)"
label variable orecdx "Other reclassified diagnosis(s) - How many (other than those above) are documented?"
label variable orecdx1 "1) Please specify other reclassified diagnosis"
label variable orecdx2 "2) Please specify other reclassified diagnosis"
label variable orecdx3 "3) Please specify other reclassified diagnosis"
label variable orecdx4 "4) Please specify other reclassified diagnosis"
label variable strunit "Was patient admitted to Stroke Unit?"
label variable sunitadmsame "Is stroke unit admission date SAME as hospital admission?"
label variable astrunitd "Date of Stroke Unit Admission"
label variable astrunitdday "Date of Stroke Unit Admission - DAY"
label variable astrunitdmonth "Date of Stroke Unit Admission - MONTH"
label variable astrunitdyear "Date of Stroke Unit Admission - YEAR"
label variable sunitdissame "Is stroke unit discharge date SAME as hospital discharge?"
label variable dstrunitd "Date of Stroke Unit Discharge"
label variable dstrunitdday "Date of Stroke Unit Discharge - DAY"
label variable dstrunitdmonth "Date of Stroke Unit Discharge - MONTH"
label variable dstrunitdyear "Date of Stroke Unit Discharge - YEAR"
label variable carunit "Was patient admitted to Cardiac Unit?"
label variable cunitadmsame "Is cardiac unit admission date SAME as hospital admission?"
label variable acarunitd "Date of Cardiac Unit Admission"
label variable acarunitdday "Date of Cardiac Unit Admission - DAY"
label variable acarunitdmonth "Date of Cardiac Unit Admission - MONTH"
label variable acarunitdyear "Date of Cardiac Unit Admission - YEAR"
label variable cunitdissame "Is cardiac unit discharge date SAME as hospital discharge?"
label variable dcarunitd "Date of Cardiac Unit Discharge"
label variable dcarunitdday "Date of Cardiac Unit Discharge - DAY"
label variable dcarunitdmonth "Date of Cardiac Unit Discharge - MONTH"
label variable dcarunitdyear "Date of Cardiac Unit Discharge - YEAR"
label variable readmit "Patient re-admitted to hospital for EVENT within 28 days following this discharge?"
label variable readmitadm "Date of Re-Admission"
label variable readmitdis "Date of Re-Admission Discharge"
label variable readmitdays "Number of days in hospital for this subsequent re-admission"
label variable copydis "Copy data to heart arm?"
label variable discharge_complete "Complete?"
label variable fu1call1 "Call Attempt 1"
label variable fu1call2 "Call Attempt 2"
label variable fu1call3 "Call Attempt 3"
label variable fu1call4 "Call Attempt 4"
label variable fu1type "Are you ready to do follow-up?"
label variable fu1doa "ABS Date"
label variable fu1da "ABS DA"
label variable fu1oda "Other ABS DA"
label variable edatefu1doadiff "Days between Date of Event and 28-day F/U Date"
label variable fu1day "Was it possible to interview the patient on the F/U date?"
label variable fu1oday "Please specify other reason"
label variable fu1sicf "Has the patient/representative given verbal consent?"
label variable fu1con "Please indicate who has given consent"
label variable fu1how "How was the 28-day F/U performed?"
label variable f1vstatus "What is the patients vital status at day 28?"
label variable fu1sit "What is the living situation of patient at day 28?"
label variable fu1osit "Please specify other living situation(s)"
label variable fu1readm "Patient re-admitted to hospital for EVENT within 28 days of event?"
label variable fu1los "If re-admitted, how many days did patient spend in hospital?"
label variable furesident "Have you (they) been resident in Barbados during last 12 months for:"
label variable ethnicity "What race do you (they) consider yourself (themselves) to be?"
label variable oethnic "Please specify other race(s)"
label variable education "What is the highest level of education you (they) have completed?"
label variable mainwork "Which of the following best describes your (their) main work status over last 12 months?"
label variable employ "What is your (their) current main occupation?"
label variable prevemploy "If retired/unemployed, what was your (their) previous main occupation?"
label variable pstrsit "What is your (their) living situation before the stroke?"
label variable pstrosit "Please specify other living situation(s)"
label variable rankin "Select appropriate option if patient/representative cannot or refuses to answer:"
label variable rankin1 "1) Did you (they) have any symptoms?"
label variable rankin2 "2) Were you (they) able to look after yourself (themselves) and carry out all normal activities"
label variable rankin3 "3) Were you (they) able to pay the bills, do shopping, cleaning, etc?"
label variable rankin4 "4) Were you (they) able to walk?"
label variable rankin5 "5) Were you (they) able to wash/bathe yourself (themselves)?"
label variable rankin6 "6) Did you (they) need to be lifted in and out of bed?"
label variable famhxs "Any family history of Stroke?"
label variable famhxa "Any family history of AMI?"
label variable mahxs "Mother"
label variable dahxs "Father"
label variable sibhxs "Sibling"
label variable mahxa "Mother"
label variable dahxa "Father"
label variable sibhxa "Sibling"
label variable smoke "Prior to this Stroke and/or AMI, did you (they) smoke?"
label variable stopsmoke "Date of you (they) gave up smoking completely?"
label variable stopsmkday "Date of stopped smoking - DAY"
label variable stopsmkmonth "Date of stopped smoking - MONTH"
label variable stopsmkyear "Date of stopped smoking - YEAR"
label variable stopsmokeage "At what age did you (they) stop smoking?  (auto-calculated) "
label variable smokeage "At what age did you (they) begin smoking?"
label variable cig "Cigarettes"
label variable pipe "Pipe"
label variable cigar "Cigars"
label variable otobacco "Other tobacco product"
label variable tobacmari "Tobacco with marijuana"
label variable marijuana "Marijuana"
label variable cignum "Cigarettes (number)"
label variable tobgram "Tobacco (grams)"
label variable cigarnum "Cigars (number)"
label variable spliffnum "Spliffs (number)"
label variable alcohol "Prior to this Stroke and/or AMI, did you (they) drink any alcohol?"
label variable stopalc "Date of you (they) gave up drinking completely?"
label variable stopalcday "Date of stopped drinking - DAY"
label variable stopalcmonth "Date of stopped drinking - MONTH"
label variable stopalcyear "Date of stopped drinking - YEAR"
label variable stopalcage "At what age did you (they) stop drinking?  (auto-calculated) "
label variable alcage "At what age did you (they) begin drinking?"
label variable beernumnd "Beer (bottles)"
label variable spiritnumnd "Spirits (shot glasses)"
label variable winenumnd "Wine (glasses)"
label variable beernum "Beer (bottles)"
label variable spiritnum "Spirits (shot glasses)"
label variable winenum "Wine (glasses)"
label variable f1rankin "Select appropriate option if patient/representative cannot or refuses to answer:"
label variable f1rankin1 "1) Did you (they) have any symptoms?"
label variable f1rankin2 "2) Were you (they) able to look after yourself (themselves) and carry out all normal activities?"
label variable f1rankin3 "3) Were you (they) able to pay the bills, do shopping, cleaning, etc?"
label variable f1rankin4 "4) Were you (they) able to walk?"
label variable f1rankin5 "5) Were you (they) able to wash/bathe yourself (themselves)?"
label variable f1rankin6 "6) Did you (they) need to be lifted in and out of bed?"
label variable copyfu1 "Copy data to heart arm?"
label variable day_fu_complete "Complete?"
label variable hcfr2020 "CFR (all months)"
label variable hcfr2020_jan "CFR (January)"
label variable hcfr2020_feb "CFR (February)"
label variable hcfr2020_mar "CFR (March)"
label variable hcfr2020_apr "CFR (April)"
label variable hcfr2020_may "CFR (May)"
label variable hcfr2020_jun "CFR (June)"
label variable hcfr2020_jul "CFR (July)"
label variable hcfr2020_aug "CFR (August)"
label variable hcfr2020_sep "CFR (September)"
label variable hcfr2020_oct "CFR (October)"
label variable hcfr2020_nov "CFR (November)"
label variable hcfr2020_dec "CFR (December)"
label variable hcfr2021 "CFR (all months)"
label variable hcfr2021_jan "CFR (January)"
label variable hcfr2021_feb "CFR (February)"
label variable hcfr2021_mar "CFR (March)"
label variable hcfr2021_apr "CFR (April)"
label variable hcfr2021_may "CFR (May)"
label variable hcfr2021_jun "CFR (June)"
label variable hcfr2021_jul "CFR (July)"
label variable hcfr2021_aug "CFR (August)"
label variable hcfr2021_sep "CFR (September)"
label variable hcfr2021_oct "CFR (October)"
label variable hcfr2021_nov "CFR (November)"
label variable hcfr2021_dec "CFR (December)"
label variable haspdash2020 "Proportion aspirin acutely (all months)"
label variable haspdash2020_jan "Proportion aspirin acutely (January)"
label variable haspdash2020_feb "Proportion aspirin acutely (February)"
label variable haspdash2020_mar "Proportion aspirin acutely (March)"
label variable haspdash2020_apr "Proportion aspirin acutely (April)"
label variable haspdash2020_may "Proportion aspirin acutely (May)"
label variable haspdash2020_jun "Proportion aspirin acutely (June)"
label variable haspdash2020_jul "Proportion aspirin acutely (July)"
label variable haspdash2020_aug "Proportion aspirin acutely (August)"
label variable haspdash2020_sep "Proportion aspirin acutely (September)"
label variable haspdash2020_oct "Proportion aspirin acutely (October)"
label variable haspdash2020_nov "Proportion aspirin acutely (November)"
label variable haspdash2020_dec "Proportion aspirin acutely (December)"
label variable haspdash2021 "Proportion aspirin acutely (all months)"
label variable haspdash2021_jan "Proportion aspirin acutely (January)"
label variable haspdash2021_feb "Proportion aspirin acutely (February)"
label variable haspdash2021_mar "Proportion aspirin acutely (March)"
label variable haspdash2021_apr "Proportion aspirin acutely (April)"
label variable haspdash2021_may "Proportion aspirin acutely (May)"
label variable haspdash2021_jun "Proportion aspirin acutely (June)"
label variable haspdash2021_jul "Proportion aspirin acutely (July)"
label variable haspdash2021_aug "Proportion aspirin acutely (August)"
label variable haspdash2021_sep "Proportion aspirin acutely (September)"
label variable haspdash2021_oct "Proportion aspirin acutely (October)"
label variable haspdash2021_nov "Proportion aspirin acutely (November)"
label variable haspdash2021_dec "Proportion aspirin acutely (December)"
label variable scfr2020 "CFR (all months)"
label variable scfr2020_jan "CFR (January)"
label variable scfr2020_feb "CFR (February)"
label variable scfr2020_mar "CFR (March)"
label variable scfr2020_apr "CFR (April)"
label variable scfr2020_may "CFR (May)"
label variable scfr2020_jun "CFR (June)"
label variable scfr2020_jul "CFR (July)"
label variable scfr2020_aug "CFR (August)"
label variable scfr2020_sep "CFR (September)"
label variable scfr2020_oct "CFR (October)"
label variable scfr2020_nov "CFR (November)"
label variable scfr2020_dec "CFR (December)"
label variable scfr2021 "CFR (all months)"
label variable scfr2021_jan "CFR (January)"
label variable scfr2021_feb "CFR (February)"
label variable scfr2021_mar "CFR (March)"
label variable scfr2021_apr "CFR (April)"
label variable scfr2021_may "CFR (May)"
label variable scfr2021_jun "CFR (June)"
label variable scfr2021_jul "CFR (July)"
label variable scfr2021_aug "CFR (August)"
label variable scfr2021_sep "CFR (September)"
label variable scfr2021_oct "CFR (October)"
label variable scfr2021_nov "CFR (November)"
label variable scfr2021_dec "CFR (December)"
label variable saspdash2020 "Proportion aspirin acutely (all months)"
label variable saspdash2020_jan "Proportion aspirin acutely (January)"
label variable saspdash2020_feb "Proportion aspirin acutely (February)"
label variable saspdash2020_mar "Proportion aspirin acutely (March)"
label variable saspdash2020_apr "Proportion aspirin acutely (April)"
label variable saspdash2020_may "Proportion aspirin acutely (May)"
label variable saspdash2020_jun "Proportion aspirin acutely (June)"
label variable saspdash2020_jul "Proportion aspirin acutely (July)"
label variable saspdash2020_aug "Proportion aspirin acutely (August)"
label variable saspdash2020_sep "Proportion aspirin acutely (September)"
label variable saspdash2020_oct "Proportion aspirin acutely (October)"
label variable saspdash2020_nov "Proportion aspirin acutely (November)"
label variable saspdash2020_dec "Proportion aspirin acutely (December)"
label variable saspdash2021 "Proportion aspirin acutely (all months)"
label variable saspdash2021_jan "Proportion aspirin acutely (January)"
label variable saspdash2021_feb "Proportion aspirin acutely (February)"
label variable saspdash2021_mar "Proportion aspirin acutely (March)"
label variable saspdash2021_apr "Proportion aspirin acutely (April)"
label variable saspdash2021_may "Proportion aspirin acutely (May)"
label variable saspdash2021_jun "Proportion aspirin acutely (June)"
label variable saspdash2021_jul "Proportion aspirin acutely (July)"
label variable saspdash2021_aug "Proportion aspirin acutely (August)"
label variable saspdash2021_sep "Proportion aspirin acutely (September)"
label variable saspdash2021_oct "Proportion aspirin acutely (October)"
label variable saspdash2021_nov "Proportion aspirin acutely (November)"
label variable saspdash2021_dec "Proportion aspirin acutely (December)"
label variable dashboards_complete "Complete?"
label variable rvpid "rid (RV record_id)"
label variable rvpidcfabs "pid (CF/ABS)"
label variable rvcfadoa "CF/ABS Date"
label variable rvcfada "CF/ABS DA"
label variable ocfada "CF/ABS other DA"
label variable rvflagd "Flag Date"
label variable rvflag "Flag Description"
label variable rvflag_old "Old value"
label variable rvflag_new "New value"
label variable rvflagcorrect "Is the flag correct?"
label variable rvaction "Action Taken"
label variable rvactiond "Date Action Taken"
label variable rvactionda "Action Taken By"
label variable rvactionoda "Action Taken By - Other"
label variable rvflagtot "Flag Total"
label variable reviewing_complete "Complete?"

order record_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance redcap_data_access_group tfdoastart tfdoatstart tfda tftype otftype tfsource cfupdate recid absdone disdone tfdepts___1 tfdepts___2 tfdepts___3 tfdepts___4 tfdepts___5 tfdepts___6 tfdepts___7 tfdepts___8 tfdepts___9 tfdepts___10 tfdepts___11 tfdepts___12 tfdepts___13 tfdepts___14 tfdepts___15 tfdepts___16 tfdepts___17 tfdepts___18 tfdepts___19 tfdepts___20 tfdepts___21 tfdepts___22 tfdepts___23 tfdepts___24 tfdepts___25 tfdepts___26 tfdepts___27 tfdepts___28 tfdepts___29 tfdepts___30 tfdepts___31 tfdepts___32 tfdepts___33 tfdepts___34 tfdepts___35 tfdepts___99 tfdepts___88 tfdepts___999 tfdepts___9999 tfwards___1 tfwards___2 tfwards___3 tfwards___4 tfwards___5 tfwards___6 tfwards___99 tfwards___88 tfwards___999 tfwards___9999 tfwardsdate tfmedrec___1 tfmedrec___2 tfmedrec___3 tfmedrec___4 tfmedrec___5 tfmedrec___99 tfmedrec___88 tfmedrec___999 tfmedrec___9999 tfmrdate tfpaypile tfmedpile tfgenpile totpile tfdrec___1 tfdrec___2 tfdrec___3 tfdrec___4 tfdrec___5 tfdrec___6 tfdrec___7 tfdrec___99 tfdrec___88 tfdrec___999 tfdrec___9999 tfaerec___1 tfaerec___2 tfaerec___3 tfaerec___4 tfaerec___5 tfaerec___99 tfaerec___88 tfaerec___999 tfaerec___9999 tfdoaend tfdoatend tfelapsed tracking_complete cfdoa cfdoat cfda sri srirec evolution sourcetype firstnf cfsource___1 cfsource___2 cfsource___3 cfsource___4 cfsource___5 cfsource___6 cfsource___7 cfsource___8 cfsource___9 cfsource___10 cfsource___11 cfsource___12 cfsource___13 cfsource___14 cfsource___15 cfsource___16 cfsource___17 cfsource___18 cfsource___19 cfsource___20 cfsource___21 cfsource___22 cfsource___23 cfsource___24 cfsource___25 cfsource___26 cfsource___27 cfsource___28 cfsource___29 cfsource___30 cfsource___31 cfsource___32 retsource oretsrce fname mname lname sex dob dobday dobmonth dobyear cfage cfage_da natregno nrnyear nrnmonth nrnday nrnnum recnum cfadmdate cfadmyr cfadmdatemon cfadmdatemondash initialdx hstatus slc dlc dlcyr dlcday dlcmonth dlcyear cfdod cfdodyr cfdodday cfdodmonth cfdodyear finaldx cfcods docname docaddr cstatus eligible ineligible pendrv duplicate duprec dupcheck requestdate1 requestdate2 requestdate3 nfdb nfdbrec reabsrec toabs copycf casefinding_complete adoa adoat ada mstatus resident citizen addr parish hometel worktel celltel fnamekin lnamekin sametel homekin workkin cellkin relation orelation copydemo demographics_complete ptmdoa ptmdoat ptmda fmc fmcplace ofmcplace fmcdate fmcdday fmcdmonth fmcdyear fmctime fmcampm hospital ohospital aeadmit dae tae taeampm daedis taedis taedisampm wardadmit dohsame doh toh tohampm arrivalmode ambcalld ambcallday ambcallmonth ambcallyear ambcallt ambcalltampm atscene atscnd atscnday atscnmonth atscnyear atscnt atscntampm frmscene frmscnd frmscnday frmscnmonth frmscnyear frmscnt frmscntampm sameadm hospd hospday hospmonth hospyear hospt hosptampm ward___1 ward___2 ward___3 ward___4 ward___5 ward___98 oward nohosp___1 nohosp___2 nohosp___3 nohosp___4 nohosp___5 nohosp___6 nohosp___98 nohosp___99 nohosp___88 nohosp___999 nohosp___9999 onohosp copyptm patient_management_complete edoa edoat eda ssym1 ssym2 ssym3 ssym4 hsym1 hsym2 hsym3 hsym4 hsym5 hsym6 hsym7 osym osym1 osym2 osym3 osym4 osym5 osym6 ssym1d ssym1day ssym1month ssym1year ssym2d ssym2day ssym2month ssym2year ssym3d ssym3day ssym3month ssym3year ssym4d ssym4day ssym4month ssym4year hsym1d hsym1day hsym1month hsym1year hsym1t hsym1tampm hsym2d hsym2day hsym2month hsym2year hsym3d hsym3day hsym3month hsym3year hsym4d hsym4day hsym4month hsym4year hsym5d hsym5day hsym5month hsym5year hsym6d hsym6day hsym6month hsym6year hsym7d hsym7day hsym7month hsym7year osymd osymday osymmonth osymyear sign1 sign2 sign3 sign4 sonset sday swalldate swalldday swalldmonth swalldyear cardmon nihss timi stype htype dxtype dstroke review reviewreason reviewer___1 reviewer___2 reviewer___3 reviewd edate fu1date edateyr edatemon edatemondash inhosp etime etimeampm age edateetime daetae ambcalldt onsetevetoae onsetambtoae cardiac cardiachosp resus sudd fname_eve lname_eve sex_eve slc_eve cstatus_eve eligible_eve fu1done copyeve f1vstatus_eve event_complete hxdoa hxdoat hxda pstroke pami pihd pcabg pcorangio pstrokeyr pamiyr dbchecked famstroke famami mumstroke dadstroke sibstroke mumami dadami sibami rfany smoker hcl af tia ccf htn diab hld alco drugs ovrf ovrf1 ovrf2 ovrf3 ovrf4 copyhx history_complete tdoa tdoat tda sysbp diasbp bpm bgunit bgmg bgmmol o2sat assess assess1 assess2 assess3 assess4 assess7 assess8 assess9 assess10 assess12 assess14 dieany dct decg dmri dcerangio dcarangio dcarus decho dctcorang dstress odie odie1 odie2 odie3 ct doct doctday doctmonth doctyear stime ctfeat ctinfarct ctsubhaem ctinthaem ckmbdone astdone tropdone tropcomm tropd tropdday tropdmonth tropdyear tropt troptampm troptype tropres trop1res trop2res ecg ecgd ecgdday ecgdmonth ecgdyear ecgt ecgtampm ecgs ischecg ecgantero ecgrv ecgant ecglat ecgpost ecginf ecgsep ecgnd oecg oecg1 oecg2 oecg3 oecg4 ecgfeat ecglbbb ecgaf ecgste ecgstd ecgpqw ecgtwv ecgnor ecgnorsin ecgomi ecgnstt ecglvh oecgfeat oecgfeat1 oecgfeat2 oecgfeat3 oecgfeat4 tiany tppv tnippv tdefib tcpr tmech tctcorang tpacetemp tcath tdhemi tvdrain oti oti1 oti2 oti3 copytests tests_complete dxdoa dxdoat dxda hcomp hdvt hpneu hulcer huti hfall hhydro hhaemo hoinfect hgibleed hccf hcpang haneur hhypo hblock hseizures hafib hcshock hinfarct hrenal hcarest ohcomp ohcomp1 ohcomp2 ohcomp3 ohcomp4 ohcomp5 absdxsame absdxs___1 absdxs___2 absdxs___3 absdxs___4 absdxs___5 absdxs___6 absdxs___7 absdxs___8 absdxs___99 absdxs___88 absdxs___999 absdxs___9999 absdxh___1 absdxh___2 absdxh___3 absdxh___4 absdxh___5 absdxh___6 absdxh___7 absdxh___8 absdxh___9 absdxh___10 absdxh___99 absdxh___88 absdxh___999 absdxh___9999 oabsdx oabsdx1 oabsdx2 oabsdx3 oabsdx4 copycomp complications_dx_complete rxdoa rxdoat rxda reperf repertype reperfd reperfdday reperfdmonth reperfdyear reperft reperftampm asp___1 asp___2 asp___3 asp___99 asp___88 asp___999 asp___9999 warf___1 warf___2 warf___3 warf___99 warf___88 warf___999 warf___9999 hep___1 hep___2 hep___3 hep___99 hep___88 hep___999 hep___9999 heplmw___1 heplmw___2 heplmw___3 heplmw___99 heplmw___88 heplmw___999 heplmw___9999 pla___1 pla___2 pla___3 pla___99 pla___88 pla___999 pla___9999 stat___1 stat___2 stat___3 stat___99 stat___88 stat___999 stat___9999 fibr___1 fibr___2 fibr___3 fibr___99 fibr___88 fibr___999 fibr___9999 ace___1 ace___2 ace___3 ace___99 ace___88 ace___999 ace___9999 arbs___1 arbs___2 arbs___3 arbs___99 arbs___88 arbs___999 arbs___9999 cors___1 cors___2 cors___3 cors___99 cors___88 cors___999 cors___9999 antih___1 antih___2 antih___3 antih___99 antih___88 antih___999 antih___9999 nimo___1 nimo___2 nimo___3 nimo___99 nimo___88 nimo___999 nimo___9999 antis___1 antis___2 antis___3 antis___99 antis___88 antis___999 antis___9999 ted___1 ted___2 ted___3 ted___99 ted___88 ted___999 ted___9999 beta___1 beta___2 beta___3 beta___99 beta___88 beta___999 beta___9999 bival___1 bival___2 bival___3 bival___99 bival___88 bival___999 bival___9999 aspdose aspd aspdday aspdmonth aspdyear aspt asptampm warfd warfdday warfdmonth warfdyear warft warftampm hepd hepdday hepdmonth hepdyear hept heptampm heplmwd heplmwdday heplmwdmonth heplmwdyear heplmwt heplmwtampm plad pladday pladmonth pladyear plat platampm statd statdday statdmonth statdyear statt stattampm fibrd fibrdday fibrdmonth fibrdyear fibrt fibrtampm aced acedday acedmonth acedyear acet acetampm arbsd arbsdday arbsdmonth arbsdyear arbst arbstampm corsd corsdday corsdmonth corsdyear corst corstampm antihd antihdday antihdmonth antihdyear antiht antihtampm nimod nimodday nimodmonth nimodyear nimot nimotampm antisd antisdday antisdmonth antisdyear antist antistampm tedd teddday teddmonth teddyear tedt tedtampm betad betadday betadmonth betadyear betat betatampm bivald bivaldday bivaldmonth bivaldyear bivalt bivaltampm copymeds edateyr_rx edatemondash_rx medications_complete ddoa ddoat dda vstatus disd disdday disdmonth disdyear dist distampm dod dodday dodmonth dodyear tod todampm pm codsame cods cod1 cod2 cod3 cod4 aspdis warfdis heplmwdis pladis statdis fibrdis acedis arbsdis corsdis antihdis nimodis antisdis teddis betadis bivaldis aspdosedis dissysbp disdiasbp dcomp ddvt dpneu dulcer duti dfall dhydro dhaemo doinfect dgibleed dccf dcpang daneur dhypo dblock dseizures dafib dcshock dinfarct drenal dcarest odcomp odcomp1 odcomp2 odcomp3 odcomp4 odcomp5 disdxsame disdxs___1 disdxs___2 disdxs___3 disdxs___4 disdxs___5 disdxs___6 disdxs___7 disdxs___8 disdxs___99 disdxs___88 disdxs___999 disdxs___9999 disdxh___1 disdxh___2 disdxh___3 disdxh___4 disdxh___5 disdxh___6 disdxh___7 disdxh___8 disdxh___9 disdxh___10 disdxh___99 disdxh___88 disdxh___999 disdxh___9999 odisdx odisdx1 odisdx2 odisdx3 odisdx4 reclass recdxs___1 recdxs___2 recdxs___3 recdxs___4 recdxs___5 recdxs___6 recdxs___7 recdxs___8 recdxs___99 recdxs___88 recdxs___999 recdxs___9999 recdxh___1 recdxh___2 recdxh___3 recdxh___4 recdxh___5 recdxh___6 recdxh___7 recdxh___8 recdxh___9 recdxh___10 recdxh___99 recdxh___88 recdxh___999 recdxh___9999 orecdx orecdx1 orecdx2 orecdx3 orecdx4 strunit sunitadmsame astrunitd astrunitdday astrunitdmonth astrunitdyear sunitdissame dstrunitd dstrunitdday dstrunitdmonth dstrunitdyear carunit cunitadmsame acarunitd acarunitdday acarunitdmonth acarunitdyear cunitdissame dcarunitd dcarunitdday dcarunitdmonth dcarunitdyear readmit readmitadm readmitdis readmitdays copydis discharge_complete fu1call1 fu1call2 fu1call3 fu1call4 fu1type fu1doa fu1da fu1oda edatefu1doadiff fu1day fu1oday fu1sicf fu1con fu1how f1vstatus fu1sit fu1osit fu1readm fu1los furesident ethnicity oethnic education mainwork employ prevemploy pstrsit pstrosit rankin rankin1 rankin2 rankin3 rankin4 rankin5 rankin6 famhxs famhxa mahxs dahxs sibhxs mahxa dahxa sibhxa smoke stopsmoke stopsmkday stopsmkmonth stopsmkyear stopsmokeage smokeage cig pipe cigar otobacco tobacmari marijuana cignum tobgram cigarnum spliffnum alcohol stopalc stopalcday stopalcmonth stopalcyear stopalcage alcage beernumnd spiritnumnd winenumnd beernum spiritnum winenum f1rankin f1rankin1 f1rankin2 f1rankin3 f1rankin4 f1rankin5 f1rankin6 copyfu1 day_fu_complete hcfr2020 hcfr2020_jan hcfr2020_feb hcfr2020_mar hcfr2020_apr hcfr2020_may hcfr2020_jun hcfr2020_jul hcfr2020_aug hcfr2020_sep hcfr2020_oct hcfr2020_nov hcfr2020_dec hcfr2021 hcfr2021_jan hcfr2021_feb hcfr2021_mar hcfr2021_apr hcfr2021_may hcfr2021_jun hcfr2021_jul hcfr2021_aug hcfr2021_sep hcfr2021_oct hcfr2021_nov hcfr2021_dec haspdash2020 haspdash2020_jan haspdash2020_feb haspdash2020_mar haspdash2020_apr haspdash2020_may haspdash2020_jun haspdash2020_jul haspdash2020_aug haspdash2020_sep haspdash2020_oct haspdash2020_nov haspdash2020_dec haspdash2021 haspdash2021_jan haspdash2021_feb haspdash2021_mar haspdash2021_apr haspdash2021_may haspdash2021_jun haspdash2021_jul haspdash2021_aug haspdash2021_sep haspdash2021_oct haspdash2021_nov haspdash2021_dec scfr2020 scfr2020_jan scfr2020_feb scfr2020_mar scfr2020_apr scfr2020_may scfr2020_jun scfr2020_jul scfr2020_aug scfr2020_sep scfr2020_oct scfr2020_nov scfr2020_dec scfr2021 scfr2021_jan scfr2021_feb scfr2021_mar scfr2021_apr scfr2021_may scfr2021_jun scfr2021_jul scfr2021_aug scfr2021_sep scfr2021_oct scfr2021_nov scfr2021_dec saspdash2020 saspdash2020_jan saspdash2020_feb saspdash2020_mar saspdash2020_apr saspdash2020_may saspdash2020_jun saspdash2020_jul saspdash2020_aug saspdash2020_sep saspdash2020_oct saspdash2020_nov saspdash2020_dec saspdash2021 saspdash2021_jan saspdash2021_feb saspdash2021_mar saspdash2021_apr saspdash2021_may saspdash2021_jun saspdash2021_jul saspdash2021_aug saspdash2021_sep saspdash2021_oct saspdash2021_nov saspdash2021_dec dashboards_complete rvpid rvpidcfabs rvcfadoa rvcfada ocfada rvflagd rvflag rvflag_old rvflag_new rvflagcorrect rvaction rvactiond rvactionda rvactionoda rvflagtot reviewing_complete 
set more off
describe

** The above code was generated by REDCap's export to Stata option on 01-Nov-2022 so now save this auto-formatted dataset (note: the header and paths were added post export)
save "`datapath'\version03\2-working\BNRCVDCORE_FormattedData", replace