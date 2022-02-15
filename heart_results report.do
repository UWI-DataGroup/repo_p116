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


*************************
**  SUMMARY STATISTICS **
*************************
** Annual report: Table 1.1
** Load the heart cleaned dataset AH used in 1.0_heart_cvd_analysis.do
use "`datapath'\version02\3-output\heart_2009-2020_v9_anonymised_Stata_v16_clean(25-Jan-2022)", clear

count //4794

** POPULATION
gen poptot_2020=277814

** REGISTRATIONS
egen hregtot_2020=count(anon_pid) if year==2020
gen hregtotper_2020=hregtot_2020/poptot_2020*100
format hregtotper_2020 %04.2f

** HOSPITAL ADMISSIONS
stop
egen patienttot_2013=count(pid) if patient==1 & dxyr==2013
egen patienttot_2014=count(pid) if patient==1 & dxyr==2014
egen patienttot_2015=count(pid) if patient==1 & dxyr==2015
** DCOs
egen dco_2013=count(pid) if basis==0 &  dxyr==2013
egen dco_2014=count(pid) if basis==0 &  dxyr==2014
egen dco_2015=count(pid) if basis==0 &  dxyr==2015
gen dcoper_2013=dco_2013/tumourtot_2013*100
gen dcoper_2014=dco_2014/tumourtot_2014*100
gen dcoper_2015=dco_2015/tumourtot_2015*100
format dcoper_2013 dcoper_2014 dcoper_2015 %2.1f
