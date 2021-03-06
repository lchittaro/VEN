/*===========================================================================
Puropose: value basket over time
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ECOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro

Dependencies:		The World Bank
Creation Date:		25th Mar, 2020
Modification Date:  

Note: 
=============================================================================*/
********************************************************************************


// Define rootpath according to user

// 	    * User 1: Trini
// 		global trini 0
//		
// 		* User 2: Julieta
// 		global juli   0
//		
// 		* User 3: Lautaro
// 		global lauta   1
//		
// 		* User 4: Malena
// 		global male   0
//			
// 		if $juli {
// 				global rootpath "C:\Users\wb563583\GitHub\VEN"
// 		}
// 	    if $lauta {
// 		global dopath "C:\Users\wb563365\GitHub\VEN"
// 		global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
// 		}
// 		if $trini   {
// 				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
// 		}
// 		if $male   {
// 				global rootpath "C:\Users\wb550905\GitHub\VEN"
// 		}
// *
// ********************************************************************************
//
// /*==============================================================================
// 0: Program set up
// ==============================================================================*/
// version 14
// drop _all
// set more off
//
//
// // set path of data
// global encovifilename "ENCOVI_2019.dta"
// global cleaned "$datapath\data_management\output\cleaned"
// global merged "$datapath\data_management\output\merged"
// global input "$datapath\poverty_measurement\input"
// global output "$datapath\poverty_measurement\output"
// global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"
// global exrate "$datapath\data_management\input\exchenge_rate_price.dta"

********************************************************************************

/*==============================================================================
0: start
==============================================================================*/


// import prices
use "$output/precios_implicitos_nov_to_march.dta", replace
merge m:1 bien using "$output/canasta_diaria.dta"
drop _merge

// generate value of each products
gen valor_canasta = pimp * cantidad_ajustada

//collapse by month to make the series and the index
collapse (sum) valor_canasta, by(month)

tsset month
gen indice = 100* valor_canasta/valor_canasta[4]


//adds observation using another index to complete up to october
gsort -indice
set obs `=_N+1'
replace month = 10 if _n==_N
local last=indice[_N-1]
di `last'
replace indice = `last'* 1600000000/2100000000 if _n==_N //complete to october using inflation of asamblea nacional
rename month mes
gen ano = 2019 if mes >9
replace ano = 2020 if mes <5

save "$inflation", replace
export excel "$output/serie_inflacion_canasta.xlsx", firstrow(variables) replace
