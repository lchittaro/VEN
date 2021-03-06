/*===========================================================================
Purpose: import exchange rate data a

Country name:	Venezuela
Year:			2014
Project:	
---------------------------------------------------------------------------
Authors:			Lautaro Chittaro, Julieta Ladronis, Trinidad Saavedra

Dependencies:		The World Bank -- Poverty Unit
Creation Date:		February, 2020
Modification Date:  
Output:			    Exchange rates dataset

Note: 
=============================================================================*/
********************************************************************************
	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   1
		
		* User 3: Lautaro
		global lauta   0
		
		* User 4: Malena
		global male   0
			
			
		if $juli {
				global rootpath "C:\Users\wb563583\VEN\data_management\management\1. merging\exchange rates" 
				global dataout "$rootpath\"
				
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
				global dataout "$rootpath\"
		}
		if $trini   {
				global rootpath ""
				global dataout "$rootpath\"
		}
		
		if $male   {
				global rootpath "C:\Users\wb550905\Github\VEN\data_management\management\1. merging\exchange rates"
				global dataout "$rootpath\"
		}
		
*********************************************************************************
*--- Import official data of exchange rates
*--- Source: 
*********************************************************************************

*--------------- 4T 2019		
*--------------- Set the dates of the exchange rate as a local 
* These are the names of the excel spreadsheet which contain daily data for each trimester	
	local fechas_T1 30122019 27122019 26122019 23122019	20122019 19122019 ///
	18122019 17122019 16122019 13122019 12122019 11122019 10122019 09122019 ///
	06122019 05122019 04122019 03122019 02122019 29112019 28112019 27112019 26112019 ///
	25112019 22112019 21112019 20112019 19112019 18112019 15112019 14112019 ///
	13112019 12112019 11112019 08112019 07112019 06112019 05112019 01112019
	
	foreach k of local fechas_T1 {
			  cap import excel using "$rootpath\2_1_2d19.xls", sheet(`k') cellrange(B9:G47) firstrow clear
		gen date="`k'"
		if `k'==30122019 {
		tempfile exch1
		save `exch1'
		}
		else {
			replace date="`k'"
			append using `exch1'
			save `exch1', replace
		}
	}


// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
	keep if Compra!=. 
	//Generate a code for each currency
	encode COD_moneda, gen(COD_moneda_e)

// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

	// Save as temporal file
	save `exch1', replace
	clear
	
*********************************************************************************
*--- Import official data of exchange rates
*--- Source: 
*********************************************************************************

*--------------- 1T 2020	
*--------------- Set the dates of the exchange rate as a local 
* These are the names of the excel spreadsheet which contain daily data for each trimester
	local fechas_T4 31032020 30032020 27032020 26032020 25032020 24032020 23032020 20032020 18032020 17032020 16032020 13032020 12032020 11032020 10032020 09032020 06032020 05032020 04032020 03032020 02032020 28022020 27022020 26022020 21022020 20022020 19022020	18022020 17022020 14022020 ///
	13022020 12022020 11022020 10022020 07022020 06022020 05022020 04022020 03022020 31012020 ///
	30012020 29012020 28012020 27012020	24012020 23012020 22012020 21012020	17012020 ///
	16012020 15012020 14012020 13012020 10012020 09012020 08012020 07012020 03012020 02012020	
foreach i of local fechas_T4 {
          cap import excel using "$rootpath\2_1_2a20.xls", sheet(`i') cellrange(B9:G47) firstrow clear	  
	gen date="`i'"
	if `i'==31032020 {
	tempfile exch2
	save `exch2'
	}
	else {
	    replace date="`i'"
		append using `exch2'
		save `exch2', replace
		}
}

// Format
	rename (B) (COD_moneda)
	label var COD_moneda Moneda
	rename (MonedaPaís) (Pais)
	rename VentaASKb Venta
	rename (F) (Compra)

// Keep useful observations
keep if Compra!=. 
//Generate a code for each currency
encode COD_moneda, gen(COD_moneda_e)

	// Replace errors with a code and destring
	foreach var of varlist Venta VentaASK {
	replace `var'="." if `var'=="----------------"
	destring `var', replace
	}

// To generate date in a format which allow to merge with price data: YYYY-MM-DD
     //Generate Year
	 gen year=substr(date,5,4)
	 //Generate Month 
	 gen month=substr(date,3,2)
	 //Generate Day
	 gen day=substr(date,1,2)
// Link the three variables to generate the variable of date  
	egen date_price=concat(year month day),  punct(-)
	//Drop the variable used as imput for date
	drop date

	// Save as temporal file
	save `exch2', replace
	clear
	
********************************************************************************
*---  Append both databases
********************************************************************************
append using `exch1' 

*********************************************************************************
*--- To select the currency units included in the survey
*********************************************************************************
// Pesos Colombianos: 11 COP 
// Euros 17 EUR
// Venezuela 29 PTR
// Dolar 35 USD

	keep if COD_moneda_e==11 | COD_moneda_e==17 | COD_moneda_e==29 | COD_moneda_e==35
	
	// Transform codes according to survey codes for currency
	// Pesos Colombianos: 11 COP ---> 4
	// Euros              17 EUR ---> 3
	// Venezuela          29 PTR ---> 
	// Dolar              35 USD ---> 2

	//replace COD_moneda_e=4 if COD_moneda_e==11 // Pesos colombianos
	//replace COD_moneda_e=3 if COD_moneda_e==17 // Euros
	//replace COD_moneda_e=2 if COD_moneda_e==35 // Dolar

	//rename COD_moneda_e moneda 
*********************************************************************************
*--- Save exchange rates dataset
*********************************************************************************
	 
	save "$rootpath\exchenge_rate_sum", replace

*********************************************************************************
*--- Generate dataset to merge with prices
*********************************************************************************

    // Keep only relevant data
	collapse (mean) mean_moneda=Venta (median) median_moneda=Venta, by (month COD_moneda)
	gen moneda=.
	replace moneda=2 if COD_moneda=="USD"
	replace moneda=3 if COD_moneda=="EUR"
	replace moneda=4 if COD_moneda=="COP"
	keep if moneda!=.
	rename month mes
	
*********************************************************************************
*--- Save exchange rates dataset to merge with prices
*********************************************************************************
	
	save "$rootpath\exchenge_rate_price", replace
