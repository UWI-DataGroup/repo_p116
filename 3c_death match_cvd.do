** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3c_death match_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-JAN-2023
    // 	date last modified      31-JAN-2023
    //  algorithm task          Matching cleaned, current CVD incidence dataset with cleaned death 2021 dataset
    //  status                  Completed
    //  objective               To have a cleaned and matched dataset with updated vital status and
	//							append any reportable deaths that were missed during data collection
    //  methods                 (1) Merge deaths with incidence using dd_natregno (death ds) and sd_natregno (incidence ds)
	//							(2) Review merged records to ensure matched with correct person
	//							(3) Perform duplicates checks using NRN, DOB and NAMES for all unmerged records
	//							(4) Fill in record_id (incidence ds) variables in matched death record 
	//							(5) Prep matched deaths for merge with ds in dofile 3d
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
    log using "`logpath'\3c_death match_cvd.smcl", replace
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
    Not matched                         3,278
        from master                       453  (_merge==1)
        from using                      2,825  (_merge==2)

    Matched                               246  (_merge==3)
    -----------------------------------------
*/

count //3524


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
count //3558
append using "`datapath'\version03\2-working\missNRNs_death"
count //3645

** Incidental spelling correction
replace fname=subinstr(fname,"Ã©","e",.) if record_id=="3024" //1 change - it's a misspelling error due to importing into Stata so DAs don't need to correct in CVDdb



*********
** DOB **
*********
** Create one DOB variable
replace dd_dob=dob if dd_dob==. & dob!=. //463 changes


** Identify possible matches using DOB
sort dd_dob
quietly by dd_dob : gen dup = cond(_N==1,0,_n)
sort dd_dob lname
count if dup>0 //709 - review these in Stata's Browse/Edit window
count if dup>0 & _merge!=3 //660 - review these in Stata's Browse/Edit window: ALL INCIDENCE multi-event records
//only review records that haven't already been merged 
//check electoral list (Sync/DM/Data/Electoral&Boundaries List/2019+2021_ElectoralList_20220516.xlsx) to determine which natregno is correct
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

** Create variable to separate out the records to merge using corrected NRNs above
gen match=1 if dd_deathid==35943|dd_deathid==36132|dd_deathid==35377|dd_deathid==37224|dd_deathid==36473|dd_deathid==35536

//gen alreadymatch=1 if _merge==3 //246 changes
preserve
drop if match!=1
keep dd_deathid dd_dob dd_natregno dd_pname dd_age dd_coddeath dd_fname dd_mname dd_lname dd_regnum dd_nrn dd_sex dd_dod dd_heart dd_stroke dd_cod1a dd_address dd_parish dd_pod dd_namematch dd_dddoa dd_ddda dd_odda dd_certtype dd_district dd_agetxt dd_nrnnd dd_mstatus dd_occu dd_durationnum dd_durationtxt dd_onsetnumcod1a dd_onsettxtcod1a dd_cod1b dd_onsetnumcod1b dd_onsettxtcod1b dd_cod1c dd_onsetnumcod1c dd_onsettxtcod1c dd_cod1d dd_onsetnumcod1d dd_onsettxtcod1d dd_cod2a dd_onsetnumcod2a dd_onsettxtcod2a dd_cod2b dd_onsetnumcod2b dd_onsettxtcod2b dd_deathparish dd_regdate dd_certifier dd_certifieraddr dd_cleaned dd_duprec dd_elecmatch dd_codheart dd_codstroke dd_dodyear dd_placeofdeath dd_redcap_event_name dd_recstatdc dd_event
save "`datapath'\version03\2-working\DOBs_death" ,replace
restore


count //3645
drop if match==1 //6 deleted

merge m:1 dd_natregno using "`datapath'\version03\2-working\DOBs_death" 
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,637
        from master                     3,635  (_merge==1)
        from using                          2  (_merge==2)

    Matched                                 4  (_merge==3)
    -----------------------------------------
*/
count //3641
STOP - merge not working properly; resolve issue tomorrow
DELETE all temp ds used in this process!!


order pid deathid fname lname primarysite dd_coddeath birthdate dob dd_dob natregno dot dod
//check there are no duplicate DOBs in the death ds as then it won't merge in 20d_final clean.do
** Review possible matches by DOB then if any are not "true" matches, tag these so that these can be dropped from the death ds for merging with the incidence ds in 20d_final clean.do
gen nomatch=1 if deathid==23918|deathid==24041

save "`datapath'\version09\2-working\possibledups_DOB" ,replace

keep if deathds==1 & dup>0 & nomatch==. //20,877 deleted
count //14
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_DOB" ,replace

** To ensure the death record correctly merges with its corresponding PID, use pid and cr5id as the variables in the mrege
gen matchpid=pid if pid=="20080653"
fillmissing matchpid
replace pid=matchpid if deathid==22396
gen matchcr5id=cr5id if pid=="20080653"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22396
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080734"
fillmissing matchpid
replace pid=matchpid if deathid==26352
gen matchcr5id=cr5id if pid=="20080734"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26352
drop matchpid matchcr5id

gen matchpid=pid if pid=="20140830"
fillmissing matchpid
replace pid=matchpid if deathid==19938
gen matchcr5id=cr5id if pid=="20140830"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19938
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080745"
fillmissing matchpid
replace pid=matchpid if deathid==19510
gen matchcr5id=cr5id if pid=="20080745"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19510
drop matchpid matchcr5id

gen matchpid=pid if pid=="20080722"
fillmissing matchpid
replace pid=matchpid if deathid==33989
gen matchcr5id=cr5id if pid=="20080722"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==33989
drop matchpid matchcr5id

gen matchpid=pid if pid=="20090060"
fillmissing matchpid
replace pid=matchpid if deathid==31532
gen matchcr5id=cr5id if pid=="20090060"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==31532
drop matchpid matchcr5id

gen matchpid=pid if pid=="20150072"
fillmissing matchpid
replace pid=matchpid if deathid==20717
gen matchcr5id=cr5id if pid=="20150072"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20717
drop matchpid matchcr5id

gen matchpid=pid if pid=="20160551"
fillmissing matchpid
replace pid=matchpid if deathid==30077
gen matchcr5id=cr5id if pid=="20160551"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==30077
drop matchpid matchcr5id

keep if deathds==1 & dupdob>0 & nomatch==. //20,869 deleted
count //8
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_DOBLNAME" ,replace
restore


** Tag records already checked so a review of possible matches is not repeated for NAMES check
replace matched=1 if deathid==19663|deathid==21407|deathid==22753|deathid==21969|deathid==27787|deathid==25481|deathid==30019|deathid==24170 ///
				|deathid==24587|deathid==26948|deathid==24025|deathid==20649|deathid==27723|deathid==25813|deathid==22396|deathid==26352 ///
				|deathid==19938|deathid==19510|deathid==33989|deathid==31532|deathid==20717|deathid==30077
//22 changes

count if matched==1 //1801

***********
** NAMES **
***********
drop if matched==1 //1801 deleted
sort lname fname
quietly by lname fname:  gen dup = cond(_N==1,0,_n)
count if dup>0 //2756 - review these in Stata's Browse/Edit window
//check these against MedData + electoral list as NRNs in death data often incorrect
order pid cr5id deathid fname lname birthdate natregno dd_dod dod dlc primarysite dd_coddeath init dd_mname dob dd_dob dot


gen matchpid=pid if pid=="20161116"
fillmissing matchpid
replace pid=matchpid if deathid==20840
gen matchcr5id=cr5id if pid=="20161116"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20840
drop matchpid matchcr5id
replace matched=1 if deathid==20840

gen matchpid=pid if pid=="20182010"
fillmissing matchpid
replace pid=matchpid if deathid==34035
gen matchcr5id=cr5id if pid=="20182010"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==34035
drop matchpid matchcr5id
replace matched=1 if deathid==34035

gen matchpid=pid if pid=="20170871"
fillmissing matchpid
replace pid=matchpid if deathid==23872
gen matchcr5id=cr5id if pid=="20170871"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23872
drop matchpid matchcr5id
replace matched=1 if deathid==23872

gen matchpid=pid if pid=="20180391"
fillmissing matchpid
replace pid=matchpid if deathid==26147
gen matchcr5id=cr5id if pid=="20180391"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26147
drop matchpid matchcr5id
replace matched=1 if deathid==26147

gen matchpid=pid if pid=="20180697"
fillmissing matchpid
replace pid=matchpid if deathid==25207
gen matchcr5id=cr5id if pid=="20180697"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25207
drop matchpid matchcr5id
replace matched=1 if deathid==25207

gen matchpid=pid if pid=="20170517"
fillmissing matchpid
replace pid=matchpid if deathid==35512
gen matchcr5id=cr5id if pid=="20170517"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==35512
drop matchpid matchcr5id
replace matched=1 if deathid==35512
replace natregno=subinstr(natregno,"41","47",.) if deathid==35512
replace dd_age=73 if deathid==35512

gen matchpid=pid if pid=="20170397"
fillmissing matchpid
replace pid=matchpid if deathid==32611
gen matchcr5id=cr5id if pid=="20170397"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==32611
drop matchpid matchcr5id
replace matched=1 if deathid==32611
replace natregno=subinstr(natregno,"34","64",.) if deathid==32611
replace dd_age=56 if deathid==32611

gen matchpid=pid if pid=="20161130"
fillmissing matchpid
replace pid=matchpid if deathid==19812
gen matchcr5id=cr5id if pid=="20161130"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19812
drop matchpid matchcr5id
replace matched=1 if deathid==19812

gen matchpid=pid if pid=="20160229"
fillmissing matchpid
replace pid=matchpid if deathid==20647
gen matchcr5id=cr5id if pid=="20160229"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20647
drop matchpid matchcr5id
replace matched=1 if deathid==20647
replace natregno=subinstr(natregno,"33","35",.) if deathid==20647
replace dd_age=80 if deathid==20647

gen matchpid=pid if pid=="20180039"
fillmissing matchpid
replace pid=matchpid if deathid==24781
gen matchcr5id=cr5id if pid=="20180039"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24781
drop matchpid matchcr5id
replace matched=1 if deathid==24781
replace natregno=subinstr(natregno,"44","40",.) if deathid==24781
replace dd_age=78 if deathid==24781

gen matchpid=pid if pid=="20130432"
fillmissing matchpid
replace pid=matchpid if deathid==36093
gen matchcr5id=cr5id if pid=="20130432"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==36093
drop matchpid matchcr5id
replace matched=1 if deathid==36093

gen matchpid=pid if pid=="20180920"
fillmissing matchpid
replace pid=matchpid if deathid==26845
gen matchcr5id=cr5id if pid=="20180920"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26845
drop matchpid matchcr5id
replace matched=1 if deathid==26845

gen matchpid=pid if pid=="20160881"
fillmissing matchpid
replace pid=matchpid if deathid==20030
gen matchcr5id=cr5id if pid=="20160881"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20030
drop matchpid matchcr5id
replace matched=1 if deathid==20030
replace natregno=subinstr(natregno,"7","8",.) if deathid==20030
replace natregno=subinstr(natregno,"808","807",.) if deathid==20030
replace dd_age=87 if deathid==20030

gen matchpid=pid if pid=="20160979"
fillmissing matchpid
replace pid=matchpid if deathid==21013
gen matchcr5id=cr5id if pid=="20160979"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==21013
drop matchpid matchcr5id
replace matched=1 if deathid==21013
replace natregno=subinstr(natregno,"08","68",.) if deathid==21013

gen matchpid=pid if pid=="20180556"
fillmissing matchpid
replace pid=matchpid if deathid==29324
gen matchcr5id=cr5id if pid=="20180556"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==29324
drop matchpid matchcr5id
replace matched=1 if deathid==29324
replace natregno=subinstr(natregno,"56","50",.) if deathid==29324
replace dd_age=69 if deathid==29324

gen matchpid=pid if pid=="20182135"
fillmissing matchpid
replace pid=matchpid if deathid==26013
gen matchcr5id=cr5id if pid=="20182135"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26013
drop matchpid matchcr5id
replace matched=1 if deathid==26013
replace natregno=subinstr(natregno,"50","20",.) if deathid==26013
replace dd_age=56 if deathid==26013

gen matchpid=pid if pid=="20181096"
fillmissing matchpid
replace pid=matchpid if deathid==24820
gen matchcr5id=cr5id if pid=="20181096"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24820
drop matchpid matchcr5id
replace matched=1 if deathid==24820

gen matchpid=pid if pid=="20172011"
fillmissing matchpid
replace pid=matchpid if deathid==34335
gen matchcr5id=cr5id if pid=="20172011"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==34335
drop matchpid matchcr5id
replace matched=1 if deathid==34335
replace natregno=subinstr(natregno,"90","70",.) if deathid==34335

gen matchpid=pid if pid=="20161106"
fillmissing matchpid
replace pid=matchpid if deathid==19512
gen matchcr5id=cr5id if pid=="20161106"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19512
drop matchpid matchcr5id
replace matched=1 if deathid==19512

gen matchpid=pid if pid=="20170731"
fillmissing matchpid
replace pid=matchpid if deathid==24335
gen matchcr5id=cr5id if pid=="20170731"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24335
drop matchpid matchcr5id
replace matched=1 if deathid==24335

gen matchpid=pid if pid=="20182158"
fillmissing matchpid
replace pid=matchpid if deathid==36194
gen matchcr5id=cr5id if pid=="20182158"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==36194
drop matchpid matchcr5id
replace matched=1 if deathid==36194

gen matchpid=pid if pid=="20170975"
fillmissing matchpid
replace pid=matchpid if deathid==22831
gen matchcr5id=cr5id if pid=="20170975"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22831
drop matchpid matchcr5id
replace matched=1 if deathid==22831

gen matchpid=pid if pid=="20172029"
fillmissing matchpid
replace pid=matchpid if deathid==23490
gen matchcr5id=cr5id if pid=="20172029"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23490
drop matchpid matchcr5id
replace matched=1 if deathid==23490

gen matchpid=pid if pid=="20180741"
fillmissing matchpid
replace pid=matchpid if deathid==25461
gen matchcr5id=cr5id if pid=="20180741"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25461
drop matchpid matchcr5id
replace matched=1 if deathid==25461

gen matchpid=pid if pid=="20160711"
fillmissing matchpid
replace pid=matchpid if deathid==21451
gen matchcr5id=cr5id if pid=="20160711"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==21451
drop matchpid matchcr5id
replace matched=1 if deathid==21451

gen matchpid=pid if pid=="20161189"
fillmissing matchpid
replace pid=matchpid if deathid==20617
gen matchcr5id=cr5id if pid=="20161189"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20617
drop matchpid matchcr5id
replace matched=1 if deathid==20617

gen matchpid=pid if pid=="20160852"
fillmissing matchpid
replace pid=matchpid if deathid==19632
gen matchcr5id=cr5id if pid=="20160852"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19632
drop matchpid matchcr5id
replace matched=1 if deathid==19632
replace natregno=subinstr(natregno,"52","42",.) if deathid==19632
replace dd_age=73 if deathid==19632

gen matchpid=pid if pid=="20160799"
fillmissing matchpid
replace pid=matchpid if deathid==22103
gen matchcr5id=cr5id if pid=="20160799"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22103
drop matchpid matchcr5id
replace matched=1 if deathid==22103

gen matchpid=pid if pid=="20170687"
fillmissing matchpid
replace pid=matchpid if deathid==22339
gen matchcr5id=cr5id if pid=="20170687"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22339
drop matchpid matchcr5id
replace matched=1 if deathid==22339
replace natregno=subinstr(natregno,"66","61",.) if deathid==22339
replace dd_age=55 if deathid==22339

gen matchpid=pid if pid=="20161200"
fillmissing matchpid
replace pid=matchpid if deathid==20355
gen matchcr5id=cr5id if pid=="20161200"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20355
drop matchpid matchcr5id
replace matched=1 if deathid==20355

gen matchpid=pid if pid=="20161201"
fillmissing matchpid
replace pid=matchpid if deathid==21408
gen matchcr5id=cr5id if pid=="20161201"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==21408
drop matchpid matchcr5id
replace matched=1 if deathid==21408

gen matchpid=pid if pid=="20160863"
fillmissing matchpid
replace pid=matchpid if deathid==19814
gen matchcr5id=cr5id if pid=="20160863"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==19814
drop matchpid matchcr5id
replace matched=1 if deathid==19814

gen matchpid=pid if pid=="20160569"
fillmissing matchpid
replace pid=matchpid if deathid==22258
gen matchcr5id=cr5id if pid=="20160569"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22258
drop matchpid matchcr5id
replace matched=1 if deathid==22258

gen matchpid=pid if pid=="20180097"
fillmissing matchpid
replace pid=matchpid if deathid==28783
gen matchcr5id=cr5id if pid=="20180097"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==28783
drop matchpid matchcr5id
replace matched=1 if deathid==28783

gen matchpid=pid if pid=="20180928"
fillmissing matchpid
replace pid=matchpid if deathid==25668
gen matchcr5id=cr5id if pid=="20180928"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25668
drop matchpid matchcr5id
replace matched=1 if deathid==25668

gen matchpid=pid if pid=="20180930"
fillmissing matchpid
replace pid=matchpid if deathid==26403
gen matchcr5id=cr5id if pid=="20180930"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26403
drop matchpid matchcr5id
replace matched=1 if deathid==26403

gen matchpid=pid if pid=="20171009"
fillmissing matchpid
replace pid=matchpid if deathid==23160
gen matchcr5id=cr5id if pid=="20171009"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23160
drop matchpid matchcr5id
replace matched=1 if deathid==23160

gen matchpid=pid if pid=="20180931"
fillmissing matchpid
replace pid=matchpid if deathid==26045
gen matchcr5id=cr5id if pid=="20180931"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26045
drop matchpid matchcr5id
replace matched=1 if deathid==26045

gen matchpid=pid if pid=="20180932"
fillmissing matchpid
replace pid=matchpid if deathid==26279
gen matchcr5id=cr5id if pid=="20180932"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==26279
drop matchpid matchcr5id
replace matched=1 if deathid==26279

gen matchpid=pid if pid=="20160893"
fillmissing matchpid
replace pid=matchpid if deathid==20242
gen matchcr5id=cr5id if pid=="20160893"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20242
drop matchpid matchcr5id
replace matched=1 if deathid==20242

gen matchpid=pid if pid=="20180159"
fillmissing matchpid
replace pid=matchpid if deathid==25174
gen matchcr5id=cr5id if pid=="20180159"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25174
drop matchpid matchcr5id
replace matched=1 if deathid==25174

gen matchpid=pid if pid=="20160482"
fillmissing matchpid
replace pid=matchpid if deathid==33721
gen matchcr5id=cr5id if pid=="20160482"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==33721
drop matchpid matchcr5id
replace matched=1 if deathid==33721
replace natregno=subinstr(natregno,"81","91",.) if deathid==33721

gen matchpid=pid if pid=="20162040"
fillmissing matchpid
replace pid=matchpid if deathid==22330
gen matchcr5id=cr5id if pid=="20162040"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22330
drop matchpid matchcr5id
replace matched=1 if deathid==22330
replace natregno=subinstr(natregno,"50","40",.) if deathid==22330

gen matchpid=pid if pid=="20180227"
fillmissing matchpid
replace pid=matchpid if deathid==25960
gen matchcr5id=cr5id if pid=="20180227"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==25960
drop matchpid matchcr5id
replace matched=1 if deathid==25960
replace natregno=subinstr(natregno,"20","50",.) if deathid==25960

gen matchpid=pid if pid=="20180935"
fillmissing matchpid
replace pid=matchpid if deathid==24573
gen matchcr5id=cr5id if pid=="20180935"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==24573
drop matchpid matchcr5id
replace matched=1 if deathid==24573
replace natregno=subinstr(natregno,"70","40",.) if deathid==24573

gen matchpid=pid if pid=="20170847"
fillmissing matchpid
replace pid=matchpid if deathid==22986
gen matchcr5id=cr5id if pid=="20170847"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==22986
drop matchpid matchcr5id
replace matched=1 if deathid==22986
replace natregno=subinstr(natregno,"02","20",.) if deathid==22986

gen matchpid=pid if pid=="20161110"
fillmissing matchpid
replace pid=matchpid if deathid==20792
gen matchcr5id=cr5id if pid=="20161110"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==20792
drop matchpid matchcr5id
replace matched=1 if deathid==20792

gen matchpid=pid if pid=="20170797"
fillmissing matchpid
replace pid=matchpid if deathid==23766
gen matchcr5id=cr5id if pid=="20170797"
fillmissing matchcr5id
replace cr5id=matchcr5id if deathid==23766
drop matchpid matchcr5id
replace matched=1 if deathid==23766

drop dup
keep if deathds==1 & matched==1 //21,630 deleted
count //48
save "`datapath'\version09\2-working\2015-2021_deaths_for_merging_NAMES" ,replace


/*
** Export corrections before dropping ineligible cases since errors maybe in these records (I only exported the flags with errors/corrections from above)
** Prepare this dataset for export to excel
** NOTE: once this list is generated then the code can be disabled to avoid generating multiple lists that will take up storage space on SharePoint
preserve
sort record_id

** Format the date flags so they are exported as dates not numbers
format flag45 flag970 %dM_d,_CY

** Create excel errors list before deleting incorrect records
** Use below code to automate file names using current date
local listdate = string( d(`c(current_date)'), "%dCYND" )
capture export_excel record_id sd_etype flag42 flag45 flag51 if ///
		flag42!="" | flag45!=. | flag51!="" ///
using "`datapath'\version03\3-output\CVDCleaning2021_CF3_`listdate'.xlsx", sheet("ERRORS") firstrow(varlabels)
capture export_excel record_id sd_etype flag967 flag970 flag976 if ///
		 flag967!="" | flag970!=. | flag976!="" ///
using "`datapath'\version03\3-output\CVDCleaning2021_CF3_`listdate'.xlsx", sheet("CORRECTIONS") firstrow(varlabels)
restore
*/

** Create cleaned, merged non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_merged_cf", replace