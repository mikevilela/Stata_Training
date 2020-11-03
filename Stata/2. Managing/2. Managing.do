//////////////////////////////////////////////////////////////////////
// Análise e Tratamento de Dados									//	
// Construção e Gestão de Base de Dados								//
// Universidade do Minho											//
//////////////////////////////////////////////////////////////////////

global st = "$S_TIME"						// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM

clear all									// CLEAR STATA'S MEMORY; START A NEW SESSION

capture cd "/Users/miguel/Dropbox/Universidade do Minho/Teaching/Mestrado/Unidades Curriculares/Análise de Dados/Stata/2. Managing"	// MOVE TO YOUR WORKING FOLDER

set more off								// ALLOW SCREENS TO PASS BY
set rmsg on									// CONTROL THE TIME NEEDED TO RUN EACH COMMAND

capture log close							// CLOSE THE LOG IN CASE IT IS OPEN; OTHERWISE PROCEED
log using managing.txt, text replace		// BUILD A LOG FILE FOR THE OUTPUT
***********************************************************************************************************



///////////////////////////////
// Import data////////////////
/////////////////////////////
import excel "../1. Importing/csv/pwt70.xls", sheet("Sheet1") firstrow case(lower) clear


// ########################################################################### //



// # 1. MANAGE VARIABLES

	// LABEL VARIABLES: use the information in the file pwt70_excel_variables.xls
					label var country		"Country name"
					label var year			"Year of observation"
					label var isocode		"Country code"
					label var pop			"Population (in thousands)"

				// Exchange Rates and PPPs over GDP
					label var xrat			"Exchange Rate to US$; national currency units per US dollar"
					label var ppp			"Purchasing Power Parity over GDP (in national currency units per US$)"  	

				//	Constant Price GDP Per Capita and Expenditure Shares
					label var rgdpl			"PPP Converted GDP Per Capita (Laspeyres), derived from growth rates of c, g, i, at 2005 constant prices"
					label var kc			"Consumption Share of PPP Converted GDP Per Capita at 2005 constant prices [rgdpl]"
					label var kg			"Government Consumption Share of PPP Converted GDP Per Capita at 2005 constant prices [rgdpl]"
					label var ki			"Investment Share of PPP Converted GDP Per Capita at 2005 constant prices [rgdpl]"
					label var openk			"Openness at 2005 constant prices (%)"
					label var rgdpwok		"PPP Converted GDP Chain per worker at 2005 constant prices"

				lookfor GDP							// LOOK FOR THE STRING 'gdp' IN VARIABLE NAMES or LABELS
				
				order country year					// order the sequence of variables as you see them, for example, in 'browse'
				keep country year isocode pop xrat ppp rgdpl kc kg ki openk rgdpwok	// keep a specific list of variables
				
				replace country = lower(country)	// small caps for country names
				tab country
					
				// correct a data issue for China & KEEP JUST ONE VERSION OF THE DATA FOR CHINA
					drop if country == "china version 1"
						replace country = "china" if country == "china version 2"

				
				// the country names have to be harmonized with the following data on education
				replace country = "antigua and barbuda"	if country == "antigua & barb."
				replace country = "central african republic"	if country == "central afr. r."
				// (...)	- include here the remaining replacements
				
				replace country = lower(country) 									// SET small caps for country names
					tab country
					tab year
				
				sort country year
				save pwt70, replace			// the file can be saved in a previous Stata format using 'saveold'
				
				describe

			clear all



// ########################################################################### //



// # 2. COMBINE INFORMATION FROM DIFFERENT SOURCES == command 'merge'



			// CROSS Penn World Table WITH BARRO & LEE DATA
			// Source:	http://www.cid.harvard.edu/ciddata/ciddata.html

			cd barro_lee

			// assignment: 	1. build an excel file with data on education by country and year
			//				2. transport the data to Stata
			//				3. combine the information with PWT used above
			import excel "barro_lee_aeduc.xlsx", sheet("education") firstrow case(lower) clear
				cf2 _all using barro_lee_aeduc, verbose 							// 'cf2': compare with the file in stata format

			use barro_lee_aeduc, clear												// READ A FILE ALREADY IN STATA FORMAT
				drop if year == .
			
			// BROWSE THE DATA USING THE COMMAND 'browse'
			// IDENTIFY THE CORRECTIONS TO BE MADE; COMPARE YOUR ANALYSIS WITH THE FOLLOWING COMMANDS
			
			replace country = country[_n+1] if year <= 1955 & country == ""
			replace country = country[_n+1] if year <= 1955 & country == "" 		// check for data on 'Philippines'
			replace country = country[_n-1] if country == "" & _n > 1

				tab country
				replace country = lower(country)
					tab country
					tab year
					
				order country year
				sort country year
				
				describe
				codebook, compact
				
				// since education is defined as string, we will transform it in a number
				destring education, force replace

					save data_educ, replace
 
			cd ..
			
			
			///// MERGE THE TWO DATASETS /////
			
			// read income data in order to combine it with the education data

			use pwt70.dta, clear

				// the key used to link the two data sets is defined by the variables country & year
				// within the pair country & year there is a unique observation
				// at this stage the data in memory is the one saved in the line 'save pwt70, replace'

				// '1:1' means that 1 row in the data in memory will be combined with 1 row in the data saved in the harddrive
				
				merge 1:1 country year using barro_lee/data_educ	// the merge is made on country & year

				tab country if _merge == 3				// identify the names of countries that are in both data sets
					ret li
				tab country if _merge == 1				// identify the names of countries that are just in the data in memory
				tab country if _merge == 2				// identify the names of countries that are just in the data in the harddrive
				
				
				
				// as we want to implement an analysis that will make use of both income & education data
				// we will only keep the observations identified in both data sets, '_merge == 3'
				
				keep if _merge == 3
					drop _merge				// we do not need this variable any longer
				
				drop if year < 1960
				sort country year
				
				describe
				codebook, compact
				compress					// optimize the storage of the data

			save tmp, replace
			

// ########################################################################### //


// # 3. RESHAPING THE DATA: use data from a 3rd source


	cd capital

			// Source:	http://www.cid.harvard.edu/ciddata/ciddata.html

			// DOWNLOAD THE DATA IN EXCEL FORMAT; IMPORT IT TO STATA AND SAVE THE FILE 'cap_inv.dta'

				import excel cap_inv.xls, sheet("CAP_INV") clear

			// explore the data with the command 'browse'
			
			// RENAME VARIABLE NAMES WITH YEARS, command 'rename'


			rename (E-AW) (k#), addnumber(1948)			// rename a group of variables
			
				keep if regexm(D,"Total Capital") 		// under variable 'D' keep only the lines that include the string 'Total Capital'
				ren B country
				keep country k1948-k1992
				replace country = lower(country)

			///// USE OF RESHAPE /////

				reshape long k, i(country) j(year) 		// to include more variables you have to do it separately
				destring k, force replace
				drop if k == .
				
				format %16.3f k
				list k in 1/10
				
				label var k "Capital"
				
				codebook, compact
				
				order country year
				
				sort country year
				save capital_data, replace

		cd ..
		
// # 4. JOIN CAPITAL TO GDP & EDUCATION; tmp.dta file defined above


		use tmp, clear											// use the data file built above: gdp + education
			merge 1:1 country year using capital/capital_data
			drop if _merge == 2		// since we can make some of the analysis just with gdp & education, we only need to drop those observations just avaulable in the 'using' data
			drop _merge
			
			des
			codebook, compact
			tab year
			inspect isocode
			ds					// list the name of the variables available in the data
			
			// create variables
			
			generate lngdp = ln(rgdpwok)
				label var lngdp "Log Real GDP per Worker"
			gen lnk = ln(k)
				label var lnk "Log Capital"
			
					
					egen nmiss = rowmiss(_all)	// identify missings in all variables
					des
					tab nmiss
						drop nmiss

					sort country year
					save growth_data, replace

// # 5. OTHER COMMANDS
					
//preserve the data in memory and build a separate data with means by country
			preserve
				collapse (mean) education rgdpwok, by(country)	// collapse the data with the mean of education & gdp within countries
				save data_overall.dta, replace
				codebook, compact
			restore

// loops		
						tab country
			
			local llist = "portugal spain france"
			
			foreach cc of local llist {
				display _new _new "COUNTRY:	`cc'"
				preserve
					keep if country == "`cc'"
					tab country
					sum
					reg lngdp education
				restore
			}


elapse $st											// TIME IT TOOK TO RUN THE FULL PROGRAM

log close

			
			
