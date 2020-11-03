//////////////////////////////////////////////////////////////////////
// Análise e Tratamento de Dados									//	
// Construção e Gestão de Base de Dados								//
// Universidade do Minho											//
//////////////////////////////////////////////////////////////////////

global st = "$S_TIME"						// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM

clear all									// CLEAR STATA'S MEMORY; START A NEW SESSION

capture cd "/Users/miguel/Dropbox/Universidade do Minho/Teaching/Mestrado/Unidades Curriculares/Análise de Dados/Stata/4. Example/log"	// MOVE TO YOUR WORKING FOLDER

set more off								// ALLOW SCREENS TO PASS BY
set rmsg on									// CONTROL THE TIME NEEDED TO RUN EACH COMMAND

capture log close							// CLOSE THE LOG IN CASE IT IS OPEN; OTHERWISE PROCEED
log using example.txt, text replace		// BUILD A LOG FILE FOR THE OUTPUT
***********************************************************************************************************

// # 1. Import Data

import excel "../data/Labour.xlsx", sheet("Folha1") firstrow //Load the first data

**Manage Variable

	label var Concelho      "Local Government"

	label var Pop_2015  	"Population 2015"
	label var Pop_2016		"Population 2016"
	label var Pop_2017		"Population 2017"


	label var Pessoal_Constr_2015   "Jobs in Construction 2015"
	label var Pessoal_Constr_2016   "Jobs in Construction 2016"
	label var Pessoal_Constr_2017 	"Jobs in Construction 2017"
	
	label var pop_empregada_2015 	"Jobs Market 2015"
	label var pop_empregada_2016	"Jobs Market 2016"
	label var pop_empregada_2017	"Jobs Market 2017"
	
save "../data/data_01.dta", replace

clear all

/////////////

import excel "../data/Local Finance.xlsx", sheet("Folha1") firstrow //Load the first data


**Manage Variable

	label var Concelho      "Local Government"

	
	label var receita_Capital_2015 		"Capital Income 2015"
	label var receita_Capital_2016 		"Capital Income 2016"
	label var receita_Capital_2017 		"Capital Income 2017"
	
	label var Receita_Corrente_2015		"Current Income 2015" 
	label var Receita_Corrente_2016		"Current Income 2016"  
	label var Receita_Corrente_2017		"Current Income 2017"  
	
	label var Imposto_Diretos_2015		"Direct Taxes 2015"  
	label var Imposto_Diretos_2016		"Direct Taxes 2016"  
	label var Imposto_Diretos_2017		"Direct Taxes 2017" 
	

rename Q IMT_2017	
	
save "../data/data_02.dta", replace

clear all

/////////////

import excel "../data/variables.xlsx", sheet("Folha1") firstrow //Load the first data


**Manage Variable

	label var Concelho      "Local Government"

	
	label var Ind_Desenvolvimento_2015 		"Development 2015"
	label var Ind_Desenvolvimento_2016 		"Development 2016"
	label var Ind_Desenvolvimento_2017 		"Development 2017"
	
	
//Eliminate Duplicates

	duplicates list
	duplicates drop

	
save "../data/data_03.dta", replace

clear all



// # 2. Merge Data


use "../data/data_01.dta"

	merge 1:1 code using  "../data/data_02.dta"
			drop _merge
			
	merge 1:1 code using  "../data/data_03.dta"	
			drop _merge
	
//Converte variables to numeric

 destring Pessoal_Constr_2015 Pessoal_Constr_2016 Pessoal_Constr_2017, replace force dpcomma
 
 
 // identify missings in all variables

	egen nmiss = rowmiss(_all)	
					des
					tab nmiss
						drop nmiss
						
						
save "../data/data_total.dta", replace



// # 3. Transforme Database


		 reshape long Pop_ Pessoal_Constr_ pop_empregada_ ///
		receita_Capital_  Receita_Corrente_ ///
		  Imposto_Diretos_  IMI_ ///
		  IMT_ Ind_Desenvolvimento_, i (Concelho) j (Ano)
		 
// # 4. Create a relative weight 


			local llist IMI_ IMT_
			
			foreach cc of local llist {
				gen r`cc' = `cc'/(Receita_Corrente_+receita_Capital_)
				
			}

				preserve
					collapse (mean) rIMI_ rIMT_, by (Ano)
					twoway (line rIMI_ rIMT_ Ano)
					graph save test.png, replace 
				restore

// # 5. Generate Variables and declare a database
