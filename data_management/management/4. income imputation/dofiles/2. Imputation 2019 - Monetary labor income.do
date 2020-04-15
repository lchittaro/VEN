********************************************************************************
*** ENCOVI 2019 - Income imputation: MONETARY LABOR INCOME 
********************************************************************************
 /*===========================================================================
Country name:	Venezuela
Year:			2014-2019
Survey:			ENCOVI
Vintage:		
Project:	
---------------------------------------------------------------------------
Authors:			
Dependencies:		The World Bank
Creation Date:		March, 2020
Modification Date:  
Output:			

Note: Income imputation - Identification missing values
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
				global path "C:\Users\wb563583\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
				global pathoutexcel "C:\Users\wb563583\Github\VEN\data_management\management\4. income imputation\output"
		}
	    if $lauta {

		}
		if $trini   {
				global rootpath "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI"
                global rootpath2 "C:\Users\WB469948\OneDrive - WBG\LAC\Venezuela"
				global path "C:\Users\WB469948\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
				global pathdo "$rootpath2\Income Imputation\dofiles"
		}
		
		if $male   {
		        global path "C:\Users\WB550905\WBG\Christian Camilo Gomez Canon - ENCOVI\Databases ENCOVI 2019\data_management\output\for imputation"
				global pathoutexcel "C:\Users\wb550905\Github\VEN\data_management\management\4. income imputation\output"

		}


///*** OPEN DATABASE ***///
	use "$path\ENCOVI_forimputation_2019.dta", clear

	* Cuántos queremos imputar
	mdesc ila_m if inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.) 
		// if me decís que recibiste pero ila monteario missing Ó estás ocupado, no decís que no recibís ila_m (eso sería un verdadero missing) y no contestás un monto de ila no mon.
		* Check: da ok! Igual que la cantidad de miss3

///*** VARIABLES FOR MINCER EQUATION ***///

	global xvar	edad edad2 agegroup hombre relacion_comp npers_viv miembros estado_civil region_est1 entidad municipio ///
				tipo_vivienda_hh material_piso_hh tipo_sanitario_comp_hh propieta_hh auto_hh /*anio_auto_hh*/ heladera_hh lavarropas_hh	computadora_hh internet_hh televisor_hh calentador_hh aire_hh tv_cable_hh microondas_hh  ///
				/*seguro_salud*/ afiliado_segsalud_comp ///
				nivel_educ ///
				tarea sector_encuesta categ_ocu total_hrtr ///
				c_sso c_rpv c_spf c_aca c_sps c_otro ///
				cuenta_corr cuenta_aho tcredito tdebito no_banco ///
				aporte_pension clap ingsuf_comida comida_trueque

* Identifying missing values in potential independent variables for Mincer equation
	*Note: "mdesc" displays the number and proportion of missing values for each variable in varlist.
	mdesc $xvar if ocup_o_rtarecibenilamon==1 // Universo: los que reportaron recibir (caso 1.a) o ocupados (caso 2)
		// few % of missinf values except nivel_educ
		// c_* will only be useful if we see divided by categ_ocup as they are only defined for workers who are not independent workers or employers
		
	/* To perform imputation by linear regression all the independent variables need have completed values, so we re-codified missing 
	values in the independent variables as an additional category. The missing values in the dependent variable are estimated from
	the posterior distribution of model parameters or from the large-sample normal approximation of the posterior distribution*/

	global xvar1 edad edad2 agegroup hombre relacion_comp npers_viv miembros total_hrtr_sinmis ///
	    dum_agegrou_1 dum_agegrou_2 dum_agegrou_3 dum_agegrou_4 dum_agegrou_5 dum_agegrou_6 ///
		dum_agegrou_7 dum_agegrou_8 dum_relacio_1 dum_relacio_2 dum_relacio_3 dum_relacio_4 dum_relacio_5 ///
		dum_relacio_6 dum_relacio_7 dum_relacio_8 dum_relacio_9 dum_relacio_10 dum_relacio_11 ///
		dum_relacio_12 dum_relacio_13 dum_estado__1 dum_estado__2 dum_estado__3 dum_estado__4 ///
		dum_estado__5 dum_estado__6 dum_region__1 dum_region__2 dum_region__3 dum_region__4 ///
		dum_region__5 dum_region__6 dum_region__7 dum_region__8 dum_region__9 dum_municip_1 dum_municip_2 ///
		dum_municip_3 dum_municip_4 dum_municip_5 dum_municip_6 dum_municip_7 dum_municip_8 ///
		dum_municip_9 dum_municip_10 dum_municip_11 dum_municip_12 dum_municip_13 dum_municip_14 ///
		dum_municip_15 dum_municip_16 dum_municip_17 dum_municip_18 dum_municip_19 dum_municip_20 ///
		dum_municip_21 dum_municip_23 dum_municip_24 dum_municip_25 dum_municip_27 dum_tipo_vi_1 ///
		dum_tipo_vi_2 dum_tipo_vi_3 dum_tipo_vi_4 dum_tipo_vi_5 dum_tipo_vi_6 dum_tipo_vi_7 dum_tipo_vi_8 ///
		dum_propiet_0 dum_propiet_1 dum_propiet_2 dum_auto_hh_0 dum_auto_hh_1 dum_auto_hh_2 ///
		dum_helader_0 dum_helader_1 dum_helader_2 dum_lavarro_0 dum_lavarro_1 dum_lavarro_2 ///
		dum_computa_0 dum_computa_1 dum_computa_2 dum_interne_0 dum_interne_1 dum_interne_2 dum_televis_0 ///
		dum_televis_1 dum_televis_2 dum_calenta_0 dum_calenta_1 dum_calenta_2 dum_aire_hh_0 ///
		dum_aire_hh_1 dum_aire_hh_2 dum_tv_cabl_0 dum_tv_cabl_1 dum_tv_cabl_2 dum_microon_0 ///
		dum_microon_1 dum_microon_2 dum_afiliad_1 dum_afiliad_2 dum_afiliad_3 dum_afiliad_4 ///
		dum_afiliad_5 dum_afiliad_6 dum_afiliad_7 dum_nivel_e_1 dum_nivel_e_2 dum_nivel_e_3 dum_nivel_e_4 ///
		dum_nivel_e_5 dum_nivel_e_6 dum_nivel_e_7 dum_nivel_e_8 dum_asiste__0 dum_asiste__1 ///
		dum_asiste__2 dum_asiste__3 dum_asiste__4 dum_asiste__5 dum_asiste__6 dum_asiste__7 dum_asiste__8 ///
		dum_asiste__9 dum_asiste__10 dum_asiste__11 dum_asiste__12 dum_asiste__13 dum_asiste__14 ///
		dum_asiste__15 dum_asiste__16 dum_tarea_s_1 dum_tarea_s_2 dum_tarea_s_3 dum_tarea_s_4 ///
		dum_tarea_s_5 dum_tarea_s_6 dum_tarea_s_7 dum_tarea_s_8 dum_tarea_s_9 dum_tarea_s_10 ///
		dum_tarea_s_11 dum_sector__1 dum_sector__2 dum_sector__3 dum_sector__4 dum_sector__5 dum_sector__6 ///
		dum_sector__7 dum_sector__8 dum_sector__9 dum_sector__10 dum_sector__11 ///
		dum_categ_o_1 dum_categ_o_3 dum_categ_o_5 dum_categ_o_6 dum_categ_o_7 dum_categ_o_8 dum_categ_o_9 ///
		dum_categ_o_10 dum_c_sso_s_0 dum_c_sso_s_1 dum_c_sso_s_2 dum_c_rpv_s_0 dum_c_rpv_s_1 ///
		dum_c_rpv_s_2 dum_c_spf_s_0 dum_c_spf_s_1 dum_c_spf_s_2 dum_c_aca_s_0 dum_c_aca_s_1 ///
		dum_c_aca_s_2 dum_c_sps_s_0 dum_c_sps_s_1 dum_c_sps_s_2 dum_c_otro__0 dum_c_otro__1 dum_c_otro__2 ///
		dum_cuenta__0 dum_cuenta__1 dum_cuenta__2 dum_cuenta__0 dum_cuenta__1 dum_cuenta__2 ///
		dum_tcredit_0 dum_tcredit_1 dum_tcredit_2 dum_tdebito_0 dum_tdebito_1 dum_tdebito_2 dum_no_banc_0 ///
		dum_no_banc_1 dum_no_banc_2 dum_aporte__1 dum_aporte__2 dum_aporte__3 dum_aporte__4 ///
		dum_aporte__5 dum_aporte__6 dum_clap_si_0 dum_clap_si_1 dum_clap_si_2 dum_ingsuf__0 dum_ingsuf__1 ///
		dum_ingsuf__2 dum_comida__0 dum_comida__1 dum_comida__2
	
	* Nuestra idea para laboral monetario
		*local nuestrasvars edad edad2 hombre relacion_comp npers_viv estado_civil entidad tipo_vivienda_hh propieta_hh microondas_hh nivel_educ afiliado_segsalud_comp no_banco_sinmis
	
	* Dependent variable
	gen log_ila_m = ln(ila_m) if ila_m!=.
	

///*** CHECKING WHICH VARIABLES MAXIMIZE R2 ***///
	
	** LASSO
		/* 	LASSO is one of the first and still most widely used techniques employed in machine learning. 
		For this specification, you may want to use the command lassoregress. 
		You will first need to install the package elasticregress, using the command line ssc install elasticregress. 
		For the purposes of this exercise, please use as argument for the Lasso command set seed 1 and the default number of folds to be 10. */
		
		*set seed 1
		
		lassoregress log_ila_m $xvar1 if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, numfolds(5)
		display e(varlist_nonzero)
		local lassovars = e(varlist_nonzero)
		
	** Stepwise (pr usa Chris; Trini usa backward)
		* ??
	
	** Vselect
		* Se puede usar R2adjustado como criterio. Ojo, no se puede poner variable como factor variables 
		* return - rpret list
	
	vselect log_ila_m $xvar1 if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, best
	
	* Best: model with XX vars. Copy and paste them here:
	* CAMBIAR CUANDO CORRA CON LA NUEVA BASE
	*local vselectvars categ_ocu_sinmis clap_sinmis comida_trueque_sinmis sector_encuesta_sinmis auto_hh_sinmis ///
					hombre total_hrtr_sinmis ingsuf_comida_sinmis tdebito_sinmis relacion_comp region_est1 ///
					tv_cable_hh_sinmis entidad tarea_sinmis lavarropas_hh_sinmis tcredito_sinmis material_piso_hh ///
					propieta_hh nivel_educ_sinmis cuenta_aho_sinmis municipio heladera_hh_sinmis televisor_hh_sinmis ///
					aporte_pension_sinmis tipo_sanitario_comp_hh computadora_hh_sinmis cuenta_corr_sinmis edad
	
	/*	vselect log_ila_m `nuestrasvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1, backward r2adj
		display r(predlist)
		local vselectvars2 = r(predlist)	*/
		
	
///*** EQUATION ***///
	
	*Obs.: should not be done with "pondera"
	
	*reg log_ila_m `xvar1' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0  // Da peor
	*reg log_ila_m `nuestrasvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0  // Da peor
	
	reg log_ila_m `lassovars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 // R2ajustado .1433
	reg log_ila_m `vselectvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 // R2ajustado .1436, mejor que Lasso

	set more off
	mi set flong
	set seed 66778899
	mi register imputed log_ila_m
	mi impute regress log_ila_m `vselectvars' if log_ila_m>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0, add(1) rseed(66778899) force noi 
	mi unregister log_ila_m
	* Obs.: _mi_m es la variable que crea Stata luego de la imputacion e identifica cada base
		*Ej. si haces 20 imputaciones _mi_m tendra valores de 0 a 20, donde 0 corresponde a la variable sin imputar e 1 a 20 a las bases con un posible valor para los missing values
	
///*** REPLACING MISSINGS BY IMPUTED VALUES ***///

	foreach x of varlist ila_m {
	gen `x'2=.
	* Genero var. con valores preliminares de los missing a imputar
	replace `x'2= exp(log_`x') if d`x'_miss3==1 // miss3 junta los 2 tipos de missing
	* Si algun valor imputado es menor que el menor ila_m, reemplazar con el menor ila_m
	sum `x' if `x'>0 & ocup_o_rtarecibenilamon==1 & recibe_ingresolab_mon!=0 & _mi_m==0 // _mi_m==0 es la variable sin imputar
	scalar min_`x'`j'=r(min)
	replace `x'2=min_`x' if (`x'2<min_`x' & d`x'_miss3==1)
	* Imputo reemplazando en variable ila_m en las variables imputadas (varias porque hay cuantas replicas como repeticiones tenga el vselect)
	replace `x'=`x'2 if (d`x'_miss3==1 & _mi_m!=0)
	drop `x'2
	}
	
	mdesc ila_m if _mi_m==0 & (inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.)) 
	mdesc ila_m if _mi_m==1 & (inlist(recibe_ingresolab_mon,1,2,3) | (ocupado==1 & recibe_ingresolab_mon!=0 & ila==.))  // Cheking we do not have "incompleted" values in monetary labor income after imputation
	* Check: Da ok! Se imputaron todos los missing a imputar
	
	gen imp_id=_mi_m // Para que se conserve esta variable luego
	*mi unset // Borramos cosas que se generan de la imputación:
	char _dta[_mi_style] 
	char _dta[_mi_marker] 
	char _dta[_mi_M] 
	char _dta[_mi_N] 
	char _dta[_mi_update] 
	char _dta[_mi_rvars] 
	char _dta[_mi_ivars] 
	drop _mi_id _mi_miss _mi_m

	drop if imp_id==0 // Droppea la variable sin imputar
	collapse (mean) ila_m, by(interview__key interview__id quest com) // da lo mismo usando by(id com)
	
	* Chequear que el número de obs. sea el mismo que en la base original
	
	rename ila_m ila_m_imp1
	save "$pathout\VEN_ila_m_imp1.dta", replace

	
********************************************************************************
*** Analyzing imputed data
********************************************************************************

use "$path\ENCOVI_forimputation_2019.dta", clear
capture drop _merge
merge 1:1 interview__key interview__id quest com using "$path\VEN_ila_m_imp1.dta" // da lo mismo usando id com

foreach x of varlist ila_m {
gen log_`x'=ln(`x')
gen log_`x'_imp1=ln(`x'_imp1)
}

cd "$pathoutexcel\income_imp"
*** Comparing not imputed vs. imputed monetary labor income distribution
foreach x in ila_m {
twoway (kdensity log_`x' if `x'>0 & ocup_o_rtarecibenilamon==1, lcolor(blue) bw(0.45)) ///
       (kdensity log_`x'_imp1 if `x'_imp1>0 & ocup_o_rtarecibenilamon==1, lcolor(red) lp(dash) bw(0.45)), ///
	    legend(order(1 "Not imputed" 2 "Imputed")) title("") xtitle("") ytitle("") graphregion(color(white) fcolor(white)) name(kd_`x'1, replace) saving(kd_`x'1, replace)
graph export "kd_`x'1.png", replace
}

foreach x in ila_m {
	tabstat `x' if `x'>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux1=r(StatTotal)'
	tabstat `x'_imp1 if `x'_imp1>0, stat(mean p10 p25 p50 p75 p90) save
	matrix aux2=r(StatTotal)'
	matrix imp=nullmat(imp)\(aux1,aux2)
}

matrix rownames imp="2019"
matrix list imp

putexcel set "$pathoutexcel\VEN_income_imputation_2019_MA.xlsx", sheet("labor_incmon_imp_stochastic_reg") modify
putexcel A3=matrix(imp), names
matrix drop imp


********************************************************************************
********************************************************************************
*** Imputation model for labor income: using chained equations
********************************************************************************
********************************************************************************

* Hacer?
