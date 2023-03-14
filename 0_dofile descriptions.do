*********************************************************************************************************************
*	BNR-CVD 2021 ANNUAL REPORT DOFILE GUIDE (format for this dofile taken from Christina Howitt's p120)
*********************************************************************************************************************

* NOTE1: to differentiate between data missing from patient notes (i.e. 99, 999 or 9999) VS 
*	     data missing from database, code 99999 has been used to signify data missing in CVDdb

* NOTE2: variable names prefixed with 'sd_' mean these are Stata derived variables

* NOTE3: variable names prefixed with 'dd_' mean these are Death Data derived variables

* NOTE4: there are several vital status variables as each document vital status at different points during the event
*		 slc = last known/contact vital status
*		 vstatus = vital status at discharge from hospital
*		 f1vstatus = vital status at day 28 post event

* NOTE5: labels prefixed with 'Death Data:' mean these are Death Data derived variables

* NOTE6: labels prefixed with 'Incidence Data:' mean these are Incidence Data/REDCap BNRCVD_CORE database variables
*		 All incidence variable labels are NOT prefixed with 'Incidence Data:' due to large number of variables
*		 All death data and Stata derived labels are prefixed so any labels that are missing a prefix are from the
*		 incidence database
*
*********************************************************************************************************************
*	CLEANING
*********************************************************************************************************************
*	1. 1_format_cvd.do
*      	*  Adds SharePoint header and pathways to the dofile that was exported from REDCap CVD database (CVDdb)
*
*   2. 2a_prep_cvd.do
*		* Removes non-annual report variables
*		* Collapses stroke repeating instruments into a single row per record
*		* Creates Stata-derived variables to be used in cleaning and analysis
*
*	3. 2b_prep flags_cvd.do
*		* Creates sequential, numbered variables (flags) corresponding to each variable in the REDCap CVDdb
*
*	4. 3a_clean cf_cvd.do
*		* Cleans each variable in the REDCap CVDdb Casefinding form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	5. 3b_clean dups_cvd.do
*		* Identifies and removes duplicates
*		* Identifies patients with both a stroke and heart event
*		* Identifies patients with multiple stroke events or multiple heart events
*		* Updates re-admission related data where applicable
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	6. 3c_prep mort.do
*		* Formats single year of already-cleaned death data
*		* Creates datasets for:
*			- Merging with incidence dataset
*			- Analysing age standardised mortality rates (ASMRs)
*	
*	7. 3d_death match_cvd.do
*		* Checks for matches between death and incidence data
*		* Merges verified matched death data with incidence data
*		* Updates analysis variables for DCO (death certificate only) cases
*	
*	8. 3e_clean demo_cvd.do
*		* Cleans each variable in the REDCap CVDdb Demographics form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	9. 3f_clean ptm_cvd.do
*		* Cleans each variable in the REDCap CVDdb Patient Management form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	10. 3g_clean event_cvd.do
*		* Cleans each variable in the REDCap CVDdb Event form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	11. 3h_clean hx_cvd.do
*		* Cleans each variable in the REDCap CVDdb History form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	12. 3i_clean tests_cvd.do
*		* Cleans each variable in the REDCap CVDdb Tests form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	13. 3j_clean comp_cvd.do
*		* Cleans each variable in the REDCap CVDdb Complications & Dx form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	14. 3k_clean rx_cvd.do
*		* Cleans each variable in the REDCap CVDdb Medications form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	15. 3l_clean dis_cvd.do
*		* Cleans each variable in the REDCap CVDdb Discharge form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	16. 3m_clean fu_cvd.do
*		* Cleans each variable in the REDCap CVDdb 28-day F/U form
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	17. 3n_clean final_cvd.do
*		* Checks and cleans analysis/report variables
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*
*********************************************************************************************************************


*********************************************************************************************************************
*	ANALYSIS
*********************************************************************************************************************
*	
*	1. 4_population_cvd.do
*		* Creates population datasets for WHO and WPP to be used in calculating rates
*		* Creates and exports to an excel workbook a list of errors and corrections for 
*		  the CVD data abstractors to correct the data directly in the REDCap CVDdb
*	
*	2. 5a_analysis prep_cvd.do
*		* Removes unnecessary variables (i.e. cleaning flags, etc.)
*		* Renames variable labels in prep for use in data requests
*		* Creates analysis variables
*		* Creates identifiable and deidentified datasets for:
*			- heart analysis/data requests
*			- stroke analysis/data requests
*		* Removes irrelevant variables (i.e. heart variables removed from stroke dataset and vice versa)
*		* Re-assigns variable that identifies records with both heart and stroke events (sd_bothevent)
*	
*	3. 6_analysis 2016-2020_cvd.do
*		* Creates datasets for outputting analysed results for 2016-2020 to MS Word and Excel
*   
*********************************************************************************************************************


