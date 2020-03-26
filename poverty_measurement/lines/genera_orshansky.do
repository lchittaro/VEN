/*===========================================================================
Puropose: This script takes spending in food and compares it with spending
in non food goods to calculate orshansky indexes over population of reference
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

	    * User 1: Trini
		global trini 0
		
		* User 2: Julieta
		global juli   0
		
		* User 3: Lautaro
		global lauta   0
		
		* User 3: Lautaro
		global lauta2   1
		
		
		* User 4: Malena
		global male   0
			
		if $juli {
				global rootpath ""
		}
	    if $lauta {
				global rootpath "C:\Users\lauta\Documents\GitHub\ENCOVI-2019"
		}
	    if $lauta2 {
				global rootpath "C:\Users\wb563365\GitHub\VEN"
		}

// set raw data path
global mergeddata "$rootpath\data_management\output\merged" //REPLACE ALL WITH CLEANED DATA
global cleaneddata "$rootpath\data_management\output\cleaned"

global output "$rootpath\poverty_measurement\input"
*
********************************************************************************

/*==============================================================================
0: Program set up
==============================================================================*/
version 14
drop _all
set more off




/*(************************************************************************************************************************************************* 
* 1: sets population of reference
*************************************************************************************************************************************************)*/

// merges with income data
use "$mergeddata/base_out_nesstar_cedlas_2019.dta", replace
keep if interview_month==2
rename region_est2 entidad
collapse (max)ipcf_max=ipcf (max) miembros (max) entidad, by (interview__key interview__id quest)

rename ipcf_max ipcf


// keeps quantiles in poverty prior surrounding
xtile quant = ipcf, nquantiles(100)
global pprior = 50
keep if inrange(quant, $pprior -15, $pprior +15)

tempfile reference
save `reference'


/*(************************************************************************************************************************************************* 
* 1: collect data of spending in feb2020
*************************************************************************************************************************************************)*/

// there are two data sources of spending. 1) Household-individual section of survey and 2) Consumption section. Also, there are two types of spending: a) food b) non-food. So we aggregate each type of consumption in each section of the survey

// Household-individual section
//COMPLETE

// Consumption section
// import feb2020 product data
use "$mergeddata/product-hh.dta", replace
merge m:1 interview__id interview__key quest using `reference'
keep if _merge ==3
drop _merge

// problems and solutions: a) homogenize currencies, b) correct date of survey with date of purchase, c) define frequency of purchases d) define current goods e) define types of goods


// a) define good type
gen type_good = .
label define type_good 1 "food" 2 "alcohol&smoke" 3 "bath&cleaning" 4 "clothes" 5 "durables" 6 "eatingout" 7 "entertainment"
label value type_good type_good

replace type_good = 1 if inrange(bien, 1,89) //alimentos
replace type_good = 2 if inrange(bien, 90,92) //alcohol&smoke
replace type_good = 3 if inrange(bien, 101,122) //bienes de consumo no alimenticios (tocador, limpieza)
replace type_good = 4 if inrange(bien, 123,131) //ropa
replace type_good = 5 if inrange(bien, 132,146) //bienes durables (TV, plancha)
replace type_good = 6 if inrange(bien, 132,146) //comida fuera del hogar
replace type_good = 7 if inrange(bien, 301,322) //entretenimiento y turismo

// b) define non current goods
gen current_good = .

replace current_good = 1 if inlist(type_good,1,2,3,4,6,7) 
replace current_good = 0 if type_good==3 //bienes durables (TV, plancha)
stop

// c) define date of purchases
// problem: dates of purchase is different among goods

/* FOR FOOD and alcohol&smoke


. tab type_good fecha

              |   8. ¿Cuando fue la última vez que compró  .... para
              |                       su hogar?
    type_good |      Ayer  Últimos 7  Últimos 1  Más de 15      Nunca |     Total
--------------+-------------------------------------------------------+----------
         food |     2,190     14,768      4,086      4,895        552 |    26,491 
alcohol&smoke |        47         68         12          6          1 |       134 
--------------+-------------------------------------------------------+----------
        Total |     2,237     14,836      4,098      4,901        553 |    26,625 

//FOR bath&cleaning 15 days
// FOR clothes 3 months
// FOR eatingout 7 days
// FOR entertainment last month	

Solution:
For food and alcohol&smoke, a) we reimputate month of purchase to january if he or she answered last 15 days or more that 15 days and the date of the survey is earlier that Feb 15th.
b) A few march purchases need to be deflacted to feb2020
For the rest, we cannot discriminate between a purchase done within the timespan of the question, so we keep the spending date in FEB2020


           |   8. ¿Cuando fue la
           |    última vez que
date_consu | compró  .... para su
mption_sur |        hogar?
       vey | Últimos 1  Más de 15 |     Total
-----------+----------------------+----------
    1Feb20 |        63         45 |       108 
    2Feb20 |        36         70 |       106 
    3Feb20 |       117        193 |       310 
    4Feb20 |       150        204 |       354 
    5Feb20 |       192        174 |       366 
    6Feb20 |       171        162 |       333 
    7Feb20 |       208        204 |       412 
    8Feb20 |       159        179 |       338 
    9Feb20 |        53         75 |       128 
   10Feb20 |       256        272 |       528 
   11Feb20 |       173        250 |       423 
   12Feb20 |       293        259 |       552 
   13Feb20 |       176        278 |       454 
   14Feb20 |       170        213 |       383 
   15Feb20 |       156        176 |       332 
   16Feb20 |        22         34 |        56 
   17Feb20 |       122        183 |       305 
   18Feb20 |       136        158 |       294 
   19Feb20 |       248        311 |       559 
... and keeps going


           |   8. ¿Cuando fue la
           |    última vez que
date_consu | compró  .... para su
mption_sur |        hogar?
       vey |      Ayer  Últimos 7 |     Total
-----------+----------------------+----------
..........
    1Mar20 |        11         47 |        58 
    3Mar20 |         6         13 |        19 
    4Mar20 |         6         13 |        19 
-----------+----------------------+----------
     Total |     2,236     14,793 |    17,029 



*/
	 
/*
// c) define frequency of purchases
// problem:
we dont know how recurrent are the purchased of different goods
FOR FOOD and alcohol&smoke
              |   8. ¿Cuando fue la última vez que compró  .... para
              |                       su hogar?
    type_good |      Ayer  Últimos 7  Últimos 1  Más de 15      Nunca |     Total
--------------+-------------------------------------------------------+----------
         food |    10,751     80,381     22,814     28,394      2,426 |   144,766 
alcohol&smoke |       264        374         36         46          1 |       721 
--------------+-------------------------------------------------------+----------
        Total |    11,015     80,755     22,850     28,440      2,427 |   145,487 

FOR bath&cleaning 15 days
FOR clothes 3 months
FOR eatingout 7 days
FOR entertainment last month	

solution:
we make the following assumptions
food and alcohol = 7 days
food and alcohol = half a month
clothes = 3 months
eatingout = 7 days
entertainment = a month
we use a standard month of 30.42 days
we convert all expenditures to montly equivalent multiplying or dividing each type of product by the proper ratio
*/




*/

// b) homogenize currencies
	* We move everything to bolivares February 2020, given that there we have more sample size // 2=dolares, 3=euros, 4=colombianos // 
		*Nota: Used the exchange rate of the doc "exchenge_rate_price", which comes from http://www.bcv.org.ve/estadisticas/tipo-de-cambio

/* tab moneda (number of spending obs. by currency)

      10b. Moneda |      Freq.     Percent        Cum.
------------------+-----------------------------------
        Bolívares |    131,356       91.18       91.18
          Dólares |      2,488        1.73       92.90
            Euros |         20        0.01       92.92
Pesos Colombianos |     10,205        7.08      100.00
------------------+-----------------------------------
            Total |    144,069      100.00
*/
		
global dolar_to_bol = 73460.1238
global euro_to_bol = 80095.41371177
global col_to_bol = 21.66060704812

gen gasto_bol = gasto if 