** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3e_clean demo_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-FEB-2023
    // 	date last modified      02-FEB-2023
    //  algorithm task          Cleaning variables in the REDCap CVDdb Demographics form
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
    log using "`logpath'\3e_clean demo_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load merged unduplicated 2021 dataset (from dofile 3d_death match_cvd.do)
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_nodups_merged_cf", clear


** Cleaning each variable as they appear in REDCap BNRCVD_CORE db

********************
** Marital Status **
********************
** Missing
count if mstatus==. & eligible!=. //0
count if retsource==98 & oretsrce=="" //0
** Invalid missing code
count if retsource==88|retsource==999|retsource==9999 //0















** Create cleaned dataset
save "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_demo" ,replace