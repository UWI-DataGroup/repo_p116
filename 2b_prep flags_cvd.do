** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          2b_prep flags_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      01-NOV-2022
    // 	date last modified      02-NOV-2022
    //  algorithm task          Creating flags for each variable
    //  status                  Completed
    //  objective               To have the prepared 2021 cvd incidence dataset with flagged fields for the CVD team to correct data in REDCap's BNRCVD_CORE db
    //  methods                 Using forvalues loop to create sequential flag variables for each field in the db except the reviewing form fields
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
    log using "`logpath'\2b_prep flags_cvd.smcl", replace
** HEADER -----------------------------------------------------

STOP
/*
	In order for the cancer team to correct the data in CanReg5 database based on the errors and corrections found and performed 
	during this Stata cleaning process, a file with the erroneous and corrected data needs to be created.
	Using the cancer duplicates process for flagging errors and corrections,
	
	(1)	Create flags for errors within found in all the variables
	(2)	Create flags for corrections performed on all the erroneous data by variable
	(3)	Create list with these error and correction flags that is exported to an excel workbook for SDA to correct in CR5db
*/

forvalues j=1/94 {
	gen flag`j'=""
}

label var flag1 "Error: STDataAbstractor"
label var flag2 "Error: STSourceDate"
label var flag3 "Error: NFType"
label var flag4 "Error: SourceName"
label var flag5 "Error: Doctor"
label var flag6 "Error: DoctorAddress"
label var flag7 "Error: RecordNumber"
label var flag8 "Error: CFDiagnosis"
label var flag9 "Error: LabNumber"
label var flag10 "Error: SurgicalNumber"
label var flag11 "Error: Specimen"
label var flag12 "Error: SampleTakenDate"
label var flag13 "Error: ReceivedDate"
label var flag14 "Error: ReportDate"
label var flag15 "Error: ClinicalDetails"
label var flag16 "Error: CytologicalFindings"
label var flag17 "Error: MicroscopicDescription"
label var flag18 "Error: ConsultationReport"
label var flag19 "Error: SurgicalFindings"
label var flag20 "Error: SurgicalFindingsDate"
label var flag21 "Error: PhysicalExam"
label var flag22 "Error: PhysicalExamDate"
label var flag23 "Error: ImagingResults"
label var flag24 "Error: ImagingResultsDate"
label var flag25 "Error: CausesOfDeath"
label var flag26 "Error: DurationOfIllness"
label var flag27 "Error: OnsetDeathInterval"
label var flag28 "Error: Certifier"
label var flag29 "Error: AdmissionDate"
label var flag30 "Error: DateFirstConsultation"
label var flag31 "Error: RTRegDate"
label var flag32 "Error: Recordstatus"
label var flag33 "Error: TTDataAbstractor"
label var flag34 "Error: TTAbstractionDate"
label var flag35 "Error: DuplicateCheck"
label var flag36 "Error: Parish"
label var flag37 "Error: Address"
label var flag38 "Error: Age"
label var flag39 "Error: PrimarySite"
label var flag40 "Error: Topography"
label var flag41 "Error: Histology"
label var flag42 "Error: Morphology"
label var flag43 "Error: Laterality"
label var flag44 "Error: Behaviour"
label var flag45 "Error: Grade"
label var flag46 "Error: BasisOfDiagnosis"
label var flag47 "Error: TNMCatStage"
label var flag48 "Error: TNMAntStage"
label var flag49 "Error: EssTNMCatStage"
label var flag50 "Error: EssTNMAntStage"
label var flag51 "Error: SummaryStaging"
label var flag52 "Error: IncidenceDate"
label var flag53 "Error: DiagnosisYear"
label var flag54 "Error: Consultant"
label var flag55 "Error: Treatment1"
label var flag56 "Error: Treatment1Date"
label var flag57 "Error: Treatment2"
label var flag58 "Error: Treatment2Date"
label var flag59 "Error: Treatment3"
label var flag60 "Error: Treatment3Date"
label var flag61 "Error: Treatment4"
label var flag62 "Error: Treatment4Date"
label var flag63 "Error: Treatment5"
label var flag64 "Error: Treatment5Date"
label var flag65 "Error: OtherTreatment1"
label var flag66 "Error: OtherTreatment2"
label var flag67 "Error: NoTreatment1"
label var flag68 "Error: NoTreatment2"
label var flag69 "Error: LastName"
label var flag70 "Error: FirstName"
label var flag71 "Error: MiddleInitials"
label var flag72 "Error: BirthDate"
label var flag73 "Error: Sex"
label var flag74 "Error: NRN"
label var flag75 "Error: HospitalNumber"
label var flag76 "Error: ResidentStatus"
label var flag77 "Error: StatusLastContact"
label var flag78 "Error: DateLastContact"
label var flag79 "Error: DateOfDeath"
label var flag80 "Error: Comments"
label var flag81 "Error: PTDataAbstractor"
label var flag82 "Error: PTCasefindingDate"
label var flag83 "Error: RetrievalSource"
label var flag84 "Error: NotesSeen"
label var flag85 "Error: NotesSeenDate"
label var flag86 "Error: FurtherRetrievalSource"
label var flag87 "Error: RFAlcohol"
label var flag88 "Error: AlcoholAmount"
label var flag89 "Error: AlcoholFreq"
label var flag90 "Error: RFSmoking"
label var flag91 "Error: SmokingAmount"
label var flag92 "Error: SmokingFreq"
label var flag93 "Error: SmokingDuration"
label var flag94 "Error: SmokingDurationFreq"

forvalues j=95/189 {
	gen flag`j'=""
}
label var flag95 "Correction: STDataAbstractor"
label var flag96 "Correction: STSourceDate"
label var flag97 "Correction: NFType"
label var flag98 "Correction: SourceName"
label var flag99 "Correction: Doctor" //repeated below in error
label var flag100 "Correction: Doctor"
label var flag101 "Correction: DoctorAddress"
label var flag102 "Correction: RecordNumber"
label var flag103 "Correction: CFDiagnosis"
label var flag104 "Correction: LabNumber"
label var flag105 "Correction: SurgicalNumber"
label var flag106 "Correction: Specimen"
label var flag107 "Correction: SampleTakenDate"
label var flag108 "Correction: ReceivedDate"
label var flag109 "Correction: ReportDate"
label var flag110 "Correction: ClinicalDetails"
label var flag111 "Correction: CytologicalFindings"
label var flag112 "Correction: MicroscopicDescription"
label var flag113 "Correction: ConsultationReport"
label var flag114 "Correction: SurgicalFindings"
label var flag115 "Correction: SurgicalFindingsDate"
label var flag116 "Correction: PhysicalExam"
label var flag117 "Correction: PhysicalExamDate"
label var flag118 "Correction: ImagingResults"
label var flag119 "Correction: ImagingResultsDate"
label var flag120 "Correction: CausesOfDeath"
label var flag121 "Correction: DurationOfIllness"
label var flag122 "Correction: OnsetDeathInterval"
label var flag123 "Correction: Certifier"
label var flag124 "Correction: AdmissionDate"
label var flag125 "Correction: DateFirstConsultation"
label var flag126 "Correction: RTRegDate"
label var flag127 "Correction: Recordstatus"
label var flag128 "Correction: TTDataAbstractor"
label var flag129 "Correction: TTAbstractionDate"
label var flag130 "Correction: DuplicateCheck"
label var flag131 "Correction: Parish"
label var flag132 "Correction: Address"
label var flag133 "Correction: Age"
label var flag134 "Correction: PrimarySite"
label var flag135 "Correction: Topography"
label var flag136 "Correction: Histology"
label var flag137 "Correction: Morphology"
label var flag138 "Correction: Laterality"
label var flag139 "Correction: Behaviour"
label var flag140 "Correction: Grade"
label var flag141 "Correction: BasisOfDiagnosis"
label var flag142 "Correction: TNMCatStage"
label var flag143 "Correction: TNMAntStage"
label var flag144 "Correction: EssTNMCatStage"
label var flag145 "Correction: EssTNMAntStage"
label var flag146 "Correction: SummaryStaging"
label var flag147 "Correction: IncidenceDate"
label var flag148 "Correction: DiagnosisYear"
label var flag149 "Correction: Consultant"
label var flag150 "Correction: Treatment1"
label var flag151 "Correction: Treatment1Date"
label var flag152 "Correction: Treatment2"
label var flag153 "Correction: Treatment2Date"
label var flag154 "Correction: Treatment3"
label var flag155 "Correction: Treatment3Date"
label var flag156 "Correction: Treatment4"
label var flag157 "Correction: Treatment4Date"
label var flag158 "Correction: Treatment5"
label var flag159 "Correction: Treatment5Date"
label var flag160 "Correction: OtherTreatment1"
label var flag161 "Correction: OtherTreatment2"
label var flag162 "Correction: NoTreatment1"
label var flag163 "Correction: NoTreatment2"
label var flag164 "Correction: LastName"
label var flag165 "Correction: FirstName"
label var flag166 "Correction: MiddleInitials"
label var flag167 "Correction: BirthDate"
label var flag168 "Correction: Sex"
label var flag169 "Correction: NRN"
label var flag170 "Correction: HospitalNumber"
label var flag171 "Correction: ResidentStatus"
label var flag172 "Correction: StatusLastContact"
label var flag173 "Correction: DateLastContact"
label var flag174 "Correction: DateOfDeath"
label var flag175 "Correction: Comments"
label var flag176 "Correction: PTDataAbstractor"
label var flag177 "Correction: PTCasefindingDate"
label var flag178 "Correction: RetrievalSource"
label var flag179 "Correction: NotesSeen"
label var flag180 "Correction: NotesSeenDate"
label var flag181 "Correction: FurtherRetrievalSource"
label var flag182 "Correction: RFAlcohol"
label var flag183 "Correction: AlcoholAmount"
label var flag184 "Correction: AlcoholFreq"
label var flag185 "Correction: RFSmoking"
label var flag186 "Correction: SmokingAmount"
label var flag187 "Correction: SmokingFreq"
label var flag188 "Correction: SmokingDuration"
label var flag189 "Correction: SmokingDurationFreq"


** Create variable to populate the Flag Description field in the Reviewing form of the REDCap db
gen sd_flagdes = flag:label