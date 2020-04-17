/*===========================================================================
Puropose: Main .do that construct encovi database
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		7th April, 2020
Modification Date:  
Output:			

Note: 
=============================================================================*/
********************************************************************************

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   1
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath "C:\Users\wb563583\GitHub\VEN"
		}
	    if $lauta {
		global dopath "C:\Users\wb563365\GitHub\VEN"
		global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global rootpath "C:\Users\wb550905\GitHub\VEN"
		}

********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

// set path for dofiles
global merging "$dopath\data_management\management\1. merging"
global harmonization "$dopath\data_management\management\3. harmonization"
global povmeasure "$dopath\poverty_measurement\scripts"

/*==============================================================================
merging data
==============================================================================*/

// set path of data
global input "$datapath\data_management\input\latest"
global output "$datapath\data_management\output\merged"


//run merge
do "$merging/__main__merge.do"


/*==============================================================================
hh-individual database and imputation (CORREGIR)
==============================================================================*/

// // set path of data (CORREGIR)
// global input "$datapath\data_management\output\merged"
// global output "$datapath\data_management\output\harmonized"
//
// //generate harmonized dataset
// run "$harmonization\ENCOVI harmonization\VEN_ENCOVI_2019.do"
//
// // set path of data  (CORREGIR)
// global input "$datapath\data_management\output\harmonized"
// global output "$datapath\data_management\output\harmonized"

// // imputate incomes (CORREGIR)
//run "$harmonization\ENCOVI harmonization\????????"


/*==============================================================================
poverty estimation
==============================================================================*/

// set path of data
global encovifilename "ENCOVI_2019.dta"
global cleaned "$datapath\data_management\output\cleaned"
global merged "$datapath\data_management\output\merged"
global input "$datapath\poverty_measurement\input"
global output "$datapath\poverty_measurement\output"
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"


//run poverty estimation
do "$povmeasure/__main__.do"

/*==============================================================================
attach pov to harmonized data
==============================================================================*/

use x, replace
merge m:1 inter, keep(match)