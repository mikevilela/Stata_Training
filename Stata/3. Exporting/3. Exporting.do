//////////////////////////////////////////////////////////////////////
// Análise e Tratamento de Dados									//	
// Construção e Gestão de Base de Dados								//
// Universidade do Minho											//
//////////////////////////////////////////////////////////////////////

global st = "$S_TIME"						// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM

clear all									// CLEAR STATA'S MEMORY; START A NEW SESSION

capture cd "/Users/miguel/Dropbox/Universidade do Minho/Teaching/Mestrado/Unidades Curriculares/Análise de Dados/Stata/3. Exporting"	// MOVE TO YOUR WORKING FOLDER

set more off								// ALLOW SCREENS TO PASS BY
set rmsg on									// CONTROL THE TIME NEEDED TO RUN EACH COMMAND

capture log close							// CLOSE THE LOG IN CASE IT IS OPEN; OTHERWISE PROCEED
log using exporting.txt, text replace		// BUILD A LOG FILE FOR THE OUTPUT
***********************************************************************************************************
use "../2. Managing/growth_data.dta"


// ########################################################################### //


// # 1. GRAPHS

	// dot

		graph dot (mean) education if (country == "denmark" | country == "portugal" | /*
				*/ country == "united states" | country == "italy" | country == "spain"),over(country, sort((mean) lngdp))
		

	// whisker plots

		graph box education if year == 2000

		preserve
			keep if year == 1960 | year == 2000
			tab year
			graph box education, by(year)
		restore

		graph box lngdp if (country == "denmark" | country == "portugal" | /*
				*/ country == "united states" | country == "italy" | country == "spain"),over(country, label(alternate) sort(education))
		
		
		
		
	// scatter

		graph twoway scatter lngdp education
		twoway scatter lngdp education
		scatter lngdp education
		
		scatter lngdp education || lfit lngdp education
			set scheme economist
		scatter lngdp education || lfit lngdp education
			set scheme s2mono
		scatter lngdp education || lfit lngdp education
		
		scatter lngdp education || lfit lngdp education, scheme(sj)
		scatter lngdp education || lfit lngdp education, scheme(s2color)
		
		label var lngdp "Log GDP per worker"
		label var education "Education"
		
		scatter lngdp education if year == 1960 || lfit lngdp education if year == 1960, scheme(s1mono) xlabel(0(2)12) ylabel(6(1.5)12) /*
				*/ title(Income vs. Education: 1960) saving(inc_educ_60, replace)
		
		scatter lngdp education if year == 2000 || lfit lngdp education if year == 2000, scheme(s1mono) xlabel(0(2)12) ylabel(6(1.5)12) /*
				*/ title(Income vs. Education: 2000) saving(inc_educ_00, replace)
				
		graph combine inc_educ_60.gph inc_educ_00.gph, note(Source: Own computations.)
			graph export inc_educ.png, replace	// APPROPRIATE FOR WORD FILES; open the file 'inc_educ.wmf' with Windows Explorer
			graph export inc_educ.png, replace	// APPROPRIATE FOR LATEX FILES


	// histogram

		histogram education if year == 2000, normal
	
	
	// pie

		graph pie rgdpwok if (country == "denmark" | country == "portugal" | country == "united states") & year == 2000, /*
			*/ scheme(s2color) over(country) title(Income share among countries) /*
					*/ plabel(1 percent, size(*1.5) color(white) format(%3.1f)) /*
					*/ plabel(2 percent, size(*1.5) color(white) format(%3.1f)) /*
					*/ plabel(3 percent, size(*1.5) color(white) format(%3.1f)) /*
					*/ legend(on) plotregion(lstyle(none))/*
					*/ note("Source: Own computations.")
					
			graph export pie_1.png, replace

		graph pie rgdpwok if (country == "denmark" | country == "portugal" | country == "united states") & year == 2000, /*
			*/ scheme(s2color) over(country) title(Income share among countries) /*
					*/ plabel(1 name, size(*1.5) color(white)) /*
					*/ plabel(2 name, size(*1.5) color(white)) /*
					*/ plabel(3 name, size(*1.5) color(white)) /*
					*/ legend(off) plotregion(lstyle(none))/*
					*/ note("Source: Own computations.")
			
			graph export pie_2.png, replace

		label var year "Year"
		sum education if country == "united states" & year == 2000
			local yy_us = r(mean) - 1
		sum education if country == "portugal" & year == 2000
			local yy_pt = r(mean) - 1

log close
