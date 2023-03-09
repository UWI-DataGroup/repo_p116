** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3m_clean fu_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      07-MAR-2023
    // 	date last modified      09-MAR-2023
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
drop stopsmokeage2 stopsmokeage3

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

**************************
** What did they smoke? **
**************************
****************
** Cigarettes **
****************
** Missing
count if cig==. & smoke!=. & smoke<4 //0
** Invalid missing code
count if cig==88|cig==999|cig==9999 //0
** Missing (quantity)
count if cignum==. & cig==1 //0
** Invalid missing code (quantity)
count if cignum==88|cignum==99|cignum==999|cignum==9999 //13 - for NS to review
** Invalid range (quantity)
count if cig==1 & (cignum==0|cignum>350) //8 - same as above
**************************
** Pipe + Other tobacco **
**************************
** Missing
count if pipe==. & smoke!=. & smoke<4 //0
count if otobacco==. & smoke!=. & smoke<4 //0
** Invalid missing code
count if pipe==88|pipe==999|pipe==9999 //0
count if otobacco==88|otobacco==999|otobacco==9999 //0
** Missing (quantity)
count if tobgram==. & (pipe==1|otobacco==1) //0
** Invalid missing code (quantity)
count if tobgram==88|tobgram==99|tobgram==999|tobgram==9999 //2 - for NS to review
** Invalid range (quantity)
count if (pipe==1|otobacco==1) & (tobgram==0|tobgram>60) //2 - same as above
************
** Cigars **
************
** Missing
count if cigar==. & smoke!=. & smoke<4 //0
** Invalid missing code
count if cigar==88|cigar==999|cigar==9999 //0
** Missing (quantity)
count if cigarnum==. & cigar==1 //0
** Invalid missing code (quantity)
count if cigarnum==88|cigarnum==99|cigarnum==999|cigarnum==9999 //0
** Invalid range (quantity)
count if cigar==1 & (cigarnum==0|cigarnum>20) //0
*************************************
** Tobac. w/ Marijuana + Marijuana **
*************************************
** Missing
count if tobacmari==. & smoke!=. & smoke<4 //0
count if marijuana==. & smoke!=. & smoke<4 //0
** Invalid missing code
count if tobacmari==88|tobacmari==999|tobacmari==9999 //0
count if marijuana==88|marijuana==999|marijuana==9999 //0
** Missing (quantity)
count if spliffnum==. & (tobacmari==1|marijuana==1) //0
** Invalid missing code (quantity)
count if spliffnum==88|spliffnum==99|spliffnum==999|spliffnum==9999 //12 - for NS to review
** Invalid range (quantity)
count if (tobacmari==1|marijuana==1) & (spliffnum==0|spliffnum>75) //12 - same as above


***************************
** Drinking History Info **
***************************
*********************
** Did they alcohol? **
*********************
** Missing
count if alcohol==. & f1vstatus==1 & fu1sicf==1 //0
** Invalid missing code
count if alcohol==88|alcohol==999|alcohol==9999 //0

*********************
** Stop alcohol Date **
*********************
** Missing
count if stopalc==. & alcohol==3 //7 - entered as 99 in CVDdb but stroke records 2856, 2885  + heart record 2210 has partial dates in DA comments so corrected below
** Invalid (before DOB)
count if dob!=. & stopalc!=. & stopalc<dob //0
** Invalid (after FU date)
count if fu1doa2!=. & stopalc!=. & stopalc>fu1doa2 //0
** possibly Invalid (after DLC/DOD)
count if dlc!=. & stopalc!=. & stopalc>dlc //0
count if cfdod!=. & stopalc!=. & stopalc>cfdod //0
** Invalid (future date)
count if stopalc!=. & stopalc>sd_currentdate //0
** Invalid (date partial missing codes for all)
count if alcohol==3 & stopalc==. & stopalcday==99 & stopalcmonth==99 & stopalcyear==9999 //0
** possibly Invalid (stop alcohol date not partial but partial field not blank)
count if stopalc==. & stopalcday!=. & stopalcmonth!=. & stopalcyear!=. //1 - it's correct leave as is
//replace stopalcday=. if stopalc==. & stopalcday!=. & stopalcmonth!=. & stopalcyear!=. //0 changes
//replace stopalcmonth=. if stopalc==. & stopalcmonth!=. & stopalcyear!=. //0 changes
//replace stopalcyear=. if stopalc==. & stopalcyear!=. //0 changes
count if stopalc==. & (stopalcday!=. | stopalcmonth!=. | stopalcyear!=.) //1 - it's correct leave as is
** Invalid missing code (notified date partial fields)
count if stopalcday==88|stopalcday==999|stopalcday==9999 //0
count if stopalcmonth==88|stopalcmonth==999|stopalcmonth==9999 //0
count if stopalcyear==88|stopalcyear==99|stopalcyear==999 //0





** Corrections from above checks
destring flag907 ,replace
destring flag1832 ,replace
destring flag908 ,replace
destring flag1833 ,replace
destring flag909 ,replace
destring flag1834 ,replace
destring flag910 ,replace
destring flag1835 ,replace
destring flag911 ,replace
destring flag1836 ,replace


replace flag908=stopalcday if record_id=="2210"|record_id=="2856"
replace stopalcday=99 if record_id=="2210"|record_id=="2856" //see above
replace flag1833=stopalcday if record_id=="2210"|record_id=="2856"

replace flag909=stopalcmonth if record_id=="2210"|record_id=="2856"
replace stopalcmonth=99 if record_id=="2210"|record_id=="2856" //see above
replace flag1834=stopalcmonth if record_id=="2210"|record_id=="2856"

replace flag910=stopalcyear if record_id=="2210"|record_id=="2856"
replace stopalcyear=2005 if record_id=="2210" //see above
replace stopalcyear=2018 if record_id=="2856" //see above
replace flag1835=stopalcyear if record_id=="2210"|record_id=="2856"

replace flag907=stopalc if record_id=="2885"
replace stopalc=edate if record_id=="2885" //see above
replace stopalc=stopalc-365 if record_id=="" //see above
replace flag1832=stopalc if record_id=="2885"

** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2210"|record_id=="2856"|record_id=="2885"


*************************
** Age stopped drinking **
*************************
** Create variable for age stopped drinking as this variable is auto-calculated in CVDdb so need to check it's correct
gen stopalcage3=(stopalc-dob)/365.25
gen stopalcage2=int(stopalcage3)
count if stopalcage!=. & stopalcage2!=. & stopalcage!=stopalcage2 //0
//list record_id dob stopalc stopalcage stopalcage2 if stopalcage!=. & stopalcage2!=. & stopalcage!=stopalcage2
count if dob!=. & stopalc!=. & stopalcage==. //2
count if dob!=. & stopalc!=. & stopalcage2==. //0
replace stopalcage=stopalcage2 //2 changes
drop stopalcage2 stopalcage3

***********************
** Age began smoking **
***********************
** Missing
count if alcage==. & alcohol!=. & alcohol<4 //0
** Invalid missing code
count if alcage==9999 //0
** Invalid (age began smoking<5)
count if alcage<5 //0
** Invalid (age stopped drinking before age began drinking)
count if stopalcage!=. & alcage!=. & alcage!=999 & stopalcage<alcage //0
** Invalid (age at event before age began drinking)
count if age!=. & alcage!=. & alcage!=999 & age<alcage //2 - stroke records 2617 + 3654 corrected below

**************************
** What did they drink? **
**************************
**********
** Beer **
**********
** Missing
count if beernumnd==. & (alcohol==1|alcohol==3) //0
** Invalid missing code
count if beernumnd==88|beernumnd==999|beernumnd==9999 //0
** Missing (quantity)
count if beernum==. & beernumnd==1 //0
** Invalid missing code (quantity)
count if beernum==88|beernum==99|beernum==999|beernum==9999 //14 - for NS to review
** Invalid range (quantity)
count if beernumnd==1 & (beernum==0|beernum>150) //11 - same as above
**********
** Wine **
**********
** Missing
count if winenumnd==. & (alcohol==1|alcohol==3) //0
** Invalid missing code
count if winenumnd==88|winenumnd==999|winenumnd==9999 //0
** Missing (quantity)
count if winenum==. & winenumnd==1 //0
** Invalid missing code (quantity)
count if winenum==88|winenum==99|winenum==999|winenum==9999 //8 - for NS to review
** Invalid range (quantity)
count if winenumnd==1 & (winenum==0|winenum>150) //7 - same as above


*******************
** 28-day Rankin **
*******************
** Missing (cannot/refuse to answer f1rankin)
count if f1rankin==. & edatefu1doadiff>25 & edatefu1doadiff<31 & sd_etype==1 & f1vstatus==1 & fu1sicf==1 & f1rankin1==. //1 - stroke record 3027 unanswered by DA so corrected below
** Invalid missing code
count if f1rankin==88|f1rankin==99|f1rankin==999|f1rankin==9999 //0
** Invalid (28-day rankin done but F/U done more than 30 days after event)
count if f1rankin!=. & edatefu1doadiff>30 //0
count if f1rankin1!=. & edatefu1doadiff>30 //0
** Missing (1) - same as above
count if f1rankin==. & edatefu1doadiff>25 & edatefu1doadiff<31 & sd_etype==1 & f1vstatus==1 & fu1sicf==1 & f1rankin1==. //1 - same as above
** Invalid missing code
count if f1rankin1==88|f1rankin1==99|f1rankin1==999|f1rankin1==9999 //0
** Missing (2)
count if f1rankin2==. & f1rankin1==1 //0
** Invalid missing code
count if f1rankin2==88|f1rankin2==99|f1rankin2==999|f1rankin2==9999 //0
** possibly Invalid (f1rankin1=No; f1rankin2 NOT blank)
count if f1rankin1==2 & f1rankin2!=. //0
** Missing (3)
count if f1rankin3==. & f1rankin2==2 //0
** Invalid missing code
count if f1rankin3==88|f1rankin3==99|f1rankin3==999|f1rankin3==9999 //0
** possibly Invalid (f1rankin2=Yes; f1rankin3 NOT blank)
count if f1rankin2==1 & f1rankin3!=. //0
** Missing (4)
count if f1rankin4==. & f1rankin3==2 //0
** Invalid missing code
count if f1rankin4==88|f1rankin4==99|f1rankin4==999|f1rankin4==9999 //0
** possibly Invalid (f1rankin3=Yes; f1rankin4 NOT blank)
count if f1rankin3==1 & f1rankin4!=. //0
** Missing (5)
count if f1rankin5==. & f1rankin4==2 //0
** Invalid missing code
count if f1rankin5==88|f1rankin5==99|f1rankin5==999|f1rankin5==9999 //0
** possibly Invalid (f1rankin4=Yes; f1rankin5 NOT blank)
count if f1rankin4==1 & f1rankin5!=. //0
** Missing (6)
count if f1rankin6==. & f1rankin5==2 //0
** Invalid missing code
count if f1rankin6==88|f1rankin6==99|f1rankin6==999|f1rankin6==9999 //0
** possibly Invalid (f1rankin5=Yes; f1rankin6 NOT blank)
count if f1rankin5==1 & f1rankin6!=. //0




** Corrections from above checks
destring flag911 ,replace
destring flag1836 ,replace

** Since the missing code 99999 is only to be used in the cleaning and analysis steps of data handling the DAs do not need to update the CVDdb
replace f1rankin1=99999 if record_id=="3027"


replace flag911=alcage if record_id=="2617"|record_id=="3654"
replace alcage=999 if record_id=="2617"|record_id=="3654" //see above
replace flag1836=alcage if record_id=="2617"|record_id=="3654"

** JC 09feb2023: Create flag date variable so that records already flagged and exported to a previous excel will not recur as they still exist in the dataset
replace flagdate=sd_currentdate if record_id=="2617"|record_id=="3654"


STOP



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
using "`datapath'\version03\3-output\CVDCleaning2021_FU1_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag986 flag1625 flag1637 flag1780 flag1781 flag1786 if ///
		 (flag986!=. | flag1625!=. | flag1637!=. |  flag1780!=. |  flag1781!=. |  flag1786!=.) & flagdate!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_FU1_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
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


** Remove unnecessary variables
drop fu1doa2 fu1date

** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_fu" ,replace