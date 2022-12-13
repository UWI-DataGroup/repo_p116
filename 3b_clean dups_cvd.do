** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3b_clean dups_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      13-DEC-2022
    // 	date last modified      13-DEC-2022
    //  algorithm task          Identifying, reviewing and removing duplicates
    //  status                  Pending
    //  objective               To have a cleaned 2021 cvd incidence dataset ready for analysis
    //  methods                 Using Stata command quietly sort to:
	//							(1) identify and remove duplicate admissions (i.e. same patient with same admissions entered in different records)
	//							(2) identify multiple events (i.e. same patient with another event >28 days after first event)
	//							(3) identify and update re-admission info (i.e. same patient with different admissions for same event)
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
    log using "`logpath'\3b_clean dups_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load prepared 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_cf", clear


PERFORM DUPLICATES CHECKS USING NRN, DOB, NAMES AFTER COMPLETION OF THE CF FORM AND BEFORE PROCEEDING TO CLEANING THE OTHER FORMS
see cancer dups process and cvd dups dofiles in Sync/CVD/Db/Redcap/Duplicates

** Create cleaned non-duplicates dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_cf", replace