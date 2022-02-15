** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          heart_results report.do
    //  project:                BNR-Heart
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      15-FEB-2022
    // 	date last modified      15-FEB-2022
    //  algorithm task          Creating MS Word document with statistical + figure outputs for 2020 annual report
    //  status                  Pending
    //  objective               To have methods, tables, figures and text in an easy-to-use format for the report writer
    //  methods                 Use putdocx, tabout and Stata memory commands to export results to MS Word

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
    log using "`logpath'\heart_results report.smcl", replace
** HEADER -----------------------------------------------------

