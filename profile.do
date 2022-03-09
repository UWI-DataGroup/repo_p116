** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          profile.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      31-MAY-2021
    // 	date last modified      09-MAR-2022
    //  algorithm task          Programming Stata's User Menu items to run particular dofiles from the Stata Results Window
    //  status                  Completed
    //  objective               (1) To have a drop-down option that once clicked runs the corresponding dofile linked to that option.
	//							(2) To have the SOP for this process also written into the dofile.
	//								The SOP is in the BNR Ops Manual OneNote book in the path - https://theuwi.sharepoint.com/sites/CaveHillTheBNR
    //  methods                 Creating the sub-menu option then associate the items for the sub-menu.
	//							This dofile is also saved in the paths: 
	//							(1) L:\Sync\CVD\Database Management\Redcap\Duplicates
	//							(2) C:\Program Files\Stata17 on the DMPC

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
** HEADER -----------------------------------------------------

window menu clear
window menu append submenu "stUser" "BNR"
window menu append submenu "BNR" "BNR-CVD"
window menu append submenu "BNR-CVD" "NFdb Transfer"
window menu append submenu "BNR-CVD" "CVD Duplicates"
window menu append submenu "BNR" "BNR-Cancer"
window menu append submenu "BNR-Cancer" "Casefinding"
window menu append submenu "BNR-Cancer" "Cancer Duplicates"
window menu append item "CVD Duplicates" "Heart" "run heart_duplicates_DMPC.do"
window menu append item "CVD Duplicates" "Stroke" "run stroke_duplicates_DMPC.do"
window menu append item "NFdb Transfer" "Identify NFdb" "run identify_NFCVD.do"
window menu append item "NFdb Transfer" "Transfer NFdb" "run transfer_NFCVD.do"
window menu append item "Casefinding" "CF Deaths" "run deathCF2020.do"
window menu refresh


