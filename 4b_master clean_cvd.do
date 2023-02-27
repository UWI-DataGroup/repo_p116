** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          4b_master clean_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      02-FEB-2023
    // 	date last modified      02-FEB-2023
    //  algorithm task          Running all the dofiles preceding this one
    //  status                  Completed
    //  objective               (1) To have a dofile to run all the cleaning dofiles preceding it, i.e. dofiles 0 to 4a
	//							(2) To have a dofile that can be used in conjunction with the profile dofile already saved on DMPC 
	//								that is used to automate the running of the casefinding duplicates dofiles
    //  methods                 Using the 'do' command in Stata
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

    ** Set working directories: this is for DOFILE, DATASET and LOGFILE import and export
    ** DOFILES to unencrypted OneDrive folder
    local dopath "X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p116"
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p116"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p116"
	
    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\4b_master clean_cvd.smcl", replace
** HEADER -----------------------------------------------------

** dofile 1
do "`dopath'\1_format_cvd"

** dofile 2a
do "`dopath'\2a_prep_cvd"

** dofile 2b
do "`dopath'\2b_prep flags_cvd"

** dofile 3a
do "`dopath'\3a_clean cf_cvd"

** dofile 3b
do "`dopath'\3b_clean dups_cvd"

** dofile 3c
do "`dopath'\3c_prep mort"

** dofile 3d
do "`dopath'\3d_death match_cvd"

** dofile 3e
do "`dopath'\3e_clean demo_cvd"

** dofile 3f
do "`dopath'\3f_clean ptm_cvd"

** dofile 3g
do "`dopath'\3g_clean event_cvd"

** dofile 3h
do "`dopath'\3h_clean hx_cvd"

** dofile 3i
do "`dopath'\3i_clean tests_cvd"

** dofile 3j
do "`dopath'\3j_clean comp_cvd"
/*
** dofile 3k
do "`dopath'\3k_clean rx_cvd"

** dofile 3l
do "`dopath'\3l_clean dis_cvd"

** dofile 3m
do "`dopath'\3m_clean fu_cvd"

** dofile 4a
do "`dopath'\4a_final clean_cvd"