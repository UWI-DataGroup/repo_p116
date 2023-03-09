** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3m_clean fu_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      07-MAR-2023
    // 	date last modified      08-MAR-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb 28-day F/U form
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
    log using "`logpath'\3m_clean fu_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned demo form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_dis", clear

count //1145

** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

********************
** Follow-up Info **
********************
****************************
** Ready to do follow-up? **
****************************
** Missing
count if fu1type==. & day_fu_complete!=0 & day_fu_complete!=. //1 - stroke record 3247 has entire F/U form blank but case status=pending 28-d f/u so leave as is
** Missing
count if eligible!=6 & sd_casetype==1 & (day_fu_complete==0|day_fu_complete==.) //9 - all have case status of pending 28-d f/u and 2 deceased before 28-d (these already corrected in dofile 3l_clean dis_cvd.do) so leave other 7 as is since they're alive
** Invalid missing code
count if fu1type==88|fu1type==99|fu1type==999|fu1type==9999 //0
** Create variable for checking this auto-calculated variable in CVDdb
gen fu1doa2=dofc(fu1doa)
format fu1doa2 %dM_d,_CY
gen edatefu1doadiff2=fu1doa2-edate
count if edatefu1doadiff!=. & edatefu1doadiff2!=. & edatefu1doadiff!=edatefu1doadiff2 //25
replace edatefu1doadiff=edatefu1doadiff2 if edatefu1doadiff!=. & edatefu1doadiff2!=. & edatefu1doadiff!=edatefu1doadiff2 //25 changes
count if edatefu1doadiff==. & edatefu1doadiff2!=. //50
replace edatefu1doadiff=edatefu1doadiff2 if edatefu1doadiff==. & edatefu1doadiff2!=. //50 changes
drop edatefu1doadiff2

**************
** ABS Date **
**************
** Note: use fu1doa2 created above for some of these checks
** Missing date
count if fu1doa==. & fu1type==1 //1 - stroke record 2244 already corrected in dofile 3l_clean dis_cvd.do so when DA performs corrections this field should be completed with date correction done
** Invalid (before DOB)
count if dob!=. & fu1doa2!=. & fu1doa2<dob //0
** possibly Invalid (before CFAdmDate)
count if fu1doa2!=. & cfadmdate!=. & fu1doa2<cfadmdate //0
** possibly Invalid (before DLC/DOD)
count if dlc!=. & fu1doa2!=. & fu1doa2<dlc //1 - pt still in hosp at time of F/U
count if cfdod!=. & fu1doa2!=. & fu1doa2<cfdod //28 - pts died after F/U done
** possibly Invalid (before A&EAdmDate)
count if fu1doa2!=. & dae!=. & fu1doa2<dae //0
** possibly Invalid (before WardAdmDate)
count if fu1doa2!=. & doh!=. & fu1doa2<doh //0
** Invalid (future date)
drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY
count if fu1doa2!=. & fu1doa2>sd_currentdate //0
** Invalid (before NotifiedDate)
count if fu1doa2!=. & ambcalld!=. & fu1doa2<ambcalld //0
** Invalid (before AtSceneDate)
count if fu1doa2!=. & atscnd!=. & fu1doa2<atscnd //0
** Invalid (before FromSceneDate)
count if fu1doa2!=. & frmscnd!=. & fu1doa2<frmscnd //0
** Invalid (before AtHospitalDate)
count if fu1doa2!=. & hospd!=. & fu1doa2<hospd //0
** Invalid (before EventDate)
count if fu1doa2!=. & edate!=. & fu1doa2<edate //0


****************************
** Interview on f/u date? **
****************************
** Missing
count if fu1day==. & fu1type==1 //0
** Invalid missing code
count if fu1day==88|fu1day==99|fu1day==999|fu1day==9999 //0
** Invalid (Interview on f/u date=Yes; Days bet. event & f/u > 30)
count if fu1day==1 & edatefu1doadiff>30 //3 - stroke records 3024 + 3128 corrected below; heart record 3351 not corrected as days bet. event only applies to rankin
** Invalid (interview on f/u date=No pt deceased; vstatus at f/u=alive/unk)
count if fu1day==3 & f1vstatus!=2 //0
** possibly Invalid (other reason=options interview on f/u date)
count if fu1day!=2 & fu1oday!="" //0
count if fu1oday!="" //334 - reviewed and all are correct
** Invalid (Interview on f/u date=Other; Other reason is blank)
count if fu1day==2 & (fu1oday==""|fu1oday=="99") //0
** Invalid (Interview on f/u date NOT=Yes; 28-d Rankin NOT blank)
count if fu1day!=1 & f1rankin1!=. //0
count if fu1day!=1 & f1rankin2!=. //0
count if fu1day!=1 & f1rankin3!=. //0
count if fu1day!=1 & f1rankin4!=. //0
count if fu1day!=1 & f1rankin5!=. //0
count if fu1day!=1 & f1rankin6!=. //0

***************************
** Verbal consent given? **
***************************
** Missing
count if fu1sicf==. & fu1day!=. & fu1day!=3 //0
** Invalid missing code
count if fu1sicf==88|fu1sicf==99|fu1sicf==999|fu1sicf==9999 //0
** Invalid (verbal consent=No contact after 4 attempts; Call attempts are blank)
count if fu1sicf==5 & (fu1call1==.|fu1call2==.|fu1call3==.|fu1call4==.) //0

***********************
** Who gave consent? **
***********************
** Missing
count if fu1con==. & fu1sicf==1 //0
** Invalid missing code
count if fu1con==88|fu1con==99|fu1con==999|fu1con==9999 //0

****************************
** How was f/u performed? **
****************************
** Missing
count if fu1how==. & fu1sicf==1 //1 - stroke record 2819 unanswered by DA so corrected below
** Invalid missing code
count if fu1how==88|fu1how==99|fu1how==999|fu1how==9999 //0

****************************
** Vital Status at day 28 **
****************************
** Missing
count if f1vstatus==. & fu1day!=. //0
** Invalid missing code
count if f1vstatus==88|f1vstatus==999|f1vstatus==9999 //0
** possibly Invalid (vstatus on CF form=deceased; f1vstatus at FU NOT=deceased; pt died before FU done)
count if slc==2 & f1vstatus!=. & f1vstatus!=2 & cfdod<fu1doa2 //12 - stroke record 1729 for NS to review; heart and stroke records 1899 + 1971 leave as is since they were alive at day 28; others corrected below - those that were alive at day 28 but were documented as deceased on FU form was changed to alive on FU form + those that were deceased before day 28 were changed from No-other reason to No-pt deceased and changed from 99 to deceased on FU form
gen double fu1date=edate+28
format fu1date %dM_d,_CY
//list sd_etype record_id slc f1vstatus edate fu1date cfdod fu1doa2 edatefu1doadiff if slc==2 & f1vstatus!=. & f1vstatus!=2 & cfdod<fu1doa2
//order sd_etype record_id slc f1vstatus edate fu1date cfdod fu1doa2 fu1day fu1oday fu1sicf fu1con fu1how f1vstatus fu1sit fu1osit fu1readm fu1los furesident ethnicity oethnic education mainwork
** possibly Invalid (f1vstatus at FU=deceased; pt was alive at day 28; FU done late)
count if f1vstatus==2 & cfdod>fu1date //37 - heart records 2704 + 2840 + stroke record 3294 changed from verbal consent=Yes to verbal consent=No-pt incapable; all records corrected below - fu1day changed from No-pt deceased to No-other reason, other reason added, verbal consent=No-pt incapable, f1vstatus changed from deceased to alive
//list sd_etype record_id slc f1vstatus edate fu1date cfdod fu1doa2 edatefu1doadiff if f1vstatus==2 & cfdod>fu1date
//list sd_etype record_id slc f1vstatus edate fu1date cfdod fu1doa2 edatefu1doadiff if f1vstatus==2 & cfdod>fu1date & edoa>fu1date: this list shows which were late due to late abs vs late call - need this for correcting fu1oday variable
** Invalid (slc on CF=alive; f1vstatus on FU=deceased)
count if slc==1 & f1vstatus==2 //0
** Invalid (vstatus at discharge=deceased; f1vstatus on FU=alive)
count if vstatus==2 & f1vstatus!=. & f1vstatus!=2 //0





** Corrections from above checks
destring flag860 ,replace
destring flag1785 ,replace
destring flag858 ,replace
destring flag1783 ,replace


** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
//replace fu1how=99999 if record_id==""


replace flag860=fu1how if record_id=="2819"
replace fu1how=2 if record_id=="2819" //see above
replace flag1785=fu1how if record_id=="2819"

replace flag856=fu1day if record_id=="3024"|record_id=="3128"|record_id=="2722"|record_id=="2892"|record_id=="3704"|record_id=="4115"|record_id=="4196"
replace fu1day=2 if record_id=="3024"|record_id=="3128" //see above
replace fu1day=3 if record_id=="2722"|record_id=="2892"|record_id=="3704"|record_id=="4115"|record_id=="4196" //see above
replace flag1781=fu1day if record_id=="3024"|record_id=="3128"|record_id=="2722"|record_id=="2892"|record_id=="3704"|record_id=="4115"|record_id=="4196"

replace flag857=fu1oday if record_id=="3024"|record_id=="3128"
replace fu1oday="Error found during annual report cleaning - interview done after f/u date" if record_id=="3024"|record_id=="3128" //see above
replace flag1782=fu1oday if record_id=="3024"|record_id=="3128"

replace f1rankin1=. if record_id=="3024"|record_id=="3128" //CVDdb will prompt DA to erase this value when they make above corrections
replace f1rankin2=. if record_id=="3024"|record_id=="3128" //CVDdb will prompt DA to erase this value when they make above corrections
replace f1rankin3=. if record_id=="3024"|record_id=="3128" //CVDdb will prompt DA to erase this value when they make above corrections
replace f1rankin4=. if record_id=="3024"|record_id=="3128" //CVDdb will prompt DA to erase this value when they make above corrections
replace f1rankin5=. if record_id=="3024"|record_id=="3128" //CVDdb will prompt DA to erase this value when they make above corrections
replace f1rankin6=. if record_id=="3024"|record_id=="3128" //CVDdb will prompt DA to erase this value when they make above corrections
replace fu1oday="" if record_id=="2722"|record_id=="2892"|record_id=="3704"|record_id=="4115"|record_id=="4196" //CVDdb will prompt DA to erase this value when they make above corrections
replace fu1sicf=. if record_id=="2722"|record_id=="2892"|record_id=="3704"|record_id=="4115"|record_id=="4196" //CVDdb will prompt DA to erase this value when they make above corrections
replace fu1con=. if record_id=="2704"|record_id=="2840"|record_id=="3294" //CVDdb will prompt DA to erase this value when they make above corrections
replace fu1how=. if record_id=="2704"|record_id=="2840"|record_id=="3294" //CVDdb will prompt DA to erase this value when they make above corrections


replace flag861=f1vstatus if record_id=="1956"|record_id=="2720"|record_id=="2722"|record_id=="2834"|record_id=="2892"|record_id=="2938"|record_id=="3704"|record_id=="4115"|record_id=="4196"
replace f1vstatus=2 if record_id=="2722"|record_id=="2892"|record_id=="3704"|record_id=="4115"|record_id=="4196" //see above
replace f1vstatus=1 if record_id=="1956"|record_id=="2720"|record_id=="2834"|record_id=="2938" //see above
replace flag1786=f1vstatus if record_id=="1956"|record_id=="2720"|record_id=="2722"|record_id=="2834"|record_id=="2892"|record_id=="2938"|record_id=="3704"|record_id=="4115"|record_id=="4196"

replace flag856=fu1day if record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"
replace fu1day=2 if record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395" //see above
replace flag1781=fu1day if record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"

replace flag857=fu1oday if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"
replace fu1oday="Late call; pt died after day 28 but before FU call" if record_id=="2302"|record_id=="2704"|record_id=="3087" //see above
replace fu1oday="Late abstraction; pt died after day 28 but before FU call" if record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395" //see above
replace flag1782=fu1oday if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"

replace flag858=fu1sicf if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"
replace fu1sicf=3 if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395" //see above
replace flag1783=fu1sicf if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"

replace flag861=f1vstatus if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"
replace f1vstatus=1 if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395" //see above
replace flag1786=f1vstatus if record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
drop sd_currentdate
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

replace flagdate=sd_currentdate if record_id=="2819"|record_id=="3024"|record_id=="3128"|record_id=="1956"|record_id=="2720"|record_id=="2722"|record_id=="2834"|record_id=="2892"|record_id=="2938"|record_id=="3704"|record_id=="4115"|record_id=="4196"|record_id=="2704"|record_id=="2840"|record_id=="3294"|record_id=="1833"|record_id=="1856"|record_id=="1873"|record_id=="1905"|record_id=="1946"|record_id=="2084"|record_id=="2153"|record_id=="2212"|record_id=="2275"|record_id=="2290"|record_id=="2302"|record_id=="2322"|record_id=="2646"|record_id=="2745"|record_id=="2883"|record_id=="2989"|record_id=="3087"|record_id=="3305"|record_id=="3318"|record_id=="3347"|record_id=="3362"|record_id=="3389"|record_id=="3418"|record_id=="3438"|record_id=="3457"|record_id=="3460"|record_id=="3461"|record_id=="3634"|record_id=="3754"|record_id=="3847"|record_id=="3916"|record_id=="3971"|record_id=="4104"|record_id=="4395"


********************************
** Living situation at day 28 **
********************************
** Missing
count if fu1sit==. & fu1sicf==1 //2 - stroke record 2300 pt died before day 28 so corrected below
** Invalid missing code
count if fu1sit==88|fu1sit==999|fu1sit==9999 //0
** possibly Invalid (other reason=options for living situation)
count if fu1osit!="" //3 - reviewed and will leave as is although would've chosen relative's home and own home for heart records 2808 + 3361, respectively
** Invalid (Living situation=Other; Other reason is blank)
count if fu1sit==98 & (fu1osit==""|fu1osit=="99") //0

********************************
** Re-admitted within 28 days **
********************************
** Missing
count if fu1readm==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if fu1readm==9999 //0
** Missing
count if fu1readm==1 & fu1los==. //0
** Invalid (Days greater than 998)
count if fu1los>998 & fu1los!=. & fu1los!=999 //0

***************
** Ethnicity **
***************
** Missing
count if ethnicity==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if ethnicity==88|ethnicity==999|ethnicity==9999 //0
** JC 08mar2023: Other ethnicity not entered for any of the cases so this variable is byte instead of string in Stata
tostring oethnic ,replace
replace oethnic="" if oethnic=="." //1145 changes
** possibly Invalid (other reason=options for ethnicity)
count if oethnic!="" //0
** Invalid (Ethnicity=Other; Other reason is blank)
count if ethnicity==98 & (oethnic==""|oethnic=="99") //0

***************
** Education **
***************
** Missing
count if education==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if education==88|education==999|education==9999 //0

*****************
** Work Status **
*****************
** Missing (mainwork)
count if mainwork==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if mainwork==88|mainwork==999|mainwork==9999 //0
** Missing (current work)
count if employ=="" & mainwork!=. & mainwork<5 //0
** Invalid missing code
count if employ=="88"|employ=="99"|employ=="999"|employ=="9999" //0
** Missing (previous work)
count if prevemploy=="" & (mainwork==7|mainwork==8) //0
** Invalid missing code
count if prevemploy=="88"|prevemploy=="99"|prevemploy=="999"|prevemploy=="9999" //2 - leave as is since cannot correct at this stage

********************************
** Living situation prestroke **
********************************
** Missing
count if pstrsit==. & sd_etype==1 & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if pstrsit==88|pstrsit==999|pstrsit==9999 //0
** possibly Invalid (other reason=options for living situation)
count if pstrosit!="" //1 - reviewed and it is correct
** Invalid (Living situation=Other; Other reason is blank)
count if pstrsit==98 & (pstrosit==""|pstrosit=="99") //0




** Corrections from above checks
replace flag856=fu1day if record_id=="2300"|record_id=="3331"
replace fu1day=3 if record_id=="2300"|record_id=="3331" //see above
replace flag1781=fu1day if record_id=="2300"|record_id=="3331"

replace fu1sicf=. if record_id=="2300"|record_id=="3331" //CVDdb will prompt DA to erase this value when they make above corrections
replace fu1con=. if record_id=="2300"|record_id=="3331" //CVDdb will prompt DA to erase this value when they make above corrections
replace fu1how=. if record_id=="2300"|record_id=="3331" //CVDdb will prompt DA to erase this value when they make above corrections


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2300"|record_id=="3331"


***********************
** Pre-stroke Rankin **
***********************
** Missing (cannot/refuse to answer rankin)
count if rankin==. & sd_etype==1 & f1vstatus==1 & fu1sicf==1 & rankin1==. //0
** Invalid missing code
count if rankin==88|rankin==99|rankin==999|rankin==9999 //0
** Missing (1) - same as above
count if rankin==. & sd_etype==1 & f1vstatus==1 & fu1sicf==1 & rankin1==. //0
** Invalid missing code
count if rankin1==88|rankin1==99|rankin1==999|rankin1==9999 //0
** Missing (2)
count if rankin2==. & rankin1==1 //0
** Invalid missing code
count if rankin2==88|rankin2==99|rankin2==999|rankin2==9999 //0
** possibly Invalid (rankin1=No; rankin2 NOT blank)
count if rankin1==2 & rankin2!=. //0
** Missing (3)
count if rankin3==. & rankin2==2 //0
** Invalid missing code
count if rankin3==88|rankin3==99|rankin3==999|rankin3==9999 //0
** possibly Invalid (rankin2=Yes; rankin3 NOT blank)
count if rankin2==1 & rankin3!=. //0
** Missing (4)
count if rankin4==. & rankin3==2 //0
** Invalid missing code
count if rankin4==88|rankin4==99|rankin4==999|rankin4==9999 //0
** possibly Invalid (rankin3=Yes; rankin4 NOT blank)
count if rankin3==1 & rankin4!=. //0
** Missing (5)
count if rankin5==. & rankin4==2 //0
** Invalid missing code
count if rankin5==88|rankin5==99|rankin5==999|rankin5==9999 //0
** possibly Invalid (rankin4=Yes; rankin5 NOT blank)
count if rankin4==1 & rankin5!=. //0
** Missing (6)
count if rankin6==. & rankin5==2 //0
** Invalid missing code
count if rankin6==88|rankin6==99|rankin6==999|rankin6==9999 //0
** possibly Invalid (rankin5=Yes; rankin6 NOT blank)
count if rankin5==1 & rankin6!=. //0

********************
** Family History **
********************
***********************
** Family Hx Stroke? **
***********************
** Missing
count if famhxs==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if famhxs==88|famhxs==999|famhxs==9999 //0
** Invalid (famhxs=No/ND; famhxs options=Yes)
count if (famhxs==2|famhxs==99) & (mahxs==1|dahxs==1|sibhxs==1) //0
** Invalid (famhxs=Yes; famhxs options NOT=Yes)
count if famhxs==1 & mahxs!=1 & dahxs!=1 & sibhxs!=1 //0
** Invalid (famhxs=Yes/No; famhxs options all=ND)
count if famhxs!=99 & mahxs==99 & dahxs==99 & sibhxs==99 //0
********************
** Family Hx AMI? **
********************
** Missing
count if famhxa==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if famhxa==88|famhxa==999|famhxa==9999 //0
** Invalid (famhxa=No/ND; famhxa options=Yes)
count if (famhxa==2|famhxa==99) & (mahxa==1|dahxa==1|sibhxa==1) //0
** Invalid (famhxa=Yes; famhxa options NOT=Yes)
count if famhxa==1 & mahxa!=1 & dahxa!=1 & sibhxa!=1 //1 - heart record 2484 corrected below
** Invalid (famhxa=Yes/No; famhxa options all=ND)
count if famhxa!=99 & mahxa==99 & dahxa==99 & sibhxa==99 //0
********************
** Mother Stroke? **
********************
** Missing
count if famhxs==1 & mahxs==. //0
** Invalid missing code
count if mahxs==88|mahxs==999|mahxs==9999 //0
********************
** Father Stroke? **
********************
** Missing
count if famhxs==1 & dahxs==. //0
** Invalid missing code
count if dahxs==88|dahxs==999|dahxs==9999 //0
*********************
** Sibling Stroke? **
*********************
** Missing
count if famhxs==1 & sibhxs==. //0
** Invalid missing code
count if sibhxs==88|sibhxs==999|sibhxs==9999 //0
*****************
** Mother AMI? **
*****************
** Missing
count if famhxa==1 & mahxa==. //0
** Invalid missing code
count if mahxa==88|mahxa==999|mahxa==9999 //0
*****************
** Father AMI? **
*****************
** Missing
count if famhxa==1 & dahxa==. //0
** Invalid missing code
count if dahxa==88|dahxa==999|dahxa==9999 //0
******************
** Sibling AMI? **
******************
** Missing
count if famhxa==1 & sibhxa==. //0
** Invalid missing code
count if sibhxa==88|sibhxa==999|sibhxa==9999 //0


**************************
** Smoking History Info **
**************************
*********************
** Did they smoke? **
*********************
** Missing
count if smoke==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if smoke==88|smoke==999|smoke==9999 //0

*********************
** Stop Smoke Date **
*********************
** Missing
count if stopsmoke==. & smoke==3 //9 - entered as 99 in CVDdb but stroke records 2136, 2856, 2885, 3060 + heart record 2802 has partial dates in DA comments so corrected below
** Invalid (before DOB)
count if dob!=. & stopsmoke!=. & stopsmoke<dob //0
** Invalid (after FU date)
count if fu1doa2!=. & stopsmoke!=. & stopsmoke>fu1doa2 //1 - heart record 3308 corrected below
** possibly Invalid (after DLC/DOD)
count if dlc!=. & stopsmoke!=. & stopsmoke>dlc //1 - leave as is
count if cfdod!=. & stopsmoke!=. & stopsmoke>cfdod //0
** Invalid (future date)
count if stopsmoke!=. & stopsmoke>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if smoke==3 & stopsmoke==. & stopsmkday==99 & stopsmkmonth==99 & stopsmkyear==9999 //0
** possibly Invalid (stop smoke date not partial but partial field not blank)
count if stopsmoke==. & stopsmkday!=. & stopsmkmonth!=. & stopsmkyear!=. //1 - it's correct leave as is
//replace stopsmkday=. if stopsmoke==. & stopsmkday!=. & stopsmkmonth!=. & stopsmkyear!=. //0 changes
//replace stopsmkmonth=. if stopsmoke==. & stopsmkmonth!=. & stopsmkyear!=. //0 changes
//replace stopsmkyear=. if stopsmoke==. & stopsmkyear!=. //0 changes
count if stopsmoke==. & (stopsmkday!=. | stopsmkmonth!=. | stopsmkyear!=.) //1 - it's correct leave as is
** Invalid missing code (notified date partial fields)
count if stopsmkday==88|stopsmkday==999|stopsmkday==9999 //0
count if stopsmkmonth==88|stopsmkmonth==999|stopsmkmonth==9999 //0
count if stopsmkyear==88|stopsmkyear==99|stopsmkyear==999 //0





** Corrections from above checks
destring flag883 ,replace
destring flag1808 ,replace
destring flag891 ,replace
destring flag1816 ,replace
destring flag892 ,replace
destring flag1817 ,replace
destring flag893 ,replace
destring flag1818 ,replace
destring flag894 ,replace
destring flag1819 ,replace
destring flag895 ,replace
destring flag1820 ,replace


replace flag883=famhxa if record_id=="2484"
replace famhxa=2 if record_id=="2484" //see above
replace flag1808=famhxa if record_id=="2484"

replace mahxa=. if record_id=="2484" //CVDdb will prompt DA to erase this value when they make above corrections
replace dahxa=. if record_id=="2484" //CVDdb will prompt DA to erase this value when they make above corrections
replace sibhxa=. if record_id=="2484" //CVDdb will prompt DA to erase this value when they make above corrections

replace flag892=stopsmkday if record_id=="2136"|record_id=="2802"|record_id=="2856"
replace stopsmkday=99 if record_id=="2136"|record_id=="2802"|record_id=="2856" //see above
replace flag1817=stopsmkday if record_id=="2136"|record_id=="2802"|record_id=="2856"

replace flag893=stopsmkmonth if record_id=="2136"|record_id=="2802"|record_id=="2856"
replace stopsmkmonth=01 if record_id=="2136" //see above
replace stopsmkmonth=99 if record_id=="2802"|record_id=="2856" //see above
replace flag1818=stopsmkmonth if record_id=="2136"|record_id=="2802"|record_id=="2856"

replace flag894=stopsmkyear if record_id=="2136"|record_id=="2802"|record_id=="2856"
replace stopsmkyear=2021 if record_id=="2136" //see above
replace stopsmkyear=1991 if record_id=="2802" //see above
replace stopsmkyear=2018 if record_id=="2856" //see above
replace flag1819=stopsmkyear if record_id=="2136"|record_id=="2802"|record_id=="2856"

replace flag895=smokeage if record_id=="2136"
replace smokeage=27 if record_id=="2136" //see above
replace flag1820=smokeage if record_id=="2136"

replace flag891=stopsmoke if record_id=="2885"|record_id=="3060"|record_id=="3308"
replace stopsmoke=edate if record_id=="2885"|record_id=="3060" //see above
replace stopsmoke=stopsmoke-365 if record_id=="3308" //see above
replace flag1816=stopsmoke if record_id=="2885"|record_id=="3060"|record_id=="3308"

** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2484"|record_id=="2136"|record_id=="2802"|record_id=="2856"|record_id=="2885"|record_id=="3060"|record_id=="3308"

STOP

*************************
** Age stopped smoking **
*************************
** Create variable for age stopped smoking as this variable is auto-calculated in CVDdb so need to check it's correct
gen stopsmokeage3=(stopsmoke-dob)/365.25
gen stopsmokeage2=int(stopsmokeage3)
count if stopsmokeage!=. & stopsmokeage2!=. & stopsmokeage!=stopsmokeage2 //1
//list record_id dob stopsmoke stopsmokeage stopsmokeage2 if stopsmokeage!=. & stopsmokeage2!=. & stopsmokeage!=stopsmokeage2
count if dob!=. & stopsmoke!=. & stopsmokeage==. //4
count if dob!=. & stopsmoke!=. & stopsmokeage2==. //0
replace stopsmokeage=stopsmokeage2 //5 changes
drop stopsmokeage2

***********************
** Age began smoking **
***********************
** Missing
count if smokeage==. & smoke!=. & smoke<4 //0
** Invalid missing code
count if smokeage==9999 //0
** Invalid (age began smoking<5)
count if smokeage<5 //0
** Invalid (age stopped smoking before age began smoking)
count if stopsmokeage!=. & smokeage!=. & smokeage!=999 & stopsmokeage<smokeage //0
** Invalid (age at event before age began smoking)
count if age!=. & smokeage!=. & smokeage!=999 & age<smokeage //0





STOP
********************************
** Discharge Medications Info **
********************************
*************
** Aspirin **
*************
** Missing
count if aspdis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if aspdis==88|aspdis==999|aspdis==9999 //0
**************
** Warfarin **
**************
** Missing
count if warfdis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if warfdis==88|warfdis==999|warfdis==9999 //0
*******************
** Heparin (lmw) **
*******************
** Missing
count if heplmwdis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if heplmwdis==88|heplmwdis==999|heplmwdis==9999 //0
*******************
** Antiplatelets **
*******************
** Missing
count if pladis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if pladis==88|pladis==999|pladis==9999 //0
************
** Statin **
************
** Missing
count if statdis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if statdis==88|statdis==999|statdis==9999 //0
*******************
** Fibrinolytics **
*******************
** Missing
count if fibrdis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if fibrdis==88|fibrdis==999|fibrdis==9999 //0
*********
** ACE **
*********
** Missing
count if acedis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if acedis==88|acedis==999|acedis==9999 //0
**********
** ARBs **
**********
** Missing
count if arbsdis==. & vstatus!=2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if arbsdis==88|arbsdis==999|arbsdis==9999 //0
*********************
** Corticosteroids **
*********************
** Missing
count if corsdis==. & vstatus!=2 & sd_etype==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if corsdis==88|corsdis==999|corsdis==9999 //0
***********************
** Antihypertensives **
***********************
** Missing
count if antihdis==. & vstatus!=2 & sd_etype==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if antihdis==88|antihdis==999|antihdis==9999 //0
****************
** Nimodipine **
****************
** Missing
count if nimodis==. & vstatus!=2 & sd_etype==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if nimodis==88|nimodis==999|nimodis==9999 //0
******************
** Antiseizures **
******************
** Missing
count if antisdis==. & vstatus!=2 & sd_etype==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if antisdis==88|antisdis==999|antisdis==9999 //0
*******************
** TED Stockings **
*******************
** Missing
count if teddis==. & vstatus!=2 & sd_etype==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if teddis==88|teddis==999|teddis==9999 //0
*******************
** Beta Blockers **
*******************
** Missing
count if betadis==. & vstatus!=2 & sd_etype==2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if betadis==88|betadis==999|betadis==9999 //0
****************
** Bivalrudin **
****************
** Missing
count if bivaldis==. & vstatus!=2 & sd_etype==2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if bivaldis==88|bivaldis==999|bivaldis==9999 //0

******************
** Aspirin Dose **
******************
** Missing date
count if aspdosedis==. & aspdis==1 //0
** Invalid missing code
count if aspdosedis==88|aspdosedis==99|aspdosedis==9999 //0

*******************
** BP - Systolic **
*******************
** Missing
count if dissysbp==. & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if dissysbp==9999 //0
** Invalid range
count if dissysbp<50 & dissysbp>350 //0
********************
** BP - Diastolic **
********************
** Missing
count if disdiasbp==. & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if disdiasbp==9999 //0
** Invalid range
count if disdiasbp<20 & disdiasbp>250 //0

************************
** Complications Info **
************************
********************
** Complications? **
********************
** Missing
count if dcomp==. & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if dcomp==88|dcomp==999|dcomp==9999 //0
** Invalid (comp=No/ND; comp options=Yes)
count if (dcomp==2|dcomp==99) & (ddvt==1|dpneu==1|dulcer==1|duti==1|dfall==1|dhydro==1|dhaemo==1|doinfect==1|dgibleed==1|dccf==1|dcpang==1|daneur==1|dhypo==1|dblock==1|dseizures==1|dafib==1|dcshock==1|dinfarct==1|drenal==1|dcarest==1) //0
** Invalid (comp=Yes; comp options NOT=Yes)
count if dcomp==1 & ddvt!=1 & dpneu!=1 & dulcer!=1 & duti!=1 & dfall!=1 & dhydro!=1 & dhaemo!=1 & doinfect!=1 & dgibleed!=1 & dccf!=1 & dcpang!=1 & daneur!=1 & dhypo!=1 & dblock!=1 & dseizures!=1 & dafib!=1 & dcshock!=1 & dinfarct!=1 & drenal!=1 & dcarest!=1 & odcomp>5 //1 - stroke record 2325 corrected below
** Invalid (comp=Yes/No; comp options all=ND)
count if dcomp!=99 & ddvt==99 & dpneu==99 & dulcer==99 & duti==99 & dfall==99 & dhydro==99 & dhaemo==99 & doinfect==99 & dgibleed==99 & dccf==99 & dcpang==99 & daneur==99 & dhypo==99 & dblock==99 & dseizures==99 & dafib==99 & dcshock==99 & dinfarct==99 & drenal==99 & dcarest==99 //0
*********
** DVT **
*********
** Missing
count if ddvt==. & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - heart record 3318 has all dcomp options blank except for pneumonia, corrected below
** Invalid missing code
count if ddvt==88|ddvt==999|ddvt==9999 //0
***************
** Pneumonia **
***************
** Missing
count if dpneu==. & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if dpneu==88|dpneu==999|dpneu==9999 //0
***********
** Ulcer **
***********
** Missing
count if dulcer==. & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dulcer==88|dulcer==999|dulcer==9999 //0
*********
** UTI **
*********
** Missing
count if duti==. & sd_etype==1 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if duti==88|duti==999|duti==9999 //0
**********
** Fall **
**********
** Missing
count if dfall==. & sd_etype==1 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if dfall==88|dfall==999|dfall==9999 //0
*******************
** Hydrocephalus **
*******************
** Missing
count if dhydro==. & sd_etype==1 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if dhydro==88|dhydro==999|dhydro==9999 //0
**********************
** Haem. Transform. **
**********************
** Missing
count if dhaemo==. & sd_etype==1 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if dhaemo==88|dhaemo==999|dhaemo==9999 //0
*******************
** Oth Infection **
*******************
** Missing
count if doinfect==. & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if doinfect==88|doinfect==999|doinfect==9999 //0
**************
** GI Bleed **
**************
** Missing
count if dgibleed==. & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dgibleed==88|dgibleed==999|dgibleed==9999 //0
*********
** CCF **
*********
** Missing
count if dccf==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dccf==88|dccf==999|dccf==9999 //0
**************************
** Recurrent chest pain **
**************************
** Missing
count if dcpang==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dcpang==88|dcpang==999|dcpang==9999 //0
**************
** Aneurysm **
**************
** Missing
count if daneur==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if daneur==88|daneur==999|daneur==9999 //0
*****************
** Hypotension **
*****************
** Missing
count if dhypo==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dhypo==88|dhypo==999|dhypo==9999 //0
*****************
** Heart Block **
*****************
** Missing
count if dblock==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dblock==88|dblock==999|dblock==9999 //0
**************
** Seizures **
**************
** Missing
count if dseizures==. & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dseizures==88|dseizures==999|dseizures==9999 //0
*****************
** Atrial Fib. **
*****************
** Missing
count if dafib==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dafib==88|dafib==999|dafib==9999 //0
*****************
** Card. Shock **
*****************
** Missing
count if dcshock==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dcshock==88|dcshock==999|dcshock==9999 //0
******************
** Reinfarction **
******************
** Missing
count if dinfarct==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dinfarct==88|dinfarct==999|dinfarct==9999 //0
*******************
** Renal failure **
*******************
** Missing
count if drenal==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if drenal==88|drenal==999|drenal==9999 //0
********************
** Cardiac Arrest **
********************
** Missing
count if dcarest==. & sd_etype==2 & dcomp==1 & discharge_complete!=0 & discharge_complete!=. //1 - same record already flagged above; corrected below
** Invalid missing code
count if dcarest==88|dcarest==999|dcarest==9999 //0

*************************
** Other complications **
** 	(Heart + Stroke)   **
*************************
** Missing
count if dcomp!=. & dcomp!=3 & dcomp!=99 & dcomp!=99999 & odcomp==. //314 - JC 02mar2023 updated branching logic in CVDdb to reflect same convention used by hcomp + ohcomp on Comp+Dx form
replace odcomp=6 if dcomp==2 & odcomp==. //314 changes - DAs do not need to update CVDdb as this error was due to branching logic
** Invalid missing code
count if odcomp==88|odcomp==999|odcomp==9999 //0
** Missing (other comp. options=1 but other comp. text blank)

*****************
** Oth Comp. 1 **
*****************
count if odcomp==1 & odcomp1=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (odcomp==6|odcomp==99|odcomp==99999) & odcomp1!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if odcomp1!="" //1 - reviewed and correct
count if sd_etype==2 & (regexm(odcomp1,"dvt")|regexm(odcomp1,"thrombosis")|regexm(odcomp1,"pneumonia")|regexm(odcomp1,"decubitus")|regexm(odcomp1,"ulcer")|regexm(odcomp1,"infection")|regexm(odcomp1,"septic")|regexm(odcomp1,"bleed")|regexm(odcomp1,"gastrointestinal")|regexm(odcomp1,"ccf")|regexm(odcomp1,"chf")|regexm(odcomp1,"failure")|regexm(odcomp1,"chest pain")|regexm(odcomp1,"angina")|regexm(odcomp1,"aneurysm")|regexm(odcomp1,"hypotension")|regexm(odcomp1,"block")|regexm(odcomp1,"seizure")|regexm(odcomp1,"fibrill*")|regexm(odcomp1,"shock")|regexm(odcomp1,"reinfarct")|regexm(odcomp1,"renal")|regexm(odcomp1,"arrest")) //0
count if sd_etype==1 & (regexm(odcomp1,"dvt")|regexm(odcomp1,"thrombosis")|regexm(odcomp1,"pneumonia")|regexm(odcomp1,"decubitus")|regexm(odcomp1,"ulcer")|regexm(odcomp1,"uti")|regexm(odcomp1,"fall")|regexm(odcomp1,"cephalus")|regexm(odcomp1,"transform")|regexm(odcomp1,"pneumonia")|regexm(odcomp1,"decubitus")|regexm(odcomp1,"ulcer")|regexm(odcomp1,"infection")|regexm(odcomp1,"septic")|regexm(odcomp1,"bleed")|regexm(odcomp1,"gastrointestinal")|regexm(odcomp1,"seizure")) //0
*****************
** Oth Comp. 2 **
*****************
count if odcomp==2 & odcomp2=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (odcomp==6|odcomp==99|odcomp==99999) & odcomp2!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if odcomp2!="" //0
count if sd_etype==2 & (regexm(odcomp2,"dvt")|regexm(odcomp2,"thrombosis")|regexm(odcomp2,"pneumonia")|regexm(odcomp2,"decubitus")|regexm(odcomp2,"ulcer")|regexm(odcomp2,"infection")|regexm(odcomp2,"septic")|regexm(odcomp2,"bleed")|regexm(odcomp2,"gastrointestinal")|regexm(odcomp2,"ccf")|regexm(odcomp2,"chf")|regexm(odcomp2,"failure")|regexm(odcomp2,"chest pain")|regexm(odcomp2,"angina")|regexm(odcomp2,"aneurysm")|regexm(odcomp2,"hypotension")|regexm(odcomp2,"block")|regexm(odcomp2,"seizure")|regexm(odcomp2,"fibrill*")|regexm(odcomp2,"shock")|regexm(odcomp2,"reinfarct")|regexm(odcomp2,"renal")|regexm(odcomp2,"arrest")) //0
count if sd_etype==1 & (regexm(odcomp2,"dvt")|regexm(odcomp2,"thrombosis")|regexm(odcomp2,"pneumonia")|regexm(odcomp2,"decubitus")|regexm(odcomp2,"ulcer")|regexm(odcomp2,"uti")|regexm(odcomp2,"fall")|regexm(odcomp2,"cephalus")|regexm(odcomp2,"transform")|regexm(odcomp2,"pneumonia")|regexm(odcomp2,"decubitus")|regexm(odcomp2,"ulcer")|regexm(odcomp2,"infection")|regexm(odcomp2,"septic")|regexm(odcomp2,"bleed")|regexm(odcomp2,"gastrointestinal")|regexm(odcomp2,"seizure")) //0
*****************
** Oth Comp. 3 **
*****************
count if odcomp==3 & odcomp3=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (odcomp==6|odcomp==99|odcomp==99999) & odcomp3!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if odcomp3!="" //0
count if sd_etype==2 & (regexm(odcomp3,"dvt")|regexm(odcomp3,"thrombosis")|regexm(odcomp3,"pneumonia")|regexm(odcomp3,"decubitus")|regexm(odcomp3,"ulcer")|regexm(odcomp3,"infection")|regexm(odcomp3,"septic")|regexm(odcomp3,"bleed")|regexm(odcomp3,"gastrointestinal")|regexm(odcomp3,"ccf")|regexm(odcomp3,"chf")|regexm(odcomp3,"failure")|regexm(odcomp3,"chest pain")|regexm(odcomp3,"angina")|regexm(odcomp3,"aneurysm")|regexm(odcomp3,"hypotension")|regexm(odcomp3,"block")|regexm(odcomp3,"seizure")|regexm(odcomp3,"fibrill*")|regexm(odcomp3,"shock")|regexm(odcomp3,"reinfarct")|regexm(odcomp3,"renal")|regexm(odcomp3,"arrest")) //0
count if sd_etype==1 & (regexm(odcomp3,"dvt")|regexm(odcomp3,"thrombosis")|regexm(odcomp3,"pneumonia")|regexm(odcomp3,"decubitus")|regexm(odcomp3,"ulcer")|regexm(odcomp3,"uti")|regexm(odcomp3,"fall")|regexm(odcomp3,"cephalus")|regexm(odcomp3,"transform")|regexm(odcomp3,"pneumonia")|regexm(odcomp3,"decubitus")|regexm(odcomp3,"ulcer")|regexm(odcomp3,"infection")|regexm(odcomp3,"septic")|regexm(odcomp3,"bleed")|regexm(odcomp3,"gastrointestinal")|regexm(odcomp3,"seizure")) //0
 
** JC 02mar2023: odcomp4 + odcomp5 not entered for any of the cases so complication is byte instead of string in Stata
tostring odcomp4 ,replace
replace odcomp4="" if odcomp4=="." //1145 changes
tostring odcomp5 ,replace
replace odcomp5="" if odcomp5=="." //1145 changes
*****************
** Oth Comp. 4 **
*****************
count if odcomp==4 & odcomp4=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (odcomp==6|odcomp==99|odcomp==99999) & odcomp4!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if odcomp4!="" //0
count if sd_etype==2 & (regexm(odcomp4,"dvt")|regexm(odcomp4,"thrombosis")|regexm(odcomp4,"pneumonia")|regexm(odcomp4,"decubitus")|regexm(odcomp4,"ulcer")|regexm(odcomp4,"infection")|regexm(odcomp4,"septic")|regexm(odcomp4,"bleed")|regexm(odcomp4,"gastrointestinal")|regexm(odcomp4,"ccf")|regexm(odcomp4,"chf")|regexm(odcomp4,"failure")|regexm(odcomp4,"chest pain")|regexm(odcomp4,"angina")|regexm(odcomp4,"aneurysm")|regexm(odcomp4,"hypotension")|regexm(odcomp4,"block")|regexm(odcomp4,"seizure")|regexm(odcomp4,"fibrill*")|regexm(odcomp4,"shock")|regexm(odcomp4,"reinfarct")|regexm(odcomp4,"renal")|regexm(odcomp4,"arrest")) //0
count if sd_etype==1 & (regexm(odcomp4,"dvt")|regexm(odcomp4,"thrombosis")|regexm(odcomp4,"pneumonia")|regexm(odcomp4,"decubitus")|regexm(odcomp4,"ulcer")|regexm(odcomp4,"uti")|regexm(odcomp4,"fall")|regexm(odcomp4,"cephalus")|regexm(odcomp4,"transform")|regexm(odcomp4,"pneumonia")|regexm(odcomp4,"decubitus")|regexm(odcomp4,"ulcer")|regexm(odcomp4,"infection")|regexm(odcomp4,"septic")|regexm(odcomp4,"bleed")|regexm(odcomp4,"gastrointestinal")|regexm(odcomp4,"seizure")) //0
*****************
** Oth Comp. 5 **
*****************
count if odcomp==5 & odcomp5=="" //0
** Invalid (other comp. options=ND/None but other comp. text NOT=blank)
count if (odcomp==6|odcomp==99|odcomp==99999) & odcomp5!="" //0
** possibly Invalid (other comp.=one of the comp. options)
count if odcomp5!="" //0
count if sd_etype==2 & (regexm(odcomp5,"dvt")|regexm(odcomp5,"thrombosis")|regexm(odcomp5,"pneumonia")|regexm(odcomp5,"decubitus")|regexm(odcomp5,"ulcer")|regexm(odcomp5,"infection")|regexm(odcomp5,"septic")|regexm(odcomp5,"bleed")|regexm(odcomp5,"gastrointestinal")|regexm(odcomp5,"ccf")|regexm(odcomp5,"chf")|regexm(odcomp5,"failure")|regexm(odcomp5,"chest pain")|regexm(odcomp5,"angina")|regexm(odcomp5,"aneurysm")|regexm(odcomp5,"hypotension")|regexm(odcomp5,"block")|regexm(odcomp5,"seizure")|regexm(odcomp5,"fibrill*")|regexm(odcomp5,"shock")|regexm(odcomp5,"reinfarct")|regexm(odcomp5,"renal")|regexm(odcomp5,"arrest")) //0
count if sd_etype==1 & (regexm(odcomp5,"dvt")|regexm(odcomp5,"thrombosis")|regexm(odcomp5,"pneumonia")|regexm(odcomp5,"decubitus")|regexm(odcomp5,"ulcer")|regexm(odcomp5,"uti")|regexm(odcomp5,"fall")|regexm(odcomp5,"cephalus")|regexm(odcomp5,"transform")|regexm(odcomp5,"pneumonia")|regexm(odcomp5,"decubitus")|regexm(odcomp5,"ulcer")|regexm(odcomp5,"infection")|regexm(odcomp5,"septic")|regexm(odcomp5,"bleed")|regexm(odcomp5,"gastrointestinal")|regexm(odcomp5,"seizure")) //0

********************
** Diagnosis Info **
********************
*********************
** Same as Abs dx? **
*********************
** Missing
count if disdxsame==. & vstatus==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if disdxsame==88|disdxsame==99|disdxsame==999|disdxsame==9999 //0
***************
** Stroke dx **
***************
** Missing
count if disdxsame!=1 & vstatus==1 & sd_etype==1 & disdxs___1==0 & disdxs___2==0 & disdxs___3==0 & disdxs___4==0 & disdxs___5==0 & disdxs___6==0 & disdxs___7==0 & disdxs___8==0 & disdxs___99==0 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if disdxs___88==1|disdxs___999==1|disdxs___9999==1 //0
** Invalid (same=No; dx options all unticked/None)
count if disdxsame==2 & sd_etype==1 & disdxs___1==0 & disdxs___2==0 & disdxs___3==0 & disdxs___4==0 & disdxs___5==0 & disdxs___6==0 & disdxs___7==0 & disdxs___8==0 & disdxs___99==0 & (odisdx==5|odisdx==99) //0
***************
** Heart dx **
***************
** Missing
count if disdxsame!=1 & vstatus==1 & sd_etype==2 & disdxh___1==0 & disdxh___2==0 & disdxh___3==0 & disdxh___4==0 & disdxh___5==0 & disdxh___6==0 & disdxh___7==0 & disdxh___8==0 & disdxh___9==0 & disdxh___10==0 & disdxh___99==0 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if disdxh___88==1|disdxh___999==1|disdxh___9999==1 //0
** Invalid (same=No; dx options all unticked/None)
count if disdxsame==2 & sd_etype==2 & disdxh___1==0 & disdxh___2==0 & disdxh___3==0 & disdxh___4==0 & disdxh___5==0 & disdxh___6==0 & disdxh___7==0 & disdxh___8==0 & disdxh___9==0 & disdxh___10==0 & disdxh___99==0 & (odisdx==5|odisdx==99) //0


**********************
** Other diagnoses  **
** (Heart + Stroke) **
**********************
** Missing
count if disdxsame!=. & disdxsame!=1 & odisdx==. //0
** Invalid missing code
count if odisdx==88|odisdx==999|odisdx==9999 //0
** Missing (other dx options=1 but other dx text blank)
**************
** Oth Dx 1 **
**************
count if odisdx==1 & odisdx1=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (odisdx==5|odisdx==99|odisdx==99999) & odisdx1!="" //0
** possibly Invalid (other dx=one of the dx options)
count if odisdx1!="" //0
count if sd_etype==2 & (regexm(odisdx1,"stemi")|regexm(odisdx1,"nstemi")|regexm(odisdx1,"ami")|regexm(odisdx1,"acs")|regexm(odisdx1,"angina")|regexm(odisdx1,"chest")|regexm(odisdx1,"septic")|regexm(odisdx1,"bleed")|regexm(odisdx1,"gastrointestinal")|regexm(odisdx1,"ccf")|regexm(odisdx1,"chf")|regexm(odisdx1,"failure")|regexm(odisdx1,"chest pain")|regexm(odisdx1,"angina")|regexm(odisdx1,"lbbb")|regexm(odisdx1,"documented")|regexm(odisdx1,"unknown")) //0
count if sd_etype==1 & (regexm(odisdx1,"stroke")|regexm(odisdx1,"haemorrhage")|regexm(odisdx1,"hemorrhage")|regexm(odisdx1,"unclassified")|regexm(odisdx1,"cva")|regexm(odisdx1,"tia")|regexm(odisdx1,"documented")|regexm(odisdx1,"unknown")) //0
**************
** Oth Dx 2 **
**************
count if odisdx==2 & odisdx2=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (odisdx==5|odisdx==99|odisdx==99999) & odisdx2!="" //0
** possibly Invalid (other dx=one of the dx options)
count if odisdx2!="" //0
count if sd_etype==2 & (regexm(odisdx2,"stemi")|regexm(odisdx2,"nstemi")|regexm(odisdx2,"ami")|regexm(odisdx2,"acs")|regexm(odisdx2,"angina")|regexm(odisdx2,"chest")|regexm(odisdx2,"septic")|regexm(odisdx2,"bleed")|regexm(odisdx2,"gastrointestinal")|regexm(odisdx2,"ccf")|regexm(odisdx2,"chf")|regexm(odisdx2,"failure")|regexm(odisdx2,"chest pain")|regexm(odisdx2,"angina")|regexm(odisdx2,"lbbb")|regexm(odisdx2,"documented")|regexm(odisdx2,"unknown")) //0
count if sd_etype==1 & (regexm(odisdx2,"stroke")|regexm(odisdx2,"haemorrhage")|regexm(odisdx2,"hemorrhage")|regexm(odisdx2,"unclassified")|regexm(odisdx2,"cva")|regexm(odisdx2,"tia")|regexm(odisdx2,"documented")|regexm(odisdx2,"unknown")) //0
**************
** Oth Dx 3 **
**************
count if odisdx==3 & odisdx3=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (odisdx==5|odisdx==99|odisdx==99999) & odisdx3!="" //0
** possibly Invalid (other dx=one of the dx options)
count if odisdx3!="" //0
count if sd_etype==2 & (regexm(odisdx3,"stemi")|regexm(odisdx3,"nstemi")|regexm(odisdx3,"ami")|regexm(odisdx3,"acs")|regexm(odisdx3,"angina")|regexm(odisdx3,"chest")|regexm(odisdx3,"septic")|regexm(odisdx3,"bleed")|regexm(odisdx3,"gastrointestinal")|regexm(odisdx3,"ccf")|regexm(odisdx3,"chf")|regexm(odisdx3,"failure")|regexm(odisdx3,"chest pain")|regexm(odisdx3,"angina")|regexm(odisdx3,"lbbb")|regexm(odisdx3,"documented")|regexm(odisdx3,"unknown")) //0
count if sd_etype==1 & (regexm(odisdx3,"stroke")|regexm(odisdx3,"haemorrhage")|regexm(odisdx3,"hemorrhage")|regexm(odisdx3,"unclassified")|regexm(odisdx3,"cva")|regexm(odisdx3,"tia")|regexm(odisdx3,"documented")|regexm(odisdx3,"unknown")) //0

** JC 02mar2023: odisdx4 not entered for any of the cases so this other dx is byte instead of string in Stata
tostring odisdx4 ,replace
replace odisdx4="" if odisdx4=="." //1145 changes
**************
** Oth Dx 4 **
**************
count if odisdx==4 & odisdx4=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (odisdx==5|odisdx==99|odisdx==99999) & odisdx4!="" //0
** possibly Invalid (other dx=one of the dx options)
count if odisdx4!="" //0
count if sd_etype==2 & (regexm(odisdx4,"stemi")|regexm(odisdx4,"nstemi")|regexm(odisdx4,"ami")|regexm(odisdx4,"acs")|regexm(odisdx4,"angina")|regexm(odisdx4,"chest")|regexm(odisdx4,"septic")|regexm(odisdx4,"bleed")|regexm(odisdx4,"gastrointestinal")|regexm(odisdx4,"ccf")|regexm(odisdx4,"chf")|regexm(odisdx4,"failure")|regexm(odisdx4,"chest pain")|regexm(odisdx4,"angina")|regexm(odisdx4,"lbbb")|regexm(odisdx4,"documented")|regexm(odisdx4,"unknown")) //0
count if sd_etype==1 & (regexm(odisdx4,"stroke")|regexm(odisdx4,"haemorrhage")|regexm(odisdx4,"hemorrhage")|regexm(odisdx4,"unclassified")|regexm(odisdx4,"cva")|regexm(odisdx4,"tia")|regexm(odisdx4,"documented")|regexm(odisdx4,"unknown")) //0


**********************
** Dx Reclassified? **
**********************
** Missing
count if reclass==. & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if reclass==88|reclass==99|reclass==999|reclass==9999 //0
***************
** Stroke dx **
***************
** Missing
count if reclass==1 & sd_etype==1 & recdxs___1==0 & recdxs___2==0 & recdxs___3==0 & recdxs___4==0 & recdxs___5==0 & recdxs___6==0 & recdxs___7==0 & recdxs___8==0 & recdxs___99==0 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if recdxs___88==1|recdxs___999==1|recdxs___9999==1 //0
** Invalid (reclassified=Yes; dx options all unticked/None)
count if reclass==1 & sd_etype==1 & recdxs___1==0 & recdxs___2==0 & recdxs___3==0 & recdxs___4==0 & recdxs___5==0 & recdxs___6==0 & recdxs___7==0 & recdxs___8==0 & recdxs___99==0 & (orecdx==5|orecdx==99) //0
***************
** Heart dx **
***************
** Missing
count if reclass==1 & sd_etype==2 & recdxh___1==0 & recdxh___2==0 & recdxh___3==0 & recdxh___4==0 & recdxh___5==0 & recdxh___6==0 & recdxh___7==0 & recdxh___8==0 & recdxh___9==0 & recdxh___10==0 & recdxh___99==0 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if recdxh___88==1|recdxh___999==1|recdxh___9999==1 //0
** Invalid (reclassified=Yes; dx options all unticked/None)
count if reclass==1 & sd_etype==2 & recdxh___1==0 & recdxh___2==0 & recdxh___3==0 & recdxh___4==0 & recdxh___5==0 & recdxh___6==0 & recdxh___7==0 & recdxh___8==0 & recdxh___9==0 & recdxh___10==0 & recdxh___99==0 & (orecdx==5|orecdx==99) //0


**********************
** Other diagnoses  **
** (Heart + Stroke) **
**********************
** Missing
count if reclass!=. & reclass==1 & orecdx==. //0
** Invalid missing code
count if orecdx==88|orecdx==999|orecdx==9999 //0
** Missing (other dx options=1 but other dx text blank)
**************
** Oth Dx 1 **
**************
count if orecdx==1 & orecdx1=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (orecdx==5|orecdx==99|orecdx==99999) & orecdx1!="" //0
** possibly Invalid (other dx=one of the dx options)
count if orecdx1!="" //0
count if sd_etype==2 & (regexm(orecdx1,"stemi")|regexm(orecdx1,"nstemi")|regexm(orecdx1,"ami")|regexm(orecdx1,"acs")|regexm(orecdx1,"angina")|regexm(orecdx1,"chest")|regexm(orecdx1,"septic")|regexm(orecdx1,"bleed")|regexm(orecdx1,"gastrointestinal")|regexm(orecdx1,"ccf")|regexm(orecdx1,"chf")|regexm(orecdx1,"failure")|regexm(orecdx1,"chest pain")|regexm(orecdx1,"angina")|regexm(orecdx1,"lbbb")|regexm(orecdx1,"documented")|regexm(orecdx1,"unknown")) //0
count if sd_etype==1 & (regexm(orecdx1,"stroke")|regexm(orecdx1,"haemorrhage")|regexm(orecdx1,"hemorrhage")|regexm(orecdx1,"unclassified")|regexm(orecdx1,"cva")|regexm(orecdx1,"tia")|regexm(orecdx1,"documented")|regexm(orecdx1,"unknown")) //0
**************
** Oth Dx 2 **
**************
count if orecdx==2 & orecdx2=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (orecdx==5|orecdx==99|orecdx==99999) & orecdx2!="" //0
** possibly Invalid (other dx=one of the dx options)
count if orecdx2!="" //0
count if sd_etype==2 & (regexm(orecdx2,"stemi")|regexm(orecdx2,"nstemi")|regexm(orecdx2,"ami")|regexm(orecdx2,"acs")|regexm(orecdx2,"angina")|regexm(orecdx2,"chest")|regexm(orecdx2,"septic")|regexm(orecdx2,"bleed")|regexm(orecdx2,"gastrointestinal")|regexm(orecdx2,"ccf")|regexm(orecdx2,"chf")|regexm(orecdx2,"failure")|regexm(orecdx2,"chest pain")|regexm(orecdx2,"angina")|regexm(orecdx2,"lbbb")|regexm(orecdx2,"documented")|regexm(orecdx2,"unknown")) //0
count if sd_etype==1 & (regexm(orecdx2,"stroke")|regexm(orecdx2,"haemorrhage")|regexm(orecdx2,"hemorrhage")|regexm(orecdx2,"unclassified")|regexm(orecdx2,"cva")|regexm(orecdx2,"tia")|regexm(orecdx2,"documented")|regexm(orecdx2,"unknown")) //0

** JC 02mar2023: orecdx3 + orecdx4 not entered for any of the cases so this other dx is byte instead of string in Stata
tostring orecdx3 ,replace
replace orecdx3="" if orecdx3=="." //1145 changes
tostring orecdx4 ,replace
replace orecdx4="" if orecdx4=="." //1145 changes
**************
** Oth Dx 3 **
**************
count if orecdx==3 & orecdx3=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (orecdx==5|orecdx==99|orecdx==99999) & orecdx3!="" //0
** possibly Invalid (other dx=one of the dx options)
count if orecdx3!="" //0
count if sd_etype==2 & (regexm(orecdx3,"stemi")|regexm(orecdx3,"nstemi")|regexm(orecdx3,"ami")|regexm(orecdx3,"acs")|regexm(orecdx3,"angina")|regexm(orecdx3,"chest")|regexm(orecdx3,"septic")|regexm(orecdx3,"bleed")|regexm(orecdx3,"gastrointestinal")|regexm(orecdx3,"ccf")|regexm(orecdx3,"chf")|regexm(orecdx3,"failure")|regexm(orecdx3,"chest pain")|regexm(orecdx3,"angina")|regexm(orecdx3,"lbbb")|regexm(orecdx3,"documented")|regexm(orecdx3,"unknown")) //0
count if sd_etype==1 & (regexm(orecdx3,"stroke")|regexm(orecdx3,"haemorrhage")|regexm(orecdx3,"hemorrhage")|regexm(orecdx3,"unclassified")|regexm(orecdx3,"cva")|regexm(orecdx3,"tia")|regexm(orecdx3,"documented")|regexm(orecdx3,"unknown")) //0
**************
** Oth Dx 4 **
**************
count if orecdx==4 & orecdx4=="" //0
** Invalid (other dx options=ND/None but other dx text NOT=blank)
count if (orecdx==5|orecdx==99|orecdx==99999) & orecdx4!="" //0
** possibly Invalid (other dx=one of the dx options)
count if orecdx4!="" //0
count if sd_etype==2 & (regexm(orecdx4,"stemi")|regexm(orecdx4,"nstemi")|regexm(orecdx4,"ami")|regexm(orecdx4,"acs")|regexm(orecdx4,"angina")|regexm(orecdx4,"chest")|regexm(orecdx4,"septic")|regexm(orecdx4,"bleed")|regexm(orecdx4,"gastrointestinal")|regexm(orecdx4,"ccf")|regexm(orecdx4,"chf")|regexm(orecdx4,"failure")|regexm(orecdx4,"chest pain")|regexm(orecdx4,"angina")|regexm(orecdx4,"lbbb")|regexm(orecdx4,"documented")|regexm(orecdx4,"unknown")) //0
count if sd_etype==1 & (regexm(orecdx4,"stroke")|regexm(orecdx4,"haemorrhage")|regexm(orecdx4,"hemorrhage")|regexm(orecdx4,"unclassified")|regexm(orecdx4,"cva")|regexm(orecdx4,"tia")|regexm(orecdx4,"documented")|regexm(orecdx4,"unknown")) //0


**********************
** Stroke Unit Info **
**********************
******************************
** Admitted to Stroke Unit? **
******************************
** Missing
count if strunit==. & vstatus!=. & sd_etype==1 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if strunit==88|strunit==999|strunit==9999 //0
*********************************
** Same as Hospital Admission? **
*********************************
** Missing
count if sunitadmsame==. & strunit==1 //0
** Invalid missing code
count if sunitadmsame==88|sunitadmsame==99|sunitadmsame==999|sunitadmsame==9999 //0
** possibly Invalid (SameAdm=Yes; AdmDate NOT blank)
count if sunitadmsame==1 & astrunitd!=. //0

***********************
** SU Admission Date **
***********************
** Missing date
count if astrunitd==. & sunitadmsame==2 //3 - entered as 99 in CVDdb
** Invalid (not 2021)
count if astrunitd!=. & year(astrunitd)!=2021 //1 - correct as event 2021 but SU adm in 2022
** Invalid (before DOB)
count if dob!=. & astrunitd!=. & astrunitd<dob //0
** possibly Invalid (before CFAdmDate)
count if astrunitd!=. & cfadmdate!=. & astrunitd<cfadmdate //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & astrunitd!=. & astrunitd>dlc //0
count if cfdod!=. & astrunitd!=. & astrunitd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if astrunitd!=. & dae!=. & astrunitd<dae //0
** possibly Invalid (before WardAdmDate)
count if astrunitd!=. & doh!=. & astrunitd<doh //0
** Invalid (future date)
count if astrunitd!=. & astrunitd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if sunitadmsame==2 & astrunitd==. & astrunitdday==99 & astrunitdmonth==99 & astrunitdyear==9999 //0
** possibly Invalid (dis date not partial but partial field not blank)
count if astrunitd==. & astrunitdday!=. & astrunitdmonth!=. & astrunitdyear!=. //0
replace astrunitdday=. if astrunitd==. & astrunitdday!=. & astrunitdmonth!=. & astrunitdyear!=. //0 changes
replace astrunitdmonth=. if astrunitd==. & astrunitdmonth!=. & astrunitdyear!=. //0 changes
replace astrunitdyear=. if astrunitd==. & astrunitdyear!=. //0 changes
count if astrunitd==. & (astrunitdday!=. | astrunitdmonth!=. | astrunitdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if astrunitdday==88|astrunitdday==999|astrunitdday==9999 //0
count if astrunitdmonth==88|astrunitdmonth==999|astrunitdmonth==9999 //0
count if astrunitdyear==88|astrunitdyear==99|astrunitdyear==999 //0
** Invalid (before NotifiedDate)
count if astrunitd!=. & ambcalld!=. & astrunitd<ambcalld //0
** Invalid (before AtSceneDate)
count if astrunitd!=. & atscnd!=. & astrunitd<atscnd //0
** Invalid (before FromSceneDate)
count if astrunitd!=. & frmscnd!=. & astrunitd<frmscnd //0
** Invalid (before AtHospitalDate)
count if astrunitd!=. & hospd!=. & astrunitd<hospd //0
** Invalid (before EventDate)
count if astrunitd!=. & edate!=. & astrunitd<edate //0
** Invalid (after Stroke Unit Discharge Date)
count if astrunitd!=. & dstrunitd!=. & astrunitd>dstrunitd //0

***********************
** SU Discharge Date **
***********************
** Missing date
count if dstrunitd==. & sunitdissame==2 //0
** Invalid (not 2021)
count if dstrunitd!=. & year(dstrunitd)!=2021 //1 - correct as event 2021 but SU dis in 2022
** Invalid (before DOB)
count if dob!=. & dstrunitd!=. & dstrunitd<dob //0
** possibly Invalid (before CFAdmDate)
count if dstrunitd!=. & cfadmdate!=. & dstrunitd<cfadmdate //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & dstrunitd!=. & dstrunitd>dlc //0
count if cfdod!=. & dstrunitd!=. & dstrunitd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if dstrunitd!=. & dae!=. & dstrunitd<dae //0
** possibly Invalid (before WardAdmDate)
count if dstrunitd!=. & doh!=. & dstrunitd<doh //0
** Invalid (future date)
count if dstrunitd!=. & dstrunitd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if sunitdissame==2 & dstrunitd==. & dstrunitdday==99 & dstrunitdmonth==99 & dstrunitdyear==9999 //0
** possibly Invalid (dis date not partial but partial field not blank)
count if dstrunitd==. & dstrunitdday!=. & dstrunitdmonth!=. & dstrunitdyear!=. //0
replace dstrunitdday=. if dstrunitd==. & dstrunitdday!=. & dstrunitdmonth!=. & dstrunitdyear!=. //0 changes
replace dstrunitdmonth=. if dstrunitd==. & dstrunitdmonth!=. & dstrunitdyear!=. //0 changes
replace dstrunitdyear=. if dstrunitd==. & dstrunitdyear!=. //0 changes
count if dstrunitd==. & (dstrunitdday!=. | dstrunitdmonth!=. | dstrunitdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if dstrunitdday==88|dstrunitdday==999|dstrunitdday==9999 //0
count if dstrunitdmonth==88|dstrunitdmonth==999|dstrunitdmonth==9999 //0
count if dstrunitdyear==88|dstrunitdyear==99|dstrunitdyear==999 //0
** Invalid (before NotifiedDate)
count if dstrunitd!=. & ambcalld!=. & dstrunitd<ambcalld //0
** Invalid (before AtSceneDate)
count if dstrunitd!=. & atscnd!=. & dstrunitd<atscnd //0
** Invalid (before FromSceneDate)
count if dstrunitd!=. & frmscnd!=. & dstrunitd<frmscnd //0
** Invalid (before AtHospitalDate)
count if dstrunitd!=. & hospd!=. & dstrunitd<hospd //0
** Invalid (before EventDate)
count if dstrunitd!=. & edate!=. & dstrunitd<edate //0
** Invalid (before Stroke Unit Adm Date)
count if dstrunitd!=. & astrunitd!=. & dstrunitd<astrunitd //0

***********************
** Cardiac Unit Info **
***********************
*******************************
** Admitted to Cardiac Unit? **
*******************************
** Missing
count if carunit==. & vstatus!=. & sd_etype==2 & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if carunit==88|carunit==999|carunit==9999 //0
*********************************
** Same as Hospital Admission? **
*********************************
** Missing
count if cunitadmsame==. & carunit==1 //0
** Invalid missing code
count if cunitadmsame==88|cunitadmsame==99|cunitadmsame==999|cunitadmsame==9999 //0
** possibly Invalid (SameAdm=Yes; AdmDate NOT blank)
count if cunitadmsame==1 & acarunitd!=. //0

***********************
** CU Admission Date **
***********************
** Missing date
count if acarunitd==. & cunitadmsame==2 //0
** Invalid (not 2021)
count if acarunitd!=. & year(acarunitd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & acarunitd!=. & acarunitd<dob //0
** possibly Invalid (before CFAdmDate)
count if acarunitd!=. & cfadmdate!=. & acarunitd<cfadmdate //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & acarunitd!=. & acarunitd>dlc //0
count if cfdod!=. & acarunitd!=. & acarunitd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if acarunitd!=. & dae!=. & acarunitd<dae //0
** possibly Invalid (before WardAdmDate)
count if acarunitd!=. & doh!=. & acarunitd<doh //0
** Invalid (future date)
count if acarunitd!=. & acarunitd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if cunitadmsame==2 & acarunitd==. & acarunitdday==99 & acarunitdmonth==99 & acarunitdyear==9999 //0
** possibly Invalid (dis date not partial but partial field not blank)
count if acarunitd==. & acarunitdday!=. & acarunitdmonth!=. & acarunitdyear!=. //0
replace acarunitdday=. if acarunitd==. & acarunitdday!=. & acarunitdmonth!=. & acarunitdyear!=. //0 changes
replace acarunitdmonth=. if acarunitd==. & acarunitdmonth!=. & acarunitdyear!=. //0 changes
replace acarunitdyear=. if acarunitd==. & acarunitdyear!=. //0 changes
count if acarunitd==. & (acarunitdday!=. | acarunitdmonth!=. | acarunitdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if acarunitdday==88|acarunitdday==999|acarunitdday==9999 //0
count if acarunitdmonth==88|acarunitdmonth==999|acarunitdmonth==9999 //0
count if acarunitdyear==88|acarunitdyear==99|acarunitdyear==999 //0
** Invalid (before NotifiedDate)
count if acarunitd!=. & ambcalld!=. & acarunitd<ambcalld //0
** Invalid (before AtSceneDate)
count if acarunitd!=. & atscnd!=. & acarunitd<atscnd //0
** Invalid (before FromSceneDate)
count if acarunitd!=. & frmscnd!=. & acarunitd<frmscnd //0
** Invalid (before AtHospitalDate)
count if acarunitd!=. & hospd!=. & acarunitd<hospd //0
** Invalid (before EventDate)
count if acarunitd!=. & edate!=. & acarunitd<edate //0
** Invalid (after Cardiac Unit Discharge Date)
count if acarunitd!=. & dcarunitd!=. & acarunitd>dcarunitd //0

***********************
** CU Discharge Date **
***********************
** Missing date
count if dcarunitd==. & cunitdissame==2 //0
** Invalid (not 2021)
count if dcarunitd!=. & year(dcarunitd)!=2021 //0
** Invalid (before DOB)
count if dob!=. & dcarunitd!=. & dcarunitd<dob //0
** possibly Invalid (before CFAdmDate)
count if dcarunitd!=. & cfadmdate!=. & dcarunitd<cfadmdate //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & dcarunitd!=. & dcarunitd>dlc //0
count if cfdod!=. & dcarunitd!=. & dcarunitd>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if dcarunitd!=. & dae!=. & dcarunitd<dae //0
** possibly Invalid (before WardAdmDate)
count if dcarunitd!=. & doh!=. & dcarunitd<doh //0
** Invalid (future date)
count if dcarunitd!=. & dcarunitd>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if cunitdissame==2 & dcarunitd==. & dcarunitdday==99 & dcarunitdmonth==99 & dcarunitdyear==9999 //0
** possibly Invalid (dis date not partial but partial field not blank)
count if dcarunitd==. & dcarunitdday!=. & dcarunitdmonth!=. & dcarunitdyear!=. //0
replace dcarunitdday=. if dcarunitd==. & dcarunitdday!=. & dcarunitdmonth!=. & dcarunitdyear!=. //0 changes
replace dcarunitdmonth=. if dcarunitd==. & dcarunitdmonth!=. & dcarunitdyear!=. //0 changes
replace dcarunitdyear=. if dcarunitd==. & dcarunitdyear!=. //0 changes
count if dcarunitd==. & (dcarunitdday!=. | dcarunitdmonth!=. | dcarunitdyear!=.) //0
** Invalid missing code (notified date partial fields)
count if dcarunitdday==88|dcarunitdday==999|dcarunitdday==9999 //0
count if dcarunitdmonth==88|dcarunitdmonth==999|dcarunitdmonth==9999 //0
count if dcarunitdyear==88|dcarunitdyear==99|dcarunitdyear==999 //0
** Invalid (before NotifiedDate)
count if dcarunitd!=. & ambcalld!=. & dcarunitd<ambcalld //0
** Invalid (before AtSceneDate)
count if dcarunitd!=. & atscnd!=. & dcarunitd<atscnd //0
** Invalid (before FromSceneDate)
count if dcarunitd!=. & frmscnd!=. & dcarunitd<frmscnd //0
** Invalid (before AtHospitalDate)
count if dcarunitd!=. & hospd!=. & dcarunitd<hospd //0
** Invalid (before EventDate)
count if dcarunitd!=. & edate!=. & dcarunitd<edate //0
** Invalid (before Cardiac Unit Adm Date)
count if dcarunitd!=. & acarunitd!=. & dcarunitd<acarunitd //0


***********************
** Re-admission Info **
***********************
******************
** Re-admitted? **
******************
** Missing
count if readmit==. & vstatus!=. & discharge_complete!=0 & discharge_complete!=. //0
** Invalid missing code
count if readmit==88|readmit==999|readmit==9999 //0

***********************
** Re-admission Date **
***********************
** Missing date
count if readmitadm==. & readmit==1 //0
** Invalid (not 2021)
count if readmitadm!=. & year(readmitadm)!=2021 //0
** Invalid (before DOB)
count if dob!=. & readmitadm!=. & readmitadm<dob //0
** possibly Invalid (before CFAdmDate)
count if readmitadm!=. & cfadmdate!=. & readmitadm<cfadmdate //0
** possibly Invalid (before/after DLC/DOD)
count if dlc!=. & readmitadm!=. & readmitadm<dlc //0
count if cfdod!=. & readmitadm!=. & readmitadm>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if readmitadm!=. & dae!=. & readmitadm<dae //0
** possibly Invalid (before WardAdmDate)
count if readmitadm!=. & doh!=. & readmitadm<doh //0
** Invalid (future date)
count if readmitadm!=. & readmitadm>sd_currentdate //0
** Invalid (before NotifiedDate)
count if readmitadm!=. & ambcalld!=. & readmitadm<ambcalld //0
** Invalid (before AtSceneDate)
count if readmitadm!=. & atscnd!=. & readmitadm<atscnd //0
** Invalid (before FromSceneDate)
count if readmitadm!=. & frmscnd!=. & readmitadm<frmscnd //0
** Invalid (before AtHospitalDate)
count if readmitadm!=. & hospd!=. & readmitadm<hospd //0
** Invalid (before EventDate)
count if readmitadm!=. & edate!=. & readmitadm<edate //0
** Invalid (after Re-adm Discharge Date)
count if readmitdis!=. & readmitadm!=. & readmitadm>readmitdis //0
** Invalid (before Stroke Unit Adm Date)
count if readmitadm!=. & dstrunitd!=. & readmitadm>dstrunitd //0
** Invalid (before Stroke Unit Discharge Date)
count if readmitadm!=. & dstrunitd!=. & readmitadm>dstrunitd //0
** Invalid (before Cardiac Unit Adm Date)
count if readmitadm!=. & dcarunitd!=. & readmitadm>dcarunitd //0
** Invalid (before Cardiac Unit Discharge Date)
count if readmitadm!=. & dcarunitd!=. & readmitadm>dcarunitd //0

***************************
** Re-adm Discharge Date **
***************************
** Missing date
count if readmitdis==. & readmit==1 //0
** Invalid (not 2021)
count if readmitdis!=. & year(readmitdis)!=2021 //0
** Invalid (before DOB)
count if dob!=. & readmitdis!=. & readmitdis<dob //0
** possibly Invalid (before CFAdmDate)
count if readmitdis!=. & cfadmdate!=. & readmitdis<cfadmdate //0
** possibly Invalid (before/after DLC/DOD)
count if dlc!=. & readmitdis!=. & readmitdis<dlc //0
count if cfdod!=. & readmitdis!=. & readmitdis>cfdod //0
** possibly Invalid (before A&EAdmDate)
count if readmitdis!=. & dae!=. & readmitdis<dae //0
** possibly Invalid (before WardAdmDate)
count if readmitdis!=. & doh!=. & readmitdis<doh //0
** Invalid (future date)
count if readmitdis!=. & readmitdis>sd_currentdate //0
** Invalid (before NotifiedDate)
count if readmitdis!=. & ambcalld!=. & readmitdis<ambcalld //0
** Invalid (before AtSceneDate)
count if readmitdis!=. & atscnd!=. & readmitdis<atscnd //0
** Invalid (before FromSceneDate)
count if readmitdis!=. & frmscnd!=. & readmitdis<frmscnd //0
** Invalid (before AtHospitalDate)
count if readmitdis!=. & hospd!=. & readmitdis<hospd //0
** Invalid (before EventDate)
count if readmitdis!=. & edate!=. & readmitdis<edate //0
** Invalid (before Re-adm Date)
count if readmitdis!=. & readmitadm!=. & readmitdis<readmitadm //0
** Invalid (before Stroke Unit Adm Date)
count if readmitdis!=. & dstrunitd!=. & readmitdis>dstrunitd //0
** Invalid (before Stroke Unit Discharge Date)
count if readmitdis!=. & dstrunitd!=. & readmitdis>dstrunitd //0
** Invalid (before Cardiac Unit Adm Date)
count if readmitdis!=. & dcarunitd!=. & readmitdis>dcarunitd //0
** Invalid (before Cardiac Unit Discharge Date)
count if readmitdis!=. & dcarunitd!=. & readmitdis>dcarunitd //0

***************************
** # of days in Hospital **
***************************
** Missing
count if readmitdays==. & readmitadm!=. & readmitdis!=. //0
** Create variable for checking this auto-calculated variable in CVDdb
gen readmitdays2=readmitdis-readmitadm
count if readmitdays!=. & readmitdays2!=. & readmitdays!=readmitdays2 //0
drop readmitdays2





** Corrections from above checks
** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace ddvt=99999 if record_id=="3318"|record_id==""|record_id==""
replace dpneu=99999 if record_id==""|record_id==""|record_id==""
replace dulcer=99999 if record_id=="3318"|record_id==""|record_id==""
replace duti=99999 if record_id==""|record_id==""|record_id==""
replace dfall=99999 if record_id==""|record_id==""|record_id==""
replace dhydro=99999 if record_id==""|record_id==""|record_id==""
replace dhaemo=99999 if record_id==""|record_id==""|record_id==""
replace doinfect=99999 if record_id=="3318"|record_id==""|record_id==""
replace dgibleed=99999 if record_id=="3318"|record_id==""|record_id==""
replace dccf=99999 if record_id=="3318"|record_id==""|record_id==""
replace dcpang=99999 if record_id=="3318"|record_id==""|record_id==""
replace daneur=99999 if record_id=="3318"|record_id==""|record_id==""
replace dhypo=99999 if record_id=="3318"|record_id==""|record_id==""
replace dblock=99999 if record_id=="3318"|record_id==""|record_id==""
replace dseizures=99999 if record_id=="3318"|record_id==""|record_id==""
replace dafib=99999 if record_id=="3318"|record_id==""|record_id==""
replace dcshock=99999 if record_id=="3318"|record_id==""|record_id==""
replace dinfarct=99999 if record_id=="3318"|record_id==""|record_id==""
replace drenal=99999 if record_id=="3318"|record_id==""|record_id==""
replace dcarest=99999 if record_id=="3318"|record_id==""|record_id==""


** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
//replace flagdate=sd_currentdate if record_id==""|record_id==""




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
using "`datapath'\version03\3-output\CVDCleaning2021_DIS1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag986 flag1625 flag1637 flag1780 flag1781 flag1786 if ///
		 (flag986!=. | flag1625!=. | flag1637!=. |  flag1780!=. |  flag1781!=. |  flag1786!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_DIS1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
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
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_fu" ,replace