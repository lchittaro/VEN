/*===========================================================================
Detected and corrected missinputed data
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Malena Acuña

Dependencies:		The World Bank
Creation Date:		22th April, 2020
Modification Date:  
Output:			products.dta

Note: 
=============================================================================*/
********************************************************************************
/*
// Define rootpath according to user (silenced as this is done by main now)

 	    * User 1: Trini
 		global trini 0
		
 		* User 2: Julieta
 		global juli   0
		
 		* User 3: Lautaro
 		global lauta   0
		
 		* User 4: Malena
 		global male   1
			
 		if $juli {
 				global dopath "C:\Users\wb563583\GitHub\VEN"
 				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
 		}
 	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
 		if $trini   {
 				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
 		}
 		if $male   {
 				global dopath "C:\Users\wb550905\Github\VEN"
 				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	
		global output "$datapath\data_management\output\merged" // although here it is input
*/

********************************************************************************

/*==============================================================================
Program set up
==============================================================================*/

version 14
drop _all
set more off

use "$merged/individual.dta"

/*==============================================================================
Domestic service
==============================================================================*/

// domestic service reported: 5 years, shares last name with hh jefe & esposa, no income. Replaced for son/daughter

replace s6q2=3 if s6q2 == 13 & interview__key == "27-27-71-43" 

// domestic service reported: 50 years with hh jefa of 46 years. He has same income as hh jefa. Sector retail, housing, general services etc. the couple shares last name. Replaced for husband. No other at this home.

replace s6q2=2 if s6q2 == 13 & interview__key == "19-22-71-57"

// Domestic service reported: 15 years, male, same last name as the family. Student. Replaced for nephew.

replace s6q2=5 if s6q2 == 13 & interview__key == "16-09-80-35"

/*==============================================================================
Total missing observation 
==============================================================================*/

*Only one household has no head: it is a 1-person home
*replace s6q2=1 if interview__id=="41c2e46694f245bd8face23c459ae18e" & interview__key=="16-35-68-66"

*Actually, it was the only one that should have not passed the HQ filter but did
drop if interview__key=="16-35-68-66"

/*==============================================================================
replace data
==============================================================================*/

save "$merged/individual.dta", replace

/*==============================================================================
Program set up 2
==============================================================================*/

use "$merged/household.dta"

/*==============================================================================
Total missing observation 
==============================================================================*/

*Only one that should have not passed the HQ filter but did)
drop if interview__key=="16-35-68-66"

/*==============================================================================
replace data
==============================================================================*/

save "$merged/household.dta", replace
