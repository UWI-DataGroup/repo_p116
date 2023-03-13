** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3d_death match_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-JAN-2023
    // 	date last modified      01-FEB-2023
    //  algorithm task          Matching cleaned, current CVD incidence dataset with cleaned death 2021 dataset
    //  status                  Completed
    //  objective               To have a cleaned and matched dataset with updated vital status and
	//							append any reportable deaths that were missed during data collection
    //  methods                 (1) Merge deaths with incidence using dd_natregno (death ds) and sd_natregno (incidence ds)
	//							(2) Review merged records to ensure matched with correct person
	//							(3) Perform duplicates checks using NRN, DOB and NAMES for all unmerged records
	//							(4) After verified matches are merged, update analysis variables in DCOs
	//							Note: to differentiate between data missing from patient notes (i.e. 99, 999 or 9999) VS 
	//								  data missing from database, code 99999 has been used to signify data missing in CVDdb
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
    log using "`logpath'\3d_death match_cvd.smcl", replace
** HEADER -----------------------------------------------------

***********
** MERGE **
***********
** Load CVD incidence ds (from dofile 3b_clean dups_cvd.do) that has no blank/missing NRNs in prep for merging with identifiable matching death ds (from dofile 4_prep mort.do)
use "`datapath'\version03\2-working\nomissNRNs_incidence", clear

count //699


** Create NRN to match NRN in death ds in prep for merge
gen dd_natregno=sd_natregno

merge m:1 dd_natregno using "`datapath'\version03\2-working\nomissNRNs_death" 

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,270
        from master                       448  (_merge==1)
        from using                      2,822  (_merge==2)

    Matched                               251  (_merge==3)
    -----------------------------------------

    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,278
        from master                       453  (_merge==1)
        from using                      2,825  (_merge==2)

    Matched                               246  (_merge==3)
    -----------------------------------------
*/

count //3524; 3521

** Create variable to differentiate records that have been matched/merged in prep for later matches using NRN, DOB and NAMES
gen match=1 if _merge==3 //246 changes


********************************
** CHECK AND IDENTIFY MATCHES **
********************************
** Search for matches by NRN, DOB, NAMES

*********
** NRN **
*********
** Identify possible matches using NRN (double checking merge didn't miss anything!)
sort dd_natregno 
quietly by dd_natregno : gen dup = cond(_N==1,0,_n)
sort dd_natregno lname fname record_id dd_deathid 
count if dup>0 //57 - review these in Stata's Browse/Edit window
count if dup>0 & _merge!=3 //39 - review these in Stata's Browse/Edit window: ALL INCIDENCE multi-event records
//only review records that haven't already been merged
order sd_etype record_id dd_deathid dd_natregno fname lname dd_pname dd_age age dd_coddeath cfcods
drop dup

** Now add back in the blank/missing NRNs from the incidence and death datasets
append using "`datapath'\version03\2-working\missNRNs_incidence"
count //3558; 3555
append using "`datapath'\version03\2-working\missNRNs_death"
count //3645; 3642

** Incidental spelling correction
replace fname=subinstr(fname,"Ã©","e",.) if record_id=="3024" //1 change - it's a misspelling error due to importing into Stata so DAs don't need to correct in CVDdb



*********
** DOB **
*********
** Create one DOB variable
replace dd_dob=dob if dd_dob==. & dob!=. //463; 458 changes


** Identify possible matches using DOB
sort dd_dob
quietly by dd_dob : gen dup = cond(_N==1,0,_n)
sort dd_dob lname
count if dup>0 //709; 703 - review these in Stata's Browse/Edit window
count if dup>0 & _merge!=3 //660; 654 - review these in Stata's Browse/Edit window
//only review records that haven't already been merged 
//check electoral list (Sync/DM/Data/Electoral&Boundaries List/2019+2021_ElectoralList_20220516.xlsx) + MedData to see which NRN is correct
//JC 31jan2023: I manually corrected NRNs from above in multi-year REDCap death db
order sd_etype record_id dd_deathid dd_dob dd_natregno fname lname dd_pname dd_age age dd_coddeath cfcods

** Correcting NRNs in death ds so can merge with the incidence ds
replace dd_natregno=subinstr(dd_natregno,"47","40",.) if dd_deathid==35943
replace dd_natregno=subinstr(dd_natregno,"15","13",.) if dd_deathid==35377
replace dd_natregno=subinstr(dd_natregno,"000","010",.) if dd_deathid==36473

** Correcting NRNs in incidence ds so can merge with the death ds (used MedData to correlate death record with incidence record using Hospital #)
replace flag51=sd_natregno if record_id=="3055"|record_id=="3773"
replace sd_natregno=subinstr(sd_natregno,"11","20",.) if record_id=="3055"
replace dd_natregno=subinstr(dd_natregno,"11","20",.) if record_id=="3055"
replace sd_natregno=subinstr(sd_natregno,"57","79",.) if record_id=="3773"
replace dd_natregno=subinstr(dd_natregno,"57","79",.) if record_id=="3773"
gen nrn=sd_natregno
destring nrn ,replace
replace natregno=nrn if record_id=="3055"|record_id=="3773"
drop nrn
replace flag976=sd_natregno if record_id=="3055"|record_id=="3773"

** NRN for record_id 2637 is blank and can't find the death NRN that corresponds with this incidence record on electoral list so going to add it in but DAs don't need to correct in CVDdb
preserve
clear
import excel using "`datapath'\version03\2-working\MissingNRN_20230131.xlsx" , firstrow case(lower)
tostring record_id, replace
destring elec_natregno, replace
tostring elec_sd_natregno, replace
save "`datapath'\version03\2-working\missing_nrn" ,replace
restore

drop _merge
merge m:1 record_id using "`datapath'\version03\2-working\missing_nrn" ,force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,641
        from master                     3,641  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------

    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,644
        from master                     3,644  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 1  (_merge==3)
    -----------------------------------------
*/
replace natregno=elec_natregno if _merge==3
replace sd_natregno=elec_sd_natregno if _merge==3
drop elec_* _merge
erase "`datapath'\version03\2-working\missing_nrn.dta"


** Add corresponding incidence record_id to death record in prep for merging the matches
replace record_id="3001" if dd_deathid==35943
replace record_id="3055" if dd_deathid==36132
replace record_id="2247" if dd_deathid==35377
replace record_id="3773" if dd_deathid==37224
replace record_id="2481" if dd_deathid==36473
replace record_id="2637" if dd_deathid==35536

** Create variable to separate out the records to merge using corrected NRNs above
replace match=1 if dd_deathid==35943|dd_deathid==36132|dd_deathid==35377|dd_deathid==37224|dd_deathid==36473|dd_deathid==35536
replace sd_casetype=2 if dd_deathid==35943|dd_deathid==36132|dd_deathid==35377|dd_deathid==37224|dd_deathid==36473|dd_deathid==35536
replace match=1 if record_id=="3001"|record_id=="3055"|record_id=="2247"|record_id=="3773"|record_id=="2481"|record_id=="2637"

preserve
keep if match==1 & sd_casetype==2 & record!="3001" & record!="2247" & record!="2481"
keep record_id dd_deathid dd_dob dd_natregno dd_pname dd_age dd_coddeath dd_fname dd_mname dd_lname dd_regnum dd_nrn dd_sex dd_dod dd_heart dd_stroke dd_cod1a dd_address dd_parish dd_pod dd_namematch dd_dddoa dd_ddda dd_odda dd_certtype dd_district dd_agetxt dd_nrnnd dd_mstatus dd_occu dd_durationnum dd_durationtxt dd_onsetnumcod1a dd_onsettxtcod1a dd_cod1b dd_onsetnumcod1b dd_onsettxtcod1b dd_cod1c dd_onsetnumcod1c dd_onsettxtcod1c dd_cod1d dd_onsetnumcod1d dd_onsettxtcod1d dd_cod2a dd_onsetnumcod2a dd_onsettxtcod2a dd_cod2b dd_onsetnumcod2b dd_onsettxtcod2b dd_deathparish dd_regdate dd_certifier dd_certifieraddr dd_cleaned dd_duprec dd_elecmatch dd_codheart dd_codstroke dd_dodyear dd_placeofdeath dd_redcap_event_name dd_recstatdc dd_event
count //6; 3
save "`datapath'\version03\2-working\DOBs_death" ,replace
restore


count //3645; 3642

** Remove death records in prep for merge
drop if match==1 & sd_casetype==2 & record!="3001" & record!="2247" & record!="2481" //6' 3 deleted
drop if record_id=="" //2906 deleted


merge 1:1 record_id using "`datapath'\version03\2-working\DOBs_death" ,update
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           730
        from master                       727  (_merge==1)
        from using                          3  (_merge==2)

    Matched                                 3
        not updated                         0  (_merge==3)
        missing updated                     2  (_merge==4)
        nonmissing conflict                 1  (_merge==5)
    -----------------------------------------

    Result                      Number of obs
    -----------------------------------------
    Not matched                           727
        from master                       727  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                 6
        not updated                         0  (_merge==3)
        missing updated                     5  (_merge==4)
        nonmissing conflict                 1  (_merge==5)
    -----------------------------------------
*/
count //733

** Add deaths back in for possible matches by NAMES
append using "`datapath'\version03\2-working\nomissNRNs_death"
count //3795; 3797
append using "`datapath'\version03\2-working\missNRNs_death"
count //3882; 3884

***********
** NAMES **
***********
** Update death NAMES variables in incidence dataset so can match using combined NAMES variables
replace dd_lname=lname if dd_lname=="" & lname!="" //481; 479 changes
replace dd_fname=fname if dd_fname=="" & fname!="" //481; 479 changes

drop dup
sort dd_lname dd_fname
quietly by dd_lname dd_fname:  gen dup = cond(_N==1,0,_n)
count if dup>0 //633 - review these in Stata's Browse/Edit window
count if dup>0 & _merge!=3 //633 - review these in Stata's Browse/Edit window
count if dup>0 & _merge!=3 & match!=1 //381; 384 - review these in Stata's Browse/Edit window
//only review records that haven't already been merged so the ones directly above
//check electoral list (Sync/DM/Data/Electoral&Boundaries List/2019+2021_ElectoralList_20220516.xlsx) to determine which natregno is correct
//JC 31jan2023: I manually corrected NRNs from above in multi-year REDCap death db
order sd_etype record_id dd_deathid dd_fname dd_lname dd_dob dd_natregno dd_dod cfadmdate dlc dd_coddeath cfcods dd_pname dd_age cfage age


** Correcting NRNs in death ds so can merge with the incidence ds
replace dd_natregno=subinstr(dd_natregno,"90","10",.) if dd_deathid==37092

replace dd_dob=dd_dob-2922 if dd_deathid==37092 //note I use an online date calculator (https://planetcalc.com/) to avoid entering identifiable data into dofile
replace dd_age=60 if dd_deathid==37092

** Correcting NRNs in incidence ds so can merge with the death ds (used MedData to correlate death record with incidence record using Hospital #)
replace flag51=sd_natregno if record_id=="2263"|record_id=="2720"|record_id=="2822"|record_id=="3763"|record_id=="2248"
replace sd_natregno=subinstr(sd_natregno,"90","10",.) if record_id=="2263"
replace dd_natregno=subinstr(dd_natregno,"90","10",.) if record_id=="2263"
replace sd_natregno=recnum if record_id=="2720"
replace sd_natregno=subinstr(sd_natregno,"21","24",.) if record_id=="2720"
replace dd_natregno=sd_natregno if record_id=="2720"
replace sd_natregno=subinstr(sd_natregno,"10","01",.) if record_id=="2822"
replace dd_natregno=subinstr(dd_natregno,"10","01",.) if record_id=="2822"
replace sd_natregno=subinstr(sd_natregno,"56","36",.) if record_id=="3763"
replace dd_natregno=subinstr(dd_natregno,"56","36",.) if record_id=="3763"
replace sd_natregno=subinstr(sd_natregno,"02","01",.) if record_id=="2248"
replace dd_natregno=subinstr(dd_natregno,"02","01",.) if record_id=="2248"
replace sd_natregno=subinstr(sd_natregno,"","",.) if record_id==""
replace dd_natregno=subinstr(dd_natregno,"","",.) if record_id==""
replace sd_natregno=subinstr(sd_natregno,"","",.) if record_id==""
replace dd_natregno=subinstr(dd_natregno,"","",.) if record_id==""
gen nrn=sd_natregno
destring nrn ,replace
replace natregno=nrn if record_id=="2263"|record_id=="2720"|record_id=="2822"|record_id=="3763"|record_id=="2248"
drop nrn
replace flag976=sd_natregno if record_id=="2263"|record_id=="2720"|record_id=="2822"|record_id=="3763"|record_id=="2248"

replace flag45=dob if record_id=="2263"|record_id=="2720"|record_id=="2822"|record_id=="3763"|record_id=="2248"
replace dd_dob=dd_dob-2922 if record_id=="2263"
replace dob=dob-2922 if record_id=="2263"
replace dd_dob=dd_dob+3 if record_id=="2720"
replace dob=dob+3 if record_id=="2720"
replace dd_dob=dd_dob-273 if record_id=="2822"
replace dob=dob-273 if record_id=="2822"
replace dd_dob=dd_dob-7305 if record_id=="3763"
replace dob=dob-7305 if record_id=="3763"
replace dd_dob=dd_dob-31 if record_id=="2248"
replace dob=dob-31 if record_id=="2248"
replace flag970=dob if record_id=="2263"|record_id=="2720"|record_id=="2822"|record_id=="3763"|record_id=="2248"
replace cfage=79 if record_id=="2263"
replace cfage=95 if record_id=="2822"
replace cfage=85 if record_id=="3763"

replace flag56=recnum if record_id=="2720"
replace recnum="" if record_id=="2720"
replace flag981=recnum if record_id=="2720"


** Add corresponding incidence record_id to death record in prep for merging the matches
replace record_id="2263" if dd_deathid==34388
replace record_id="2720" if dd_deathid==35809
replace record_id="2155" if dd_deathid==34525
replace record_id="2822" if dd_deathid==35695
replace record_id="3763" if dd_deathid==36037
replace record_id="2331" if dd_deathid==35236
replace record_id="2536" if dd_deathid==35631
replace record_id="2915" if dd_deathid==34481
//replace record_id="3521" if dd_deathid==37092 - 13feb2023 already matched above since running updated multi-yr db dataset
replace record_id="3524" if dd_deathid==37193
replace record_id="4196" if dd_deathid==36792
replace record_id="2248" if dd_deathid==35349
replace record_id="4115" if dd_deathid==37081
replace record_id="2938" if dd_deathid==35995

** Create variable to separate out the records to merge using corrected NRNs above
replace match=1 if dd_deathid==34388|dd_deathid==35809|dd_deathid==34525|dd_deathid==35695|dd_deathid==36037|dd_deathid==35236 ///
				  |dd_deathid==35631|dd_deathid==34481|dd_deathid==37193|dd_deathid==36792|dd_deathid==35349 ///
				  |dd_deathid==37081|dd_deathid==35995 //|dd_deathid==37092
replace sd_casetype=2 if dd_deathid==34388|dd_deathid==35809|dd_deathid==34525|dd_deathid==35695|dd_deathid==36037|dd_deathid==35236 ///
				  |dd_deathid==35631|dd_deathid==34481|dd_deathid==37193|dd_deathid==36792|dd_deathid==35349 ///
				  |dd_deathid==37081|dd_deathid==35995 //|dd_deathid==37092
replace match=1 if record_id=="2263"|record_id=="2720"|record_id=="2155"|record_id=="2822"|record_id=="3763"|record_id=="2331" ///
				  |record_id=="2536"|record_id=="2915"|record_id=="3524"|record_id=="4196"|record_id=="2248" ///
				  |record_id=="4115"|record_id=="2938" //|record_id=="3521"

preserve
keep if match==1 & sd_casetype==2
keep record_id dd_deathid dd_dob dd_natregno dd_pname dd_age dd_coddeath dd_fname dd_mname dd_lname dd_regnum dd_nrn dd_sex dd_dod dd_heart dd_stroke dd_cod1a dd_address dd_parish dd_pod dd_namematch dd_dddoa dd_ddda dd_odda dd_certtype dd_district dd_agetxt dd_nrnnd dd_mstatus dd_occu dd_durationnum dd_durationtxt dd_onsetnumcod1a dd_onsettxtcod1a dd_cod1b dd_onsetnumcod1b dd_onsettxtcod1b dd_cod1c dd_onsetnumcod1c dd_onsettxtcod1c dd_cod1d dd_onsetnumcod1d dd_onsettxtcod1d dd_cod2a dd_onsetnumcod2a dd_onsettxtcod2a dd_cod2b dd_onsetnumcod2b dd_onsettxtcod2b dd_deathparish dd_regdate dd_certifier dd_certifieraddr dd_cleaned dd_duprec dd_elecmatch dd_codheart dd_codstroke dd_dodyear dd_placeofdeath dd_redcap_event_name dd_recstatdc dd_event
count //14; 13
save "`datapath'\version03\2-working\NAMES_death" ,replace
restore


count //3882; 3884

** Remove death records in prep for merge
drop if match==1 & sd_casetype==2 & record!="3001" & record!="2247" & record!="2481" //14; 13 deleted
drop if record_id=="" //3135; 3138 deleted

drop _merge
merge 1:1 record_id using "`datapath'\version03\2-working\NAMES_death" ,update
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           720
        from master                       720  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                13
        not updated                         0  (_merge==3)
        missing updated                    13  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------

    Result                      Number of obs
    -----------------------------------------
    Not matched                           719
        from master                       719  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                14
        not updated                         0  (_merge==3)
        missing updated                    14  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------
*/
count //733


** Update incidence ds based on above corrections as some of the incidence variables are blank but in death they're not blank
replace flag51=sd_natregno if (sd_natregno==""|sd_natregno=="99") & dd_natregno!="" //6 changes
replace sd_natregno=dd_natregno if (sd_natregno==""|sd_natregno=="99") & dd_natregno!="" //6 changes
replace flag976=sd_natregno if flag51!="" & flag976=="" //6 changes

replace flag45=d(01jan2000) if dob==. & dd_dob!=. //6 changes
replace dob=dd_dob if dob==. & dd_dob!=. //6 changes
replace flag970=dob if flag45!=. & flag970==. //6 changes

replace cfage=(cfadmdate-dob)/365.25 if cfage==. & dob!=. & cfadmdate!=.

destring flag60 ,replace
destring flag985 ,replace
replace flag60=slc if slc!=2 & dd_deathid!=. //28 changes
replace slc=2 if slc!=2 & dd_deathid!=. //28 changes
replace flag985=slc if flag60!=. & flag985==. //28 changes

replace flag65=d(01jan2000) if dd_dod!=. & cfdod==. //28 changes
replace cfdod=dd_dod if dd_dod!=. & cfdod==. //28 changes
replace flag990=cfdod if flag65!=. & flag990==. //28 changes


** Add deaths back in for adding in missed cases found during death prep (i.e. heart/stroke deaths that were not matched with incidence records above)
append using "`datapath'\version03\2-working\nomissNRNs_death"
count //3795
append using "`datapath'\version03\2-working\missNRNs_death"
count //3882

** First remove death records that have already been matched/merged above
** Identify duplicate deathIDs to assist with death matching
drop dup
duplicates tag dd_deathid, gen(dup)
count if dup>0 //990
count if dup==0 //2892
count if dup>0 & record_id!="" //733
count if dup>0 & record_id!="" & dd_deathid!=. //266
//list record_id dd_deathid dup if dup>0, nolabel sepby(dd_deathid)
//list record_id dd_deathid dup if dup>0 & record_id!="", nolabel sepby(dd_deathid)
//list record_id dd_deathid dup if dup>0 & record_id!="" & dd_deathid!=., nolabel sepby(dd_deathid)
//list record_id dd_deathid dup if dup==0, nolabel sepby(dd_deathid)

** Remove the duplicate death records (i.e. the already merged death records)
count if dup>1 & record_id!="" & dd_deathid!=. //18 records merged with more than one incidence record
drop if dup>0 & dd_deathid!=. & record_id=="" //257 deleted 
drop dup

** Remove unmerged death records that are not assigned as heart or stroke
count if record_id=="" & dd_heart!=1 & dd_stroke!=1 //2478
count if record_id=="" & (dd_heart==1|dd_strok==1) //414
drop if record_id=="" & dd_heart!=1 & dd_stroke!=1 //2478 deleted

count if record_id=="" //414
count //1147


** Update incidence variables with death variables info for DCO cases as these are needed for cleaning and analysis
replace fname=dd_fname if (fname==""|fname=="99") & dd_fname!="" //414 changes
replace mname=dd_mname if (mname==""|mname=="99") & dd_mname!="" //164 changes
replace lname=dd_lname if (lname==""|lname=="99") & dd_lname!="" //414 changes
replace sd_natregno=dd_natregno if sd_natregno=="" & dd_natregno!="" //401 changes
replace natregno=dd_nrn if (natregno==.|natregno==88|natregno==99) & dd_nrn!=. //407 changes
replace sex=dd_sex if sex==. & dd_sex!=. //414 changes
replace age=dd_age if age==. & dd_age!=. //442 changes - none of the DCOs are under 1 so don't need to change dd_age=0
replace cfdod=dd_dod if cfdod==. & dd_dod!=. //414 changes
replace addr=dd_address if addr=="" & dd_address!="" //424 changes
replace parish=dd_parish if (parish==.|parish==99) & dd_parish!=. //425 changes
replace mstatus=dd_mstatus if (mstatus==.|mstatus==99) & dd_mstatus!=. //482 changes
replace dob=dd_dob if dob==. & dd_dob!=. //401 changes
replace sd_etype=1 if sd_etype==. & dd_stroke==1 //160 changes
replace sd_etype=2 if sd_etype==. & dd_heart==1 //254 changes
tab sd_etype ,m
count if dd_heart==1 & dd_stroke==1 //17
count if dd_heart==1 & dd_stroke==1 & sd_bothevent==. //11
tab sd_bothevent ,m //don't update sd_bothevent until later the final cleaning dofile after the datasets are split into heart and stroke
replace sd_etype=3 if sd_etype==. & dd_stroke==1 & dd_heart==1 //0 changes
replace dlc=dd_dod if (dlc==.|dlc==99) & dd_dod!=. //414 changes
replace slc=2 if cfdod!=. //414 changes
replace edate=cfdod if edate==. & sd_casetype==2 //414 changes
//replace etime="99" if etime=="" & sd_casetype==2 //414 changes - ask NS if to update this variable because we're changing the meaning of the 99 since time of event for DCOs would never be documented anyway; leave as blank as noted by NS on 06-Feb-2023 at CVD mtg.

count if slc==2 & cfdod==. //1 - stroke record 3362: cannot find pt in 2022 or multi-yr Deathdb + no death info in MedData but documented as dead on 28d form



** JC 09feb2023: Now realized that records already flagged and exported to a previous excel will recur as they still exist in the dataset so need to date each flagged record in this dofile
gen currentd=c(current_date)
gen double sd_currentdate=date(currentd, "DMY", 2017)
drop currentd
format sd_currentdate %dD_m_CY

gen flagdate=sd_currentdate if record_id=="3055"|record_id=="3773"|record_id=="2263"|record_id=="2720"|record_id=="2822"|record_id=="3763"|record_id=="2248"|(flag51!="" & flag976=="")|(flag45!=. & flag970==.)|(flag60!=. & flag985==.)|(flag65!=. & flag990==.)

/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flag45 flag970 flag65 flag990 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag45 flag51 flag56 flag60 flag65 if ///
		flag45!=. | flag51!="" | flag56!="" | flag60!=. | flag65!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_CF4_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag970 flag976 flag981 flag985 flag990 if ///
		 flag970!=. | flag976!="" | flag981!="" | flag985!=. | flag990!=. ///
using "`datapath'\version03\3-output\CVDCleaning2021_CF4_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/


** Remove unnecessary variables
drop _merge match c d sd_currentdate flagdate

** To reduce storage space on SharePoint, remove temporary datasets used in the above process
erase "`datapath'\version03\2-working\nomissNRNs_death.dta"
erase "`datapath'\version03\2-working\missNRNs_death.dta"
erase "`datapath'\version03\2-working\nomissNRNs_incidence.dta"
erase "`datapath'\version03\2-working\missNRNs_incidence.dta"
erase "`datapath'\version03\2-working\DOBs_death.dta"
erase "`datapath'\version03\2-working\NAMES_death.dta"

** Create cleaned, merged non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_merged_cf", replace