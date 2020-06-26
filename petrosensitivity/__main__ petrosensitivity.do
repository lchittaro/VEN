/*===========================================================================
Puropose: Main .do that construct encovi database
===========================================================================
Country name:	Venezuela
Year:			2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Malena Acuña

Dependencies:		The World Bank
Creation Date:		17th April, 2020
Modification Date:  
Output:			

Note: 
=============================================================================*/
********************************************************************************
clear all

// Define rootpath according to user

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta  1
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global dopath "C:\Users\wb563583\GitHub\VEN"
				global datapath 	"C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
		}
	    if $lauta {
				global dopath "C:\Users\wb563365\GitHub\VEN"
				global datapath "C:\Users\wb563365\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
				global outSEDLAC "C:\Users\wb563365\GitHub\VEN\petrosensitivity\"
				global outENCOVI "C:\Users\wb563365\GitHub\VEN\petrosensitivity\"
		}
		if $trini   {
				global rootpath "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela\VEN"
		}
		if $male   {
				global dopath "C:\Users\wb550905\Github\VEN"
				global datapath "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\"
				global outSEDLAC "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_SEDLAC_DATA_2014_2019\"
				global outENCOVI "C:\Users\wb550905\WBG\Christian Camilo Gomez Canon - ENCOVI\FINAL_ENCOVI_DATA_2019_COMPARABLE_2014-2018\"
		}		
********************************************************************************



/*==============================================================================
Program set up
==============================================================================*/
version 14
drop _all
set more off

//set universal datapaths
global merged "$datapath\data_management\output\merged"
global cleaned "$datapath\data_management\output\cleaned"
global forinflation "$datapath\data_management\output\for inflation"
global impdos "$dopath\data_management\management\4. income imputation\dofiles"

//set universal dopaths
global harmonization "$dopath\data_management\management\2. harmonization"
global inflado "$dopath\data_management\management\5. inflation"
global pathaux "$harmonization\aux_do"

//exchange rate input
global exrate "$datapath\data_management\input\exchenge_rate_price.dta"


/*==============================================================================
petro sensitivity
==============================================================================*/
global petro_parameter_wage 1 4 6 12
global petro_parameter_other 1 4 6 12
putexcel set "$outENCOVI/petrosensi_24may20.xlsx", replace
global i = 1
include "$pathaux\cuantiles.do"

foreach ipetro in $petro_parameter_wage{
foreach jpetro in $petro_parameter_other{
qui{
global ipetro = `ipetro'
global jpetro = `jpetro'
/*==============================================================================
 merging data
 ==============================================================================*/

*set path of data
global merging "$dopath\data_management\management\1. merging"
global input "$datapath\data_management\input\latest"

* run merge
run "$merging\__main__merge.do"

/*==============================================================================
Inflation
==============================================================================*/

// specific path to inflation estimation

global povinput "$datapath\poverty_measurement\input"
global inflationout "$datapath\data_management\input"


// calculates inflation
run "$inflado/__main__inflation.do"

// set global inflation input
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta"

/*==============================================================================
hh-individual database
==============================================================================*/

//run ENCOVI harmonization
run "$harmonization\ENCOVI harmonization\VEN_ENCOVI_2019.do"

/*==============================================================================
imputation
==============================================================================*/
include "$pathaux\cuantiles.do"
*Specific for imputation
global impdos "$dopath\data_management\management\4. income imputation\dofiles"
global forimp "$datapath\data_management\output\for imputation"
global pathoutexcel "$datapath\data_management\output\post imputation"
global numberofimpruns 2

//run ENCOVI imputation
run "$impdos\MASTER 1-5. Run all imputation do's 2019.do"

/*==============================================================================
poverty estimation
==============================================================================*/
// set global inflation input
global inflation "$datapath\data_management\input\inflacion_canasta_alimentos_diaria_precios_implicitos.dta" // Ya estaba arriba también
// set path of data
global povmeasure "$dopath\poverty_measurement\scripts"
global input "$datapath\poverty_measurement\input"
global output "$datapath\poverty_measurement\output"

//run poverty estimation
run "$povmeasure\__main__pobreza.do"

/*==============================================================================
creating separate dataset for variables to merge with SEDLAC version
==============================================================================*/

global output "$datapath\poverty_measurement\output"
use "$output\ENCOVI_2019_postpobreza.dta", replace

	keep interview__key interview__id com miembro__id ///
	pobre pobre_extremo lp_moderada lp_extrema ///
	iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_m ///
	ijubi_nm icap_m icap_nm cct itrane_o_m itrane_o_nm itrane_ns ///
	rem itranp_o_m itranp_o_nm itranp_ns inla_otro ipatrp ///
	iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ///
	ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ///
	ila ila_m ilaho ilaho_m perila ijubi icap ///
	itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ///
	ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m ///
	itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m ///
	inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee ///
	pipcf dipcf piea qiea ipc ipc11 ppp11 ipcf_cpi11 ipcf_ppp11 

save "$pathaux\Variables to merge with SEDLAC.dta", replace

/*==============================================================================
final variable selection
==============================================================================*/

global output "$datapath\poverty_measurement\output"

//run cleaning of variables
run "$dopath\data_management\management\3. cleaning\final_variable_selection.do"
/*==============================================================================
labeling and saving final full databases
==============================================================================*/

//run spanish labeling
run "$pathaux\labels ENCOVI spanish.do"


putexcel set "$outENCOVI/petrosensi_24may20.xlsx", modify
putexcel A$i = ("wageparam")
putexcel B$i = (`ipetro')
putexcel C$i = ("otherparam")
putexcel D$i = (`jpetro')
}
di "$ipetro"
di "$jpetro"

tabstat pobre pobre_extremo [w=pondera], s(mean) save
global ii = ($i + 2)
matrix define result = matrix(r(StatTotal))
putexcel A$ii = matrix(result)
global j = ($ii + rowsof(result) + 1)

local orshansky_result = lp_moderada[1]/lp_extrema[1]
di `orshansky_result'
putexcel A$j = ("orshansky")
putexcel B$j = (`orshansky_result')


global i = $j + 3

}
}
