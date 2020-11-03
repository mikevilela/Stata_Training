//////////////////////////////////////////////////////////////////////
// Análise e Tratamento de Dados									//	
// Construção e Gestão de Base de Dados								//
// Universidade do Minho											//
//////////////////////////////////////////////////////////////////////

global st = "$S_TIME"						// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM


//SOME INFORMATION ABOUT MENUS


// # 1. MENU 'File'
// # 1.1 "Working directory..."
		capture cd "/Users/miguel/Dropbox/Universidade do Minho/Teaching/Mestrado/Unidades Curriculares/Análise de Dados/Stata/1. Importing"
		
		clear all
		set more off
		set rmsg on
		
//  CREATE A LOG FILE, 'Log'
	
		capture log close						// in the event a log is open, close it, otherwise move to the next line; avoids the error message in case no log is open
		log using read_data.txt, text replace
		
		
///////////////////////////////////////
// OPEN A STATA DATA FILE			//
/////////////////////////////////////



//   # 1. READ DATA FROM the WEB & SAVE IT IN AS A LOCAL FILE

		// Import data from an internet archive
			capture use http://www.stata-press.com/data/r12/apple.dta
			capture save apple, replace					// save the file in Stata data format
			
// you can complicate things a little

*local URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
*forvalues month = 1/12 {
*   forvalues day = 1/31 {
*      local month = string(`month', "%02.0f")
*      local day = string(`day', "%02.0f")
*      local year = "2020"
*     local today = "`month'-`day'-`year'"
*      local FileName = "`URL'`today'.csv"
*      clear
*      capture import delimited "`FileName'"
*capture confirm variable ïprovincestate
*     if _rc == 0 {
*         rename ïprovincestate provincestate
*         label variable provincestate "Province/State"
*      }
*      capture rename province_state provincestate
*      capture rename country_region countryregion
*      capture rename last_update lastupdate
*      capture rename lat latitude
*      capture rename long longitude
*      generate tempdate = "`today'"
*      capture save "`today'", replace
*   }
*}
*clear
*forvalues month = 1/12 {
*   forvalues day = 1/31 {
*      local month = string(`month', "%02.0f")
*      local day = string(`day', "%02.0f")
*      local year = "2020"
*      local today = "`month'-`day'-`year'"
*      capture append using "`today'"
*   }
*}
*generate date = date(tempdate, "MDY")
*format date %tdNN/DD/CCYY

// Keep SAFE

clear all   
			
	
		use http://www.stata-press.com/data/r13/abdata.dta, clear	
			capture save abdata, replace					// save the file in Stata data format
			
clear all			
			
// # 2. READING DATA FROM CSV (comma-separated values) FORMAT
//		EXPORT & IMPORT FILES FROM .CVS & EXCEL FILES		
			
			cd csv							// move down one folder
			
			
		// Read text data created by a spreadsheet; indicate that variables names
			// are in the first row of the data file
			insheet using pwt70_csv_data_file.csv, names clear
				describe
			

		keep isocode year pop xrat openc rgdpl rgdpwok

		save pwt71_short, replace

		// Export in xlsx format
			export excel using "pwt71_short.xlsx", firstrow(variables) replace

		// Import the xlsx file format
			import excel "pwt71_short.xlsx", sheet("Sheet1") firstrow case(lower) clear
			
			
///////////////////////////////////////
// EXPLORE THE DATA 				//
/////////////////////////////////////			

		// Load the Stata native binary format '.dta'
			use pwt71_short, clear
			
			
		describe			// Describe data in memory
		inspect pop			// Display simple summary of data's attributes
		ds					// Compactly list variable names
		summarize			// Summary statistics
		sum pop, detail		// Additional statistics 

		
clear all									// clear the memory at the end of the session to free resources
log close									// CLOSE THE LOG FILE

