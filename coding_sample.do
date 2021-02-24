*---------------------------------------------------*
* 	 Impactos del COVID en el mercado de vivienda	*					
*			 	 RA Magdalena Cortina				*
*---------------------------------------------------*

set more off
clear all

* Magdalena
global path = "/Users/magdalena/Dropbox/0201 Pandemic Impacts on Housing/"
global pathD = "${path}01 Data/"
global pathR = "${path}04 Results/"

*use "${pathD}Data_1.dta"
*use "${pathD}Data_2.dta"
use "${pathD}Data_3.dta"

*** New variables
*---------------------------------------------------------*

** Pandemic Variable (before and after the pandemic started)
gen pandemic=year==2020 & month>=3
label variable pandemic "Pandemic"
label define pand 0 "Before the pandemic" 1 "After the pandemic"
label values pandemic pand

** Seasonal quarter variable
gen quarter=.
replace	quarter	= 1		if	month==12 | month==1  | month==2
replace	quarter	= 2		if	month==3  | month==4  | month==5
replace	quarter	= 3		if	month==6  | month==7  | month==8
replace	quarter	= 4		if	month==9  | month==10 | month==11

label var quarter "Year seasons"
label define season 1 "Summer" 2 "Autumn" 3 "Winter" 4 "Spring"
label values quarter season

* Interaction variable
gen pand_q		=	pandemic*month_q
gen LPE_q		=	LPE*month_q
gen pand_LPE	=	pandemic*LPE

label var pand_q 	"Pandemix * Quarantine month"
label var LPE_q 	"LPE * Quarantine month"
label var pand_LPE	"Pandemic * LPE"


replace LPE = 0 if LPE == .

*** Cleaning observations
*---------------------------------------------------------*

** keeping only comunas that have 5 obs before and after the pandemic

	*bysort comuna: egen before=count(month) if pandemic==0
	*bysort comuna: egen after=count(month) if pandemic==1
	*sort comuna year month
	*order before after comuna year month
	*bysort comuna: replace before = before[_n-1] if missing(before)
	*gsort comuna after
	*bysort comuna: replace after = after[_n-1] if missing(after)

*drop if before < 5 | after < 5

*codebook comuna
* 36 comunas with 5 observations before and after the pandemic

** Variables that indicate how many observations per category (house/apt, sale/rent)

sort comuna year month quarter 
order comuna year month quarter


global X1 "p_sale_house p_rent_house p_sale_apt p_rent_apt m_sale_house m_rent_house m_sale_apt m_rent_apt"

foreach i of global X1 {
		bysort comuna: egen b_`i'=count(`i') if pandemic==0
		gsort comuna b_`i'
		bysort comuna: replace b_`i' = b_`i'[_n-1] if missing(b_`i')

		bysort comuna: egen a_`i'=count(`i') if pandemic==1
		gsort  comuna a_`i'
		bysort comuna: replace a_`i' = a_`i'[_n-1] if missing(a_`i')

	}
	
		** example: the variable b_p_rent_apt represents the amount of observations before the pandemic for mean price (p) of rent apts.


** Global outcomes
global out1_mean	= "p_rent_house p_sale_house p_rent_apt p_sale_apt"
global out2_med		= "m_rent_house m_sale_house m_rent_apt m_sale_apt"

global out			= "out1_mean out2_med"

** Global independent variables
global L1 = "pandemic LPE LPE_q"
global L2 = "pandemic LPE pand_q"
global L3 = "pandemic LPE c.LPE#c.days_q"

foreach z of global out1_mean {

	reg `z' $L1 i.cod_comuna i.quarter if b_`z'>=5 & a_`z'>=5, vce(cl cod_comuna) 
	est store R_L1_`y'
	
	reg `z' $L2 i.cod_comuna i.quarter if b_`z'>=5 & a_`z'>=5, vce(cl cod_comuna) 
	est store R_L2_`y'
	
	reg `z' $L3 i.cod_comuna i.quarter if b_`z'>=5 & a_`z'>=5, vce(cl cod_comuna) 
	margins, dydx(*) post
	est store R_L3_`y'
	
	esttab R_L1_`y' using reg1.tex, append
	esttab R_L2_`y'	using reg2.tex, append
	esttab R_L3_`y' using reg3.tex, append
	
}
* b_`z'>=5 & a_`i'>=5 restringe que hayan al menos 5 obs antes/despues para esa estimación


*---------------------------------------------------------*
* second part (run until line 51)

** Variables that indicate how many observations per category (sale/rent)
foreach i of global X1 {
		bysort comuna: egen b_`i'=count(`i') if pandemic==0
		gsort comuna b_`i'
		bysort comuna: replace b_`i' = b_`i'[_n-1] if missing(b_`i')

		bysort comuna: egen a_`i'=count(`i') if pandemic==1
		gsort  comuna a_`i'
		bysort comuna: replace a_`i' = a_`i'[_n-1] if missing(a_`i')

	}

	
global Z1 "sale_price rent_price"
global Z1 "sale_price_m rent_price_m"


foreach z of global Z1 {

	reg `z' $L1 i.cod_comuna i.quarter perc_apts if b_`z'>=5 & a_`z'>=5, vce(cl cod_comuna) 
	est store R_L1_`z'
	
	reg `z' $L2 i.cod_comuna i.quarter perc_apts if b_`z'>=5 & a_`z'>=5, vce(cl cod_comuna) 
	est store R_L2_`z'
	
	reg `z' $L3 i.cod_comuna i.quarter perc_apts if b_`z'>=5 & a_`z'>=5, vce(cl cod_comuna) 
	margins, dydx(*) post
	est store R_L3_`z'
	
	esttab R_L1_`z' using reg_z1.tex, drop (*.cod_comuna *.quarter) append
	esttab R_L2_`z'	using reg_z2.tex, drop (*.cod_comuna *.quarter) append
	esttab R_L3_`z' using reg_z3.tex, drop (*.cod_comuna *.quarter) append
	
}
